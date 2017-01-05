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
  @@heap : Heap = Heap.new 0_u32
  @@instance = Pointer(Heap).null
  @used_bytes_sys : UInt32
  @used_bytes_real : UInt32

  def self.init(end_of_kernel : USize)
    @@heap = Heap.new end_of_kernel
    @@instance = pointerof(@@heap)
  end

  def initialize(end_of_kernel : USize)
    addr = Pointer(UInt8).new align(end_of_kernel).to_u64
    @used_top = Pointer(Block).null
    @free_top = Pointer(Block).null
    @free_addr = addr.as UInt8*
    @used_bytes_sys = 0_u32
    @used_bytes_real = 0_u32
  end

  def self.size_sys
    instance = @@instance.value
    instance.@used_bytes_sys
  end

  def self.size_real
    instance = @@instance.value
    instance.@used_bytes_real
  end

  def self.calloc(size : USize) : UInt8*
    instance = @@instance
    raise "Unable to calloc memory" unless instance
    instance.value.calloc size
  end

  def self.kalloc(size : USize) : UInt8*
    instance = @@instance
    raise "Unable to kalloc memory" unless instance
    instance.value.kalloc size
  end

  def self.free(ptr : _*, __file__ = __FILE__, __line__ = __LINE__)
    instance = @@instance
    raise "Unable to free memory" unless instance
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
    raise "Unable to obtain heap address" unless instance
    instance.value.@free_addr.address.to_u32
  end

  def calloc(size : USize) : UInt8*
    block = alloc size
    raise "Unable to calloc memory" unless block
    chunk = block.value.block_chunk.to_void_ptr
    memset chunk, 0_u8, block.value.block_size
    block.value.block_chunk
  end

  def kalloc(size : USize) : UInt8*
    block = alloc size
    raise "Unable to kalloc memory" unless block
    block.value.block_chunk
  end

  private def alloc(size : USize) : Block*
    new_block = get_or_alloc_block size
    raise "Unable to alloc memory" unless new_block
    new_block.value.block_next = @used_top
    @used_top = new_block
    new_block
  end

  private def get_or_alloc_block(size : USize) : Block* | Nil
    block = get_block size
    unless block
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
    free_addr += 1
    (free_addr + (size / sizeof(UInt32)) + 1).value = GUARD2
    @free_addr += aligned
    @used_bytes_sys += guard_size + size # ignore alignment for now
    @used_bytes_real += size
    free_addr.as UInt8*
  end

  def realloc(ptr : _*, size : USize) : UInt8*
    tmp = ptr
    block_size = get_block_size tmp
    return Pointer(UInt8).null if block_size == 0
    free tmp
    new_ptr = kalloc size
    memcpy new_ptr.to_void_ptr, tmp.to_void_ptr, block_size
    new_ptr
  end

  def free(ptr : _*, __file__ = __FILE__, __line__ = __LINE__)
    i = @used_top
    p = i
    while i
      if i.value.block_chunk == ptr
        block = i.value.block_chunk.as UInt32*
        unless (block - 1).value == GUARD1
          panic "Heap corruption: Failed to validate GUARD 1."
        end
        unless (block + (i.value.block_size / sizeof(UInt32)) + 1).value == GUARD2
          panic "Heap corruption: Failed to validate GUARD 2."
        end
        @used_bytes_sys -= i.value.block_size + (sizeof(UInt32) * 2) # ignore alignment for now
        @used_bytes_real -= i.value.block_size
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
    p = i
    while i
      if i.value.block_size <= size
        if p == i
          @free_top = i.value.block_next
        else
          p.value.block_next = i.value.block_next
        end
        return i
      end
      p = i
      i = i.value.block_next
    end
  end

  private def get_block_size(ptr : _*) : USize
    ptr = ptr.to_void_ptr
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
      heap_guard_integrity,
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
    ptr_b = HeapAllocator(UInt8).kalloc
    assert_not_eq ptr_a, ptr_b
    # This still breaks stuff
    # Heap.free ptr_a
    # Heap.free ptr_b
  end

  test heap_guard_integrity, "Heap/guard_integrity", begin
    panic_on_fail!
    ptr_a = HeapAllocator(UInt32).kalloc
    ptr_a.value = 0xFFFFFFFF_u32
    ptr_b = HeapAllocator(UInt32).kalloc
    ptr_b.value = 0xFFFFFFFF_u32
    assert_eq GUARD1, (ptr_a - 1).value
    assert_eq GUARD1, (ptr_b - 1).value
    assert_eq GUARD2, (ptr_a + 2).value
    assert_eq GUARD2, (ptr_b + 2).value
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
    addr_a = ptr.address
    ptr.value = 123_u8
    ptr = HeapAllocator(UInt16).realloc ptr
    assert ptr
    addr_b = ptr.address
    assert_eq 123_u16, ptr.value
    assert_eq addr_a, addr_b
    Heap.free ptr
  end
end
