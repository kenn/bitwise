require 'bitwise'
require 'set'

describe Bitwise do
  before do
    @bitwise = Bitwise.new(1)
  end

  it "should set and clear" do
    @bitwise.to_bits.should == '00000000'

    @bitwise.set_at 1
    @bitwise.set_at 2
    @bitwise.set_at 3
    @bitwise.set_at 5
    @bitwise.to_bits.should == '01110100'
    @bitwise.cardinality.should == 4

    @bitwise.clear_at(1)
    @bitwise.clear_at(3)
    @bitwise.to_bits.should == '00100100'
    @bitwise.cardinality.should == 2
  end

  it "should set by indexes" do
    @bitwise.indexes = [1,10]
    @bitwise.indexes.should == [1,10]
    @bitwise.to_bits.should == '0100000000100000'
    @bitwise.cardinality.should == 2
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

      assign_indexes(10_000, 100)
      measure { @bitwise.indexes = @indexes }.should < 0.001

      assign_indexes(100_000, 1000)
      measure { @bitwise.indexes = @indexes }.should < 0.01

      assign_indexes(1000_000, 10_000)
      measure { @bitwise.indexes = @indexes }.should < 0.1
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
