struct Bool
  def |(other : Bool)
    self ? true : other
  end

  def &(other : Bool)
    self ? other : false
  end

  def ^(other : Bool)
    self != other
  end

  def hash
    self ? 1 : 0
  end

  def to_s
    self ? "true" : "false"
  end

  def to_s(io)
    io << to_s
  end

  def clone
    self
  end
end
