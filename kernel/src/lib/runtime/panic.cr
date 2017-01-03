def panic(__file__ = __FILE__, __line__ = __LINE__) : NoReturn
  panic "No further information available.", __file__, __line__
end

def panic(message : String, __file__ = __FILE__, __line__ = __LINE__) : NoReturn
  print "*** KERNEL PANIC: "
  puts message
  panic_print_debug_information __file__, __line__
  panic_halt_system
end

private def panic_print_debug_information(__file__, __line__)
  print "*** File: "
  puts __file__
  print "*** Line: "
  puts __line__
end

private macro panic_halt_system
  asm("cli; hlt")
  while true; end
end
