struct Enum
  def +(other : Int)
    self.class.new value + other
  end

  def -(other : Int)
    self.class.new value - other
  end

  def |(other : self)
    self.class.new value | other.value
  end

  def &(other : self)
    self.class.new value & other.value
  end

  def ^(other : self)
    self.class.new value ^ other.value
  end

  def ~
    self.class.new ~value
  end

  def <=>(other : self)
    value <=> other.value
  end

  def ==(other)
    false
  end

  def ==(other : self)
    value == other.value
  end

  def includes?(other : self)
    (value & other.value) != 0
  end

  def hash
    value.hash
  end

  macro flags(*values)
    {% for value, i in values %}\
      {% if i != 0 %} | {% end %}\
      {{ @type }}::{{ value }}{% end %}\
  end
end
