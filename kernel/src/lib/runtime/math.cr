module Math
  extend self

  def min(value1, value2)
    value1 <= value2 ? value1 : value2
  end

  def max(value1, value2)
    value1 >= value2 ? value1 : value2
  end

  # Computes the next highest power of 2 of *v*
  def pw2ceil(v)
    # Taken from http://graphics.stanford.edu/~seander/bithacks.html#RoundUpPowerOf2
    v -= 1
    v |= v >> 0x01
    v |= v >> 0x02
    v |= v >> 0x04
    v |= v >> 0x08
    v |= v >> 0x10
    v += 1
  end
end
