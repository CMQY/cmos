	ORG	20000H
	JMP	SHORT KERNALSTART	;SHORT 不能少，否则跳转后第一条指令异常，不知为何。
	%include	"inc/kernal.inc"
[SECTION CODE32]
ALIGN	32
[BITS	32]
KERNALSTART:
	MOV	DX,0300H
	MOV	CL,02H
	MOV	ESI,MS_KERNAL
	CALL	DISPLAYSTR32
	JMP	$

[SECTION DATA]
ALIGN	32
_MS_KERNAL	DB	'In kernal now',0


MS_KERNAL	EQU	_MS_KERNAL+KERNALADDR
[SECTION .CODE32_CALL]		;32位下的调用
ALIGN	32
[BITS	32]
;功能为显示一个用0结束的字符串
;参数：
;(dh)=行号
;(dl)=列号
;(cl)=颜色
;ds:si指向字符串首地址。

DISPLAYSTR32:	      
	PUSH EAX       
	PUSH EBX
	PUSH EDI
	MOV AL,160D
	MUL DH
	MOV DI,AX
	MOV AL,2        
	MUL DL          
	ADD DI,AX
	MOV BL,CL
AGAIN32:	
	MOV CX,[ESI]
	MOV CH,0
	JCXZ NO7CRET32
	MOV [FS:DI],CL
	MOV [FS:DI+1],BL
	INC ESI
	ADD DI,2
	JMP SHORT AGAIN32
	
NO7CRET32:        
	POP EDI
        POP EBX
        POP EAX
	RET
