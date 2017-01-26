# Skeleton:
# https://github.com/crystal-lang/crystal/blob/master/src/gc/null.cr

# Allocates memory.
# TODO: Implement this properly.
fun __crystal_malloc(size : UInt32) : Void*
  # Heap.kalloc(size).to_void_ptr
  Pointer(Void).null
end

# Allocates memory in a thread-safe way.
# TODO: Implement this properly.
fun __crystal_malloc_atomic(size : UInt32) : Void*
  # Heap.kalloc(size).to_void_ptr
  Pointer(Void).null
end

# Reallocates memory.
# TODO: Implement this properly.
fun __crystal_realloc(ptr : Void*, size : UInt32) : Void*
  # Heap.realloc(ptr, size).to_void_ptr
  Pointer(Void).null
end

module GC
  def self.init
  end

  def self.collect
  end

  def self.enable
  end

  def self.disable
  end

  def self.free(pointer : Void*)
    raise "GC.free is not yet supported"
  end

  def self.add_finalizer(object)
  end
end
