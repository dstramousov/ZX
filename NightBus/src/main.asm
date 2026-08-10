start:
        ; Чёрная рамка
        xor a
        out ($fe),a

        ; Начало видеопамяти Spectrum
        ld hl,$4000

        ; Нарисуем простой узор
        ld a,%10101010

loop:
        ld (hl),a
        inc hl

        ; Пока заполним первые 256 байт экрана
        ld a,h
        cp $41
        jr nz,loop

forever:
        jr forever