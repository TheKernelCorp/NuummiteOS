# Only ASCII characters are supported.

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
      str = str.realloc bytesize.to_u32 + HEADER_SIZE + 1
    end
    str_header = str.as {Int32, Int32, Int32}*
    str_header.value = {TYPE_ID, bytesize.to_i, size.to_i}
    str.as String
  end

  def self.build(capacity = 64) : self
    String::Builder.build(capacity) do |builder|
      yield builder
    end
  end

  def self.check_capacity_in_bounds(capacity)
    raise ArgumentError.new "Negative capacity" if capacity < 0
    raise ArgumentError.new "Capacity too big" if capacity.to_u64 > (UInt32::MAX - HEADER_SIZE - 1)
  end

  def bytesize
    @bytesize
  end

  def empty?
    bytesize == 0
  end

  def ==(other : self)
    return true if same? other
    return false unless bytesize == other.bytesize
    to_unsafe.memcmp(other.to_unsafe, bytesize) == 0
  end

  def [](index : Int)
    at(index) { raise IndexError.new }
  end

  def [](range : Range(Int, Int))
    from, size = range_to_index_and_size range
    self[from, size]
  end

  def [](start : Int, count : Int)
    byte_slice start, count
  end

  def []?(index : Int)
    at(index) { nil }
  end

  def at(index : Int)
    at(index) { raise IndexError.new }
  end

  def at(index : Int)
    byte = byte_at? index
    byte ? byte.unsafe_chr : yield
  end

  def byte_slice(start : Int, count : Int)
    start += bytesize if start < 0
    single_byte_optimizable = true
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

  def starts_with?(char : Char)
    each_char do |c|
      return c == char
    end
    false
  end

  def ends_with?(str : String)
    return false if str.bytesize > bytesize
    (to_unsafe + bytesize - str.bytesize).memcmp(str.to_unsafe, str.bytesize) == 0
  end

  def ends_with?(char : Char)
    return false unless bytesize > 0
    return to_unsafe[bytesize - 1] == char.ord
  end

  def starts_with?(str : String)
    return false if str.bytesize > bytesize
    to_unsafe.memcmp(str.to_unsafe, str.bytesize) == 0
  end

  def lchomp(char : Char)
    if starts_with? char
      unsafe_byte_slice_string char.bytesize, bytesize - char.bytesize
    else
      self
    end
  end

  def lchomp(str : String)
    if starts_with? str
      unsafe_byte_slice_string str.bytesize, bytesize - str.bytesize
    else
      self
    end
  end

  def chomp
    return self if empty?
    case to_unsafe[bytesize - 1]
    when '\n'
      if bytesize > 1 && to_unsafe[bytesize - 2] === '\r'
        unsafe_byte_slice_string 0, bytesize - 2
      else
        unsafe_byte_slice_string 0, bytesize - 1
      end
    when '\r'
      unsafe_byte_slice_string 0, bytesize - 1
    else
      self
    end
  end

  def chomp(char : Char)
    if char == '\n'
      chomp
    elsif ends_with? char
      unsafe_byte_slice_string 0, bytesize - char.bytesize
    else
      self
    end
  end

  def chomp(str : String)
    if ends_with? str
      unsafe_byte_slice_string 0, bytesize - str.bytesize
    else
      self
    end
  end

  def chomp(arr : Array(Char))
    arr.each do |chr|
      if ends_with? chr
        return unsafe_byte_slice_string 0, bytesize - chr.bytesize
      end
    end
    self
  end

  def chop
    return "" if bytesize <= 1
    if true &&
      bytesize >= 2 &&
      to_unsafe[bytesize - 1] === '\n' &&
      to_unsafe[bytesize - 2] === '\r'
      return unsafe_byte_slice_string 0, bytesize - 2
    end
    if to_unsafe[bytesize - 1] < 128
      return unsafe_byte_slice_string 0, bytesize - 1
    end
    self[0, size - 1]
  end

  def strip
    excess_right = calc_excess_right
    if excess_right == bytesize
      return ""
    end
    excess_left = calc_excess_left
    if excess_right == 0 && excess_left == 0
      self
    else
      unsafe_byte_slice_string excess_left, bytesize - excess_left - excess_right
    end
  end

  def count
    count = 0
    each_char do |char|
      count += 1 if yield char
    end
    count
  end

  def count(other : Char)
    count { |char| char == other }
  end

  def split(limit : Int32? = nil)
    ary = Array(String).new
    split(limit) do |string|
      ary << string
    end
    ary
  end

  def split(separator : Char, limit = nil)
    ary = Array(String).new
    split(separator, limit) do |string|
      ary << string
    end
    ary
  end

  def split(separator : String, limit = nil)
    ary = Array(String).new
    split(separator, limit) do |string|
      ary << string
    end
    ary
  end

  def split(limit : Int32? = nil, &block : String -> _)
    if limit && limit <= 1
      yield self
      return
    end
    yielded = 0
    single_byte_optimizable = true
    index = 0
    i = 0
    looking_for_space = false
    limit_reached = false
    while i < bytesize
      if looking_for_space
        while i < bytesize
          c = to_unsafe[i]
          i += 1
          if c.unsafe_chr.ascii_whitespace?
            piece_bytesize = i - 1 - index
            piece_size = single_byte_optimizable ? piece_bytesize : 0
            yield String.new to_unsafe + index, piece_bytesize, piece_size
            yielded += 1
            looking_for_space = false
            if limit && yielded + 1 == limit
              limit_reached = true
            end
            break
          end
        end
      else
        while i < bytesize
          c = to_unsafe[i]
          i += 1
          unless c.unsafe_chr.ascii_whitespace?
            index = i - 1
            looking_for_space = true
            break
          end
        end
        break if limit_reached
      end
    end
    if looking_for_space
      piece_bytesize = bytesize - index
      piece_size = single_byte_optimizable ? piece_bytesize : 0
      yield String.new to_unsafe + index, piece_bytesize, piece_size
    end
  end

  def split(separator : Char, limit = nil, &block : String -> _)
    if empty? || limit && limit <= 1
      yield self
      return
    end
    yielded = 0
    byte_offset = 0
    pos = 0
    self.each_char do |char|
      if char == separator
        piece_bytesize = pos - byte_offset
        yield String.new to_unsafe + byte_offset, piece_bytesize
        yielded += 1
        byte_offset = pos + 1
        break if limit && yielded + 1 == limit
      end
      pos += 1
    end
    piece_bytesize = bytesize - byte_offset
    yield String.new(to_unsafe + byte_offset, piece_bytesize)
  end

  def split(separator : String, limit = nil, &block : String -> _)
    if empty? || (limit && limit <= 1)
      yield self
      return
    end
    if separator.empty?
      split_by_empty_separator(limit) do |string|
        yield string
      end
      return
    end
    yielded = 0
    byte_offset = 0
    separator_bytesize = separator.bytesize
    single_byte_optimizable = true
    i = 0
    stop = bytesize - separator.bytesize + 1
    while i < stop
      if (to_unsafe + i).memcmp(separator.to_unsafe, separator_bytesize) == 0
        piece_bytesize = i - byte_offset
        piece_size = single_byte_optimizable ? piece_bytesize : 0
        yield String.new to_unsafe + byte_offset, piece_bytesize, piece_size
        yielded += 1
        byte_offset = i + separator_bytesize
        i += separator_bytesize - 1
        break if limit && yielded + 1 == limit
      end
      i += 1
    end
    piece_bytesize = bytesize - byte_offset
    piece_size = single_byte_optimizable ? piece_bytesize : 0
    yield String.new to_unsafe + byte_offset, piece_bytesize, piece_size
  end

  private def split_by_empty_separator(limit, &block : String -> _)
    yielded = 0
    each_char do |c|
      yield c.to_s
      yielded += 1
      break if limit && yielded + 1 == limit
    end
    if limit && yielded != size
      yield self[yielded..-1]
      yielded += 1
    end
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

  def each_char
    each_byte do |byte|
      yield byte.unsafe_chr
    end
    self
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

  def unsafe_byte_slice(byte_offset, count)
    Slice.new to_unsafe + byte_offset, count
  end

  def unsafe_byte_slice(byte_offset)
    Slice.new to_unsafe + byte_offset, bytesize - byte_offset
  end

  protected def unsafe_byte_slice_string(byte_offset)
    String.new unsafe_byte_slice(byte_offset)
  end

  protected def unsafe_byte_slice_string(byte_offset, count)
    String.new unsafe_byte_slice(byte_offset, count)
  end

  private def calc_excess_right
    i = bytesize - 1
    while i >= 0 && to_unsafe[i].unsafe_chr.ascii_whitespace?
      i -= 1
    end
    bytesize - 1 - i
  end

  private def calc_excess_left
    excess_left = 0
    while to_unsafe[excess_left].unsafe_chr.ascii_whitespace?
      excess_left += 1
    end
    excess_left
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
end

