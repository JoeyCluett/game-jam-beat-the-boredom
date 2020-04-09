;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;

; just some stuff its nice to have globally
global sdl_rect_a
global sdl_rect_b
global screen
global screen_format
global draw_rect_a
global draw_rect_b
global draw_tree
global draw_stage

extern ticks
extern linearmap

extern SDL_FillRect
extern SDL_GetTicks
extern filledPolygonColor ; part of the SDL_gfxPrimitives
extern filledTrigonColor  ; ...
extern filledCircleColor  ; ...
extern lineColor          ; ...
extern color_lut_begin
extern green
extern brown
extern gray
extern yellow
extern white
extern silver
extern gold
extern black

%define rect_a_X(v) mov [sdl_rect_a + 0], word v
%define rect_a_Y(v) mov [sdl_rect_a + 2], word v
%define rect_a_W(v) mov [sdl_rect_a + 4], word v
%define rect_a_H(v) mov [sdl_rect_a + 6], word v

%define rect_b_X(v) mov [sdl_rect_b + 0], word v
%define rect_b_Y(v) mov [sdl_rect_b + 2], word v
%define rect_b_W(v) mov [sdl_rect_b + 4], word v
%define rect_b_H(v) mov [sdl_rect_b + 6], word v

section .bss
    ; a single SDL_Rect is 8 bytes. save space for a few
    sdl_rect_a: resb 8
    sdl_rect_b: resb 8

    ; SDL_Surface ptr
    screen: resq 1
    screen_format: resq 1

section .data
align 16
; tree data : x   y    x   y    x   y
    t1: dw    0, 30,  -4, 20,   4, 20
    t2: dw   -2, 20,   2, 20,  -7, 10
    t3: dw    2, 20,  -7, 10,   7, 10 
    t4: dw   -5, 10,   5, 10, -10, 0
    t5: dw    5, 10, -10,  0,  10, 0
    t_none:

; road data : x y x y x y
    road1: dw 350, 300, 450, 300, 300, 600
    road2: dw 450, 300, 300, 600, 500, 600
    r_none:

    _320: dd 320.0
    _550: dd 550.0
    _615: dd 615.0
    _250: dd 250.0
    _185: dd 185.0

align 16
draw_tree:
    push rbp
    mov rbp, rsp
    ; rdi : x
    ; rsi : y
    ; edx : color

    ; need some space for locals
    sub rsp, 64

    ; store our arguments where we can get them easily
    mov qword [rsp + 16], rdi ; X
    mov qword [rsp + 24], rsi ; Y
    mov qword [rsp + 32], rdx ; color

    ;
    ; filledTrigonColor
    ;   rdi  : SDL_Surface ptr
    ;   rsi  : x1
    ;   rdx  : y1
    ;   rcx  : x2
    ;   r8   : y2
    ;   r9   : x3
    ;   push : y3
    ;   push : color
    ;      (no padding needed)
    ;   remove stack args after subroutine returns
    ;

    ; preserve that which needs preservation
    mov qword [rsp + 40], r14
    mov qword [rsp + 48], r13

    mov r14, qword t1 ; point to first triangle coord array

  draw_tree_loop:
    movsx rsi, word [r14 + 0]  ; x1
    movsx rdx, word [r14 + 2]  ; y1
    movsx rcx, word [r14 + 4]  ; x2
    movsx r8,  word [r14 + 6]  ; y2
    movsx r9,  word [r14 + 8]  ; x3 <- last register arg to filledTrigonColor
    movsx r13, word [r14 + 10] ; y3 <- needs to be placed on the stack

    add r14, 12 ; advance to next triangle
                ; r14 is callee preserved

    ; y coords need to be negated
    neg rdx
    neg r8
    neg r13

    ; multiply everything by 2
    shl rsi, 1 
    shl rdx, 1
    shl rcx, 1
    shl r8,  1
    shl r9,  1
    shl r13, 1
    ; optimization... now thats a word I havent heard in a long time

    ; fetch the offset from its local storage
    mov r10, qword [rsp + 16] ; tmp Xoffset
    mov r11, qword [rsp + 24] ; tmp Yoffset

    add rsi, r10 ; x1 + Xoff
    add rdx, r11 ; y1 + Yoff
    add rcx, r10 ; x2 + Xoff
    add r8,  r11 ; y2 + Yoff
    add r9,  r10 ; x3 + Xoff
    add r13, r11 ; y3 + Yoff

    mov rdi, [screen]  ; SDL_Surface ptr
        ; remaining arguments are passed on the stack in right-to-left 
        ; order (so last arg is pushed first)
    push qword [rsp + 32] ; fetch and push the color (last argument)
    push r13              ; y3, needs to be on the stack (penultimate argument)
    call filledTrigonColor
    add rsp, 16 ; destroy temorary arguments to filledTrigonColor (y3 and color)

    cmp r14, t_none    ; end of triangles
    jne draw_tree_loop ; loop through all triangles

    ; need to draw brown trunk of tree
    mov r10, qword [rsp + 16] ; X
    mov r11, qword [rsp + 24] ; Y
    sub r10, 4 ; apply small x offset to base
    inc r11    ; apply small y offset to base

    ; SDL_Rect describing the tree trunk
    rect_a_X(r10w)
    rect_a_Y(r11w)
    rect_a_H(10)
    rect_a_W(8)
    mov edi, dword [brown + 0]
    call draw_rect_a

    ; restore certain registers
    mov r14, qword [rsp + 40]
    mov r13, qword [rsp + 48]

    mov rsp, rbp
    pop rbp
    ret

