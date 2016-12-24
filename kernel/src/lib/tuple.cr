struct Tuple
  def self.new(*args : *T)
    args
  end

  def self.from(array : Array)
    {% begin %}
    Tuple.new(*{{T}}).from(array)
    {% end %}
  end

  def from(array : Array)
    if size != array.size
      raise ArgumentError.new "Expected array of size #{size} but one of size #{array.size} was given."
    end

    {% begin %}
    Tuple.new(
    {% for i in 0...@type.size %}
      self[{{i}}].cast(array[{{i}}]),
    {% end %}
    )
    {% end %}
  end

  def unsafe_at(index : Int)
    self[index]
  end

  def [](index : Int)
    at(index)
  end

  def []?(index : Int)
    at(index) { nil }
  end

  def at(index : Int)
    at(index) { raise IndexError.new }
  end

  def at(index : Int)
    {% for i in 0...T.size %}
      return self[{{i}}] if {{i}} == index
    {% end %}
    yield
  end

  def each
    {% for i in 0...T.size %}
      yield self[{{i}}]
    {% end %}
    self
  end

  def ==(other : self)
    {% for i in 0...T.size %}
      return false unless self[{{i}}] == other[{{i}}]
    {% end %}
    true
  end

  def ==(other : Tuple)
    return false unless size == other.size

    size.times do |i|
      return false unless self[i] == other[i]
    end
    true
  end

  def ==(other)
    false
  end

  def ===(other : self)
    {% for i in 0...T.size %}
      return false unless self[{{i}}] === other[{{i}}]
    {% end %}
    true
  end

  def ===(other : Tuple)
    return false unless size == other.size

    size.times do |i|
      return false unless self[i] === other[i]
    end
    true
  end

  def <=>(other : self)
    {% for i in 0...T.size %}
      cmp = self[{{i}}] <=> other[{{i}}]
      return cmp unless cmp == 0
    {% end %}
    0
  end

  def <=>(other : Tuple)
    min_size = Math.min(size, other.size)
    min_size.times do |i|
      cmp = self[i] <=> other[i]
      return cmp unless cmp == 0
    end
    size <=> other.size
  end

  def hash
    hash = 31 * size
    {% for i in 0...T.size %}
      hash = 31 * hash + self[{{i}}].hash
    {% end %}
    hash
  end

  def clone
    {% if true %}
      Tuple.new(
        {% for i in 0...T.size %}
          self[{{i}}].clone,
        {% end %}
      )
    {% end %}
  end

  def +(other : Tuple)
    plus_implementation(other)
  end

  private def plus_implementation(other : U) forall U
    {% begin %}
      Tuple.new(
        {% for i in 0...@type.size %}
          self[{{i}}],
        {% end %}
        {% for i in 0...U.size %}
          other[{{i}}],
        {% end %}
      )
    {% end %}
  end

  def size
    {{T.size}}
  end

  def types
    T
  end

  def inspect
    to_s
  end

  def to_s(io)
    io << "{"
    join ", ", io, &.inspect(io)
    io << "}"
  end

  def pretty_print(pp) : Nil
    pp.list("{", self, "}")
  end

  def map
    {% if true %}
      Tuple.new(
        {% for i in 0...T.size %}
          (yield self[{{i}}]),
        {% end %}
      )
   {% end %}
  end

  def reverse
    {% if true %}
      Tuple.new(
        {% for i in 1..T.size %}
          self[{{T.size - i}}],
        {% end %}
      )
    {% end %}
  end

  def reverse_each
    {% for i in 1..T.size %}
      yield self[{{T.size - i}}]
    {% end %}
    self
  end

  def first
    self[0]
  end

  def first?
    {% if T.size == 0 %}
      nil
    {% else %}
      self[0]
    {% end %}
  end

  def last
    {% if true %}
      self[{{T.size - 1}}]
    {% end %}
  end

  def last?
    {% if T.size == 0 %}
      nil
    {% else %}
      self[{{T.size - 1}}]
    {% end %}
  end
end