module IO
  abstract def read(slice : Bytes)
  abstract def write(slice : Bytes) : Nil

  def flush
  end

  def close
  end

  def closed?
    false
  end

  def tty? : Bool
    false
  end

  def <<(obj) : self
    obj.to_s self
    self
  end

  def write_byte(byte : UInt8)
    x = byte
    write Slice.new(pointerof(x), 1)
  end

  protected def check_open
    raise IO::Error.new "Closed stream" if closed?
  end
end

require "./io/*"
