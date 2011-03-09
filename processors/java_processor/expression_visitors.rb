module Java2Ruby
  class JavaProcessor
    def visit_dual(element, data)
      visit(element[:left]).combine element[:operator], visit(element[:right])
    end
    
    def visit_expression_list(element, data)
      element[:children].each do |child|
        expression = visit child
        expression.result_used = false
        puts_output expression
      end
    end
    
    def visit_assignment(element, data)
      expression = visit element[:left]
      other_expression = visit element[:right]
      if element[:operator] == "=" and expression.is_a?(ConstantExpression)
        Expression.new nil, "const_set :#{expression.constant.ruby_name}, ", other_expression.typecast(expression.type)
      else
        Expression.new nil, expression, " #{element[:operator]} ", other_expression.typecast(expression.type)
      end
    end
    
    def visit_equal(element, data)
      other_expression = visit(element[:right])
      if other_expression.type == :null
        Expression.new nil, "(", visit(element[:left]), ").nil?"
      else
        Expression.new nil, "(", visit(element[:left]), ").equal?(", other_expression, ")"
      end
    end
    
    def visit_inequal(element, data)
      other_expression = visit(element[:right])
      if other_expression.type == :null
        Expression.new nil, "!(", visit(element[:left]), ").nil?"
      else
        Expression.new nil, "!(", visit(element[:left]), ").equal?(", other_expression, ")"
      end
    end
    
    def visit_one_line_if(element, data)
      Expression.new nil, visit(element[:condition]), " ? ", visit(element[:true_value]), " : ", visit(element[:false_value])
    end
    
    def visit_relation(element, data)
      visit(element[:left]).combine element[:operator], visit(element[:right])
    end
    
    def visit_typecheck(element, data)
      Expression.new nil, visit(element[:value]), ".is_a?(#{visit element[:checked_type]})"
    end
    
    def visit_shift(element, data)
      Expression.new nil, visit(element[:left]), " #{element[:operator]} ", visit(element[:right])
    end
    
    def visit_unary_plus(element, data)
      Expression.new nil, "+", visit(element[:value])
    end
    
    def visit_unary_minus(element, data)
      Expression.new nil, "-", visit(element[:value])
    end
    
    def visit_pre_increment(element, data)
      Expression.new nil, "(", visit(element[:value]), " += 1)"
    end
    
    def visit_pre_decrement(element, data)
      Expression.new nil, "(", visit(element[:value]), " -= 1)"
    end
    
    def visit_cast(element, data)
      type = visit element[:cast_type]
      expression = visit element[:value]
      if type.is_a?(JavaPrimitiveType)
        case type.name
        when "int"
          Expression.new nil, "(", expression, ").to_int"
        when "short", "char"
          Expression.new nil, "RJava.cast_to_#{type.name}(", expression, ")"
        when "float", "double"
          Expression.new nil, "(", expression, ").to_f"
        when "long", "byte", "boolean"
          expression
        else
          raise type.name
        end
      else
        expression
      end
    end
    
    def visit_not(element, data)
      Expression.new nil, "!", visit(element[:value])
    end
    
    def visit_complement(element, data)
      Expression.new nil, "~", visit(element[:value])
    end
    
    def visit_post_increment(element, data)
      PostIncrementExpression.new visit(element[:value])
    end
    
    def visit_post_decrement(element, data)
      PostDecrementExpression.new visit(element[:value])
    end
    
    def visit_parentheses(element, data)
      Expression.new nil, "(", visit(element[:value]), ")"
    end
    
    def visit_integer(element, data)
      Expression.new :Integer, element[:value]
    end
    
    def visit_boolean(element, data)
      Expression.new :Boolean, element[:value]
    end
    
    def visit_nil(element, data)
      Expression.new :null, "nil"
    end
    
    def visit_string(element, data)
      Expression.new JavaType::STRING, element[:value]
    end
    
    def visit_character(element, data)
      Expression.new nil, "Character.new(#{element[:value]})"
    end
    
    def visit_float(element, data)
      Expression.new :Float, element[:value]
    end
    
    def visit_array_class(element, data)
      Expression.new nil, "Array"
    end
        
    def visit_super_call(element, data)
      if element[:class]
        Expression.new nil, visit(element[:class]), ".superclass.instance_method(:", ruby_method_name(element[:method]), ").bind(self).call", *compose_arguments(element[:arguments])
      elsif element[:method] == current_method.name
        Expression.new nil, "super", *compose_arguments(element[:arguments])
      else
        Expression.new nil, current_module.superclass, ".instance_method(:", ruby_method_name(element[:method]), ").bind(self).call", *compose_arguments(element[:arguments])
      end
    end
    
    def visit_super_field(element, data)
      Expression.new nil, "@#{ruby_field_name element[:name]}"
    end
    
    def visit_call(element, data)
      current_module && current_module.method_used(element[:name])
      
      if element[:arguments].size == 1 and element[:name] == "equals"
        Expression.new nil, "(", visit(element[:target]), " == ", visit(element[:arguments].first), ")"
      elsif element[:arguments].size == 1 and element[:name] == "compareTo"
        Expression.new nil, "(", visit(element[:target]), " <=> ", visit(element[:arguments].first), ")"
      elsif element[:arguments].size == 1 and element[:name] == "split"
        Expression.new nil, visit(element[:target]), ".split(Regexp.new(", visit(element[:arguments].first), "))"
      else
        Expression.new nil, visit(element[:target]), ".", ruby_method_name(element[:name]), *compose_arguments(element[:arguments])
      end
    end
    
    def visit_field(element, data)
      identifiers = element[:identifiers].dup
      
      expression = nil
      expression ||= @statement_context && @statement_context.resolve(identifiers)
      expression ||= current_module && current_module.resolve(identifiers)
      
      identifiers.each do |identifier|
        expression = Expression.new nil, expression, ".attr_", ruby_field_name(identifier)
      end
      
      expression
    end
    
    def visit_array_creator(element, data)
      type = visit element[:entry_type]
      element[:initializer] ? visit(element[:initializer]) : type.default(element[:sizes].map{ |size| visit size })
    end
    
    def visit_array_access(element, data)
      if element[:index]
        Expression.new nil, visit(element[:array]), "[", visit(element[:index]), "]"
      else
        Expression.new nil, visit(element[:array]), "[]"
      end
    end
    
    def visit_expression_stuff # TODO delete this
      if try_match :identifierSuffix
        if next_is? "["
          loop do
            try_match "[" or break
            if next_is? :expression
              sub_expression = visit
              suffix.push "[", sub_expression, "]"
            else
              suffix << "[]"
            end
            match "]"
            if try_match "."
              match "class"
              expression = Expression.new nil, "Array"
            end
          end
        elsif next_is? :arguments
          arguments = visit_arguments
        else
          match "."
          if try_match :explicitGenericInvocation do
              match :nonWildcardTypeArguments do
                match "<"
                visit_typeList
                match ">"
              end
              identifiers << visit_name
              arguments = visit_arguments
            end
          elsif try_match "this"

          elsif try_match "new"
            match :innerCreator do
              type = visit_name
              expression = visit_classCreatorRest JavaClassType.new(converter, nil, nil, nil, [type]) # TODO this is wrong
            end
          elsif try_match "class"
            # class names are Class instances by themselves
          else
            raise ArgumentError
          end
        end
      end
      
      loop_match :selector do
        if try_match "."
          selector = visit_name
          if selector == "super"
            match :superSuffix do
              match "."
              identifier = visit_name
              if next_is? :arguments
                arguments = visit_arguments
                expression = Expression.new nil, expression, ".superclass.instance_method(:", ruby_method_name(identifier), ").bind(self).call", *compose_arguments(arguments)
              else
                raise ArgumentError
              end
            end
          else
            if next_is? :arguments
              arguments = visit_arguments
              expression = method_call expression, selector, arguments
            else
              expression = Expression.new nil, expression, ".attr_", ruby_field_name(selector)
            end
          end
        else
          match "["
          index_expression = visit
          match "]"
          expression = Expression.new nil, expression, "[", index_expression, "]"
        end
      end
      
      expression
    end
    
    def visit_field_access(element, data)
      Expression.new nil, visit(element[:target]), ".attr_", ruby_field_name(element[:name])
    end
        
    def visit_anonymous_class(element, data)
      puts_output current_module.java_type, " = self.class" if current_module.type == :inner_class
      java_module = JavaModule.new current_module, :inner_class, nil
      java_module.superclass = visit element[:superclass]
      visit_children element, java_module: java_module, context_module: java_module
      Expression.new nil, java_module, ".new_local", *compose_arguments([{ type: :self }] + element[:arguments])
    end
    
    def visit_class_creator(element, data)
      type = visit element[:class_type]
      arguments = element[:arguments]
      local_module = current_module && current_module.find_local_module(type.names.first)
      if local_module and local_module.type == :local_class
        Expression.new nil, type, ".new_local", *compose_arguments([{ type: :self }] + arguments)
      else
        Expression.new nil, type, ".new", *compose_arguments(arguments)
      end
    end
    
    def visit_self(element, data)
      Expression.new nil, "self"
    end
    
    def visit_self_call(element, data)
      current_module && current_module.method_used(element[:method])
      expression = Expression.new nil, (element[:method] == "equals" ? "self.==" : ruby_method_name(element[:method])), *compose_arguments(element[:arguments])
    end
    
    def visit_local_instance_access(element, data)
      if element[:name] == current_module.name
        Expression.new nil, "self"
      else
        expression = Expression.new nil, "@local_class_parent"
        target_module = current_module.context_module
        
        while element[:name] != target_module.name
          expression = Expression.new nil, expression, ".local_class_parent"
          target_module = target_module.context_module
        end
        
        expression
      end
    end
    
  end
end
