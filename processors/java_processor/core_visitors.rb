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
    
    def visit_line_comment(element, data)
      @current_generator.comment element[:text], element[:same_line]
      nil
    end
  end
end
