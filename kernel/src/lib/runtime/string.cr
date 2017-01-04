class String
  TYPE_ID = "".crystal_type_id
  HEADER_SIZE = sizeof({Int32, Int32, Int32})

  def self.new(slice : Bytes)
    new slice.to_unsafe, slice.size
  end

  def self.new(chars : UInt8*)
    new chars, LibC.strlen(chars)
  end

  def self.new(chars : UInt8*, bytesize, size = 0)
    return "" if bytesize == 0
    new(bytesize) do |buffer|
      buffer.copy_from chars, bytesize
      {bytesize, size}
    end
  end

  def self.new(capacity : Int)
    check_capacity_in_bounds capacity
    str = GC.malloc_atomic(capacity.to_u32 + HEADER_SIZE + 1).as UInt8*
    buffer = str.as(String).to_unsafe
    bytesize, size = yield buffer
    unless 0 <= bytesize <= capacity
      raise ArgumentError.new "Bytesize out of capacity bounds"
    end
    buffer[bytesize] = 0_u8
    if bytesize < capacity
      str = HeapAllocator(UInt8).realloc str, bytesize.to_u32 + HEADER_SIZE + 1
    end
    str_header = str.as({Int32, Int32, Int32}*)
    str_header.value = {TYPE_ID, bytesize.to_i, size.to_i}
    str.as String
  end

  def self.build(capacity = 64) : self
    String::Builder.build(capacity) do |builder|
      yield builder
    end
  end

  def bytesize
    @bytesize
  end

  def [](index : Int)
    at(index) { raise IndexError.new }
  end

  def [](range : Range(Int, Int))
    from, size = range_to_index_and_size range
    self[from, size]
  end

  def [](start : Int, count : Int)
    # Only support ASCII strings for now
    return byte_slice(start, count)
  end

  def []?(index : Int)
    at(index) { nil }
  end

  def at(index : Int)
    at(index) { raise IndexError.new }
  end

  def at(index : Int)
    # Only support ASCII strings for now
    byte = byte_at? index
    return byte ? byte.unsafe_chr : yield
  end

  def byte_slice(start : Int, count : Int)
    start += bytesize if start < 0
    single_byte_optimizable = true # We only support ASCII strings
    if 0 <= start < bytesize
      raise ArgumentError.new "Negative count" if count < 0
      count = bytesize - start if start + count > bytesize
      return "" if count == 0
      return self if count == bytesize
      String.new(count) do |buffer|
        buffer.copy_from to_unsafe + start, count
        slice_size = single_byte_optimizable ? count : 0
        {count, slice_size}
      end
    elsif start == bytesize
      return "" if count >= 0
      raise ArgumentError.new "Negative count"
    end
    raise IndexError.new
  end

  def byte_slice(start : Int)
    byte_slice start, bytesize - start
  end

  def codepoint_at(index)
    char_at(index).ord
  end

  def char_at(index)
    self[index]
  end

  def byte_at(index)
    byte_at(index) { raise IndexError.new }
  end

  def byte_at?(index)
    byte_at(index) { nil }
  end

  def byte_at(index)
    index += bytesize if index < 0
    if 0 <= index < bytesize
      to_unsafe[index]
    else
      yield
    end
  end

  def unsafe_byte_at(index)
    to_unsafe[index]
  end

  def self.check_capacity_in_bounds(capacity)
    raise ArgumentError.new "Negative capacity" if capacity < 0
    raise ArgumentError.new "Capacity too big" if capacity.to_u64 > (UInt32::MAX - HEADER_SIZE - 1)
  end

  private def range_to_index_and_size(range)
    from = range.begin
    from += size if from < 0
    raise IndexError.new if from < 0
    to = range.end
    to += size if to < 0
    to -= 1 if range.excludes_end?
    size = to - from + 1
    size = 0 if size < 0
    {from, size}
  end

  def each_byte_index_and_char_index
    byte_index = 0
    char_index = 0
    while byte_index < bytesize
      yield byte_index, char_index
      c = to_unsafe[byte_index]
      if c < 0x80
        byte_index += 1
      elsif c < 0xE0
        byte_index += 2
      elsif c < 0xF0
        byte_index += 3
      else
        byte_index += 4
      end
      char_index += 1
    end
    char_index
  end

  def each_byte
    to_unsafe.to_slice(bytesize).each do |byte|
      yield byte
    end
    self
  end

  def each_byte
    to_slice.each
  end

  def to_slice
    Slice.new to_unsafe, bytesize
  end

  def hash
    h = 0
    each_byte do |c|
      h = 31 * h + c
    end
    h
  end

  def size
    if @length > 0 || @bytesize == 0
      return @length
    end
    @length = each_byte_index_and_char_index { }
  end

  def to_unsafe
    pointerof(@c)
  end

  def to_s
    self
  end

  def to_s(io)
    io.write Slice.new(to_unsafe, bytesize)
  end

  def dup
    self
  end

  def clone
    self
  end
end

module StringTests
  def self.run
    run_tests [
      init,
      init_slice,
      at,
      at_range,
    ]
  end

  test init, "String#new", begin
    chars = StaticArray[
      'a'.ord.to_u8,
      'b'.ord.to_u8,
      0_u8, # ASCII NUL
    ]
    str = String.new chars.to_unsafe
    assert_eq 'a'.ord.to_u8, (str.to_unsafe + 0).value
    assert_eq 'b'.ord.to_u8, (str.to_unsafe + 1).value
    str = String.new chars.to_unsafe, 2
    assert_eq 'a'.ord.to_u8, (str.to_unsafe + 0).value
    assert_eq 'b'.ord.to_u8, (str.to_unsafe + 1).value
  end

  test init_slice, "String#new/slice", begin
    chars = Slice[
      'a'.ord.to_u8,
      'b'.ord.to_u8,
      0_u8, # ASCII NUL
    ]
    str = String.new chars
    assert_eq 'a'.ord.to_u8, (str.to_unsafe + 0).value
    assert_eq 'b'.ord.to_u8, (str.to_unsafe + 1).value
  end

  test at, "String#[]", begin
    chars = StaticArray[
      'a'.ord.to_u8,
      'b'.ord.to_u8,
      0_u8, # ASCII NUL
    ]
    str = String.new chars.to_unsafe
    assert_eq 'a', str[0]
    assert_eq 'b', str[1]
  end

  test at_range, "String#[]=", begin
    chars = StaticArray[
      'a'.ord.to_u8,
      'b'.ord.to_u8,
      0_u8, # ASCII NUL
    ]
    str = String.new chars.to_unsafe
    slice = str[0..1]
    assert_eq 'a', slice[0]
    assert_eq 'b', slice[1]
  end
end

require "./string/builder"
