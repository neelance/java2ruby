require "monitor"

class Object
  RUBY_ENGINE = "ruby" if not defined? RUBY_ENGINE
  
  def synchronization_monitor
    @synchronization_monitor ||= Monitor.new
  end

  def synchronization_condition_variable
    @synchronization_condition_variable ||= synchronization_monitor.new_cond
  end

  def wait
    synchronization_condition_variable.wait
  end
end

module Kernel
  def non_verbose
    verbose_before = $VERBOSE
    begin
      $VERBOSE = false
      yield
    ensure
      $VERBOSE = verbose_before
    end
  end
  
  def is_mri?
    RUBY_ENGINE == "ruby"
  end
  
  def is_jruby?
    RUBY_ENGINE == "jruby"
  end
  
  def is_ruby_1_8?
    RUBY_VERSION =~ /^1.8/
  end
  
  def is_ruby_1_9?
    RUBY_VERSION =~ /^1.9/
  end
  
  def synchronized(object)
    object.synchronization_monitor.synchronize do
      yield
    end
  end
end

if is_ruby_1_8?
  class String
    def force_encoding(enc)
      self
    end
    
    def ord
      self[0]
    end
  end
end

class Module
  public :define_method
  
  def included_in
    @included_in ||= []
  end
  
  undef_method :included
  def included(mod)
    included_in << mod
  end
  
  alias_method :include_orig, :include
  def include(mod)
    include_orig mod
    included_in.each { |incl_mod| incl_mod.include mod }
  end
  
  alias_method :cmp_orig, :<=>
  
  def <=>(other)
    if other == self
      0
    elsif Object == self
      1
    elsif Object == other
      -1
    else
      cmp_orig other
    end 
  end
  
  def const_attr_reader(*names)
    names.each do |name|
      define_method "attr_#{RJava.lower_name name.to_s}" do
        class_module.expand_lazy_constant name
        const_get name
      end
    end
  end
end

class Array
  @@typed_classes = {}
  attr_reader :type
  
  def self.typed(type)
    @@typed_classes[type.__id__] ||= begin
      cls = Class.new(Array)
      cls.class_eval do
        @type = type
      end
      cls
    end
  end
  
  def insert_seperators(seperator)
    a = []
    each do |e|
      a << seperator unless a.empty?
      a << e
    end
    a
  end

  def is_a?(cls)
    (self.class == Array && cls.ancestors.include?(Array)) || super
  end
end

module Tracing
  @@call_level = 0
  
  def self.call_level
    @@call_level
  end
  
  def self.call_level=(value)
    @@call_level = value
  end
  
  def self.trace_calls(mod)
    mod.class_eval do
      instance_methods.each do |name|
        method = instance_method name
        define_method name do |*args|
          return_value = nil
          begin
            puts(("  " * Tracing.call_level) + "Entering: #{name}")
            Tracing.call_level += 1
            return_value = method.bind(self).call(*args)
          ensure
            Tracing.call_level -= 1
            puts(("  " * Tracing.call_level) + "Leaving: #{name}")
          end
          return_value
        end
      end
    end
  end
end
