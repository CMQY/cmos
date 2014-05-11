%include	"inc/loader.inc"
ORG	0H
JMP	RAELMODEBEGIN

;��JMP���룬16λ�Σ����ú�GDT��IDT�����뱣��ģʽ
[SECTION .CODE16]
[BITS 16]
RAELMODEBEGIN:
	MOV	AX,CS
	MOV	DS,AX
	MOV	AX,TopOfStack
	MOV	SP,AX


;�����ں�KERNAL.BIN
NEXTREAD:
	MOV	BX,[RootSectionStart]
	MOV	CL,1
	MOV	AX,RootDirSeg
	MOV	ES,AX
	MOV	DI,RootDirOffset
	CALL	ReadSection	;��һ������

	MOV	DX,10H		;COMPARE MAX TIMES
	CLD
COMTINUE:
	MOV	CX,11
	MOV	SI,INFOLOADER
COMPARE:
	LODSB
	CMP	BYTE 	[ES:DI],AL
	JNE	NEXTITEM
	INC	DI
	LOOP	COMPARE
	JMP	FOUND

NEXTITEM:
	DEC	DX
	CMP	DX,0
	JZ	NEXTSECTION
	AND	DI,0FFE0H	;DI	RESET
	ADD	DI,020H		;NEXT	ITEM
	JMP	COMTINUE	;JMP TO COMTINUE
	

NEXTSECTION:
	ADD	WORD	[RootSectionStart],1	;��һ������
	SUB	WORD	[RootSectionCnt],1	;������¼
	CMP	WORD	[RootSectionCnt],0
	JZ	NOLOADER		;�Ҳ���LOADER
	JMP	NEXTREAD


NOLOADER:
	MOV	DX,0200H
	MOV	CL,02H
	MOV	SI,MESSAGE3
	CALL	DISPLAYSTR
	JMP $

FOUND:
	AND	DI,0FFE0H
	ADD	DI,WORD 1AH
	MOV	BX,[ES:DI]	
NEXTFATREAD:
	MOV	AX,BX		;AX��¼FAT��ָ����һ��
	ADD	BX,DATABEGIN
	MOV	CL,1
	MOV	DX,[PhyAddrSeg]
	MOV	ES,DX
	MOV	DI,[PhyAddrOffset]
	CALL	ReadSection



	CALL	GetNextFAT
	MOV	DX,0FFEFH
	CMP	BX,DX
	JA	READEND
	ADD	WORD [PhyAddrSeg],20H
	JMP	NEXTFATREAD
READEND:
	MOV	DX,0200H
	MOV	CL,02H
	MOV	SI,MESSAGE4
	CALL	DISPLAYSTR

	JMP	JUMPTOPROTECTEDMODE

RootSectionStart	DW	47
RootSectionCnt	DW	7

RootDirSeg	EQU	07F0H	;���ظ�Ŀ¼�ε�ַ
RootDirOffset	EQU	0	;���ظ�Ŀ¼ƫ��

PhyAddrSeg	DW	2000H	;����Loader�ڴ�ε�ַ
PhyAddrOffset	DW	0	;����Loader�ڴ�ƫ��

FATItemSeg	EQU	08F0H	;����FAT��ε�ַ
FATItemOffset	EQU	0	;����FAT��ƫ��

NH		EQU	2	;��ͷ��
NS		EQU	36	;ÿ��������
DATABEGIN	EQU	52	;���ϴ���������������

TopOfStack	EQU	7C00H

INFOLOADER	DB	'KERNAL  BIN'

MESSAGE3	DB	'NO KERNAL!',0
MESSAGE4	DB	'LOAD KERNAL SUCCESSFULLY',0

;����

;----------------------------------------------------------------------------
;Find Next Fat Item 
;----------------------------------------------------------------------------
;INPUT:
;	AX=FAT Item
;OUTPUT:
;	BX=Next FAT Item
;----------------------------------------------------------------------------
GetNextFAT:
	PUSH	CX
	PUSH	DX
	XOR	DX,DX
	SHL	AX,1
	MOV	BX,512
	DIV	BX
	INC	AX
	MOV	BX,AX
	MOV	CL,1
	MOV	AX,FATItemSeg
	MOV	ES,AX
	MOV	DI,FATItemOffset
	CALL	ReadSection
	MOV	DI,DX
	MOV	BX,[ES:DI]
	POP	DX
	POP	CX
	RET


