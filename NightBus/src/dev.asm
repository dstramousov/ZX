        DEVICE ZXSPECTRUM128

        ORG $8000

code_start:
        INCLUDE "main.asm"
code_end:

        ; Raw fixed-bank image used to build the .z80 development snapshot.
        SAVEBIN "build/nightbus.bin",code_start,code_end-code_start

        ; Store entry address as a two-byte little-endian value for the packer.
        OUTPUT "build/nightbus.start"
        dw start
        OUTEND
