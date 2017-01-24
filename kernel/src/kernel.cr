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
  Heap.init info.end_of_kernel
  GDT.setup
  PIC.remap
  PIC.enable
  IDT.setup
  Paging.setup
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
  IDT.add_handler 0, ->{
    PIT.tick
    Scheduler.update
    # Async::Timeout.update
    nil
  }
  IDT.add_handler 1, ->Keyboard.handle_keypress
end

fun kmain
  # Get down to business
  puts "Hello, world!"
  IDT.enable_interrupts
  Scheduler.schedule Task.new (->ktrdmain).pointer.address.to_u32
  Scheduler.enable
  while true; end
end

def ktrdmain
  puts "Hello from the other side!"
  shell = NuumShell.new
  shell.run
  while true; end
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
