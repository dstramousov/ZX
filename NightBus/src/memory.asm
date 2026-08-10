; NightBus memory map — Sinclair ZX Spectrum 128K
;
; Z80 always sees 64 KiB:
;   $0000-$3FFF  ROM
;   $4000-$7FFF  RAM bank 5 (normal screen)
;   $8000-$BFFF  RAM bank 2 (fixed code/data)
;   $C000-$FFFF  pageable RAM bank 0..7
;
; Bits 0..2 of port $7FFD select the bank visible at $C000-$FFFF.

SCREEN_ADDR     = $4000
FIXED_CODE_ADDR = $8000
BANK_WINDOW     = $C000
PORT_7FFD       = $7FFD
