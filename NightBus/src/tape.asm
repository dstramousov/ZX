        DEFINE TAPE_FILE "build/nightbus.tap"

        EMPTYTAP TAPE_FILE

        ; BASIC loader header
        TAPOUT TAPE_FILE,0
        db $00
        db "NIGHTBUS  "
        dw basic_end-basic
        dw 10
        dw basic_end-basic
        TAPEND

        ; BASIC loader body:
        ; 10 LOAD "" CODE
        ; 20 RANDOMIZE USR 32768
        TAPOUT TAPE_FILE

LOAD        = $EF
CODE        = $AF
RANDOMIZE   = $F9
USR         = $C0

basic:
        db 0,10
        dw line10_end-line10
line10:
        db LOAD,'""',CODE
        db $0D
line10_end:

        db 0,20
        dw line20_end-line20
line20:
        db RANDOMIZE,USR
        LUA ALLPASS
            _pc('db "' .. tostring(_c("start")) .. '"')
        ENDLUA
        db $0E
        db $00,$00
        dw start
        db $00
        db $0D
line20_end:
basic_end:

        TAPEND

        ; Machine-code header
        TAPOUT TAPE_FILE,0
        db $03
        db "NIGHTBUS  "
        dw code_end-start
        dw start
        dw $8000
        TAPEND

        ; Machine-code body
        TAPOUT TAPE_FILE

        ORG $8000

        INCLUDE "main.asm"
code_end:

        TAPEND
