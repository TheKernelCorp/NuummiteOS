struct Char
  ZERO = '\0'
  MAX_CODEPOINT = 127
  MAX = MAX_CODEPOINT.unsafe_chr

  def -(other : Char)
    ord - other.ord
  end

  def -(other : Int)
    (ord - other).chr
  end

  def +(other : Int)
    (ord + other).chr
  end

  def ===(byte : Int)
    ord === byte
  end

  def <=>(other : Char)
    self - other
  end

  def ascii?
    ord < 128
  end

  def ascii_lowercase?
    'a' <= self <= 'z'
  end

  def ascii_uppercase?
    'A' <= self <= 'Z'
  end

  def ascii_digit?
    '0' <= self <= '9'
  end

  def ascii_letter?
    ascii_lowercase? || ascii_uppercase?
  end

  def ascii_whitespace?
    self == ' ' || 0 <= ord <= 13
  end

  def ascii_control?
    ord < 0x20 || (0x7F <= ord <= 0x9F)
  end

  def bytesize
    1 # The byte size is always one byte
  end

  def hash
    ord
  end

  def each_byte
    c = ord
    yield c.to_u8
  end
end
