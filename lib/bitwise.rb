# coding: ascii-8bit

require 'bitwise/bitwise'

class Bitwise
  attr_accessor :value

  def initialize(value = "")
    @value = value.force_encoding(Encoding::ASCII_8BIT)
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
    raise IndexError, 'out of bounds' if @div < 0 or @div >= @value.bytesize
    @byte = @value.getbyte(@div)
  end

  def not
    Bitwise.new(Bitwise.string_not(self.value))
  end
  alias :~ :not

  def intersect(other)
    assign_max_and_min(other)
    Bitwise.new Bitwise.string_intersect(@max, @min)
  end
  alias :& :intersect

  def union(other)
    assign_max_and_min(other)
    Bitwise.new Bitwise.string_union(@max, @min)
  end
  alias :| :union

  def xor(other)
    assign_max_and_min(other)
    Bitwise.new Bitwise.string_xor(@max, @min)
  end
  alias :^ :xor

  def assign_max_and_min(other)
    @min, @max = [ self.value, other.value ].sort_by{|i| i.bytesize }
  end

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
    array.size
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
