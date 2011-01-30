module Java2Ruby
  class JavaProcessor
    def visit_dual(element, data)
      visit(element[:left]).combine element[:operator], visit(element[:right])
    end
    
    def visit_list
      expressions = []
      loop_match :expressionList do
        loop do
          expression = visit
          expression.result_used = false
          expressions << expression
          try_match "," or break
        end
      end
      expressions
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
      Expression.new nil, visit(element[:value]), ".is_a?(#{visit element[:type]})"
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
    
    def visit_pre_drecrement(element, data)
      Expression.new nil, "(", visit(element[:value]), " -= 1)"
    end
    
    def visit_cast(element, data)
      match "("
      type = nil
      if try_match :primitiveType do
          type = visit_name
        end
        match ")"
        expression = visit_unaryExpression
      else
        visit_type
        match ")"
        expression = visit_unaryExpressionNotPlusMinus
      end
      case type
      when "int", "short", "char"
        expression = Expression.new nil, "RJava.cast_to_#{type}(", expression, ")"
      when "float", "double"
        expression = Expression.new nil, "(", expression, ").to_f"
      end
    end
    
    def visit_not(element, data)
      expression = visit_unaryExpression
      expression = Expression.new nil, "!", expression
    end
    
    def visit_complement(element, data)
      expression = visit_unaryExpression
      expression = Expression.new nil, "~", expression
    end
    
    def visit_post_increment(element, data)
      PostIncrementExpression.new visit(element[value])
    end
    
    def visit_post_decrement(element, data)
      PostDecrementExpression.new visit(element[value])
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
    
    def visit_new(element, data)
      type = nil
      match :creator do
        match :createdName do
          if try_match :primitiveType do
              type = JavaPrimitiveType.new visit_name
            end
          elsif next_is? :classOrInterfaceType
            type = visit_classOrInterfaceType
          end
        end
        if try_match :arrayCreatorRest do
            sizes = []
            while try_match "["
              if next_is? :expression
                sizes << visit
              end
              match "]"
              type = JavaArrayType.new self, type
            end
            expression = try_visit_arrayInitializer(type) || type.default(sizes) 
          end
        elsif next_is? :classCreatorRest
          expression = visit_classCreatorRest type
        end
      end
    end
    
    def visit_array_class(element, data)
      Expression.new nil, "Array"
    end
    
    def visit_super(element, data)
      match :superSuffix do
        match "."
        identifier = visit_name
        if next_is? :arguments
          arguments = visit_arguments
          if identifier == current_method.name
            expression = Expression.new nil, "super", *compose_arguments(arguments)
          else
            expression = Expression.new nil, current_module.superclass, ".instance_method(:", ruby_method_name(identifier), ").bind(self).call", *compose_arguments(arguments)
          end
        else
          expression = Expression.new nil, "@#{ruby_field_name identifier}"
        end
      end
    end
    
    def visit_call(element, data)
      current_module && current_module.method_used(element[:name])
      
      if element[:arguments].size == 1 and element[:name] == "equals"
        Expression.new nil, "(", visit(element[:target]), " == ", element[:arguments].first, ")"
      elsif element[:arguments].size == 1 and element[:name] == "compareTo"
        Expression.new nil, "(", visit(element[:target]), " <=> ", element[:arguments].first, ")"
      elsif element[:arguments].size == 1 and element[:name] == "split"
        Expression.new nil, visit(element[:target]), ".split(Regexp.new(", element[:arguments].first, "))"
      else
        Expression.new nil, visit(element[:target]), ".", ruby_method_name(element[:name]), *compose_arguments(element[:arguments])
      end
    end
    
    def visit_field(element, data)
      identifiers = element[:identifiers]
      
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
      element[:initializer] ? visit_arrayInitializer(element[:initializer]) : type.default(element[:sizes].map{ |size| visit size })
    end
    
    def visit_array_access(element, data)
      Expression.new nil, visit(element[:array]), "[", visit(element[:index]), "]"
    end
    
    def visit_expression_stuff
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
            if identifiers.first == current_module.name
              expression = Expression.new nil, "self"
            else
              expression = Expression.new nil, "@local_class_parent"
              target_module = current_module.context_module
              
              while identifiers.first != target_module.name
                expression = Expression.new nil, expression, ".local_class_parent"
                target_module = target_module.context_module
              end
            end
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
      
      if expression.nil?
        if identifiers.size == 1 and arguments
          current_module && current_module.method_used(identifiers.first)
          expression = Expression.new nil, (identifiers.first == "equals" ? "self.==" : ruby_method_name(identifiers.first)), *compose_arguments(arguments)
        else

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
        
    def visit_classCreatorRest(type)
      expression = nil
      match :classCreatorRest do
        arguments = visit_arguments
        expression = if type.names.size == 1 && type.names.first == "Integer"
          arguments.first
        else
          if next_is? :classBody
            puts_output current_module.java_type, " = self.class" if current_module.type == :inner_class
            java_module = JavaModule.new current_module, :inner_class, nil
            java_module.superclass = type
            visit_classBody java_module
            arguments.unshift "self"
            Expression.new nil, java_module, ".new_local", *compose_arguments(arguments)
          else
            local_module = current_module && current_module.find_local_module(type.names.first)
            if local_module and local_module.type == :local_class
              arguments.unshift "self"
              Expression.new nil, type, ".new_local", *compose_arguments(arguments)
            else
              Expression.new nil, type, ".new", *compose_arguments(arguments)
            end            
          end
        end
      end
      expression
    end
    
  end
end
