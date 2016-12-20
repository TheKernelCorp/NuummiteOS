require "./lib/pointer.cr"

fun kmain
  scr = Pointer(UInt32).new(0xB8000_u64)
  scr[0] = 0x07690748_u32
end
