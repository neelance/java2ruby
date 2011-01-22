module Java2Ruby
  class JavaParseTreeProcessor
    def match_localVariableDeclaration
      match :localVariableDeclaration do
        match_variableModifiers
        type = match_type
        match_variableDeclarators(type) do |name, var_type, value|
          real_value = (value && value.call) || type.default
          var_name = @statement_context.new_variable name, var_type
          puts_output "#{var_name} = ", real_value
        end
      end
    end
    
    def match_variableModifiers
      match :variableModifiers do
        if try_match :variableModifier do
            try_match "final" \
            or match_annotation
          end
        else
          match EPSILON
        end
      end
    end
    
    def match_variableDeclarators(type)
      match :variableDeclarators do
        loop do
          match :variableDeclarator do
            name = nil
            match :variableDeclaratorId do
              name = match_name
              loop do
                try_match "[" or break
                match "]"
                type = JavaArrayType.new self, type
              end
            end
            value = nil
            if try_match "="
              value = buffer_match_variableInitializer type
            end
            yield name, type, value
          end
          try_match "," or break
        end
      end
    end
    
    def buffer_match_variableInitializer(type)
      buffer_match :variableInitializer do
       (type.is_a?(JavaArrayType) && try_match_arrayInitializer(type)) || match_expression
      end
    end
    
    def try_match_arrayInitializer(type)
      output_parts = [type, ".new(["]
      try_match :arrayInitializer do
        match "{"
        loop do
          try_match :variableInitializer do
            output_parts << ((type.is_a?(JavaArrayType) && try_match_arrayInitializer(type.entry_type)) || match_expression)
          end or break
          try_match "," or break
          output_parts << ", "
        end
        match "}"
      end or return nil
      output_parts << "])"
      Expression.new :Array, *output_parts
    end
    
  end
end