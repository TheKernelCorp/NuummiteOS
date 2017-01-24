lib LibGDT
  @[Packed]
  struct GDTR
    limit : UInt16
    base : UInt32
  end

  @[Packed]
  struct GDT
    null : UInt64
    kernel_code : UInt64
    kernel_data : UInt64
    user_code : UInt64
    user_data : UInt64
    user_tss : UInt64
  end

  @[Packed]
  struct TSS
    link : UInt32
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
end

module GDT
  extend self

  @@tss = uninitialized LibGDT::TSS
  @@gdt = uninitialized LibGDT::GDT
  @@gdtr = uninitialized LibGDT::GDTR

  def setup
    LibC.memset pointerof(@@tss), 0_u8, sizeof(LibGDT::TSS).to_u32
    @@tss.ss0 = 0x10
    @@tss.cs = 0x0b
    @@tss.ss = 0x13
    @@tss.ds = 0x13
    @@tss.es = 0x13
    @@tss.fs = 0x13
    @@tss.gs = 0x13
    @@gdt.null = 0_u64
    @@gdt.kernel_code = create_descriptor 0_u64, 0xFFFFF_u64, GDT_kernel_code
    @@gdt.kernel_data = create_descriptor 0_u64, 0xFFFFF_u64, GDT_kernel_data
    @@gdt.user_code = create_descriptor 0_u64, 0xFFFFF_u64, GDT_user_code
    @@gdt.user_data = create_descriptor 0_u64, 0xFFFFF_u64, GDT_user_data
    @@gdt.user_tss = create_descriptor pointerof(@@tss).address, sizeof(LibGDT::TSS).to_u64, GDT_user_tss
    @@gdtr.limit = sizeof(LibGDT::GDT).to_u16 - 1_u16
    @@gdtr.base = pointerof(@@gdt).address.to_u32
    asm("
      lgdtl ($0)
      movw $$0x10, %ax
      movw %ax, %ds
      movw %ax, %es
      movw %ax, %fs
      movw %ax, %gs
      movw %ax, %ss
      call glue_flush_gdt
      movw $$0x2b, %ax
      ltrw %ax"
      :: "{eax}"(pointerof(@@gdtr).address))
  end

  private def create_descriptor(base : UInt64, limit : UInt64, flags : UInt64) : UInt64
    entry = limit & 0xF0000_u64
    entry |= ((flags & 0xFFFF_u64) << 0x08_u64) & 0xF0FF00_u64
    entry |= (base >> 0x10_u64) & 0xFF_u64
    entry |= base & 0xFF000000_u64
    entry <<= 32_u64
    entry |= base << 0x10_u64
    entry |= limit & 0xFFFF_u64
    entry
  end

  private def seg_desc(x) x.to_u64 << 0x04_u64 end
  private def seg_pres(x) x.to_u64 << 0x07_u64 end
  private def seg_savl(x) x.to_u64 << 0x0C_u64 end
  private def seg_long(x) x.to_u64 << 0x0D_u64 end
  private def seg_size(x) x.to_u64 << 0x0E_u64 end
  private def seg_gran(x) x.to_u64 << 0x0F_u64 end
  private def seg_priv(x) (x.to_u64 & 0x03_u64) << 0x05_u64 end

  private SEG_code_x = 0x08
  private SEG_code_xa = 0x09
  private SEG_code_xr = 0x0A
  private SEG_code_xra = 0x0B
  private SEG_code_xc = 0x0C
  private SEG_code_xca = 0x0D
  private SEG_code_xrc = 0x0E
  private SEG_code_xrca = 0x0F
  private SEG_data_r = 0x00
  private SEG_data_ra = 0x01
  private SEG_data_rw = 0x02
  private SEG_data_rwa = 0x03
  private SEG_data_re = 0x04
  private SEG_data_rea = 0x05
  private SEG_data_rwe = 0x06
  private SEG_data_rwea = 0x07

  private GDT_kernel_base = seg_desc(1) | seg_pres(1) | seg_size(1) | seg_gran(1)
  private GDT_kernel_code = GDT_kernel_base | SEG_code_xr
  private GDT_kernel_data = GDT_kernel_base | SEG_data_rw
  private GDT_user_base = GDT_kernel_base | seg_priv(3)
  private GDT_user_code = GDT_user_base | SEG_code_xr
  private GDT_user_data = GDT_user_base | SEG_data_rw
  private GDT_user_tss = seg_pres(1) | seg_size(1) | SEG_code_xa
end
