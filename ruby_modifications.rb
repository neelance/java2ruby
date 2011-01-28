require "monitor"

class Object
  RUBY_ENGINE = "ruby" if not defined? RUBY_ENGINE
  
  def class_self
    self.class
  end
  
  def synchronization_monitor
    @synchronization_monitor ||= Monitor.new
  end

  def synchronization_condition_variable
    @synchronization_condition_variable ||= synchronization_monitor.new_cond
  end

  def wait
    synchronization_condition_variable.wait
  end

  def notify
    synchronization_condition_variable.signal
  end

  def notify_all
    synchronization_condition_variable.broadcast
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
    def intern
      empty? ? :__empty_string__ : to_sym
    end

    def force_encoding(enc)
      self
    end
    
    def ord
      self[0]
    end

    def encoding
      nil
    end

    alias_method :string_push_1_8, :<<
    def <<(data)
      string_push_1_8(data.is_a?(Integer) ? data.chr : data)
    end
  end

  class Encoding
    def self.find(name)
      nil
    end
  end

  class Symbol
    alias_method :symbol_to_s, :to_s
    def to_s
      self == :__empty_string__ ? "" : symbol_to_s
    end

    def length
      to_s.length
    end

    def =~(regexp)
      to_s =~ regexp
    end
  end
  
  class Module
    alias_method :module_instance_methods, :instance_methods
    def instance_methods(include_super = true)
      module_instance_methods(include_super).map { |name| name.to_sym }
    end
  end

  class Integer
    alias_method :chr_without_encoding, :chr
    def chr(enc = nil)
      chr_without_encoding
    end
  end
end

class Module
  public :define_method
  
  def class_self
    self
  end
  
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

  def overload_protected
	  ancestor_list = ancestors
    yield
    ancestors.each do |ancestor|
      next if ancestor_list.include?(ancestor)
      ancestor.instance_methods(false).each do |name|
				next if not superclass.method_defined?(name)
        define_method name, superclass.instance_method(name)
      end
    end
  end
end

class Array
  class TypedArray < Array
    def is_a?(cls)
      (cls.ancestors.include?(TypedArray) && self.class.type.ancestors.include?(cls.type)) || super
    end
  end

  @@typed_classes = {}
  def self.typed(type)
    @@typed_classes[type.__id__] ||= begin
      cls = Class.new(TypedArray)
      (class << cls; self; end).define_method(:type) { type }
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
    (self.class == Array && cls.ancestors.include?(TypedArray)) || super
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
  
  def self.trace_all(mod, &block)
    mod.class_eval do
      instance_methods.each do |name|
        method = instance_method name
        define_method name do |*method_args, &method_block|
          bound_method = method.bind self
          block.call(name, lambda { bound_method.call(*method_args, &method_block) })
        end
      end
    end
  end

  def self.trace_call(label)
    return_value = nil
    start_time = Time.new.to_f
    begin
      puts(start_time.to_s + " " + ("  " * Tracing.call_level) + "Entering: #{label}")
      $stdout.flush
      Tracing.call_level += 1
      return_value = yield
    ensure
      Tracing.call_level -= 1
      end_time = Time.new.to_f
      duration = end_time - start_time
      puts(end_time.to_s + " " + ("  " * Tracing.call_level) + "Leaving: #{label} (#{duration}#{duration > 0.1 ? ' !!!' : ''})")
      $stdout.flush
    end
    return_value
  end

  def self.trace_calls(mod)
    trace_all(mod) { |name, block| trace_call("#{mod}.#{name}", &block) }
  end

  $tracing = false
  def self.trace_new_objects(label = nil, condition = true)
    return_value = nil
    before = {}
    after = {}
    if $debug and condition and not $tracing
      $tracing = true
      GC.start
      gc_disabled_before = GC.disable
      before = ObjectSpace.count_objects before
      start_time = Time.new.to_f
      begin
        return_value = yield
      ensure
        end_time = Time.new.to_f
        after = ObjectSpace.count_objects after
        unless after == before
          puts
          puts "#{label} (#{start_time} / #{end_time - start_time})" if label
          before.each_key do |key|
            puts "#{key} #{after[key] - before[key]}"
          end
        end
        GC.enable unless gc_disabled_before
        $tracing = false
      end
      return_value
    else
      yield
    end
  end

end
