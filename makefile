NASM32		=	nasm -f elf
GCC32		=	gcc -c -m32 -fno-builtin
AS32		=	as -32
LD		=	ld -m elf_i386 -static



everything	=	boot.bin loader.bin kernal.bin 
kernal		=	kernal.o lib/print.o lib/exit.o interrupt.o initinterrupt.o interrupttransfer.o
boot.bin : boot.asm inc/fat16head.inc
	nasm -o $@ $<
loader.bin : loader.asm inc/loader.inc
	nasm -o $@ $<
 
# kernal.bin : kernal.asm inc/kernal.inc
# 	nasm -o $@ $<

lib/disbin.o : /lib/disbin.asm
	$(NASM32) -o $@ $^
lib/displaymeminfo.o : lib/displaymeminfo.c inc/type.h
	$(GCC) -c -m32 -fno-builtin -o $@ $<
lib/displaystr16.o : lib/displaystr16.asm
	$(NASM32) -o $@ $<
lib/getmemoryinfo.o : lib/getmemoryinfo.asm
	$(NASM32) -o $@ $<
	ld	
lib/print.o : lib/print.asm
	$(NASM32) -o $@ $<
lib/exit.o : lib/exit.asm
	$(NASM32) -o $@ $<
build : boot.bin loader.bin kernal.bin
	dd if=boot.bin of=boot.img bs=512 conv=notrunc count=1
	mount boot.img /mnt
	cp loader.bin /mnt
	cp kernal.bin /mnt
	umount /mnt

kernal.o : kernal.c inc/type.h
	$(GCC32) -o $@ $<
interrupt.o : interrupt.c inc/type.h
	$(GCC32) -o $@ $<

initinterrupt.o : initinterrupt.c inc/type.h
	$(GCC32) -o $@ $<
interrupttransfer.o : interrupttransfer.asm
	$(NASM32) -o $@ $<


kernal.bin : $(kernal)
	$(LD) -Ttext 0x40000 -o $@ $^

clean : 
	rm $(everything)
