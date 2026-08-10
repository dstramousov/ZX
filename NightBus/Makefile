ASM=sjasmplus
PYTHON=python3

all: build/nightbus.tap build/nightbus.z80

build/nightbus.tap: src/main.asm src/memory.asm src/paging.asm src/interrupts.asm src/tape.asm
	$(ASM) src/tape.asm

build/nightbus.bin build/nightbus.start: src/main.asm src/memory.asm src/paging.asm src/interrupts.asm src/dev.asm
	$(ASM) src/dev.asm

build/nightbus.z80: build/nightbus.bin build/nightbus.start tools/make_z80.py
	$(PYTHON) tools/make_z80.py \
		--bin build/nightbus.bin \
		--start build/nightbus.start \
		--out build/nightbus.z80

clean:
	rm -f build/*
