module Async::Timeout
  extend self

  MAX_TIMEOUTS = 64
  @@list = Deque(TickTimeout).new MAX_TIMEOUTS

  def update
    ticks = PIT.ticks
    mark_list = uninitialized TickTimeout[MAX_TIMEOUTS]
    mark_count = 0
    @@list.each { |elem|
      next if ticks < elem.@end_time
      mark_list[mark_count] = elem
      mark_count += 1
      elem.callback.call
    }
    mark_count.times { |i|
      @@list.delete mark_list[i]
    }
  end

  def register(duration : Int, callback : -> Nil)
    raise "Timeout limit reached!" unless @@list.size < MAX_TIMEOUTS
    @@list.push TickTimeout.new(duration, callback)
  end
end

private struct TickTimeout
  getter duration : UInt64
  getter end_time : UInt64
  getter callback : -> Nil

  def initialize(duration : Int, callback : -> Nil)
    @duration = duration.to_u64
    @end_time = PIT.ticks + ((@duration * PIT.frequency) / 1000)
    @callback = callback
  end

  def hash
    @end_time
  end

  def ==(other : TickTimeout)
    hash == other.hash
  end
end
