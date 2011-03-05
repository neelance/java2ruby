module RJava
  extend RubyNaming
  
  begin
    cpu, os = RUBY_PLATFORM.split "-", 2
    cpu = "x86_32" if cpu =~ /^i\d86$/
    os = case os
    when /^unknown-linux-gnu$/ then "linux"
    when /^darwin(\d+)?$/ then "darwin"
    else os
    end
    CPU = cpu
    OS = os
    PLATFORM = "#{os}-#{cpu}"
  end
  
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
  
  def self.cast_to_string(v)
    v.nil? ? nil : v.to_s
  end
  
  def self.cast_to_short(v)
    v = v.to_int % 0x10000
    v -= 0x10000 if v >= 0x8000
    v
  end
    
  def self.cast_to_char(v)
    Java::Lang::Character.new v.to_i
  end
end
