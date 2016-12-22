class Class
  def hash
    crystal_type_id
  end

  def ==(other : Class)
    crystal_type_id == other.crystal_type_id
  end

  def ===(other)
    other.is_a? self
  end

  def name : String
    {{ @type.name.stringify }}
  end

  def cast(other) : self
    other.as self
  end

  def self.|(other : U.class) forall U
    t = uninitialized self
    u = uninitialized U
    typeof(t, u)
  end

  def nilable?
    self == ::Nil
  end

  def to_s(io)
    io << name
  end

  def dup
    self
  end

  def clone
    self
  end
end