;FILENAME : print16.asm
;FUNCTION : 十六位下打印以0结束的字符串
;USAGE    : void print16161616161616161616161616161616(void *)
;NOTICE   : 不能卷屏,隐藏使用ds传参
;
global print16

CursorPos16   EQU 0BE00h  ;4 BITS  16位下光标位置，进入32位后修正

print16:
		push bp
		mov bp,sp

		push es
		push si
		push di
		push ds
		mov ax,CursorPos16
		mov ds,ax
		mov di,[2]
		pop ds
		mov ax,0b800h
		mov es,ax
		mov si,[bp+4]
		cld
.next:
		lodsb
		cmp al,0
		jz .end
		stosb 

		mov al,02
		stosb
		
		jmp .next

.end:	
		push ds
		mov ax,CursorPos16
		mov ds,ax
		mov [2],di
		pop ds
		pop di
		pop si
		pop es
		leave
		ret
