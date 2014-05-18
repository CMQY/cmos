memcpyasm:		;void *memcpy(void *destin, void *source, unsigned n); 
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	EDI
	PUSH	ESI
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
	POP	ESI
	POP	EDI
	LEAVE
	RET
