class CharArray < Array.typed(Java::Char)
  Character = Java::Lang::Character
  UTF_8 = Encoding.find("UTF-8")
  
   (instance_methods - Object.instance_methods).each do |method|
    define_method(method) do
      raise NotImplementedError
    end
  end
  
  attr_accessor :data
  
  def initialize(size)
    @data = ("\0" * size).force_encoding("ASCII-8BIT")
  end
  
  def []=(index, a2, a3 = nil)
    if a3
      @data.set_int_chars index, a2, a3
    elsif index.is_a? Range
      @data.set_int_chars index, a2
    else
      @data.set_int_chars index, a2
    end
  end
  
  def [](index, length = nil)
    if length
      data[index, length].chars.map { |c| Character.new c.ord }
    else
      Character.new @data[index].ord
    end
  end
  
  def size
    @data.size
  end
  
  def each_index(&block)
    0.upto(size - 1, &block)
  end
  
  def clear
    @data = ""
  end
  
  def concat(other)
    self[size, 0] = other
  end
  
  def to_a
    @data.int_chars
  end
  
  def inspect
    "[" + self[0, size].map(&:to_int).join(", ") + "]"
  end
    
  alias_method :attr_length, :size
end
