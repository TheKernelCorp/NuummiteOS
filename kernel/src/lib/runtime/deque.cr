class Deque(T)
  include Indexable(T)
  protected setter size
  protected getter buffer
  @start = 0

  def initialize
    @size = 0
    @capacity = 0
    @buffer = Pointer(T).null
  end

  def initialize(capacity : Int)
    if capacity < 0
      raise ArgumentError.new "Negative deque capacity: #{capacity}"
    end
    @size = 0
    @capacity = capacity.to_i
    if @capacity == 0
      @buffer = Pointer(T).null
    else
      @buffer = Pointer(T).malloc @capacity
    end
  end

  def self.new(size : Int, &block : Int32 -> T)
    if size < 0
      raise ArgumentError.new "Negative deque size: #{size}"
    end
    deque = Deque(T).new size
    deque.size = size
    size.to_i.times do |i|
      deque.buffer[i] = yield i
    end
    deque
  end

  def self.new(array : Array(T))
    Deque(T).new(array.size) { |i| array[i] }
  end

  def ==(other : Deque)
    equals?(other) { |x, y| x == y }
  end

  def ==(other)
    false
  end

  def <<(value : T)
    push value
  end

  def []=(index : Int, value : T)
    index += @size if index < 0
    unless 0 <= index < @size
      raise IndexError.new
    end
    index += @start
    index -= @capacity if index >= @capacity
    @buffer[index] = value
  end

  def unsafe_at(index : Int)
    index += @start
    index -= @capacity if index >= @capacity
    @buffer[index]
  end

  def clear
    halfs do |r|
      (@buffer + r.begin).clear r.end - r.begin
    end
    @size = 0
    @start = 0
    self
  end

  def delete(obj)
    found = false
    i = 0
    while i < @size
      if self[i] == obj
        delete_at i
        found = true
      else
        i += 1
      end
    end
    found
  end

  def delete_at(index : Int)
    if index < 0
      index += @size
    end
    unless 0 <= index < @size
      raise IndexError.new
    end
    return shift if index == 0
    return pop if index == @size - 1
    rindex = @start + index
    rindex -= @capacity if rindex >= @capacity
    value = @buffer[rindex]
    if index > @size / 2
      # Move following items to the left, starting with the first one
      # [56-01234] -> [6x-01235]
      dst = rindex
      finish = (@start + @size - 1) % @capacity
      loop do
        src = dst + 1
        src -= @capacity if src >= @capacity
        @buffer[dst] = @buffer[src]
        break if src == finish
        dst = src
      end
      (@buffer + finish).clear
    else
      # Move preceding items to the right, starting with the last one
      # [012345--] -> [x01345--]
      dst = rindex
      finish = @start
      @start += 1
      @start -= @capacity if @start >= @capacity
      loop do
        src = dst - 1
        src += @capacity if src < 0
        @buffer[dst] = @buffer[src]
        break if src == finish
        dst = src
      end
      (@buffer + finish).clear
    end
    @size -= 1
    value
  end

  def each
    halfs do |r|
      r.each do |i|
        yield @buffer[i]
      end
    end
  end

  def size
    @size
  end

  def push(value : T)
    increase_capacity if @size >= @capacity
    index = @start + @size
    index -= @capacity if index >= @capacity
    @buffer[index] = value
    @size += 1
    self
  end

  def pop
    pop { raise IndexError.new }
  end

  def pop
    if @size == 0
      yield
    else
      @size -= 1
      index = @start + @size
      index -= @capacity if index >= @capacity
      value = @buffer[index]
      (@buffer + index).clear
      value
    end
  end

  def pop?
    pop { nil }
  end

  def shift
    shift { raise IndexError.new }
  end

  def shift
    if @size == 0
      yield
    else
      value = @buffer[@start]
      (@buffer + @start).clear
      @size -= 1
      @start += 1
      @start -= @capacity if @start >= @capacity
      value
    end
  end

  def shift?
    shift { nil }
  end

  def unshift(value : T)
    increase_capacity if @size >= @capacity
    @start -= 1
    @start += @capacity if @start < 0
    @buffer[@start] = value
    @size += 1
    self
  end

  def swap(i : Int, j : Int)
    self[i], self[j] = self[j], self[i]
    self
  end

  def to_a
    arr = Array(T).new @size
    each do |x|
      arr << x
    end
    arr
  end

  private def halfs
    return if empty?
    a = @start
    b = @start + @size
    b -= @capacity if b > @capacity
    if a < b
      yield a...b
    else
      yield a...@capacity
      yield 0...b
    end
  end

  private def increase_capacity
    unless @buffer
      @capacity = 4
      @buffer = Pointer(T).malloc @capacity.to_u64
    end
    old_capacity = @capacity
    @capacity *= 2
    @buffer = HeapAllocator(T).realloc @buffer, @capacity.to_u32
    finish = @start + @size
    if finish > old_capacity
      finish -= old_capacity
      if old_capacity - @start >= @start
        (@buffer + old_capacity).copy_from @buffer, finish
        @buffer.clear finish
      else
        to_move = old_capacity - @start
        new_start = @capacity - to_move
        (@buffer + new_start).copy_from @buffer + @start, to_move
        (@buffer + @start).clear to_move
        @start = new_start
      end
    end
  end
