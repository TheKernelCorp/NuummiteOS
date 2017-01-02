fun glue_handle_isr
    # IDT.handle_isr intr
end

lib LibGlue
    fun setup_gdt = "glue_setup_gdt"
    fun setup_idt = "glue_setup_idt"
end