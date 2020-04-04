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
extern puts

; a bunch of SDL1.2 library stuff
extern SDL_Init
extern SDL_SetVideoMode
extern SDL_FillRect
extern SDL_MapRGB
extern SDL_Flip
extern SDL_Delay
extern SDL_Quit

; custom subroutines and asst. global data
extern setup_colors
extern sdl_rect_a
extern sdl_rect_b
extern screen
extern screen_format
extern draw_rect_a
extern draw_rect_b

%define rect_a_X(v) mov [sdl_rect_a + 0], word v
%define rect_a_Y(v) mov [sdl_rect_a + 2], word v
%define rect_a_W(v) mov [sdl_rect_a + 4], word v
%define rect_a_H(v) mov [sdl_rect_a + 6], word v

%define rect_b_X(v) mov [sdl_rect_b + 0], word v
%define rect_b_Y(v) mov [sdl_rect_b + 2], word v
%define rect_b_W(v) mov [sdl_rect_b + 4], word v
%define rect_b_H(v) mov [sdl_rect_b + 6], word v

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

section .data

    proloque: db "Welcome to my olc:btb game jam entry", 10, 0x00
    ;printf_int: db "integer value: %d", 10, 0x00

section .text
_start:
    ;push rbp
    ;mov rbp, rsp

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
    mov rcx, 1073741825   ; ~~~ voodoo ~~~
    call SDL_SetVideoMode
    mov [screen], rax     ; save the returned pointer
    mov rax, [rax + 8]    ; fetch the format field
    mov [screen_format], rax ; store fetched value

    ; generate the colors used in the program
    mov rdi, color_lut_begin ; pass pointer to first color
    mov rsi, [screen_format] ; format info needed by SDL
    call setup_colors

    ; fill an SDL rect with proper data
    rect_a_X(0)   ; macro expansion gives proper offset into global SDL_Rect
    rect_a_Y(0)   ; ...
    rect_a_H(600) ; ...
    rect_a_W(800) ; ...
    mov rdi, [navy]
    call draw_rect_a

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

