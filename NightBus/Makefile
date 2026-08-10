ASM=sjasmplus

all: build/nightbus.tap

build/nightbus.tap: src/main.asm src/tape.asm
	$(ASM) src/tape.asm

clean:
	rm -f build/*