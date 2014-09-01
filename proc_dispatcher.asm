;任务调度执行部件，内嵌选择部件

global dispatcher
extern printbyte,quenein,queneout

READYAddr equ 0x501100
READYBottom equ 0x502100
READYhead equ 0x503220
READYtail equ 0x503224

TSSADDR equ 0x1CA00
CURPCB equ 0x503230
READY equ 0x1
RUN equ 0x0
dispatcher:

;保存PCB
	push ebp
	mov ebp,esp
	mov ebx,CURPCB	;取当前PCB地址
	mov eax,[ebx]

	mov ebx,[ebp+8]
	mov [eax+0x4c],ebx	;eflags

	mov ebx,[ebp+0xc]
	mov [eax+0x48],ebx	;gs

	mov ebx,[ebp+0x10]
	mov [eax+0x44],ebx	;fs
	
	mov ebx,[ebp+0x14]
	mov [eax+0x34],ebx	;es

	mov ebx,[ebp+0x18]	;ds
	mov [eax+0x40],ebx

	mov ebx,[ebp+0x48]	;cs
	mov [eax+0x38],ebx

	mov ebx,[ebp+0x20]	;edi
	mov [eax+0x30],ebx

	mov ebx,[ebp+0x24]	;esi
	mov [eax+0x2c],ebx
	
	mov ebx,[ebp+0x28]	;ebp
	mov [eax+0x28],ebx

	mov ebx,[ebp+0x50]	;esp
	mov [eax+0x24],ebx

	mov ebx,[ebp+0x30]	;ebx
	mov [eax+0x20],ebx

	mov ebx,[ebp+0x34]	;edx
	mov [eax+0x1c],ebx

	mov ebx,[ebp+0x38]	;ecx
	mov [eax+0x18],ebx

	mov ebx,[ebp+0x3c]	;eax
	mov [eax+0x14],ebx
	
	mov ebx,[ebp+0x54]	;ss
	mov [eax+0x3c],ebx

	mov ebx,[ebp+0x44]	;eip
	mov [eax+0xc],ebx

	jmp $

	mov ebx,cr3
	mov [eax+8],ebx
	mov dword [eax+0x4c],READY

;pcb进入就绪队列
	push eax
	push READYtail
	push READYhead
	push READYBottom
	push READYAddr
	call quenein
	add esp,0x14
	
;获取下一进程
	mov ebp,esp
	sub esp,4
	lea eax,[ebp-4]
	push eax
	push READYtail
	push READYhead
	push READYBottom
	push READYAddr
	call queneout
	add esp,0x14
	
	mov eax,[ebp-4]
	mov esp,ebp

;修改pcb->status
	mov dword [eax+0x4c],RUN
	
;修改CURPCB
	mov ebx,CURPCB
	mov [ebx],eax
	
	push eax
	call printbyte
	add esp,4

;恢复CPU上下文
	mov ecx,[eax+0x18]
	mov edx,[eax+0x1c]
	mov ebx,[eax+0x20]
	mov ebp,[eax+0x28]
	mov esi,[eax+0x2c]
	mov edi,[eax+0x30]
	mov es,[eax+0x34]
	mov ds,[eax+0x40]
	mov fs,[eax+0x44]
	mov gs,[eax+0x48]

	push dword [eax+0x3c]
	push dword [eax+0x24]
	push dword [eax+0x10]
	push dword [eax+0x38]
	push dword [eax+0xc]
	push dword [eax+0x14] ;eax
	push dword [eax+0x20] ;ebx
	mov ebx,[eax+0x08]
	mov cr3,ebx
	pop ebx
	mov al,0x20
	out 0x20,al
	pop eax
	sti
	iret
