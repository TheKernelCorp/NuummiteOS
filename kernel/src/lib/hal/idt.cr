private EXCEPTION_MESSAGES = StaticArray[
  "Divide by zero",
  "Reserved",
  "Non maskable interrupt",
  "Breakpoint",
  "Into detected overflow",
  "Bounds range exceeded",
  "Invalid opcode",
  "Device not available",
  "Double fault",
  "Coprocessor segment overrun",
  "Bad TSS",
  "Segment not present",
  "Stack segment fault",
  "General protection fault",
  "Page fault",
  "Reserved",
  "x87 FPU error",
  "Alignment check",
  "Machine check",
  "SIMD floating-point exception",
]

alias StackFrame = LibIDT::StackFrame

lib LibIDT
  @[Packed]
  struct StackFrame
    gs, fs, es, ds : UInt32
    edi, esi, ebp, esp, ebx, edx, ecx, eax : UInt32
    intr, error : UInt32
    eip, cs, eflags, useresp, ss : UInt32
  end
end

alias InterruptHandler = -> Nil
alias ExceptionHandler = LibIDT::StackFrame -> Nil

module IDT
  extend self

  ISR_COUNT = 32
  IRQ_COUNT = 16
  @@isrs = uninitialized ExceptionHandler[ISR_COUNT]
  @@irqs = uninitialized InterruptHandler[IRQ_COUNT]

  def setup
    LibGlue.setup_idt
    {% for i in 0...ISR_COUNT %}
      @@isrs[{{ i }}] = ->handle_exception(LibIDT::StackFrame)
    {% end %}
    {% for i in 0...IRQ_COUNT %}
      @@irqs[{{ i }}] = ->{ nil }
    {% end %}
  end

  def add_handler(irq : Int, handler : InterruptHandler)
    if irq < 0 || irq > 16
      raise "Invalid IRQ number. Valid: [0..16]"
    end
    @@irqs[irq] = handler
  end

  def add_fault_handler(isr : Int, handler : ExceptionHandler)
    if isr < 0 || isr > 31
      raise "Invalid ISR number. Valid: [0..31]"
    end
    @@isrs[isr] = handler
  end

  @[AlwaysInline]
  def enable_interrupts
    asm("sti")
  end

  @[AlwaysInline]
  def disable_interrupts
    asm("cli")
  end

  def handle_isr(frame : LibIDT::StackFrame)
    if frame.intr < 0x20
      @@isrs[frame.intr].call frame
    elsif frame.intr >= 0x20 && frame.intr <= 0x2F
      irq = frame.intr - 0x20
      @@irqs[irq].call
    else
      raise "Syscalls are not yet unsupported", "(Interrupt)", 0
    end
    PIC.acknowledge frame.intr
  end

  def handle_exception(frame : LibIDT::StackFrame)
    if frame.intr < 0x14
      raise EXCEPTION_MESSAGES[frame.intr], "(Interrupt)", 0
    else
      raise "Reserved exception occurred. This is a bug.", "(Interrupt)", 0
    end
    asm("cli; hlt;")
  end

  def halt
    asm("cli; hlt")
    while true
      asm("hlt")
    end
  end
end
