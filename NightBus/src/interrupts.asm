; ------------------------------------------------------------
; NightBus frame interrupt — compact IM2 setup
;
; Spectrum ULA supplies $FF on the interrupt data bus.
; With I=$90, Z80 reads the handler address from $90FF/$9100.
; Those two bytes are written at runtime, so the binary stays small.
; ------------------------------------------------------------

IM2_VECTOR      = $90FF
STACK_TOP       = $BFF0

init_interrupts:
        di

        ; Install address of our handler into the IM2 vector.
        ld hl,im2_handler
        ld (IM2_VECTOR),hl

        ; I=$90 => vector lookup starts at $90FF.
        ld a,$90
        ld i,a

        im 2
        ei
        ret

im2_handler:
        ; Minimal 50 Hz handler: nothing to update yet.
        ei
        reti
