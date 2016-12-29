private def seg_desc(x : UInt64) x << 0x04_u64 end
private def seg_pres(x : UInt64) x << 0x07_u64 end
private def seg_savl(x : UInt64) x << 0x0C_u64 end
private def seg_long(x : UInt64) x << 0x0D_u64 end
private def seg_size(x : UInt64) x << 0x0E_u64 end
private def seg_gran(x : UInt64) x << 0x0F_u64 end
private def seg_priv(x : UInt64) (x & 0x03_u64) << 0x05_u64 end

private NULL = 0x00_u64
private SEG_DATA_RD = 0x00_u64
private SEG_DATA_RDA = 0x01_u64
private SEG_DATA_RDWR = 0x02_u64
private SEG_DATA_RDWRA = 0x03_u64
private SEG_DATA_RDEXPD = 0x04_u64
private SEG_DATA_RDEXPDA = 0x05_u64
private SEG_DATA_RDWREXPD = 0x06_u64
private SEG_DATA_RDWREXPDA = 0x07_u64
private SEG_CODE_EX = 0x08_u64
private SEG_CODE_EXA = 0x09_u64
private SEG_CODE_EXRD = 0x0A_u64
private SEG_CODE_EXRDA = 0x0B_u64
private SEG_CODE_EXC = 0x0C_u64
private SEG_CODE_EXCA = 0x0D_u64
private SEG_CODE_EXRDC = 0x0E_u64
private SEG_CODE_EXRDCA = 0x0F_u64
private SEG_LIMIT = 0x000FFFFF_u64

private CODE_PL0 =
    seg_desc(1_u64) |
    seg_pres(1_u64) |
    seg_size(1_u64) |
    seg_gran(1_u64) |
    seg_priv(0_u64) |
    SEG_CODE_EXRD

private DATA_PL0 =
    seg_desc(1_u64) |
    seg_pres(1_u64) |
    seg_size(1_u64) |
    seg_gran(1_u64) |
    seg_priv(0_u64) |
    SEG_DATA_RDWR

private CODE_PL3 =
    seg_desc(1_u64) |
    seg_pres(1_u64) |
    seg_size(1_u64) |
    seg_gran(1_u64) |
    seg_priv(3_u64) |
    SEG_CODE_EXRD

private DATA_PL3 =
    seg_desc(1_u64) |
    seg_pres(1_u64) |
    seg_size(1_u64) |
    seg_gran(1_u64) |
    seg_priv(3_u64) |
    SEG_DATA_RDWR

private TSS =
    seg_desc(0_u64) |
    seg_pres(1_u64) |
    seg_size(1_u64) |
    seg_gran(0_u64) |
    seg_priv(3_u64) |
    SEG_CODE_EXA

lib LibGDT
    fun flush_gdt = "nu_flush_gdt"(ptr : UInt32)

    @[Packed]
    struct GDT32
        null : UInt64
        kernel_code : UInt64
        kernel_data : UInt64
        user_code : UInt64
        user_data : UInt64
        tss : UInt64
    end

    @[Packed]
    struct GDTR
        limit : UInt16
        base : UInt32
    end
end

lib LibTSS
    fun flush_tss = "nu_flush_tss"

    @[Packed]
    struct TSS32
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
end

fun create_descriptor(base : UInt64, limit : UInt64, flag : UInt64) : UInt64
    flag = flag.to_u64 & 0x0000FFFF_u64
    desc = limit & 0x000F0000_u64
    desc |= (flag << 0x08_u64) & 0x00F0FF00_u64
    desc |= (base >> 0x10_u64) & 0x000000FF_u64
    desc |= base & 0xFF000000_u64
    desc <<= 32_u64
    desc |= base << 16_u64
    desc |= limit & 0x0000FFFF_u64
    desc
end

fun setup_gdt_tss
    gdt = uninitialized LibGDT::GDT32
    gdtr = uninitialized LibGDT::GDTR
    tss = uninitialized LibTSS::TSS32
    setup_gdt gdt, gdtr
    setup_tss gdt, tss
    LibGDT.flush_gdt pointerof(gdtr).address
    LibTSS.flush_tss
end

macro setup_gdt(gdt, gdtr)
    gdt.null = create_descriptor NULL, NULL, NULL
    gdt.kernel_code = create_descriptor NULL, SEG_LIMIT, CODE_PL0
    gdt.kernel_data = create_descriptor NULL, SEG_LIMIT, DATA_PL0
    gdt.user_code = create_descriptor NULL, SEG_LIMIT, CODE_PL3
    gdt.user_data = create_descriptor NULL, SEG_LIMIT, DATA_PL3
    gdtr.base = pointerof(gdt).address.to_u32
    gdtr.limit = sizeof(LibGDT::GDT32).to_u32 - 1
end

macro setup_tss(gdt, tss)
    %size = sizeof(LibTSS::TSS32)
    %base = pointerof(tss).address
    %limit = %base + %size
    gdt.tss = create_descriptor %base, %limit, TSS
    memset pointerof(tss).to_void_ptr, 0u8, %size.to_u32
    tss.ss0 = 0x10
    tss.cs = 0x0b
    tss.ss = 0x13
    tss.ds = 0x13
    tss.es = 0x13
    tss.fs = 0x13
    tss.gs = 0x13
end