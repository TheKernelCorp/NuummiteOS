struct Proc
  def self.new(pointer : Void*, closure_data : Void*)
    func = {pointer, closure_data}
    ptr = pointerof(func).as self*
    ptr.value
  end

  def partial(*args : *U) forall U
    {% begin %}
      {% remaining = (T.size - U.size) %}
      ->(
          {% for i in 0...remaining %}
            arg{{i}} : {{T[i + U.size]}},
          {% end %}
        ) {
        call(
          *args,
          {% for i in 0...remaining %}
            arg{{i}},
          {% end %}
        )
      }
    {% end %}
  end

  def arity
    {{ T.size }}
  end

  def pointer
    internal_representation[0]
  end

  def closure_data
    internal_representation[1]
  end

  def closure?
    !closure_data.null?
  end

  private def internal_representation
    func = self
    ptr = pointerof(func).as {Void*, Void*}*
    ptr.value
  end

  def ==(other : self)
    pointer == other.pointer && closure_data == other.closure_data
  end

  def ===(other : self)
    self == other
  end

  def ===(other)
    call(other)
  end

  def hash
    internal_representation.hash
  end

  def clone
    self
  end

  def to_s(io)
    io << "#<"
    io << {{@type.name.stringify}}
    io << ":0x"
    pointer.address.to_s 16, io
    if closure?
      io << ":closure"
    end
    io << ">"
    nil
  end
end
