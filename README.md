Bitwise
=======

Fast, memory efficient bitwise operations on large binary strings.

Internally a bit array is represented as a ruby string with `Encoding::ASCII_8BIT` encoding, which keeps billions of bits in a workable footprint.

* 1,000,000 bits = 125KB
* 10,000,000 bits = 1.25MB
* 100,000,000 bits = 12.5MB
* 1,000,000,000 bits = 125MB

Install
-------

    gem install bitwise

Usage
-----

Bitwise assignment and retrieval:

```ruby
b = Bitwise.new(1)

b.to_bits
 => "00000000"

b.set_at(1)
b.set_at(4)

b.to_bits
 => "01001000"

b.clear_at(1)

b.to_bits
 => "00001000"
```

String-based assignment and retrieval:

```ruby
b = Bitwise.new
b.value = "abc"

b.size
 => 3

b.to_bits
 => "011000010110001001100011"

b.value.unpack('C*')
 => [97, 98, 99]
```

Index-based assignment and retrieval:

```ruby
b = Bitwise.new
b.indexes = [1, 10, 100]

b.to_bits
 => "01000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000"

b.cardinality
 => 3

b.set_at(20)

b.to_bits
 => "01000000001000000000100000000000000000000000000000000000000000000000000000000000000000000000000000001000"

b.cardinality
 => 4

b.indexes
 => [1, 10, 20, 100]
```

Union and intersect:

```ruby
b1 = Bitwise.new
b2 = Bitwise.new
b1.indexes = [1, 2, 3, 5, 6]
b2.indexes = [1, 2, 4, 8]

b1.to_bits
 => "01110110"
b2.to_bits
 => "0110100010000000"
(b1 | b2).to_bits
 => "0111111010000000"
(b1 & b2).to_bits
 => "01100000"
```
