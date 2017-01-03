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

alias InterruptHandler = StackFrame -> Nil

struct IDT
    @@handlers = uninitialized Array(InterruptHandler)[16]

    def self.setup
        LibGlue.setup_idt
    end

    def self.setup_handlers
        {% for i in 0...16 %}
            @@handlers[{{ i }}] = Array(InterruptHandler).new
        {% end %}
    end

    def self.add_handler(irq : Int, handler : InterruptHandler)
        if irq < 0 || irq > 16
            raise "Invalid IRQ number. Valid: [0..16]"
        end
        @@handlers[irq].push handler
    end

    @[AlwaysInline]
    def self.enable_interrupts
        asm("sti")
    end

    @[AlwaysInline]
    def self.disable_interrupts
        asm("cli")
    end

    def self.handle_isr(frame : LibIDT::StackFrame)
        if frame.intr < 0x20
            self.handle_exception frame
        elsif frame.intr >= 0x20 && frame.intr <= 0x2F
            irq = frame.intr - 0x20
            if @@handlers[irq].size != 0
                i = 0
                while i < @@handlers[irq].size
                    callback = @@handlers[irq][i]
                    callback.call frame
                    i += 1
                end
            end
        else
            raise "Syscalls are not yet unsupported", "(Interrupt)", 0
        end
        PIC.acknowledge frame.intr
    end

    def self.handle_exception(frame : LibIDT::StackFrame)
        if frame.intr < 0x14
            raise EXCEPTION_MESSAGES[frame.intr], "(Interrupt)", 0
        else
            raise "Reserved exception occurred. This is a bug.", "(Interrupt)", 0
        end
        asm("cli; hlt")
    end
end