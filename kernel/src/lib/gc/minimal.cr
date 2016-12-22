# Skeleton:
# https://github.com/crystal-lang/crystal/blob/master/src/gc/null.cr

require "../heap"
require "../panic"

fun __crystal_malloc(size : UInt32) : Void*
    block = Heap.kalloc(size).as Void*
    panic if block.null?
    block
end

fun __crystal_malloc_atomic(size : UInt32) : Void*
    block = Heap.kalloc(size).as Void*
    panic if block.null?
    block
end

# TODO: Implement
fun __crystal_realloc(size : UInt32) : Void*
    panic
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
        panic
    end

    def self.add_finalizer(object)
    end
end