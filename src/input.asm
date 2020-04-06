
global evaluate_inputs
global clear_inputs
global sdl_event
extern SDL_PollEvent

global key_w
global key_a
global key_s
global key_d
global key_enter
global key_spc
global key_esc
global quit_p
global key_down
global key_up
global key_left
global key_right
global mouse_X
global mouse_Y

section .bss

ALIGN 64
    key_w:     resb 1
    key_a:     resb 1
    key_s:     resb 1
    key_d:     resb 1

    key_enter: resb 1
    key_spc:   resb 1
    key_esc:   resb 1
    quit_p:    resb 1
    
    key_down:  resb 1
    key_up:    resb 1
    key_left:  resb 1
    key_right: resb 1

    ; X/Y coordinates of the mouse, both integers
    mouse_X: resd 1
    mouse_Y: resd 1

    ; one global SDL_Event
    sdl_event: resb 24

section .text

align 16
clear_inputs:
    ; zero out all input flags
    xor rax, rax
    mov [key_w], rax
    mov [key_down], eax
    ret

;
; evaluate SDL_KEYDOWN event types
;
align 16
evaluate_keydown:
    mov eax, dword [sdl_event + 8] ; offset of key.keysym.sym in SDL_Event (4 byte field)

    ; first test:
    cmp eax, 119 ; w
    jne keydown_test_a
    mov [key_w], byte 1
    ret
  keydown_test_a:
    cmp eax, 97  ; a
    jne keydown_test_s
    mov [key_a], byte 1
    ret
  keydown_test_s:
    cmp eax, 115 ; s
    jne keydown_test_d
    mov [key_s], byte 1
    ret
  keydown_test_d:
    cmp eax, 100 ; d
    jne keydown_test_esc
    mov [key_d], byte 1
    ret
  keydown_test_esc:
    cmp eax, 27 ; esc
    jne keydown_test_enter
    mov [key_esc], byte 1
    ret
  keydown_test_enter:
    cmp eax, 13 ; return
    jne keydown_test_space
    mov [key_enter], byte 1
    ret
  keydown_test_space:
    cmp eax, 32 ; space
    jne keydown_test_down
    mov [key_spc], byte 1
    ret
  keydown_test_down:
    cmp eax, 274 ; down arrow
    jne keydown_test_up
    mov [key_down], byte 1
    ret
  keydown_test_up:
    cmp eax, 273 ; up arrow
    jne keydown_test_left
    mov [key_up], byte 1
    ret
  keydown_test_left:
    cmp eax, 276 ; left arrow
    jne keydown_test_right
    mov [key_left], byte 1
    ret
  keydown_test_right:
    cmp eax, 275 ; right arrow
    jne keydown_done
    mov [key_right], byte 1
    keydown_done:
    ret

;
; evaluate SDL_KEYUP event types
;
align 16
evaluate_keyup:
    mov eax, dword [sdl_event + 8] ; offset of key.keysym.sym in SDL_Event
    
    cmp eax, 119 ; w
    jne keyup_test_a
    mov [key_w], byte 0
    ret
  keyup_test_a:
    cmp eax, 97  ; a
    jne keyup_test_s
    mov [key_a], byte 0
    ret
  keyup_test_s:
    cmp eax, 115 ; s
    jne keyup_test_d
    mov [key_s], byte 0
    ret
  keyup_test_d:
    cmp eax, 100 ; d
    jne keyup_test_esc
    mov [key_d], byte 0
    ret    
  keyup_test_esc:
    cmp eax, 27 ; esc
    jne keyup_test_enter
    mov [key_esc], byte 0
    ret
  keyup_test_enter:
    cmp eax, 13 ; return
    jne keyup_test_space
    mov [key_enter], byte 0
    ret
  keyup_test_space:
    cmp eax, 32 ; space
    jne keyup_test_down
    mov [key_spc], byte 0
    ret
  keyup_test_down:
    cmp eax, 274 ; down arrow
    jne keyup_test_up
    mov [key_down], byte 0
    ret
  keyup_test_up:
    cmp eax, 273 ; up arrow
    jne keyup_test_left
    mov [key_up], byte 0
    ret
  keyup_test_left:
    cmp eax, 276 ; left arrow
    jne keyup_test_right
    mov [key_left], byte 0
    ret
  keyup_test_right:
    cmp eax, 275 ; right arrow
    jne keyup_done
    mov [key_right], byte 0
    keyup_done:
    ret

;
; grab the updated mouse position
;
align 16
evaluate_mouse_motion:
    push rbp
    mov rbp, rsp

    ; just update the mouse position and return
    mov ax, word [sdl_event + 4] ; offset of X
    movzx rax, ax      ; zero-extend X value
    mov [mouse_X], eax ; store X as integer
    mov ax, word [sdl_event + 6] ; offset of Y
    movzx rax, ax      ; zero-extend Y value
    mov [mouse_Y], eax ; store Y as integer

    mov rsp, rbp
    pop rbp
    ret

;
; update mouse position and call callback
;
align 16
evaluate_mouse_button:
    push rbp
    mov rbp, rsp

    mov ax, word [sdl_event + 4] ; offset of X
    movzx rax, ax      ; zero-extend X value
    mov [mouse_X], eax ; store X as integer
    mov ax, word [sdl_event + 6] ; offset of Y
    movzx rax, ax      ; zero-extend Y value
    mov [mouse_Y], eax ; store Y as integer

    ; click callback is in rdi
    cmp rdi, 0
    je end_eval_mouse_button ; dont make callback if it is zero
    call rdi                 ; otherwise call away

  end_eval_mouse_button:
    mov rsp, rbp
    pop rbp
    ret

evaluate_inputs:
    push rbp
    mov rbp, rsp

    ; need some space for locally saved variables
    sub rsp, 16
    mov qword [rsp], rdi ; rdi : mouse click callback

  start_poll_loop:
    mov rdi, sdl_event ; ptr to SDL_Event structure
    call SDL_PollEvent
    cmp rax, 0         ; SDL_PollEvent returns zero if there are no more events
    je end_eval_inputs ; ...

    ; we have an event. fill out the key data above
    ; test for SDL_QUIT event
    cmp [sdl_event + 0], byte 12 ; SDL_QUIT
    jne test_keydown

    ; update the quit flag
    mov [quit_p], byte 1 ; flag becomes true
    jmp end_eval_inputs  ; dont care about the other events

  test_keydown:
    cmp [sdl_event + 0], byte 2 ; SDL_KEYDOWN
    jne test_keyup
    call evaluate_keydown
    jmp start_poll_loop

  test_keyup:
    cmp [sdl_event + 0], byte 3 ; SDL_KEYUP
    jne test_mousemotion
    call evaluate_keyup
    jmp start_poll_loop

  test_mousemotion:
    cmp [sdl_event + 0], byte 4 ; SDL_MOUSEMOTION
    jne test_mousebutton
    call evaluate_mouse_motion
    jmp start_poll_loop

  test_mousebutton:
    cmp [sdl_event + 0], byte 5 ; SDL_MOUSEBUTTONDOWN
    jne test_mbup
    mov rdi, qword [rsp]       ; move callback into rdi
    call evaluate_mouse_button ; button is down
    jmp start_poll_loop
    
    test_mbup:
    cmp [sdl_event + 0], byte 6 ; SDL_MOUSEBUTTONUP
    jne start_poll_loop
    mov rdi, qword [rsp]       ; move callback into rdi
    call evaluate_mouse_button ; button is up
    jmp start_poll_loop

  end_eval_inputs:
    mov rsp, rbp
    pop rbp
    ret
