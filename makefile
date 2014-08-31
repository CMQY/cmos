NASM32		=	nasm -f elf
GCC32		=	gcc -c -m32 -fno-builtin -W
AS32		=	as -32
LD		=	ld -m elf_i386 -static
LD86	=	ld86 -T 0


everything	=	boot.bin loader.bin kernel.bin 
kernel		=	kernel.o lib/print.o lib/exit.o interrupt.o initinterrupt.o interrupttransfer.o inittss.o initgdt.o keyboard_ctl.o lib/printbin.o lib/scrollscreen.o do_systemcall.o mem_mgr.o lib/hd_drive.o lib/lbatochs.o key_handle.o proc.o fat16_driver.o proc_link_stack.o quene.o lib/memset.o
boot.bin : boot.asm inc/fat16head.inc
	nasm -o $@ $<
loader.bin : loader.asm inc/loader.inc
	nasm -o $@ $<


# kernal.bin : kernel.asm inc/kernal.inc
# 	nasm -o $@ $<

lib/disbin.o : lib/disbin.asm
	$(NASM32) -o $@ $^
lib/scrollscreen.o : lib/scrollscreen.asm
	$(NASM32) -o $@ $<
lib/displaymeminfo.o : lib/displaymeminfo.c inc/type.h
	$(GCC) -c -m32 -fno-builtin -o $@ $<

lib/print.o : lib/print.asm
	$(NASM32) -o $@ $<
lib/printbin.o : lib/printbin.asm
	$(NASM32) -o $@ $<
lib/exit.o : lib/exit.asm
	$(NASM32) -o $@ $<
lib/hd_drive.o : lib/hd_drive.asm
	$(NASM32) -o $@ $<
lib/lbatochs.o : lib/lbatochs.c
	$(GCC32) -o $@ $<
lib/memset.o : lib/memset.asm
	$(NASM32) -o $@ $<

#test_intterrupt.o : test_intterrupt.asm
#	$(NASM32) -o $@ $<
build : boot.bin loader.bin kernel.bin
	dd if=boot.bin of=boot.img bs=512 conv=notrunc count=1
	mount boot.img /mnt
	cp loader.bin /mnt
	cp kernel.bin /mnt
	umount /mnt
	rm *.bin *.o lib/*.o

kernel.o : kernel.c inc/type.h
	$(GCC32) -o $@ $<
interrupt.o : interrupt.c inc/type.h
	$(GCC32) -o $@ $<

keyboard_ctl.o :keyboard_ctl.asm
	$(NASM32) -o $@ $<
key_handle.o : key_handle.c
	$(GCC32) -o $@ $<

initinterrupt.o : initinterrupt.c inc/type.h
	$(GCC32) -o $@ $<
interrupttransfer.o : interrupttransfer.asm
	$(NASM32) -o $@ $<
inittss.o : inittss.c inc/type.h
	$(GCC32) -o $@ $<
initgdt.o :initgdt.c inc/type.h
	$(GCC32) -o $@ $<
do_systemcall.o : do_systemcall.c
	$(GCC32) -o $@ $<
mem_mgr.o : mem_mgr.c
	$(GCC32)  -o $@ $<

kernel.bin : $(kernel)
	$(LD) -Ttext 0x40000 -o $@ $^

clean : 
	rm $(everything)

proc.o : proc.c
	$(GCC32) -o $@ $<
quene.o : quene.c
	$(GCC32) -o $@ $<
proc_link_stack.o : proc_link_stack.c
	$(GCC32) -o $@ $<
fat16_driver.o : fat16_driver.asm
	$(NASM32) -o $@ $<

int_80_systemcall.o :int_80_systemcall.asm
	$(NASM32) -o $@ $<
program.o : console.c
	nasm -o $@ $<