align 16
draw_stage:

    sub rsp, 24

    ; set the background
    rect_b_X(0)
    rect_b_Y(0)
    rect_b_H(600)
    rect_b_W(800)
    mov edi, dword [gray]
    call draw_rect_b

    ;   rdi, rsi, rdx, rcx, r8, r9
    ; draw the sunrise
    mov rdi, [screen]
    mov si, 400
    mov dx, 375
    mov cx, 150
    mov r8d, dword [gold + 4]
    call filledCircleColor

    ; draw the foreground
    rect_b_X(0)
    rect_b_Y(300)
    rect_b_H(300)
    rect_b_W(800)
    mov edi, dword [silver]
    call draw_rect_b

    ; draw the road in the center
    mov rdi, [screen]
    movsx rsi, word [road1 + 0]  ; x1
    movsx rdx, word [road1 + 2]  ; y1
    movsx rcx, word [road1 + 4]  ; x2
    movsx r8,  word [road1 + 6]  ; y2
    movsx r9,  word [road1 + 8]  ; x3 <- last register arg to filledTrigonColor
    movsx r13, word [road1 + 10] ; y3 <- needs to be placed on the stack
    push qword [black + 4] ; color
    push r13               ; y3
    call filledTrigonColor
    add rsp, 16 ; readjust stack

    ; second triangle for road
    mov rdi, [screen]
    movsx rsi, word [road2 + 0]  ; x1
    movsx rdx, word [road2 + 2]  ; y1
    movsx rcx, word [road2 + 4]  ; x2
    movsx r8,  word [road2 + 6]  ; y2
    movsx r9,  word [road2 + 8]  ; x3 <- last register arg to filledTrigonColor
    movsx r13, word [road2 + 10] ; y3 <- needs to be placed on the stack
    push qword [black + 4] ; color
    push r13               ; y3
    call filledTrigonColor
    add rsp, 16 ; readjust stack

    ; draw lines on the side of the road
    ;
    ; lineColor()
    ;   rdi : SDL_Surface ptr
    ;   rsi : x1
    ;   rdx : y1
    ;   rcx : x2
    ;   r8  : y2
    ;   r9  : color
    ;

    ; left hand line
    mov rdi, [screen]
    mov si, 360  ; x1
    mov dx, 300  ; y1 (centerline)
    mov cx, 320  ; x2
    mov r8w, 600 ; y2 (bottom)
    mov r9d, [white + 4]
    call lineColor

    ; right hand line
    mov rdi, [screen]
    mov si, 440  ; x1
    mov dx, 300  ; y1 (centerline)
    mov cx, 480  ; x2
    mov r8w, 600 ; y2 (bottom)
    mov r9d, [white + 4]
    call lineColor

    ; calculate the offset used to draw the center lines in the road
    mov eax, [ticks]
    shr eax, 3 ; divide by 8
    xor edx, edx ; yeah...division on AMD64 is not pretty
    mov ebx, 80  ; setup the divisor (because there is no div imm)
    div ebx      ; eax=quotient, edx=remainder
    mov eax, edx ; overwrite the quotient with le remainder
    add eax, 300 ; start in the center

    ; draw a bunch of lines in the center of the road
    mov qword [rsp], rax
    add rax, 400             ; enough for 4 lines
    mov qword [rsp + 8], rax ; used for loop termination later
    mov rax, [rsp]           ; get correct offset value

  center_line_loop:
    rect_b_X(398)
    rect_b_Y(ax)
    rect_b_H(50)
    rect_b_W(4)
    mov edi, [white]
    call draw_rect_b

    mov rax, qword [rsp] ; restore rax
    add rax, 80          ; go to next iteration
    mov qword [rsp], rax ; update stored loop value

    cmp rax, qword [rsp + 8] ; test against termination value
    jne center_line_loop     ; repeat until termination


    ; draw some trees!
    xor rdi, rdi ; offset=0
    xor rsi, rsi ; left=0
    call draw_tree_w_offset

    mov rdi, 160 ; offset=160
    xor rsi, rsi ; left=0
    call draw_tree_w_offset

    mov rdi, 80 ; offset=80
    mov rsi, 1  ; right=1
    call draw_tree_w_offset

    mov rdi, 240 ; offset=240
    mov rsi, 1   ; right=1
    call draw_tree_w_offset

    add rsp, 24
    ret

