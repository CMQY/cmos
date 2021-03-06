		ORG 0x7c00
		JMP SHORT	START
		NOP
		
%include	"inc/fat16head.inc"


START:
	MOV	AX,0600H
	MOV	BH,07
	MOV	CX,0000
	MOV	DX,184FH
	INT	10H
	MOV	AX,CS
	MOV	ES,AX
	MOV	SS,AX
	MOV	DS,AX
	MOV	SP,TopOfStack

	;输出BOOTINT
	MOV	BP,MESSAGE1
	MOV	AX,0X1301
	MOV	BX,0007H
	MOV	DX,0H
	MOV	CX,7	;STRING SIZE
	INT 	10H
	
	;JMP	NOLOADER

NEXTREAD:
	MOV	BX,[RootSectionStart]
	MOV	CL,1
	MOV	AX,RootDirSeg
	MOV	ES,AX
	MOV	DI,RootDirOffset
	CALL	ReadSection	;读一个扇区

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
	ADD	WORD	[RootSectionStart],1	;下一个扇区
	SUB	WORD	[RootSectionCnt],1	;扇区记录
	CMP	WORD	[RootSectionCnt],0
	JZ	NOLOADER		;找不到LOADER
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
	MOV	AX,BX		;AX记录FAT项指向下一簇
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
	MOV	DX,0100H
	MOV	CL,02H
	MOV	SI,MESSAGE4
	CALL	DISPLAYSTR

	JMP		1000H:0

	JMP	$

RootSectionStart	DW	47
RootSectionCnt	DW	7

RootDirSeg	EQU	07F0H	;加载根目录段地址
RootDirOffset	EQU	0	;加载根目录偏移

PhyAddrSeg	DW	1000H	;加载Loader内存段地址
PhyAddrOffset	DW	0	;加载Loader内存偏移

FATItemSeg	EQU	08F0H	;加载FAT表段地址
FATItemOffset	EQU	0	;加载FAT表偏移

NH		EQU	2	;磁头数
NS		EQU	36	;每道扇区数
DATABEGIN	EQU	52	;加上簇数便是数据扇区

TopOfStack	EQU	7C00H

INFOLOADER	DB	'LOADER  BIN'	;要加载的BIN文件，共11位，文件名8位，后缀3位
MESSAGE1	DB	'Booting'

MESSAGE3	DB	'No loader',0
MESSAGE4	DB	'Load successfully',0

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
;Read Sections   读一个扇区
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
	MOV	DL,00H		;第一个软盘
	MOV	BX,DI
	INT	13H
	JC	GoReading
	POP	CX
	POP	DX
	POP	AX
	RET


;功能为显示一个用0结束的字符串
;参数：
;(dh)=行号
;(dl)=列号
;(cl)=颜色
;ds:si指向字符串首地址。

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

TIMES	510-($-$$)	DB	0
			DW	0xAA55
