class Module
  public :include
  
  def class_module
    if not defined? @class_module
      @class_module = Module.new
      const_set :ClassModule, @class_module
      (class << @class_module; self; end;).include @class_module
      (class << self; self; end;).include @class_module
      self.include @class_module
      @included_with_missing_static_module ||= []
      update_static_module_includes
    end
    @class_module
  end
  
  alias_method :included_orig, :included
  def included(mod)
    included_orig mod
     (@included_with_missing_static_module ||= []) << mod
    update_static_module_includes if defined? @class_module
  end
  
  def update_static_module_includes
    until @included_with_missing_static_module.empty?
      @included_with_missing_static_module.pop.class_module.include @class_module
    end
  end
  
  def include_class_members(target)
    class_module.include target.class_module
  end
end

class Class
  undef_method :inherited
  def inherited(subclass)
   (@included_with_missing_static_module ||= []) << subclass
    update_static_module_includes if defined? @class_module
  end

  alias_method :class_inherited, :inherited
end
