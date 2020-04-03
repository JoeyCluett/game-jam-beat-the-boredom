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

; stdlib stuff
extern printf

; a bunch of SDL1.2 library stuff
extern SDL_Init
extern SDL_SetVideoMode
extern SDL_FillRect
extern SDL_MapRGB
extern SDL_Flip
extern SDL_Delay
extern SDL_Quit

extern setup_colors

section .bss
color_lut_begin:
    white:   resd 1
    black:   resd 1
    maroon:  resd 1
    red:     resd 1
    orange:  resd 1
    yellow:  resd 1
    olive:   resd 1
    purple:  resd 1
    fuschia: resd 1
    lime:    resd 1
    green:   resd 1
    navy:    resd 1
    blue:    resd 1
    aqua:    resd 1
    silver:  resd 1
    gray:    resd 1
color_lut_end:

    ; SDL_Surface ptr
    screen: resq 1
    screen_format: resq 1

    ; a single SDL_Rect is 8 bytes. save space for a few
    sdl_rect_a: resb 8
    sdl_rect_b: resb 8

section .data

    proloque: db "Welcome to my olc game jam entry", 10, 0x00
    ;printf_int: db "integer value: %d", 10, 0x00

section .text
_start:

    mov rdi, proloque
    xor rax, rax ; set AL to zero
    call printf

    ; initialize all SDL subsystems
    mov rdi, 65535 ; SDL_INIT_EVERYTHING
    call SDL_Init

    ; generate a screen
    mov rdi, 800          ; width
    mov rsi, 600          ; height
    mov rdx, 32           ; bpp (bits per pixel)
    mov rcx, 1073741825   ; options for the window
    call SDL_SetVideoMode ; 
    mov [screen], rax     ; save the returned pointer
    add rax, 8            ; advance to the format area
    mov rax, [rax]        ;  fetch and replace current value of rax
    mov [screen_format], rax ; store fetched value

    ; generate the colors used in the program
    mov rdi, color_lut_begin ; pass pointer to first color
    mov rsi, [screen_format] ; format info needed by SDL
    call setup_colors

    ; fill an SDL rect with proper data
    mov [sdl_rect_a + 0], WORD 0   ; x
    mov [sdl_rect_a + 2], WORD 0   ; y
    mov [sdl_rect_a + 4], WORD 800 ; w
    mov [sdl_rect_a + 6], WORD 600 ; h
    mov rdi, [screen]   ; SDL_Surface ptr
    mov rsi, sdl_rect_a ; SDL_Rect ptr
    mov rdx, [gray]    ; pregenerated color
    call SDL_FillRect

    mov rdi, [screen]
    call SDL_Flip

    mov rdi, 1000
    call SDL_Delay

    ; release SDL resources and quit   
    call SDL_Quit

    ; exit program
    mov rbx, 0 ; exit code: 0
    mov rax, 1 ; exit syscall number
    int 0x80   ; tell the troll we are done

