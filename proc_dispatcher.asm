;任务调度执行部件，内嵌选择部件

extern dispatcher

TSSADDR equ 0x1CA00
CURPCB equ 0x503230
RAEDY equ 0x1
dispatcher:

;保存PCB
	push ebp
	mov ebp,esp
	mov ebx,CURPCB	;取当前PCB地址
	mov eax,[ebx]

	mov ebx,[ebp+8]
	mov [eax+0x10],ebx	;eflags

	mov ebx,[ebp+0xc]
	mov [eax+0x48],ebx	;gs

	mov ebx,[ebp+0x10]
	mov [eax+0x44],ebx	;fs
	
	mov ebx,[ebp+0x14]
	mov [eax+0x34],ebx	;es

	mov ebx,[ebp+0x18]	;ds
	mov [eax+0x40],ebx

	mov ebx,[ebp+0x1c]	;cs
	mov [eax+0x38],ebx

	mov ebx,[ebp+0x20]	;edi
	mov [eax+0x30],ebx

	mov ebx,[ebp+0x24]	;esi
	mov [eax+0x2c],ebx
	
	mov ebx,[ebp+0x28]	;ebp
	mov [eax+0x28],ebx

	mov ebx,[ebp+0x2c]	;esp
	mov [eax+0x24],ebx

	mov ebx,[ebp+0x30]	;ebx
	mov [eax+0x20],ebx

	mov ebx,[ebp+0x34]	;edx
	mov [eax+0x1c],ebx

	mov ebx,[ebp+0x38]	;ecx
	mov [eax+0x18],ebx

	mov ebx,[ebp+0x3c]	;eax
	mov [eax+0x14],ebx
	
	
	mov [eax+8],cr3
	mov [eax+c],eip;
	mov [eax+12],

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
	add esp 0x14
	
	mov eax,[ebp-4]
	mov esp,ebp

;修改pcb->status
	mov [eax+0x4c],RUN
	
;修改CURPCB
	mov ebx,CURPCB
	mov [ebx],eax

	push eax
	push TSSADDR
	call loadtss	;装载TSS

	push 

	mov al,0x20		;发送EOI
	out 0x20,,al
	
	push ss
	pus esp
	pushf
	push cs
	push eip
	sti
	iret
