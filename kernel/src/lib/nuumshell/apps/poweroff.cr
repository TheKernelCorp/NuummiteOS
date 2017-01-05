class Power
  def self.off
    puts "It's now safe to turn off the computer."
    asm("cli; hlt")
  end
end
