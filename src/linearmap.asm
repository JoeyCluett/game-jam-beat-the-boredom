

global linearmap

section .bss

section .data

section .text

align 16
linearmap:
    ;
    ; x       : xmm0
    ; x_begin : xmm1
    ; x_end   : xmm2
    ; y_begin : xmm3
    ; y_end   : xmm4
    ;
    ; result : xmm0
    ;
    ; output = y_begin + ((y_end - y_begin) / (x_end - x_begin)) * (x - x_begin)
    ;

    ; leaf function so no need to create stack frame
    subss xmm4, xmm3 ; y_end -= y_begin
    subss xmm0, xmm1 ; x -= x_begin
    subss xmm2, xmm1 ; x_end -= x_begin

    divss xmm4, xmm2 ; y_end /= x_end
    mulss xmm4, xmm0 ; y_end *= x

    addss xmm3, xmm4 ; y_begin += y_end
    movss xmm0, xmm3 ; returned in xmm0

    ret
