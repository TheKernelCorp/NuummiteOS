require "./lib/prelude"

lib LibBootstrap
  $end_of_kernel = END_OF_KERNEL : UInt32
end

fun kearly(mboot_ptr : MultibootPointer)
  include Dev
  sym = LibBootstrap.end_of_kernel
  end_of_kernel = pointerof(sym)
  puts end_of_kernel.address
  Heap.init end_of_kernel.address.to_u32

fun kearly(mboot_ptr : MultibootPointer)
  Heap.init MultibootHelper.load(mboot_ptr).end_of_kernel
  DeviceManager.init
  run_self_tests
end

fun kmain
  puts "Hello from Nuummite!"
  writeln Serial0, "Hello, world!"
end

def run_self_tests
  puts "Testing kernel integrity..."
  run_tests Tests, [
    heap_calloc,
    heap_kalloc,
    dev_serial,
  ]
  puts "FYI the kernel is still running."
end

module Tests
  test heap_calloc, "Heap#calloc", begin
    ptr = HeapAllocator(UInt64).calloc
    assert_not ptr.null?
    assert_eq ptr.value, 0_u64
  end

  test heap_kalloc, "Heap#kalloc", begin
    ptr = HeapAllocator(UInt64).kalloc
    assert_not ptr.null?
  end

  test dev_serial, "Device#serial", begin
    serial = DeviceManager.get_device("ttys0")
    assert_not serial.not_nil!
  end
end
