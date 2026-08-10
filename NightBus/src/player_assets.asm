; Active player asset selector.
; All five variants are stored under assets/sprites/player/.
; Only the selected 192-byte set is included in the game image.

PLAYER_VARIANT = 4

player_sprite_data:
IF PLAYER_VARIANT = 1
        INCBIN "assets/sprites/player/variant_1/sprites.bin"
ENDIF
IF PLAYER_VARIANT = 2
        INCBIN "assets/sprites/player/variant_2/sprites.bin"
ENDIF
IF PLAYER_VARIANT = 3
        INCBIN "assets/sprites/player/variant_3/sprites.bin"
ENDIF
IF PLAYER_VARIANT = 4
        INCBIN "assets/sprites/player/variant_4/sprites.bin"
ENDIF
IF PLAYER_VARIANT = 5
        INCBIN "assets/sprites/player/variant_5/sprites.bin"
ENDIF

PLAYER_FRAME_SIZE = 32

player_right_idle   = player_sprite_data + PLAYER_FRAME_SIZE * 0
player_right_walk_1 = player_sprite_data + PLAYER_FRAME_SIZE * 1
player_right_walk_2 = player_sprite_data + PLAYER_FRAME_SIZE * 2
player_left_idle    = player_sprite_data + PLAYER_FRAME_SIZE * 3
player_left_walk_1  = player_sprite_data + PLAYER_FRAME_SIZE * 4
player_left_walk_2  = player_sprite_data + PLAYER_FRAME_SIZE * 5
