module Java2Ruby
  class JavaParseTreeProcessor
    NOT_IMPLEMENTED = lambda { puts_output "raise NotImplementedError" }

    def match_classOrInterfaceDeclaration
      element = nil
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
        element = if next_is? :classDeclaration
          match_classDeclaration []
        else
          match_interfaceDeclaration
        end
      end
      element
    end

    def match_interfaceDeclaration
      element = nil
      match :interfaceDeclaration do
        element = try_match_normalInterfaceDeclaration
        if not element
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
      element
    end

    def try_match_normalInterfaceDeclaration
      name = nil
      generic_classes = []
      interfaces = []
      interface_children = []
      
      try_match :normalInterfaceDeclaration do
        match "interface"
        name = match_name
        
        if next_is? :typeParameters
          generic_classes = match_typeParameters
        end
        if try_match "extends"
          interfaces = match_typeList
        end
        
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
                            value = match_variableInitializer type
                            interface_children << { :type => :constant_declaration, :name => member_name, :constant_type => type, :value => value }
                          end
                        end
                        match ";"
                      end
                    end
                  end
                elsif next_is? :classDeclaration
                  java_module.add_local_module match_classDeclaration(modifiers, java_module)
                elsif next_is? :interfaceDeclaration
                  java_module.add_local_module match_interfaceDeclaration(java_module)
                elsif try_match :interfaceGenericMethodDecl do
                    generic_classes = match_typeParameters
                    return_type = match_type
                    member_name = match_name
                    match_interfaceMethodDeclaratorRest java_module, return_type, member_name, generic_classes
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
      
      { :type => :interface_declaration, :name => name, :interfaces => interfaces, :generic_classes => generic_classes, :children => interface_children }
    end

    def match_interfaceMethodDeclaratorRest(java_module, return_type, method_name, generic_classes = nil)
      match :interfaceMethodDeclaratorRest do
        method_parameters = match_formalParameters
        try_match_throws
        match ";"
        java_module.new_abstract_method(false, method_name, method_parameters, return_type, generic_classes)
      end
    end

    def match_classDeclaration(class_modifiers)
      element = nil
      
      match :classDeclaration do
        try_match :normalClassDeclaration do
          generic_classes = []
          superclass = nil
          interfaces = []
          
          match "class"
          name = match_name

          if next_is? :typeParameters
            generic_classes = match_typeParameters
          end
          if try_match "extends"
            superclass = match_type
          end
          if try_match "implements"
            interfaces = match_typeList
          end
          class_children = match_classBody(name)
          
          element = { :type => :class_declaration, :name => name, :class_modifiers => class_modifiers, :generic_classes => generic_classes, :superclass => superclass, :interfaces => interfaces, :children => class_children }
        end \
        or match :enumDeclaration do
          match "enum"
          name = match_name
          enum_children = []
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
          
          element = { :type => :enum_declaration, :name => name, :children => enum_children }
        end
      end
      
      element
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

    def match_classBody(class_name)
      children = nil
      match :classBody do
        match "{"
        children = loop_match_classBodyDeclaration(class_name)
        match "}"
      end
      children
    end

    def loop_match_classBodyDeclaration(class_name)
      children = []
      
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
            if class_name and try_match class_name
              match :constructorDeclaratorRest do
                constructor_parameters = match_formalParameters
                explicit_invocation_type = nil
                explicit_invocation_arguments = nil
                constructor_children = []

                try_match_throws
                match :constructorBody do
                  body = nil

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

                  match_block_statements constructor_children
                  match "}"
                end
                
                children << { :type => :constructor, :parameters => constructor_parameters, :explicit_invocation_type => explicit_invocation_type, :explicit_invocation_arguments => explicit_invocation_arguments, :children => constructor_children }
              end
            elsif try_match :memberDeclaration do
                type = match_type
                try_match :methodDeclaration do
                  method_name = match_name
                  children << match_methodDeclaratorRest(static, native, synchronized, type, method_name)
                end \
                or try_match :fieldDeclaration do
                  match_variableDeclarators(type) do |name, var_type, value|
                    children << { :type => :field_declaration, :static => static, :final => final, :name => name, :field_type => var_type, :value => value }
                  end
                  match ";"
                end
              end
            elsif try_match "void"
              method_name = match_name
              match :voidMethodDeclaratorRest do
                method_parameters = match_formalParameters
                method_children = nil
                try_match_throws
                if try_match ";"
                  # nothing
                else
                  match :methodBody do
                    method_children = []
                    match :block do
                      match "{"
                      match_block_statements method_children
                      match "}"
                    end
                  end
                end
                children << { :type => :method_declaration, :static => static, :name => method_name, :parameters => method_parameters, :return_type => { :type => :void_type }, :synchronized => synchronized, :children => method_children }
              end
            elsif next_is? :classDeclaration
              children << { :type => :local_class_declaration, :class => match_classDeclaration(modifiers) }
            elsif next_is? :interfaceDeclaration
              children << { :type => :local_interface_declaration, :interface => match_interfaceDeclaration }
            elsif try_match :genericMethodOrConstructorDecl do
                generic_classes = match_typeParameters
                match :genericMethodOrConstructorRest do
                  return_type = if try_match "void"
                    JavaType::VOID
                  else
                    match_type
                  end
                  method_name = match_name
                  match_methodDeclaratorRest java_module, static, native, synchronized, return_type, method_name, generic_classes
                end
              end
            end
          end
        end
      end
      
      children
    end
    
    def match_methodDeclaratorRest(static, native, synchronized, return_type, method_name, generic_classes = nil)
      method_parameters = nil
      method_children = nil
      
      match :methodDeclaratorRest do
        method_parameters = match_formalParameters
        if try_match "["
          match "]"
        end
        try_match_throws
        if try_match ";"
          # nothing
        else
          method_children = []
          match :methodBody do
            match :block do
              match "{"
              match_block_statements method_children
              match "}"
            end
          end
        end
      end
      
      { :type => :method_declaration, :static => static, :native => native, :name => method_name, :parameters => method_parameters, :return_type => return_type, :generic_classes => generic_classes, :children => method_children }
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
