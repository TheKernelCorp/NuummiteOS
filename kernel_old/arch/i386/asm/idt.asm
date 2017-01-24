global idt_setup
global active_stack

;
; Routine to set the IDT up.
;
idt_setup:
    call idt_set_gates
    call idt_load
    ret

;
; ISR handler.
;
idt_handle_isr:
.enter:
    pusha
    push ds
    push es
    push fs
    push gs
.transition:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
.handle:
    mov [active_stack], esp ; backup stack
    ; Defined in src/lib/glue.cr
    extern glue_handle_isr
    call glue_handle_isr
    mov esp, [active_stack] ; apply new stack
.leave:
    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 8
    iretd

;
; Macro to calculate the base address of an IDT gate.
;
%define IDT_GATE_ADDR(gate) (idt_data.start + (gate * 8))

;
; Macro to set an IDT gate.
;
; Usage:
; idtsetgate <num> <base_addr> <sel> <flags>
;
%macro idt_set_gate 4
    push eax
    push ebx
    ; Get gate address
    mov eax, IDT_GATE_ADDR(%1)
    ; Set low base
    mov ebx, %2
    mov word [eax + 0], bx
    ; Set selector
    mov word [eax + 2], %3
    ; Set zero byte
    mov byte [eax + 4], 0
    ; Set flags
    mov byte [eax + 5], %4
    ; Set high base
    shr ebx, 16
    mov word [eax + 6], bx
    pop ebx
    pop eax
%endmacro

;
; ISR builder (common).
;
%macro isr 1
    idt_isr%1:
        cli
        push dword 0
        push dword %1
        jmp idt_handle_isr
%endmacro

;
; ISR builder (with exception code).
;
%macro exc 1
    idt_isr%1:
        cli
        push dword %1
        jmp idt_handle_isr
%endmacro

;
; Routine to set the IDT gates.
; Loads the IDT in the process.
; Registers are preserved.
;
idt_set_gates:
    ; Exceptions
    idt_set_gate 0x00, idt_isr00, 0x08, 0x8E
    idt_set_gate 0x01, idt_isr01, 0x08, 0x8E
    idt_set_gate 0x02, idt_isr02, 0x08, 0x8E
    idt_set_gate 0x03, idt_isr03, 0x08, 0x8E
    idt_set_gate 0x04, idt_isr04, 0x08, 0x8E
    idt_set_gate 0x05, idt_isr05, 0x08, 0x8E
    idt_set_gate 0x06, idt_isr06, 0x08, 0x8E
    idt_set_gate 0x07, idt_isr07, 0x08, 0x8E
    idt_set_gate 0x08, idt_isr08, 0x08, 0x8E
    idt_set_gate 0x09, idt_isr09, 0x08, 0x8E
    idt_set_gate 0x0a, idt_isr10, 0x08, 0x8E
    idt_set_gate 0x0b, idt_isr11, 0x08, 0x8E
    idt_set_gate 0x0c, idt_isr12, 0x08, 0x8E
    idt_set_gate 0x0d, idt_isr13, 0x08, 0x8E
    idt_set_gate 0x0e, idt_isr14, 0x08, 0x8E
    idt_set_gate 0x0f, idt_isr15, 0x08, 0x8E
    idt_set_gate 0x10, idt_isr16, 0x08, 0x8E
    idt_set_gate 0x11, idt_isr17, 0x08, 0x8E
    idt_set_gate 0x12, idt_isr18, 0x08, 0x8E
    idt_set_gate 0x13, idt_isr19, 0x08, 0x8E
    idt_set_gate 0x14, idt_isr20, 0x08, 0x8E
    idt_set_gate 0x15, idt_isr21, 0x08, 0x8E
    idt_set_gate 0x16, idt_isr22, 0x08, 0x8E
    idt_set_gate 0x17, idt_isr23, 0x08, 0x8E
    idt_set_gate 0x18, idt_isr24, 0x08, 0x8E
    idt_set_gate 0x19, idt_isr25, 0x08, 0x8E
    idt_set_gate 0x1a, idt_isr26, 0x08, 0x8E
    idt_set_gate 0x1b, idt_isr27, 0x08, 0x8E
    idt_set_gate 0x1c, idt_isr28, 0x08, 0x8E
    idt_set_gate 0x1d, idt_isr29, 0x08, 0x8E
    idt_set_gate 0x1e, idt_isr30, 0x08, 0x8E
    idt_set_gate 0x1f, idt_isr31, 0x08, 0x8E
    ; IRQs
    idt_set_gate 0x20, idt_isr32, 0x08, 0x8E
    idt_set_gate 0x21, idt_isr33, 0x08, 0x8E
    idt_set_gate 0x22, idt_isr34, 0x08, 0x8E
    idt_set_gate 0x23, idt_isr35, 0x08, 0x8E
    idt_set_gate 0x24, idt_isr36, 0x08, 0x8E
    idt_set_gate 0x25, idt_isr37, 0x08, 0x8E
    idt_set_gate 0x26, idt_isr38, 0x08, 0x8E
    idt_set_gate 0x27, idt_isr39, 0x08, 0x8E
    idt_set_gate 0x28, idt_isr40, 0x08, 0x8E
    idt_set_gate 0x29, idt_isr41, 0x08, 0x8E
    idt_set_gate 0x2a, idt_isr42, 0x08, 0x8E
    idt_set_gate 0x2b, idt_isr43, 0x08, 0x8E
    idt_set_gate 0x2c, idt_isr44, 0x08, 0x8E
    idt_set_gate 0x2d, idt_isr45, 0x08, 0x8E
    idt_set_gate 0x2e, idt_isr46, 0x08, 0x8E
    idt_set_gate 0x2f, idt_isr47, 0x08, 0x8E
    ret

;
; Routine to load the IDT.
;
idt_load:
    lidt [idt_register]
    ret

;
; Interrupt handlers.
;
idt_handlers:
    ; Exceptions
    isr 00
    isr 01
    isr 02
    isr 03
    isr 04
    isr 05
    isr 06
    isr 07
    exc 08
    isr 09
    exc 10
    exc 11
    exc 12
    exc 13
    exc 14
    isr 15
    isr 16
    exc 17
    isr 18
    isr 19
    isr 20
    isr 21
    isr 22
    isr 23
    isr 24
    isr 25
    isr 26
    isr 27
    isr 28
    isr 29
    exc 30
    isr 31
    ; IRQs
    isr 32
    isr 33
    isr 34
    isr 35
    isr 36
    isr 37
    isr 38
    isr 39
    isr 40
    isr 41
    isr 42
    isr 43
    isr 44
    isr 45
    isr 46
    isr 47

section .data
align 4

;
; Address of the active stack.
;
active_stack:
    dd 0

section .rodata
align 8

;
; IDT register.
;
idt_register:
    ; Limit
    dw idt_data.end - idt_data.start - 1
    ; Base
    dd idt_data.start

section .bss
align 8

;
; IDT contents.
;
idt_data:
.start:
    resb 2048
.end: