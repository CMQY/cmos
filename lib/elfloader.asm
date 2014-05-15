KernalAddr	EQU	20000H	;加载KERNAL内存段地址

loadkernal:
	XOR	ESI,ESI
	MOV	CX,[KernalAddr+2CH]
	MOVZX	ECX,CX
	MOV	ESI,[KernalAddr+1CH]
	ADD	ESI,KernalAddr
.LKMOVE
	MOV	EAX,[ESI]
	CMP	EAX,0
	JZ	.PASS
	PUSH	DWORD [ESI+010H]
	MOV	EAX,[ESI+04H]
	ADD	EAX,KernalAddr
	PUSH	EAX
	PUSH	DWORD	[ESI+08H]
	CALL	memcpyasm	;void *memcpy(void *destin, void *source, unsigned n); 
.PASS:
	ADD	ESI,020H
	DEC	ECX
	JNZ	.LKMOVE

	RET
;------------------------------------------------------
;memcpyasm
;DS:ESI->ES:EDI
;------------------------------------------------------
memcpyasm:		;void *memcpy(void *destin, void *source, unsigned n); 
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EDI,[ESP+8]
	MOV	ESI,[ESP+12]
	MOV	ECX,[ESP+16]
        CLD
.1	CMP	ECX,0
	JZ	.2
	MOVSB
	DEC	ECX
	JZ	.1
.2	MOV	EAX,[ESP+16]
	LEAVE
	RET	12