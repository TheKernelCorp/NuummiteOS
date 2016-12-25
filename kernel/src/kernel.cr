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
end

fun kearly(mboot_ptr : MultibootPointer)
  Heap.init 10_000_000u32
  DeviceManager.init
  run_self_tests
end

fun kmain
  puts "Hello from Nuummite!"
  writeln Serial0, "Hello, world!"
end

def run_self_tests
  puts "Testing kernel integrity..."
  Tests.run
  HeapTests.run
  LinkedListTests.run
  puts "FYI the kernel is still running."
end

module Tests
  def self.run
    run_tests [
      dev_serial
    ]
  end

  test dev_serial, "Device#serial", begin
    serial = DeviceManager.get_device("ttys0")
    assert serial
  end
end
