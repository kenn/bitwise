# coding: ascii-8bit

class Bitwise
  attr_accessor :value

  def initialize(size = 0)
    @value = "\x00" * size
  end

  def size
    @value.bytesize
  end
  alias :to_s :size

  def to_bits
    @value.unpack('B*').first
  end

  def set_at(index)
    get_byte(index)
    @value.setbyte(@div, @byte | bitmask)
  end

  def clear_at(index)
    get_byte(index)
    @value.setbyte(@div, @byte  & ~bitmask)
  end

  def set_at?(index)
    get_bit(index) == 1
  end

  def clear_at?(index)
    get_bit(index) == 0
  end

  def get_bit(index)
    get_byte(index)
    (@byte & bitmask) > 0 ? 1 : 0
  end

  def bitmask
    2**(7 - @mod)
  end

  def get_byte(index)
    @div, @mod = index.divmod(8)
    @byte = @value.getbyte(@div)
  end

  def intersect(other)
    min, max = [ self.value, other.value ].sort_by{|i| i.bytesize }
    result = Bitwise.new
    result.value = Bitwise.string_intersect(max, min)
    result
  end
  alias :& :intersect

  def union(other)
    min, max = [ self.value, other.value ].sort_by{|i| i.bytesize }
    result = Bitwise.new
    result.value = Bitwise.string_union(max, min)
    result
  end
  alias :| :union

  def value=(string)
    @value = string.force_encoding(Encoding::ASCII_8BIT)
    @value.bytesize
  end

  def indexes=(array)
    max_index = array.max
    @value = "\x00" * (max_index.div(8) + 1)
    array.each do |index|
      set_at(index)
    end
    @value.bytesize
  end

  def indexes
    indexes = []
    position = 0
    @value.each_byte do |c|
      BITS_TABLE[c].each do |i|
        indexes << (position*8 + i)
      end
      position += 1
    end
    indexes
  end

  def cardinality
    Bitwise.population_count(self.value)
  end

  BITS_TABLE = (0..255).map do |i|
    (0..7).map do |j|
      j = 7 - j
      ((i & 2**j) > 0) ? (7 - j) : nil
    end.compact
  end
end
