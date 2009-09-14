module RJava::ClassLoading
  @@class_paths = []

  def self.add_class_path(*layer_paths)
    @@class_paths << layer_paths
    import_classes Object, "", layer_paths
  end

  def self.bootstrap_class_paths
    paths = []
    @@class_paths.each do |layer_paths|
      $:.each do |load_path|
        full_path = File.expand_path(layer_paths.first, load_path)
        paths << full_path if File.exist?(full_path)
      end
    end
    paths
  end

  def self.import_classes(target_module, package_path, layer_paths)
    dirs = []
    names = []
    $:.each do |load_path|
      search_path = "#{load_path}/#{layer_paths.first}/#{package_path}"
      if File.directory? search_path
        Dir.entries(search_path).each do |entry|
          next if entry == "." or entry == ".."
          if File.directory? File.join(search_path, entry)
            dirs << entry if entry =~ /^[a-z][a-z0-9]*$/
          else
            names << entry.split(".").first if entry =~ /^[A-Z][a-zA-Z0-9_]*\.(rb|class)$/
          end
        end
      end
    end
    dirs.uniq!
    names.uniq!
    
    dirs.each do |dir|
      name = RJava.ruby_constant_name(dir).to_sym
      sub_package_path = File.join package_path, dir
      if target_module.const_defined? name
        import_classes target_module.const_get(name), sub_package_path, layer_paths
      else
        target_module = target_module
        target_module.lazy_constants[name] ||= lambda {
          mod = Module.new
          @@class_paths.each do |cur_layer_paths|
            import_classes mod, sub_package_path, cur_layer_paths
          end
          target_module.const_set name, mod
        }
      end
    end
    
    names.each do |name|
      target_module.lazy_constants[name.to_sym] ||= lambda {
        file_path = "#{package_path}/#{name}.rb"
        loadable_files = layer_paths.map { |layer_path| "#{layer_path}/#{file_path}" }.select { |file| $:.any? { |load_path| File.exist?("#{load_path}/#{file}") } }
        if not loadable_files.empty?
         require(*loadable_files)
        elsif is_jruby? or JavaUtilities.get_java_class(java_class_name)
          java_class_name = "#{package_path.gsub("/", ".")}.#{name}"
          puts "using java proxy: #{java_class_name}" if $rjava_verbose
          RJava.create_java_proxy sym, java_class_name, target_module
        else
          raise LoadError, name
        end
      }
    end
  end
end

module Kernel
  def add_class_path(*layer_paths)
    RJava::ClassLoading.add_class_path *layer_paths
  end
end
