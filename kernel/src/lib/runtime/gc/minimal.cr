# Skeleton:
# https://github.com/crystal-lang/crystal/blob/master/src/gc/null.cr

fun __crystal_malloc(size : UInt32) : Void*
  block = Heap.kalloc(size).as Void*
  raise "Allocated pointer is zero" unless block
  block
end

fun __crystal_malloc_atomic(size : UInt32) : Void*
  __crystal_malloc size
end

# TODO: Implement
fun __crystal_realloc(size : UInt32) : Void*
  raise "__crystal_realloc is not yet supported"
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

  # TODO: Implement
  def self.free(pointer : Void*)
    raise "GC.free is not yet supported"
  end

  def self.add_finalizer(object)
  end
end
