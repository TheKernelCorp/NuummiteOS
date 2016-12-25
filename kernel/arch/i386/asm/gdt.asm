global gdt_load

section .text
gdt_load:
  lgdt [gdt32.ptr]
  mov ax, gdt32.kernel_data
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  jmp gdt32.kernel_code:flush_gdt

flush_gdt:
  ret

flush_tss:
  mov ax, 0x2B
  ltr ax
  ret

section .rodata
gdt32:
%define NULL                 0x00
%define SEG_DESC(x)  ((x) << 0x04)
%define SEG_PRES(x)  ((x) << 0x07)
%define SEG_SAVL(x)  ((x) << 0x0C)
%define SEG_LONG(x)  ((x) << 0x0D)
%define SEG_SIZE(x)  ((x) << 0x0E)
%define SEG_GRAN(x)  ((x) << 0x0F)
%define SEG_PRIV(x) (((x) &  0x03) << 0x05)
%define SEG_DATA_RD          0x00
%define SEG_DATA_RDA         0x01
%define SEG_DATA_RDWR        0x02
%define SEG_DATA_RDWRA       0x03
%define SEG_DATA_RDEXPD      0x04
%define SEG_DATA_RDEXPDA     0x05
%define SEG_DATA_RDWREXPD    0x06
%define SEG_DATA_RDWREXPDA   0x07
%define SEG_CODE_EX          0x08
%define SEG_CODE_EXA         0x09
%define SEG_CODE_EXRD        0x0A
%define SEG_CODE_EXRDA       0x0B
%define SEG_CODE_EXC         0x0C
%define SEG_CODE_EXCA        0x0D
%define SEG_CODE_EXRDC       0x0E
%define SEG_CODE_EXRDCA      0x0F
%define SEG_LIMIT            0x000FFFFF
%define CODE_PL0 NULL \
        | SEG_DESC(1) \
        | SEG_PRES(1) \
        | SEG_SIZE(1) \
        | SEG_GRAN(1) \
        | SEG_PRIV(0) \
        | SEG_CODE_EXRD
%define DATA_PL0 NULL \
        | SEG_DESC(1) \
        | SEG_PRES(1) \
        | SEG_SIZE(1) \
        | SEG_GRAN(1) \
        | SEG_PRIV(0) \
        | SEG_DATA_RDWR
%define CODE_PL3 NULL \
        | SEG_DESC(1) \
        | SEG_PRES(1) \
        | SEG_SIZE(1) \
        | SEG_GRAN(1) \
        | SEG_PRIV(3) \
        | SEG_CODE_EXRD
%define DATA_PL3 NULL \
        | SEG_DESC(1) \
        | SEG_PRES(1) \
        | SEG_SIZE(1) \
        | SEG_GRAN(1) \
        | SEG_PRIV(3) \
        | SEG_DATA_RDWR

%macro create_descriptor 3
  %assign base %1 & 0xFFFFFFFF
  %assign flag %3 & 0x0000FFFF
  %assign segl %2 & 0xFFFFFFFF
  %assign desc segl & 0x000F0000
  %assign desc desc | ((flag << 08) & 0x00F0FF00)
  %assign desc desc | ((base >> 16) & 0x000000FF)
  %assign desc desc |  (base        & 0xFF000000)
  %assign desc desc << 32
  %assign desc desc |  (base << 16)
  %assign desc desc |  (segl        & 0x0000FFFF)
  dq desc
%endmacro

;
; Null descriptor.
;
.null:
  create_descriptor NULL, NULL, NULL

;
; Kernel code descriptor.
;
.kernel_code: equ $ - gdt32
  create_descriptor NULL, SEG_LIMIT, CODE_PL0

;
; Kernel data descriptor.
;
.kernel_data: equ $ - gdt32
  create_descriptor NULL, SEG_LIMIT, DATA_PL0

;
; User code descriptor.
;
.user_code: equ $ - gdt32
  create_descriptor NULL, SEG_LIMIT, CODE_PL3

;
; User data descriptor.
;
.user_data: equ $ - gdt32
  create_descriptor NULL, SEG_LIMIT, DATA_PL3

.ptr:
  dw .ptr - gdt32 - 1
  dd gdt32