require "rjava"
require "antlr4ruby"

non_verbose {
  require "#{File.dirname(__FILE__)}/JavaLexer"
  require "#{File.dirname(__FILE__)}/JavaParser"
}

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

class JavaLexer
  M_TOKENS_LIST = [nil, :m_t__25, :m_t__26, :m_t__27, :m_t__28, :m_t__29, :m_t__30, :m_t__31, :m_t__32, :m_t__33, :m_t__34, :m_t__35, :m_t__36, :m_t__37, :m_t__38, :m_t__39, :m_t__40, :m_t__41, :m_t__42, :m_t__43, :m_t__44, :m_t__45, :m_t__46, :m_t__47, :m_t__48, :m_t__49, :m_t__50, :m_t__51, :m_t__52, :m_t__53, :m_t__54, :m_t__55, :m_t__56, :m_t__57, :m_t__58, :m_t__59, :m_t__60, :m_t__61, :m_t__62, :m_t__63, :m_t__64, :m_t__65, :m_t__66, :m_t__67, :m_t__68, :m_t__69, :m_t__70, :m_t__71, :m_t__72, :m_t__73, :m_t__74, :m_t__75, :m_t__76, :m_t__77, :m_t__78, :m_t__79, :m_t__80, :m_t__81, :m_t__82, :m_t__83, :m_t__84, :m_t__85, :m_t__86, :m_t__87, :m_t__88, :m_t__89, :m_t__90, :m_t__91, :m_t__92, :m_t__93, :m_t__94, :m_t__95, :m_t__96, :m_t__97, :m_t__98, :m_t__99, :m_t__100, :m_t__101, :m_t__102, :m_t__103, :m_t__104, :m_t__105, :m_t__106, :m_t__107, :m_t__108, :m_t__109, :m_t__110, :m_t__111, :m_t__112, :m_t__113, :m_hex_literal, :m_decimal_literal, :m_octal_literal, :m_floating_point_literal, :m_character_literal, :m_string_literal, :m_enum, :m_assert, :m_identifier, :m_ws, :m_comment, :m_line_comment]
  undef_method :m_tokens
  def m_tokens
    __send__ M_TOKENS_LIST[@dfa29.predict(self.attr_input)]
  end
end

