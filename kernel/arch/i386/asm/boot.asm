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
    mov eax, [esp + 4]
    lgdt [eax]
    jmp 0x08:.flush
.flush:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ret

;
; Nuummite export:
; Flush TSS
;
global glue_flush_tss
glue_flush_tss:
    mov ax, 0x2b
    ltr ax
    ret

;
; Nuummite export:
; Setup GDT
;
global glue_setup_gdt
glue_setup_gdt:
    extern gdt_setup
    call gdt_setup
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
; Page tables.
;
page_tables:
.p4:
    resb 4096
.p3:
    resb 4096
.p2:
    resb 4096

;
; Kernel stack.
;
stack:
.bottom:
resb 16384 ; 16 KiB
.top: