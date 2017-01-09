# Power Management
module PM
  extend self

  def reboot
    IDT.disable_interrupts
    loop do
      tmp = inb 0x64_u16
      inb(0x60_u16) unless tmp & 1 == 0
      break unless tmp & 2 == 0
    end
    outb 0x64_u16, 0xFE_u8
    asm("hlt; 1: hlt; jmp 1b")
  end
end
