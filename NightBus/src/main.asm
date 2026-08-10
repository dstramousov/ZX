        INCLUDE "memory.asm"
        INCLUDE "paging.asm"
        INCLUDE "interrupts.asm"

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
        ; Очищаем bitmap один раз.
        call clear_screen

        ; Начальная позиция игрового маркера.
        ld a,128
        ld (player_x),a

        ld a,96
        ld (player_y),a

        call init_interrupts
        call draw_player


; ------------------------------------------------------------
; main_loop
;
; Один цикл = один кадр Spectrum (~50 Гц).
;
;   HALT
;   erase
;   input
;   draw
; ------------------------------------------------------------

main_loop:
        halt

        call erase_player
        call read_keyboard
        call draw_player

        jr main_loop


; ------------------------------------------------------------
; clear_screen
;
; Очищает bitmap $4000-$57FF.
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
; Вход:
;   A  = Y, 0..191
;
; Выход:
;   HL = адрес начала pixel row.
; ------------------------------------------------------------

screen_address:
        ld b,a

        ; H = 010 Y7 Y6 Y2 Y1 Y0
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

        ; L = Y5 Y4 Y3 00000
        ld a,b
        and %00111000
        rlca
        rlca
        ld l,a

        ret


; ------------------------------------------------------------
; pixel_mask
;
; Вход:
;   A = X, 0..255
;
; Выход:
;   C = номер байта в строке (X / 8)
;   A = маска нужного пикселя
;
; ZX хранит левый пиксель в bit 7:
;
; X mod 8:
;   0 -> %10000000
;   1 -> %01000000
;   ...
;   7 -> %00000001
; ------------------------------------------------------------

pixel_mask:
        ld c,a

        ; C = X / 8
        srl c
        srl c
        srl c

        ; B = X & 7
        and %00000111
        ld b,a

        ld a,%10000000
        jr z,pixel_mask_done

pixel_mask_shift:
        srl a
        djnz pixel_mask_shift

pixel_mask_done:
        ret


; ------------------------------------------------------------
; draw_player
;
; Рисует один белый пиксель в (player_x, player_y).
; ------------------------------------------------------------

draw_player:
        ld a,(player_y)
        call screen_address

        ld a,(player_x)
        call pixel_mask

        ; HL += X / 8
        ld b,0
        add hl,bc

        or (hl)
        ld (hl),a
        ret


; ------------------------------------------------------------
; erase_player
;
; Так как фон пока пустой, старый пиксель можно просто стереть.
; ------------------------------------------------------------

erase_player:
        ld a,(player_y)
        call screen_address

        ld a,(player_x)
        call pixel_mask

        ld b,0
        add hl,bc

        cpl
        and (hl)
        ld (hl),a
        ret


; ------------------------------------------------------------
; read_keyboard
;
; Читаем стандартные cursor keys Spectrum:
;
;   LEFT  = 5
;   DOWN  = 6
;   UP    = 7
;   RIGHT = 8
;
; На настоящем Spectrum курсоры — CAPS SHIFT + 5/6/7/8.
; Нам состояние CAPS SHIFT не важно: достаточно увидеть сами 5..8.
;
; В Fuse обычные стрелки обычно эмулируют эти сочетания.
; Заодно можно нажимать цифровые 5/6/7/8.
; ------------------------------------------------------------

read_keyboard:
        call key_left
        call key_right
        call key_up
        call key_down
        ret


; ------------------------------------------------------------
; LEFT = key 5
;
; Keyboard row: 1 2 3 4 5
; Port high byte = $F7
; bit 4 = key 5
; ------------------------------------------------------------

key_left:
        ld bc,$F7FE
        in a,(c)
        bit 4,a
        ret nz

        ld a,(player_x)
        or a
        ret z

        dec a
        ld (player_x),a
        ret


; ------------------------------------------------------------
; RIGHT = key 8
;
; Keyboard row: 6 7 8 9 0
; Port high byte = $EF
; bit 2 = key 8
; ------------------------------------------------------------

key_right:
        ld bc,$EFFE
        in a,(c)
        bit 2,a
        ret nz

        ld a,(player_x)
        cp 255
        ret z

        inc a
        ld (player_x),a
        ret


; ------------------------------------------------------------
; UP = key 7
;
; Row 0 9 8 7 6, bit 3 = key 7
; ------------------------------------------------------------

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


; ------------------------------------------------------------
; DOWN = key 6
;
; Row 0 9 8 7 6, bit 4 = key 6
; ------------------------------------------------------------

key_down:
        ld bc,$EFFE
        in a,(c)
        bit 4,a
        ret nz

        ld a,(player_y)
        cp 191
        ret z

        inc a
        ld (player_y),a
        ret


player_x:
        db 128

player_y:
        db 96
