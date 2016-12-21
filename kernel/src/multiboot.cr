lib LibMultiboot
    MULTIBOOT_SEARCH                = 8192
    MULTIBOOT_HEADER_ALIGN          = 4
    MULTIBOOT_HEADER_MAGIC          = 0x1BADB002
    MULTIBOOT_BOOTLOADER_MAGIC      = 0x2BADB002
    MULTIBOOT_MOD_ALIGN             = 0x00001000
    MULTIBOOT_INFO_ALIGN            = 0x00000004
    MULTIBOOT_PAGE_ALIGN            = 0x00000001
    MULTIBOOT_MEMORY_INFO           = 0x00000002
    MULTIBOOT_VIDEO_MODE            = 0x00000004
    MULTIBOOT_AOUT_KLUDGE           = 0x00010000
    MULTIBOOT_INFO_MEMORY           = 0x00000001
    MULTIBOOT_INFO_BOOTDEV          = 0x00000002
    MULTIBOOT_INFO_CMDLINE          = 0x00000004
    MULTIBOOT_INFO_MODS             = 0x00000008
    MULTIBOOT_INFO_AOUT_SYMS        = 0x00000010
    MULTIBOOT_INFO_ELF_SHDR         = 0x00000020
    MULTIBOOT_INFO_MEM_MAP          = 0x00000040
    MULTIBOOT_INFO_DRIVE_INFO       = 0x00000080
    MULTIBOOT_INFO_CONFIG_TABLE     = 0x00000100
    MULTIBOOT_INFO_BOOT_LOADER_NAME = 0x00000200
    MULTIBOOT_INFO_APM_TABLE        = 0x00000400
    MULTIBOOT_INFO_VBE_INFO         = 0x00000800
    MULTIBOOT_INFO_FRAMEBUFFER_INFO = 0x00001000

    struct MultibootHeader
        magic : UInt32
        flags : UInt32
        checksum : UInt32
        aout_info : MultibootAoutInfo
        video_info : MultibootVideoInfo
    end

    struct MultibootAoutInfo
        header_addr : UInt32
        load_addr : UInt32
        load_end_addr : UInt32
        bss_end_addr : UInt32
        entry_addr : UInt32
    end

    struct MultibootVideoInfo
        mode_type : UInt32
        width : UInt32
        height : UInt32
        depth : UInt32
    end

    struct MultibootAoutSymbolTable
        tab_size : UInt32
        str_size : UInt32
        addr : UInt32
        reserved : UInt32
    end

    struct MultibootElfSectionHeaderTable
        num : UInt32
        size : UInt32
        addr : UInt32
        shndx : UInt32
    end

    union MultibootSymbolTable
        aout_sym : MultibootAoutSymbolTable
        elf_sec : MultibootElfSectionHeaderTable
    end

    struct MultibootBootDevice
        drive : UInt8
        partition_1 : UInt8
        partition_2 : UInt8
        partition_3 : UInt8
    end

    struct MultibootVbeFramebufferPaletteMemoryInfo
        fb_palette_addr : UInt32
        fb_palette_num_colors : UInt16
    end

    struct MultibootVbeFramebufferPaletteEntry
        field_position : UInt8
        mask_size : UInt8
    end

    struct MultibootVbeFramebufferPaletteData
        red : MultibootVbeFramebufferPaletteEntry
        green : MultibootVbeFramebufferPaletteEntry
        blue : MultibootVbeFramebufferPaletteEntry
    end

    union MultibootVbeFramebufferPaletteInfo
        palette_mem : MultibootVbeFramebufferPaletteMemoryInfo
        palette_data : MultibootVbeFramebufferPaletteData
    end

    struct MultibootVbeFramebufferInfo
        fb_addr : UInt64
        fb_pitch : UInt32
        fb_width : UInt32
        fb_height : UInt32
        fb_bpp : UInt8
        fb_type : UInt8
        palette : MultibootVbeFramebufferPaletteInfo
    end

    struct MultibootVbeInfo
        vbe_control_info : UInt32
        vbe_mode_info : UInt32
        vbe_mode : UInt16
        vbe_interface_seg : UInt16
        vbe_interface_off : UInt16
        vbe_interface_len : UInt16
        vbe_framebuffer_info : MultibootVbeFramebufferInfo
    end

    struct MultibootInfo
        flags : UInt32
        mem_lower : UInt32
        mem_upper : UInt32
        boot_device : MultibootBootDevice
        cmdline : UInt32
        mods_count : UInt32
        mods_addr : UInt32
        elf_symbols : MultibootSymbolTable
        mmap_length : UInt32
        mmap_addr : UInt32
        config_table : UInt32
        boot_loader_name : UInt32
        apm_table : UInt32
        vbe_info : MultibootVbeInfo
    end
end
