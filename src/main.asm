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

%define deersize 40

global ticks
global deer_upper_left
global deer_upper_right
global deer_lower_left
global deer_lower_right

section .bss

    ticks: resd 1
    clicks: resd 1 ; count of number of times mouse has been clicked

    ; pointers to raw font data
    fontptr: resq 1

    deer_upper_left:  resd 2 ; x/y ints (half)
    deer_upper_right: resd 2 ; x/y ints (full)
    deer_lower_left:  resd 2 ; x/y ints (full)
    deer_lower_right: resd 2 ; x/y ints (half)
    deer_end: ; end iterator for deer positions

    deer_half_tick: resd 1 ; 500ms
    deer_full_tick: resd 1 ; 1000ms

    state_half_tick: resd 1
    state_full_tick: resd 1

    points: resd 1  ; increment when deer is hit
    time: resd 1    ; time remaining in the round
    maxtime: resd 1 ; when SDL_GetTicks reaches this mark, time is up

    ; simple state machine to update deer position
    state_deer_update: resq 2 ; (full):(half)

    cbuffer: resb 64 ; character

section .data

    prologue: db "Welcome to my olc:btb game jam entry", 10, 0x00
    epilogue: db "Thanks for playing!!", 10, "You scored %d points!", 10, 0x00
    clickmessage: db "Mouse click!", 10, 0x00
    intconvert: db "POINTS %d", 0x00
    inttimeformat: db "TIME %d", 0x00

    fontdata_filename: db "assets/fontdata.txt", 0x00

section .text
align 16
_start:
    ; not sure why but creating a stack frame here causes a segfault (likely 
    ; due to misaligned stack). im guessing this is because _start is not
    ; call'd but rather jmp'd to. no function call, no return address, 
    ; no stack misalignment
    ;
    ; UPDATE: after some work with gdb, i have verfified that _start is jmp'd to. 
    ; when this routine starts, there is no stack frame (no backtrace anyway)
    ;
    ;push rbp
    ;mov rbp, rsp

    ; need some space for locals
    sub rsp, 32 ; maintain stack alignment

    mov rdi, prologue
    xor rax, rax ; set AL to zero
    call printf

    call clear_inputs

    ; setup state machine for drawing deer on screen
    mov qword [state_deer_update + 0], eval_deer_full_A ; each state swaps to other when needed
    mov qword [state_deer_update + 8], eval_deer_half_B ; ...

    ; read in font data
    mov rdi, fontdata_filename ; specify filename containing font data
    call importfontfile        ; load font data into memory
    mov [fontptr], rax         ; save the font data ptr locally

    ; initialize all SDL subsystems
    mov rdi, 65535 ; SDL_INIT_EVERYTHING
    call SDL_Init

    ; set initial conditions for deer ticks (haha)
    mov [deer_half_tick], dword 500  ; this offset follows the deer the whole game
    mov [deer_full_tick], dword 1250 ; ...

    xor rdi, rdi ; SDL_DISABLE=0
    call SDL_ShowCursor

    ; generate a screen
    mov rdi, 800          ; width
    mov rsi, 600          ; height
    mov rdx, 32           ; bpp (bits per pixel)
    mov rcx, 1073741825   ; ~~~ voodoo ~~~ ...jk
    ;mov rcx, 3221225473    ; ~~~ voodoo ~~~ ...but in fullscreen
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

    ; set a point when the game ends
    call SDL_GetTicks ; get ticks after game is setup
    add rax, 10000    ; calculate when the game should end (10s)
    mov dword [maxtime], eax ; store end time for game

    call eval_time_left
    mov dword [time], eax ; move current time left into storage

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

    ; draw deer
    call draw_deer          ; uses state machine internally to generate positions
    call eval_deer_position ; evaluate new position for next frame (time sensitive)

    ; draw a cross to follow the mouse pointer around
    ; draw vertical bar
    mov ax, word [mouse_X] ; works because little-endian is heckin awesome
    mov bx, word [mouse_Y] ; ...
    sub bx, 30 ; modify Y coordinate
    rect_a_X(ax)
    rect_a_Y(bx)
    rect_a_H(60)
    rect_a_W(1)
    mov edi, dword [red]
    call draw_rect_a

    ; draw the horizontal bar
    mov ax, word [mouse_X]
    mov bx, word [mouse_Y]
    sub ax, 30 ; modify X coordinates
    rect_a_X(ax)
    rect_a_Y(bx)
    rect_a_H(1)
    rect_a_W(60)
    mov edi, dword [red]
    call draw_rect_a

    ; display the number of points

    sub rsp, 64  ; make space on stack

    mov rdi, rsp ; move buffer ptr
    add rdi, 64  ; move buffer ptr to beginning
    mov rsi, 64  ; no of bytes to zero out
    call bzero

    mov rdi, rsp ; move char buffer ptr
    add rdi, 64  ; adjust buffer pointer to beginning
    mov rsi, intconvert ; points format string
    mov edx, dword [points]
    xor rax, rax ; AL needs to be zero
    call sprintf

    mov rdi, [screen] ; SDL_Surface ptr
    mov si, 50 ; x
    mov dx, 50 ; y
    lea rcx, [rsp + 64]
    mov r8d, dword [black + 4]    
    call stringColor

    ; display the number of seconds left

    ;sub rsp, 64  ; make space on stack
    mov rdi, rsp ; move buffer ptr
    add rdi, 64  ; move buffer ptr to beginning
    mov rsi, 64  ; no of bytes to zero out
    call bzero

    mov rdi, rsp ; move char buffer ptr
    add rdi, 64  ; adjust buffer pointer to beginning
    mov rsi, inttimeformat ; points format string
    mov edx, dword [time]
    xor rax, rax ; AL needs to be zero
    call sprintf

    mov rdi, [screen] ; SDL_Surface ptr
    mov si, 50  ; x
    mov dx, 100 ; y
    lea rcx, [rsp + 64]
    mov r8d, dword [black + 4]    
    call stringColor

    add rsp, 64 ; destroy buffer space on stack

  main_flip_screen:
    mov rdi, [screen] ; SDL_Surface ptr
    call SDL_Flip

    mov rdi, 15   ; delay for a short time. framerate regulation has no power here
    call SDL_Delay

    call eval_time_left   ; find number of seconds left
    mov dword [time], eax ; move current time left into storage
    cmp eax, 0
    jne main_loop  ; repeat while we have time left
    ;jmp main_loop ; game didnt quit so repeat the loop

  end_main_loop:
    ; release SDL resources and quit   
    call SDL_Quit

    mov rdi, epilogue
    mov esi, dword [points] ; specify the number of points scored
    xor rax, rax            ; set AL to zero (varargs)
    call printf

    ; exit program
    mov rbx, 0 ; exit code: 0
    mov rax, 1 ; exit syscall number
    int 0x80   ; tell the troll we are done

