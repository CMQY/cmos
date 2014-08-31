;FILENAME : int_32_timer()
;FUNCTION : 时钟中断处理程序
;需要任务调度锁，暂定位置：0x503300

PROCLOCK equ 0x503300


bits 32
global int_32_timer
int_32_timer:
		cli
		pushad
		;temp<--esp	;0x40
		;eax		;0x3c
		;ecx		;0x38
		;edx		;0x34
		;ebx		;0x30
		;temp(esp)	;0x2c
		;ebp		;0x28
		;esi		;0x24
		;edi		;0x20
		push cs		;0x1c
		push ds		;+0x18
		push es		;+0x14
		push fs		;+0x10
		push gs		;+0xc
		pushf		;+0x8
		mov eax,PROCLOCK
		mov ebx,[eax]
		cmp ebx,0
		jz nodispatch

		call dispatcher

nodispatch:
		mov al,0x20    //发送EOI信号
		out 0x20,al
		popf
		pop gs
		pop fs
		pop es
		pop ds
		pop eax		;丢弃cs
		popad
		sti
		iret

