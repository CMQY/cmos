global hd_write
[bits 32]
hd_write:
		push ebp
		mov ebp,esp
		push es
		push edi


		mov dx,1f6h
		mov al,0a0h
		out dx,al

		mov dx,1f3h
		mov al,2
		out dx,al

		mov dx,1f4h
		mov al,0
		out dx,al
		mov dx,1f7h
		mov al,30h
		out dx,al
ready:
		in al,dx
		test al,8
		jz ready
		mov cx,256
		mov ax,31ffh
		mov dx,1f0h
.L:
		out dx,ax
		loop .L
		
		pop edi
		pop es
		leave
		ret

