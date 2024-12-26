CC = riscv-none-elf-gcc
CFLAGS = -nostdlib -march=rv32imc_zicsr -mabi=ilp32 -g -Os
LDFLAGS = -T esp32c3.ld
SRCS = interrupts.S ivectors.S start.S wdt.S systimer.S uart_utils.S cli.c kernel.S
PORT = COM3

dict.txt: dict.json
	python gendict.py

a.elf: $(SRCS) dict.txt
	$(CC) $(CFLAGS) $(SRCS) $(LDFLAGS) -o $@

a.e2i: a.elf
	esptool --chip esp32c3 elf2image --flash_mode dio --flash_freq 80m --flash_size 4MB a.elf -o $@

flash: a.e2i
	esptool -p $(PORT) --chip esp32c3 write_flash 0x0 a.e2i

clean:
	rm a.elf a.e2i
