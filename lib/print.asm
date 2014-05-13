;�������ù���
;����ָ���Ĵ���EAX��EDX��ECX�����ݱ����е������Լ����𱣴棬�����ú������������ƻ�
;EBX��ESI��EDI��ESP��EBP�����ɱ������߱���
SELECTOR_DATA	EQU	0H
SELECTOR_STACK	EQU	8H
SELECTOR_CODE32	EQU	10H
SELECTOR_VEDIO	EQU	18H
;print(char *str)
;
;DS:ESI--->FS:EDI
;
CursorPos	EQU	0BE00h	;4 BITS
[SECTION .CODE32]
GLOBAL print
print:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EDI,[CursorPos]
	MOV	ESI,[EBP+8]
	CLD
p_NEXT:
	LODSB
	CMP	AL,0AH
	JNE	p_NC
	MOV	EAX,EDI
	MOV	BL,160
	DIV	BL
	AND	EAX,0FFH
	INC	EAX
	MOV	BL,160
	MUL	BL
	MOV	EDI,EAX
	JMP	p_NEXT

p_NC:
	CMP	AL,0H
	JE	p_END
	STOSB
	MOV	AL,02H
	STOSB
	JMP	p_NEXT
p_END:
	MOV	[CursorPos],EDI
	RET	4