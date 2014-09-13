;FILENAME : int_80_systemcall.asm
;FUNCTION : 提供系统调用，使用三个参数
;系统调用提供形式：void systemcall(b32 type,b32 arg1,b32 arg2)
bits 32
global int_80_systemcall
extern print,exec,keyout

PROCLOCK equ 0x503310
selector_code equ 0x18
selector_data equ 0x08
selector_stack equ 0x10
selector_vedio equ 0x20

int_80_systemcall:
		cli
		push ebp
		mov ebp,esp
		pushad
		push ds
		push es
		push fs
		push gs

		mov ebx,cr3
		push ebx
		mov eax,0x100000
		mov cr3,eax
		mov eax,cr4
		and eax,0xFFEF
		mov cr4,eax
		mov ax,selector_data
		mov ds,ax
		mov es,ax
		mov gs,ax
		mov ax,selector_vedio
		mov fs,ax

		mov eax,[ebp+12]
		cmp eax,1
		jz call1
		cmp eax,2
		jz call2
		cmp eax,3
		jz call3
		cmp eax,4
		jz call4
		jmp non

call1:	
		call proclock
		jmp non
call2:
		call procunlock
		jmp non
call3:	
		push dword [ebp+0x10]
		call print
		add esp,4
		jmp non
call4:
		push dword [ebp+0x10]
		call keyout
		add esp,4
		jmp non
non:	
		mov ebx,cr4
		or ebx,0x10
		mov cr4,ebx
		pop ebx
		mov cr3,ebx
		pop gs
		pop fs
		pop es
		pop ds
		popad
		leave
		sti
		retf 12


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

