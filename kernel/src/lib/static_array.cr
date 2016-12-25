struct StaticArray(T, N)
  macro [](*args)
    %array = uninitialized StaticArray(typeof({{*args}}), {{args.size}})
    {% for arg, i in args %}
      %array.to_unsafe[{{i}}] = {{arg}}
    {% end %}
    %array
  end

  def self.new(&block : Int32 -> T)
    array = uninitialized self
    N.times do |i|
      array.to_unsafe[i] = yield i
    end
    array
  end

  def self.new(value : T)
    new { value }
  end

  private def initialize
  end

  def ==(other : StaticArray)
    return false unless size == other.size
    each_with_index do |e, i|
      return false unless e == other[i]
    end
    true
  end

  def ==(other)
    false
  end

  @[AlwaysInline]
  def unsafe_at(index : Int)
    to_unsafe[index]
  end

  @[AlwaysInline]
  def [](index : Int)
    to_unsafe[index]
  end

  @[AlwaysInline]
  def []=(index : Int, value : T)
    index = check_index_out_of_bounds index
    to_unsafe[index] = value
  end

  def update(index : Int)
    index = check_index_out_of_bounds index
    to_unsafe[index] = yield to_unsafe[index]
  end

  def size
    N
  end

  def []=(value : T)
    size.times do |i|
      to_unsafe[i] = value
    end
  end

  def shuffle!(random = Random::DEFAULT)
    to_slice.shuffle!(random)
    self
  end

  def map!
    to_unsafe.map!(size) { |e| yield e }
    self
  end

  def reverse!
    to_slice.reverse!
    self
  end

  def to_slice
    Slice.new(to_unsafe, size)
  end

  def to_unsafe : Pointer(T)
    pointerof(@buffer)
  end

  def to_s(io : IO)
    io << "StaticArray["
    join ", ", io, &.inspect(io)
    io << "]"
  end

  def pretty_print(pp)
    pp.list("StaticArray[", to_slice, "]")
  end

  def clone
    array = uninitialized self
    N.times do |i|
      array.to_unsafe[i] = to_unsafe[i].clone
    end
    array
  end

  def index(object, offset : Int = 0)
    if T.is_a?(UInt8.class) &&
       (object.is_a?(UInt8) || (object.is_a?(Int) && 0 <= object < 256))
      return to_slice.fast_index(object, offset)
    end

    super
  end

  private def check_index_out_of_bounds(index)
    check_index_out_of_bounds(index) { raise "Index Error" }
  end

  private def check_index_out_of_bounds(index)
    index += size if index < 0
    if 0 <= index < size
      index
    else
      yield
    end
  end
end

module StaticArrayTests
  def self.run
    run_tests [
      static_array,
      static_array_ptr,
    ]
  end
  
  test static_array, "StaticArray#[]/[]=", begin
    panic_on_fail!
    arr = uninitialized UInt8[2]
    arr[0] = 64_u8
    arr[1] = 32_u8
    assert_eq arr[0], 64_u8
    assert_eq arr[1], 32_u8
  end

  test static_array_ptr, "StaticArray#ptr[]/ptr[]=", begin
    panic_on_fail!
    arr = uninitialized UInt8[2]
    ptr = arr.to_unsafe
    ptr[0] = 64_u8
    ptr[1] = 32_u8
    assert_eq ptr[0], 64_u8
    assert_eq ptr[1], 32_u8
  end
end
