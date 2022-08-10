# encoding: binary

require 'test_helper'

class BitwiseTest < Minitest::Test
  def setup
    @bitwise = Bitwise.new("\x00")
  end

  class BaseTest < BitwiseTest
    def test_encode_to_binary
      assert_equal @bitwise.raw.encoding, Encoding::BINARY
      @bitwise.indexes = [1,2]
      assert_equal @bitwise.raw.encoding, Encoding::BINARY
    end

    def test_set_and_unset
      assert_equal @bitwise.bits, '00000000'

      @bitwise.set_at(1)
      @bitwise.set_at(4)
      assert_equal @bitwise.bits, '01001000'
      assert_equal @bitwise.cardinality, 2

      @bitwise.unset_at(1)
      assert_equal @bitwise.bits, '00001000'
      assert_equal @bitwise.cardinality, 1

      @bitwise.set_at(7)
      assert_raises(IndexError) { @bitwise.set_at(8) }
    end
  end

  class AccessorTest < BitwiseTest
    def test_bit
      @bitwise.bits = '0100100010'
      assert_equal @bitwise.size, 2
      assert_equal @bitwise.bits, '0100100010000000'
      assert_equal @bitwise.cardinality, 3
    end

    def test_string
      @bitwise.raw = 'abc'
      assert_equal @bitwise.size, 3
      assert_equal @bitwise.bits, '011000010110001001100011'
      assert_equal @bitwise.cardinality, 10
    end

    def test_index
      @bitwise.indexes = [1, 2, 4, 8, 16]
      assert_equal @bitwise.bits, '011010001000000010000000'
      assert_equal @bitwise.indexes, [1, 2, 4, 8, 16]
      assert_equal @bitwise.cardinality, 5

      @bitwise.set_at 10
      assert_equal @bitwise.bits, '011010001010000010000000'
      assert_equal @bitwise.indexes, [1, 2, 4, 8, 10, 16]
      assert_equal @bitwise.cardinality, 6
    end
  end

  class OperatorTest < BitwiseTest
    def setup
      @b1 = Bitwise.new
      @b2 = Bitwise.new
      @b1.indexes = [1, 2, 3, 5, 6]
      @b2.indexes = [1, 2, 4, 8, 16]
    end

    def test_not
      assert_equal @b1.not.indexes, [0, 4, 7]
    end

    def test_or
      assert_equal @b1.union(@b2).indexes, [1, 2, 3, 4, 5, 6, 8, 16]
    end

    def test_and
      assert_equal @b1.intersect(@b2).indexes, [1, 2]
    end

    def test_xor
      assert_equal @b1.xor(@b2).indexes, [3, 4, 5, 6, 8, 16]
    end
  end

  class StandaloneTest < BitwiseTest
    def test_not
      assert_equal Bitwise.string_not("\xF0"), "\x0F"
    end

    def test_or
      assert_equal Bitwise.string_union("\xF0","\xFF"), "\xFF"
    end

    def test_and
      assert_equal Bitwise.string_intersect("\xF0","\xFF"), "\xF0"
    end

    def test_xor
      assert_equal Bitwise.string_xor("\xF0","\xFF"), "\x0F"
    end
  end

  class BenchmarkTest < BitwiseTest
    def assign_indexes(total, picks)
      set = Set.new

      picks.times do
        set << (rand*total).to_i
      end

      @indexes = set.to_a
    end

    def measure
      start = Time.now.to_f
      yield
      Time.now.to_f - start
    end

    def test_indexes_assignment
      assign_indexes(1000, 10)
      assert measure { @bitwise.indexes = @indexes } < 0.0001
      assert measure { @bitwise.indexes } < 0.0001

      assign_indexes(10_000, 100)
      assert measure { @bitwise.indexes = @indexes } < 0.001
      assert measure { @bitwise.indexes } < 0.001

      assign_indexes(100_000, 1000)
      assert measure { @bitwise.indexes = @indexes } < 0.01
      assert measure { @bitwise.indexes } < 0.01

      assign_indexes(1000_000, 10_000)
      assert measure { @bitwise.indexes = @indexes } < 0.1
      assert measure { @bitwise.indexes } < 0.1
    end

    def test_cardinality_sparse
      @bitwise.indexes = [1, 10, 100, 1000, 10_000, 100_000, 1000_000, 10_000_000, 100_000_000]
      assert measure { assert_equal @bitwise.cardinality, 9 } < 1.0
    end

    def test_cardinality_dense
      assign_indexes(10_000_000, 100_000)
      @bitwise.indexes = @indexes
      assert measure { @bitwise.cardinality } < 1.0
    end

    def test_union_sparse
      b1 = Bitwise.new
      b2 = Bitwise.new
      b1.indexes = [1, 10, 100, 1000, 10_000, 100_000, 1000_000, 10_000_000, 100_000_000]
      b2.indexes = [2, 20, 200, 2000, 20_000, 200_000, 2000_000, 20_000_000, 200_000_000]
      assert measure { b3 = b1.union(b2); assert_equal b3.cardinality, 18 } < 1.0
    end

    def test_intersect_sparse
      b1 = Bitwise.new
      b2 = Bitwise.new
      b1.indexes = [1, 10, 100, 1000, 10_000, 100_000, 1000_000, 10_000_000, 100_000_000]
      b2.indexes = [2, 20, 200, 2000, 20_000, 200_000, 2000_000, 20_000_000, 200_000_000]
      assert measure { b3 = b1.intersect(b2); assert_equal b3.cardinality, 0 } < 1.0
    end
  end
end
