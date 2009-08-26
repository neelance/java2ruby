module Java2Ruby
  class Converter
    NOT_IMPLEMENTED = lambda { puts_output "raise NotImplementedError" }
    
    def match_classOrInterfaceDeclaration(context_module)
      java_module = nil
      match :classOrInterfaceDeclaration do
        match :classOrInterfaceModifiers do
          if try_match EPSILON
            #nothing
          else
            loop_match :classOrInterfaceModifier do
              try_match "public", "abstract", "final" or match_annotation
            end
          end
        end
        java_module = if next_is? :classDeclaration
          match_classDeclaration [], context_module
        else
          match_interfaceDeclaration context_module
        end
      end
      java_module
    end
    
    def match_interfaceDeclaration(context_module)
      java_module = nil
      match :interfaceDeclaration do
        java_module = try_match_normalInterfaceDeclaration context_module
        if not java_module
          match :annotationTypeDeclaration do
            match "@"
            match "interface"
            java_module = JavaModule.new context_module, :interface, match_name
            match :annotationTypeBody do
              match "{"
              loop_match :annotationTypeElementDeclaration do
                match_modifiers
                match :annotationTypeElementRest do
                  match_type
                  match :annotationMethodOrConstantRest do
                    match :annotationMethodRest do
                      match_name
                      match "("
                      match ")"
                    end
                  end
                  match ";"
                end
              end 
              match "}"
            end
          end
        end
      end
      java_module
    end
    
    def try_match_normalInterfaceDeclaration(context_module)
      java_module = nil
      try_match :normalInterfaceDeclaration do
        match "interface"
        if context_module.is_a? JavaModule
          java_module = JavaModule.new context_module, :local_interface, match_name
        else
          java_module = JavaModule.new context_module, :interface, match_name
        end
        if next_is? :typeParameters
          java_module.generic_classes = match_typeParameters
        end
        if try_match "extends"
          java_module.interfaces = match_typeList
        end
        java_module.in_context do
          match :interfaceBody do
            match "{"
            loop_match :interfaceBodyDeclaration do
              if try_match ";"
              else
                modifiers = match_modifiers
                try_match :interfaceMemberDecl do
                  if try_match :interfaceMethodOrFieldDecl do
                      type = match_type
                      member_name = match_name
                      match :interfaceMethodOrFieldRest do
                        if next_is? :interfaceMethodDeclaratorRest
                          match_interfaceMethodDeclaratorRest java_module, type, member_name
                        else
                          match :constantDeclaratorsRest do
                            match :constantDeclaratorRest do
                              match "="
                              value = buffer_match_variableInitializer type
                              java_module.new_constant member_name, type, value
                            end
                          end
                          match ";"
                        end
                      end
                    end
                  elsif try_match "void"
                    member_name = match_name
                    match :voidInterfaceMethodDeclaratorRest do
                      method_parameters = match_formalParameters
                      try_match_throws
                      match ";"
                      java_module.new_abstract_method(false, member_name, method_parameters, JavaType::VOID)
                    end
                  elsif next_is? :classDeclaration
                    java_module.add_local_module match_classDeclaration(modifiers, java_module)
                  elsif next_is? :interfaceDeclaration
                    java_module.add_local_module match_interfaceDeclaration(java_module)
                  elsif try_match :interfaceGenericMethodDecl do
                      match_typeParameters
                      return_type = match_type
                      member_name = match_name
                      match_interfaceMethodDeclaratorRest java_module, return_type, member_name
                    end
                  else
                    try_match_normalInterfaceDeclaration java_module
                  end
                end
              end
            end
            match "}"
          end
        end
      end
      java_module
    end
    
    def match_interfaceMethodDeclaratorRest(java_module, return_type, method_name)
      match :interfaceMethodDeclaratorRest do
        method_parameters = match_formalParameters
        try_match_throws
        match ";"
        java_module.new_abstract_method(false, method_name, method_parameters, return_type)
      end
    end
    
    def match_classDeclaration(class_modifiers, context_module)
      java_module = nil
      match :classDeclaration do
        try_match :normalClassDeclaration do
          match "class"
          if current_method
            java_module = JavaModule.new context_module, :inner_class, match_name
            current_method.method_classes << java_module
          elsif context_module.is_a? JavaModule
            if class_modifiers.include? "static"
              java_module = JavaModule.new context_module, :static_local_class, match_name
            else
              java_module = JavaModule.new context_module, :local_class, match_name
            end
          else
            java_module = JavaModule.new context_module, :class, match_name
          end
          if next_is? :typeParameters
            java_module.generic_classes = match_typeParameters
          end
          if try_match "extends"
            java_module.superclass = match_type
          end
          if try_match "implements"
            java_module.interfaces = match_typeList
          end
          java_module.in_context do
            match_classBody java_module
          end
        end \
        or match :enumDeclaration do
          match "enum"
          java_module = JavaModule.new context_module, :class, match_name
          constant_names = []
          java_module.in_context do
            match :enumBody do
              match "{"
              match :enumConstants do
                loop do
                  match :enumConstant do
                    enum_constant_name = match_name
                    arguments = nil
                    if next_is? :arguments
                      arguments = match_arguments
                    end
                    enum_constant_module = java_module
                    if next_is? :classBody
                      enum_constant_module = JavaModule.new java_module, :inner_class, enum_constant_name
                      enum_constant_module.superclass = java_module.java_type
                      enum_constant_module.new_constructor [], lambda { puts_output "super \"#{enum_constant_name}\"" }
                      match_classBody enum_constant_module
                    end
                    expression_parts = [enum_constant_module.java_type, ".new"]
                    expression_parts.concat compose_arguments(arguments)
                    expression_parts << ".set_value_name(\"#{enum_constant_name}\")"
                    ruby_name = java_module.new_constant enum_constant_name, nil, Expression.new(nil, *expression_parts)
                    constant_names << ruby_name
                    context_module.new_constant enum_constant_name, nil, Expression.new(nil, "#{java_module.java_type}::#{ruby_name}") if context_module.is_a? JavaModule
                  end
                  try_match "," or break
                end
              end
              try_match ","
              try_match :enumBodyDeclarations do
                match ";"
                loop_match_classBodyDeclaration java_module
              end
              match "}"
            end
          end
          
          java_module.new_method(false, "set_value_name", [["name", JavaClassType::STRING, false]], nil, lambda { puts_output "@value_name = name"; puts_output "self" })
          java_module.new_method(false, "to_s", [], nil, lambda { puts_output "@value_name" })
          java_module.new_method(true, "values", [], nil, lambda { puts_output "[#{constant_names.join(', ')}]" })
        end
      end
      
      java_module
    end
    
    def match_typeParameters
      names = []
      match :typeParameters do
        match "<"
        loop do
          match :typeParameter do
            names << match_name
            if try_match "extends"
              match :typeBound do
                loop do
                  match_type
                  try_match "&" or break
                end
              end
            end
          end
          try_match "," or break
        end
        match ">"
      end
      names
    end
    
    def match_classBody(java_module)
      match :classBody do
        match "{"
        loop_match_classBodyDeclaration java_module
        match "}"
      end
    end
    
    def loop_match_classBodyDeclaration(java_module)
      loop_match :classBodyDeclaration do
        if try_match ";"
          next
        end
        if try_match "static"
          block_body = buffer_match :block do
            match "{"
            match_block_statements
            match "}"
          end
          java_module.new_static_block block_body
        elsif next_is? :block
          match_block # TODO what is this block?
        else
          modifiers = match_modifiers
          static = modifiers.include?("static")
          native = modifiers.include?("native")
          final = modifiers.include?("final")
          synchronized = modifiers.include?("synchronized")
          match :memberDecl do
            if try_match java_module.name
              match :constructorDeclaratorRest do
                constructor_parameters = match_formalParameters
                try_match_throws
                constructor_body = buffer_match :constructorBody do
                  body = nil
                  explicit_invocation_type = nil
                  explicit_invocation_arguments = nil
                  
                  match "{"
                  try_match :explicitConstructorInvocation do
                    if try_match "super"
                      explicit_invocation_type = :super
                    else
                      try_match "this"
                      explicit_invocation_type = :this
                    end
                    explicit_invocation_arguments = match_arguments
                    match ";"
                  end
                  
                  if explicit_invocation_type == :this
                    puts_output current_module.explicit_constructor_name, *compose_arguments(explicit_invocation_arguments, true)
                  else
                    if current_module.superclass
                      arguments = (explicit_invocation_type == :super) ? explicit_invocation_arguments : []
                      current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = #{field.type.default}" }
                      puts_output "super", *compose_arguments(arguments, true)
                      current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = ", field.value.call if field.value }
                    else
                      current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = ", field.value ? field.value.call : field.type.default }
                    end
                  end
                  
                  match_block_statements
                  match "}"
                end
                java_module.new_constructor constructor_parameters, constructor_body
              end
            elsif try_match :memberDeclaration do
                type = match_type
                try_match :methodDeclaration do
                  method_name = match_name
                  match_methodDeclaratorRest java_module, static, native, synchronized, type, method_name
                end \
                or try_match :fieldDeclaration do
                  match_variableDeclarators(type) do |name, var_type, value|
                    if static
                      if final
                        java_module.new_constant name, var_type, value
                      else
                        java_module.new_static_field name, var_type, value
                      end
                    else
                      java_module.new_field name, var_type, value
                    end
                  end
                  match ";"
                end
              end
            elsif try_match "void"
              method_name = match_name
              match :voidMethodDeclaratorRest do
                method_parameters = match_formalParameters
                try_match_throws
                if try_match ";"
                  if native
                    java_module.new_native_method(static, method_name, method_parameters, JavaType::VOID)
                  else
                    java_module.new_abstract_method(static, method_name, method_parameters, JavaType::VOID)
                  end
                else
                  match :methodBody do
                    method_body = buffer_match :block do
                      match "{"
                      if synchronized
                        puts_output "synchronized(self) do"
                        indent_output do
                          match_block_statements
                        end
                        puts_output "end"
                      else
                        match_block_statements
                      end
                      match "}"
                    end
                    java_module.new_method(static, method_name, method_parameters, JavaType::VOID, method_body)
                  end
                end
              end
            elsif next_is? :classDeclaration
              java_module.add_local_module match_classDeclaration(modifiers, java_module)
            elsif next_is? :interfaceDeclaration
              java_module.add_local_module match_interfaceDeclaration(java_module)
            elsif try_match :genericMethodOrConstructorDecl do
                match_typeParameters
                match :genericMethodOrConstructorRest do
                  return_type = if try_match "void"
                    JavaType::VOID
                  else
                    match_type
                  end
                  method_name = match_name
                  match_methodDeclaratorRest java_module, static, native, synchronized, return_type, method_name
                end
              end
            end
          end
        end
      end
    end
    
    def match_methodDeclaratorRest(java_module, static, native, synchronized, return_type, method_name)
      match :methodDeclaratorRest do
        method_parameters = match_formalParameters
        if try_match "["
          match "]"
        end
        try_match_throws
        if try_match ";"
          if native
            java_module.new_native_method(static, method_name, method_parameters, return_type)
          else
            java_module.new_abstract_method(static, method_name, method_parameters, return_type)
          end
        else
          match :methodBody do
            method_body = buffer_match :block do
              match "{"
              if synchronized
                puts_output "synchronized(self) do"
                indent_output do
                  match_block_statements
                end
                puts_output "end"
              else
                match_block_statements
              end
              match "}"
            end
            java_module.new_method(static, method_name, method_parameters, return_type, method_body)
          end
        end
      end
    end
    
    def match_modifiers
      modifiers = []
      match :modifiers do
        try_match EPSILON or
        loop_match :modifier do
          if modifier = try_match("public", "protected", "private", "static", "final", "abstract", "transient", "native", "volatile", "synchronized", "strictfp")
            modifiers << modifier
          else
            match_annotation
          end
        end
      end
      modifiers
    end
    
    def match_formalParameters
      method_parameters = []
      match :formalParameters do
        match "("
        if next_is? :formalParameterDecls
          match_formalParameterDecls method_parameters
        end
        match ")"
      end
      method_parameters
    end
    
    def match_formalParameterDecls(method_parameters)
      match :formalParameterDecls do
        match_variableModifiers
        type = match_type
        match :formalParameterDeclsRest do
          array_arg = try_match "..."
          match :variableDeclaratorId do
            parameter_name = match_name
            loop do
              try_match "[" or break
              match "]"
              type = JavaArrayType.new(converter, type)
            end
            method_parameters << [parameter_name, type, array_arg]
          end
          if try_match ","
            match_formalParameterDecls method_parameters
          end
        end
      end
    end
    
    def match_arguments
      arguments = []
      match :arguments do
        match "("
        try_match :expressionList do
          loop do
            arguments << match_expression
            try_match "," or break
          end
        end
        match ")"
      end
      arguments
    end
    
    def try_match_throws
      if try_match "throws"
        match :qualifiedNameList do
          loop do
            match :qualifiedName do
              loop do
                match_name
                try_match "." or break
              end
            end
            try_match "," or break
          end
        end
      end
    end
    
  end
end