
; stdlib stuff
extern printf
extern puts
extern sprintf
extern bzero

; a bunch of SDL1.2 library stuff
extern SDL_Init
extern SDL_SetVideoMode
extern SDL_FillRect
extern SDL_MapRGB
extern SDL_Flip
extern SDL_Delay
extern SDL_Quit
extern SDL_ShowCursor
extern SDL_GetTicks

extern gfxPrimitivesSetFont
extern stringColor

extern draw_stage

; input subsystem stuff
extern evaluate_inputs
extern clear_inputs
extern key_w
extern key_a
extern key_s
extern key_d
extern key_enter
extern key_spc
extern key_esc
extern quit_p
extern key_up
extern key_down
extern key_left
extern key_right

extern mouse_X
extern mouse_Y

; custom subroutines and asst. global data
extern setup_colors
extern sdl_rect_a
extern sdl_rect_b
extern screen
extern screen_format
extern draw_rect_a
extern draw_rect_b
extern sdl_event
extern draw_tree

; global colors and related info
extern color_lut_begin
extern color_lut_end
extern white
extern black
extern maroon
extern red
extern orange
extern yellow
extern olive
extern purple
extern fuschia
extern lime
extern green
extern navy
extern blue
extern aqua
extern silver
extern gray
extern brown
