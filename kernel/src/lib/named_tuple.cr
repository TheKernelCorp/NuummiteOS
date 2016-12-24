struct NamedTuple
  def self.new(**options : **T)
    options
  end

  def self.from(hash : Hash)
    {% begin %}
    NamedTuple.new(**{{T}}).from(hash)
    {% end %}
  end

  def from(hash : Hash)
    if size != hash.size
      raise ArgumentError.new("Expected a hash with #{size} keys but one with #{hash.size} keys was given.")
    end

    {% begin %}
      NamedTuple.new(
      {% for key, value in T %}
        {{key.stringify}}: self[{{key.symbolize}}].cast(hash.fetch({{key.symbolize}}) { hash["{{key}}"] }),
      {% end %}
      )
    {% end %}
  end

  def [](key : Symbol | String)
    fetch(key) { raise KeyError.new "Missing named tuple key: #{key.inspect}" }
  end

  def []?(key : Symbol | String)
    fetch(key, nil)
  end

  def fetch(key : Symbol | String, default_value)
    fetch(key) { default_value }
  end

  def fetch(key : Symbol, &block)
    {% for key in T %}
      return self[{{key.symbolize}}] if {{key.symbolize}} == key
    {% end %}
    yield
  end

  def fetch(key : String, &block)
    {% for key in T %}
      return self[{{key.symbolize}}] if {{key.stringify}} == key
    {% end %}
    yield
  end

  def hash
    hash = 31 * size
    {% for key in T.keys.sort %}
      hash = 31 * hash + {{key.symbolize}}.hash
      hash = 31 * hash + self[{{key.symbolize}}].hash
    {% end %}
    hash
  end

  def inspect
    to_s
  end

  def keys
    {% begin %}
      Tuple.new(
        {% for key in T %}
          {{key.symbolize}},
        {% end %}
      )
    {% end %}
  end

  def values
    {% begin %}
      Tuple.new(
        {% for key in T %}
          self[{{key.symbolize}}],
        {% end %}
      )
    {% end %}
  end

  def has_key?(key : Symbol) : Bool
    {% for key in T %}
      return true if {{key.symbolize}} == key
    {% end %}
    false
  end

  def to_s(io)
    io << "{"
    {% for key, value, i in T %}
      {% if i > 0 %}
        io << ", "
      {% end %}
      key = {{key.stringify}}
      if Symbol.needs_quotes?(key)
        key.inspect(io)
      else
        io << key
      end
      io << ": "
      self[{{key.symbolize}}].inspect(io)
    {% end %}
    io << "}"
  end

  def pretty_print(pp)
    pp.surround("{", "}", left_break: nil, right_break: nil) do
      {% for key, value, i in T %}
        {% if i > 0 %}
          pp.comma
        {% end %}
        pp.group do
          key = {{key.stringify}}
          if Symbol.needs_quotes?(key)
            pp.text key.inspect
          else
            pp.text key
          end
          pp.text ": "
          pp.nest do
            pp.breakable ""
            self[{{key.symbolize}}].pretty_print(pp)
          end
        end
      {% end %}
    end
  end

  def each
    {% for key in T %}
      yield {{key.symbolize}}, self[{{key.symbolize}}]
    {% end %}
    self
  end

  def each_key
    {% for key in T %}
      yield {{key.symbolize}}
    {% end %}
    self
  end

  def each_value
    {% for key in T %}
      yield self[{{key.symbolize}}]
    {% end %}
    self
  end

  def each_with_index(offset = 0)
    i = offset
    each do |key, value|
      yield key, value, i
      i += 1
    end
    self
  end

  def map
    array = Array(typeof(yield first_key_internal, first_value_internal)).new(size)
    each do |k, v|
      array.push yield k, v
    end
    array
  end

  def to_a
    ary = Array({typeof(first_key_internal), typeof(first_value_internal)}).new(size)
    each do |key, value|
      ary << {key.as(typeof(first_key_internal)), value.as(typeof(first_value_internal))}
    end
    ary
  end

  def to_h
    {% begin %}
      {
        {% for key in T %}
          {{key.symbolize}} => self[{{key.symbolize}}].clone,
        {% end %}
      }
    {% end %}
  end

  def size
    {{T.size}}
  end

  def empty?
    size == 0
  end

  def ==(other : self)
    {% for key in T %}
      return false unless self[{{key.symbolize}}] == other[{{key.symbolize}}]
    {% end %}
    true
  end

  def ==(other : NamedTuple)
    compare_with_other_named_tuple(other)
  end

  private def compare_with_other_named_tuple(other : U) forall U
    {% if T.keys.sort == U.keys.sort %}
      {% for key in T %}
        return false unless self[{{key.symbolize}}] == other[{{key.symbolize}}]
      {% end %}

      true
    {% else %}
      false
    {% end %}
  end

  def clone
    {% begin %}
      {
        {% for key in T %}
          {{key.stringify}}: self[{{key.symbolize}}].clone,
        {% end %}
      }
    {% end %}
  end

  private def first_key_internal
    i = 0
    keys[i]
  end

  private def first_value_internal
    i = 0
    values[i]
  end
end