lib LibBootstrap
  $end_of_kernel = END_OF_KERNEL : Pointer(UInt8)
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
  IDT.setup
  PIT.setup 100
  Keyboard.init
  init_devices
  run_self_tests
  install_irq_handlers
end

def init_devices
  SerialDevice.new SERIAL_PORT_0, "ttys0"
  SerialDevice.new SERIAL_PORT_1, "ttys1"
  SerialDevice.new SERIAL_PORT_2, "ttys2"
  SerialDevice.new SERIAL_PORT_3, "ttys3"
end

def install_irq_handlers
  IDT.add_handler 0, -> PIT.tick
  IDT.add_handler 1, -> Keyboard.handle_keypress
end

fun kmain
  print_color_thing
  # Say hello to tty-serial-0
  writeln ttys0, "Hello, world!"
  # Get down to business
  IDT.enable_interrupts
  while true
    # Echo!
    print "kecho> "
    puts "kecho: #{Keyboard.gets}"
  end
end

def print_color_thing
  # The following is a mess
  # But it's a beautiful mess
  print "Hello from "
  Terminal.set_color 0xA_u8, 0x0_u8
  print "N"
  Terminal.set_color 0xB_u8, 0x0_u8
  print "u"
  print "u"
  Terminal.set_color 0xC_u8, 0x0_u8
  print "m"
  print "m"
  Terminal.set_color 0xD_u8, 0x0_u8
  print "i"
  Terminal.set_color 0xE_u8, 0x0_u8
  print "t"
  Terminal.set_color 0xF_u8, 0x0_u8
  print "e"
  Terminal.set_color 0x8_u8, 0x0_u8
  puts "!"
end

def run_self_tests
  puts "Testing kernel integrity..."
  Tests.run
  HeapTests.run
  ArrayTests.run
  DequeTests.run
  LinkedListTests.run
  StaticArrayTests.run
  KeyboardTests.run
  StringTests.run
  puts "FYI the kernel is still running."
end

module Tests
  def self.run
    run_tests [
      dev_serial,
    ]
  end

  test dev_serial, "Device#serial", begin
    serial = DeviceManager.get_device("ttys0")
    assert serial
  end
end
