module Java2Ruby
  class JavaProcessor
    def visit_compilationUnit(element)
      puts_output "require \"rjava\""
      puts_output ""
      
      @package = JavaPackage.new element[:package]

      if not element[:package].empty?
        puts_output "module #{@package.ruby_name}"
        indent_output do
          visit_compilation_unit_content element
        end
        puts_output "end"
      else
        visit_compilation_unit_content element
      end
    end
    
    def visit_compilation_unit_content(element)
      compilation_unit = JavaCompilationUnit.new @package, @basename, converter

      element[:imports].each do |import|
        compilation_unit.new_import import[:names].map{ |name| RubyNaming.ruby_package_name(name) }, import[:package_import], import[:static_import]
      end
      
      visit_children(element, :java_module => compilation_unit, :context_module => compilation_unit)
      
      puts_output compilation_unit
    end
    
    def visit_typeList
      list = []
      match :typeList do
        loop do
          list << visit_type
          try_match "," or break
        end
      end
      list
    end
    
    def visit_void_type(element, data)
      JavaType::VOID
    end
    
    def visit_primitive_type(element, data)
      JavaPrimitiveType.new element[:name]
    end
    
    def visit_class_type(element, data)
      JavaClassType.new converter, current_module, current_method, element[:package] && JavaPackage.new(element[:package]), element[:names]
    end
    
    def visit_array_type(element, data)
      JavaArrayType.new converter, visit(element[:entry_type])
    end
    
    def visit_classOrInterfaceType
      type = nil
      match :classOrInterfaceType do
        package_names = true
        package = nil
        names = []
        loop do
          name = visit_name
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
                try_match "extends", "super" and visit_type
              else
                visit_type
              end
            end
            try_match "," or break
          end
          match ">"
        end
      end
      type
    end
    
    def visit_annotation
      match :annotation do
        match "@"
        match :annotationName do
          visit_name
        end
        if try_match "("
          match :elementValue do
            if try_match :elementValueArrayInitializer do
                match "{"
                loop do
                  match :elementValue do
                    visit_conditionalExpression
                  end
                  try_match "," or break
                end
                match "}"
              end
            else
              visit_conditionalExpression
            end
          end
          match ")"
        end
      end
    end
    
    def visit_line_comment(element, data)
      @current_generator.comment element[:text], element[:same_line]
      nil
    end
    
  end
end
