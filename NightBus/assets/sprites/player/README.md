# Player sprites

Five 16x16 player variants. Variant 4 (coat + scarf) is the default.

Each `sprites.bin` contains six 32-byte frames:
right_idle, right_walk_1, right_walk_2,
left_idle, left_walk_1, left_walk_2.

A 16x16 monochrome frame is 16 rows x 2 bytes = 32 bytes.
One full variant is 192 bytes.

`*_16x16.png` files are native-resolution previews.
`*_x8.png` and `sheet_x8.png` are nearest-neighbour developer previews.

Runtime is currently white INK on black PAPER. This keeps 1-pixel smooth motion
free of ZX Spectrum attribute clash. Colour attributes will be handled separately.
