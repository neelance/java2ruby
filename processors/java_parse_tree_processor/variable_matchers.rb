module Java2Ruby
  class JavaParseTreeProcessor
    def match_localVariableDeclaration(element)
      match :localVariableDeclaration do
        match_variableModifiers
        type = match_type
        match_variableDeclarators(type) do |name, var_type, value|
          element[:children] << { :type => :variable_declaration, :name => name, :var_type => var_type, :value => value }
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
              value = match_variableInitializer type
            end
            yield name, type, value
          end
          try_match "," or break
        end
      end
    end
    
    def match_variableInitializer(type_element)
      value = nil
      match :variableInitializer do
        value = (type_element[:type] == :array_type && try_match_arrayInitializer(type_element)) || match_expression
      end
      value
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