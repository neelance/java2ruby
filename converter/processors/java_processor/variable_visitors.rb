module Java2Ruby
  class JavaProcessor
    def visit_localVariableDeclaration(element)
      type = visit_type(element[:var_type])
      real_value = (element[:value] && visit_expression(element[:value])) || type.default
      var_name = @statement_context.new_variable element[:name], type
      puts_output "#{var_name} = ", real_value
    end
    
    def visit_variableModifiers
      match :variableModifiers do
        if try_match :variableModifier do
            try_match "final" \
            or visit_annotation
          end
        else
          match EPSILON
        end
      end
    end
    
    def buffer_visit_variableInitializer(type)
      buffer_match :variableInitializer do
       (type.is_a?(JavaArrayType) && try_visit_arrayInitializer(type)) || visit_expression
      end
    end
    
    def try_visit_arrayInitializer(type)
      output_parts = [type, ".new(["]
      try_match :arrayInitializer do
        match "{"
        loop do
          try_match :variableInitializer do
            output_parts << ((type.is_a?(JavaArrayType) && try_visit_arrayInitializer(type.entry_type)) || visit_expression)
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