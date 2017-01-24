struct Number
  macro [](*nums)
    Array({{@type}}).build({{nums.size}}) do |%buffer|
      {% for num, i in nums %}
        %buffer[{{i}}] = {{@type}}.new({{num}})
      {% end %}
      {{nums.size}}
    end
  end

  macro slice(*nums)
    %slice = Slice({{@type}}).new({{nums.size}})
    {% for num, i in nums %}
      %slice.to_unsafe[{{i}}] = {{@type}}.new({{num}})
    {% end %}
    %slice
  end

  macro static_array(*nums)
    %array = uninitialized StaticArray({{@type}}, {{nums.size}})
    {% for num, i in nums %}
      %array.to_unsafe[{{i}}] = {{@type}}.new({{num}})
    {% end %}
    %array
  end
  
  def self.zero : self
    new 0
  end

  def +
    self
  end

  def step(*, to = nil, by = 1)
    x = self + (by - by)
    if to
      if by > 0
        while x <= to
          yield x
          x += by
        end
      elsif by < 0
        while x >= to
          yield x
          x += by
        end
      end
    else
      while true
        yield x
        x += by
      end
    end
    self
  end

  def abs
    self < 0 ? -self : self
  end

  def abs2
    self * self
  end

  def sign
    self < 0 ? -1 : (self == 0 ? 0 : 1)
  end

  def divmod(number)
    {(self / number).floor, self % number}
  end

  def <=>(other)
    self > other ? 1 : (self < other ? -1 : 0)
  end

  def round(digits, base = 10)
    x = self.to_f
    y = base ** digits
    self.class.new (x * y).round / y
  end

  def clamp(range : Range)
    raise ArgumentError.new("can't clamp an exclusive range") if range.exclusive?
    clamp range.begin, range.end
  end

  def clamp(min, max)
    return max if self > max
    return min if self < min
    self
  end
end
