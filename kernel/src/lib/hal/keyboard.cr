private KBD_DATA = 0x60_u16
private KBD_STATUS = 0x64_u16
private KBD_RES_ACK = 0xFA_u16
private KBD_RES_ECHO = 0xEE_u16
private KBD_RES_RESEND = 0xFE_u16
private KBD_RES_ERROR_A = 0x00_u16
private KBD_RES_ERROR_B = 0xFF_u16
private KBD_RES_ST_PASS = 0xAA_u16
private KBD_RES_ST_FAIL_A = 0xFC_u16
private KBD_RES_ST_FAIL_B = 0xFD_u16
private KBD_COM_LED = 0xED_u16
private KBD_COM_ECHO = 0xEE_u16
private KBD_COM_SCANCODE = 0xF0_u16
private KBD_COM_IDENTIFY = 0xF2_u16
private KBD_COM_TYPEMATIC = 0xF3_u16
private KBD_COM_SCAN_ON = 0xF4_u16
private KBD_COM_SCAN_OFF = 0xF5_u16
private KBD_COM_SET_DEFAULT = 0xF6_u16
private KBD_COM_TM_AR_ALL = 0xF7_u16
private KBD_COM_MK_RE_ALL = 0xF8_u16
private KBD_COM_MK_ALL = 0xF9_u16
private KBD_COM_TM_AR_MK_RE_ALL = 0xFA_u16
private KBD_COM_TM_AR_SINGLE = 0xFB_u16
private KBD_COM_MK_RE_SINGLE = 0xFC_u16
private KBD_COM_MK_SINGLE = 0xFD_u16
private KBD_COM_RESEND = 0xFE_u16
private KBD_COM_SELF_TEST = 0xFF_u16

struct Keyboard
  @@shift : Bool?
  @@buffer = Deque(Char).new 256

  macro send_command(command)
    until (inb(KBD_STATUS) & 0x2) == 0; end
    outb KBD_DATA, {{ command }}.to_u8
  end

  # Initializes the keyboard
  # - Clears the LEDs
  # - Sets the fastest possible refresh-rate
  # - Enables keycode scanning
  def self.init
    # Clear LEDs
    send_command KBD_COM_LED
    send_command 0x00
    # Fastest refresh-rate
    send_command KBD_COM_TYPEMATIC
    send_command 0x00
    # Enable keyboard
    self.enable
  end

  # Enables the keyboard
  def self.enable
    send_command KBD_COM_SCAN_ON
  end

  # Disables the keyboard
  def self.disable
    send_command KBD_COM_SCAN_OFF
  end

  def self.handle_keypress
    data = inb KBD_DATA
    pressed = (data & 0x80) == 0
    if pressed # Key pressed
      case data
        when 42 || 55 # LShift || RShift
          @@shift = true
          return
      end
      if @@shift
        # If shift is pressed, we want
        # the key codes from the second
        # half of the key map.
        data += 128
      end
      @@shift = false
      key = pointerof(KEYMAP_EN_US.@c)[data].chr
      self.buffer_key key
    else # Key released
    end
  end

  def self.read_key
    read_key { raise "No key available" }
  end

  def self.read_key?
    read_key { nil }
  end

  def self.read_key
    if @@buffer.size == 0
      yield
    else
      @@buffer.shift
    end
  end

  def self.buffer_key(key : Char)
    if @@buffer.size < 256
      @@buffer.push key
    else
      @@buffer.pop
      @@buffer.unshift key
    end
  end
end

module KeyboardTests
  def self.run
    run_tests [
      flatbuffer,
      ringbuffer,
    ]
  end

  test flatbuffer, "Keyboard/flatbuffer", begin
    Keyboard.buffer_key 'a'
    Keyboard.buffer_key 'b'
    assert_eq 'a', Keyboard.read_key
    assert_eq 'b', Keyboard.read_key
  end

  test ringbuffer, "Keyboard/ringbuffer", begin
    {% for i in 0...256 %}
      Keyboard.buffer_key 'a'
    {% end %}
    Keyboard.buffer_key 'b'
    Keyboard.buffer_key 'c'
    assert_eq 'c', Keyboard.read_key
    assert_eq 'b', Keyboard.read_key
    assert_eq 'a', Keyboard.read_key
  end
end
