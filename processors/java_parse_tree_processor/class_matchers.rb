module Java2Ruby
  class JavaParseTreeProcessor
    def match_classOrInterfaceDeclaration
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
        if next_is? :classDeclaration
          match_classDeclaration []
        else
          match_interfaceDeclaration
        end
      end
    end

    def match_interfaceDeclaration
      match :interfaceDeclaration do
        try_match_normalInterfaceDeclaration
        try_match :annotationTypeDeclaration do
          create_element :interface_declaration do
            match "@"
            match "interface"
            set_attribute :name, match_name
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
    end

    def try_match_normalInterfaceDeclaration
      create_element :interface_declaration do
        try_match :normalInterfaceDeclaration do
          match "interface"
          set_attribute :name, match_name
          
          if next_is? :typeParameters
            set_attribute :generic_classes, match_typeParameters
          end
          if try_match "extends"
            set_attribute :interfaces, match_typeList
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
                          match_interfaceMethodDeclaratorRest(type, member_name)
                        else
                          match :constantDeclaratorsRest do
                            match :constantDeclaratorRest do
                              match "="
                              value = match_variableInitializer type
                              create_element :constant_declaration, :name => member_name, :constant_type => type, :value => value
                            end
                          end
                          match ";"
                        end
                      end
                    end
                  elsif try_match "void"
                    create_element :method_declaration, :static => false, :abstract => true, :return_type => { :type => :void_type } do
                      set_attribute :name, match_name
                      match :voidInterfaceMethodDeclaratorRest do
                        set_attribute :parameters, match_formalParameters
                        try_match_throws
                        match ";"
                      end
                    end
                  elsif next_is? :classDeclaration
                    match_classDeclaration modifiers
                  elsif next_is? :interfaceDeclaration
                    match_interfaceDeclaration
                  elsif try_match :interfaceGenericMethodDecl do
                      generic_classes = match_typeParameters
                      return_type = match_type
                      member_name = match_name
                      match_interfaceMethodDeclaratorRest return_type, member_name, generic_classes
                    end
                  else
                    try_match_normalInterfaceDeclaration
                  end
                end
              end
            end
            match "}"
          end
        end
      end
    end

    def match_interfaceMethodDeclaratorRest(return_type, method_name, generic_classes = nil)
      create_element :method_declaration, :static => false, :abstract => true, :name => method_name, :return_type => return_type do
        match :interfaceMethodDeclaratorRest do
          set_attribute :parameters, match_formalParameters
          try_match_throws
          match ";"
        end
      end
    end

    def match_classDeclaration(class_modifiers)
      match :classDeclaration do
        try_match :normalClassDeclaration do
          create_element :class_declaration, :class_modifiers => class_modifiers do
            match "class"
            set_attribute :name, name = match_name
  
            if next_is? :typeParameters
              set_attribute :generic_classes, match_typeParameters
            end
            if try_match "extends"
              set_attribute :superclass, match_type
            end
            if try_match "implements"
              set_attribute :interfaces, match_typeList
            end
            
            match_classBody name
          end
        end \
        or match :enumDeclaration do
          create_element :enum_declaration do
            match "enum"
            set_attribute :name, name = match_name

            match :enumBody do
              match "{"
              match :enumConstants do
                loop do
                  match :enumConstant do
                    create_element :enum_constant do
                      set_attribute :name, match_name
                      if next_is? :arguments
                        set_attribute :arguments, match_arguments
                      end
                      if next_is? :classBody
                        match_classBody name
                      end
                    end
                  end
                  try_match "," or break
                end
              end
              try_match ","
              try_match :enumBodyDeclarations do
                match ";"
                loop_match_classBodyDeclaration name
              end
              match "}"
            end
          end
        end
      end
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
      match :classBody do
        match "{"
        loop_match_classBodyDeclaration class_name
        match "}"
      end
    end

    def loop_match_classBodyDeclaration(class_name)
      loop_match :classBodyDeclaration do
        if try_match ";"
          next
        end
        
        if try_match "static"
          create_element :static_block do
            match :block do
              match "{"
              match_block_statements
              match "}"
            end
          end
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
                create_element :constructor do
                  set_attribute :parameters, match_formalParameters
  
                  try_match_throws
                  match :constructorBody do
                    match "{"

                    try_match :explicitConstructorInvocation do
                      if try_match "super"
                        set_attribute :explicit_invocation_type, :super
                      else
                        match "this"
                        set_attribute :explicit_invocation_type, :this
                      end
                      set_attribute :explicit_invocation_arguments, match_arguments
                      match ";"
                    end
  
                    match_block_statements
                    match "}"
                  end
                end
              end
            elsif try_match :memberDeclaration do
                type = match_type
                try_match :methodDeclaration do
                  method_name = match_name
                  match :methodDeclaratorRest do
                    match_methodDeclaratorRestContent static, native, synchronized, type, method_name
                  end
                end \
                or try_match :fieldDeclaration do
                  match_variableDeclarators(type) do |name, var_type, value|
                    create_element :field_declaration, :static => static, :final => final, :name => name, :field_type => var_type, :value => value
                  end
                  match ";"
                end
              end
            elsif try_match "void"
              method_name = match_name
              match :voidMethodDeclaratorRest do
                match_methodDeclaratorRestContent static, native, synchronized, { :type => :void_type }, method_name, nil
              end
            elsif next_is? :classDeclaration
              match_classDeclaration modifiers
            elsif next_is? :interfaceDeclaration
              match_interfaceDeclaration
            elsif try_match :genericMethodOrConstructorDecl do
                generic_classes = match_typeParameters
                match :genericMethodOrConstructorRest do
                  return_type = if try_match "void"
                    { :type => :void_type }
                  else
                    match_type
                  end
                  method_name = match_name
                  match :methodDeclaratorRest do
                    match_methodDeclaratorRestContent static, native, synchronized, return_type, method_name, generic_classes
                  end
                end
              end
            end
          end
        end
      end
    end
    
    def match_methodDeclaratorRestContent(static, native, synchronized, return_type, method_name, generic_classes = nil)
      create_element :method_declaration, :static => static, :native => native, :synchronized => synchronized, :name => method_name, :return_type => return_type, :generic_classes => generic_classes do
        set_attribute :parameters, match_formalParameters
        if try_match "["
          match "]"
        end
        try_match_throws
        if try_match ";"
          set_attribute :abstract, true
        else
          match :methodBody do
            match :block do
              match "{"
              match_block_statements
              match "}"
            end
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
              type = { :type => :array_type, :entry_type => type }
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
