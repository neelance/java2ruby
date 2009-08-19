class CharArray < Array.typed(Java::Char)
  Character = Java::Lang::Character
  
   (instance_methods - Object.instance_methods).each do |method|
    undef_method method
  end
  
  attr_accessor :data, :array
  
  def initialize(size)
    @data = "\0" * size
    @array = nil
  end
  
  def use_array
    return if @array
    @array = @data.split("").map { |c| c.ord }
    @data = nil
  end
  
  def []=(index, a2, a3 = nil)
    if a3
      use_array if not @array and a3.any? { |c| c > 255 }
      return @array[index, a2] = a3 if @array
      @data[index, a2] = a3.map { |c| c.chr }.join
    else
      if index.is_a? Range
        use_array if not @array and a2.any? { |c| c > 255 }
        return @array[index] = a2 if @array
        @data[index] = a2.map { |c| c.chr }.join
      else
        use_array if not @array and a2 > 255
        return @array[index] = a2 if @array
        @data[index] = a2.chr
      end
    end
  end
  
  def [](index, length = nil)
    if length
      return @array[index, length].map { |c| Character.new c.ord } if @array
      data[index, length].split("").map { |c| Character.new c.ord }
    else
      return Character.new @array[index] if @array
      Character.new @data[index].ord
    end
  end
  
  def size
    return @array.size if @array
    @data.size
  end
  
  def each_index(&block)
    0.upto(size - 1, &block)
  end
  
  def clear
    if @array
      @array.clear
    else
      @data = ""
    end
  end
  
  def concat(other)
    if @array
      @array.concat other
    else
      self[size, 0] = other
    end
  end
  
  def to_a
    if @array
      @array
    else
      @data.split("").map { |c| c.ord }
    end
  end
  
  def inspect
    "[" + self[0, size].map{ |e| e.to_int }.join(", ") + "]"
  end
    
  alias_method :attr_length, :size
end
