alias PageDirectory = LibPaging::PageDirectory

lib LibPaging
  @[Packed]
  struct PageTable
    pages : UInt32[1024]
  end

  @[Packed]
  struct PageDirectory
    tables : PageTable*[1024]
    physical_tables : UInt32[1024]
    paddr : UInt32
  end
end

module Paging
  extend self

  PAGE_RW = 0x01_u32
  PAGE_USER = 0x02_u32

  @@current_directory = Pointer(PageDirectory).null

  def setup
    IDT.add_fault_handler 14, ->handle_page_fault(StackFrame)
    kernel_directory = HeapAllocator(PageDirectory).palloc
    LibC.memset kernel_directory, 0_u8, sizeof(PageDirectory).to_u32
    switch_page_directory kernel_directory
    addr = 0_u32
    while addr < 0x4000000_u32
      page_alloc kernel_directory, addr, addr, false, false
      addr += 0x1000_u32
    end
    enable
  end

  private def page_alloc(directory : PageDirectory*, vaddr : UInt32, paddr : UInt32, read_write : Bool, user : Bool)
    vaddr /= 0x1000
    i = vaddr / 0x400
    if directory.value.tables[i] == 0
      page = HeapAllocator(LibPaging::PageTable).palloc
      LibC.memset page, 0_u8, sizeof(LibPaging::PageTable).to_u32
      directory.value.tables[i] = page
      directory.value.physical_tables[i] = page.address.to_u32 | 0x7
    end
    page_index = vaddr % 0x400
    page = directory.value.tables[i].value.pages[page_index]
    return if PageHelper.present?(page)
    page = PageHelper.set_present(page, true)
    page = PageHelper.set_read_write(page, read_write)
    page = PageHelper.set_user(page, user)
    page = PageHelper.set_frame(page, paddr >> 12)
    directory.value.tables[i].value.pages[page_index] = page
  end

  private def handle_page_fault(frame : StackFrame)
    fault_address = 0_u32
    asm("mov %cr2, $0" : "=r"(fault_address))
    # frame_alloc @@current_directory, fault_address & 0xFFFFF000, PAGE_RW
    raise "Page fault at #{Pointer(UInt32).new(fault_address.to_u64)}"
  end

  private def enable
    asm("
      pushl %eax
      movl %cr0, %eax
      orl $$0x80000000, %eax
      movl %eax, %cr0
      popl %eax
    ")
  end

  private def disable
    asm("
      pushl %eax
      movl %cr0, %eax
      andl $$0x7FFFFFFF, %eax
      movl %eax, %cr0
      popl %eax
    ")
  end

  private def switch_page_directory(directory : LibPaging::PageDirectory*)
    @@current_directory = directory
    asm("movl $0, %cr3" :: "{eax}"(directory.value.physical_tables.to_unsafe))
  end
end

module PageHelper
  extend self

  private enum PageFlags : UInt32
    Present   = 0,
    ReadWrite = 1,
    User      = 2,
    Accessed  = 3,
    Dirty     = 4,
  end

  macro create_helper(name, bit_flag)
    def {{ name.id }}?(page : UInt32)
      page.bit({{ bit_flag }}.value) == 1
    end
    def set_{{ name.id }}(page : UInt32, value : Bool)
      %bit = {{ bit_flag }}.value
      page & ~(1 << %bit) | ((value ? 1 : 0) << %bit)
    end
  end

  create_helper present, PageFlags::Present
  create_helper read_write, PageFlags::ReadWrite
  create_helper user, PageFlags::User
  create_helper accessed, PageFlags::Accessed
  create_helper dirty, PageFlags::Dirty

  def frame(page : UInt32)
    page & (1 << 20) - 1
  end

  def set_frame(page : UInt32, value : UInt32)
    (page & 0xFFFF) | (value << 12)
  end
end
