global memcpy

memcpy:		;void *memcpy(void *destin, void *source, unsigned n); 
	push ebp
	mov ebp,esp
	push esi
	push edi
	push ds
	push es
	mov ax,0x08
	mov ds,ax
	mov es,ax
	cld
	mov esi,[ebp+0xc]
	mov edi,[ebp+0x8]
	mov ecx,[ebp+0x10]
.L:
	movsb
	loop .L

	pop es
	pop ds
	pop edi
	pop esi
	leave
	ret
