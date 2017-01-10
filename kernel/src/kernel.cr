lib LibBootstrap
  $end_of_kernel = END_OF_KERNEL : Pointer(UInt8)
end

require "./lib/nuumshell/shell"
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
  write ttys0, String.new(Pointer(UInt8).new(mboot_ptr.value.cmdline.to_u64))
end

def init_devices
  TerminalDevice.new "tty0"
  SerialDevice.new SERIAL_PORT_0, "ttys0"
  SerialDevice.new SERIAL_PORT_1, "ttys1"
  SerialDevice.new SERIAL_PORT_2, "ttys2"
  SerialDevice.new SERIAL_PORT_3, "ttys3"
end

def install_irq_handlers
  IDT.add_handler 0, ->PIT.tick
  IDT.add_handler 0, ->Async::Timeout.update
  IDT.add_handler 1, ->Keyboard.handle_keypress
end

fun kmain
  # Get down to business
  IDT.enable_interrupts
  shell = NuumShell.new
  shell.run
end

def run_self_tests
  HeapTests.run
  ArrayTests.run
  DequeTests.run
  LinkedListTests.run
  StaticArrayTests.run
  KeyboardTests.run
  StringTests.run
end
