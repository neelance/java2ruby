module Java2Ruby
  class JavaParseTreeProcessor
    def match_compilationUnit(element)
      puts_output "require \"rjava\""
      puts_output ""
      
      package = JavaPackage.new element[:package]

      if not element[:package].empty?
        puts_output "module #{package.ruby_name}"
        indent_output do
          match_compilation_unit_content element
        end
        puts_output "end"
      else
        match_compilation_unit_content element
      end
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
            type = { :type => :primitive_type, :name => match_name }
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
