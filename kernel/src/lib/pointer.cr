struct Pointer(T)
  def self.null
    new 0_u64
  end

  def +(other : Int)
    self + other.to_i64
  end

  def -(other : Int)
    if other > address
      panic
    end
    self + (0 - other)
  end

  def <(other : Pointer(_))
    self < other
  end

  def >(other : Pointer(_))
    self > other
  end

  def ==(other : Int)
    self.address == other.to_i64
  end

  def ==(other : Pointer(_))
    self == other
  end

  def <=>(other : self)
    address <=> other.address
  end

  def [](offset : Int) : T
    (self + offset).value
  end

  def []=(offset : Int, value : T)
    (self + offset).value = value
  end

  def null?
    address == 0
  end

  def to_byte_ptr
    self.as UInt8*
  end

  def to_void_ptr
    self.as Void*
  end
end
