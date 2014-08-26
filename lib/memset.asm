;FILENAME : memset.asm
;FUNCTION : 提供void memset(b32 addr,b32 size) 函数,默认填充0

global memset

memset:
	push ebp
	mov ebp,esp
	push edi
	push ecx

	mov edi,[ebp+8]
	mov ecx,[ebp+0xc]
	mov al,0
	cld
.L:
	stosb
	loop .L

	pop ecx
	pop edi
	leave
	ret
