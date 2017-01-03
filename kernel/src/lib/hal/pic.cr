# General
private PIC_EOI = 0x20_u8

# Masking
private PIC_UNMASK = 0x00_u8
private PIC_MASK = 0xFF_u8

# PIC 1 (Master)
private PIC_MASTER_COMMAND = 0x20_u16
private PIC_MASTER_DATA = 0x21_u16

# PIC 2 (Slave)
private PIC_SLAVE_COMMAND = 0xA0_u16
private PIC_SLAVE_DATA = 0xA1_u16

# ICW 1
private PIC_ICW1_ICW4 = 0x01_u8
private PIC_ICW1_SINGLE = 0x02_u8
private PIC_ICW1_INTERVAL4 = 0x04_u8
private PIC_ICW1_LEVEL = 0x08_u8
private PIC_ICW1_INIT = 0x10_u8

# ICW 2
private PIC_ICW2_MASTER_OFF = 0x20_u8
private PIC_ICW2_SLAVE_OFF = 0x28_u8

# ICW 3
private PIC_ICW3_CASCADE = 0x02_u8
private PIC_ICW3_IRQ2_SLAVE = 0x04_u8

# ICW 4
private PIC_ICW4_8086 = 0x01_u8
private PIC_ICW4_AUTO = 0x02_u8
private PIC_ICW4_BUF_SLAVE = 0x08_u8
private PIC_ICW4_BUF_MASTER = 0x0C_u8
private PIC_ICW4_SFNM = 0x10_u8

struct PIC
  def self.acknowledge(intr : UInt32)
    if intr >= 0x08
      outb PIC_SLAVE_COMMAND, PIC_EOI
    end
    outb PIC_MASTER_COMMAND, PIC_EOI
  end

  def self.enable
    outb PIC_MASTER_DATA, PIC_UNMASK
    outb PIC_SLAVE_DATA, PIC_UNMASK
  end

  def self.disable
    outb PIC_MASTER_DATA, PIC_MASK
    outb PIC_SLAVE_DATA, PIC_UNMASK
  end

  def self.remap
    self.remap_master
    self.remap_slave
  end

  def self.remap_master
    outb PIC_MASTER_COMMAND, PIC_ICW1_INIT | PIC_ICW1_ICW4
    outb PIC_MASTER_DATA, PIC_ICW2_MASTER_OFF
    outb PIC_MASTER_DATA, PIC_ICW3_IRQ2_SLAVE
    outb PIC_MASTER_DATA, PIC_ICW4_8086
  end

  def self.remap_slave
    outb PIC_SLAVE_COMMAND, PIC_ICW1_INIT | PIC_ICW1_ICW4
    outb PIC_SLAVE_DATA, PIC_ICW2_SLAVE_OFF
    outb PIC_SLAVE_DATA, PIC_ICW3_CASCADE
    outb PIC_SLAVE_DATA, PIC_ICW4_8086
  end
end
