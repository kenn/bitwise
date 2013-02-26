# encoding: binary

require 'bitwise_ext'

class Bitwise
  attr_accessor :value

  def initialize(string = "")
    self.raw = string
  end

  def size
    @value.bytesize
  end
  alias :to_s :size

  def set_at(index)
    get_byte(index)
    @value.setbyte(@div, @byte | bitmask)
  end

  def unset_at(index)
    get_byte(index)
    @value.setbyte(@div, @byte  & ~bitmask)
  end

  def clear_at(index)
    warn 'Bitwise#clear_at is deprecated. Use Bitwise#unset_at instead.'
    unset_at(index)
  end

  def set_at?(index)
    get_bit(index) == 1
  end

  def unset_at?(index)
    get_bit(index) == 0
  end

  def clear_at?(index)
    warn 'Bitwise#clear_at? is deprecated. Use Bitwise#unset_at? instead.'
    unset_at?(index)
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
    Bitwise.new(Bitwise.string_not(self.raw))
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
    @min, @max = [ self.raw, other.raw ].sort_by{|i| i.bytesize }
  end

  def bits
    @value.unpack('B*').first
  end

  def bits=(string)
    @value = string.scan(/[01]{1,8}/).map do |slice|
      (slice.bytesize == 8 ? slice : (slice + '0' * (8 - slice.bytesize))).to_i(2).chr
    end.join
    @value.bytesize
  end

  def raw
    @value
  end

  def raw=(string)
    @value = string.force_encoding(Encoding::BINARY)
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
    @value.each_byte.with_index do |c, position|
      BITS_TABLE[c].each do |i|
        indexes << (position*8 + i)
      end
    end
    indexes
  end

  def cardinality
    Bitwise.population_count(self.raw)
  end

  BITS_TABLE = (0..255).map do |i|
    (0..7).map do |j|
      j = 7 - j
      ((i & 2**j) > 0) ? (7 - j) : nil
    end.compact
  end
end
