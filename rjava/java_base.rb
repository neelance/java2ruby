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
end

module Java::Byte
end

module Java::Short
end

module Java::Int
end

module Java::Long
end

module Java::Float
end

module Java::Double
end

module Java::Boolean
  def self.new(value)
    value
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
end

class String
  include_const Java::Lang, :Character
  
  def self.new(str = nil, offset = nil, length = nil)
    if not str
      ""
    elsif str.is_a? CharArray
      offset ? str.data[offset, length] : str.data
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
  
  def to_char_array
    ca = CharArray.new 0
    ca.data = self.dup
    ca
  end
  
  def substring(start_offset, end_offset = nil)
    if end_offset
      self[start_offset...end_offset]
    else
      self[start_offset..-1]
    end
  end
  
  def get_chars(src_begin, src_end, dst, dst_begin)
    if dst.is_a? CharArray
      dst.data[dst_begin, src_end - src_begin] = self[src_begin...src_end]
    else
      dst[dst_begin, src_end - src_begin] = (src_begin...src_end).map { |i| Character.new self[i].ord }
    end
  end
  
  def char_at(index)
    Character.new self[index].ord
  end
  
  def index_of(t)
    index(t.to_s) || -1
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
      rindex str
    else
      rindex str.to_int.chr
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
    self.size >= str.size && self[0...str.size] == str
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