align 16
draw_tree_w_offset:
    sub rsp, 8
    ;
    ; rdi : local offset
    ; rsi : 0=left, 1=right
    ;

    mov eax, [ticks]
    shr eax, 3
    add eax, edi ; given deg offset from 'normal'
    xor edx, edx ; need to zero this register
    mov ebx, 320 ; divisor
    div ebx      ; eax=quotient, edx=remainder
    mov eax, edx ; get the remainder

    cmp rsi, 0
    jne map_right_side

    ; use linearmap to place trees at correct places
    cvtsi2ss xmm0, eax ; x
    xorps xmm1, xmm1   ; x_begin, place 0.0f in xmm1
    movss xmm2, [_320] ; x_end, 300
    movss xmm3, [_250] ; y_begin
    movss xmm4, [_185] ; y_end
    call linearmap
    jmp mapping_done

  map_right_side:
    cvtsi2ss xmm0, eax ; x
    xorps xmm1, xmm1   ; x_begin, place 0.0f in xmm1
    movss xmm2, [_320] ; x_end, 300
    movss xmm3, [_550] ; y_begin
    movss xmm4, [_615] ; y_end
    call linearmap

  mapping_done:
    ; place x,y,color and call draw_tree
    cvttss2si edi, xmm0  ; mapped value is in xmm0
    mov esi, eax         ; y
    add esi, 300         ; y+300 to put in bottom half of screen
    mov edx, [green + 4] ; this is useless but i dont want to rewrite draw_tree
    call draw_tree

    add rsp, 8
    ret

align 16
draw_rect_a:
    ; quick way to align stack
    sub rsp, 8
    ;
    ; rdi : color of rectangle
    ;

    mov rdx, rdi
    mov rdi, [screen]
    mov rsi, sdl_rect_a
    call SDL_FillRect

    add rsp, 8
    ret

align 16
draw_rect_b:
    sub rsp, 8

    mov rdx, rdi
    mov rdi, [screen]
    mov rsi, sdl_rect_b
    call SDL_FillRect

    add rsp, 8
    ret
