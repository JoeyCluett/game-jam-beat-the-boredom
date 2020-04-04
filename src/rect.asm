
; just some stuff its nice to have globally
global sdl_rect_a
global sdl_rect_b
global screen
global screen_format
global draw_rect_a
global draw_rect_b

extern SDL_FillRect

section .bss
    ; a single SDL_Rect is 8 bytes. save space for a few
    sdl_rect_a: resb 8
    sdl_rect_b: resb 8

    ; SDL_Surface ptr
    screen: resq 1
    screen_format: resq 1

section .data

section .text
draw_rect_a:
    ; quick way to align stack
    sub rsp, 8

    ; rdi : color of rectangle
    mov rdx, rdi
    mov rdi, [screen]
    mov rsi, sdl_rect_a
    call SDL_FillRect

    add rsp, 8
    ret

draw_rect_b:
    sub rsp, 8

    mov rdx, rdi
    mov rdi, [screen]
    mov rsi, sdl_rect_b
    call SDL_FillRect

    add rsp, 8
    ret
