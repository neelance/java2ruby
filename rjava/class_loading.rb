class ClassLoaderBase
  def import_classes(target_module, package_path)
    old_target_module = @target_module
    begin
      @target_module = target_module
      call_loader_proc package_path
    ensure
      @target_module = old_target_module
    end
  end
  
  def list_paths(*paths)
    dirs = []
    names = []
    paths.each do |search_path|
      if File.exists? search_path
        Dir.entries(search_path).each do |entry|
          next if entry == "." or entry == ".."
          if File.directory? File.join(search_path, entry)
            dirs << entry if entry =~ /^[a-z][a-z0-9]*$/
          else
            name = entry.split(".").first
            names << name if name =~ /^[A-Z][a-zA-Z0-9_]*$/
          end
        end
      end
    end
    dirs.uniq!
    names.uniq!
    [dirs, names]
  end
  
  def import_package(dir, package_path)
    name = (dir[0..0].upcase << dir[1..-1]).to_sym
    sub_package_path = File.join package_path, dir
    if @target_module.const_defined? name
      import_classes @target_module.const_get(name), sub_package_path
    else
      target_module = @target_module
      generator = @target_module.lazy_constants[name] || lambda { target_module.const_set name, Module.new }
      @target_module.lazy_constants[name] = lambda {
        mod = generator.call
        import_classes mod, sub_package_path
        mod
      }
    end
  end
  
  def import_class(name, *files)
    @target_module.lazy_constants[name.to_sym] = lambda { require(*files) }
  end
  
  def import_java_class(name, java_class_name)
    return false if not is_jruby? or not JavaUtilities.get_java_class(java_class_name)
    
    @target_class.lazy_constants[name.to_sym] = lambda {
      puts "using java proxy: #{java_class_name}" if $rjava_verbose
      RJava.create_java_proxy sym, java_class_name, @target_class
    }
    true
  end
end

module Kernel
  def add_class_loader(&loader_proc)
    loader = ClassLoaderBase.new
    loader_class = (class << loader; self; end)
    loader_class.class_eval do
      define_method :call_loader_proc, &loader_proc
    end    
    loader.import_classes Object, ""
  end
end

require "jre4ruby" # TODO should not be here
