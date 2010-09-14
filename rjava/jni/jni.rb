require "ffi"

module FFI::Library
  alias_method :ffi_lib_orig, :ffi_lib
  def ffi_lib(*libs)
    ffi_lib_orig *libs.map { |lib| lookup_lib lib }
  end

  def lookup_lib(lib)
    return lib if File.exist? lib
    $:.each do |path|
      full_path = "#{path}/#{lib}"
      return full_path if File.exist? full_path
    end
    raise NameError, lib
  end
  
  DEBUG = false

  alias_method :attach_function_orig, :attach_function
  def attach_function(*args)
    ruby_name, basic_native_name, arg_types, return_type = case args.size
    when 3 then [args[0], args[0], args[1], args[2]]
    when 4 then args
    else raise ArgumentError
    end
    
    attach = lambda { |native_name|
      if DEBUG
        puts "attaching: #{basic_native_name}"
        debug_name = "#{ruby_name}_inner".to_sym
        attach_function_orig debug_name, native_name, arg_types, return_type
        metaclass = (class << self; self; end)
        metaclass.define_method(ruby_name) { |*args|
          puts "calling: #{basic_native_name}"
          __send__ debug_name, *args
        }
      else
        attach_function_orig ruby_name, native_name, arg_types, return_type
      end
    }
  
    begin
      attach.call basic_native_name
    rescue FFI::NotFoundError
      arg_size = 0
      args[-2].each do |type|
        type_size = FFI.type_size type
        arg_size += type_size > 4 ? type_size : 4
      end
      begin
        attach.call "_#{args[-3]}@#{arg_size}"
      rescue FFI::NotFoundError
        attach.call "#{args[-3]}@#{arg_size}"
      end
    end
  end
end

class Object
  alias_method :jni_id, :__id__
end

class Module
  def jni_name
    @jni_name ||= get_name.gsub(".", "_")
  end

  def jni_package_name
    @jni_package_name ||= get_name.split(".")[0..-2].join("_")
  end
end

class NilClass
  def jni_id
    0
  end
end

module JniArrayFunctions
  def jni_get_elements(type, put_method_sym, boolean)
    @jni_ptr ||= begin
      @jni_ptr_ref_count = 0
      @jni_ptr_type = type
      FFI::MemoryPointer.new type, size
    end
    raise ArgumentError if type != @jni_ptr_type
    @jni_ptr.__send__ put_method_sym, 0, boolean ? self.map{ |b| b ? 1 : 0 } : self.to_a
    @jni_ptr_ref_count += 1
    @jni_ptr
  end
    
  def jni_release_elements(type, get_method_sym, boolean, ref_ptr)
    raise ArgumentError if type != @jni_ptr_type
    array = @jni_ptr.__send__ get_method_sym, 0, size
    clear
    concat(boolean ? array.map{ |b| b != 0 } : array)
    @jni_ptr_ref_count -= 1
    #if @jni_ptr_ref_count == 0 # TODO commented out to avoid much gc, but maybe a memory leak
    #  @jni_ptr.free
    #  @jni_ptr = nil
    #end
  end
end

class Array
  include JniArrayFunctions
end

class CharArray
  include JniArrayFunctions
end

class String
  def jni_get_utf_chars
    raise RuntimeError if @jni_utf_chars_ptr ||= nil
    @jni_utf_chars_ptr = FFI::MemoryPointer.new :char, size + 1
    @jni_utf_chars_ptr.write_string self
    @jni_utf_chars_ptr.put_char size, 0
    @jni_utf_chars_ptr
  end
  
  def jni_release_utf_chars
    @jni_utf_chars_ptr.free
    @jni_utf_chars_ptr = nil
  end
end

module JNI
  extend FFI::Library
  
  @@lib_files = []
  @@exception = nil
  @@exception_handler = nil

  def self.load_library(path)
    @@lib_files << path
    ffi_lib(*@@lib_files)
  end

  def self.load_native_method(name, arg_types, return_type)
   (class << self; self; end).define_method(name) { |*args|
      attach_function name, arg_types, return_type
      __send__ name, *args
    }
  end

  def self.call_native_method(name, *args)
    result = __send__ name, *args
    if @@exception
      e = @@exception
      @@exception = nil
      raise e
    end
    result
  end

  def self.on_exception(&block)
    @@exception_handler = block
  end

  def self.current_exception
    @@exception
  end
  
  module VaArgTools
    extend FFI::Library
    ffi_lib "rjava/jni/#{RJava::PLATFORM}/jni_tools.so"
  end

  @@va_arg_list = [] # TODO not thread safe
  if RUBY_PLATFORM == "x86_64-linux"
    VaArgTools.attach_function :int32, :va_arg_int32_direct, [:long], :int32
    VaArgTools.attach_function :int64, :va_arg_int64_direct, [:long], :int64

    method_names = {}
    def self.call_with_va_arg(target, method, arg_list, arg_types)
      @@va_arg_list.clear
      arg_types.each { |arg_type| @@va_arg_list << VaArgTools.__send__(arg_type, arg_list) }
      target.__send__ method, *@@va_arg_list
    rescue Exception => e
      if @@exception_handler
        @@exception_handler[e]
      else
        @@exception = e
      end
      0
    end
  else
    VaArgTools.attach_function :int32, :va_arg_int32_pointer, [:pointer], :int32
    VaArgTools.attach_function :int64, :va_arg_int64_pointer, [:pointer], :int64

    @@va_arg_list_ptr = FFI::MemoryPointer.new :long, 1
    def self.call_with_va_arg(target, method, arg_list, arg_types)
      @@va_arg_list_ptr.put_long 0, arg_list
      @@va_arg_list.clear
      arg_types.each { |arg_type| @@va_arg_list << VaArgTools.__send__(arg_type, @@va_arg_list_ptr) }
      target.__send__ method, *@@va_arg_list
    rescue Exception => e
      if @@exception_handler
        @@exception_handler[e]
      else
        @@exception = e
      end
      0
    end
  end

  class << VaArgTools
    alias_method :array_pointer, "int#{FFI.type_size(FFI.find_type(:pointer)) * 8}"
    def array(arg_list)
      ObjectSpace._id2ref array_pointer(arg_list)
    end
  end
end
