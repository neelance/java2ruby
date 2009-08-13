class Module
  public :define_method, :alias_method
  
  def typesig(*sig, &block)
    @current_typesig = block || sig
  end
  
  def method_variations
    @method_variations ||= {}
  end
  
  def method_added(name)
    return if !defined?(@current_typesig) or @current_typesig.nil?
    own_specific_method_variations = (method_variations[name] ||= [])
    own_specific_method_variations << [@current_typesig, 0, self, instance_method(name), nil]
    @current_typesig = nil
    
    specific_method_variations = []
    if name == :initialize
      specific_method_variations.concat own_specific_method_variations
    else
      ancestors.each do |ancestor|
        ancestor_method_variations = ancestor.method_variations[name]
        specific_method_variations.concat ancestor_method_variations if ancestor_method_variations
      end
    end
    
    if specific_method_variations.size > 1
      cls = self
      define_method name do |*args|
        size_hash = {}
        specific_method_variations.reverse_each do |var|
          var[0] = var[0].call if var[0].is_a?(Proc)
          if var[4].nil?
            var_name = "#{name}_#{var[0].__id__.abs}".to_sym
            var[2].define_method var_name, var[3]
            var[4] = var_name
          end
          
          specific_size_variations = (size_hash[var[0].size] ||= [])
          specific_size_variations.reject! { |v| v[0] == var[0] }
          specific_size_variations.unshift var
        end
        if size_hash.inject(0) { |v, (size, specific_size_variations)| v + specific_size_variations.size } == 1
          single_variation = size_hash.values.first.first
          cls.alias_method name, single_variation[4]
          __send__ single_variation[4], *args
        else
          size_hash.each do |size, specific_size_variations|
            specific_size_variations.each_index { |i| specific_size_variations[i][1] = i }
            specific_size_variations.sort! { |a, b|
              a[0] <=> b[0] || a[1] <=> b[1]
            }
          end
          
          cache = {}
          method = cls.define_method name do |*args|
            classes = args.map { |arg| arg.class }
            var_name = cache[classes]
            if not var_name
              arg_count = args.size
              matching_var = size_hash[arg_count].find { |var|
                sig_classes = var[0]
                matching = true
                arg_count.times do |i|
                  if not (args[i].nil? or args[i].is_a?(sig_classes[i]))
                    matching = false
                    break
                  end
                end
                matching
              } or raise ArgumentError
              
              var_name = matching_var[4]
              cache[classes] = var_name
            end
            __send__ var_name, *args
          end
          method.call(*args)
        end
      end
    end
  end
end
