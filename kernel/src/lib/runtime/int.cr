struct Int
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
    unsafe_div other
  end

  def %(other : Int)
    if other == 0
      self
    end
    unsafe_mod other
  end

  def times
    i = 0
    while i < self
      yield i
      i += 1
    end
  end
end
