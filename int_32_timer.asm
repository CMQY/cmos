;FILENAME : int_32_timer()
;FUNCTION : 时钟中断处理程序
;需要任务调度锁，暂定位置：0x503300

PROCLOCK equ 0x503300


bits 32
global int_32_timer
int_32_timer:
		cli
		pushad
		push ds
		push es
		push fs
		push gs
		mov eax,PROCLOCK
		mov ebx,[eax]
		cmp ebx,0
		jz nodispatch

		call dispatcher

nodispatch:
		mov al,0x20    //发送EOI信号
		out 0x20,al
		pop gs
		pop fs
		pop es
		pop ds
		popad
		sti
		iret

