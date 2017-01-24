; Multiboot constants
MBALIGN   equ 1<<0
MEMINFO   equ 1<<1
VIDINFO   equ 1<<2
FLAGS     equ MBALIGN | MEMINFO | VIDINFO
MAGIC     equ 0x1BADB002
CHECKSUM  equ -(MAGIC + FLAGS)

; Multiboot header
section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM
    dd 0x00000000 
    dd 0x00000000
    dd 0x00000000
    dd 0x00000000
    dd 0x00000000
    dd 0x00000000
    dd 0
    dd 0
    dd 32

section .text
global _start
bits 32

;
; This is where GRUB takes us.
;
_start:
    cli
    mov esp, stack.top
    push ebx

;
; Jumps into the Crystal kernel.
;
enter_kernel:
    extern END_OF_KERNEL
    push dword END_OF_KERNEL
    extern kearly
    call kearly
    extern kmain
    call kmain
.hang:
    cli
    hlt
    jmp $

;
; Nuummite export:
; Flush GDT
;
global glue_flush_gdt
glue_flush_gdt:
    jmp 0x08:.flush
.flush:
    ret

;
; Nuummite export:
; Setup IDT
;
global glue_setup_idt
glue_setup_idt:
    extern idt_setup
    call idt_setup
    ret

section .bss
align 4096

;
; Kernel stack.
;
stack:
.bottom:
resb 16384 ; 16 KiB
.top: