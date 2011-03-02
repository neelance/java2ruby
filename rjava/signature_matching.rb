class Vararg
  attr_reader :type
  
  def initialize(type)
    @type = type
  end
end

class Module
  public :define_method, :alias_method
  
  def can_be_nil?
    true
  end
  
  def typesig(*sig, &block)
    sig << block if block
    @current_typesig = sig
  end
  
  def method_variations
    @method_variations ||= {}
  end
  
  def specific_method_variations(name)
    if name == :initialize
      method_variations[name]
    else
      variations = []
      ancestors.each do |ancestor|
        ancestor_method_variations = ancestor.method_variations[name]
        variations.concat ancestor_method_variations if ancestor_method_variations
      end
      variations
    end
  end
  
  @@parameter_id_hash = Hash.new { |h, k| h[k] = h.size }
  def ranked_variations(name)
    @ranked_variations_hash ||= {}
    @ranked_variations_hash[name] ||= begin
      variations = {}
      specific_method_variations(name).reverse_each do |var|
        var[0] = var[0].first.call if var[0].first.is_a?(Proc)
        if var[4].nil?
          var[4] = "#{name}_#{var[0].__id__.abs}".to_sym
          var[2].define_method var[4], var[3]
          var[5] = "#{name}__#{@@parameter_id_hash[var[0].map(&:__id__ )]}".to_sym
          var[2].define_method var[5], var[3]
        end
        var[6] ||= var[0].map { |t| t.is_a?(Vararg) ? t.type : t }
        
        vararg = !var[0].empty? && var[0].last.is_a?(Vararg)
        specific_size_variations = (variations[vararg ? :varargs : var[0].size] ||= [])
        specific_size_variations.reject! { |v| v[0] == var[0] }
        specific_size_variations.unshift var
      end
      variations.each do |size, specific_size_variations|
        specific_size_variations.each_index { |i| specific_size_variations[i][1] = i }
        specific_size_variations.sort! { |a, b|
          a[0] <=> b[0] || a[1] <=> b[1]
        }
      end
      variations
    end
  end
  
  def method_added(name)
    return if !defined?(@current_typesig) or @current_typesig.nil?
    method_variations[name] ||= []
    data = [@current_typesig, 0, self, instance_method(name), nil, nil, nil]
    if @current_typesig.first == :precedence
      @current_typesig.shift
      method_variations[name].unshift data
    else
      method_variations[name] << data
    end
    @current_typesig = nil
    
    if specific_method_variations(name).size > 1
      cls = self
      
      define_method name do |*args|
        ranked_variations = cls.ranked_variations(name)
        if ranked_variations.inject(0) { |v, (size, specific_size_variations)| v + specific_size_variations.size } == 1
          single_variation = ranked_variations.values.first.first
          cls.alias_method name, single_variation[4]
          __send__ single_variation[4], *args
        else
          cache = {}
          method = cls.define_method name do |*args2|
            current_cache = cache
            args2.each do |arg|
              current_cache = (current_cache[arg.class] ||= {})
            end
            var_name = current_cache[nil]
            
            if not var_name
              var_name = Module.match_signature ranked_variations, args2
              current_cache[nil] = var_name
            end
            __send__ var_name, *args2
          end
          method.call(*args)
        end
      end
    end
  end
  
  def self.match_signature(ranked_variations, args)
    arg_count = args.size
    find_var = lambda { |hash|
      hash && hash.find { |var|
        sig_classes = var[6]
        matching = true
        arg_count.times do |i|
          arg = args[i]
          sig_class = sig_classes[i] || sig_classes.last
          if not ((arg.nil? and sig_class.can_be_nil?) or arg.is_a?(sig_class))
            matching = false
            break
          end
        end
        matching
      }
    }
    
    matching_var = find_var.call ranked_variations[arg_count]
    matching_var ||= find_var.call ranked_variations[:varargs]
    raise ArgumentError if not matching_var
    
    matching_var[4]
  end
end

module RJava
  module ObjectSignatureMatchingExtension
    def method_missing(name, *args, &block)
      if name.to_s.include?("___")
        orig_name = name.to_s.split("___").first.to_sym
        singleton_class = (class << self; self; end)
        owner = singleton_class.ancestors.find { |ancestor| ancestor.instance_methods(false).include? orig_name }
        if owner
          var_name = Module.match_signature(owner.ranked_variations(orig_name), args)
          singleton_class.alias_method name, var_name
          return __send__(var_name, *args, &block)
        end
      end

      super name, *args
    end
  end
end

class Object
  include RJava::ObjectSignatureMatchingExtension

  typesig Object
  define_method :==, instance_method(:==)
end

class Exception
  alias_method :full_backtrace, :backtrace
  def backtrace
    full_backtrace && full_backtrace.reject { |bt| bt.include?(__FILE__) }
  end
end
