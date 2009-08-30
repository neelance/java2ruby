$rjava_verbose = $*.delete("--rjava-verbose")

module RJava
  RUBY_KEYWORDS = %w{alias and begin break case class def defined do else elsif end ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield}

  def self.create_java_proxy(constant_name, class_name, target)
    proxy_class = JavaUtilities.create_proxy_class(constant_name, JavaUtilities.get_java_class(class_name), target)
    if proxy_class.is_a? Class
      proxy_class.class_eval do
        # attribute accessors
        current_class = self.java_class
        while current_class
          current_class.declared_fields.each do |field|
            unless field.static?
              name = RJava.lower_name(field.name)
              define_method name do
                field.accessible = true
                field.value self.java_object
              end
              define_method "#{name}=" do |value|
                field.accessible = true
                field.set_value self.java_object, value
                value
              end
              alias_method "attr_#{name}", name
              alias_method "attr_#{name}=", "#{name}="
            end
          end
          current_class = current_class.superclass
        end
        
        # lower name methods
        #        self.java_class.declared_instance_methods.each do |method|
        #          alias_method RJava.lower_name(method.name), method.name
        #        end
        
        # methods accepting exceptions
        self.java_class.declared_instance_methods.each do |method|
          exception_indices = []
          types = method.parameter_types
          types.each_index do |index|
            type = types[index]
            exception_indices << index if Java.java.lang.Exception.java_class.assignable_from? type
          end
          unless exception_indices.empty?
            method_name = RJava.lower_name method.name
            orig_method = instance_method method_name
            define_method method_name do |*args|
              exception_indices.each do |index|
                e = args[index]
                args[index] = e.cause if e.is_a? NativeException 
              end
              orig_method.bind(self).call(*args)
            end
          end
        end
      end
    end
    proxy_class
  end
  
  def self.lower_name(name, escape_first = false)
    name = "_#{name}" if escape_first and name[0] == ?_
    new_word = escape_first
    name.gsub(/./) { |char|
      case char
      when /[a-z]/
        new_word = true
        char
      when /[A-Z]/
        if new_word
          new_word = false
          escape_first = false
          "_" + char.downcase
        else
          char.downcase
        end
      else
        new_word = false unless escape_first
        char
      end
    }
  end
  
  def self.ruby_method_name(name)
    case name
    when :constructor
      "initialize"
    when "initialize"
      "initialize_"
    when "toString"
      "to_s"
    when "equals"
      "=="
    else
      ruby_name = lower_name name, true
      ruby_name << "_" if RUBY_KEYWORDS.include?(ruby_name)
      ruby_name
    end
  end
  
  def self.ruby_constant_name(name)
    return "Exception" if name == :ruby_exception
    if name.to_s[0..0] =~ /[a-z]/
      if name.to_s[1..1] =~ /[A-Z]/
        name = name.to_s[0..0].upcase + "_" + name.to_s[1..-1]
      else
        name = name.to_s[0..0].upcase + name.to_s[1..-1]
      end
    end
    name = "Java#{name}" if %w{Comparable Date Error Exception File Integer List Queue Set Thread ThreadGroup Throwable}.include? name
    name << "_" if %w{BEGIN END}.include? name
    name
  end
  
  def self.ruby_package_name(name)
    ruby_constant_name name
  end
  
  def self.ruby_class_name(names)
    names.map do |name|
      ruby_constant_name name
    end
  end

  def self.cast_to_string(v)
    v.nil? ? nil : v.to_s
  end
  
  def self.cast_to_short(v)
    v = v.to_int % 0x10000
    v -= 0x10000 if v >= 0x8000
    v
  end
  
  def self.cast_to_int(v)
    v.to_int
  end
  
  def self.cast_to_char(v)
    Java::Lang::Character.new v.to_i
  end
end

require "rjava/ruby_modifications"
require "rjava/lazy_constants"
require "rjava/signature_matching"
require "rjava/class_module"
require "rjava/local_class"
require "rjava/extended_require"
require "rjava/class_loading"
require "rjava/java_base"
require "rjava/char_array"
require "rjava/jni/jni"
require "rjava/jni/jni_structs_#{RUBY_PLATFORM}"
