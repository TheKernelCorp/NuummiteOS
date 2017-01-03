struct GDT
  def self.setup
    LibGlue.setup_gdt
  end
end
