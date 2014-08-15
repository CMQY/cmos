; FILENAME : getmemoryinfo.asm
; FUNCTION : 获取内存信息，以备保护模式下显示和内存管理时使用
; USAGE	   : void get_memoryinfo ()

MemoryInfoSeg       EQU 0BB0H
MemoryInfoOffset    EQU 0H

message1 db 'Get memory information error!',0

extern print16
global getmemoryinfo

getmemoryinfo:
		push bp
		mov bp,sp
		push es
		push ds
		push di
		push bx
		push cx
		xor cx
		mov ax,cs
		mov ds,ax
	
		mov ax,MemoryInfoSeg
		mov es,ax
		mov di,MemoryinfoOffet+4
		mov ebx,0
.next:
		mov eax,0E820h
		mov ecx,20
		mov edx,0534d4150h
		int 0x15
		jc .err
		inc cx
		cmp ebx,0
		jz .end
		add di.20
		jmp .next

.err:	
		push message1
		call print16
		add sp,2

.end:	
		mov [0],2  ;存放内存块数
		pop cx
		pop bx
		pop di
		pop ds
		pop es
		leave 
		ret

