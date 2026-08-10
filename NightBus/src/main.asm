        INCLUDE "memory.asm"
        INCLUDE "paging.asm"
        INCLUDE "interrupts.asm"
        INCLUDE "player_assets.asm"

start:
        di
        ld sp,STACK_TOP

        ; Чёрная рамка.
        xor a
        out ($fe),a

        ; Весь экран: bright white on black.
        ld hl,$5800
        ld a,$47
        ld bc,768

attr_loop:
        ld (hl),a
        inc hl
        dec bc

        ld d,a
        ld a,b
        or c
        jr z,attr_done
        ld a,d
        jr attr_loop

attr_done:
        call clear_screen

        ; Начальная позиция спрайта.
        ; X ограничиваем 0..248, Y 0..184,
        ; чтобы 8x8 объект всегда помещался на экране.
        ld a,124
        ld (player_x),a

        ld a,92
        ld (player_y),a

        ; Смотрим вправо, стоим.
        xor a
        ld (player_facing),a
        ld (player_frame),a
        ld (anim_timer),a
        ld (horizontal_moving),a

        call init_interrupts
        call draw_player


main_loop:
        halt

        call erase_player
        call read_keyboard
        call update_animation
        call draw_player

        jr main_loop


; ------------------------------------------------------------
; clear_screen
; ------------------------------------------------------------

clear_screen:
        ld hl,SCREEN_ADDR
        xor a
        ld bc,6144

clear_screen_loop:
        ld (hl),a
        inc hl
        dec bc

        ld d,a
        ld a,b
        or c
        jr z,clear_screen_done
        ld a,d
        jr clear_screen_loop

clear_screen_done:
        ret


; ------------------------------------------------------------
; screen_address
;
; A = Y, 0..191
; HL = адрес начала pixel row.
; ------------------------------------------------------------

screen_address:
        ld b,a

        and %00000111
        or $40
        ld h,a

        ld a,b
        and %11000000
        rrca
        rrca
        rrca
        or h
        ld h,a

        ld a,b
        and %00111000
        rlca
        rlca
        ld l,a

        ret


; ------------------------------------------------------------
; sprite_row_address
;
; Вход:
;   A = Y строки спрайта
;
; Выход:
;   HL = экранный адрес строки
;   C  = byte offset по X (player_x / 8)
;   B  = bit shift (player_x & 7)
; ------------------------------------------------------------

sprite_row_address:
        call screen_address

        ld a,(player_x)
        ld c,a
        and %00000111
        ld b,a

        ld a,c
        srl a
        srl a
        srl a
        ld c,a

        ld a,l
        add a,c
        ld l,a
        ret


; ------------------------------------------------------------
; shift_sprite_word
;
; D:E = 16 source pixels, B = X & 7.
; Result: D:E:A = up to 3 screen bytes.
; ------------------------------------------------------------

shift_sprite_word:
        ld c,b
        xor a
        ld b,c
        ld c,a

        ld a,b
        or a
        ld a,c
        ret z

shift_sprite_word_loop:
        srl d
        rr e
        rra
        djnz shift_sprite_word_loop
        ret


; ------------------------------------------------------------
; draw_player — 16x16
; ------------------------------------------------------------

draw_player:
        call select_player_sprite
        ld a,(player_y)
        ld (work_y),a
        ld c,16

draw_player_row:
        ld a,(work_y)
        push bc
        call sprite_row_address

        ld d,(ix+0)
        ld e,(ix+1)
        call shift_sprite_word
        ld c,a

        ld a,(hl)
        or d
        ld (hl),a

        inc hl
        ld a,(hl)
        or e
        ld (hl),a

        ld a,b
        or a
        jr z,draw_player_next

        inc hl
        ld a,(hl)
        or c
        ld (hl),a

draw_player_next:
        inc ix
        inc ix
        ld a,(work_y)
        inc a
        ld (work_y),a
        pop bc
        dec c
        jr nz,draw_player_row
        ret


; ------------------------------------------------------------
; erase_player — 16x16
; ------------------------------------------------------------

erase_player:
        call select_player_sprite
        ld a,(player_y)
        ld (work_y),a
        ld c,16

erase_player_row:
        ld a,(work_y)
        push bc
        call sprite_row_address

        ld d,(ix+0)
        ld e,(ix+1)
        call shift_sprite_word
        ld c,a

        ld a,d
        cpl
        and (hl)
        ld (hl),a

        inc hl
        ld a,e
        cpl
        and (hl)
        ld (hl),a

        ld a,b
        or a
        jr z,erase_player_next

        inc hl
        ld a,c
        cpl
        and (hl)
        ld (hl),a

