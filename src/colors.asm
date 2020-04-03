;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;

extern SDL_MapRGB
global setup_colors

section .data

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
setup_colors:
    push rbp
    mov rbp, rsp

    ; rdi : start of the color array
    ; rsi : SDL_Surface->format
    push rdi
    push rsi

    ; white 0xFFFFFF
    mov rdi, [rbp-16] ; format
    mov rsi, 0xFF ; red
    mov rdx, 0xFF ; green
    mov rcx, 0xFF ; blue
    call SDL_MapRGB
    mov rdi, [rbp-8]     ; get the base pointer for the color array
    mov [rdi], DWORD eax ; store generated color
    add rdi, 4           ; advance pointer to next color entry
    mov [rbp-8], rdi     ; replace old pointer with new pointer  

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

    mov rsp, rbp
    pop rbp    
    ret



