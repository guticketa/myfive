RISCV_PREFIX := riscv32-unknown-elf-

all: hello.elf

startup.o: startup.s
	$(RISCV_PREFIX)as -march=rv32g $< -o $@

main.o: main.c
	$(RISCV_PREFIX)gcc -Wall -O2 -march=rv32g -nostdlib -nostartfiles -ffreestanding -c $< -o $@

hello.elf: memmap startup.o main.o
	$(RISCV_PREFIX)ld startup.o main.o -T memmap -o $@
	$(RISCV_PREFIX)objdump -D hello.elf > hello.dump

.PHONY: clean
clean:
	$(RM) *.o
	$(RM) *.elf
	$(RM) *.dump
