lib LibBootstrap
  $end_of_kernel = END_OF_KERNEL : UInt32
end

require "./lib/prelude"

fun kearly(mboot_ptr : MultibootPointer)
  # The following code breaks stuff
  # sym = LibBootstrap.end_of_kernel
  # end_of_kernel = pointerof(sym)
  # Heap.init end_of_kernel.address.to_u32
  GDT.setup
  PIC.remap
  PIC.enable
  Heap.init 2_000_000_u32
  init_devices
  run_self_tests
end

def init_devices
  SerialDevice.new SERIAL_PORT_0, "ttys0"
  SerialDevice.new SERIAL_PORT_1, "ttys1"
  SerialDevice.new SERIAL_PORT_2, "ttys2"
  SerialDevice.new SERIAL_PORT_3, "ttys3"
end

fun kmain
  puts "Hello from Nuummite!"
  writeln ttys0, "Hello, world!"
end

def run_self_tests
  puts "Testing kernel integrity..."
  Tests.run
  HeapTests.run
  ArrayTests.run
  LinkedListTests.run
  StaticArrayTests.run
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
