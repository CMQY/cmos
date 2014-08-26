;时钟中断

CURPCB equ 0x503230
RAEDY equ 0x1
dispatcher:
	cli
	push eax
	push ebx
	push ecx
	push edx
	push ebp
	push esi
	push edi
	push ds
	push es
	push fs
	push gs
	pushf
	
;保存PCB
	mov ebx,CURPCB
	mov eax,[ebx]
	mov [eax],esp
	mov [eax+4],ERADY
	mov [eax+8],cr3

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
	mov [eax+4],RUN
	
;修改CURPCB
	mov ebx,CURPCB
	mov [ebx],eax

	mov esp,[eax]
	mov cr3,[eax+8]

	popf
	pop gs
	pop fs
	pop es
	pop ds
	pop edi
	pop esi
	pop ebp
	pop edx
	pop ecx
	pop ebx
	pop eax
	sti
	iret
