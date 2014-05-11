everything	=	boot.bin loader.bin 
boot.bin : boot.asm inc/fat16head.inc
	nasm -o $@ $<
loader.bin : loader.asm inc/loader.inc
	nasm -o $@ $<
build : boot.bin loader.bin
	dd if=boot.bin of=boot.img bs=512 conv=notrunc count=1
	mount boot.img /mnt
	cp loader.bin /mnt
	umount /mnt
clean : 
	rm $(everything)
