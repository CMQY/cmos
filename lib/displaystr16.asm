;nasm -o displaystr16.o displaystr16.asm
;功能为显示一个用0结束的字符串
;参数：
;(dh)=行号
;(dl)=列号
;(cl)=颜色
;ds:si指向字符串首地址。
GLOBAL displaystr16
[SECTION .CODE16]
[BITS 16]
DisplayStr16:	      
	PUSH AX       
	PUSH BX
	PUSH DI
	MOV BX,0B800H
	MOV ES,BX
	MOV AL,160D
	MUL DH
	MOV DI,AX
	MOV AL,2        
	MUL DL          
	ADD DI,AX
	MOV BL,CL
AGAIN:	
	MOV CX,[SI]
	MOV CH,0
	JCXZ NO7CRET
	MOV [ES:DI],CL
	MOV [ES:DI+1],BL
	INC SI
	ADD DI,2
	JMP SHORT AGAIN
	
NO7CRET:        
	POP DI
        POP BX
        POP AX
	RET
