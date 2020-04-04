;
; entry for the olc game jam 2020
;
; author: Joe aka SevenSignBits
;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;

; starting location:
global _start

; avoid cluttering up main.asm
%include 'mainexterns.asm'

%define rect_a_X(v) mov [sdl_rect_a + 0], word v
%define rect_a_Y(v) mov [sdl_rect_a + 2], word v
%define rect_a_W(v) mov [sdl_rect_a + 4], word v
%define rect_a_H(v) mov [sdl_rect_a + 6], word v

%define rect_b_X(v) mov [sdl_rect_b + 0], word v
%define rect_b_Y(v) mov [sdl_rect_b + 2], word v
%define rect_b_W(v) mov [sdl_rect_b + 4], word v
%define rect_b_H(v) mov [sdl_rect_b + 6], word v

section .bss

section .data

    prologue: db "Welcome to my olc:btb game jam entry", 10, 0x00
    epilogue: db "Thanks for playing!!", 10, 0x00
    ;printf_int: db "integer value: %d", 10, 0x00

section .text
_start:
    ; not sure why but creating a stack frame here causes a segfault (likely 
    ; due to misaligned stack). im guessing this is because _start is not
    ; call'd but rather jmp'd to. no function call, no return address, 
    ; no stack misalignment
    ;push rbp
    ;mov rbp, rsp

    ; need some space for locals
    sub rsp, 16 ; maintain stack alignment

    mov rdi, prologue
    xor rax, rax ; set AL to zero
    call printf

    call clear_inputs

    ; initialize all SDL subsystems
    mov rdi, 65535 ; SDL_INIT_EVERYTHING
    call SDL_Init

    ; generate a screen
    mov rdi, 800          ; width
    mov rsi, 600          ; height
    mov rdx, 32           ; bpp (bits per pixel)
    mov rcx, 1073741825   ; ~~~ voodoo ~~~ ...jk
    call SDL_SetVideoMode
    mov [screen], rax     ; save the returned pointer
    mov rax, [rax + 8]    ; fetch the format field
    mov [screen_format], rax ; store fetched value

    ; generate the colors used in the program
    mov rdi, color_lut_begin ; pass pointer to first color
    mov rsi, [screen_format] ; format info needed by SDL
    call setup_colors

    ; save the color pointer in the stack for now
    mov qword [rsp], color_lut_begin

  main_loop:

    ; call event evaluation subroutine
    call evaluate_inputs
    mov al, [quit_p]  ; grab quit flag
    add al, [key_esc] ; add two flags together. if either of 
                      ; them is high, results will be non-zero
    cmp al, 0
    jne end_main_loop

    ; fill an SDL rect with proper data
    rect_a_X(0)   ; macro expansion gives proper offset into global SDL_Rect
    rect_a_Y(0)   ; ...
    rect_a_H(600) ; ...
    rect_a_W(800) ; ...

    mov rax, [rsp]       ; grab color ptr from the stack
    mov edi, dword [rax] ; deref that pointer to get a color
    call draw_rect_a

    mov rax, [rsp] ; update color
    add rax, 8     ; advance to next SDL color
    mov [rsp], rax ; store new pointer

    cmp rax, color_lut_end     ; compare current ptr to end ptr
    jne main_flip_screen       ; if we are not to the end, skip next instruction
    mov qword [rsp], color_lut_begin ; otherwise reset the color ptr

  main_flip_screen:
    mov rdi, [screen]
    call SDL_Flip

    mov rdi, 100   ; delay for a short time
    call SDL_Delay

    jmp main_loop

  end_main_loop:
    ; release SDL resources and quit   
    call SDL_Quit

    mov rdi, epilogue
    xor rax, rax ; set AL to zero
    call printf

    ; exit program
    mov rbx, 0 ; exit code: 0
    mov rax, 1 ; exit syscall number
    int 0x80   ; tell the troll we are done

