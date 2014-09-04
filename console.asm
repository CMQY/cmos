bits 32
		push 2
		push 2
		push 2
		call dword 0x50:0
next:
		push 0
		push 'task'
		push 0
		mov eax,esp
		add eax,4
		push eax
		push 3
		call dword 0x50:0
		add esp,8
		jmp next
