def print(val : String)
  Terminal.write_string val
end

def puts(val : String)
  print val
  print "\r\n"
end

module Terminal
  extend self

  # Constants
  private TAB_SIZE = 4
  private VGA_WIDTH = 80
  private VGA_HEIGHT = 25
  private VGA_SIZE = VGA_WIDTH * VGA_HEIGHT
  private BLANK = ' '.ord.to_u8

  # The video memory.
  @@vmem : UInt16* = Pointer(UInt16).new 0xB8000_u64

  # The color attribute.
  @@color : UInt8 = make_color 0x7_u8, 0x0_u8

  # The column.
  @@x : Int32 = 0

  # The row.
  @@y : Int32 = 0

  # Writes a `String` to the screen.
  def write_string(str : String)
    c = pointerof(str.@c)
    i = 0
    while i < str.@length
      write_byte c[i]
      i += 1
    end
  end

  # Writes an `UInt8` to the screen.
  def write_byte(b : UInt8)
    case b
    when '\r'.ord; @@x = 0
    when '\n'.ord; newline
    when '\t'.ord
      spaces = TAB_SIZE - (@@x % TAB_SIZE)
      spaces.times { write_byte BLANK }
    when 0x08 # backspace
      if @@x == 0
        @@y = @@y > 0 ? @@y - 1 : 0
        @@x = VGA_WIDTH - 1
      else
        @@x -= 1
      end
      attr = make_attribute BLANK, @@color
      @@vmem[offset @@x, @@y] = attr
    else
      attr = make_attribute b, @@color
      @@vmem[offset @@x, @@y] = attr
      @@x += 1
    end
    if @@x >= VGA_WIDTH
      newline
    end
  end

  # Begins a new line.
  private def newline
    @@x = 0
    if @@y < VGA_HEIGHT - 1
      @@y += 1
    else
      scroll
    end
    update_cursor @@x, @@y
  end

  # Clears the screen.
  private def clear
    attr = make_attribute BLANK, @@color
    VGA_SIZE.times { |i| @@vmem[i] = attr }
  end

  # Updates the position of the hardware cursor.
  private def update_cursor(x : Int, y : Int)
    pos = offset x, y
    LibK.outb 0x3D4_u16, 0x0F_u8
    LibK.outb 0x3D5_u16, pos.to_u8
    LibK.outb 0x3D4_u16, 0x0E_u8
    LibK.outb 0x3D5_u16, (pos >> 8).to_u8
  end

  # Scrolls the terminal.
  private def scroll
    attr = make_attribute BLANK, @@color
    VGA_HEIGHT.times do |y|
      VGA_WIDTH.times do |x|
        @@vmem[offset x, y] = @@vmem[offset x, y + 1]
      end
    end
    VGA_WIDTH.times do |x|
      @@vmem[VGA_SIZE - VGA_WIDTH + x] = attr
    end
  end

  # Calculates an offset into the video memory.
  private def offset(x : Int, y : Int)
    y * VGA_WIDTH + x
  end

  private def make_color(fc : UInt8, bc : UInt8) : UInt8
    bc << 4 | fc
  end

  private def make_attribute(ord : Int, color : UInt8) : UInt16
    color.to_u16 << 8 | ord
  end
end
