        INCLUDE "memory.asm"
        INCLUDE "paging.asm"

start:
        ; Чёрная рамка.
        xor a
        out ($fe),a

        ; Сделаем весь экран bright white on black,
        ; чтобы пиксели были видимы независимо от строки.
        ld hl,$5800
        ld a,$47
        ld b,0

clear_attrs:
        ld (hl),a
        inc hl
        djnz clear_attrs

        ; Остальные 512 байт attribute memory.
        ld b,0

clear_attrs_2:
        ld (hl),a
        inc hl
        djnz clear_attrs_2

        ; Y-позиция нашей линии: 0..23.
        xor a
        ld (line_y),a

main_loop:
        call clear_screen
        call draw_line
        call wait_frame
        call move_line
        jr main_loop


; ------------------------------------------------------------
; clear_screen
;
; Очищает bitmap $4000-$57FF.
; 6144 байта = 24 блока по 256 байт.
; ------------------------------------------------------------

clear_screen:
        ld hl,SCREEN_ADDR
        xor a
        ld c,24

clear_screen_block:
        ld b,0

clear_screen_byte:
        ld (hl),a
        inc hl
        djnz clear_screen_byte

        dec c
        jr nz,clear_screen_block
        ret


; ------------------------------------------------------------
; draw_line
;
; Рисует одну горизонтальную строку знакомест.
; Для простоты пока двигаемся по 8 пикселей за кадр:
; line_y = 0..23.
;
; Экран Spectrum хранится хитро, поэтому для первых 24 строк
; знакомест используем готовую таблицу адресов bitmap.
; ------------------------------------------------------------

draw_line:
        ld a,(line_y)
        add a,a

        ld e,a
        ld d,0

        ld hl,line_addresses
        add hl,de

        ld e,(hl)
        inc hl
        ld d,(hl)

        ex de,hl

        ld a,%10101010
        ld b,32

draw_line_loop:
        ld (hl),a
        inc hl
        djnz draw_line_loop
        ret


; ------------------------------------------------------------
; wait_frame
;
; HALT ждёт следующее прерывание Spectrum.
; Стандартно это примерно 50 раз в секунду.
; Чтобы движение не было бешеным, ждём 5 кадров.
; ------------------------------------------------------------

wait_frame:
        ld de,12000

wait_frame_loop:
        dec de
        ld a,d
        or e
        jr nz,wait_frame_loop
        ret

; ------------------------------------------------------------
; move_line
;
; Увеличивает Y. После 23 снова переходит к 0.
; ------------------------------------------------------------

move_line:
        ld a,(line_y)
        inc a
        cp 24
        jr nz,move_line_store

        xor a

move_line_store:
        ld (line_y),a
        ret


line_y:
        db 0


; ------------------------------------------------------------
; Адреса начала 24 строк знакомест Spectrum.
; Каждая следующая позиция соответствует +8 пикселям по Y.
;
; Это временная учебная таблица. Позже напишем нормальную
; функцию вычисления экранного адреса без таблицы.
; ------------------------------------------------------------

line_addresses:
        dw $4000,$4020,$4040,$4060,$4080,$40A0,$40C0,$40E0
        dw $4800,$4820,$4840,$4860,$4880,$48A0,$48C0,$48E0
        dw $5000,$5020,$5040,$5060,$5080,$50A0,$50C0,$50E0
