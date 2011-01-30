module Java2Ruby
  class JavaProcessor
    class Expression
      attr_accessor :type, :output_parts, :result_used
      
      def initialize(type, *output_parts)
        @type = type
        output_parts.each { |p| raise if p.is_a?(Hash) }
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
  end
end