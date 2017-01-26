private alias Block = LibHeap::Block

private lib LibHeap
  @[Packed]
  struct Block
    phys_size : USize
  end
end

# Heap allocator.
module Heap
  extend self

  # The start address.
  @@maddr : USize = USize.new(0)
  # The absolute memory limit.
  @@limit : USize = USize.new(0)
  # The initialized flag.
  @@initialized : Bool = false

  # Initializes the heap.
  # The allocatable memory starts at _maddr_ and ends at _limit_.
  #
  # If no limit is supplied, the amount of allocatable memory
  # will only be limited by the platform integer width.
  def init(maddr : USize, limit : USize = 0)
    @@maddr = maddr
    @@limit = limit == 0 ? USize.new(((1 << sizeof(USize)) - 1)) : maddr + limit
    @@initialized = true
  end

  # Tests whether the Heap has been initialized.
  @[AlwaysInline]
  def initialized?
    @@initialized
  end

  # Gets the memory address.
  @[AlwaysInline]
  def memory_address
    @@maddr
  end

  # Gets the absolute memory limit.
  def memory_limit
    @@limit
  end
end
