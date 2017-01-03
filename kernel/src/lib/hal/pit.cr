private PIT_CH0_DATA = 0x40_u16
private PIT_CH1_DATA = 0x41_u16
private PIT_CH2_DATA = 0x42_u16
private PIT_COMMAND = 0x43_u16
private PIT_FREQ = 1193182_u32

struct PIT
  @@ticks = 0_u64
  @@divisor = 0_u32
  @@frequency = 0_u32

  def self.setup(frequency : Int)
    divisor = PIT_FREQ / frequency
    outb PIT_COMMAND, 0x36_u8
    outb PIT_CH0_DATA, divisor.to_u8
    outb PIT_CH0_DATA, (divisor >> 8).to_u8
    @@divisor = divisor
    @@frequency = frequency.to_u32
  end

  def self.tick
    @@ticks += 1
  end

  def self.ticks
    @@ticks
  end

  def self.sleep(ms : Int)
    end_tick_count = @@ticks + ((@@frequency * ms) / 1000)
    while @@ticks < end_tick_count
    end
  end
end
