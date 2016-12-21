struct Pointer(T)
  def +(other : Int)
    self + other.to_i64
  end

  def []=(offset : Int, value : T)
    (self + offset).value = value
  end
end