class Object
  # abstract def ==(other)

  def !=(other)
    !(self == other)
  end

  def !~(other)
    !(self =~ other)
  end

  def ===(other)
    self == other
  end

  def =~(other)
    nil
  end

  # abstract def hash

  def tap
    yield self
    self
  end

  def try
    yield self
  end

  def not_nil!
    self
  end

  def itself
    self
  end
end