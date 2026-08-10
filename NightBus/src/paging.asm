; 128K RAM paging.
;
; set_bank
;   A = RAM bank number 0..7
;
; Keeps the other $7FFD control bits unchanged.
; Do not set bit 5 here: it permanently disables paging until reset.

set_bank:
        and %00000111
        ld b,a

        ld a,(paging_7ffd)
        and %11111000
        or b

        ld (paging_7ffd),a
        ld bc,PORT_7FFD
        out (c),a
        ret

; Shadow copy of the last value written to $7FFD.
; At startup we assume standard 128K state: bank 0, screen 5, ROM 0.
paging_7ffd:
        db 0
