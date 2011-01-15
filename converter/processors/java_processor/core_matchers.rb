module Java2Ruby
  class JavaProcessor
    def match_compilationUnit(element)
      puts_output "require \"rjava\""
      puts_output ""
      
      @package = JavaPackage.new element[:package]

      if not element[:package].empty?
        puts_output "module #{@package.ruby_name}"
        indent_output do
          match_compilation_unit_content element
        end
        puts_output "end"
      else
        match_compilation_unit_content element
      end
    end
    
    def match_compilation_unit_content(element)
      imports_module = JavaImportsModule.new @package, @basename, converter

      element[:imports].each do |import|
        imports_module.new_import import[:names], import[:package_import], import[:static_import]
      end
      
      java_modules = []
      base_module = nil
      element[:declared_types].each do |type|
        java_module = match_classDeclaration type, imports_module
        java_modules << java_module
        base_module = java_module if java_module.name == @basename
      end
      
      puts_output imports_module
      puts_output ""
      
      java_modules.each do |java_module|
        puts_output java_module
        puts_output ""
      end
      puts_output "#{base_module.name}.main($*) if $0 == __FILE__" if base_module and base_module.has_main
    end
    
    def match_typeList
      list = []
      match :typeList do
        loop do
          list << match_type
          try_match "," or break
        end
      end
      list
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
          type = JavaArrayType.new converter, type
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
        type = JavaClassType.new converter, current_module, current_method, package, names
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
    
    def match_annotation
      match :annotation do
        match "@"
        match :annotationName do
          match_name
        end
        if try_match "("
          match :elementValue do
            if try_match :elementValueArrayInitializer do
                match "{"
                loop do
                  match :elementValue do
                    match_conditionalExpression
                  end
                  try_match "," or break
                end
                match "}"
              end
            else
              match_conditionalExpression
            end
          end
          match ")"
        end
      end
    end
    
  end
end