module Java2Ruby
  module ParseTreeExtensions
    attr_writer :internal_name
    
    def internal_name
      @internal_name ||= if attr_payload.is_a? String
        attr_payload.to_sym
      else
        attr_payload.get_text
      end
    end
    
    def handle_case_end
      case internal_name
      when :block
        @children[-2].handle_case_end
      when :blockStatement
        @children.first.handle_case_end
      when :statement
        case @children.first.internal_name
        when "break"
          @children.first.internal_name = :disabled_break if @children[1].internal_name == ";"
          true
        when "return", "throw"
          true
        when "if"
          @children[2].handle_case_end && (@children.size < 5 || @children[4].handle_case_end)
        else
          false
        end
      else
        false
      end
    end
  end
  
  class Converter
    include Org::Antlr::Runtime
    include Org::Antlr::Runtime::Debug
    
    EPSILON = "<epsilon>".to_sym
    
    attr_accessor :java_file, :basename, :ruby_file, :controller, :converter_id, :size, :error
    attr_accessor :current_generator
    
    def initialize(java_file, ruby_dir = nil, controller = nil, converter_id = nil, size = nil)
      @java_file = java_file
      @controller = controller || ConversionController.new
      @basename = File.basename @java_file, ".java"
      @ruby_file = "#{ruby_dir || File.dirname(@java_file)}/#{JavaClassType.new self, nil, nil, nil, [@basename]}.rb"
      @converter_id = converter_id
      @size = size
    end
    
    def converter
      self
    end
    
    def is_constant?(name)
      value = false
      @controller.is_constant_hooks.each do |hook|
        value = hook.call self, name, value
      end
      value
    end
    
    def ruby_constant_name(name)
      @controller.ruby_constant_name_hooks.each do |hook|
        ruby_name = hook.call self, name
        return ruby_name if ruby_name
      end
      RJava.ruby_constant_name name
    end
    
    def ruby_class_name(package, names)
      @controller.ruby_class_name_hooks.each do |hook|
        ruby_name = hook.call self, package, names
        return ruby_name if ruby_name
      end
      nil
    end
    
    def ruby_field_name(name)
      @controller.ruby_field_name_hooks.each do |hook|
        ruby_name = hook.call self, name
        return ruby_name if ruby_name
      end
      RJava.lower_name name
    end
    
    def ruby_method_name(name)
      RJava.ruby_method_name name
    end
    
    def input
      @input ||= File.read(java_file).force_encoding("ASCII-8BIT")
    end
    
    def parse_tree
      @parse_tree ||= begin
        stream = ANTLRStringStream.new(input)
        lexer = JavaLexer.new stream
        tokens = CommonTokenStream.new
        tokens.set_token_source lexer
        builder = ParseTreeBuilder.new "Java"
        parser = JavaParser.new tokens, builder
        parser.compilation_unit
        builder.get_tree
      end
    end
    
    def output
      @output ||= begin
        @current_generator = nil
        @elements = [parse_tree]
        @next_element_index = 0
        @next_element = @elements.first
        compilation_unit = CompilationUnit.new self, @basename 
        generate_indented_output "", compilation_unit.output_parts.first, 0
      end
    end
    
    def current_module
      @current_generator.current_module
    end
    
    def current_method
      @current_generator.current_method
    end
    
    def puts_output(*parts)
      @current_generator.puts_output *parts
    end
    
    def indent_output
      @current_generator.indent_output do
        yield
      end
    end
    
    def generate_indented_output(output, array, indention)
      array.each do |element|
        if element.is_a? Array
          generate_indented_output output, element, indention + 1
        else
          output << "#{'  ' * indention}#{element}\n"
        end
      end
      output
    end
    
    def convert
      result = self.output # only write when no exception raised, so we use local variable first
      File.open(ruby_file, "w") { |file| file.write result }
    end
    
    attr_reader :next_element
    
    def process_children(element)
      parent_elements = @elements
      parent_next_element_index = @next_element_index
      
      @elements = element.attr_children || []
      @next_element_index = 0
      @next_element = @elements.first
      result = yield
      raise ArgumentError, "Elements of #{element} not processed: #{@elements.join(", ")}" if not @next_element_index == @elements.size
      
      @elements = parent_elements
      @next_element_index = parent_next_element_index
      @next_element = @elements && @elements[@next_element_index]
      
      result
    end
    
    def next_is?(*names)
      next_element && names.include?(next_element.internal_name)
    end
    
    def match(*names)
      raise "Wrong match: #{next_element.internal_name.inspect} instead one of #{names.inspect}" if not names.include? next_element.internal_name
      element = consume
      process_children element do
        yield if block_given?
      end
      element.get_text
    end
    
    def match_name
      raise "Wrong match: #{next_element.internal_name.inspect} instead one of name string" if not next_element.internal_name.is_a? String
      consume.get_text # string elements have no children
    end
    
    def try_match(*names)
      return nil if not next_is?(*names)
      element = consume
      process_children element do
        yield if block_given?
      end
      element.get_text
    end
    
    def buffer_match(*names)
      raise "Wrong match: #{next_element.internal_name.inspect} instead one of #{names.inspect}" if not names.include? next_element.internal_name
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
      if current_element.attr_hidden_tokens
        current_element.attr_hidden_tokens.each do |hidden_token|
          if hidden_token.attr_type == JavaLexer::LINE_COMMENT
            @current_generator.single_line_comment hidden_token.get_text[2..-1].strip
          elsif hidden_token.attr_type == JavaLexer::COMMENT
            lines = []
            hidden_token.get_text.split("\n").each do |line|
              line.strip!
              line.gsub! /\*\/$/, ""
              line.gsub! /^\/?\*+/, ""
              line.strip!
              lines << line
            end
            @current_generator.multi_line_comment lines
          elsif hidden_token.get_text == "\r" || hidden_token.get_text == "\n"
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
  
  class CompilationUnit < OutputGenerator
    def initialize(converter, basename)
      super converter
      @basename = basename
    end
    
    def write_output
      @converter.match "<grammar Java>".to_sym do
        @converter.match_compilationUnit @basename
      end
    end
    
    def current_module
      nil
    end
    
    def current_method
      nil
    end
  end
  
  class ConversionController
    attr_reader :is_constant_hooks, :ruby_constant_name_hooks, :ruby_class_name_hooks, :ruby_field_name_hooks
    
    def initialize
      @is_constant_hooks = [lambda { |converter, name, value| name =~ /^[A-Z]/ }]
      @ruby_constant_name_hooks = []
      @ruby_class_name_hooks = []
      @ruby_field_name_hooks = []
      @current_converter_id = 0
      @pending_converters = {}
      @queued_converters = []
      @failed_converters = []
      @amount_to_convert = 0
      @converted_amount = 0
    end
    
    def add_files(src_dir, lib_dir, files)
      files.each do |file|
        src_file = "#{src_dir}/#{file}"  
        next if File.directory? src_file
        
        if File.extname(file) == ".java"
          lib_file_dir = "#{lib_dir}/#{File.dirname(file)}"
          mkdir_p lib_file_dir unless File.exist? lib_file_dir
          
          size = File.size src_file
          @amount_to_convert += size
          converter = Java2Ruby::Converter.new src_file, lib_file_dir, self, @current_converter_id, size
          if File.exist? converter.ruby_file
            @converted_amount += size
          else
            converter.controller = nil
            @current_converter_id += 1
            @pending_converters[converter.converter_id] = converter
            @queued_converters << converter
          end
        else
          lib_file = "#{lib_dir}/#{file}"
          lib_file_dir = File.dirname lib_file
          mkdir_p lib_file_dir unless File.exist? lib_file_dir
          cp src_file, lib_file unless File.exist? lib_file
        end
      end
    end
    
    def add_is_constant_hook(&hook)
      @is_constant_hooks << hook
    end
    
    def add_ruby_constant_name_hook(&hook)
      @ruby_constant_name_hooks << hook
    end
    
    def add_ruby_class_name_hook(&hook)
      @ruby_class_name_hooks << hook
    end
    
    def add_ruby_field_name_hook(&hook)
      @ruby_field_name_hooks << hook
    end
    
    def run(process_count)
      if process_count.nil?
        ConversionController.client_convert_loop self, self, true
      else
        File.delete "drburi" if File.exist? "drburi"
        process_count.to_i.times do
          fork do
            DRb.start_service
            sleep 0.1 until File.exist? "drburi"
            controller = DRbObject.new nil, File.read("drburi")
            ConversionController.client_convert_loop controller, self
          end
        end
        DRb.start_service nil, self
        File.open("drburi", "w") do |file|
          file.write DRb.uri
        end
        sleep 1 until @pending_converters.empty?
        File.delete "drburi"
      end
      
      puts "Conversions complete" + (@failed_converters.empty? ? "" : ", but some of them failed:")
      @failed_converters.each do |converter|
        puts "#{converter.java_file}: #{converter.error}"
      end
    end
    
    def fetch_converter
      converter = @queued_converters.shift
      percent = format "%.2f", (@converted_amount.quo(@amount_to_convert) * 100)
      print "java2ruby #{File.basename converter.java_file} (#{percent}% - #{@pending_converters.size} left)\n" if converter
      converter
    end
    
    def converter_complete(converter_id)
      converter = @pending_converters.delete converter_id
      @converted_amount += converter.size
      nil
    end
    
    def converter_failed(converter_id, error)
      converter = @pending_converters.delete converter_id
      @converted_amount += converter.size
      converter.error = error
      @failed_converters << converter
      puts "Conversion failed: #{converter.java_file} (#{converter.error})"
      nil
    end
    
    def self.client_convert_loop(remote_controller, local_controller, fail_on_error = false)
      loop do
        converter = remote_controller.fetch_converter
        break if converter.nil?
        begin
          converter.controller = local_controller
          converter.convert
          remote_controller.converter_complete converter.converter_id
        rescue Interrupt
          exit
        rescue Exception => e
          raise if fail_on_error
          remote_controller.converter_failed converter.converter_id, e.to_s
        end
      end
    end
  end
  
end

Org::Antlr::Runtime::Tree::ParseTree.class_eval do
  include Java2Ruby::ParseTreeExtensions
end

class NilClass
  def internal_name
    nil
  end
end