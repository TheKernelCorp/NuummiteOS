SERIAL_PORT_0 = 0x03F8_u16
SERIAL_PORT_1 = 0x02F8_u16
SERIAL_PORT_2 = 0x03E8_u16
SERIAL_PORT_3 = 0x02E8_u16

class SerialDevice < Device
  def initialize(@port : UInt16, name : String)
    super(name, DeviceType::CharDevice)
    outb @port + 0x01_u16, 0x00_u8
    outb @port + 0x03_u16, 0x80_u8
    outb @port + 0x00_u16, 0x03_u8
    outb @port + 0x01_u16, 0x00_u8
    outb @port + 0x03_u16, 0x03_u8
    outb @port + 0x02_u16, 0xC7_u8
    outb @port + 0x04_u16, 0x03_u8
  end

  def write_byte(b : UInt8)
    await_ready_state
    outb @port, b
  end

  def read_byte : UInt8
    raise "Reading is not supported for this device"
  end

  def ioctl(code : Enum, data)
  end

  private def await_ready_state
    while inb(@port + 0x05) & 0x20 == 0
    end
  end
end
