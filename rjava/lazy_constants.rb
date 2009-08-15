class Module
  def lazy_constants
    @lazy_constants ||= {}
  end
  
  def expand_lazy_constant(name)
    generator = lazy_constants[name]
    if generator
      # puts "generating: #{self.name}::#{name}" if $rjava_verbose
      lazy_constants.delete name
      generator.call
      true
    else
      false
    end
  end
  
  alias_method :const_lookup_failed, :const_missing
  def const_missing(name)
    ancestors.each do |ancestor|
      if ancestor.expand_lazy_constant(name)
        return ancestor.const_get(name)
      end
    end
    
    const_lookup_failed name
  end
  
  alias_method :normal_constants, :constants
  def constants
    normal_constants + lazy_constants.keys.map { |key| key }
  end
  
  def const_set_lazy(name, &block)
    lazy_constants[name] = lambda { const_set name, block.call }
  end
  
  def include_const(parent_class, name)
    lazy_constants[name] = lambda { const_set name, parent_class.const_get(name) }
  end
end
