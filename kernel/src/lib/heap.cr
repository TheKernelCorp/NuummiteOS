private ALIGN = 8_u32
private GUARD1 = 0x4E69636F_u32
private GUARD2 = 0x42697574_u32

private alias Block = LibHeap::Block

struct HeapAllocator(T)
  def self.calloc : T*
    Heap.calloc(sizeof(T).to_u32).as T*
  end

  def self.kalloc : T*
    Heap.kalloc(sizeof(T).to_u32).as T*
  end

  def self.realloc(ptr : T*, size : USize) : T*
    Heap.realloc(ptr, size).as T*
  end

  def self.realloc(ptr : _*) : T*
    Heap.realloc(ptr, sizeof(T).to_u32).as T*
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

  def self.free(ptr : _*, __file__ = __FILE__, __line__ = __LINE__)
    instance = @@instance
    return unless instance
    instance.value.free ptr, __file__, __line__
  end

  def self.realloc(ptr : _*, size : USize) : UInt8*
    instance = @@instance
    return Pointer(UInt8).null unless instance
    new_ptr = instance.value.realloc ptr, size
    return Pointer(UInt8).null unless new_ptr
    new_ptr
  end

  def self.addr : USize
    instance = @@instance
    return 0u32 unless instance
    instance.value.@free_addr.address.to_u32
  end

  def calloc(size : USize) : UInt8*
    block = alloc size
    return Pointer(UInt8).null unless block
    chunk = block.value.block_chunk.to_void_ptr
    memset chunk, 0_u8, block.value.block_size
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
    if !block
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

  def realloc(ptr : _*, size : USize) : UInt8*
    block_size = get_block_size ptr
    return Pointer(UInt8).null if block_size == 0
    free ptr
    new_ptr = kalloc size
    memcpy new_ptr.to_void_ptr, ptr.to_void_ptr, block_size
    new_ptr
  end

  def free(ptr : _*, __file__ = __FILE__, __line__ = __LINE__)
    i = @used_top
    p = i
    while i
      if i.value.block_chunk == ptr
        block = i.value.block_chunk.as UInt32*
        unless (block - 1).value == GUARD1 && (block + (i.value.block_size / 4) + 4).value == GUARD2
          panic "Heap corruption!", __file__, __line__
        end
        if p == i
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
      if i.value.block_size <= size
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

  private def get_block_size(ptr : UInt8*) : USize
    i = @used_top
    while i
      chunk = i.value.block_chunk
      if chunk == ptr
        return i.value.block_size
      end
      i = i.value.block_next
    end
    0_u32
  end

  private def align(addr : USize) : USize
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
      heap_free_alloc,
      heap_realloc,
    ]
  end
  
  test heap_calloc, "Heap#calloc", begin
    panic_on_fail!
    ptr = HeapAllocator(UInt8).calloc
    assert ptr
    assert_eq 0_u64, ptr.value
    Heap.free ptr
  end

  test heap_kalloc, "Heap#kalloc", begin
    panic_on_fail!
    ptr = HeapAllocator(UInt8).kalloc
    assert ptr
    Heap.free ptr
  end

  test heap_kalloc_diff, "Heap#kalloc/diversity", begin
    panic_on_fail!
    ptr_a = HeapAllocator(UInt8).kalloc
    assert ptr_a
    addr_a = Heap.addr
    ptr_b = HeapAllocator(UInt8).kalloc
    assert ptr_b
    addr_b = Heap.addr
    assert_not_eq addr_a, addr_b
    assert_not_eq ptr_a, ptr_b
    # This corrupts the heap
    # Heap.free ptr_a
    # Heap.free ptr_b
  end

  test heap_free, "Heap#free", begin
    panic_on_fail!
    ptr = HeapAllocator(UInt8).kalloc
    assert ptr
    addr_a = ptr.address
    Heap.free ptr
    ptr = HeapAllocator(UInt8).kalloc
    assert ptr
    addr_b = ptr.address
    assert_eq addr_a, addr_b
    Heap.free ptr
  end

  test heap_free_alloc, "Heap#free/alloc", begin
    panic_on_fail!
    ptr_a = HeapAllocator(UInt8).kalloc
    Heap.free ptr_a
    ptr_b = HeapAllocator(UInt8).kalloc
    Heap.free ptr_b
    assert_eq ptr_a, ptr_b
  end

  test heap_realloc, "Heap#realloc", begin
    panic_on_fail!
    ptr = HeapAllocator(UInt8).kalloc
    assert ptr
    ptr.value = 123_u8
    ptr = HeapAllocator(UInt16).realloc ptr
    assert ptr
    assert_eq 123_u16, ptr.value
    Heap.free ptr
  end
end