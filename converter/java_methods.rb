require "set"

module Java2Ruby  
  class JavaMethod < JavaMember
    attr_reader :name, :method_classes, :generic_classes
    
    def initialize(parent_module, static, name, parameters, return_type, body, generic_classes)
      super parent_module, static
      @name = name
      @ruby_name = @name && ruby_method_name(@name)
      @parameters = parameters
      @return_type = return_type
      @body = body
      @generic_classes = generic_classes || []
      @method_classes = []
      @parameters.each { |name, type, array_arg| type.context_method = self } if @parameters
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

      method_context = MethodContext.new self
      if @name.nil?
        puts_output "when_class_loaded do"
      else
        puts_output_without_comments "typesig { [#{@parameters.map{ |name, type, array_arg| array_arg ? "Vararg.new(#{type.to_s(true)})" : type.to_s(true) }.join(", ")}] }"
        parameter_names = @parameters.map { |name, type, array_arg| (array_arg ? "*" : "") + method_context.new_variable(name, type) }
        if @parent_module.type != :inner_class
          parameter_part = parameter_names.empty? ? "" : "(#{parameter_names.join(", ")})"
          puts_output "def #{@ruby_name}#{parameter_part}"
        else
          parameter_part = parameter_names.empty? ? "" : " |#{parameter_names.join(", ")}|"
          puts_output "define_method :#{@ruby_name} do#{parameter_part}"
        end
      end
      converter.switch_statement_context method_context do
        indent_output do
          write_inner_output
        end
      end
      puts_output "end"

      if @parameters and not @parameters.empty? and @parameters.last[2] and @name != :constructor # array_arg
        puts_output ""
        puts_output "typesig { [#{@parameters.map{ |name, type, array_arg| array_arg ? JavaArrayType.new(converter, type).to_s(true) : type.to_s(true) }.join(", ")}] }"
        method_context = MethodContext.new self
        parameter_names = @parameters.map { |name, type, array_arg| method_context.new_variable(name, type) }
        if @parent_module.type != :inner_class
          puts_output "def #{@ruby_name}(#{parameter_names.join(", ")})"
        else
          puts_output "define_method :#{@ruby_name} do# |#{parameter_names.join(", ")}|"
        end
        indent_output do
          argument_names = parameter_names[0..-2] + ["*#{parameter_names[-1]}"]
          puts_output "#{@ruby_name}(#{argument_names.join(", ")})"
        end
        puts_output "end"        
      end
    end
    
    def write_loaders
    end
    
    def write_inner_output
      @body.call if @body
    end
  end
  
  class JavaDefaultConstructor < JavaMethod
    def initialize(parent_module, pass_args)
      super parent_module, false, :constructor, (pass_args ? [["args", JavaType::OBJECT, true]] : []), nil, nil, nil
      @pass_args = pass_args
    end
    
    def write_inner_output
      if current_module.superclass
        current_module.fields.each { |name, field| puts_output "@#{field.ruby_name} = #{field.type.default}" }
        puts_output(@pass_args ? "super(*args)" : "super()")
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