end

module DequeTests
  def self.run
    run_tests [
      init,
      init_capacity,
      push,
      size,
      pop,
      pop?,
      index,
      index_assign,
      swap,
      shift,
      shift?,
      unshift,
      to_a,
    ]
  end

  test init, "Deque#new", begin
    arr = Deque(UInt8).new
    assert_not arr.@buffer
    assert_eq 0, arr.@size
    assert_eq 0, arr.@capacity
  end

  test init_capacity, "Deque#new/capacity", begin
    arr = Deque(UInt8).new 2
    assert arr.@buffer
    assert_eq 0, arr.@size
    assert_eq 2, arr.@capacity
  end

  test push, "Deque#push", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.push 2_u8
    assert arr.@buffer
    assert_eq 1_u8, arr.@buffer[0]
    assert_eq 2_u8, arr.@buffer[1]
  end

  test size, "Deque#size", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.push 2_u8
    assert_eq 2_u8, arr.size
  end

  test pop, "Deque#pop", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.push 2_u8
    assert_eq 2_u8, arr.pop
    assert_eq 1_u8, arr.pop
  end

  test pop?, "Deque#pop?", begin
    arr = Deque(UInt8).new 2
    assert_not arr.pop?
  end

  test index, "Deque#[]", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.push 2_u8
    assert arr.@buffer
    assert_eq 1_u8, arr[0]
    assert_eq 2_u8, arr[1]
  end

  test index_assign, "Deque#[]=", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.push 2_u8
    arr[0] = 3_u8
    arr[1] = 4_u8
    assert_eq 3_u8, arr[0]
    assert_eq 4_u8, arr[1]
  end

  test swap, "Deque#swap", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.push 2_u8
    arr.swap 0, 1
    assert_eq 2_u8, arr[0]
    assert_eq 1_u8, arr[1]
  end

  test shift, "Deque#shift", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.push 2_u8
    assert_eq 1_u8, arr.shift
    assert_eq 2_u8, arr.shift
  end

  test shift?, "Deque#shift?", begin
    arr = Deque(UInt8).new 2
    assert_not arr.shift?
  end

  test unshift, "Deque#unshift", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr.unshift 2_u8
    assert_eq 2_u8, arr[0]
    assert_eq 1_u8, arr[1]
  end

  test to_a, "Deque#to_a", begin
    arr = Deque(UInt8).new 2
    arr.push 1_u8
    arr = arr.to_a
    assert_eq 1_u8, arr.pop
  end
end
