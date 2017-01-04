class String::Builder
  include IO

  getter bytesize : Int32
  getter capacity : Int32
  getter buffer : UInt8*

  def initialize(capacity : Int = 64)
    String.check_capacity_in_bounds capacity
    capacity += String::HEADER_SIZE + 1
    String.check_capacity_in_bounds capacity
    @buffer = GC.malloc_atomic(capacity.to_u32).as UInt8*
    @bytesize = 0
    @capacity = capacity.to_i
    @finished = false
  end

  def self.build(capacity : Int = 64) : String
    builder = new capacity
    yield builder
    builder.to_s
  end

  def self.new(string : String)
    builder = new string.bytesize
    builder << string
    builder
  end

  def read(slice : Bytes)
    raise "Not implemented"
  end

  def write(slice : Bytes)
    count = slice.size
    new_bytesize = real_bytesize + count
    if new_bytesize > @capacity
      resize_to_capacity Math.pw2ceil(new_bytesize)
    end
    slice.copy_to @buffer + real_bytesize, count
    @bytesize += count
    nil
  end

  def buffer
    @buffer + String::HEADER_SIZE
  end

  def empty?
    @bytesize == 0
  end

  def to_s
    raise "Can only invoke `to_s` once on String::Builder" if @finished
    @finished = true
    write_byte 0_u8
    real_byte_size = real_bytesize
    if @capacity > real_byte_size
      resize_to_capacity real_byte_size
    end
    header = @buffer.as {Int32, Int32, Int32}*
    header.value = {String::TYPE_ID, @bytesize - 1, 0}
    @buffer.as String
  end

  private def real_bytesize
    @bytesize + String::HEADER_SIZE
  end

  private def check_needs_resize
    resize_to_capacity(@capacity * 2) if real_bytesize == @capacity
  end

  private def resize_to_capacity(capacity)
    @capacity = capacity
    @buffer = HeapAllocator(UInt8).realloc @buffer, @capacity.to_u32
  end
end
