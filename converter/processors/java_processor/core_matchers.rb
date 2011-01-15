module Java2Ruby
  class JavaProcessor
    def match_compilationUnit
      puts_output "require \"rjava\""
      puts_output ""
      
      match :compilationUnit do
        @package = JavaPackage.new
        if try_match :packageDeclaration do
            match "package"
            match :qualifiedName do
              loop do
                @package << match_name
                try_match "." or break
              end
            end
            match ";"
          end
          puts_output "module #{@package.ruby_name}"
          indent_output do
            match_compilation_unit_content
          end
          puts_output "end"
        else
          match_compilation_unit_content
        end
      end
    end
    
    def match_compilation_unit_content
      imports_module = JavaImportsModule.new @package, @basename, converter

      loop_match :importDeclaration do
        match "import"
        static_import = try_match "static"
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
        imports_module.new_import names, package_import, static_import
        match ";"
      end
      
      java_modules = []
      base_module = nil
      loop_match :typeDeclaration do
        try_match ";" \
        or begin
          java_module = match_classOrInterfaceDeclaration imports_module
          java_modules << java_module
          base_module = java_module if java_module.name == @basename
        end
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
