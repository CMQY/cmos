;FILENAME : int_80_systemcall.asm
;FUNCTION : 提供系统调用，使用三个参数
;系统调用提供形式：void systemcall(b32 type,b32 arg1,b32 arg2)
bits 32
global int_80_systemcall
extern print

PROCLOCK equ 0x503310

int_80_systemcall:
		cli
		push ebp
		mov ebp,esp
		pushad
		push ds
		push es
		push fs
		push gs

		mov eax,[ebp+8]
		cmp eax,1
		jz call1
		cmp eax,2
		jz call2
		cmp eax,3
		jz call3
		jmp non

call1:	
		call proclock
		jmp non
call2:
		call procunlock
		jmp non
call3:	
		push dword [ebp+0xc]
		call print
		add esp,4
non:	
		pop gs
		pop fs
		pop es
		pop ds
		popad
		leave
		iret


proclock:
		push eax
		mov eax,PROCLOCK
		mov dword [eax],0
		pop eax
		ret

procunlock:
		push eax
		mov eax,PROCLOCK
		mov dword [eax],1
		pop eax
		ret

