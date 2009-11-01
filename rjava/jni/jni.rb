require "ffi"

class Object
  alias_method :jni_id, :__id__
end

class Module
  def jni_name
    @jni_name ||= get_name.gsub(".", "_")
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

  class FieldID
    attr_reader :reader_sym, :writer_sym

    def initialize(name)
      lower_name = RJava.lower_name name
      @reader_sym = "attr_#{lower_name}".to_sym
      @writer_sym = "attr_#{lower_name}=".to_sym
    end
  end
  
  class MethodID
    attr_reader :name_sym, :arg_types, :return_type
    
    def initialize(name, sig)
      @name_sym = RJava.ruby_method_name(name).to_sym
      raise ArgumentError if not sig =~ /^\((.*?)\)(.)$/
      @return_type = parse_type $2
      @arg_types = $1.split("").map { |char| parse_type char }
    end
    
    def parse_type(char)
      case char
      when "B"
        :int8
      when "I"
        :int32
      when "J"
        :int64
      else
        :unknown
      end
    end
  end
  
  @@lib_files = []
  
  module EnvFunctions
    @@functions = %w{GetVersion DefineClass FindClass FromReflectedMethod FromReflectedField ToReflectedMethod GetSuperclass IsAssignableFrom ToReflectedField Throw ThrowNew ExceptionOccurred ExceptionDescribe ExceptionClear FatalError PushLocalFrame PopLocalFrame NewGlobalRef DeleteGlobalRef DeleteLocalRef IsSameObject NewLocalRef EnsureLocalCapacity AllocObject NewObject NewObjectV NewObjectA GetObjectClass IsInstanceOf GetMethodID CallObjectMethod CallObjectMethodV CallObjectMethodA CallBooleanMethod CallBooleanMethodV CallBooleanMethodA CallByteMethod CallByteMethodV CallByteMethodA CallCharMethod CallCharMethodV CallCharMethodA CallShortMethod CallShortMethodV CallShortMethodA CallIntMethod CallIntMethodV CallIntMethodA CallLongMethod CallLongMethodV CallLongMethodA CallFloatMethod CallFloatMethodV CallFloatMethodA CallDoubleMethod CallDoubleMethodV CallDoubleMethodA CallVoidMethod CallVoidMethodV CallVoidMethodA CallNonvirtualObjectMethod CallNonvirtualObjectMethodV CallNonvirtualObjectMethodA CallNonvirtualBooleanMethod CallNonvirtualBooleanMethodV CallNonvirtualBooleanMethodA CallNonvirtualByteMethod CallNonvirtualByteMethodV CallNonvirtualByteMethodA CallNonvirtualCharMethod CallNonvirtualCharMethodV CallNonvirtualCharMethodA CallNonvirtualShortMethod CallNonvirtualShortMethodV CallNonvirtualShortMethodA CallNonvirtualIntMethod CallNonvirtualIntMethodV CallNonvirtualIntMethodA CallNonvirtualLongMethod CallNonvirtualLongMethodV CallNonvirtualLongMethodA CallNonvirtualFloatMethod CallNonvirtualFloatMethodV CallNonvirtualFloatMethodA CallNonvirtualDoubleMethod CallNonvirtualDoubleMethodV CallNonvirtualDoubleMethodA CallNonvirtualVoidMethod CallNonvirtualVoidMethodV CallNonvirtualVoidMethodA GetFieldID GetObjectField GetBooleanField GetByteField GetCharField GetShortField GetIntField GetLongField GetFloatField GetDoubleField SetObjectField SetBooleanField SetByteField SetCharField SetShortField SetIntField SetLongField SetFloatField SetDoubleField GetStaticMethodID CallStaticObjectMethod CallStaticObjectMethodV CallStaticObjectMethodA CallStaticBooleanMethod CallStaticBooleanMethodV CallStaticBooleanMethodA CallStaticByteMethod CallStaticByteMethodV CallStaticByteMethodA CallStaticCharMethod CallStaticCharMethodV CallStaticCharMethodA CallStaticShortMethod CallStaticShortMethodV CallStaticShortMethodA CallStaticIntMethod CallStaticIntMethodV CallStaticIntMethodA CallStaticLongMethod CallStaticLongMethodV CallStaticLongMethodA CallStaticFloatMethod CallStaticFloatMethodV CallStaticFloatMethodA CallStaticDoubleMethod CallStaticDoubleMethodV CallStaticDoubleMethodA CallStaticVoidMethod CallStaticVoidMethodV CallStaticVoidMethodA GetStaticFieldID GetStaticObjectField GetStaticBooleanField GetStaticByteField GetStaticCharField GetStaticShortField GetStaticIntField GetStaticLongField GetStaticFloatField GetStaticDoubleField SetStaticObjectField SetStaticBooleanField SetStaticByteField SetStaticCharField SetStaticShortField SetStaticIntField SetStaticLongField SetStaticFloatField SetStaticDoubleField NewString GetStringLength GetStringChars ReleaseStringChars NewStringUTF GetStringUTFLength GetStringUTFChars ReleaseStringUTFChars GetArrayLength NewObjectArray GetObjectArrayElement SetObjectArrayElement NewBooleanArray NewByteArray NewCharArray NewShortArray NewIntArray NewLongArray NewFloatArray NewDoubleArray GetBooleanArrayElements GetByteArrayElements GetCharArrayElements GetShortArrayElements GetIntArrayElements GetLongArrayElements GetFloatArrayElements GetDoubleArrayElements ReleaseBooleanArrayElements ReleaseByteArrayElements ReleaseCharArrayElements ReleaseShortArrayElements ReleaseIntArrayElements ReleaseLongArrayElements ReleaseFloatArrayElements ReleaseDoubleArrayElements GetBooleanArrayRegion GetByteArrayRegion GetCharArrayRegion GetShortArrayRegion GetIntArrayRegion GetLongArrayRegion GetFloatArrayRegion GetDoubleArrayRegion SetBooleanArrayRegion SetByteArrayRegion SetCharArrayRegion SetShortArrayRegion SetIntArrayRegion SetLongArrayRegion SetFloatArrayRegion SetDoubleArrayRegion RegisterNatives UnregisterNatives MonitorEnter MonitorExit GetJavaVM GetStringRegion GetStringUTFRegion GetPrimitiveArrayCritical ReleasePrimitiveArrayCritical GetStringCritical ReleaseStringCritical NewWeakGlobalRef DeleteWeakGlobalRef ExceptionCheck NewDirectByteBuffer GetDirectBufferAddress GetDirectBufferCapacity GetObjectRefType}.map { |name| [name.to_sym, [], :void, lambda { raise NotImplementedError, name }] }
    
    def self.map_function(name, arg_types, return_type, &block)
      @@functions.find { |function| function[0] == name }.replace [name, arg_types, return_type, block]
    end
    
    def self.each_function
      @@functions.each do |name, arg_types, return_type, block|
        yield name, arg_types, return_type, block
      end
    end
    
    type_map = [["Byte", :uint8], ["Char", :uint16], ["Short", :int16], ["Int", :int32], ["Long", :int64], ["Float", :float], ["Double", :double]]
    
    @@global_refs = []
    @@exception = nil

    map_function :GetVersion, [:long], :int do |env|
      0x00010006
    end
    
    map_function :ExceptionOccurred, [:long], :long do |env|
      0
    end
    
    map_function :NewGlobalRef, [:long, :long], :long do |env, object_id|
      @@global_refs << ObjectSpace._id2ref(object_id)
      object_id
    end
    
    map_function :DeleteGlobalRef, [:long, :long], :void do |env, object_id|
      @@global_refs.delete ObjectSpace._id2ref(object_id)
    end
    
    map_function :IsSameObject, [:long, :long, :long], :int8 do |env, object_1_id, object_2_id|
      (object_1_id == object_2_id) ? 1 : 0
    end
    
    map_function :GetObjectClass, [:long, :long], :long do |env, object_id|
      ObjectSpace._id2ref(object_id).class.__id__
    end
    
    map_function :GetMethodID, [:long, :long, :string, :string], :long do |env, object_id, name, sig|
      method_id = MethodID.new name, sig
      @@global_refs << method_id
      method_id.jni_id
    end
    
    type_map.each do |name, type|
      map_function "Call#{name}Method".to_sym, [:long, :long, :long], type do |env, object_id, method_id|
        puts "Call#{name}Method"
        exit
      end
    end
    
    type_map.each do |name, type|
      map_function "Call#{name}MethodV".to_sym, [:long, :long, :long, :long], type do |env, object_id, method_id, arg_list|
        begin
          method_id = ObjectSpace._id2ref method_id
          JNI.call_with_va_arg ObjectSpace._id2ref(object_id), method_id.name_sym, arg_list, method_id.arg_types
        rescue Exception => e
          @@exception = e
          0
        end
      end
    end
    
    map_function :GetFieldID, [:long, :long, :string, :string], :long do |env, class_id, name, type|
      field_id = FieldID.new name
      @@global_refs << field_id
      field_id.__id__
    end

    map_function "GetObjectField".to_sym, [:long, :long, :long], :long do |env, object_id, field_id|
      ObjectSpace._id2ref(object_id).__send__(ObjectSpace._id2ref(field_id).reader_sym).jni_id
    end
    
    map_function "GetBooleanField".to_sym, [:long, :long, :long], :int8 do |env, object_id, field_id|
      ObjectSpace._id2ref(object_id).__send__(ObjectSpace._id2ref(field_id).reader_sym) ? 1 : 0
    end
    
    type_map.each do |name, type|
      map_function "Get#{name}Field".to_sym, [:long, :long, :long], type do |env, object_id, field_id|
        ObjectSpace._id2ref(object_id).__send__ ObjectSpace._id2ref(field_id).reader_sym
      end
    end
    
    map_function "SetBooleanField".to_sym, [:long, :long, :long, :int8], :void do |env, object_id, field_id, value|
      ObjectSpace._id2ref(object_id).__send__ ObjectSpace._id2ref(field_id).writer_sym, value != 0
    end
    
    type_map.each do |name, type|
      map_function "Set#{name}Field".to_sym, [:long, :long, :long, type], :void do |env, object_id, field_id, value|
        ObjectSpace._id2ref(object_id).__send__ ObjectSpace._id2ref(field_id).writer_sym, value
      end
    end
    
    map_function :GetStaticMethodID, [:long, :long, :string, :string], :long do |env, class_id, name, sig|
      method_id = MethodID.new(name, sig)
      @@global_refs << method_id
      method_id.jni_id
    end
    
    type_map.each do |name, type|
      map_function "CallStatic#{name}Method".to_sym, [:long, :long, :long], type do |env, class_id, method_id|
        puts "CallStatic#{name}Method"
        exit
      end
    end
    
    type_map.each do |name, type|
      map_function "CallStatic#{name}MethodV".to_sym, [:long, :long, :long, :long], type do |env, class_id, method_id, arg_list|
        begin
          method_id = ObjectSpace._id2ref method_id
          JNI.call_with_va_arg ObjectSpace._id2ref(class_id), method_id.name_sym, arg_list, method_id.arg_types
        rescue Exception => e
          @@exception = e
          0
        end
      end
    end
    
    map_function :GetStringUTFChars, [:long, :long, :long], :pointer do |env, string_id, flag|
      ObjectSpace._id2ref(string_id).jni_get_utf_chars
    end
    
    map_function :ReleaseStringUTFChars, [:long, :long, :long], :void do |env, string_id, char_ptr|
      ObjectSpace._id2ref(string_id).jni_release_utf_chars
    end
    
    type_map.each do |name, type|
      map_function "New#{name}Array".to_sym, [:long, :int], :long do |env, size|
        array = Array.new(size, 0)
        @@global_refs << array
        array.jni_id
      end
    end
    
    map_function "GetBooleanArrayElements".to_sym, [:long, :long, :long], :pointer do |env, array_id, flag|
      ObjectSpace._id2ref(array_id).jni_get_elements(:int8, :put_array_of_int8, true)
    end
    
    type_map.each do |name, type|
      put_method_sym = "put_array_of_#{type}".to_sym
      map_function "Get#{name}ArrayElements".to_sym, [:long, :long, :long], :pointer do |env, array_id, flag|
        ObjectSpace._id2ref(array_id).jni_get_elements(type, put_method_sym, false)
      end
    end
    
    map_function "ReleaseBooleanArrayElements".to_sym, [:long, :long, :pointer, :long], :void do |env, array_id, ptr, flag|
      ObjectSpace._id2ref(array_id).jni_release_elements(:int8, :get_array_of_int8, true, ptr)
    end
    
    type_map.each do |name, type|
      get_method_sym = "get_array_of_#{type}".to_sym
      map_function "Release#{name}ArrayElements".to_sym, [:long, :long, :pointer, :long], :void do |env, array_id, ptr, flag|
        ObjectSpace._id2ref(array_id).jni_release_elements(type, get_method_sym, false, ptr)
      end
    end

    type_map.each do |name, type|
      put_method_sym = "put_array_of_#{type}".to_sym
      map_function "Get#{name}ArrayRegion".to_sym, [:long, :long, :int32, :int32, :pointer], :void do |env, array_id, start, length, ptr|
        ptr.__send__ put_method_sym, 0, ObjectSpace._id2ref(array_id)[start, length]
      end
    end
    
    type_map.each do |name, type|
      get_method_sym = "get_array_of_#{type}".to_sym
      map_function "Set#{name}ArrayRegion".to_sym, [:long, :long, :int32, :int32, :pointer], :void do |env, array_id, start, length, ptr|
        ObjectSpace._id2ref(array_id)[start, length] = ptr.__send__ get_method_sym, 0, length
      end
    end
    
    map_function :GetJavaVM, [:long, :pointer], :int do |env, vm_ptr|
      vm_ptr.put_pointer 0, JNI.jvm
      0
    end

    
  end
  
  module JvmFunctions
    @@functions = %w{DestroyJavaVM AttachCurrentThread DetachCurrentThread GetEnv AttachCurrentThreadAsDaemon}.map { |name| [name.to_sym, [], :void, lambda { raise NotImplementedError, name }] }
    
    def self.map_function(name, arg_types, return_type, &block)
      @@functions.find { |function| function[0] == name }.replace [name, arg_types, return_type, block]
    end
    
    def self.each_function
      @@functions.each do |name, arg_types, return_type, block|
        yield name, arg_types, return_type, block
      end
    end
    
    map_function :AttachCurrentThread, [:long, :pointer, :long], :int do |env, vm_ptr|
      vm_ptr.put_pointer 0, JNI.env
      0
    end
  end
  
  def self.env
    @@env ||= begin
      @@env_struct = EnvStruct.new
      EnvFunctions.each_function do |name, arg_types, return_type, block|
        @@env_struct[name] = block
      end
      pointer = FFI::MemoryPointer.new :pointer
      pointer.put_pointer 0, @@env_struct.pointer
      pointer
    end
  end
  
  def self.jvm
    @@java_vm ||= begin
      @@jvm_struct = JvmStruct.new
      JvmFunctions.each_function do |name, arg_types, return_type, block|
        @@jvm_struct[name] = block
      end
      pointer = FFI::MemoryPointer.new :pointer
      pointer.put_pointer 0, @@jvm_struct.pointer
      pointer
    end
  end
  
  def self.load_library(path)
    raise LoadError, path if not File.exist? path
    @@lib_files << path
    ffi_lib(*@@lib_files)
  end

  def self.load_native_method(name, arg_types, return_type)
   (class << self; self; end).define_method(name) { |*args|
      begin
        attach_function name, arg_types, return_type
      rescue FFI::NotFoundError
        arg_size = 0
        arg_types.each do |type|
          type_size = FFI.type_size type
          arg_size += type_size > 4 ? type_size : 4
        end
        attach_function name, "_#{name}@#{arg_size}", arg_types, return_type
      end
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
  
  module VaArgTools
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "jni_tools_#{RJava::PLATFORM}.so")
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
    end
  end
end
