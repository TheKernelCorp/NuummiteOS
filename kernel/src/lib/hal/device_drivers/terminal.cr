Terminal = TerminalDevice.new

def print(val)
  Terminal.write "#{val}"
end

def puts(val)
  print "#{val}\n"
end

private struct TerminalDevice
  # Constants
  private TAB_SIZE = 4
  private VGA_WIDTH = 80
  private VGA_HEIGHT = 25
  private VGA_SIZE = VGA_WIDTH * VGA_HEIGHT
  private BLANK = ' '.ord.to_u8

  # Initializes the `Terminal`.
  def initialize
    @x = 0
    @y = 0
    @vmem = Pointer(UInt16).new 0xB8000_u64
    @color = TerminalHelper.make_color 0x08_u8, 0x00_u8
  end

  def set_color(fc : UInt8, bc : UInt8)
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
    when 0x08
      attr = TerminalHelper.make_attribute BLANK, @color
      if @y != 0
        @vmem[offset @x, @y] = attr
        case @x
        when 0
          @y -= 1
          @x = VGA_WIDTH - 1
        else @x -= 1
        end
      end
    else
      if @x >= VGA_WIDTH
        newline
      end
      attr = TerminalHelper.make_attribute b, @color
      @vmem[offset @x, @y] = attr
      @x += 1
    end
  end

  # Writes a `String` to the screen.
  def write(str : String)
    str.size.times do |i|
      write_byte pointerof(str.@c)[i]
    end
  end

  # Begins a new line.
  def newline
    @x = 0
    if @y < VGA_HEIGHT - 1
      @y += 1
    else
      scroll
    end
  end

  # Clears the screen.
  def clear
    attr = TerminalHelper.make_attribute BLANK, @color
    VGA_SIZE.times { |i| @vmem[i] = attr }
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
