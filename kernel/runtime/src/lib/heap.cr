{% if flag?(:x86_64) %}
  # A magic number used in the `BlockHeader`.
  private MAGIC = USize.new(0x22A33ADD44C66CBB_u64)
{% else %}
  # A magic number used in the `BlockHeader`.
  private MAGIC = USize.new(0x22A33ADD_u32)
{% end %}

private alias Block = LibHeap::Block
private alias BlockHeader = LibHeap::BlockHeader

private lib LibHeap

  # Block header.
  #
  # Stores basic information about the block,
  # including its size and connection to other blocks.
  #
  # NOTE: On 32-bit platforms the header size is 12 bytes.
  # NOTE: On 64-bit platforms the header size is 24 bytes.
  @[Packed]
  struct BlockHeader
    # A magic field used to verify the integrity of the block.
    #
    # NOTE: Always equal to `MAGIC`.
    magic : USize

    # The physical size of the block, including the header.
    size : USize

    # The next block in the list.
    next_block : Block*
  end

  # Block.
  #
  # NOTE: On 32-bit platforms the block size is 16 bytes.
  # NOTE: On 64-bit platforms the block size is 32 bytes.
  @[Packed]
  struct Block
    # The block header.
    header : BlockHeader

    # The usable memory of the block.
    entry : UInt8*
  end
end

# Heap allocator.
module Heap
  extend self

  # The start address.
  @@maddr : USize = USize.new 0
  # The absolute memory limit.
  @@limit : USize = USize.new 0
  # The initialized flag.
  @@initialized : Bool = false

  # Initializes the heap.
  #
  # The allocatable memory starts at _maddr_ and ends at _limit_.
  #
  # If no limit is supplied, the amount of allocatable memory
  # will only be limited by the platform integer width.
  def init(maddr : USize, limit : USize = USize.new(0))
    @@maddr = maddr
    if limit == 0
      @@limit = (USize.new(1) << (sizeof(USize) * 8)) - 1 
    else
      @@limit = maddr + limit
    end
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
