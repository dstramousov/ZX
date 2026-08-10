        INCLUDE "memory.asm"
        INCLUDE "paging.asm"
        INCLUDE "interrupts.asm"

start:
        ; Interrupts off while we establish a safe fixed-bank stack.
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
        ld a,d

        ; Очищаем bitmap ОДИН раз при старте.
        call clear_screen

        ; Начальная Y-позиция.
        xor a
        ld (line_y),a

        ; Ставим собственный IM2 и включаем 50 Гц interrupts.
        call init_interrupts

        ; Первый кадр.
        call draw_line


; ------------------------------------------------------------
; main_loop
;
; Один проход = один аппаратный кадр Spectrum (~50 Гц).
; Вместо очистки всех 6144 байт стираем только старую линию.
; ------------------------------------------------------------

main_loop:
        halt
        call erase_line
        call move_line
        call draw_line
        jr main_loop


; ------------------------------------------------------------
; clear_screen
;
; Очищает bitmap $4000-$57FF (6144 байта).
; Используется только один раз при старте.
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
;   HL = адрес начала физической pixel row.
;
; Адрес Spectrum:
;
;   H = 010 Y7 Y6 Y2 Y1 Y0
;   L = Y5 Y4 Y3 00000
;
; Поэтому строки 0,1,2... лежат не подряд в памяти.
; ------------------------------------------------------------

screen_address:
        ld b,a

        ; H: базовый $40 + Y2..Y0 в битах 2..0.
        and %00000111
        or $40
        ld h,a

        ; Y7..Y6 -> биты 4..3 H.
        ld a,b
        and %11000000
        rrca
        rrca
        rrca
        or h
        ld h,a

        ; Y5..Y3 -> биты 7..5 L.
        ld a,b
        and %00111000
        rlca
        rlca
        ld l,a

        ret


; ------------------------------------------------------------
; erase_line
;
; Стирает только текущую горизонтальную линию: 32 байта.
; ------------------------------------------------------------

erase_line:
        ld a,(line_y)
        call screen_address

        xor a
        ld b,32

erase_line_loop:
        ld (hl),a
        inc hl
        djnz erase_line_loop
        ret


; ------------------------------------------------------------
; draw_line
;
; Рисует пунктирную линию на Y=line_y.
; ------------------------------------------------------------

draw_line:
        ld a,(line_y)
        call screen_address

        ld a,%10101010
        ld b,32

draw_line_loop:
        ld (hl),a
        inc hl
        djnz draw_line_loop
        ret


; ------------------------------------------------------------
; move_line
;
; Движение ровно на 1 пиксель каждый кадр.
; 50 Гц => примерно 50 пикселей в секунду.
; ------------------------------------------------------------

move_line:
        ld a,(line_y)
        inc a
        cp 192
        jr nz,move_line_store

        xor a

move_line_store:
        ld (line_y),a
        ret


line_y:
        db 0
