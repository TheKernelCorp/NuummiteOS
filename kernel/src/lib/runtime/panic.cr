def panic(__file__ = __FILE__, __line__ = __LINE__) : NoReturn
  panic "No further information available.", __file__, __line__
end

def panic(message : String, __file__ = __FILE__, __line__ = __LINE__) : NoReturn
  panic_print "*** KERNEL PANIC: "
  panic_puts message
  panic_print_debug_information __file__, __line__
  panic_halt_system
end

private def panic_print_debug_information(__file__, __line__)
  panic_print "*** File: "
  panic_puts __file__
  panic_print "*** Line: "
  panic_puts __line__.to_s
end

private def panic_print(str : String)
  ptr = pointerof(str.@c)
  (0...str.bytesize).each do |i|
    # Write directly to the rescue terminal
    RESCUE_TERM.write_byte ptr[i]
  end
end

private def panic_puts(str : String)
  panic_print str
  panic_print "\n"
end

private macro panic_halt_system
  asm("cli; hlt")
  while true; end
end
