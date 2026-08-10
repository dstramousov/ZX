#!/usr/bin/env python3
"""Build a minimal uncompressed Z80 v3 snapshot for a Sinclair ZX Spectrum 128K.

The assembled program is placed in RAM bank 2 at $8000.
The snapshot starts execution directly at the supplied PC, bypassing BASIC/tape.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import struct


PAGE_SIZE = 16 * 1024
CODE_BASE = 0x8000


def z80_v3_header(pc: int, sp: int = 0xFF00) -> bytes:
    # 30-byte base header. PC=0 marks a v2/v3 snapshot.
    h = bytearray(30)

    # AF, BC, HL
    h[0] = 0                    # A
    h[1] = 0                    # F
    h[2:4] = struct.pack("<H", 0)  # BC
    h[4:6] = struct.pack("<H", 0)  # HL

    h[6:8] = b"\x00\x00"        # PC=0 => extended header follows
    h[8:10] = struct.pack("<H", sp)
    h[10] = 0                   # I
    h[11] = 0                   # R
    h[12] = 0                   # border 0, uncompressed base

    h[13:15] = struct.pack("<H", 0)  # DE
    h[15:17] = struct.pack("<H", 0)  # BC'
    h[17:19] = struct.pack("<H", 0)  # DE'
    h[19:21] = struct.pack("<H", 0)  # HL'
    h[21] = 0                   # A'
    h[22] = 0                   # F'
    h[23:25] = struct.pack("<H", 0)  # IY
    h[25:27] = struct.pack("<H", 0)  # IX
    h[27] = 0                   # IFF1
    h[28] = 0                   # IFF2
    h[29] = 1                   # interrupt mode 1

    # Z80 v3 additional header, length 54.
    ext = bytearray(54)
    ext[0:2] = struct.pack("<H", pc)
    ext[2] = 4                  # hardware mode 4 = Sinclair 128K in v3
    ext[3] = 0                  # last OUT to $7FFD: bank 0, screen 5, ROM 0
    ext[4] = 0                  # Interface I ROM not paged
    ext[5] = 0                  # emulator flags
    ext[6] = 0                  # last OUT to $FFFD (AY selected register)
    # ext[7:23] are AY registers, left at zero.
    # Remaining v3 fields are also zero.

    return bytes(h) + struct.pack("<H", len(ext)) + bytes(ext)


def page_block(z80_page: int, data: bytes) -> bytes:
    if len(data) != PAGE_SIZE:
        raise ValueError(f"page {z80_page}: expected {PAGE_SIZE} bytes, got {len(data)}")
    # $FFFF means the following page is stored uncompressed.
    return b"\xff\xff" + bytes([z80_page]) + data


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", required=True, dest="bin_file")
    ap.add_argument("--start", required=True, dest="start_file")
    ap.add_argument("--out", required=True, dest="out_file")
    args = ap.parse_args()

    code = Path(args.bin_file).read_bytes()
    if len(code) > PAGE_SIZE:
        raise SystemExit(
            f"program is {len(code)} bytes; fixed bank 2 can hold at most {PAGE_SIZE}"
        )

    start_raw = Path(args.start_file).read_bytes()
    if len(start_raw) != 2:
        raise SystemExit(f"{args.start_file}: expected exactly 2 bytes")
    pc = struct.unpack("<H", start_raw)[0]

    if not (CODE_BASE <= pc <= 0xBFFF):
        raise SystemExit(f"entry point ${pc:04X} is outside fixed bank 2")

    # Physical Spectrum 128 RAM banks 0..7.
    banks = [bytearray(PAGE_SIZE) for _ in range(8)]

    # $8000-$BFFF is always physical RAM bank 2.
    banks[2][0:len(code)] = code

    out = bytearray(z80_v3_header(pc))

    # Z80 snapshot page numbers 3..10 map to physical RAM banks 0..7.
    for bank in range(8):
        z80_page = bank + 3
        out += page_block(z80_page, bytes(banks[bank]))

    Path(args.out_file).write_bytes(out)

    print(
        f"Z80 snapshot: {args.out_file} | "
        f"128K | PC=${pc:04X} | code={len(code)} bytes"
    )


if __name__ == "__main__":
    main()
