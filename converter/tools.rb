module Java2Ruby
  class OutputGenerator
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
        @output_lines.last << " # #{line}"
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
      @comment_lines.shift while !@comment_lines.empty? and @comment_lines.first.empty?
      @comment_lines.pop while !@comment_lines.empty? and @comment_lines.last.empty?
      @comment_lines.map! { |comment| "# #{comment}" }
      @output_lines.concat @comment_lines
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
        when String
          lines << "" if lines.empty?
          lines.last << part
        when Array
          unless part.empty?
            part.first.insert 0, lines.pop unless lines.empty?
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
      outer_array << @output_lines
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
    
    def ruby_method_name(name)
      @converter.ruby_method_name name
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
  
  class JavaPackage < OutputGenerator
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
end
