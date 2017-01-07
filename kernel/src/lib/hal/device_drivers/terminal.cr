RESCUE_TERM = TerminalDevice.new("__NU_RESCUE_TTY", true)

def print(val)
  return unless val
  write tty0, "#{val}"
end

def puts(val = nil)
  if val.is_a? Nil
    write tty0, "\r\n"
  else
    write tty0, "#{val}\r\n"
  end
end

class TerminalDevice < Device
  # I/O Control
  enum IOControl : UInt32
    # Get color
    # Data: UInt8*
    COLOR_GET = 1 << 1
    # Set color
    # Data : UInt8
    COLOR_SET = COLOR_GET | 1
    # Get cursor status
    # Data : Bool*
    CURSOR_GET_STATUS = 1 << 2
    # Set cursor status
    # Data : Bool
    CURSOR_SET_STATUS = CURSOR_GET_STATUS | 1
  end

  # Constants
  private TAB_SIZE = 4
  private VGA_WIDTH = 80
  private VGA_HEIGHT = 25
  private VGA_SIZE = VGA_WIDTH * VGA_HEIGHT
  private BLANK = ' '.ord.to_u8

  # Initializes the `Terminal`.
  def initialize(name : String, rescue_term = false)
    fc, bc = { 0x8_u8, 0x0_u8 }
    @use_cursor = true
    if rescue_term
      @name = name
      @type = DeviceType::CharDevice
      disable_cursor
      fc = 0xC_u8
    else
      super(name, DeviceType::CharDevice)
    end
    @x = 0
    @y = 0
    @vmem = Pointer(UInt16).new 0xB8000_u64
    @color = TerminalHelper.make_color fc, bc
  end

  # Writes an `UInt8` to the screen.
  def write_byte(b : UInt8)
    case b
    when '\r'.ord; @x = 0
    when '\n'.ord; newline
    when '\t'.ord
      spaces = TAB_SIZE - (@x % TAB_SIZE)
      spaces.times { write_byte BLANK }
    when 0x08 # backspace
      if @x == 0
        @y = @y > 0 ? @y - 1 : 0
        @x = VGA_WIDTH - 1
      else
        @x -= 1
      end
      attr = TerminalHelper.make_attribute BLANK, @color
      @vmem[offset @x, @y] = attr
    else
      attr = TerminalHelper.make_attribute b, @color
      @vmem[offset @x, @y] = attr
      @x += 1
    end
    if @x >= VGA_WIDTH
      newline
    end
    update_cursor @x, @y
  end

  def read_byte : UInt8
    raise "Reading is not supported for this device"
  end

  def ioctl(code : Enum, data = nil)
    case code
    when IOControl::COLOR_GET
      raise "Invalid data" unless data.is_a? Int8*
      data.value = @color
    when IOControl::COLOR_SET
      raise "Invalid data" unless data.is_a? Int
      @color = data.to_u8
    when IOControl::CURSOR_GET_STATUS
      raise "Invalid data" unless data.is_a? Bool*
      data.value = @use_cursor
    when IOControl::CURSOR_SET_STATUS
      raise "Invalid data" unless data.is_a? Bool
      data ? enable_cursor : disable_cursor
    end
  end

  # Begins a new line.
  private def newline
    @x = 0
    if @y < VGA_HEIGHT - 1
      @y += 1
    else
      scroll
    end
  end

  # Clears the screen.
  private def clear
    attr = TerminalHelper.make_attribute BLANK, @color
    VGA_SIZE.times { |i| @vmem[i] = attr }
  end

  # Disables the hardware cursor.
  private def disable_cursor
    update_cursor 0, VGA_HEIGHT + 1
    @use_cursor = false
  end

  # Enables the hardware cursor.
  private def enable_cursor
    @use_cursor = true
    update_cursor @x, @y
  end

  private def update_cursor(x : Int, y : Int)
    return unless @use_cursor
    pos = offset x, y
    outb 0x3D4_u16, 0x0F_u8
    outb 0x3D5_u16, pos.to_u8
    outb 0x3D4_u16, 0x0E_u8
    outb 0x3D5_u16, (pos >> 8).to_u8
  end

  # Scrolls the terminal.
  private def scroll
    attr = TerminalHelper.make_attribute BLANK, @color
    VGA_HEIGHT.times do |y|
      VGA_WIDTH.times do |x|
        @vmem[offset x, y] = @vmem[offset x, y + 1]
      end
    end
    VGA_WIDTH.times do |x|
      @vmem[VGA_SIZE - VGA_WIDTH + x] = attr
    end
  end

  # Calculates an offset into the video memory.
  private def offset(x : Int, y : Int)
    y * VGA_WIDTH + x
  end
end

private struct TerminalHelper
  def self.make_color(fc : UInt8, bc : UInt8) : UInt8
    bc << 4 | fc
  end

  def self.make_attribute(ord : Int, color : UInt8) : UInt16
    color.to_u16 << 8 | ord
  end
end
