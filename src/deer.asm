;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;

global draw_deer
global testhitdeer
global removedeer

extern deer_upper_left
extern deer_upper_right
extern deer_lower_left
extern deer_lower_right

extern brown     ; color of the deer
extern darkbrown ; ...
extern white
extern black
extern beige

%define rect_a_X(v) mov [sdl_rect_a + 0], word v
%define rect_a_Y(v) mov [sdl_rect_a + 2], word v
%define rect_a_W(v) mov [sdl_rect_a + 4], word v
%define rect_a_H(v) mov [sdl_rect_a + 6], word v

%define rect_b_X(v) mov [sdl_rect_b + 0], word v
%define rect_b_Y(v) mov [sdl_rect_b + 2], word v
%define rect_b_W(v) mov [sdl_rect_b + 4], word v
%define rect_b_H(v) mov [sdl_rect_b + 6], word v

%define deersize 40

extern sdl_rect_a
extern sdl_rect_b
extern draw_rect_a
extern draw_rect_b

section .bss
section .data

section .text
align 16
draw_deer:
    push rbp
    mov rbp, rsp

    ; space for locals
    ;sub rsp, 16

    mov rdi, deer_lower_right
    call drawsingledeer

    mov rdi, deer_lower_left
    call drawsingledeer

    mov rdi, deer_upper_right
    call drawsingledeer

    mov rdi, deer_upper_left
    call drawsingledeer

    ;rect_a_H(40)
    ;rect_a_W(40)
    ;mov eax, [deer_lower_right + 0] ; upper left X
    ;rect_a_X(ax)
    ;mov eax, [deer_lower_right + 4] ; upper left Y
    ;rect_a_Y(ax)
    ;mov edi, dword [brown]
    ;call draw_rect_a

    ;rect_a_H(40)
    ;rect_a_W(40)
    ;mov eax, [deer_upper_left + 0] ; upper left X
    ;rect_a_X(ax)
    ;mov eax, [deer_upper_left + 4] ; upper left Y
    ;rect_a_Y(ax)
    ;mov edi, dword [brown]
    ;call draw_rect_a

    ;rect_a_H(40)
    ;rect_a_W(40)
    ;mov eax, [deer_lower_left + 0] ; upper left X
    ;rect_a_X(ax)
    ;mov eax, [deer_lower_left + 4] ; upper left Y
    ;rect_a_Y(ax)
    ;mov edi, dword [brown]
    ;call draw_rect_a

    ;rect_a_H(40)
    ;rect_a_W(40)
    ;mov eax, [deer_upper_right + 0] ; upper left X
    ;rect_a_X(ax)
    ;mov eax, [deer_upper_right + 4] ; upper left Y
    ;rect_a_Y(ax)
    ;mov edi, dword [brown]
    ;call draw_rect_a

    mov rsp, rbp
    pop rbp
    ret

align 16
drawsingledeer:
    push rbp
    mov rbp, rsp
    ;
    ; rdi : deer position ptr (X/Y)
    ;

    sub rsp, 16
    mov qword [rsp + 0], rdi

    ; draw first dark leg
    rect_a_H(40)
    rect_a_W(5)
    mov eax, dword [rdi + 0] ; X
    add eax, 12
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    rect_a_Y(ax)
    mov edi, dword [darkbrown]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw second dark leg
    rect_a_H(40)
    rect_a_W(5)
    mov eax, dword [rdi + 0] ; X
    add eax, 23
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    rect_a_Y(ax)
    mov edi, dword [darkbrown]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw first light leg
    rect_a_H(40)
    rect_a_W(5)
    mov eax, dword [rdi + 0] ; X
    add eax, 3
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    rect_a_Y(ax)
    mov edi, dword [brown]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw second light leg
    rect_a_H(40)
    rect_a_W(5)
    mov eax, dword [rdi + 0] ; X
    add eax, 32
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    rect_a_Y(ax)
    mov edi, dword [brown]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw first part of tail
    rect_a_H(3)
    rect_a_W(7)
    mov eax, dword [rdi + 0] ; X
    add eax, 40 ; adjust X
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    add eax, 10 ; adjust Y
    rect_a_Y(ax)
    mov edi, dword [brown]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw second part of tail
    rect_a_H(1)
    rect_a_W(5)
    mov eax, dword [rdi + 0] ; X
    add eax, 40 ; adjust X
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    add eax, 13 ; adjust Y
    rect_a_Y(ax)
    mov edi, dword [white]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw neck
    rect_a_H(15)
    rect_a_W(8)
    mov eax, dword [rdi + 0] ; X
    add eax, -1
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    add eax, -10
    rect_a_Y(ax)
    mov edi, dword [brown]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw first antler
    rect_a_H(11)
    rect_a_W(3)
    mov eax, dword [rdi + 0] ; X
    add eax, 5
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    add eax, -23
    rect_a_Y(ax)
    mov edi, dword [beige]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw second antler
    rect_a_H(3)
    rect_a_W(11)
    mov eax, dword [rdi + 0] ; X
    add eax, 6
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    add eax, -13
    rect_a_Y(ax)
    mov edi, dword [beige]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw head
    rect_a_H(11)
    rect_a_W(18)
    mov eax, dword [rdi + 0] ; X
    add eax, -8
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    add eax, -14
    rect_a_Y(ax)
    mov edi, dword [brown]
    call draw_rect_a

    mov rdi, qword [rsp + 0]

    ; draw main body
    rect_a_H(15)
    rect_a_W(40)
    mov eax, dword [rdi + 0] ; X
    rect_a_X(ax)
    mov eax, dword [rdi + 4] ; Y
    rect_a_Y(ax)
    mov edi, dword [brown]
    call draw_rect_a

    mov rsp, rbp
    pop rbp
    ret

align 16
removedeer:
    ;
    ; rdi : pointer to deer (X/Y)
    ;

    ; leaf routine so no stack frame

    mov dword [rdi], -200
    mov dword [rdi + 4], -200
    ret

align 16
testhitdeer:
    ;
    ; rdi : pointer to deer position (X/Y)
    ; rsi : xpos
    ; rdx : ypos
    ;
    
    xor rax, rax ; zero out return register
    mov r8d, dword [rdi + 0] ; X start for deer
    mov r9d, dword [rdi + 4] ; Y start for deer

    cmp esi, r8d    ; compare Xpos to Xdeer
    jl testdeernone ; signed jump-if
    inc rax

  testdeery:
    cmp edx, r9d    ; compare Ypos to Ydeer
    jl testdeernone ; signed jump-if
    inc rax

    ; add 40 to deer position to get maximums
    add r8d, 40 ; add to X
    add r9d, 40 ; add to Y

  testdeerxmax:
    cmp r8d, esi ; compare Xdeermax to Xpos
    jl testdeernone
    inc rax

  testdeerymax:
    cmp r9d, edx ; compare Ydeermax to Ypos
    jl testdeernone ; jump if Ypos to too large
    inc rax

  testdeernone:
    xor rbx, rbx ; might need a zero-source later
    cmp rax, 4   ; if all comparisons were true, rax should be 4
    cmovl ax, bx ; make ax zero if less than 4
    ret
