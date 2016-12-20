struct Pointer(T)
  def +(other : Int)
    self + other.to_i64
  end

  def []=(offset, value)
    (self + offset).value = value
  end
end