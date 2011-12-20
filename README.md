Bitwise
=======

[![Build Status](https://secure.travis-ci.org/kenn/bitwise.png)](http://travis-ci.org/kenn/bitwise)

Fast, memory efficient bitwise operations on large binary strings.

Internally a bit array is represented as a ruby string with `Encoding::BINARY` encoding, which keeps billions of bits in a workable footprint.

* 1,000,000 bits = 125KB
* 10,000,000 bits = 1.25MB
* 100,000,000 bits = 12.5MB
* 1,000,000,000 bits = 125MB

Install
-------

    gem install bitwise

Usage
-----

Set and clear bits:

```ruby
b = Bitwise.new("\x00")

b.bits
 => "00000000"

b.set_at(1)
b.set_at(4)

b.bits
 => "01001000"

b.clear_at(1)

b.bits
 => "00001000"
```

String-based accessor:

```ruby
b = Bitwise.new
b.raw = "abc"

b.size
 => 3
b.bits
 => "011000010110001001100011"
b.raw.unpack('C*')
 => [97, 98, 99]
```

Index-based accessor:

```ruby
b = Bitwise.new
b.indexes = [1, 2, 4, 8, 16]

b.bits
 => "011010001000000010000000"
b.indexes
 => [1, 2, 4, 8, 16]
b.cardinality
 => 5

b.set_at(10)

b.bits
 => "011010001010000010000000"
b.indexes
 => [1, 2, 4, 8, 10, 16]
b.cardinality
 => 6
```

Bit-based accessor is also provided for convenience, but be aware that it's not efficient. Use string-based accessor whenever possible.

```ruby
b = Bitwise.new
b.bits = '0100100010'
b.bits
 => "0100100010000000"
```

NOT, OR, AND and XOR:

```ruby
b1 = Bitwise.new
b2 = Bitwise.new
b1.indexes = [1, 2, 3, 5, 6]
b2.indexes = [1, 2, 4, 8, 16]

(~b1).indexes
 => [0, 4, 7]
(b1 | b2).indexes
 => [1, 2, 3, 4, 5, 6, 8, 16]
(b1 & b2).indexes
 => [1, 2]
(b1 ^ b2).indexes
 => [3, 4, 5, 6, 8, 16]
```

As a bonus, `Bitwise.string_not`, `Bitwise.string_union`, `Bitwise.string_intersect`, and `Bitwise.string_xor` can be used as a standalone utility to work with any binary string.

```ruby
Bitwise.string_not "\xF0"
 => "\x0F"
Bitwise.string_union "\xF0","\xFF"
 => "\xFF"
Bitwise.string_intersect "\xF0","\xFF"
 => "\xF0"
Bitwise.string_xor "\xF0","\xFF"
 => "\x0F"
```
