; Balanced Parentheses Checker using Stack
; NASM syntax for x86 architecture

section .data
    input_msg db "Enter string (max 100 chars): ", 0
    balanced_msg db "Parentheses are balanced!", 10, 0
    unbalanced_msg db "Parentheses are NOT balanced!", 10, 0
    stack_size equ 100
    
section .bss
    input resb 101          ; Input buffer
    stack resb 100          ; Stack array
    stack_ptr resd 1        ; Stack pointer

section .text
    global _start

_start:
    ; Initialize stack pointer
    mov dword [stack_ptr], 0
    
    ; Get input string (simplified - would use system calls)
    mov esi, input         ; ESI points to input string
    
check_loop:
    lodsb                  ; Load byte from [ESI] into AL
    cmp al, 0              ; Check for null terminator
    je check_complete
    
    ; Check if opening parenthesis
    cmp al, '('
    je push_paren
    cmp al, '['
    je push_paren
    cmp al, '{'
    je push_paren
    
    ; Check if closing parenthesis
    cmp al, ')'
    je pop_and_match
    cmp al, ']'
    je pop_and_match
    cmp al, '}'
    je pop_and_match
    
    jmp check_loop         ; Continue if not a parenthesis

push_paren:
    ; Push opening parenthesis onto stack
    mov ebx, [stack_ptr]
    cmp ebx, stack_size    ; Check stack overflow
    jge stack_overflow
    
    mov [stack + ebx], al  ; Store character
    inc dword [stack_ptr]  ; Increment stack pointer
    jmp check_loop

pop_and_match:
    ; Pop from stack and match with closing parenthesis
    mov ebx, [stack_ptr]
    cmp ebx, 0             ; Check if stack is empty
    je unbalanced
    
    dec dword [stack_ptr]  ; Decrement stack pointer
    mov ebx, [stack_ptr]
    mov bl, [stack + ebx]  ; Get top of stack
    
    ; Match pairs
    cmp al, ')'
    jne try_bracket
    cmp bl, '('
    jne unbalanced
    jmp check_loop
    
try_bracket:
    cmp al, ']'
    jne try_brace
    cmp bl, '['
    jne unbalanced
    jmp check_loop
    
try_brace:
    cmp al, '}'
    jne unbalanced
    cmp bl, '{'
    jne unbalanced
    jmp check_loop

check_complete:
    ; Check if stack is empty (all parentheses matched)
    mov ebx, [stack_ptr]
    cmp ebx, 0
    jne unbalanced
    
    ; Print balanced message
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    mov ecx, balanced_msg
    mov edx, 27
    int 0x80
    jmp exit

unbalanced:
stack_overflow:
    ; Print unbalanced message
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    mov ecx, unbalanced_msg
    mov edx, 31
    int 0x80

exit:
    mov eax, 1             ; sys_exit
    xor ebx, ebx
    int 0x80
