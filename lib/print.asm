;º¯Êýµ÷ÓÃ¹ßÀý
;¹ßÀýÖžÃ÷ŒÄŽæÆ÷EAX¡¢EDXºÍECXµÄÄÚÈÝ±ØÐëÓÐµ÷ÓÃÕß×ÔŒºžºÔð±£Žæ£¬±»µ÷ÓÃº¯Êý¿ÉÒÔËæÒâÆÆ»µ
;EBX¡¢ESI¡¢EDI¡¢ESP¡¢EBP±ØÐëÓÉ±»µ÷ÓÃÕß±£Žæ

;
SELECTOR_DATA	EQU	8H
SELECTOR_STACK	EQU	10H
SELECTOR_CODE32	EQU	18H
SELECTOR_VEDIO	EQU	20H
;print(char *str)
;
;DS:ESI--->ES:EDI
;
CursorPos	EQU	0BE00h	;4 BITS
global print
[SECTION .CODE32]

print:
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	ESI
	PUSH	EDI
	PUSH	EBX
	MOV	AX,SELECTOR_VEDIO
	MOV	ES,AX
	MOV	EDI,[CursorPos]
	MOV	ESI,[EBP+8]
	CLD

.p_NEXT:
	CMP	EDI,0FA0H
	JB	.p_NEXT2
	CALL	.SCROLL			;unfinish .scroll
.p_NEXT2:
	LODSB
	CMP	AL,0AH
	JNE	.p_NC
	MOV	EAX,EDI
	MOV	BL,160
	DIV	BL
	AND	EAX,0FFH
	INC	EAX
	MOV	BL,160
	MUL	BL
	MOV	EDI,EAX
	JMP	.p_NEXT

.p_NC:
	CMP	AL,0H
	JE	.p_END
	STOSB
	MOV	AL,02H
	STOSB
	JMP	.p_NEXT
.p_END:
	MOV	[CursorPos],EDI
	POP	EBX
	POP	EDI
	POP	ESI
	LEAVE
	RET

.SCROLL:
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	ESI
	PUSH	EDI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	DS
	MOV	AX,SELECTOR_VEDIO
	MOV	DS,AX
	MOV	CX,780H
	MOV	EDI,0H
	MOV	ESI,160
.L:
	MOVSW
	LOOP	.L
	MOV	AX,0H
	MOV	CX,80
.L2:
	STOSW
	LOOP	.L2
	MOV	EAX,[EBP-8]
	SUB	EAX,160
	MOV	[EBP-8],EAX
	POP	DS
	POP	ECX
	POP	EBX
	POP	EAX
	POP	EDI
	POP	ESI
	LEAVE
	RET	