align 16
eval_time_left:
    mov ecx, [maxtime]     ; load max time
    sub ecx, dword [ticks] ; subtract current time
    xor r11, r11    ; might need a zero later
    cmp ecx, 0      ; compare time left with 0
    cmovle rax, r11 ; if there is no time left, mov 0 into return register
    jle evaltimeleftdone ; skip the next part if there is zero time left

    ; find the number of full seconds left. time for one of two actual divides in this program
    mov eax, ecx  ; load lower bits of dividend
    xor edx, edx  ; dont need the upper bits of dividend
    mov ecx, 1000 ; 1000ms/sec
    div ecx       ; eax:quotient, edx:remainder

  evaltimeleftdone:
    ret  

align 16
eval_deer_position:
    push rbp
    mov rbp, rsp

    ; update position of all deer
    ;call eval_deer_full_ticks

    mov rax, qword [state_deer_update + 0] ; deer full
    call rax

    mov rax, qword [state_deer_update + 8] ; deer half
    call rax

  end_evaldeerpos:
    mov rsp, rbp
    pop rbp
    ret

align 16
eval_deer_half_A: ; upper left

    sub rsp, 8

    mov eax, dword [ticks]    ; get the current time for this state
    cmp eax, [deer_half_tick] ; compare to threshold time
    jl halfAend               ; skip next step if we havent reached threshold

    ; swap which routine is called next time
    mov qword [state_deer_update + 8], eval_deer_half_B ; switch states
    add dword [deer_half_tick], 1500 ; update for next iteration

    ; update positions of relevant deer
    mov dword [deer_upper_left + 0], -200 ; ensure deer is offscreen
    mov dword [deer_upper_left + 4], -200 ; ...
    mov dword [deer_lower_right + 0], 700 ; X
    mov dword [deer_lower_right + 4], 500 ; Y

  halfAend:
    add rsp, 8
    ret

