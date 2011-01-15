require "rjava"
require "antlr4ruby"
require "yaml"

require "#{File.dirname(__FILE__)}/tree_visitor"
require "#{File.dirname(__FILE__)}/processors/java_code_parser"
require "#{File.dirname(__FILE__)}/processors/output_indenter"

require "#{File.dirname(__FILE__)}/conversion_controller"
require "#{File.dirname(__FILE__)}/tools"
require "#{File.dirname(__FILE__)}/java_types"
require "#{File.dirname(__FILE__)}/java_modules"
require "#{File.dirname(__FILE__)}/java_methods"

require "#{File.dirname(__FILE__)}/matchers/core_matchers"
require "#{File.dirname(__FILE__)}/matchers/class_matchers"
require "#{File.dirname(__FILE__)}/matchers/statement_matchers"
require "#{File.dirname(__FILE__)}/matchers/expression_matchers"
require "#{File.dirname(__FILE__)}/matchers/variable_matchers"

class Dir
  def self.dir_glob(dir, pattern)
    files = nil
    chdir dir do
      files = Dir.glob(pattern).sort
    end
    files
  end
end

module Java2Ruby
  class Converter
    EPSILON = "<epsilon>".to_sym
    
    attr_accessor :java_file, :basename, :ruby_file, :controller, :converter_id, :size, :error
    attr_accessor :current_generator, :statement_context
    attr_reader :input, :input_tree, :output
    
    def initialize(java_file, conversion_rules = {}, ruby_dir = nil, controller = nil, converter_id = nil, size = nil)
      @java_file = java_file
      @prefix = conversion_rules["prefix"] || "Java"
      @prefix_class_names = conversion_rules["prefix_class_names"] || []
      @constants = conversion_rules["constants"] || []
      @no_constants = conversion_rules["no_constants"] || []
      @constant_name_mapping = conversion_rules["constant_name_mapping"] || {}
      @field_name_mapping = conversion_rules["field_name_mapping"] || {}
      @explicit_calls = conversion_rules["explicit_calls"] || {}
      @basename = File.basename @java_file, ".java"
      @ruby_file = "#{ruby_dir || File.dirname(@java_file)}/#{JavaClassType.new self, nil, nil, nil, [@basename]}.rb"
      @converter_id = converter_id
      @size = size
    end
    
    def converter
      self
    end
    
    def is_constant?(name)
      @constants.include?(name) || (!@no_constants.include?(name) && name =~ /^[A-Z]/)
    end
    
    def ruby_constant_name(name)
      @constant_name_mapping[name] || RJava.ruby_constant_name(name)
    end
    
    def ruby_class_name(package, names)
      if @prefix_class_names.include?(names.first)
        name_parts = []
        name_parts << package.ruby_name unless package.nil? or package.root?
        name_parts << "#{@prefix}#{names.first}"
        name_parts.concat names[1..-1]
        name_parts.join "::"
      else
        nil
      end
    end
    
    def ruby_field_name(name)
      @field_name_mapping[name] || RJava.lower_name(name)
    end
    
    def ruby_method_name(name, call = true)
      if call and @explicit_calls.include? name
        @explicit_call_counter += 1
        "#{RJava.ruby_method_name name}___#{@package.names.join '_'}_#{RJava.lower_name @basename}_#{@explicit_call_counter}"
      else
        RJava.ruby_method_name name
      end
    end
    
    def generate_output(tree)
      @current_generator = nil
      @statement_context = nil
      @elements = tree[:children]
      @next_element_index = 0
      @next_element = @elements.first
      @explicit_call_counter = -1
      compilation_unit = CompilationUnit.new self
      { :type => :output_tree, :children => compilation_unit.output_parts.first }
    end
    
    def current_module
      @current_generator.current_module
    end
    
    def current_method
      @current_generator.current_method
    end
    
    def switch_statement_context(context)
      context.parent_context = @statement_context
      @statement_context = context
      yield
      @statement_context = @statement_context.parent_context
    end
    
    def puts_output(*parts)
      @current_generator.puts_output *parts
    end
    
    def indent_output
      @current_generator.indent_output do
        yield
      end
    end
        
    def convert
      @input = File.read(java_file).force_encoding("ASCII-8BIT")
      @input_tree = JavaCodeParser.new.parse_java @input
      @output_tree = generate_output @input_tree
      @output = OutputIndenter.new.process @output_tree
      File.open(ruby_file, "w") { |file| file.write @output }
    end
    
    attr_reader :next_element
    
    def process_children(element)
      parent_elements = @elements
      parent_next_element_index = @next_element_index
      
      @elements = element[:children]
      @next_element_index = 0
      @next_element = @elements.first
      result = yield
      raise ArgumentError, "Elements of #{element} not processed: #{@elements[@next_element_index..-1].join(", ")}" if not @next_element_index == @elements.size
      
      @elements = parent_elements
      @next_element_index = parent_next_element_index
      @next_element = @elements && @elements[@next_element_index]
      
      result
    end
    
    def next_is?(*names)
      next_element && names.include?(next_element[:internal_name])
    end
    
    def match(*names)
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of #{names.inspect}" if not names.include? next_element[:internal_name]
      element = consume
      process_children element do
        yield if block_given?
      end
      element[:text]
    end
    
    def match_name
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of name string" if not next_element[:internal_name].is_a? String
      consume[:text] # string elements have no children
    end
    
    def try_match(*names)
      return nil if not next_is?(*names)
      element = consume
      process_children element do
        yield if block_given?
      end
      element[:text]
    end
    
    def buffer_match(*names)
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of #{names.inspect}" if not names.include? next_element[:internal_name]
      element = consume
      lambda {
        process_children element do
          yield
        end
      }
    end
    
    def loop_match(name)
      loop do
        try_match(name) do
          yield
        end or break
      end
    end
    
    def multi_match(*options)
      result = nil
      index = 0
      loop do
        names = options.map { |option| option[index] }
        break if not names.any?
        part = names.all? ? match(*names) : try_match(*names)
        break if part.nil?
        options.reject! { |option| option[index] != part }
        result ||= ""
        result << part
        index += 1
      end
      result
    end
    
    def consume
      current_element = next_element
      
      # handle comments
      if current_element[:hidden_tokens]
        current_element[:hidden_tokens].each do |hidden_token|
          if hidden_token[:type] == JavaLexer::LINE_COMMENT
            @current_generator.single_line_comment hidden_token[:text][2..-1].strip
          elsif hidden_token[:type] == JavaLexer::COMMENT
            lines = []
            hidden_token[:text].split("\n").each do |line|
              line.strip!
              line.gsub! /\*\/$/, ""
              line.gsub! /^\/?\*+/, ""
              line.strip!
              lines << line
            end
            @current_generator.multi_line_comment lines
          elsif hidden_token[:text] == "\r" || hidden_token[:text] == "\n"
            @current_generator.new_line
          end
        end
      end
      
      @next_element_index += 1
      @next_element = @elements[@next_element_index]
      
      current_element
    end
    
    def compose_arguments(arguments, force_braces = false)
      if (arguments.nil? || arguments.empty?) && !force_braces
        []
      else
        parts = ["("]
        arguments and arguments.each do |argument|
          parts << ", " if parts.size > 1
          parts << argument
        end
        parts << ")"
        parts
      end
    end
  end
  
  class CompilationUnit
    include OutputGenerator
    
    def initialize(converter)
      super converter
    end
    
    def write_output
      @converter.match_compilationUnit
    end
    
    def current_module
      nil
    end
    
    def current_method
      nil
    end
  end  
end
