struct Pointer(T)
  def self.null
    new 0_u64
  end

  def +(other : Int)
    self + other.to_i64
  end

  def -(other : Int)
    if other > address
      raise
    end
    self - other.to_i64
  end

  def <(other : Pointer(_))
    self.address < other.address
  end

  def >(other : Pointer(_))
    self.address > other.address
  end

  def ==(other : Int)
    address == other.to_i64
  end

  def ==(other : Pointer(_))
    self.address == other.address
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
end
