struct Pointer(T)
  def +(other : Int)
    self + other.to_i64
  end
  def -(other : Int)
    self - other.to_i64
  end
  def ==(other : Int)
    self == other.to_i64
  end
  def ==(other : Pointer(_))
    self == other
  end
  def [](offset : Int) : T
    (self + offset).value
  end
  def []=(offset : Int, value : T)
    (self + offset).value = value
  end
  def unwrap : T
    self[0]
  end
  def null?
    self == 0_u64
  end
end