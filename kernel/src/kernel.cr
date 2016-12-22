require "./lib/prelude"

fun kmain(mboot_ptr : MultibootPointer)
    Heap.init MultibootHelper.load(mboot_ptr).end_of_kernel
    puts "Hello from Nuummite!"
    run_self_tests
end

def run_self_tests
    puts "Testing kernel integrity..."
    run_tests Tests, [
        heap_calloc,
        heap_kalloc,
    ]
    puts "FYI the kernel is still running."
end

module Tests
    test heap_calloc, "Heap#calloc", begin
        ptr = HeapAllocator(UInt64).calloc
        assert !ptr.null?
        assert_eq ptr.as(Pointer(UInt64)).value, 0_u64
    end

    test heap_kalloc, "Heap#kalloc", begin
        ptr = HeapAllocator(UInt64).calloc
        assert !ptr.null?
    end
end