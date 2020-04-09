;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;

global importfontfile
global drawstring
global drawcharacter

extern fscanf
extern malloc ; thats right, dynamic memory!
extern fopen
extern fclose
extern printf
extern exit
extern puts
extern __errno_location

extern screen
extern screen_format
extern sdl_rect_a
extern sdl_rect_b
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

section .data
    readspecifier: db "r", 0x00
    readintformat: db "%d", 0x00
    fileopenerror: db "error : failed to open font file", 10, 0x00
    filereaderror: db "error : failed to read data from font file, errno: %d", 10, 0x00
    mallocamtmessage: db "allocating %d bytes for font data...", 10, 0x00
    mallocerrormsg:   db "error allocating memory...", 10, 0x00
    fileopenerrormsg: db "error opening file '%s'", 10, 0x00

    ; lazy debugging...
    readloopmessage: db "starting font read loop...", 0x00

    ; ...
    pointervalmsg: db "begin:   %ul", 10, "current: %ul", 10, "end:     %ul", 10, 0x00

section .bss
    begin:    resq 1
    current:  resq 1
    end:      resq 1
    filename: resq 1
    fptr:     resq 1 ; file handle (FILE*)
    errnoptr: resq 1 ; pointer to errno variable

section .text
align 16
importfontfile:
    push rbp
    mov rbp, rsp
    ;
    ; rdi : string containing the name of the file
    ; 
    ; pointer to new data returned in rax
    ;

    ; local variable space
    sub rsp, 32

    mov [filename], rdi   ; store filename string ptr
    call __errno_location ; get the location of errno
    mov [errnoptr], rax   ; save it elsewhere

    mov rdi, qword [filename] ; ptr to filename string
    mov rsi, readspecifier    ; "r"
    call fopen      ; FILE ptr returned in rax
    mov [fptr], rax ; store file pointer

    mov rsi, [filename] ; pass the file name to error routine to prep for printf call
    cmp rax, 0          ; fopen returns 0 on failure 
    je openfileerrexit

    ; read the size data from the file
    call readinteger
    mov dword [rsp + 0], eax ; H
    call readinteger
    mov dword [rsp + 4], eax ; W

    ; prep for the code i wrote below 
    mov edi, dword [rsp + 0] ; H
    mov esi, dword [rsp + 4] ; W

    ; figure out how many bytes are actually in the file
    xor edx, edx ; need upper 32-bits to be zero
    mov eax, edi ; move multiplicand into eax
    mul esi      ; mul specifies the multiplier    
    shl eax, 8   ; need to multiply by 256 to get the total number of bytes

    mov qword [rsp + 8], rax ; save the number of bytes

    ; print how much memory is being allocated via malloc
    mov rdi, mallocamtmessage ; format string
    mov rsi, qword [rsp + 8]  ; calculated size
    xor rax, rax              ; AL needs to be clear (varargs)
    call printf

    ; allocate memory (via malloc)
    mov rdi, qword [rsp + 8] ; amt in bytes
    call malloc
    cmp rax, 0               ; error checking
    je mallocerrexit         ; exit on error

    ; calculate values for pointers and other stuff
    mov [begin], rax         ; store start pointer
    mov [current], rax       ; iter ptr starts at the beginning
    add rax, qword [rsp + 8] ; calculate end of iteration
    mov [end], rax           ; store end iterator

  readloopstart:

    call readinteger
    mov r14, [current] ; fetch pointer from storage place
    mov [r14], byte al ; low byte
    inc r14            ; increment pointer value
    mov [current], r14 ; store pointer back in memory
    cmp r14, [end]     ; compare begin and end iterators
    jne readloopstart  ; repeat until we get to the end

    ; explicitly close resources, this isnt C++ amirite!?
    mov rdi, [fptr]
    call fclose

    ; return a pointer to allocated memory
    mov rax, [begin]

    mov rsp, rbp
    pop rbp
    ret

  openfileerrexit:
    mov rdi, fileopenerrormsg
    jmp errorhandler

  mallocerrexit:
    mov rdi, mallocerrormsg
    jmp errorhandler

  importfontexit:
    mov rdi, fileopenerror
    jmp errorhandler

