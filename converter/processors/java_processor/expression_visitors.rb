module Java2Ruby
  class JavaProcessor
    def visit_combining_expression(element, &block)
      if element[:type] == :dual
        visit_combining_expression(element[:left], &block).combine element[:operator], visit_combining_expression(element[:right], &block)
      else
        yield element
      end
    end
    
    def visit_expression_list
      expressions = []
      loop_match :expressionList do
        loop do
          expression = visit_expression
          expression.result_used = false
          expressions << expression
          try_match "," or break
        end
      end
      expressions
    end
    
    def visit_expression(element)
      if element[:type] == :assignment
        expression = visit_conditionalExpression element[:left]
        other_expression = visit_expression element[:right]
        if element[:operator] == "=" and expression.is_a?(ConstantExpression)
          Expression.new nil, "const_set :#{expression.constant.ruby_name}, ", other_expression.typecast(expression.type)
        else
          Expression.new nil, expression, " #{operator} ", other_expression.typecast(expression.type)
        end
      else
        visit_conditionalExpression element
      end
    end
    
    def visit_conditionalExpression(element)
      expression = nil
      expression = visit_combining_expression element do |element|
        case element[:type]
        when :equal
          other_expression = visit_conditionalExpression(element[:right])
          if other_expression.type == :null
            expression = Expression.new nil, "(", visit_conditionalExpression(element[:left]), ").nil?"
          else
            expression = Expression.new nil, "(", visit_conditionalExpression(element[:left]), ").equal?(", other_expression, ")"
          end
        when :inequal
          other_expression = visit_conditionalExpression(element[:right])
          if other_expression.type == :null
            expression = Expression.new nil, "!(", visit_conditionalExpression(element[:left]), ").nil?"
          else
            expression = Expression.new nil, "!(", visit_conditionalExpression(element[:left]), ").equal?(", other_expression, ")"
          end
        when :one_line_if
          expression = Expression.new nil, visit_expression(element[:condition]), " ? ", visit_expression(element[:true_value]), " : ", visit_expression(element[:false_value])
        else
          expression = visit_instanceOfExpression element
        end
        expression
      end
      expression
    end
    
    def visit_instanceOfExpression(element)
      case element[:type]
      when :relation
        visit_instanceOfExpression(element[:left]).combine element[:operator], visit_instanceOfExpression(element[:right])
      when :typecheck
        Expression.new nil, visit_instanceOfExpression(element[:value]), ".is_a?(#{visit_type element[:type]})"
      else
        visit_shiftExpression element
      end
    end
    
    def visit_shiftExpression(element)
      if element[:type] == :shift
        Expression.new nil, visit_shiftExpression(element[:left]), " #{element[:operator]} ", visit_shiftExpression(element[:right])
      else
        visit_additiveExpression element
      end
    end
    
    def visit_additiveExpression(element)
      visit_combining_expression element do |element|
        visit_unaryExpression element
      end
    end
    
    def visit_unaryExpression(element)
      case element[:type]
      when :unary_plus
        Expression.new nil, "+", visit_unaryExpression(element[:value])
      when :unary_minus
        Expression.new nil, "-", visit_unaryExpression(element[:value])
      when :pre_increment
        Expression.new nil, "(", visit_unaryExpression(element[:value]), " += 1)"
      when :pre_decrement
        Expression.new nil, "(", visit_unaryExpression(element[:value]), " -= 1)"
      else
        visit_unaryExpressionNotPlusMinus element
      end
    end
    
    def visit_unaryExpressionNotPlusMinus(element)
      expression = nil
      case element[:type]
      when :cast
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
      when :not
        expression = visit_unaryExpression
        expression = Expression.new nil, "!", expression
      when :complement
        expression = visit_unaryExpression
        expression = Expression.new nil, "~", expression
      when :post_increment
        expression = PostIncrementExpression.new visit_primary(element[value])
      when :post_decrement
        expression = PostDecrementExpression.new visit_primary(element[value])
      else
        expression = visit_primary element
      end
      raise ArgumentError if not expression.is_a?(Expression)
      expression
    end
    
    def visit_parExpression(element)
      Expression.new nil, "(", visit_expression(element[:value]), ")"
    end
    
    UNICODE_MATCHER = if is_ruby_1_8?
      require "oniguruma"
      Oniguruma::ORegexp.new "(?<!\\\\)\\\\u(....)"
    else
      Regexp.new "(?<!\\\\)\\\\u(....)"
    end
    
    def visit_primary(element)
      expression = nil
      case element[:type]
      when :integer
        expression = Expression.new(:Integer, element[:value])
      when :boolean
        boolean = visit_name
        expression = Expression.new :Boolean, boolean
      when :nil
        expression = Expression.new :null, "nil"
      when :string
        expression = Expression.new(JavaType::STRING, element[:value])
      when :character
        java_char = literal[1..-2]
        char = if java_char == " "
          "?\\s.ord"
        elsif java_char =~ /^\\u/
          "0x#{java_char[2..-1]}"
        else
          "?#{java_char}.ord"
        end
        Expression.new nil, "Character.new(#{char})"
      when :float
        literal.gsub!(/[fdFD]$/, "")
        literal.gsub!(/^\./, "0.")
        Expression.new :Float, literal
      when :new
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
                  sizes << visit_expression
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
      when :parentheses
        expression = visit_parExpression element
      when :array_class
        expression = Expression.new nil, "Array"
      when :super
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
      when :call
        current_module && current_module.method_used(element[:name])
        expression = method_call element
      when :field
        identifiers = element[:identifiers]
        expression = nil
        expression ||= @statement_context && @statement_context.resolve(identifiers)
        expression ||= current_module && current_module.resolve(identifiers)
        
        identifiers.each do |identifier|
          expression = Expression.new nil, expression, ".attr_", ruby_field_name(identifier)
        end
      else
        raise ArgumentError, element[:type].inspect
        
        if try_match :identifierSuffix
          if next_is? "["
            loop do
              try_match "[" or break
              if next_is? :expression
                sub_expression = visit_expression
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
        expression = Expression.new nil, expression, *suffix unless suffix.empty?
      end
      
      if false
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
          index_expression = visit_expression
          match "]"
          expression = Expression.new nil, expression, "[", index_expression, "]"
        end
      end
      end
      
      expression
    end
    
    def method_call(element)
      if element[:arguments].size == 1 and element[:name] == "equals"
        Expression.new nil, "(", visit_expression(element[:target]), " == ", element[:arguments].first, ")"
      elsif element[:arguments].size == 1 and element[:name] == "compareTo"
        Expression.new nil, "(", visit_expression(element[:target]), " <=> ", element[:arguments].first, ")"
      elsif element[:arguments].size == 1 and element[:name] == "split"
        Expression.new nil, visit_expression(element[:target]), ".split(Regexp.new(", element[:arguments].first, "))"
      else
        Expression.new nil, visit_expression(element[:target]), ".", ruby_method_name(element[:name]), *compose_arguments(element[:arguments])
      end
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
