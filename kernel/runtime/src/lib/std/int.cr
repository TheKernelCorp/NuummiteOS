struct Int
  alias Signed = Int8 | Int16 | Int32 | Int64
  alias Unsigned = UInt8 | UInt16 | UInt32 | UInt64
  alias Primitive = Signed | Unsigned

  private DIGITS_DOWNCASE = "0123456789abcdefghijklmnopqrstuvwxyz"
  private DIGITS_UPCASE = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  private DIGITS_BASE62 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  def chr
    unless 0 <= self <= Char::MAX_CODEPOINT
      raise "#{self} out of char range"
    end
    unsafe_chr
  end

  def ~
    self ^ -1
  end

  def /(other : Int)
    check_div_argument other
    div = unsafe_div other
    mod = unsafe_mod other
    div -= 1 if other > 0 ? mod < 0 : mod > 0
    div
  end

  def tdiv(other : Int)
    check_div_argument other
    unsafe_div other
  end

  def %(other : Int)
    if other == 0
      raise "Division by zero"
    elsif (self ^ other) >= 0
      self.unsafe_mod other
    else
      me = self.unsafe_mod other
      me == 0 ? me : me + other
    end
  end

  def remainder(other : Int)
    if other == 0
      raise "Division by zero"
    else
      unsafe_mod other
    end
  end

  def >>(count : Int)
    if count < 0
      self << count.abs
    elsif count < sizeof(self) * 8
      self.unsafe_shr count
    else
      self.class.zero
    end
  end

  def <<(count : Int)
    if count < 0
      self >> count.abs
    elsif count < sizeof(self) * 8
      self.unsafe_shl(count)
    else
      self.class.zero
    end
  end

  def **(exponent : Int) : self
    if exponent < 0
      raise "Cannot raise an integer to a negative integer power"
    end
    result = self.class.new 1
    k = self
    while exponent > 0
      result *= k if exponent & 0b1 != 0
      k *= k
      exponent = exponent.unsafe_shr 1
    end
    result
  end

  def ===(char : Char)
    self === char.ord
  end

  def bit(bit)
    self >> bit & 1
  end

  def gcd(other : Int)
    self == 0 ? other.abs : (other % self).gcd self
  end

  def lcm(other : Int)
    (self * other).abs / gcd other
  end

  def abs
    self >= 0 ? self : -self
  end

  def times(&block : self ->)
    i = self ^ self
    while i < self
      yield i
      i += 1
    end
    self
  end

  def upto(to, &block : self ->)
    x = self
    while x <= to
      yield x
      x += 1
    end
    self
  end

  def downto(to, &block : self ->)
    x = self
    while x >= to
      yield x
      x -= 1
    end
    self
  end

  def to(to, &block : self ->)
    if self < to
      upto(to) { |i| yield i }
    elsif self > to
      downto(to) { |i| yield i }
    else
      yield self
    end
    self
  end

  def modulo(other)
    self % other
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

  def succ
    self + 1
  end

  def pred
    self - 1
  end

  def ceil
    self
  end

  def floor
    self
  end

  def round
    self
  end

  def trunc
    self
  end

  def hash
    self
  end

  private def check_div_argument(other)
    if other == 0
      raise "Division by zero"
    end
    {% begin %}
      if self < 0 && self == {{@type}}::MIN && other == -1
        raise "Overflow"
      end
    {% end %}
  end
end

struct Int8
  MIN = -0x80_i8
  MAX =  0x7F_i8

  def self.new(value)
    value.to_i8
  end

  def -
    0_i8 - self
  end

  def clone
    self
  end

  def self.zero
    0_i8
  end
end

struct Int16
  MIN = -0x8000_i16
  MAX =  0x7FFF_i16

  def self.new(value)
    value.to_i16
  end

  def -
    0_i16 - self
  end

  def clone
    self
  end

  def self.zero
    0_i16
  end
end

struct Int32
  MIN = -0x80000000_i32
  MAX =  0x7FFFFFFF_i32

  def self.new(value)
    value.to_i32
  end

  def -
    0 - self
  end

  def clone
    self
  end

  def self.zero
    0_i32
  end
end

struct Int64
  MIN = -0x8000000000000000_i64
  MAX =  0x7FFFFFFFFFFFFFFF_i64

  def self.new(value)
    value.to_i64
  end

  def -
    0_i64 - self
  end

  def clone
    self
  end

  def self.zero
    0_i64
  end
end

struct UInt8
  MIN = 0x00_u8
  MAX = 0xFF_u8

  def self.new(value)
    value.to_u8
  end

  def abs
    self
  end

  def clone
    self
  end

  def self.zero
    0_u8
  end
end

struct UInt16
  MIN = 0x0000_u16
  MAX = 0xFFFF_u16

  def self.new(value)
    value.to_u16
  end

  def abs
    self
  end

  def clone
    self
  end

  def self.zero
    0_u16
  end
end

struct UInt32
  MIN = 0x00000000_u32
  MAX = 0xFFFFFFFF_u32

  def self.new(value)
    value.to_u32
  end

  def abs
    self
  end

  def clone
    self
  end

  def self.zero
    0_u32
  end
end

struct UInt64
  MIN = 0x0000000000000000_u64
  MAX = 0xFFFFFFFFFFFFFFFF_u64

  def self.new(value)
    value.to_u64
  end

  def abs
    self
  end

  def clone
    self
  end

  def self.zero
    0_u64
  end
end
