; Multiboot constants
MBALIGN   equ 1<<0
MEMINFO   equ 1<<1
FLAGS     equ MBALIGN | MEMINFO
MAGIC     equ 0x1BADB002
CHECKSUM  equ -(MAGIC + FLAGS)

; Multiboot header
section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

section .bss
align 4096
page_tables:
.p4:
    resb 4096
.p3:
    resb 4096
.p2:
    resb 4096
stack:
.bottom:
resb 16384 ; 16 KiB
.top:

section .text
bits 32
global _start
extern kearly
extern kmain

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
    call kearly
    call kmain
.hang:
    cli
    jmp $

global nu_flush_gdt
nu_flush_gdt:
    mov eax, [esp + 4]
    lgdt [eax]
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp 0x08:.flush
.flush:
    ret