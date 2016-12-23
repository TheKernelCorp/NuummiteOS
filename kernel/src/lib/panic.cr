def panic(file = __FILE__, line = __LINE__) : NoReturn
  puts "*** KERNEL PANIC"
  print "*** File: "
  puts file
  asm("cli")
  asm("hlt")
  while true; end
end
