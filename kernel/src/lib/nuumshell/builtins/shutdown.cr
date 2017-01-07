module Builtins
  extend self

  def shutdown(args : Array(String))
    puts "It's now safe to turn off the computer."
    asm("cli; hlt")
  end
end
