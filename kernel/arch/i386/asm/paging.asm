global paging_setup

section .text
paging_setup:

; Links the page tables together.
.link:
    %macro makelink 2
    mov eax, page_tables.%1
    or eax, 0x03
    mov dword [page_tables.%2], eax
    %endmacro
    makelink p3, p4
    makelink p2, p3
    mov ecx, 0

; Maps the p2 table.
.map:
    mov eax, 0x200000
    mul ecx
    or eax, 0x83
    mov [page_tables.p2 + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .map
    
; Loads the p4 table into cr3.
.load:
    mov eax, page_tables.p4
    mov cr3, eax

; Enables PAE (Physical Address Extension).
.enable_pae:
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax

; Enables paging.
.enable_paging:
    mov eax, cr0
    or eax, 0x00000010
    mov cr0, eax
    ret

section .bss
align 4096
page_tables:
.p4:
    resb 4096
.p3:
    resb 4096
.p2:
    resb 4096