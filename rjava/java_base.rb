if is_jruby?
  require "java"
  
  module Java
    def self.const_missing(name)
      super
    end
  end
  
  class ArrayJavaProxy
    alias_method :attr_length, :length
  end
else
  $" << "java.rb" # do not try to load "java" somewhere else # "
  $CLASSPATH = []
end

module Java::Char
  def self.can_be_nil?
    false
  end
end

module Java::Byte
  def self.can_be_nil?
    false
  end
end

module Java::Short
  def self.can_be_nil?
    false
  end
end

module Java::Int
  def self.can_be_nil?
    false
  end
end

module Java::Long
  def self.can_be_nil?
    false
  end
end

module Java::Float
  def self.can_be_nil?
    false
  end
end

module Java::Double
  def self.can_be_nil?
    false
  end
end

module Java::Boolean
  TRUE = true
  FALSE = false

  def self.can_be_nil?
    false
  end

  def self.new(value)
    value
  end

  def self.get_boolean(name)
    Java::Lang::System.get_property(name) == "true"
  end

  def boolean_value
    self
  end
end

Boolean = Java::Boolean

Java::Lang::Character.class_eval do
  include Java::Char
end

class Integer
  include Java::Byte
  include Java::Short
  include Java::Int
  include Java::Long
  include Java::Float
  include Java::Double
end

class Float
  include Java::Float
  include Java::Double
end

class TrueClass
  include Java::Boolean
end

class FalseClass
  include Java::Boolean
end

class AssertError < RuntimeError
end

class Object
  def get_class
    self.class
  end

  def hash_code
    hash
  end
end

class Module
  def get_name
    parts = name.split "::"
    0.upto(parts.size - 2) do |i|
      parts[i] = parts[i].downcase
    end
    parts.join "."
  end
end

class Class
  def self.for_name(name, initialize = false, loader = nil)
    parts = name.split(".")
    cls = Object
    RJava.ruby_class_name(parts).each do |ruby_name|
      cls = cls.const_get ruby_name
    end
    cls
  rescue NameError
    raise Java::Lang::ClassNotFoundException.new
  end
  
  alias_method :new_instance, :new
  
  def get_class_loader
    nil
  end
  
  def get_declared_field(name)
    Java::Lang::Reflect::Field.new(self, name, nil, nil, nil, nil, nil)
  end

  def is_instance(obj)
    obj.is_a? self
  end

  def is_assignable_from(cls)
    cls.ancestors.include? self
  end

  def get_resource_as_stream(name)
    if name[0..0] == "/"
      Java::Lang::ClassLoader.get_system_resource_as_stream name[1..-1]
    else
      raise NotImplementedError
    end
  end
end

