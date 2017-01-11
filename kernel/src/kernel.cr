lib LibBootstrap
  @[Packed]
  struct EarlyInfo
    end_of_kernel : UInt32
    mboot_ptr : MultibootPointer
  end
end

require "./lib/nuumshell/shell"
require "./lib/prelude"

fun kearly(info : LibBootstrap::EarlyInfo)
  # The following code breaks stuff
  GDT.setup
  PIC.remap
  PIC.enable
  IDT.setup
  Heap.init info.end_of_kernel
  IDT.post_heap_setup
  PIT.setup 100
  Keyboard.init
  init_devices
  run_self_tests
  install_irq_handlers
  write ttys0, String.new(Pointer(UInt8).new(info.mboot_ptr.value.cmdline.to_u64))
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
