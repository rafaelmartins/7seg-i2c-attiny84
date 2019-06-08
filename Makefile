# This is a simple build system for attiny mcus.

# this is the programmer I have, so lets use it by default
AVRDUDE_PROGRAMMER ?= usbtiny
AVRDUDE_PORT ?= usb

# the final target of this project is attiny84, because it needs more IO pins,
# but I'm starting development with attiny85, because it is what I have wired
# up in the breadboard right now :^)
AVR_MCU ?= attiny85


### fuse-related settings

# use internal clock at 8mhz
AVR_FUSE_LOW = 0xE2
AVR_CPU_FREQUENCY = 8000000UL

# spi programming enabled
AVR_FUSE_HIGH = 0xDF

AVR_FUSE_EXTENDED = 0xFF
AVR_LOCKBIT = 0xFF


### toolchain

AVRDUDE = avrdude
CC = avr-gcc
OBJCOPY = avr-objcopy
SIZE = avr-size


### build flags

CFLAGS = \
	-std=gnu99 \
	-mmcu=$(AVR_MCU) \
	-DF_CPU=$(AVR_CPU_FREQUENCY) \
	-Os \
	-funsigned-char \
	-funsigned-bitfields \
	-fpack-struct \
	-fshort-enums \
	-fno-unit-at-a-time \
	-Wall \
	-Wextra \
	-Werror \
	$(NULL)

LDFLAGS = \
	-Wl,-Map=firmware.map,--cref \
	$(NULL)


### source files

SOURCES = \
	main.c \
	$(NULL)

HEADERS = \
	$(NULL)


### build rules

all: firmware.hex

%.hex: %.elf
	$(OBJCOPY) \
		-O ihex \
		-j .data \
		-j .text \
		$< \
		$@

%.elf: $(SOURCES) $(HEADERS) Makefile
	$(CC) \
		$(CFLAGS) \
		$(SOURCES) \
		-o $@ \
		$(LDFLAGS)
	@$(MAKE) --no-print-directory size

size: firmware.elf
	@echo;$(SIZE) \
		--mcu=$(AVR_MCU) \
		-C $<

flash: firmware.hex
	$(AVRDUDE) \
		-p $(AVR_MCU) \
		-c $(AVRDUDE_PROGRAMMER) \
		-P $(AVRDUDE_PORT) \
		-U flash:w:$< \
		-U lfuse:w:$(AVR_FUSE_LOW):m \
		-U hfuse:w:$(AVR_FUSE_HIGH):m \
		-U efuse:w:$(AVR_FUSE_EXTENDED):m \
		-U lock:w:$(AVR_LOCKBIT):m

clean:
	-$(RM) \
		firmware.elf \
		firmware.hex \
		firmware.map

.PHONY: all size flash clean