align 16
readinteger:
    push rbp
    mov rbp, rsp ; rbp now points at its own previous value

    ; file pointer is already in [fptr]
    sub rsp, 16 ; some local vars

    ; prep for the read call
    xor rax, rax ; need AL to be zero
    mov rdi, [fptr]
    mov rsi, readintformat
    mov rdx, rsp ; int storage is local
    call fscanf

    cmp rax, 1 ; should have read exactly one item
    jne readfileexit

    ; mov integer into GPR
    mov eax, dword [rsp] ; li'l endian saves the day!

    mov rsp, rbp ; rsp now points at old rbp value
    pop rbp      ; replace rbp with old value
    ret          ; see ya

  readfileexit:
    mov rsi, [errnoptr] ; get ptr to errno
    mov esi, [rsi]      ; deref ptr to get errno value
    mov rdi, filereaderror
    jmp errorhandler

align 16
errorhandler:
    ;
    ; rdi : error message
    ; 

    xor rax, rax ; clear AL
    call printf
    mov rdi, 1 ; abnormal exit
    call exit

; big sad... couldnt get the font import function to work properly
align 16
drawcharacter:
    push rbp
    mov rbp, rsp
    ;
    ; rdi : char (really in dil)
    ; rsi : color (esi)
    ; rdx : x
    ; rcx : y
    ; r8  : format data ptr
    ; r9  : charsize
    ;

    sub rsp, 48

    ; preserve arguments in local stack frame
    mov qword [rsp + 0], rdi  ; char
    mov qword [rsp + 8], rsi  ; color (esi)
    mov qword [rsp + 16], rdx ; x
    mov qword [rsp + 24], rcx ; y
    mov qword [rsp + 32], r8  ; format data ptr
    mov qword [rsp + 40], r9  ; charsize

    ; for now, just print a box over the entire area
    shl r9, 3 ; multiply by 8

    rect_a_H(r9w)
    rect_a_W(r9w)
    rect_a_X(dx)
    rect_a_Y(cx)
    mov edi, esi
    call draw_rect_a

    mov rsp, rbp
    pop rbp
    ret

align 16
drawstring:
    push rbp
    mov rbp, rsp
    ;
    ; rdi : string (null-terminated)
    ; rsi : color
    ; rdx : x (top left)
    ; rcx : y
    ; r8  : format data ptr
    ; r9  : charsize
    ;

    sub rsp, 48 ; space for locals. maintain stack alignment
    
    ; preserve arguments in local stack frame
    mov qword [rsp + 0], rdi  ; string
    mov qword [rsp + 8], rsi  ; color (esi)
    mov qword [rsp + 16], rdx ; x
    mov qword [rsp + 24], rcx ; y
    mov qword [rsp + 32], r8  ; format data ptr
    mov qword [rsp + 40], r9  ; charsize

  drawstringloop:
    
    mov rdi, qword [rsp + 0]  ; get string ptr
    mov rdi, [rdi]            ; fetch char at ptr
    mov rsi, qword [rsp + 8]  ; color (esi)
    mov rdx, qword [rsp + 16] ; x
    mov rcx, qword [rsp + 24] ; y
    mov r8, qword [rsp + 32]  ; format data ptr
    mov r9, qword [rsp + 40]  ; charsize
    call drawcharacter

    mov rax, qword [rsp + 40] ; fetch charsize
    add [rsp + 16], rax       ; advance to next x position
    mov rdi, qword [rsp + 0]  ; fetch string ptr
    inc rdi                   ; advance to next character
    mov qword [rsp + 0], rdi  ; store new pointer
    cmp byte [rdi], 0         ; is this a null-terminator?
    jne drawstringloop        ; repeat until we hit null

    mov rsp, rbp
    pop rbp
    ret

