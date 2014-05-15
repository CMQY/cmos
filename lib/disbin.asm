;nasm -o disbin.o
;disptr(char *P)
;stosb	DI
;
;
SELECTOR_DATA	EQU	8H	;ds
SELECTOR_STACK	EQU	10H	;ss
SELECTOR_CODE32	EQU	18H	;cs
SELECTOR_VEDIO	EQU	20H	;fs

GLOBAL disbin
CursorPos	EQU	0C000h	;4 BITS
[SECTION .CODE32]
disbin:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	AX,SELECTOR_VEDIO
	MOV	ES,AX
	MOV	EDI,[CursorPos]
	MOV	EAX,[EBP+8]
	MOV	ECX,4H
db_L:
	ROL	EAX,1		;循环左移四位
	ROL	EAX,1
	ROL	EAX,1
	ROL	EAX,1
	CMP	AL,'9'
	JA	db_B
	ADD	AL,'0'
	STOSB	AL
	MOV	AL,02H
	STOSB	AL
	JMP	db_NEXT

db_B:
	SUB	AL,10H
	ADD	AL,'A'
	STOSB	AL
	MOV	AL,02H
	STOSB
db_NEXT:
	LOOP	db_L
	MOV	[CursorPos],EDI
	RET	4
