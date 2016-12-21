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
global _start
extern kmain

;
; This is where GRUB takes us.
;
_start:
    cli
    mov esp, stack.top
    push ebx

;
; Paging magic.
;
setup_paging:

;
; Links the page tables together.
;
.link:
    ; Keep it DRY
    %macro makelink 2
    mov eax, page_tables.%1
    or eax, 0x03
    mov dword [page_tables.%2], eax
    %endmacro
    makelink p3, p4
    makelink p2, p3
    mov ecx, 0

;
; Maps the p2 table.
;
.map:
    mov eax, 0x200000
    mul ecx
    or eax, 0x83
    mov [page_tables.p2 + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .map

;
; Loads the p4 table into cr3.
;
.load:
    mov eax, page_tables.p4
    mov cr3, eax

;
; Enables PAE (Physical Address Extension).
;
.enable_pae:
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax

;
; Enables paging.
;
.enable_paging:
    mov eax, cr0
    or eax, 0x00010000
    mov cr0, eax

;
; Enables SSE.
;
enable_sse:
    mov eax, cr0
    and ax, 0xFFFB
    or ax, 0x2
    mov cr0, eax
    mov eax, cr4
    or ax, 0x600
    mov cr4, eax

;
; Jumps into the Crystal kernel.
;
enter_kernel:
    call kmain
.hang:
    cli
    jmp $