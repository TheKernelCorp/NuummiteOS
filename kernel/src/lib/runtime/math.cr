module Math
  extend self

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
