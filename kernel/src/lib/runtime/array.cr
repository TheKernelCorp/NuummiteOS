class Array(T)
  include Indexable(T)
  protected getter size

  def initialize
    @size = 0
    @capacity = 0
    @buffer = Pointer(T).null
  end

  def initialize(capacity : Int)
    if capacity < 0
      panic "Negative array capacity!"
    end
    @size = 0
    @capacity = capacity.to_i
    if capacity == 0
      @buffer = Pointer(T).null
    else
      @buffer = Pointer(T).malloc capacity.to_u64
    end
  end

  def self.new(size : Int, &block : Int32 -> T)
    Array(T).build(size) do |buffer|
      size.to_i.times do |i|
        buffer[i] = yield i
      end
      size
    end
  end

  def self.build(capacity : Int)
    ary = Array(T).new capacity
    ary.size = (yield ary.to_unsafe).to_i
    ary
  end

  def size
    @size
  end

  def to_unsafe : T*
    @buffer
  end

  def push(value : T)
    check_needs_resize
    @buffer[@size] = value
    @size += 1_u32
    self
  end

  def pop
    pop { raise "Invalid index" } # IndexError.new
  end

  def pop
    if @size == 0
      yield
    else
      @size -= 1
      value = @buffer[@size]
      (@buffer + @size).clear
      value
    end
  end

  def <<(value : T)
    push value
  end

  @[AlwaysInline]
  def unsafe_at(index : Int) : T
    @buffer[index]
  end

  protected def size=(size : Int)
    @size = size.to_i
  end

  private def check_needs_resize
    double_capacity if @size == @capacity
  end

  private def double_capacity
    new_capacity = @capacity == 0_u32 ? 3_u32 : (@capacity * 2_u32)
    resize_to_capacity new_capacity
  end

  private def resize_to_capacity(capacity : Int)
    @capacity = capacity.to_i
    if @buffer
      @buffer = HeapAllocator(T).realloc @buffer, @capacity.to_u32
    else
      @buffer = Pointer(T).malloc @capacity.to_u64
    end
  end
end

module ArrayTests
  def self.run
    run_tests [
      init,
      init_capacity,
      push,
      pop,
      index,
      index_assign,
    ]
  end

  test init, "Array#new", begin
    arr = Array(UInt8).new
    assert arr
    assert_not arr.@buffer
    assert_eq 0_u32, arr.@size
    assert_eq 0_u32, arr.@capacity
  end

  test init_capacity, "Array#new/capacity", begin
    arr = Array(UInt8).new 2
    assert arr
    assert arr.@buffer
    assert_eq 0_u32, arr.@size
    assert_eq 2_u32, arr.@capacity
  end

  test push, "Array#push", begin
    arr = Array(UInt8).new
    assert arr
    arr.push 24_u8
    arr.push 68_u8
    assert arr.@buffer
    assert_eq 24_u8, arr.@buffer[0]
    assert_eq 68_u8, arr.@buffer[1]
  end

  test pop, "Array#pop", begin
    arr = Array(UInt8).new
    arr.push 1_u8
    assert_eq 1_u8, arr.pop
  end

  test index, "Array#[]", begin
    arr = Array(UInt8).new
    assert arr
    arr.push 24_u8
    arr.push 68_u8
    assert_eq 24_u8, arr[0]
    assert_eq 68_u8, arr[1]
  end

  test index_assign, "Array#[]=", begin
    arr = Array(UInt8).new
    assert arr
    arr.push 24_u8
    arr.push 68_u8
    arr[0] = 13_u8
    arr[1] = 57_u8
    assert_eq 13_u8, arr[0]
    assert_eq 57_u8, arr[1]
  end
end
