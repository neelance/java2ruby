module Java2Ruby
  class JavaProcessor
    def visit_interface_declaration(element, data)
      java_module = JavaModule.new data[:context_module], data[:context_module].is_a?(JavaModule) ? :local_interface : :interface, element[:name]
      java_module.generic_classes = element[:generic_classes] || []
      java_module.interfaces = (element[:interfaces] || []).map { |e| visit e }

      java_module.in_context do
        visit_children element, :java_module => java_module
      end
      
      data[:java_module].add_module java_module
    end

    def visit_class_declaration(element, data)
      module_type = if current_method
        :inner_class
      elsif data[:context_module].is_a? JavaModule
        if element[:class_modifiers].include? "static"
          :static_local_class
        else
          :local_class
        end
      else
        :class
      end
      
      java_module = JavaModule.new data[:context_module], module_type, element[:name]
      current_method.method_classes << java_module if module_type == :inner_class
      
      java_module.generic_classes = element[:generic_classes] || []
      java_module.superclass = element[:superclass] && visit(element[:superclass])
      java_module.interfaces = (element[:interfaces] || []).map { |e| visit e }
      
      java_module.in_context do
        visit_children element, :context_module => java_module, :java_module => java_module
      end
      
      if data[:in_method]
        puts_output java_module.java_type, " = ", java_module
      else
        data[:context_module].add_module java_module
      end
    end
    
    def visit_enum_declaration(element, data)
      java_module = JavaModule.new data[:context_module], :class, element[:name]
      constant_names = []
      java_module.in_context do
        visit_children element, :context_module => data[:context_module], :java_module => java_module, :constant_names => constant_names
      end

      java_module.new_method(false, "set_value_name", [["name", JavaClassType::STRING, false]], nil, lambda { puts_output "@value_name = name"; puts_output "self" })
      java_module.new_method(false, "to_s", [], nil, lambda { puts_output "@value_name" })
      java_module.new_method(true, "values", [], nil, lambda { puts_output "[#{constant_names.join(', ')}]" })
      
      data[:context_module].add_module java_module
    end
    
    def visit_enum_constant(element, data)
      enum_constant_module = data[:java_module]
      if element[:children]
        enum_constant_module = JavaModule.new java_module, :inner_class, element[:name]
        enum_constant_module.superclass = java_module.java_type
        enum_constant_module.new_constructor [], lambda { puts_output "super \"#{element[name]}\"" }
        visit_children element, :java_module => enum_constant_module
      end
      expression_parts = [enum_constant_module.java_type, ".new"]
      expression_parts.concat compose_arguments(element[:arguments])
      expression_parts << ".set_value_name(\"#{element[:name]}\")"
      ruby_name = data[:java_module].new_constant element[:name], nil, Expression.new(nil, *expression_parts)
      data[:constant_names] << ruby_name
      data[:context_module].new_constant element[:name], nil, Expression.new(nil, "#{data[:java_module].java_type}::#{ruby_name}") if data[:context_module].is_a? JavaModule
    end

    def visit_static_block(element, data)
      block_body = lambda {
        visit_children element, data
      }
      data[:java_module].new_static_block block_body
    end

    def visit_constructor(element, data)
      method_parameters = element[:parameters].map do |parameter_name, type, array_arg|
        [parameter_name, visit(type), array_arg]
      end
      
      constructor_body = lambda {
        if element[:explicit_invocation_type] == :this
          puts_output current_module.explicit_constructor_name, *compose_arguments(element[:explicit_invocation_arguments], true)
        else
          if current_module.superclass
            arguments = (element[:explicit_invocation_type] == :super) ? element[:explicit_invocation_arguments] : []
            current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = #{field.type.default}" }
            puts_output "super", *compose_arguments(arguments, true)
            current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = ", field.value.call if field.value }
          else
            current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = ", field.value ? field.value.call : field.type.default }
          end
        end

        visit_children element, :in_method => true
      }
      
      data[:java_module].new_constructor method_parameters, constructor_body
    end
          
    def visit_member_declaration(element, data)
      visit_methodDeclaratorRest java_module, static, native, synchronized, type, method_name
    end
    
    def visit_field_declaration(element, data)
      name = element[:name]
      type = visit element[:field_type]
      value = element[:value] && lambda { visit element[:value] }
      if element[:static]
        if element[:final]
          data[:java_module].new_constant name, type, value
        else
          data[:java_module].new_static_field name, type, value
        end
      else
        data[:java_module].new_field name, type, value
      end
    end
    
    def visit_constant_declaration(element, data)
      name = element[:name]
      type = visit element[:constant_type]
      value = element[:value] && lambda { visit element[:value] }
      data[:java_module].new_constant name, type, value
    end
        
    def visit_method_declaration(element, data)
      method_parameters = element[:parameters].map do |parameter_name, type, array_arg|
        [parameter_name, visit(type), array_arg]
      end
      
      if element[:native]
        data[:java_module].new_native_method(element[:static], element[:name], method_parameters, visit(element[:return_type]), element[:generic_classes])
      elsif element[:abstract]
        data[:java_module].new_abstract_method(element[:static], element[:name], method_parameters, visit(element[:return_type]), element[:generic_classes])
      else
        method_body = lambda {
          if element[:synchronized]
            puts_output "synchronized(self) do"
            indent_output do
              visit_children element
            end
            puts_output "end"
          else
            visit_children element, :context_module => data[:java_module], :java_module => data[:java_module], :in_method => true
          end
        }
        data[:java_module].new_method(element[:static], element[:name], method_parameters, visit(element[:return_type]), method_body, element[:generic_classes])
      end
    end

  end
end
