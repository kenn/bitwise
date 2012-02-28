require 'bitwise'
require 'set'

describe Bitwise do
  before do
    @bitwise = Bitwise.new("\x00")
  end

  it "should encode to binary" do
    @bitwise.raw.encoding.should == Encoding::BINARY
    @bitwise.indexes = [1,2]
    @bitwise.raw.encoding.should == Encoding::BINARY
  end

  it "set and unset" do
    @bitwise.bits.should == '00000000'

    @bitwise.set_at(1)
    @bitwise.set_at(4)
    @bitwise.bits.should == '01001000'
    @bitwise.cardinality.should == 2

    @bitwise.unset_at(1)
    @bitwise.bits.should == '00001000'
    @bitwise.cardinality.should == 1

    lambda { @bitwise.set_at(7) }.should_not raise_error(IndexError)
    lambda { @bitwise.set_at(8) }.should raise_error(IndexError)
  end

  describe "accessor" do
    it "bit-based" do
      @bitwise.bits = '0100100010'
      @bitwise.size.should == 2
      @bitwise.bits.should == '0100100010000000'
      @bitwise.cardinality.should == 3
    end

    it "string-based" do
      @bitwise.raw = 'abc'
      @bitwise.size.should == 3
      @bitwise.bits.should == '011000010110001001100011'
      @bitwise.cardinality.should == 10
    end

    it "index-based" do
      @bitwise.indexes = [1, 2, 4, 8, 16]
      @bitwise.bits.should == '011010001000000010000000'
      @bitwise.indexes.should == [1, 2, 4, 8, 16]
      @bitwise.cardinality.should == 5

      @bitwise.set_at 10
      @bitwise.bits.should == '011010001010000010000000'
      @bitwise.indexes.should == [1, 2, 4, 8, 10, 16]
      @bitwise.cardinality.should == 6
    end
  end

  describe "operators" do
    before do
      @b1 = Bitwise.new
      @b2 = Bitwise.new
      @b1.indexes = [1, 2, 3, 5, 6]
      @b2.indexes = [1, 2, 4, 8, 16]
    end

    it "NOT" do
      @b1.not.indexes.should == [0, 4, 7]
    end

    it "OR" do
      @b1.union(@b2).indexes.should == [1, 2, 3, 4, 5, 6, 8, 16]
    end

    it "AND" do
      @b1.intersect(@b2).indexes.should == [1, 2]
    end

    it "XOR" do
      @b1.xor(@b2).indexes.should == [3, 4, 5, 6, 8, 16]
    end
  end

  describe "standalone" do
    it "NOT" do
      Bitwise.string_not("\xF0").should == "\x0F"
    end

    it "OR" do
      Bitwise.string_union("\xF0","\xFF").should == "\xFF"
    end

    it "AND" do
      Bitwise.string_intersect("\xF0","\xFF").should == "\xF0"
    end

    it "XOR" do
      Bitwise.string_xor("\xF0","\xFF").should == "\x0F"
    end

  end

  describe "benchmark" do
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

    it "indexes assignment" do
      assign_indexes(1000, 10)
      measure { @bitwise.indexes = @indexes }.should < 0.0001
      measure { @bitwise.indexes }.should < 0.0001

      assign_indexes(10_000, 100)
      measure { @bitwise.indexes = @indexes }.should < 0.001
      measure { @bitwise.indexes }.should < 0.001

      assign_indexes(100_000, 1000)
      measure { @bitwise.indexes = @indexes }.should < 0.01
      measure { @bitwise.indexes }.should < 0.01

      assign_indexes(1000_000, 10_000)
      measure { @bitwise.indexes = @indexes }.should < 0.1
      measure { @bitwise.indexes }.should < 0.1
    end

    it "cardinality sparse" do
      @bitwise.indexes = [1, 10, 100, 1000, 10_000, 100_000, 1000_000, 10_000_000, 100_000_000]
      measure { @bitwise.cardinality.should == 9 }.should < 1.0
    end

    it "cardinality dense" do
      assign_indexes(10_000_000, 100_000)
      @bitwise.indexes = @indexes
      measure { @bitwise.cardinality }.should < 1.0
    end

    it "union sparse" do
      b1 = Bitwise.new
      b2 = Bitwise.new
      b1.indexes = [1, 10, 100, 1000, 10_000, 100_000, 1000_000, 10_000_000, 100_000_000]
      b2.indexes = [2, 20, 200, 2000, 20_000, 200_000, 2000_000, 20_000_000, 200_000_000]
      measure do
        b3 = b1.union(b2)
        b3.cardinality.should == 18
      end.should < 1.0
    end

    it "intersect sparse" do
      b1 = Bitwise.new
      b2 = Bitwise.new
      b1.indexes = [1, 10, 100, 1000, 10_000, 100_000, 1000_000, 10_000_000, 100_000_000]
      b2.indexes = [2, 20, 200, 2000, 20_000, 200_000, 2000_000, 20_000_000, 200_000_000]
      measure do
        b3 = b1.intersect(b2)
        b3.cardinality.should == 0
      end.should < 1.0
    end
  end
end