module StringTests
  def self.run
    run_tests [
      init,
      init_slice,
      at,
      at_range,
      starts_with,
      ends_with,
      lchomp,
      chomp,
      chop,
      strip,
      count,
      split,
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

  test starts_with, "String#starts_with?", begin
    str = "Foo"
    assert str.starts_with? 'F'
    assert str.starts_with? "Fo"
  end

  test ends_with, "String#ends_with?", begin
    str = "Foo"
    assert str.ends_with? 'o'
    assert str.ends_with? "oo"
  end

  test lchomp, "String#lchomp", begin
    str = "Foo"
    assert_eq "oo", str.lchomp 'F'
    assert_eq "Foo", str.lchomp 'f'
    assert_eq "o", str.lchomp "Fo"
    assert_eq "Foo", str.lchomp "foo"
  end

  test chomp, "String#chomp", begin
    assert_eq "Foo", "Foo".chomp
    assert_eq "Foo", "Foo\r".chomp
    assert_eq "Foo", "Foo\n".chomp
    assert_eq "Foo", "Foo\r\n".chomp
    assert_eq "Foo", "Foox".chomp 'x'
    assert_eq "Foo", "Foox".chomp "x"
    assert_eq "Foo", "Fooxa".chomp "xa"
  end

  test chop, "String#chop", begin
    assert_eq "Foo", "Foox".chop
    assert_eq "Foo", "Foo\r".chop
    assert_eq "Foo", "Foo\n".chop
    assert_eq "Foo", "Foo\r\n".chop
  end

  test strip, "String#strip", begin
    assert_eq "Foo", "Foo ".strip
    assert_eq "Foo", " Foo".strip
    assert_eq "Foo", " Foo ".strip
    assert_eq "Foo", "\r\tFoo \n".strip
  end

  test count, "String#count", begin
    str = "Hello, world!"
    accum = 0
    str.count { |i| accum += 1 }
    assert_eq 13, accum
    assert_eq 3, str.count 'l'
  end

  test split, "String#split", begin
    str = "Foo Bar Baz"
    arr = str.split
    assert_eq 3, arr.size
    assert_eq "Foo", arr[0]
    assert_eq "Bar", arr[1]
    assert_eq "Baz", arr[2]
    str = "Once upon a time"
    arr = str.split 3
    assert_eq 3, arr.size
    assert_eq "Once", arr[0]
    assert_eq "upon", arr[1]
    assert_eq "a time", arr[2]
    str = "Foo,Bar,Baz,Woo"
    arr = str.split ','
    assert_eq 4, arr.size
    assert_eq "Foo", arr[0]
    assert_eq "Bar", arr[1]
    assert_eq "Baz", arr[2]
    assert_eq "Woo", arr[3]
    str = "BisonBison"
    arr = str.split "Bi"
    assert_eq 3, arr.size
    assert_eq "", arr[0]
    assert_eq "son", arr[1]
    assert_eq "son", arr[2]
  end
end

require "./string/builder"
