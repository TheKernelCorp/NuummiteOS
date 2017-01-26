fun __crystal_personality : NoReturn
  panic
end

@[Raises]
fun __crystal_raise : NoReturn
  panic
end

fun __crystal_raise_string : NoReturn
  panic
end

def raise(__file__ = __FILE__, __line__ = __LINE__) : NoReturn
  panic __file__, __line__
end

def raise(message : String, __file__ = __FILE__, __line__ = __LINE__) : NoReturn
  panic message, __file__, __line__
end

def raise(ex : Exception, __file__ = __FILE__, __line__ = __LINE__) : NoReturn
  panic ex.message, __file__, __line__
end

# Initiates a kernel panic.
# TODO: Implement this properly
def panic(message : String = "KERNEL PANIC", __file__ = __FILE__, __line__ = __LINE__) : NoReturn
  # Disable interrupts and halt
  asm("cli; hlt")
  while true
    # Halt on NMI
    asm("hlt")
  end
end
