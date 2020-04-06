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

global ticks

section .bss

    ticks: resd 1

section .data

    prologue: db "Welcome to my olc:btb game jam entry", 10, 0x00
    epilogue: db "Thanks for playing!!", 10, 0x00
    clickmessage: db "Mouse click!", 10, 0x00

section .text
_start:
    ; not sure why but creating a stack frame here causes a segfault (likely 
    ; due to misaligned stack). im guessing this is because _start is not
    ; call'd but rather jmp'd to. no function call, no return address, 
    ; no stack misalignment
    ;push rbp
    ;mov rbp, rsp

    ; need some space for locals
    sub rsp, 32 ; maintain stack alignment

    mov rdi, prologue
    xor rax, rax ; set AL to zero
    call printf

    call clear_inputs

    ; initialize all SDL subsystems
    mov rdi, 65535 ; SDL_INIT_EVERYTHING
    call SDL_Init

    xor rdi, rdi ; SDL_DISABLE
    call SDL_ShowCursor

    ; generate a screen
    mov rdi, 800          ; width
    mov rsi, 600          ; height
    mov rdx, 32           ; bpp (bits per pixel)
    ;mov rcx, 1073741825   ; ~~~ voodoo ~~~ ...jk
    mov rcx, 3221225473    ; ~~~ voodoo ~~~ ...but in fullscreen
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
    ;xor rdi, rdi ; evaluate_inputs expects a callback in rdi. wont call a nullptr tho (pfft... obviously)
    mov rdi, mouse_click_callback
    call evaluate_inputs

    ; evaluate_inputs updates all the input flags
    mov al, [quit_p]  ; grab quit flag
    add al, [key_esc] ; add two flags together. if either of 
                      ; them is high, result will be non-zero
    cmp al, 0
    jne end_main_loop

    ; update tick count
    call SDL_GetTicks
    mov [ticks], eax

    ; base to draw on
    call draw_stage

    ; draw a cross to follow the mouse pointer around
    ; draw vertical bar
    mov ax, word [mouse_X] ; works because little-endian is heckin awesome
    mov bx, word [mouse_Y] ; ...
    sub bx, 30 ; modify Y coordinate
    rect_a_X(ax)
    rect_a_Y(bx)
    rect_a_H(60)
    rect_a_W(1)
    mov edi, dword [white]
    call draw_rect_a

    ; draw the horizontal bar
    mov ax, word [mouse_X]
    mov bx, word [mouse_Y]
    sub ax, 30 ; modify X coordinates
    rect_a_X(ax)
    rect_a_Y(bx)
    rect_a_H(1)
    rect_a_W(60)
    mov edi, dword [white]
    call draw_rect_a

    ; draw...trees
    call draw_trees

  main_flip_screen:
    mov rdi, [screen]
    call SDL_Flip

    mov rdi, 15   ; delay for a short time. framerate regulation has no power here
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

align 16
draw_trees:
    push rbp
    mov rbp, rsp

    ;mov rdi, 400
    ;mov rsi, 300
    ;mov edx, dword [green + 4]
    ;call draw_tree

    mov rsp, rbp
    pop rbp
    ret

align 16
mouse_click_callback:
    push rbp
    mov rbp, rsp
    ; start body of callback
    ;
    ; the global SDL_Event structure is still in valid 
    ; state during this callback and the mouse position 
    ; was updated before the callback was called
    ;

    cmp [sdl_event], byte 5      ; SDL_MOUSEBUTTONDOWN
    jne end_mouse_click_callback ; ignore SDL_MOUSEBUTTONUP

    ; for now, just print a nice message
    mov rdi, clickmessage
    xor rax, rax
    call printf

  end_mouse_click_callback:
    ; end body of callback
    mov rsp, rbp
    pop rbp
    ret