class String
  include_const Java::Lang, :Character
  
  def self.new(str = nil, offset = nil, length = nil, charset = nil)
    if not str
      ""
    elsif str.class == CharArray
      if str.data
        offset ? str.data[offset, length] : str.data
      else
        new_str = UnicodeString.new ""
        new_str.chars.concat str.array[offset, length]
        new_str
      end
    elsif defined? ArrayJavaProxy and str.is_a? ArrayJavaProxy
      str = String.from_java_bytes str
      offset ? str[offset, length] : str
    elsif str.is_a? Array
      new_str = ""
       (offset || 0).upto(offset ? offset + length - 1 : str.size - 1) do |i|
        break if not str[i]
        new_str << str[i].to_int
      end
      str = new_str
    elsif str.is_a? String
      offset ? str[offset, length] : str
    else
      raise ArgumentError
    end
  end
  
  def self.value_of(object)
    object.to_s
  end
  
  alias_method :attr_length, :size
  alias_method :replace_all, :gsub
  alias_method :to_lower_case, :downcase
  alias_method :to_upper_case, :upcase
  alias_method :trim, :strip
  
  def to_char_array
    ca = CharArray.new 0
    ca.data = self.dup
    ca
  end

  def equals_ignore_case(other)
    other.is_a?(String) && casecmp(other) == 0
  end
  
  def substring(start_offset, end_offset = nil)
    if end_offset
      self[start_offset...end_offset]
    else
      self[start_offset..-1]
    end
  end
  
  def get_chars(src_begin, src_end, dst, dst_begin)
    if dst.class == CharArray
      if dst.data
        dst.data[dst_begin, src_end - src_begin] = self[src_begin...src_end]
      else
        dst.array[dst_begin, src_end - src_begin] = self[src_begin...src_end].split("").map { |c| c.ord }
      end
    else
      dst[dst_begin, src_end - src_begin] = (src_begin...src_end).map { |i| Character.new self[i].ord }
    end
  end
  
  def char_at(index)
    Character.new self[index].ord
  end
  
  def index_of(t, offset = 0)
    index(t.to_s, offset) || -1
  end
  
  def to_u
    UnicodeString.new self
  end
  
  def hash_code
    @hash ||= begin
      h = 0
      each_byte do |b|
        h = 31 * h + b
      end
      h
    end
  end
  
  def last_index_of(str)
    if str.is_a? String
      rindex(str) || -1
    else
      rindex(str.to_int.chr) || -1
    end
  end

  alias_method :ruby_string_replace, :replace
  def replace(str1, str2 = nil)
    if str2
      self.gsub str1.to_s, str2.to_s
    else
      ruby_string_replace str1
    end
  end

  def starts_with(str)
    self =~ /^#{str}/
  end

  def ends_with(str)
    self =~ /#{str}$/
  end

  def region_matches(*args)
    ignore_case, toffset, other, ooffset, len = false
    case args.size
    when 4
      toffset, other, ooffset, len = args
    when 5
      ignore_case, toffset, other, ooffset, len = args
    end
    if ignore_case
	    self[toffset, len].downcase == other[ooffset, len].downcase
    else
	    self[toffset, len] == other[ooffset, len]
    end
  end
end

class UnicodeString # TODO try to use normal binary encoded strings in ruby 1.9
  include_const Java::Lang, :Character
  attr_reader :chars
  
  def initialize(string)
    @chars = []
    0.upto(string.size - 1) do |i|
      @chars << string[i].ord
    end
  end

  def is_a?(cls)
    cls == String
  end
  
  def size
    @chars.size
  end
  
  alias_method :length, :size
  
  def char_at(i)
    Character.new @chars[i]
  end
  
  def to_char_array
    ca = CharArray.new 0
    ca[0, 0] = @chars
    ca
  end

  def get_chars(src_begin, src_end, dst, dst_begin)
    if dst.is_a? CharArray
      dst.use_array
      dst.array[dst_begin, src_end - src_begin] = @chars[src_begin...src_end]
    else
      dst[dst_begin, src_end - src_begin] = @chars[src_begin...src_end]
    end
  end
  
  def <<(other)
    case other
    when Numeric
      @chars << other
    when UnicodeString
      @chars.concat other.chars
    when String
      self << UnicodeString.new(other)
    else
      raise ArgumentError
    end
    self
  end
  
  def +(other)
    self.dup << other
  end
  
  def to_u
    self
  end
end

class Integer
  MAX_VALUE = 2147483647
end

class Fixnum
  alias_method :int_value, :to_i
  alias_method :double_value, :to_f
  alias_method :equal?, :==
  
  def hash_code
    self
  end
  
  def ord
    self
  end
end

class Bignum
  alias_method :int_value, :to_i
  alias_method :double_value, :to_f
  alias_method :equal?, :==
  
  def hash_code
    self
  end
  
  def ord
    self
  end
end

class Float
  alias_method :double_value, :to_f
  
  def self.is_na_n(value)
    value.nan?
  end
end

class Symbol
  def hash_code
		to_s.hash_code
  end

  def equal?(other)
    (other.is_a?(String) && self == other.intern) || super
  end
end

module Math
  def self.min(a, b)
    a < b ? a : b
  end
  
  def self.max(a, b)
    a > b ? a : b
  end

  def self.abs(v)
    v.abs
  end

  def self.ceil(v)
    v.ceil
  end

  def self.round(v)
    v.round
  end
end

class Array
  alias_method :attr_length, :size
  
  def self.new_instance(component_type, length)
    new(length)
  end
  
  def self.get_component_type
    Object
  end
end
