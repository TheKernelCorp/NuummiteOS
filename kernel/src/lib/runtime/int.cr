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
