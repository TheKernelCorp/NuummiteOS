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
    @free_addr = addr.as UInt8*
  end

  def self.calloc(size : USize) : UInt8*
    instance = @@instance
    return Pointer(UInt8).null unless instance
    instance.value.calloc size
  end

  def self.kalloc(size : USize) : UInt8*
    instance = @@instance
    return Pointer(UInt8).null unless instance
    instance.value.kalloc size
  end
  
  def self.addr() : USize
    instance = @@instance
    return 0u32 unless instance
    instance.value.@free_addr.address.to_u32
  end

  def self.free(ptr : Pointer(_))
    instance = @@instance
    return unless instance
    instance.value.free ptr
  end

  def calloc(size : USize) : UInt8*
    block = alloc size
    return Pointer(UInt8).null unless block
    chunk = block.value.block_chunk.as Void*
    memset chunk, 0_u8, size
    block.value.block_chunk
  end

  def kalloc(size : USize) : UInt8*
    block = alloc size
    return Pointer(UInt8).null unless block
    block.value.block_chunk
  end

  private def alloc(size : USize) : Block* | Nil
    new_block = get_or_alloc_block size
    return unless new_block
    new_block.value.block_next = @used_top
    @used_top = new_block
    new_block
  end

  private def get_or_alloc_block(size : USize) : Block* | Nil
    block = get_block size
    if get_block(size).is_a? Nil
      block = alloc_block(sizeof(Block).to_u32).as Block*
      return unless block
      block.value.block_size = size
      block.value.block_chunk = alloc_block size
    end
    block
  end

  private def alloc_block(size : USize) : UInt8*
    guard_size = sizeof(UInt32) * 2
    aligned = guard_size + align size
    free_addr = @free_addr.as UInt32*
    free_addr.value = GUARD1
    (free_addr + size + sizeof(UInt32)).value = GUARD2
    ptr = @free_addr + sizeof(UInt32)
    @free_addr += aligned
    ptr
  end

  def free(ptr : Pointer(_))
    i = @used_top
    p = i
    until i.is_a?(Nil) || i.null?
      if i.value.block_chunk.address == ptr.address
        # block = i.value.block_chunk.as UInt32*
        # unless (block - 4).value == GUARD1 && (block + i.value.block_size).value == GUARD2
        #   panic "Heap corruption!"
        # end
        if p.address == i.address
          @used_top = i.value.block_next
        else
          p.value.block_next = i.value.block_next
        end
        i.value.block_next = @free_top
        @free_top = i
      end
      p = i
      i = i.value.block_next
    end
  end

  private def get_block(size : USize) : Block* | Nil
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

module HeapTests
  def self.run
    run_tests [
      heap_calloc,
      heap_kalloc,
      heap_kalloc_diff,
      heap_free,
    ]
  end
  
  test heap_calloc, "Heap#calloc", begin
    panic_on_fail!
    ptr = HeapAllocator(UInt8).calloc
    assert ptr
    assert_not ptr.null?
    assert_eq 0_u64, ptr.value
  end

  test heap_kalloc, "Heap#kalloc", begin
    panic_on_fail!
    ptr = HeapAllocator(UInt8).kalloc
    assert ptr
    assert_not ptr.null?
  end

  test heap_kalloc_diff, "Heap#kalloc/diversity", begin
    panic_on_fail!
    ptr_a = HeapAllocator(UInt8).kalloc
    addr_a = Heap.addr
    ptr_b = HeapAllocator(UInt8).kalloc
    addr_b = Heap.addr
    assert_not_eq addr_a, addr_b
    assert_not_eq ptr_a.address, ptr_b.address
  end

  test heap_free, "Heap#free", begin
    panic_on_fail!
    ptr_a = HeapAllocator(UInt8).kalloc
    assert ptr_a
    assert_not ptr_a.null?
    Heap.free ptr_a
  end
end