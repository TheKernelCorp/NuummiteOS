lib LibBootstrap
  @[Packed]
  struct EarlyInfo
    end_of_kernel : UInt32
    mboot_ptr : UInt32
  end
end

fun kmain(info : LibBootstrap::EarlyInfo)
  asm("cli; hlt")
end
