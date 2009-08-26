module Java2Ruby
  class JavaType < OutputGenerator
    def initialize
      super nil
    end
    
    def output_parts
      [to_s]
    end
  end
  
  class JavaVoidType < JavaType
    def ffi_type
      ":void"
    end
    
    def ffi_return_cast(value)
      value
    end
  end
  
  class JavaType
    VOID = JavaVoidType.new
  end
  
  class JavaPrimitiveType < JavaType
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
    
    def to_s(in_class = false)
      "::Java::#{@name[0..0].upcase}#{@name[1..-1]}"
    end
    
    def default
      case @name
      when "boolean"
        "false"
      when "float", "double"
        "0.0"
      else # "byte", "short", "int", "long", "char"
        "0"
      end
    end
    
    def jni_signature
      case @name
      when "boolean"
        "Z"
      when "char"
        "C"
      when "short"
        "S"
      when "int"
        "I"
      when "long"
        "J"
      when "byte"
        "B"
      else
        "X#{@name}X"
      end
    end
    
    def ffi_type
      case @name
      when "boolean", "byte"
        ":int8"
      when "short"
        ":int16"
      when "int"
        ":int32"
      when "long"
        ":int64"
      when "float"
        ":float"
      when "double"
        ":double"
      else
        ":unknown"
      end
    end
    
    def ffi_parameter_cast(value)
      case @name
      when "byte", "char", "short", "int", "long"
        "#{value}.to_int" # TODO FFI should do that
      when "float", "double"
        value
      when "boolean"
        "#{value} ? 1 : 0"
      else
        "0"
      end
    end
    
    def ffi_return_cast(value)
      case @name
      when "boolean"
        "#{value} != 0"
      else
        value
      end
    end
  end
  
  class JavaClassType < JavaType
    attr_reader :names, :package
    
    def initialize(converter, context_module, context_method, package, names)
      @converter = converter
      @context_module = context_module
      @context_method = context_method
      @package = package
      @names = names
    end
    
    def ==(other)
      self.equal?(other) or (other.is_a? JavaClassType and @package == other.package and @names == other.names)
    end
    
    def to_s(in_class = (@context_method.nil? || @context_method.static))
      class_name = @converter && @converter.ruby_class_name(@package, @names)
      class_name ||= begin
        name_parts = []
        name_parts << @package.ruby_name unless @package.nil? or @package.root?
        single = @package.nil? && @names.size == 1
        if single and ["Object", "String", "Boolean"].include? @names.first
          name_parts = [@names.first]
        elsif single and @names.first == "Number"
          name_parts = ["Numeric"]
        elsif single and @context_module and @context_module.generic_classes.include? @names.first
          name_parts = ["Object"]
        elsif single and @context_method and method_class = @context_method.method_classes.find { |cls| cls.name == @names.first } 
          name_parts = [method_class.java_type]
        else
          if (@package.nil? or @package.root?) and @context_module and [:inner_class, :local_class, :static_local_class].include?(@context_module.type)
            name_parts << (in_class ? "class_self" : "self.class")
          end
          name_parts.concat @names.map { |name| @converter.ruby_constant_name name }
        end
        name_parts.join "::"
      end
      class_name
    end
    
    def simple_name
      @names.last
    end
    
    def module_type
      JavaClassType.new @converter, nil, nil, nil, ["#{simple_name}Module"]
    end
    
    def default
      "nil"
    end
    
    def jni_signature
      "L\#{#{self}.jni_name}_2"
    end
    
    def ffi_type
      ":long"
    end
    
    def ffi_parameter_cast(value)
      "#{value}.jni_id"
    end
    
    def ffi_return_cast(value)
      value
    end
  end
  
  class JavaArrayType < JavaClassType
    attr_reader :entry_type
    
    def initialize(converter, entry_type)
      super converter, nil, nil, nil, ["Array"]
      @entry_type = entry_type
    end
    
    def jni_signature
      "_3#{@entry_type.jni_signature}"
    end
    
    def to_s(in_class = false)
      "Array.typed(#{@entry_type.to_s(in_class)})"
    end
    
    def default(sizes = nil)
      if sizes.nil?
        "nil"
      elsif sizes.size == 1 and @entry_type.is_a?(JavaPrimitiveType) and @entry_type.name == "char"
        Expression.new :Array, "CharArray.new(", sizes.first, ")"
      else
        size = sizes.shift
        Expression.new :Array, "Array.typed(", @entry_type, ").new(", size, ") { ", (sizes.empty? ? @entry_type.default : @entry_type.default(sizes)), " }"
      end
    end
  end
  
  class JavaInnerClassType < JavaType
    def initialize(name)
      @name = name
    end
    
    def to_s(in_class = false)
      @name
    end
    
    def simple_name
      @name
    end
    
    def module_type
      JavaInnerClassType.new "#{lower_name simple_name}_module"
    end
  end
  
  class JavaType
    STRING = JavaClassType.new nil, nil, nil, nil, ["String"]
  end
end
