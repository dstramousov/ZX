ASM=sjasmplus

all: build/nightbus.tap build/nightbus.sna

build/nightbus.tap: src/main.asm src/tape.asm
	$(ASM) src/tape.asm

build/nightbus.sna: src/main.asm src/snapshot.asm
	$(ASM) src/snapshot.asm

clean:
	rm -f build/*
