alias Bytes = Slice(UInt8)

struct Slice(T)
  include Indexable(T)

  # Creates a heap-allocated slice
  macro [](*args)
    {% if @type.name != "Slice(T)" && T < Number %}
      {{T}}.slice({{*args}})
    {% else %}
      %ptr = Pointer(typeof({{*args}})).malloc({{args.size}}.to_u64)
      {% for arg, i in args %}
        %ptr[{{i}}] = {{arg}}
      {% end %}
      Slice.new(%ptr, {{args.size}})
    {% end %}
  end

  getter size : Int32

  def initialize(@pointer : T*, size : Int)
    @size = size.to_i32
  end

  def self.new(size : Int)
    {% unless T <= Int::Primitive %}
      {% raise "Can only use primitive integers with Slice.new(size)." %}
    {% end %}
    ptr = Pointer(T).malloc size.to_u64
    new ptr, size
  end

  def self.new(size : Int)
    ptr = Pointer(T).malloc size.to_u64
    new ptr, size
  end

  def self.new(size : Int, value : T)
    new(size) { value }
  end

  def self.empty
    new Pointer(T).null, 0
  end

  def +(offset : Int)
    unless 0 <= offset <= size
      raise IndexError.new
    end
    Slice.new @pointer + offset, @size - offset
  end

  @[AlwaysInline]
  def []=(index : Int, value : T)
    index += size if index < 0
    unless 0 <= index < size
      raise IndexError.new
    end
    @pointer[index] = value
  end

  def [](start, count)
    unless 0 <= start <= @size
      raise IndexError.new
    end
    unless 0 <= count <= @size - start
      raise IndexError.new
    end
    Slice.new @pointer + start, count
  end

  @[AlwaysInline]
  def unsafe_at(index : Int)
    @pointer[index]
  end

  def pointer(size)
    unless 0 <= size <= @size
      raise IndexError.new
    end
    @pointer
  end

  def copy_from(source : T*, count)
    pointer(count).copy_from source, count
  end

  def copy_to(target : T*, count)
    pointer(count).copy_to target, count
  end

  def copy_to(target : self)
    @pointer.copy_to target.pointer(size), size
  end

  @[AlwaysInline]
  def copy_from(source : self)
    source.copy_to self
  end

  def to_slice
    self
  end

  def to_unsafe : T*
    @pointer
  end
end
