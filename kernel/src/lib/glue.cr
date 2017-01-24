# Assembly -> Nuummite

fun glue_handle_isr(frame : StackFrame)
  IDT.handle_isr frame
end

# Nuummite -> Assembly

lib LibGlue
  fun setup_idt = "glue_setup_idt"
end

# Crystal runtime glue

fun memset(ptr : Void*, val : UInt8, count : UInt32)
  LibC.memset ptr, val, count
end
