;任务调度执行部件，内嵌选择部件

global dispatcher
extern printdword,quenein,queneout,savecontext

READYAddr equ 0x501100
READYBottom equ 0x502100
READYhead equ 0x503220
READYtail equ 0x503224

TSSADDR equ 0x1CA00
CURPCB equ 0x503230
READY equ 0x1
RUN equ 0x0

user_data equ 0x33
user_stack equ 0x3b
user_code equ 0x43

dispatcher:

;保存PCB
	push ebp
	mov ebp,esp
	mov ebx,CURPCB	;取当前PCB地址
	mov eax,[ebx]

	mov ebx,cr3
	mov [eax],ebx
	mov dword [eax+0x2c],READY
	
	push eax
	push eax
	lea ebx,[ebp+0x18]
	push ebx;
	call savecontext;
	add esp,0x8
	pop eax
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
	mov dword [eax+0x2c],RUN
	
;修改CURPCB
	mov ebx,CURPCB
	mov [ebx],eax
	
	push eax
	push eax
	call printdword
	add esp,4
	pop eax

;恢复CPU上下文
	mov ecx,[eax+0x10]
	mov edx,[eax+0x14]
	mov ebp,[eax+0x20]
	mov esi,[eax+0x24]
	mov edi,[eax+0x28]

	mov bx,user_data
	mov es,bx
	mov ds,bx
	mov fs,bx
	mov gs,bx

	push dword [eax+0x38]
	push dword [eax+0x1c]
	push dword [eax+0x8]
	push dword [eax+0x34]
	push dword [eax+0x4]
	push dword [eax+0xc] ;eax
	push dword [eax+0x18] ;ebx
	mov ebx,[eax]
	mov cr3,ebx
	pop ebx
	mov al,0x20
	out 0x20,al
	pop eax
	sti
	iret
