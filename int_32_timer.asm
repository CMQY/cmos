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

		;ss			;0x48
		;esp		;0x44
		;eflags		;0x40
		;cs			;0x3c
		;eip		;0x38
int_32_timer:
		cli
		pushad
		;temp<--esp	;
		;eax		;0x34
		;ecx		;0x30
		;edx		;0x2c
		;ebx		;0x28
		;temp(esp)	;0x24	x
		;ebp		;0x20
		;esi		;0x1c
		;edi		;0x18
		push gs		;0x14
		push fs		;0x10
		push es		;0xc
		push ds		;0x8
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
		pop gs
		pop fs
		pop es
		pop ds
		popad
		sti
		iret

