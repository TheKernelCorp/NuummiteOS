alias GDTEntry = LibGDT::GDTEntry
alias GDTEntries = LibGDT::GDTEntries
alias GDTPointer = LibGDT::GDTPointer
alias TSSEntry = LibTSS::TSSEntry

private lib LibGDT
  @[Packed]
  struct GDTEntry
    limit_low : UInt16
    base_low : UInt16
    base_middle : UInt8
    access : UInt8
    granularity : UInt8
    base_high : UInt8
  end

  @[Packed]
  struct GDTPointer
    limit : UInt16
    base : UInt32
  end

  @[Packed]
  struct GDTEntries
    null : GDTEntry
    kern_code : GDTEntry
    kern_data : GDTEntry
    user_code : GDTEntry
    user_data : GDTEntry
    tss : GDTEntry
  end

  fun gdt_flush(gdt : UInt32)
end

private lib LibTSS
  @[Packed]
  struct TSSEntry
    prev_tss : UInt32
    esp0 : UInt32
    ss0 : UInt32
    esp1 : UInt32
    ss1 : UInt32
    esp2 : UInt32
    ss2 : UInt32
    cr3 : UInt32
    eip : UInt32
    eflags : UInt32
    eax : UInt32
    ecx : UInt32
    edx : UInt32
    ebx : UInt32
    esp : UInt32
    ebp : UInt32
    esi : UInt32
    edi : UInt32
    es : UInt32
    cs : UInt32
    ss : UInt32
    ds : UInt32
    fs : UInt32
    gs : UInt32
    ldt : UInt32
    trap : UInt32
    iomap_base : UInt32
  end

  fun tss_flush
end

struct GDT
  def initialize
    # raise "Crystal based GDT not working"
    @ptr = GDTPointer.new
    @gdt = GDTEntries.new
    @tss = TSSEntry.new

    @ptr.limit = sizeof(GDTEntry) * 6;
    @ptr.base = pointerof(@gdt).address.to_u32

    set_gate @gdt.null, 0u32, 0u32, 0u8, 0u8
    set_gate @gdt.kern_code, 0u32, 0xFFFFFFFFu32, 0x9Au8, 0xCFu8
    set_gate @gdt.kern_data, 0u32, 0xFFFFFFFFu32, 0x92u8, 0xCFu8
    set_gate @gdt.user_code, 0u32, 0xFFFFFFFFu32, 0xFAu8, 0xCFu8
    set_gate @gdt.user_data, 0u32, 0xFFFFFFFFu32, 0xF2u8, 0xCFu8

    write_tss @gdt.tss, 0x10u16, 0x00u32

    print "before_flush"

    LibGDT.gdt_flush pointerof(@ptr).address.to_u32
    print "after_flush"
    LibTSS.tss_flush
  end

  def set_gate(entry : GDTEntry, base : UInt32, limit : UInt32, access : UInt8, gran : UInt8)
    entry.base_low = base.to_u16
    entry.base_middle = (base >> 16).to_u8
    entry.base_high = (base >> 24).to_u8
    entry.limit_low = limit.to_u16
    entry.granularity = ((limit >> 16) & 0x0F).to_u8
    entry.granularity |= (gran & 0xF0).to_u8
    entry.access = access
    entry
  end

  def write_tss(entry : GDTEntry, ss0 : UInt16, esp0 : UInt32)
    base = pointerof(@tss).address.to_u32
    limit = base + sizeof(TSSEntry)

    set_gate entry, base, limit, 0xE9u8, 0x00u8
    memset pointerof(@tss).as Void*, 0u8, sizeof(TSSEntry).to_u32

    @tss.ss0 = ss0
    @tss.esp0 = esp0
    @tss.cs = 0x0B
    @tss.ss = @tss.ds = @tss.es = @tss.fs = @tss.gs = 0x13;
    entry
  end
end