;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;

extern SDL_MapRGB
global setup_colors

global color_lut_begin
global color_lut_end
global white
global black
global maroon
global red
global orange
global yellow
global olive
global purple
global fuschia
global lime
global green
global navy
global blue
global aqua
global silver
global gray
global brown
global gold

section .data

section .bss
color_lut_begin:
    white:   resd 2
    black:   resd 2
    maroon:  resd 2
    red:     resd 2
    orange:  resd 2
    yellow:  resd 2
    olive:   resd 2
    purple:  resd 2
    fuschia: resd 2
    lime:    resd 2
    green:   resd 2
    navy:    resd 2
    blue:    resd 2
    aqua:    resd 2
    silver:  resd 2
    gray:    resd 2
    brown:   resd 2
    gold:    resd 2
color_lut_end:

section .text

; 0:  white  
; 1:  black  
; 2:  maroon 
; 3:  red    
; 4:  orange 
; 5:  yellow 
; 6:  olive  
; 7:  purple 
; 8:  fuschia
; 9:  lime   
; 10: green  
; 11: navy   
; 12: blue   
; 13: aqua   
; 14: silver 
; 15: gray   
; 16: brown
setup_colors:
    push rbp     ; create stack frame and re-align stack
    mov rbp, rsp ; ...

    ; rdi : start of the color array
    ; rsi : SDL_Surface->format
    push rdi ; save both of these pieces of information
    push rsi ; ...

    ; white 0xFFFFFF
    mov rdi, [rbp-16] ; format
    mov rsi, 0xFF ; red
    mov rdx, 0xFF ; green
    mov rcx, 0xFF ; blue
    call SDL_MapRGB   ; new color is now in rax
    mov rdi, [rbp-8]     ; get the base pointer for the color array
    mov [rdi], DWORD eax ; store generated color
    add rdi, 4           ; advance pointer to next color entry
    mov [rbp-8], rdi     ; replace old pointer with new pointer  

    ; SDL_gfxPrimitives library needs different color format:
    mov [rdi], DWORD 0xFFFFFFFF ; RGBA
    add rdi, 4       ; advance pointer
    mov [rbp-8], rdi ; store new pointer
    
    ; black 0x000000
    mov rdi, [rbp-16]
    mov rsi, 0x00
    mov rdx, 0x00
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi    

        ; gfxP
    mov [rdi], DWORD 0x000000FF
    add rdi, 4
    mov [rbp-8], rdi

    ; maroon 0x800000
    mov rdi, [rbp-16]
    mov rsi, 0x80
    mov rdx, 0x00
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x800000FF
    add rdi, 4
    mov [rbp-8], rdi

    ; red 0xFF0000
    mov rdi, [rbp-16]
    mov rsi, 0xFF
    mov rdx, 0x00
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0xFF0000FF
    add rdi, 4
    mov [rbp-8], rdi

    ; orange 0xFFA500
    mov rdi, [rbp-16]
    mov rsi, 0xFF
    mov rdx, 0xA5
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0xFFA500FF
    add rdi, 4
    mov [rbp-8], rdi

    ; yellow 0xFFFF00
    mov rdi, [rbp-16]
    mov rsi, 0xFF
    mov rdx, 0xFF
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0xFFFF00FF
    add rdi, 4
    mov [rbp-8], rdi

    ; olive 0x808000
    mov rdi, [rbp-16]
    mov rsi, 0x80
    mov rdx, 0x80
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x808000FF
    add rdi, 4
    mov [rbp-8], rdi

    ; purple 0x800080
    mov rdi, [rbp-16]
    mov rsi, 0x80
    mov rdx, 0x00
    mov rcx, 0x80
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x800080FF
    add rdi, 4
    mov [rbp-8], rdi

    ; fuscia 0xFF00FF
    mov rdi, [rbp-16]
    mov rsi, 0xFF
    mov rdx, 0x00
    mov rcx, 0xFF
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0xFF00FFFF
    add rdi, 4
    mov [rbp-8], rdi

    ; lime 0x00FF00
    mov rdi, [rbp-16]
    mov rsi, 0x00
    mov rdx, 0xFF
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x00FF00FF
    add rdi, 4
    mov [rbp-8], rdi

    ; green 0x008000
    mov rdi, [rbp-16]
    mov rsi, 0x00
    mov rdx, 0x80
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x008000FF
    add rdi, 4
    mov [rbp-8], rdi

    ; navy 0x000080
    mov rdi, [rbp-16]
    mov rsi, 0x00
    mov rdx, 0x00
    mov rcx, 0x80
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x000080FF
    add rdi, 4
    mov [rbp-8], rdi

    ; blue 0x0000FF
    mov rdi, [rbp-16]
    mov rsi, 0x00
    mov rdx, 0x00
    mov rcx, 0xFF
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x0000FFFF
    add rdi, 4
    mov [rbp-8], rdi

    ; aqua 0x00FFFF
    mov rdi, [rbp-16]
    mov rsi, 0x00
    mov rdx, 0xFF
    mov rcx, 0xFF
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x00FFFFFF
    add rdi, 4
    mov [rbp-8], rdi

    ; silver 0xC0C0C0
    mov rdi, [rbp-16]
    mov rsi, 0xC0
    mov rdx, 0xC0
    mov rcx, 0xC0
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0xC0C0C0FF
    add rdi, 4
    mov [rbp-8], rdi

    ; gray 0x808080
    mov rdi, [rbp-16]
    mov rsi, 0x80
    mov rdx, 0x80
    mov rcx, 0x80
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x808080FF
    add rdi, 4
    mov [rbp-8], rdi

    ; brown 0x8B4513
    mov rdi, [rbp-16]
    mov rsi, 0x8B
    mov rdx, 0x45
    mov rcx, 0x13
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0x8B4513FF
    add rdi, 4
    mov [rbp-8], rdi

    ; gold 0xFFDF00
    mov rdi, [rbp-16]
    mov rsi, 0xFF
    mov rdx, 0xDF
    mov rcx, 0x00
    call SDL_MapRGB
    mov rdi, [rbp-8]    
    mov [rdi], DWORD eax
    add rdi, 4          
    mov [rbp-8], rdi   

        ; gfxP
    mov [rdi], DWORD 0xFFDF00FF
    add rdi, 4
    mov [rbp-8], rdi

    mov rsp, rbp
    pop rbp    
    ret