;---------------------------------------------------------------------
;Read Sections
;---------------------------------------------------------------------
;BX	LBA
;CL	Section Count
;ES=Destination Seg
;DI=Destination Offset
;----------------------------------------------------------------------
ReadSection:
	PUSH	 AX
	PUSH	DX
	PUSH	CX
	MOV	AH,00H
	MOV	DL,00H
	INT	13H
	JC	ReadSection

GoReading:
	MOV	AX,BX
	MOV	DL,NS
	DIV	DL
	XOR	AH,AH
	MOV	DL,NH
	DIV	DL
	MOV	CH,AL	;C
	MOV	DH,AH	;H
	MOV	AX,BX
	MOV	DL,NS
	DIV	DL
	ADD	AH,1
	MOV	AL,CL	;Section Count
	MOV	CL,AH	;S
	MOV	AH,02H
	MOV	DL,00H		;��һ������
	MOV	BX,DI
	INT	13H
	JC	GoReading
	POP	CX
	POP	DX
	POP	AX
	RET


;����Ϊ��ʾһ����0�������ַ���
;������
;(dh)=�к�
;(dl)=�к�
;(cl)=��ɫ
;ds:siָ���ַ����׵�ַ��

DISPLAYSTR:	      
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

;�˴����뱣��ģʽ����������ҳ
JUMPTOPROTECTEDMODE:
	LGDT	[GDTREG]
	CLI
	IN	AL,92H
	OR	AL,00000010B
	OUT	92H,AL
	MOV	EAX,CR0
	OR	EAX,1
	MOV	CR0,EAX
	JMP	DWORD	SELECTOR_CODE32:(LOADERADDR+PROTECTED_BEGIN)



[SECTION .gdt]
;GDT
;				�λ�ַ		�ν���	������
GDT:		Descriptor	0,		0,	0
GDT_DATA:	Descriptor	0,		0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW
GDT_STACK:	Descriptor	0,		0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW
GDT_CODE32:	Descriptor	0,		0FFFFFH,DA_CCOR|DA_DPL0|DA_32|DA_LIMIT_4K
GDT_VEDIO:	Descriptor	0B8000H,		0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW

GDTLEN	EQU	$-GDT
GDTREG	DW	GDTLEN-1	;����GDTRʱ�ı�����ַ;�ν���
	DD	LOADERADDR+GDT		;�λ�ַ

;ѡ����
SELECTOR_DATA	EQU	GDT_DATA-GDT
SELECTOR_STACK	EQU	GDT_STACK-GDT
SELECTOR_CODE32	EQU	GDT_CODE32-GDT
SELECTOR_VEDIO	EQU	GDT_VEDIO-GDT

[SECTION .DATA]
ALIGN	32
_MESSAGE_PROTECTEDDMODE	DB	'WELCOME TO PROTECTED MODE!!!',0



;����ģʽ��ʹ��һ�±�־
MESSAGE_PROTECTEDDMODE	EQU	_MESSAGE_PROTECTEDDMODE+LOADERADDR

[SECTION STACK]
STACKSPACE:
TIMES	1024	DB	0	;ջ�ռ����Ϊ1K
TOPOFSTACK	EQU	$+LOADERADDR

[SECTION .CODE32]
ALIGN	32
[BITS	32]
PROTECTED_BEGIN:
	MOV	AX,SELECTOR_DATA
	MOV	DS,AX
	MOV	AX,SELECTOR_STACK
	MOV	SS,AX
	MOV	AX,SELECTOR_VEDIO
	MOV	FS,AX
	MOV	SP,TOPOFSTACK

	MOV	DX,0H
	MOV	CL,02H
	MOV	SI,MESSAGE_PROTECTEDDMODE
	CALL	DISPLAYSTR32

	JMP	$

[SECTION .CODE32_CALL]		;32λ�µĵ���
ALIGN	32
[BITS	32]
;����Ϊ��ʾһ����0�������ַ���
;������
;(dh)=�к�
;(dl)=�к�
;(cl)=��ɫ
;ds:siָ���ַ����׵�ַ��

DISPLAYSTR32:	      
	PUSH AX       
	PUSH BX
	PUSH DI
	MOV BX,SELECTOR_VEDIO
	MOV ES,BX
	MOV AL,160D
	MUL DH
	MOV DI,AX
	MOV AL,2        
	MUL DL          
	ADD DI,AX
	MOV BL,CL
AGAIN32:	
	MOV CX,[SI]
	MOV CH,0
	JCXZ NO7CRET32
	MOV [ES:DI],CL
	MOV [ES:DI+1],BL
	INC SI
	ADD DI,2
	JMP SHORT AGAIN32
	
NO7CRET32:        
	POP DI
        POP BX
        POP AX
	RET
