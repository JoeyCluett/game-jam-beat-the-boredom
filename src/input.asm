
global evaluate_inputs
global clear_inputs
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

section .bss
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

    ; one global SDL_Event
    sdl_event: resb 24

section .text
clear_inputs:
    ; zero out all input flags
    mov [key_w], dword 0
    mov [key_enter], dword 0
    mov [key_down], dword 0
    ret

evaluate_keydown:
    mov eax, dword [sdl_event + 8] ; offset of key.keysym.sym in SDL_Event

    cmp eax, 119 ; w
    jne keydown_test_a
    mov [key_w], byte 1
    jmp keydown_done

  keydown_test_a:
    cmp eax, 97  ; a
    jne keydown_test_s
    mov [key_a], byte 1
    jmp keydown_done

  keydown_test_s:
    cmp eax, 115 ; s
    jne keydown_test_d
    mov [key_s], byte 1
    jmp keydown_done

  keydown_test_d:
    cmp eax, 100 ; d
    jne keydown_test_esc
    mov [key_d], byte 1
    jmp keydown_done
    
  keydown_test_esc:
    cmp eax, 27 ; esc
    jne keydown_done
    mov [key_esc], byte 1

  keydown_done:
    ret

evaluate_keyup:
    mov eax, dword [sdl_event + 8] ; offset of key.keysym.sym in SDL_Event
    
    cmp eax, 119 ; w
    jne keyup_test_a
    mov [key_w], byte 0
    jmp keydown_done

  keyup_test_a:
    cmp eax, 97  ; a
    jne keyup_test_s
    mov [key_a], byte 0
    jmp keydown_done

  keyup_test_s:
    cmp eax, 115 ; s
    jne keyup_test_d
    mov [key_s], byte 0
    jmp keydown_done

  keyup_test_d:
    cmp eax, 100 ; d
    jne keyup_test_esc
    mov [key_d], byte 0
    jmp keydown_done
    
  keyup_test_esc:
    cmp eax, 27 ; esc
    jne keyup_done
    mov [key_esc], byte 0

  keyup_done:
    ret

evaluate_inputs:
    push rbp
    mov rbp, rsp

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
    jne start_poll_loop

    call evaluate_keyup
    jmp start_poll_loop

  end_eval_inputs:
    mov rsp, rbp
    pop rbp
    ret
