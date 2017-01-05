struct Pointer(T)
  def self.null
    new 0_u64
  end

  def +(other : Int)
    self + other.to_i64
  end

  def -(other : Int)
    if other > address
      panic
    end
    self + (0 - other)
  end

  def <(other : Pointer(_))
    address < other.address
  end

  def >(other : Pointer(_))
    address > other.address
  end

  def ==(other : Int)
    address == other.address.to_i64
  end

  def ==(other : Pointer(_))
    address == other.address
  end

  def <=>(other : self)
    address <=> other.address
  end

  def [](offset : Int) : T
    (self + offset).value
  end

  def []=(offset : Int, value : T)
    (self + offset).value = value
  end

  def copy_from(source : Pointer(T), count : Int)
    source.copy_to self, count
  end

  def copy_from(source : Pointer(NoReturn), count : Int)
    raise "Negative count" if count < 0
    self
  end

  def copy_to(target : Pointer, count : Int)
    target.copy_from_impl self, count
  end

  def clear(count = 1)
    memset self.to_void_ptr, 0_u8, (count * sizeof(T)).to_u32
  end

  def null?
    address == 0
  end

  def to_byte_ptr
    self.as UInt8*
  end

  def to_void_ptr
    self.as Void*
  end

  def to_s(io : IO)
    io << "Pointer("
    io << T.to_s
    io << ")"
    if address == 0
      io << ".null"
    else
      io << "@0x"
      address.to_s 16, io
    end
  end

  protected def copy_from_impl(source : Pointer(T), count : Int)
    raise "Negative count" if count < 0
    if self.class == source.class
      memcpy self.to_void_ptr, source.to_void_ptr, (count * sizeof(T)).to_u32
    else
      while (count -= 1) >= 0
        self[count] = source[count]
      end
    end
    self
  end
end
