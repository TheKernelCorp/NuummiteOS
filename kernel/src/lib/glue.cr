fun glue_handle_isr(frame : LibIDT::StackFrame*)
    IDT.handle_isr frame
end

lib LibGlue
    fun setup_gdt = "glue_setup_gdt"
    fun setup_idt = "glue_setup_idt"
end