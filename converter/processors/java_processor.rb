module Java2Ruby
  class JavaProcessor
    EPSILON = "<epsilon>".to_sym

    attr_accessor :current_generator, :statement_context
    attr_reader :next_element

    def initialize(conversion_rules)
      @prefix = conversion_rules["prefix"] || "Java"
      @prefix_class_names = conversion_rules["prefix_class_names"] || []
      @constants = conversion_rules["constants"] || []
      @no_constants = conversion_rules["no_constants"] || []
      @constant_name_mapping = conversion_rules["constant_name_mapping"] || {}
      @field_name_mapping = conversion_rules["field_name_mapping"] || {}
      @explicit_calls = conversion_rules["explicit_calls"] || {}
    end
    
    def process(tree)
      @current_generator = nil
      @statement_context = nil
      @elements = tree[:children]
      @next_element_index = 0
      @next_element = @elements.first
      @explicit_call_counter = -1
      compilation_unit = CompilationUnit.new self
      { :type => :output_tree, :children => compilation_unit.output_parts.first }
    end
    
    def converter
      self
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
    
    module OutputGenerator
      attr_reader :converter, :comment_lines
      
      def initialize(converter)
        @converter = converter
        @comment_lines = []
        @current_line_comment = false
        if converter && converter.current_generator
          @generator_comments = converter.current_generator.comment_lines.dup
          converter.current_generator.comment_lines.clear
        else
          @generator_comments = []
        end
      end
      
      def in_context(&block)
        raise if @converter.current_generator == self
        last_generator = @converter.current_generator
        @converter.current_generator = self
        result = block.call
        @converter.current_generator = last_generator
        result
      end
      
      def output_parts
        @output_lines = []
        @comment_lines.concat @generator_comments
        in_context do
          write_output
        end
        [@output_lines]
      end
      
      def new_line
        @current_line_comment = false
      end
      
      def single_line_comment(line)
        if @current_line_comment and not @output_lines.empty?
          @output_lines.last[:content] << " # #{line}"
        else
          @comment_lines << line
        end
        @current_line_comment = false
      end
      
      def multi_line_comment(lines)
        @comment_lines.concat lines
        @current_line_comment = false
      end
      
      def write_comments
        @comment_lines.shift while not @comment_lines.empty? and @comment_lines.first.empty?
        @comment_lines.pop while not @comment_lines.empty? and @comment_lines.last.empty?
        @output_lines.concat(@comment_lines.map { |comment| { :type => :output_line, :content => "# #{comment}" } })
        @comment_lines.clear
      end
      
      def puts_output(*parts)
        write_comments
        puts_output_without_comments(*parts)
        @current_line_comment = true
      end
      
      def puts_output_without_comments(*parts)
        lines = []
        combine_output_parts parts, lines
        @output_lines.concat lines
      end
      
      def combine_output_parts(parts, lines)
        parts.each do |part|
          case part
          when String, JavaType
            lines << { :type => :output_line, :content => "" } if lines.empty?
            lines.last[:content] << part.to_s
          when Array
            unless part.empty?
              lines.last[:content] << part.shift[:content] unless lines.empty?
              lines.concat part
            end
          else
            combine_output_parts part.output_parts, lines
          end
        end
      end
      
      def indent_output
        outer_array = @output_lines
        @output_lines = []
        yield
        write_comments
        outer_array << { :type => :output_block, :children => @output_lines }
        @output_lines = outer_array
      end
      
      def lower_name(name)
        RJava.lower_name name
      end
      
      def upper_name(name)
        new_word = false
        name.gsub(/./) { |char|
          case char
          when /[a-z]/
            new_word = true
            char.upcase
          when /[A-Z]/
            if new_word
              new_word = false
              "_" + char
            else
              char
            end
          else
            new_word = false
            char
          end
        }
      end
      
      def ruby_field_name(name)
        @converter.ruby_field_name name
      end
      
      def ruby_method_name(name, call = true)
        @converter.ruby_method_name name, call
      end  
    end
    
    class Expression
      attr_accessor :type, :output_parts, :result_used
      
      def initialize(type, *output_parts)
        @type = type
        @output_parts = output_parts
        @result_used = true
      end
      
      def to_s
        raise "Do not include Expression object into a string"
      end
      
      def combine(combiner, other_expression)
        other_type = other_expression.type
        combined_type = case
        when self.type == JavaType::STRING || other_type == JavaType::STRING
          JavaType::STRING
        else
          nil
        end
        Expression.new combined_type, self.typecast(combined_type), " #{combiner} ", other_expression.typecast(combined_type)
      end
      
      def typecast(target_type)
        case
        when target_type == JavaType::STRING && self.type != JavaType::STRING
          Expression.new JavaType::STRING, "RJava.cast_to_string(", self, ")"
        else
          self
        end
      end
    end
    
    class PostIncrementExpression < Expression
      def initialize(variable)
        super nil
        @variable = variable
      end
      
      def output_parts
        @result_used ? ["((", @variable, " += 1) - 1)"] : [@variable, " += 1"]
      end
    end
    
    class PostDecrementExpression < Expression
      def initialize(variable)
        super nil
        @variable = variable
      end
      
      def output_parts
        @result_used ? ["((", @variable, " -= 1) + 1)"] : [@variable, " -= 1"]
      end
    end
    
    class JavaPackage
      include OutputGenerator
      attr_reader :names
      
      def initialize(names = [])
        super nil
        @names = names
      end
      
      def <<(name)
        @names << name
        @ruby_names = nil
      end
      
      def root?
        @names.empty?
      end
      
      def ruby_name
        @ruby_names ||= @names.map{ |p| RJava.ruby_package_name p }.join('::')
      end
      
      ROOT = self.new
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
end

require "#{File.dirname(__FILE__)}/java_processor/java_types"
require "#{File.dirname(__FILE__)}/java_processor/java_modules"
require "#{File.dirname(__FILE__)}/java_processor/java_methods"

require "#{File.dirname(__FILE__)}/java_processor/core_matchers"
require "#{File.dirname(__FILE__)}/java_processor/class_matchers"
require "#{File.dirname(__FILE__)}/java_processor/statement_matchers"
require "#{File.dirname(__FILE__)}/java_processor/expression_matchers"
require "#{File.dirname(__FILE__)}/java_processor/variable_matchers"