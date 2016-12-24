private ALIGN = 8_u32
private GUARD1 = 0x4E69636F_u32
private GUARD2 = 0x42697574_u32

private alias Block = LibHeap::Block

struct HeapAllocator(T)
  def self.calloc : Pointer(T)
    Heap.calloc(sizeof(T).to_u32).as Pointer(T)
  end

  def self.kalloc : Pointer(T)
    Heap.kalloc(sizeof(T).to_u32).as Pointer(T)
  end
end

private lib LibHeap
  struct Block
    block_size : USize
    block_next : Pointer(Block)
    block_chunk : Pointer(UInt8)
  end
end

struct Heap
  @@instance = Pointer(Heap).null

  def self.init(end_of_kernel : USize)
    heap = Heap.new end_of_kernel
    @@instance = pointerof(heap)
  end

  def initialize(end_of_kernel : USize)
    addr = Pointer(UInt8).new align(end_of_kernel).to_u64
    @used_top = Pointer(Block).null
    @free_top = Pointer(Block).null
    @free_addr = addr.as Pointer(UInt8)
  end

  def self.calloc(size : USize) : Pointer(UInt8)
    instance = @@instance
    return Pointer(UInt8).null unless instance
    instance.value.calloc size
  end

  def self.kalloc(size : USize) : Pointer(UInt8)
    instance = @@instance
    return Pointer(UInt8).null unless instance
    instance.value.kalloc size
  end
  
  def self.addr() : USize
    instance = @@instance
    return 0u32 unless instance
    instance.value.@free_addr.address.to_u32
  end

  def calloc(size : USize) : Pointer(UInt8)
    block = alloc size
    return Pointer(UInt8).null unless block
    chunk = block.value.block_chunk.as Pointer(Void)
    memset chunk, 0_u8, size
    block.value.block_chunk
  end

  def kalloc(size : USize) : Pointer(UInt8)
    block = alloc size
    return Pointer(UInt8).null unless block
    block.value.block_chunk
  end

  private def alloc(size : USize) : Pointer(Block) | Nil
    new_block = get_or_alloc_block size
    return unless new_block
    new_block.value.block_next = @used_top
    @used_top = new_block
    new_block
  end

  private def get_or_alloc_block(size : USize) : Pointer(Block) | Nil
    block = get_block size
    if get_block(size).is_a? Nil
      block = alloc_block(sizeof(Block).to_u32).as Pointer(Block)
      return unless block
      block.value.block_size = size
      block.value.block_chunk = alloc_block size
    end
    block
  end

  private def alloc_block(size : USize) : Pointer(UInt8)
    guard_size = sizeof(USize) * 2
    aligned = guard_size + align size
    free_addr = @free_addr.as Pointer(USize)
    free_addr[0] = GUARD1
    free_addr[aligned + 4] = GUARD2
    @free_addr += aligned
    @free_addr + (4_i32 - aligned.to_i32)
  end

  private def get_block(size : USize) : Pointer(Block) | Nil
    i = @free_top
    p = @free_top
    while i
      if i.value.block_size > size
        if p == i
          @free_top = i.value.block_next
        else
          i.value.block_next = i.value.block_next
        end
        return i
      end
      p = i
      i = i.value.block_next
    end
  end

  private def align(addr : USize)
    (addr % ALIGN) + addr
  end
end
