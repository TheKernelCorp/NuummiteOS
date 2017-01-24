class Reference
  def ==(other : self)
    same? other
  end

  def ==(other)
    false
  end

  def same?(other : Reference)
    object_id == other.object_id
  end

  def same?(other : Nil)
    false
  end

  def hash
    object_id
  end

  def to_s(io : IO) : Nil
    io << "#<" << self.class.name << ":0x"
    object_id.to_s 16, io
    io << ">"
    nil
  end
end
