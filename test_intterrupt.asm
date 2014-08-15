	ORG 0x7c00
	jmp start
	nop
	%include "inc/fat16head.inc"

message db 'test success',0
errmesa	db 'error',0

start:
		mov ax,cs
		mov ds,ax
		mov ax,0B800H
		mov es,ax
		mov ax,0
		mov ss,ax
		mov sp,7c00H
		cld
		
		mov di,160
		mov ebx,0
.next:
		mov eax,0E820h
		add di,20
		mov ecx,20
		mov edx,0534d4150H
		int 0x15
		jc .err
		cmp ebx,0
		jz .end
		jmp .next

.end:	
		xor di,di
		mov si,message
.next2:	lodsb 
		cmp al,0
		jz .end2
		stosb
		mov byte [es:di],02
		inc di
		jmp .next

.end2:
		jmp $

.err:	
		mov di,360
		mov si,errmesa
.next3:	lodsb 
		cmp al,0
		jz .end2
		stosb
		mov byte [es:di],02
		inc di
		jmp .next3 

	times 510-($-$$) db 0
		dw 0xAA55
