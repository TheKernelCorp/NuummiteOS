module Indexable(T)
  abstract def size
  abstract def unsafe_at(index : Int)

  def at(index : Int)
    index = check_index_out_of_bounds index do
      return yield
    end
    unsafe_at index
  end

  @[AlwaysInline]
  def at(index : Int)
    at(index) { panic "Invalid index!" }
  end

  @[AlwaysInline]
  def [](index : Int)
    at index
  end

  @[AlwaysInline]
  def []?(index : Int)
    at(index) { nil }
  end

  @[AlwaysInline]
  def []=(index : Int, value : T)
    index = check_index_out_of_bounds index
    @buffer[index] = value
  end

  def each
    each_index do |i|
      yield unsafe_at i
    end
  end

  def each_index
    i = 0
    while i < size
      yield i
      i += 1
    end
    self
  end

  def empty?
    size == 0
  end

  private def check_index_out_of_bounds(index)
    check_index_out_of_bounds(index) { panic "Index out of bounds!" }
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
