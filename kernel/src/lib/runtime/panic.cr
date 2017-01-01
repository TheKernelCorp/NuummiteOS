def panic(file = __FILE__, line = __LINE__) : NoReturn
  puts "*** KERNEL PANIC"
  panic_print_debug_information file, line
  panic_halt_system
end

def panic(message : String, file = __FILE__, line = __LINE__) : NoReturn
  print "*** KERNEL PANIC: "
  puts message
  panic_print_debug_information file, line
  panic_halt_system
end

private def panic_print_debug_information(file, line)
  print "*** File: "
  puts file
  print "*** Line: "
  puts line
end

private macro panic_halt_system
  asm("cli; hlt")
  while true; end
end