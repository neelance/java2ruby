module Java2Ruby
  class Converter
    def match_combining_expression(name, *combiners)
      expression = nil
      match name do
        expression = yield
        loop do
          combiner_found = false
          combiners.each do |combiner|
            if try_match combiner
              expression = expression.combine combiner, yield
              combiner_found = true
              break
            end
          end
          combiner_found or break
        end
      end
      raise ArgumentError if expression.nil?
      expression
    end
    
    def match_expression_list
      expressions = []
      loop_match :expressionList do
        loop do
          expression = match_expression
          expression.result_used = false
          expressions << expression
          try_match "," or break
        end
      end
      expressions
    end
    
    def match_expression
      expression = nil
      match :expression do
        expression = match_conditionalExpression
        operator = nil
        if try_match :assignmentOperator do
            operator = multi_match ["="], ["+="], ["-="], ["*="], ["/="], ["&="], ["|="], ["^="], ["%="], ["<", "<", "="], [">", ">", "="], [">", ">", ">", "="]
            operator = ">>=" if operator == ">>>="
          end
          other_expression = match_expression
          if operator == "=" and expression.is_a?(ConstantExpression)
            expression = Expression.new nil, "const_set :#{expression.constant.ruby_name}, ", other_expression.typecast(expression.type)
          else
            expression = Expression.new nil, expression, " #{operator} ", other_expression.typecast(expression.type)
          end
        end
      end
      raise ArgumentError if expression.nil?
      expression
    end
    
    def match_conditionalExpression
      expression = nil
      match :conditionalExpression do
        expression = match_combining_expression :conditionalOrExpression, "||" do
          match_combining_expression :conditionalAndExpression, "&&" do
            match_combining_expression :inclusiveOrExpression, "|" do
              match_combining_expression :exclusiveOrExpression, "^" do
                match_combining_expression :andExpression, "&" do
                  expression = nil
                  match :equalityExpression do
                    expression = match_instanceOfExpression
                    loop do
                      if try_match "=="
                        other_expression = match_instanceOfExpression
                        if other_expression.type == :null
                          expression = Expression.new nil, "(", expression, ").nil?"
                        else
                          expression = Expression.new nil, "(", expression, ").equal?(", other_expression, ")"
                        end
                      elsif try_match "!="
                        other_expression = match_instanceOfExpression
                        if other_expression.type == :null
                          expression = Expression.new nil, "!(", expression, ").nil?"
                        else
                          expression = Expression.new nil, "!(", expression, ").equal?(", other_expression, ")"
                        end
                      else
                        break
                      end
                    end
                  end
                  expression
                end
              end
            end
          end
        end
        if try_match "?"
          true_expression = match_expression
          match ":"
          false_expression = match_expression
          expression = Expression.new nil, expression, " ? ", true_expression, " : ", false_expression
        end
      end
      expression
    end
    
    def match_instanceOfExpression
      expression = nil
      match :instanceOfExpression do
        match :relationalExpression do
          expression = match_shiftExpression
          operator = nil
          if try_match :relationalOp do
              operator = multi_match ["<"], ["<", "="], [">", "="], [">"]
            end
            expression = expression.combine operator, match_shiftExpression
          end
        end
        if try_match "instanceof"
          type = match_type
          expression = Expression.new nil, expression, ".is_a?(#{type})"
        end
      end
      raise ArgumentError if expression.nil?
      expression
    end
    
    def match_shiftExpression
      expression = nil
      match :shiftExpression do
        expression = match_additiveExpression
        operator = nil
        loop do
          if try_match :shiftOp do
              operator = multi_match ["<", "<"], [">", ">"], [">", ">", ">"]
              operator = ">>" if operator == ">>>" # TODO may have side effects, check
            end
            other_expression = match_additiveExpression
            expression = Expression.new nil, expression, " #{operator} ", other_expression
          else
            break
          end
        end
      end
      raise ArgumentError if expression.nil?
      expression
    end
    
    def match_additiveExpression
      match_combining_expression :additiveExpression, "+", "-" do
        match_combining_expression :multiplicativeExpression, "*", "/", "%" do
          match_unaryExpression
        end
      end
    end
    
    def match_unaryExpression
      expression = nil
      match :unaryExpression do
        expression = if try_match "+"
          Expression.new nil, "+", match_unaryExpression
        elsif try_match "-"
          Expression.new nil, "-", match_unaryExpression
        elsif try_match "++"
          Expression.new nil, "(", match_unaryExpression, " += 1)"
        elsif try_match "--"
          Expression.new nil, "(", match_unaryExpression, " -= 1)"
        else
          match_unaryExpressionNotPlusMinus
        end
      end
      raise ArgumentError if expression.nil?
      expression
    end
    
    def match_unaryExpressionNotPlusMinus
      expression = nil
      match :unaryExpressionNotPlusMinus do
        if try_match :castExpression do
            match "("
            type = nil
            if try_match :primitiveType do
                type = match_name
              end
              match ")"
              expression = match_unaryExpression
            else
              match_type
              match ")"
              expression = match_unaryExpressionNotPlusMinus
            end
            case type
            when "int", "short", "char"
              expression = Expression.new nil, "RJava.cast_to_#{type}(", expression, ")"
            when "float", "double"
              expression = Expression.new nil, "(", expression, ").to_f"
            end
          end
        elsif try_match "!"
          expression = match_unaryExpression
          expression = Expression.new nil, "!", expression
        elsif try_match "~"
          expression = match_unaryExpression
          expression = Expression.new nil, "~", expression
        else
          expression = match_primary
          if try_match "++"
            expression = PostIncrementExpression.new expression
          elsif try_match "--"
            expression = PostDecrementExpression.new expression
          end
        end
      end
      raise ArgumentError if expression.nil?
      expression
    end
    
    def match_parExpression
      expression = nil
      match :parExpression do
        if try_match "("
          expression = match_expression
          expression = Expression.new nil, "(", expression, ")"
          match ")"
        else
          expression = Expression.new nil # TODO why empty parExpression?
        end
      end
      raise ArgumentError if expression.nil?
      expression
    end
    
    UNICODE_MATCHER = if is_ruby_1_8?
      require "oniguruma"
      Oniguruma::ORegexp.new "(?<!\\\\)\\\\u(....)"
    else
      Regexp.new "(?<!\\\\)\\\\u(....)"
    end
    
    def match_primary
      expression = nil
      match :primary do
        if try_match :literal do
            if try_match :integerLiteral do
                str = match_name
                is_neg = str.gsub!(/^-/, "")
                is_hex = str.gsub!(/^0x/, "")
                is_long = str.gsub!(/L$/, "")
                int = str.to_i(is_hex ? 16 : 10)
                if is_long and int >= 0x8000000000000000
                  int = 0x10000000000000000 - int
                  is_neg = !is_neg
                end
                if not is_long and int >= 0x80000000
                  int = 0x100000000 - int
                  is_neg = !is_neg
                end
                expression = Expression.new(:Integer, (is_neg ? "-" : "") + (is_hex ? "0x" : "") + int.to_s(is_hex ? 16 : 10))
              end
            elsif try_match :booleanLiteral do
                boolean = match_name
                expression = Expression.new :Boolean, boolean
              end
            else
              literal = match_name
              expression = case
              when literal == "null"
                Expression.new :null, "nil"
              when literal[0..0] == "\""
                content = literal[1..-2]
                unicode = if is_ruby_1_8?
                  UNICODE_MATCHER.gsub(content, '".to_u << 0x\1 << "')
                else
                  content.gsub!(UNICODE_MATCHER, '".to_u << 0x\1 << "')
                end
                Expression.new(JavaType::STRING, unicode ? "(\"#{content}\")" : "\"#{content}\"")
              when literal[0..0] == "'"
                java_char = literal[1..-2]
                char = if java_char == " "
                  "?\\s.ord"
                elsif java_char =~ /^\\u/
                  "0x#{java_char[2..-1]}"
                else
                  "?#{java_char}.ord"
                end
                Expression.new nil, "Character.new(#{char})"
              else
                literal.gsub!(/[fdFD]$/, "")
                literal.gsub!(/^\./, "0.")
                Expression.new :Float, literal
              end
            end
          end
        elsif try_match "new"
          type = nil
          match :creator do
            match :createdName do
              if try_match :primitiveType do
                  type = JavaPrimitiveType.new match_name
                end
              elsif next_is? :classOrInterfaceType
                type = match_classOrInterfaceType
              end
            end
            if try_match :arrayCreatorRest do
                sizes = []
                while try_match "["
                  if next_is? :expression
                    sizes << match_expression
                  end
                  match "]"
                  type = JavaArrayType.new self, type
                end
                expression = try_match_arrayInitializer(type) || type.default(sizes) 
              end
            elsif next_is? :classCreatorRest
              expression = match_classCreatorRest type
            end
          end
        elsif next_is? :parExpression
          expression = match_parExpression
        elsif try_match :primitiveType do
            match_name
          end
          loop do
            multi_match ["[", "]"], [] or break
          end
          match "."
          match "class"
          expression = Expression.new nil, "Array"
        elsif try_match "super"
          match :superSuffix do
            match "."
            identifier = match_name
            if next_is? :arguments
              arguments = match_arguments
              if identifier == current_method.name
                expression = Expression.new nil, "super", *compose_arguments(arguments)
              else
                expression = Expression.new nil, current_module.superclass, ".instance_method(:", ruby_method_name(identifier), ").bind(self).call", *compose_arguments(arguments)
              end
            else
              expression = Expression.new nil, "@#{ruby_field_name identifier}"
            end
          end
        else
          identifiers = []
          arguments = nil
          suffix = []
          
          identifiers << match_name
          loop do
            if try_match "."
              identifiers << match_name
            else
              break
            end
          end
          if try_match :identifierSuffix do
              if next_is? "["
                loop do
                  try_match "[" or break
                  if next_is? :expression
                    sub_expression = match_expression
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
                arguments = match_arguments
              else
                match "."
                if try_match :explicitGenericInvocation do
                    match :nonWildcardTypeArguments do
                      match "<"
                      match_typeList
                      match ">"
                    end
                    identifiers << match_name
                    arguments = match_arguments
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
                    type = match_name
                    expression = match_classCreatorRest JavaClassType.new(converter, nil, nil, nil, [type]) # TODO this is wrong
                  end
                elsif try_match "class"
                  suffix << ".class"
                else
                  raise ArgumentError
                end
              end
            end
          end
          
          if expression.nil?
            if identifiers.size == 1 and arguments
              current_module && current_module.method_used(identifiers.first)
              expression = Expression.new nil, ruby_method_name(identifiers.first), *compose_arguments(arguments)
            else
              method_identifier = arguments ? identifiers.pop : nil
              
              expression = nil
              expression ||= @statement_context && @statement_context.resolve(identifiers)
              expression ||= current_module && current_module.resolve(identifiers)
              
              identifiers.each do |identifier|
                expression = Expression.new nil, expression, ".attr_", ruby_field_name(identifier)
              end
              
              if method_identifier
                current_module && current_module.method_used(method_identifier)
                expression = method_call expression, method_identifier, arguments
              end
            end
          end
          expression = Expression.new nil, expression, *suffix unless suffix.empty?
        end
      end
      
      loop_match :selector do
        if try_match "."
          selector = match_name
          if next_is? :arguments
            arguments = match_arguments
            expression = method_call expression, selector, arguments
          else
            expression = Expression.new nil, expression, ".attr_", ruby_field_name(selector)
          end
        else
          match "["
          index_expression = match_expression
          match "]"
          expression = Expression.new nil, expression, "[", index_expression, "]"
        end
      end
      
      expression
    end
    
    def method_call(expression, method_name, arguments)
      case method_name
      when "equals"
        expression = Expression.new nil, "(", expression, " == ", arguments.first, ")"
      when "compareTo"
        expression = Expression.new nil, "(", expression, " <=> ", arguments.first, ")"
      when "split"
        expression = Expression.new nil, expression, ".split(Regexp.new(", arguments.first, "))"
      else
        expression = Expression.new nil, expression, ".", ruby_method_name(method_name), *compose_arguments(arguments)
      end
    end
    
    def match_classCreatorRest(type)
      expression = nil
      match :classCreatorRest do
        arguments = match_arguments
        expression = if type.names.size == 1 && type.names.first == "Integer"
          arguments.first
        else
          if next_is? :classBody
            puts_output current_module.java_type, " = self.class" if current_module.type == :inner_class
            java_module = JavaModule.new current_module, :inner_class, nil
            java_module.superclass = type
            match_classBody java_module
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
