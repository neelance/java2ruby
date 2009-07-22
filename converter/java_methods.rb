require "set"

module Java2Ruby  
  class JavaMethod < JavaMember
    attr_reader :name, :method_classes
    
    def initialize(parent_module, static, name, parameters, return_type, body = nil)
      super parent_module, static
      @name = name
      @parameters = parameters
      @return_type = return_type;
      @body = body
    end
    
    def current_module
      @parent_module
    end
    
    def current_method
      self
    end
    
    def converter
      @parent_module.converter
    end
    
    def write_output
      write_loaders
      @method_classes = []
      
      method_context = MethodContext.new self
      if @name.nil?
        puts_output "when_class_loaded do"
      else
        parameter_names = @parameters.map { |name, type, array_arg| (array_arg ? "*" : "") + method_context.new_variable(name, type) }
        puts_output_without_comments "typesig { [#{@parameters.map{ |name, type, array_arg| type }.join(", ")}] }"
        if @parent_module.type != :inner_class
          parameter_part = parameter_names.empty? ? "" : "(#{parameter_names.join(", ")})"
          puts_output "def #{ruby_method_name @name}#{parameter_part}"
        else
          parameter_part = parameter_names.empty? ? "" : " |#{parameter_names.join(", ")}|"
          puts_output "define_method :#{ruby_method_name @name} do#{parameter_part}"
        end
      end
      converter.switch_statement_context method_context do
        indent_output do
          write_inner_output
        end
      end
      puts_output "end"
    end
    
    def write_loaders
    end
    
    def write_inner_output
      @body.call if @body
    end
  end
  
  class JavaDefaultConstructor < JavaMethod
    def initialize(parent_module)
      super parent_module, false, :constructor, [], nil, nil
    end
    
    def write_inner_output
      if current_module.superclass
        current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = #{field.type.default}" }
        puts_output "super()"
        current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = ", field.value.call if field.value }
      else
        current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = ", field.value ? field.value.call : field.type.default }
      end
    end
  end
  
  class JavaAbstractMethod < JavaMethod
    def write_inner_output
      puts_output "raise NotImplementedError"
    end
  end
  
  class JavaNativeMethod < JavaMethod
    def native_method_name
      @native_method_name ||= begin
        name = (["Java"] + @parent_module.package.names + [@parent_module.name, @name.gsub("_", "_1")]).join("_")
        if @parent_module.native_method_overloaded?(@name)
          name += "__"
          @parameters.each do |param_name, type, array_arg|
            name += type.jni_signature
          end
        end
        name.include?('#{') ? "\"#{name}\".to_sym" : ":#{name}"
      end
    end
    
    def write_loaders
      arg_types = [":pointer", ":long"]
      @parameters.each do |name, type, array_arg|
        arg_types << type.ffi_type
      end
      puts_output_without_comments "JNI.native_method #{native_method_name}, [#{arg_types.join(", ")}], #{@return_type.ffi_type}"
    end
    
    def write_inner_output
      jni_parameters = ["JNI.env", "self.jni_id"]
      @parameters.each do |name, type, array_arg|
        jni_parameters << type.ffi_parameter_cast(converter.statement_context.resolve([name]).output_parts.first)
      end
      puts_output @return_type.ffi_return_cast("JNI.__send__(#{native_method_name}, #{jni_parameters.join(", ")})")
    end
  end
end