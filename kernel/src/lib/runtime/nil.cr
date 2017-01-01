struct Nil
  def object_id
    0_u64
  end

  def crystal_type_id
    0
  end

  def ==(other : Nil)
    true
  end

  def same?(other : Nil)
    true
  end

  def same?(other : Reference)
    false
  end

  def hash
    0
  end

  def to_s
    ""
  end

  def to_s(io : IO)
  end

  def inspect
    "nil"
  end

  def inspect(io)
    io << "nil"
  end

  def try(&block)
    self
  end

  def not_nil!
    return true
    #raise "Nil assertion failed"
  end

  def clone
    self
  end
end