module LocalClass
  module LocalClassMethodMissing
    attr_reader :local_class_parent
    
    def method_missing(name, *args, &block)
      @local_class_parent.__send__(name, *args, &block)
    end
  end
  
  def self.extend_object(cls)
    super
    cls.instance_eval do
      include LocalClassMethodMissing
    end
  end
  
  def new_local(parent, *args)
    inst = allocate
    inst.instance_eval do
      @local_class_parent = parent
      initialize(*args)
    end
    inst
  end
end

class Module
  def local_class_in(cls)
    extend LocalClass
    cls.instance_methods.each do |name|
      if not instance_methods.include?(name)
        define_method name do |*args, &block|
          @local_class_parent.__send__(name, *args, &block)
        end
      end
    end
  end
end