align 16
eval_deer_half_B: ; lower right
    sub rsp, 8

    mov eax, dword [ticks]    
    cmp eax, [deer_half_tick] 
    jl halfBend               

    ; swap which routine is called next time
    mov qword [state_deer_update + 8], eval_deer_half_A
    add dword [deer_half_tick], 1500 ; update for next iteration

    ; update positions of relevant deer
    mov dword [deer_lower_right + 0], -200 ; X
    mov dword [deer_lower_right + 4], -200 ; Y
    mov dword [deer_upper_left + 0],   60  ; X
    mov dword [deer_upper_left + 4],  350  ; Y

  halfBend:
    add rsp, 8
    ret

align 16
eval_deer_full_A: ; upper right
    sub rsp, 8

    mov eax, dword [ticks]    ; get the current time for this state
    cmp eax, [deer_full_tick] ; compare to threshold time
    jl fullAend               ; skip next step if we havent reached threshold

    ; swap which routine is called next time
    mov qword [state_deer_update + 0], eval_deer_full_B ; switch states
    add dword [deer_full_tick], 2500 ; update for next iteration

    ; update positions of relevant deer
    mov dword [deer_lower_left + 0],    60 ; X
    mov dword [deer_lower_left + 4],   500 ; Y
    mov dword [deer_upper_right + 0], -200 ; make offscreen
    mov dword [deer_upper_right + 4], -200 ; ...

  fullAend:
    add rsp, 8
    ret

align 16
eval_deer_full_B: ; lower left
    sub rsp, 8

    mov eax, dword [ticks]    ; get the current time for this state
    cmp eax, [deer_full_tick] ; compare to threshold time
    jl fullBend               ; skip next step if we havent reached threshold

    ; swap which routine is called next time
    mov qword [state_deer_update + 0], eval_deer_full_A ; switch states
    add dword [deer_full_tick], 2500 ; update for next iteration

    ; update positions of relevant deer
    mov dword [deer_lower_left + 0],  -200 ; X
    mov dword [deer_lower_left + 4],  -200 ; Y
    mov dword [deer_upper_right + 0],  700 ; make offscreen
    mov dword [deer_upper_right + 4],  350 ; ...

  fullBend:
    add rsp, 8
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

    ; test hits against every deer
    mov rdi, deer_lower_left ; location of deer
    mov si, [mouse_X]        ; mouse X
    mov dx, [mouse_Y]        ; mouse Y
    movzx rsi, si    ; zero-extend X
    movzx rdx, dx    ; zero-extend Y
    call testhitdeer
    cmp rax, 0       ; testhitdeer returns 1 if deer is hit
    je testhitdeerlowerright ; skip next few instructions if deer was missed
    inc dword [points]       ; increment point count
    mov rdi, deer_lower_left ; remove deer from frame until next update
    call removedeer          ; ...

  testhitdeerlowerright:
    mov rdi, deer_lower_right ; location of deer
    mov si, [mouse_X]         ; mouse X
    mov dx, [mouse_Y]         ; mouse Y
    movzx rsi, si    ; zero-extend X
    movzx rdx, dx    ; zero-extend Y
    call testhitdeer
    cmp rax, 0       ; testhitdeer returns 1 if deer is hit
    je testhitdeerupperleft  ; skip next few instructions if deer was missed
    inc dword [points]       ; increment point count
    mov rdi, deer_lower_right ; remove deer from frame until next update
    call removedeer          ; ...

  testhitdeerupperleft:
    mov rdi, deer_upper_left ; location of deer
    mov si, [mouse_X]        ; mouse X
    mov dx, [mouse_Y]        ; mouse Y
    movzx rsi, si    ; zero-extend X
    movzx rdx, dx    ; zero-extend Y
    call testhitdeer
    cmp rax, 0       ; testhitdeer returns 1 if deer is hit
    je testhitdeerupperright ; skip next few instructions if deer was missed
    inc dword [points]       ; increment point count
    mov rdi, deer_upper_left ; remove deer from frame until next update
    call removedeer          ; ...

  testhitdeerupperright:
    mov rdi, deer_upper_right ; location of deer
    mov si, [mouse_X]         ; mouse X
    mov dx, [mouse_Y]         ; mouse Y
    movzx rsi, si    ; zero-extend X
    movzx rdx, dx    ; zero-extend Y
    call testhitdeer
    cmp rax, 0       ; testhitdeer returns 1 if deer is hit
    je end_mouse_click_callback ; skip next few instructions if deer was missed
    inc dword [points]          ; increment point count
    mov rdi, deer_upper_right   ; remove deer from frame until next update
    call removedeer             ; ...

  end_mouse_click_callback:
    ; end body of callback
    mov rsp, rbp
    pop rbp
    ret

