ENTRY (start)

SECTIONS {
  . = 1M;

  .text BLOCK (4K) : ALIGN (4K) {
    *(.multiboot)
    *(.text)
    *(.glue)
  }

  .rodata BLOCK (4K) : ALIGN (4K) {
    *(.rodata*)
  }

  .data BLOCK (4K) : ALIGN (4K) {
    *(.data)
  }

  .bss BLOCK (4K) : ALIGN (4K) {
    *(COMMON*)
    *(.bss*)
  }

  END_OF_KERNEL = .;
}