erase_player_next:
        inc ix
        inc ix
        ld a,(work_y)
        inc a
        ld (work_y),a
        pop bc
        dec c
        jr nz,erase_player_row
        ret


; ------------------------------------------------------------
; read_keyboard
; ------------------------------------------------------------

read_keyboard:
        xor a
        ld (horizontal_moving),a

        call key_left
        call key_right
        call key_up
        call key_down
        ret


; LEFT = 5
key_left:
        ld bc,$F7FE
        in a,(c)
        bit 4,a
        ret nz

        ; 1 = смотрим влево.
        ld a,1
        ld (player_facing),a

        ld a,(player_x)
        or a
        ret z

        dec a
        ld (player_x),a

        ld a,1
        ld (horizontal_moving),a
        ret


; RIGHT = 8
key_right:
        ld bc,$EFFE
        in a,(c)
        bit 2,a
        ret nz

        ; 0 = смотрим вправо.
        xor a
        ld (player_facing),a

        ld a,(player_x)
        cp 240
        ret z

        inc a
        ld (player_x),a

        ld a,1
        ld (horizontal_moving),a
        ret


; UP = 7
key_up:
        ld bc,$EFFE
        in a,(c)
        bit 3,a
        ret nz

        ld a,(player_y)
        or a
        ret z

        dec a
        ld (player_y),a
        ret


; DOWN = 6
key_down:
        ld bc,$EFFE
        in a,(c)
        bit 4,a
        ret nz

        ld a,(player_y)
        cp 176
        ret z

        inc a
        ld (player_y),a
        ret


; ------------------------------------------------------------
; update_animation
;
; player_frame:
;   0 = стоит
;   1 = шаг A
;   2 = шаг B
;
; При горизонтальном движении кадр ног меняется раз в 6
; экранных кадров. Положение при этом обновляется каждый кадр.
; ------------------------------------------------------------

update_animation:
        ld a,(horizontal_moving)
        or a
        jr z,animation_idle

        ; Если только начали идти — сразу показываем первый шаг.
        ld a,(player_frame)
        or a
        jr nz,animation_tick

        ld a,1
        ld (player_frame),a
        xor a
        ld (anim_timer),a
        ret

animation_tick:
        ld a,(anim_timer)
        inc a
        cp 6
        jr c,animation_store_timer

        xor a
        ld (anim_timer),a

        ; 1 <-> 2
        ld a,(player_frame)
        cp 1
        jr z,animation_set_frame_2

        ld a,1
        ld (player_frame),a
        ret

animation_set_frame_2:
        ld a,2
        ld (player_frame),a
        ret

animation_store_timer:
        ld (anim_timer),a
        ret

animation_idle:
        xor a
        ld (player_frame),a
        ld (anim_timer),a
        ret


; ------------------------------------------------------------
; select_player_sprite
;
; Выход:
;   IX = адрес нужного 8x8 кадра.
;
; player_facing:
;   0 = вправо
;   1 = влево
; ------------------------------------------------------------

select_player_sprite:
        ld a,(player_facing)
        or a
        jr nz,select_left_sprite

select_right_sprite:
        ld a,(player_frame)
        or a
        jr z,select_right_idle
        cp 1
        jr z,select_right_walk_1

        ld ix,player_right_walk_2
        ret

select_right_idle:
        ld ix,player_right_idle
        ret

select_right_walk_1:
        ld ix,player_right_walk_1
        ret

select_left_sprite:
        ld a,(player_frame)
        or a
        jr z,select_left_idle
        cp 1
        jr z,select_left_walk_1

        ld ix,player_left_walk_2
        ret

select_left_idle:
        ld ix,player_left_idle
        ret

select_left_walk_1:
        ld ix,player_left_walk_1
        ret


; Sprite data moved to src/player_assets.asm + assets/sprites/player/.

player_x:
        db 124

player_y:
        db 92

; 0 = вправо, 1 = влево
player_facing:
        db 0

; 0 = idle, 1/2 = шаги
player_frame:
        db 0

; Считает кадры до следующей смены фазы шага.
anim_timer:
        db 0

; Ставится в 1 только если в этом кадре реально изменился X.
horizontal_moving:
        db 0

work_y:
        db 0
