private EXCEPTION_MESSAGES = StaticArray [
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

lib LibIDT
    @[Packed]
    struct StackFrame
        gs, fs, es, ds : UInt32
        edi, esi, ebp, esp, ebx, edx, ecx, eax : UInt32
        intr, error : UInt32
        eip, cs, eflags, useresp, ss : UInt32
    end
end

alias InterruptHandler = LibIDT::StackFrame* -> Nil

struct IDT
    def self.setup
        LibGlue.setup_idt
    end

    @[AlwaysInline]
    def self.enable_interrupts
        asm("sti")
    end

    @[AlwaysInline]
    def self.disable_interrupts
    end

    def self.handle_isr(frame : LibIDT::StackFrame*)
        if frame.value.intr < 0x20
            self.handle_exception frame
        end
        PIC.acknowledge frame.value.intr
    end

    def self.handle_exception(frame : LibIDT::StackFrame*)
        frame = frame.value
        if frame.intr < 0x14
            raise EXCEPTION_MESSAGES[frame.intr], "(Interrupt)", 0
        else
            raise "Reserved exception occurred. This is a bug.", "(Interrupt)", 0
        end
        asm("cli; hlt")
    end
end