struct Pointer(T)
  def self.null
    new 0_u64
  end

  def self.malloc(size : Int = 1)
    if size < 0
      raise ArgumentError.new "negative Pointer#malloc size"
    end
    Heap.kalloc(size.to_u32).as T*
  end

  def self.malloc(size : Int, value : T)
    ptr = Pointer(T).malloc size
    size.times { |i| ptr[i] = value }
    ptr
  end

  def self.malloc(size : Int, &block : Int32 -> T)
    ptr = Pointer(T).malloc size
    size.times { |i| ptr[i] = yield i }
    ptr
  end

  def realloc(size : Int)
    HeapAllocator(T).realloc self, size.to_u32
  end

  def memcmp(other : Pointer(T), count : Int)
    LibC.memcmp self, other, (count * sizeof(T)).to_u32
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
    LibC.memset self, 0_u8, (count * sizeof(T)).to_u32
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

  def to_slice(size)
    Slice.new self, size
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

  def appender
    Pointer::Appender.new(self)
  end

  protected def copy_from_impl(source : T*, count : Int)
    raise "Negative count" if count < 0
    if self.class == source.class
      LibC.memcpy self, source, (count * sizeof(T)).to_u32
    else
      while (count -= 1) >= 0
        self[count] = source[count]
      end
    end
    self
  end

  struct Appender(T)
    def initialize(@pointer : T*)
      @start = @pointer
    end

    def <<(value : T)
      @pointer.value = value
      @pointer += 1
    end

    def size
      @pointer - @start
    end

    def pointer
      @pointer
    end
  end
end
