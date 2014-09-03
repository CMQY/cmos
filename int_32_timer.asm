;FILENAME : int_32_timer()
;FUNCTION : 时钟中断处理程序
;需要任务调度锁，暂定位置：0x503300

PROCLOCK equ 0x503310
selector_code equ 0x18
selector_data equ 0x08
selector_stack equ 0x10
selector_vedio equ 0x20

bits 32
global int_32_timer
extern dispatcher

		;ss			;0x54
		;esp		;0x50
		;eflags		;0x4c
		;cs			;0x48
		;eip		;0x44
int_32_timer:
		cli
		pushad
		;temp<--esp	;0x40
		;eax		;0x3c
		;ecx		;0x38
		;edx		;0x34
		;ebx		;0x30
		;temp(esp)	;0x2c	x
		;ebp		;0x28
		;esi		;0x24
		;edi		;0x20
		push cs		;0x1c	x
		push ds		;+0x18
		push es		;+0x14
		push fs		;+0x10
		push gs		;+0xc
		pushf		;+0x8	x
		mov ax,selector_data
		mov ds,ax
		mov es,ax
		mov gs,ax
		mov ax,selector_vedio
		mov fs,ax
		mov eax,PROCLOCK
		mov ebx,[eax]
	;	jmp $
		cmp ebx,0
		jz nodispatch

		call dispatcher

nodispatch:
		mov al,0x20    ;发送EOI信号
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

