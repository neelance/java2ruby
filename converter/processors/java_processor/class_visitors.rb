module Java2Ruby
  class JavaProcessor
    NOT_IMPLEMENTED = lambda { puts_output "raise NotImplementedError" }

    def visit_interfaceDeclaration(context_module)
      java_module = nil
      match :interfaceDeclaration do
        java_module = try_visit_normalInterfaceDeclaration context_module
        if not java_module
          match :annotationTypeDeclaration do
            match "@"
            match "interface"
            java_module = JavaModule.new context_module, :interface, visit_name
            match :annotationTypeBody do
              match "{"
              loop_match :annotationTypeElementDeclaration do
                visit_modifiers
                match :annotationTypeElementRest do
                  visit_type
                  match :annotationMethodOrConstantRest do
                    match :annotationMethodRest do
                      visit_name
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

    def try_visit_normalInterfaceDeclaration(context_module)
      java_module = nil
      try_match :normalInterfaceDeclaration do
        match "interface"
        if context_module.is_a? JavaModule
          java_module = JavaModule.new context_module, :local_interface, visit_name
        else
          java_module = JavaModule.new context_module, :interface, visit_name
        end
        if next_is? :typeParameters
          java_module.generic_classes = visit_typeParameters
        end
        if try_match "extends"
          java_module.interfaces = visit_typeList
        end
        java_module.in_context do
          match :interfaceBody do
            match "{"
            loop_match :interfaceBodyDeclaration do
              if try_match ";"
              else
                modifiers = visit_modifiers
                try_match :interfaceMemberDecl do
                  if try_match :interfaceMethodOrFieldDecl do
                      type = visit_type
                      member_name = visit_name
                      match :interfaceMethodOrFieldRest do
                        if next_is? :interfaceMethodDeclaratorRest
                          visit_interfaceMethodDeclaratorRest java_module, type, member_name
                        else
                          match :constantDeclaratorsRest do
                            match :constantDeclaratorRest do
                              match "="
                              value = buffer_visit_variableInitializer type
                              java_module.new_constant member_name, type, value
                            end
                          end
                          match ";"
                        end
                      end
                      match ";"
                    end
                  elsif next_is? :classDeclaration
                    java_module.add_local_module visit_classDeclaration(modifiers, java_module)
                  elsif next_is? :interfaceDeclaration
                    java_module.add_local_module visit_interfaceDeclaration(java_module)
                  elsif try_match :interfaceGenericMethodDecl do
                      generic_classes = visit_typeParameters
                      return_type = visit_type
                      member_name = visit_name
                      visit_interfaceMethodDeclaratorRest java_module, return_type, member_name, generic_classes
                    end
                  else
                    try_visit_normalInterfaceDeclaration java_module
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

    def visit_interfaceMethodDeclaratorRest(java_module, return_type, method_name, generic_classes = nil)
      match :interfaceMethodDeclaratorRest do
        method_parameters = visit_formalParameters
        try_visit_throws
        match ";"
        java_module.new_abstract_method(false, method_name, method_parameters, return_type, generic_classes)
      end
    end

    def visit_classDeclaration(element, context_module)
      java_module = nil

      if element[:type] == :class_declaration
        module_type = if current_method
          :inner_class
        elsif context_module.is_a? JavaModule
          if element[:class_modifiers].include? "static"
            :static_local_class
          else
            :local_class
          end
        else
          :class
        end
        
        java_module = JavaModule.new context_module, module_type, element[:name]
        current_method.method_classes << java_module if module_type == :inner_class
        
        java_module.generic_classes = element[:generic_classes]
        java_module.superclass = element[:superclass]
        java_module.interfaces = element[:interfaces]
        
        java_module.in_context do
          visit_classBody java_module, element
        end
      else
        match "enum"
        java_module = JavaModule.new context_module, :class, visit_name
        constant_names = []
        java_module.in_context do
          match :enumBody do
            match "{"
            match :enumConstants do
              loop do
                match :enumConstant do
                  enum_constant_name = visit_name
                  arguments = nil
                  if next_is? :arguments
                    arguments = visit_arguments
                  end
                  enum_constant_module = java_module
                  if next_is? :classBody
                    enum_constant_module = JavaModule.new java_module, :inner_class, enum_constant_name
                    enum_constant_module.superclass = java_module.java_type
                    enum_constant_module.new_constructor [], lambda { puts_output "super \"#{enum_constant_name}\"" }
                    visit_classBody enum_constant_module
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
              loop_visit_classBodyDeclaration java_module
            end
            match "}"
          end
        end

        java_module.new_method(false, "set_value_name", [["name", JavaClassType::STRING, false]], nil, lambda { puts_output "@value_name = name"; puts_output "self" })
        java_module.new_method(false, "to_s", [], nil, lambda { puts_output "@value_name" })
        java_module.new_method(true, "values", [], nil, lambda { puts_output "[#{constant_names.join(', ')}]" })
      end

      java_module
    end

    def visit_typeParameters
      names = []
      match :typeParameters do
        match "<"
        loop do
          match :typeParameter do
            names << visit_name
            if try_match "extends"
              match :typeBound do
                loop do
                  visit_type
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

    def visit_classBody(java_module, element)
      loop_visit_classBodyDeclaration java_module, element
    end

    def loop_visit_classBodyDeclaration(java_module, element)
      element[:body_declarations].each do |decl|
        
        case decl[:type]
        when :static_block
          block_body = buffer_match :block do
            match "{"
            visit_block_statements
            match "}"
          end
          java_module.new_static_block block_body

        when :constructor
          match :constructorDeclaratorRest do
            constructor_parameters = visit_formalParameters
            try_visit_throws
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
                explicit_invocation_arguments = visit_arguments
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

              visit_block_statements
              match "}"
            end
            java_module.new_constructor constructor_parameters, constructor_body
          end
          
        when :member_declaration
          visit_methodDeclaratorRest java_module, static, native, synchronized, type, method_name
        when :field_declaration
          visit_variableDeclarators(type) do |name, var_type, value|
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
          
        when :void_method_declaration
          method_parameters = decl[:parameters].map do |parameter_name, type, array_arg|
            [parameter_name, map_type(type), array_arg]
          end
          
          if false #try_match ";"
            if native
              java_module.new_native_method(static, decl[:name], method_parameters, JavaType::VOID)
            else
              java_module.new_abstract_method(static, decl[:name], method_parameters, JavaType::VOID)
            end
          else
            method_body = lambda {
              if decl[:synchronized]
                puts_output "synchronized(self) do"
                indent_output do
                  visit_block_statements decl[:body]
                end
                puts_output "end"
              else
                visit_block_statements decl[:body]
              end
            }
            
            java_module.new_method(decl[:static], decl[:name], method_parameters, JavaType::VOID, method_body)
          end
          
        when :class_declaration
          java_module.add_local_module visit_classDeclaration(modifiers, java_module)
          
        when :interface_declaration
          java_module.add_local_module visit_interfaceDeclaration(java_module)
          
        when :generic_method_or_constructor_decl
          generic_classes = visit_typeParameters
          match :genericMethodOrConstructorRest do
            return_type = if try_match "void"
              JavaType::VOID
            else
              visit_type
            end
            method_name = visit_name
            visit_methodDeclaratorRest java_module, static, native, synchronized, return_type, method_name, generic_classes
          end
        
        else
          raise
          
        end
        
      end
    end
    
    def map_type(element)
      case element[:type]
      when :java_class_type
        JavaClassType.new converter, current_module, current_method, element[:package], element[:names]
      when :java_array_type
        JavaArrayType.new(converter, map_type(element[:entry_type]))
      else
        raise element[:type].to_s
      end
    end

    def visit_methodDeclaratorRest(java_module, static, native, synchronized, return_type, method_name, generic_classes = nil)
      match :methodDeclaratorRest do
        method_parameters = visit_formalParameters
        if try_match "["
          match "]"
        end
        try_visit_throws
        if try_match ";"
          if native
          java_module.new_native_method(static, method_name, method_parameters, return_type, generic_classes)
          else
          java_module.new_abstract_method(static, method_name, method_parameters, return_type, generic_classes)
          end
        else
          match :methodBody do
            method_body = buffer_match :block do
              match "{"
              if synchronized
                puts_output "synchronized(self) do"
                indent_output do
                  visit_block_statements
                end
                puts_output "end"
              else
                visit_block_statements
              end
              match "}"
            end
            java_module.new_method(static, method_name, method_parameters, return_type, method_body, generic_classes)
          end
        end
      end
    end

    def visit_modifiers
      modifiers = []
      match :modifiers do
        try_match EPSILON or
        loop_match :modifier do
          if modifier = try_match("public", "protected", "private", "static", "final", "abstract", "transient", "native", "volatile", "synchronized", "strictfp")
            modifiers << modifier
          else
            visit_annotation
          end
        end
      end
      modifiers
    end

    def visit_formalParameters
      method_parameters = []
      match :formalParameters do
        match "("
        if next_is? :formalParameterDecls
          visit_formalParameterDecls method_parameters
        end
        match ")"
      end
      method_parameters
    end

    def visit_formalParameterDecls(method_parameters)
      match :formalParameterDecls do
        visit_variableModifiers
        type = visit_type
        match :formalParameterDeclsRest do
          array_arg = try_match "..."
          match :variableDeclaratorId do
            parameter_name = visit_name
            loop do
              try_match "[" or break
              match "]"
              type = JavaArrayType.new(converter, type)
            end
            method_parameters << [parameter_name, type, array_arg]
          end
          if try_match ","
            visit_formalParameterDecls method_parameters
          end
        end
      end
    end

    def visit_arguments
      arguments = []
      match :arguments do
        match "("
        try_match :expressionList do
          loop do
            arguments << visit_expression
            try_match "," or break
          end
        end
        match ")"
      end
      arguments
    end

    def try_visit_throws
      if try_match "throws"
        match :qualifiedNameList do
          loop do
            match :qualifiedName do
              loop do
                visit_name
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