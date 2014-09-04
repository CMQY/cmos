;FILENAME : systemcall.asm
;FUNCITON : 提供ring3层系统调用转接调用门
global systemcall
systemcall:
		push ebp
		mov ebp,esp
		push dword [ebp+0x10]
		push dword [ebp+0xc]
		push dword [ebp+0x08]
		call dword 0x50:0
		leave
		ret
