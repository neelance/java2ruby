class Module
  @@class_loaded_hooks = nil
  
  def self.class_loaded_hooks
    @@class_loaded_hooks
  end
  
  def when_class_loaded(&block)
    if @@class_loaded_hooks
      @@class_loaded_hooks << block
    else
      block.call
    end
  end
  
  def self.collect_and_run_class_loaded_hooks
    last_class_loaded_hooks = @@class_loaded_hooks
    @@class_loaded_hooks = []
    yield
    @@class_loaded_hooks.shift.call until @@class_loaded_hooks.empty?
    @@class_loaded_hooks = last_class_loaded_hooks
  end
end

module Kernel
  alias_method :original_require, :require
  
  def require_file(file)
    if File.extname(file) == ""
      $:.each do |dir|
        if File.exist?("#{dir}/#{file}.rb")
          file += ".rb"
          break
        end
      end
    end
    
    if File.extname(file) == ".rb"
      return false if $".include? file # "
      puts "requiring: #{file}" if $rjava_verbose
      original_require(file)
      return true
    end
    
    if File.extname(file) == "" and is_jruby?
      $:.each do |dir|
        if File.exist?("#{dir}/#{file}.class")
          class_name = File.basename(file)
          full_dir = File.join dir, File.dirname(file)
          puts "requiring class: #{class_name}" if $rjava_verbose
          $CLASSPATH << full_dir
          RJava.create_java_proxy class_name, class_name, Object
          return true
        end
      end
    end
    
    puts "requiring: #{file}" if $rjava_verbose
    return original_require file
  end
  
  def require(*files)
    result = true
    Module.collect_and_run_class_loaded_hooks do
      files.each do |file|
        result &&= require_file file
      end
    end
    return result
  end
end
