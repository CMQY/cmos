;FILENAME : vpmlink.asm
;FUNCTION : 链接虚拟页和物理页,提供：void vpmlink(b32 vmaddr)函数
extern mempop
global vpmlink
[bits 32]
vpmlink:
		push ebp
		mov ebp,esp
		sub esp,4
		push ebx

		mov ebx,cr3
		mov eax,[ebp+8]
		mov edx,0x400000
		div edx
		mul 4
		add ebx
		push eax
		
		lea ebx,[ebp-4]
		push ebx
		call mempop
		add esp,4
		pop eax
		mov ebx,[ebp-4]
		mov [eax],ebx

		pop ebx
		leave
		ret
