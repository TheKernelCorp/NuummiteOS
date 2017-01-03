struct Range(B, E)
  getter begin : B
  getter end : E
  getter exclusive : Bool

  def initialize(@begin : B, @end : E, @exclusive : Bool = false)
  end

  def cycle
    each.cycle
  end

  def each
    current = @begin
    while current < @end
      yield current
      current = current.succ
    end
    yield current if !@exclusive && current == @end
    self
  end
end
