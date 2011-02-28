module Java2Ruby
  class JavaProcessor
    def visit_compilation_unit(element, data)
      puts_output "require \"rjava\""
      puts_output ""
      
      visit_children element, data

      base_module = data[:java_module].base_module
      if base_module and base_module.has_main
        puts_output ""
        puts_output "#{data[:java_module].package ? "#{data[:java_module].package.ruby_name}::" : ""}#{base_module.name}.main($*) if $0 == __FILE__"
      end
    end
    
    def visit_package(element, data)
      package = JavaPackage.new element[:name]
      data[:java_module].package = package

      puts_output "module #{package.ruby_name}"
      indent_output do
        visit_children element, data
      end
      puts_output "end"
    end
    
    def visit_import(element, data)
    	data[:java_module].new_import element[:names].map{ |name| RubyNaming.ruby_package_name(name) }, element[:package_import], element[:static_import]
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
