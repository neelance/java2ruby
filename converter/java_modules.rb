module Java2Ruby
  class JavaMember < OutputGenerator
    attr_reader :parent_module, :static
    
    def initialize(parent_module, static)
      super parent_module.converter
      @parent_module = parent_module
      @static = static
    end
    
    def current_module
      @parent_module.current_module
    end
    
    def current_method
      @parent_module.current_method
    end
  end
  
  class JavaConstant < JavaMember
    attr_reader :name, :ruby_name, :type, :value
    
    def initialize(parent_module, name, type, value)
      super parent_module, true
      @name = name
      @ruby_name = converter.ruby_constant_name name
      @type = type
      @value = value
    end
    
    def write_output
      constant_parts = ["const_set_lazy(:#{@ruby_name}) { "]
      if @value.is_a? Expression
        constant_parts << @value
      else
        constant_parts << @value.call
      end
      constant_parts << " }"
      puts_output(*constant_parts)
      puts_output "const_attr_reader  :#{@ruby_name}"
    end
    
    def expression
      @expression ||= ConstantExpression.new self
    end
  end
  
  class ConstantExpression < Expression
    attr_reader :constant
    
    def initialize(constant)
      @constant = constant
    end
    
    def type
      @constant.type
    end
    
    def output_parts
      @output_parts ||= if [:inner_class, :local_class, :static_local_class].include?(@constant.parent_module.type)
        ["self.class::", @constant.ruby_name]
      else
        [@constant.ruby_name]
      end
    end
  end
  
  class JavaStaticField < JavaMember
    attr_reader :name, :ruby_name, :type, :value
    
    def initialize(parent_module, name, type, value)
      super parent_module, true
      @name = name
      @ruby_name = converter.ruby_field_name name
      @type = type
      @value = value
    end
    
    def write_output
      real_value = @value ? @value.call : @type.default
      puts_output ""
      puts_output "def #{@ruby_name}"
      indent_output do
        puts_output "defined?(@@#{@ruby_name}) ? @@#{@ruby_name} : @@#{@ruby_name}= ", real_value
      end
      puts_output "end"
      puts_output "alias_method :attr_#{@ruby_name}, :#{@ruby_name}"
      puts_output ""
      puts_output "def #{@ruby_name}=(value)"
      indent_output do
        puts_output "@@#{@ruby_name} = value"
      end
      puts_output "end"
      puts_output "alias_method :attr_#{@ruby_name}=, :#{@ruby_name}="
    end
  end
  
  class JavaField < JavaMember
    attr_reader :name, :ruby_name, :type, :value
    
    def initialize(parent_module, name, type, value)
      super parent_module, false
      @name = name
      @ruby_name = converter.ruby_field_name name
      @type = type
      @value = value
    end
    
    def write_output
      puts_output "attr_accessor :#{@ruby_name}"
      puts_output "alias_method :attr_#{@ruby_name}, :#{@ruby_name}"
      puts_output "undef_method :#{@ruby_name}"
      puts_output "alias_method :attr_#{@ruby_name}=, :#{@ruby_name}="
      puts_output "undef_method :#{@ruby_name}="
    end
  end
  
  class JavaModule < JavaMember
    attr_reader :context_module, :type, :name, :has_main
    attr_accessor :superclass, :interfaces
    attr_accessor :variable_declarators, :fields, :generic_classes
    
    def initialize(context_module, type, name) # possible types: :class, :inner_class, :local_class, :interface, :local_interface
      super context_module, true
      @context_module = context_module
      @type = type
      @name = name
      
      @superclass = nil
      @interfaces = []
      @members = []
      @local_modules = {}
      @constructors = []
      @has_constructor = false
      @has_main = false
      @static_fields = {}
      @variable_declarators = []
      @fields = {}
      @constants = {}
      @generic_classes = []
      @ruby_method_names = Set.new
    end
    
    def package
      @context_module.package
    end
    
    def simple_name
      @name || (@superclass && @superclass.simple_name) || (@interfaces.first && @interfaces.first.simple_name) || "anonymous"
    end
    
    def explicit_constructor_name
      @name ? "initialize_#{ruby_method_name(@name)}" : "initialize_anonymous"
    end
    
    def java_type
      if @type == :inner_class
        JavaInnerClassType.new "#{lower_name simple_name}_class"
      else
        JavaClassType.new converter, nil, nil, nil, [simple_name]
      end
    end
    
    def add_local_module(mod)
      @local_modules[mod.name] = mod
      @members << mod
    end
    
    def find_local_module(name)
      @local_modules[name]
    end
    
    def new_constant(name, type, value)
      # override System.out and System.err
      if @name == "System" and (name == "in" or name == "out" or name == "err")
        new_static_field name, type, value
        return
      end
      constant = JavaConstant.new self, name, type, value
      @constants[name] = constant
      @members << constant unless value.nil?
      constant.ruby_name
    end
    
    def new_static_field(name, type, value)
      field = JavaStaticField.new self, name, type, value
      @static_fields[name] = field
      @members << field
    end
    
    def new_field(name, type, value)
      field = JavaField.new self, name, type, value
      @fields[name] = field
      @members << field
    end
    
    def new_method(static, name, parameters, return_type, body, generic_classes = nil)
      @has_main = true if static and name == "main"
      @members << JavaMethod.new(self, static, name, parameters, return_type, body, generic_classes)
    end
    
    def new_abstract_method(static, name, parameters, return_type, generic_classes = nil)
      @members << JavaAbstractMethod.new(self, static, name, parameters, return_type, nil, generic_classes)
    end
    
    def new_native_method(static, name, parameters, return_type, generic_classes = nil)
      @members << JavaNativeMethod.new(self, static, name, parameters, return_type, nil, generic_classes)
    end
    
    def new_static_block(block_body)
      @members << JavaMethod.new(self, true, nil, nil, nil, block_body, nil)
    end
    
    def new_constructor(parameters, body)
      @has_constructor = true
      @members << JavaMethod.new(self, false, :constructor, parameters, nil, body, nil)
    end
    
    def method_used(name)
      ruby_name = ruby_method_name name
      @ruby_method_names << ruby_name
    end
    
    def has_ruby_method?(name)
      @ruby_method_names.include? name
    end
    
    def native_method_overloaded?(name)
      first_found = false
      @members.each do |method|
        if method.is_a?(JavaNativeMethod) and method.name == name
          return true if first_found
          first_found = true
        end
      end
      false
    end
    
    def find_static_field(name)
      @static_fields[name] || @context_module.find_static_field(name)
    end
    
    def find_constant(name)
      @constants[name] || @context_module.find_constant(name)
    end
    
    def current_module
      self
    end
    
    def current_method
      nil
    end
    
    def resolve(identifiers)
      first_identifier = identifiers.shift
      
      if first_identifier == "this"
        if field = fields[identifiers.first]
          identifiers.shift
          Expression.new nil, "@#{field.ruby_name}"
        else
          Expression.new nil, "self"
        end
      elsif first_identifier == "System"
        if ["in", "out", "err"].include? identifiers.first
          Expression.new nil, "System", ".", identifiers.shift
        else
          Expression.new nil, "System"
        end
      elsif first_identifier == @name and field1 = find_static_field(identifiers.first)
        identifiers.shift
        Expression.new field1.type, "self.attr_#{field1.ruby_name}"
      elsif field2 = find_static_field(first_identifier)
        Expression.new field2.type, "self.attr_#{field2.ruby_name}"
      elsif field3 = @fields[first_identifier]
        Expression.new field3.type, "@#{field3.ruby_name}"
      elsif constant = find_constant(first_identifier)
        constant.expression
      else
        class_name_index = -1
        class_name_index = 0 if converter.is_constant?(first_identifier)
        identifiers.each_index do |i|
          if converter.is_constant?(identifiers[i])
            class_name_index = i + 1
          end
        end
        
        if class_name_index == -1
          Expression.new nil, "self.attr_#{ruby_field_name first_identifier}"
        else
          names = [first_identifier]
          1.upto(class_name_index) do
            names << identifiers.shift
          end
          Expression.new nil, JavaClassType.new(converter, nil, nil, nil, names).to_s
        end
      end
    end
    
    def write_output
      if @name == "Throwable"
        @superclass = JavaClassType.new converter, nil, nil, JavaPackage::ROOT, [:ruby_exception]
      end
      
      # write module
      case @type
      when :class
        superclas_part = if @superclass
          " < " + if @context_module.is_a? JavaImportsModule and not @superclass.package
            "#{@context_module.java_type}.const_get :#{@superclass}"
          else
            @superclass.to_s
          end
        else
          " "
        end
        puts_output "class #{java_type}#{superclas_part}"
      when :local_class, :static_local_class
        superclass_part = @superclass ? "(#{@superclass})" : ""
        puts_output "const_set_lazy(:#{java_type}) { Class.new#{superclass_part} do"
      when :inner_class
        superclass_part = @superclass ? "(#{@superclass}.class == Class ? #{@superclass} : Object)" : ""
        puts_output "Class.new#{superclass_part} do"
      when :interface
        puts_output "module #{java_type}"
      when :local_interface
        puts_output "const_set_lazy(:#{java_type}) { Module.new do"
      end
      
      # default constructor
      if not @has_constructor
        case @type
        when :class, :local_class, :static_local_class
          @members << JavaDefaultConstructor.new(self, false)
        when :inner_class
          @members << JavaDefaultConstructor.new(self, !@superclass.nil?)
        end
      end
      
      indent_output do
        puts_output "extend LocalClass" if @type == :inner_class or @type == :local_class
        puts_output "include_class_members #{@context_module.java_type}"
        puts_output "include #{@superclass.to_s(true)} if #{@superclass.to_s(true)}.class == Module" if @type == :inner_class and @superclass
        unless @interfaces.empty?
          if @superclass
            puts_output "overload_protected {"
            indent_output do
              @interfaces.each do |interface|
                puts_output "include #{interface}"
              end
            end
            puts_output "}"
          else
            @interfaces.each do |interface|
              puts_output "include #{interface}"
            end
          end
        end
        
        write_members = lambda { |static, member_block|
          if static
            puts_output ""
            puts_output "class_module.module_eval {"
            indent_output do
              member_block.each_index do |i|
                puts_output "" unless i == 0
                puts_output member_block[i]
              end
            end
            puts_output "}"
          else
            member_block.each_index do |i|
              puts_output ""
              puts_output member_block[i]
            end
          end
        }
        member_block = []
        static = @members.first.static unless @members.empty?
        @members.each do |member|
          if member.static != static
            write_members[static, member_block]
            member_block.clear
            static = member.static
          end
          member_block << member
        end
        write_members[static, member_block]
        
        unless @type == :interface or @type == :local_interface
          puts_output ""
          puts_output "private"
          puts_output "alias_method :#{explicit_constructor_name}, :initialize"
        end
      end
      
      if @type == :local_class || @type == :static_local_class || @type == :local_interface
        puts_output "end }"
      else
        puts_output "end"
      end
    end
    
  end
  
  class JavaImportsModule < OutputGenerator
    def initialize(package, basename, converter)
      super converter
      @package = package
      @basename = basename
      @imports = []
    end
    
    def package
      @package
    end
    
    def new_import(names, package_import, static_import)
      @imports << [names, package_import, static_import]
    end
    
    def java_type
      JavaClassType.new converter, nil, nil, nil, ["#{@basename}Imports"]
    end
    
    def find_static_field(name)
      nil
    end
    
    def find_constant(name)
      nil
    end
    
    def write_output
      puts_output "module ", java_type, " #:nodoc:"
      indent_output do
        puts_output "class_module.module_eval {"
        indent_output do
          puts_output 'include ::Java::Lang'
          puts_output "include ::#{@package.ruby_name}" unless @package.names.empty? or @package.names == ["java", "lang"]
          
          @imports.each do |names, package_import, static_import|
            if package_import
              if static_import
                #                puts_output "class << self; Java.#{name}.methods(false).each { |m| define_method(m) { |*args| Java.#{name}.method(m).call(*args) } }; end"
                #                puts_output "Java.#{name}.constants.each { |c| const_set c, Java.#{name}.const_get(c) }"
              else
                puts_output "include ::#{names.join('::')}"
              end
            else
              puts_output "include_const ::#{names[0..-2].join('::')}, :#{JavaClassType.new(@converter, nil, nil, nil, [names.last])}"
            end
          end
        end
        puts_output "}"
      end
      puts_output "end"
    end
  end
end
