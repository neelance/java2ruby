module Java2Ruby
  class JavaParseTreeProcessor
    EPSILON = "<epsilon>".to_sym

    attr_reader :next_element
    def process(tree)
      @elements = tree[:children]
      @next_element_index = 0
      @next_element = @elements.first

      match_compilationUnit
    end

    def match_compilationUnit
      element = {
        :type => :compilation_unit,
        :package => [],
        :imports => [],
        :declared_types => []
      }

      match :compilationUnit do
        try_match :packageDeclaration do
          match "package"
          match :qualifiedName do
            loop do
              element[:package] << match_name
              try_match "." or break
            end
          end
          match ";"
        end

        loop_match :importDeclaration do
          match "import"
          static_import = !try_match("static").nil?
          names = []
          package_import = false
          match :qualifiedName do
            names << RJava.ruby_package_name(match_name)
            while try_match "."
              names << RJava.ruby_package_name(match_name)
            end
          end
          if try_match "."
            match "*"
          package_import = true
          end
          match ";"

          element[:imports] << { :type => :import, :names => names, :package_import => package_import, :static_import => static_import }
        end

        loop_match :typeDeclaration do
          try_match ";" \
          or begin
            element[:declared_types] << match_classOrInterfaceDeclaration
          end
        end
      end

      element
    end

    def match_classOrInterfaceDeclaration
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
          match_classDeclaration []
        else
          match_interfaceDeclaration
        end
      end
      java_module
    end
    
    def match_classDeclaration(class_modifiers)
      element = {
        :type => :class_declaration,
        :class_modifiers => [],
        :generic_classes => [],
        :superclass => nil,
        :interfaces => [],
        :methods => []
      }
      
      match :classDeclaration do
        try_match :normalClassDeclaration do
          match "class"
          element[:name] = match_name

          if next_is? :typeParameters
            java_module.generic_classes = match_typeParameters
          end
          if try_match "extends"
            java_module.superclass = match_type
          end
          if try_match "implements"
            java_module.interfaces = match_typeList
          end
          match_classBody element
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
        end
      end
      
      element
    end
    
    def match_classBody(element)
      match :classBody do
        match "{"
        loop_match_classBodyDeclaration element
        match "}"
      end
    end
    
    def loop_match_classBodyDeclaration(element)
      element[:body_declarations] = []
      
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
            if try_match element[:name]
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
                    method_body = { :type => :body, :children => [] }
                    match :block do
                      match "{"
                      method_body[:children] << consume while next_is?(:blockStatement)
                      # match_block_statements
                      match "}"
                    end
                    element[:body_declarations] << { :type => :void_method_declaration, :static => static, :name => method_name, :parameters => method_parameters, :return_type => :void, :synchronized => synchronized, :body => method_body }
                  end
                end
              end
            elsif next_is? :classDeclaration
              java_module.add_local_module match_classDeclaration(modifiers, java_module)
            elsif next_is? :interfaceDeclaration
              java_module.add_local_module match_interfaceDeclaration(java_module)
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
    
    def match_type
      type = nil
      match :type do
        if try_match :primitiveType do
            type = JavaPrimitiveType.new match_name
          end
        elsif next_is? :classOrInterfaceType
          type = match_classOrInterfaceType
        end
        while try_match "["
          match "]"
          type = { :type => :java_array_type, :entry_type => type }
        end
      end
      type
    end
    
    def match_classOrInterfaceType
      type = nil
      match :classOrInterfaceType do
        package_names = true
        package = nil
        names = []
        loop do
          name = match_name
          is_last = !try_match(".")
          package_names = false if name =~ /^[A-Z]/ or is_last
          if package_names
            package ||= JavaPackage.new
            package << name
          else
            names << name
          end
          break if is_last
        end
        type = { :type => :java_class_type, :package => package, :names => names }
        try_match :typeArguments do
          match "<"
          loop do
            match :typeArgument do
              if try_match "?"
                try_match "extends", "super" and match_type
              else
                match_type
              end
            end
            try_match "," or break
          end
          match ">"
        end
      end
      type
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
    
    def process_children(element)
      parent_elements = @elements
      parent_next_element_index = @next_element_index

      @elements = element[:children]
      @next_element_index = 0
      @next_element = @elements.first
      result = yield
      raise ArgumentError, "Elements of #{element[:internal_name]} not processed: #{@elements[@next_element_index..-1].map{ |child| child[:internal_name] }.join(", ")}" if not @next_element_index == @elements.size

      @elements = parent_elements
      @next_element_index = parent_next_element_index
      @next_element = @elements && @elements[@next_element_index]

      result
    end

    def next_is?(*names)
      next_element && names.include?(next_element[:internal_name])
    end

    def match(*names)
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of #{names.inspect}" if not names.include? next_element[:internal_name]
      element = consume
      process_children element do
        yield if block_given?
      end
      element[:text]
    end

    def match_name
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of name string" if not next_element[:internal_name].is_a? String
      consume[:text] # string elements have no children
    end

    def try_match(*names)
      return nil if not next_is?(*names)
      element = consume
      process_children element do
        yield if block_given?
      end
      element[:text]
    end

    def buffer_match(*names)
      raise "Wrong match: #{next_element[:internal_name].inspect} instead one of #{names.inspect}" if not names.include? next_element[:internal_name]
      element = consume
      lambda {
        process_children element do
          yield
        end
      }
    end

    def loop_match(name)
      loop do
        try_match(name) do
          yield
        end or break
      end
    end

    def multi_match(*options)
      result = nil
      index = 0
      loop do
        names = options.map { |option| option[index] }
        break if not names.any?
        part = names.all? ? match(*names) : try_match(*names)
        break if part.nil?
        options.reject! { |option| option[index] != part }
        result ||= ""
        result << part
        index += 1
      end
      result
    end

    def consume
      current_element = next_element

      # handle comments
      # if current_element[:hidden_tokens]
      #   current_element[:hidden_tokens].each do |hidden_token|
      #     if hidden_token[:type] == JavaLexer::LINE_COMMENT
      #     @current_generator.single_line_comment hidden_token[:text][2..-1].strip
      #     elsif hidden_token[:type] == JavaLexer::COMMENT
      #       lines = []
      #       hidden_token[:text].split("\n").each do |line|
      #         line.strip!
      #         line.gsub! /\*\/$/, ""
      #         line.gsub! /^\/?\*+/, ""
      #         line.strip!
      #         lines << line
      #       end
      #     @current_generator.multi_line_comment lines
      #     elsif hidden_token[:text] == "\r" || hidden_token[:text] == "\n"
      #     @current_generator.new_line
      #     end
      #   end
      # end

      @next_element_index += 1
      @next_element = @elements[@next_element_index]

      current_element
    end
  end
end