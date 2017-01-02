struct IDT
    def self.setup
        LibGlue.setup_idt
    end

    def self.handle_isr(intr : UInt32)
        PIC.acknowledge intr
    end
end