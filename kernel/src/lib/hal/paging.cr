lib LibPaging
  @[Packed]
  struct PageTable
    pages : UInt32[1024]
  end

  @[Packed]
  struct PageDirectory
    tables : PageTable*[1024]
    physical_tables : UInt32[1024]
    physical_address : UInt32
  end
end

module Paging
  extend self

  def setup
    # TODO: Enable paging
  end

  def old_setup
    LibGlue.setup_paging
  end
end

struct Page
  getter value : UInt32

  def initialize
    @value = 0_u32
  end

  def present?
    @value.bit(31) == 1
  end

  def read_write?
    @value.bit(30) == 1
  end

  def user?
    @value.bit(29) == 1
  end

  def accessed?
    @value.bit(28) == 1
  end

  def dirty?
    @value.bit(27) == 1
  end

  def frame
    @value & (1 << 20) - 1
  end
end
