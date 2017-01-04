struct Int
  alias Signed = Int8 | Int16 | Int32 | Int64
  alias Unsigned = UInt8 | UInt16 | UInt32 | UInt64
  alias Primitive = Signed | Unsigned

  def <<(count)
    unsafe_shl count
  end

  def >>(count)
    unsafe_shr count
  end

  def ===(other : Int)
    self == other
  end

  def /(other : Int)
    if other == 0
      self
    end
    div = unsafe_div other
    mod = unsafe_mod other
    div -= 1 if other > 0 ? mod < 0 : mod > 0
    div
  end

  def %(other : Int)
    if other == 0
      self
    end
    unsafe_mod other
  end

  def chr
    unless 0 <= self <= Char::MAX_CODEPOINT
      raise "Out of char range"
    end
    unsafe_chr
  end

  def divisible_by?(num : Int)
    self % num == 0
  end

  def even?
    divisible_by? 2
  end

  def odd?
    !even?
  end

  def hash
    self
  end

  def succ
    self + 1
  end

  def pred
    self - 1
  end
  def times
    i = 0
    while i < self
      yield i
      i += 1
    end
  end
end

struct Int8
  MIN = -128_i8
  MAX =  127_i8

  def self.new(value)
    value.to_i8
  end

  def -
    0_i8 - self
  end

  def clone
    self
  end
end

struct Int16
  MIN = -32768_i16
  MAX =  32767_i16

  def self.new(value)
    value.to_i16
  end

  def -
    0_i16 - self
  end

  def clone
    self
  end
end

struct Int32
  MIN = -2147483648_i32
  MAX =  2147483647_i32

  def self.new(value)
    value.to_i32
  end

  def -
    0 - self
  end

  def clone
    self
  end
end

struct Int64
  MIN = -9223372036854775808_i64
  MAX =  9223372036854775807_i64

  def self.new(value)
    value.to_i64
  end

  def -
    0_i64 - self
  end

  def clone
    self
  end
end

struct UInt8
  MIN = 0_u8
  MAX = 255_u8

  def self.new(value)
    value.to_u8
  end

  def abs
    self
  end

  def clone
    self
  end
end

struct UInt16
  MIN = 0_u16
  MAX = 65535_u16

  def self.new(value)
    value.to_u16
  end

  def abs
    self
  end

  def clone
    self
  end
end

struct UInt32
  MIN = 0_u32
  MAX = 4294967295_u32

  def self.new(value)
    value.to_u32
  end

  def abs
    self
  end

  def clone
    self
  end
end

struct UInt64
  MIN = 0_u64
  MAX = 18446744073709551615_u64

  def self.new(value)
    value.to_u64
  end

  def abs
    self
  end

  def clone
    self
  end
end
