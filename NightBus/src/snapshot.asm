        ; Development snapshot for Fuse.
        ; TAP remains the distribution format for real ZX hardware.

        DEVICE ZXSPECTRUM48
        ORG $8000

        INCLUDE "main.asm"
        SAVESNA "build/nightbus.sna",start
