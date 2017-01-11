# Assembly -> Nuummite

fun glue_handle_isr(frame : LibIDT::StackFrame*)
  IDT.handle_isr frame.value
end

# Nuummite -> Assembly

lib LibGlue
  fun setup_gdt = "glue_setup_gdt"
  fun setup_idt = "glue_setup_idt"
  fun setup_paging = "glue_setup_paging"
end

# Crystal runtime glue

fun memset(ptr : Void*, val : UInt8, count : UInt32)
  LibC.memset ptr, val, count
end
