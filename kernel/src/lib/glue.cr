# Assembly -> Nuummite

fun glue_handle_isr(frame : LibIDT::StackFrame*)
  IDT.handle_isr frame.value
end

# Nuummite -> Assembly

lib LibGlue
  fun flush_gdt = "glue_flush_gdt"
  fun setup_idt = "glue_setup_idt"
end

# Crystal runtime glue

fun memset(ptr : Void*, val : UInt8, count : UInt32)
  LibC.memset ptr, val, count
end
