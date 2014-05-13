%include	"inc/loader.inc"
	ORG	10000H
	JMP	RAELMODEBEGIN

;由JMP跳入，16位段，设置好GDT及IDT后跳入保护模式
[SECTION .CODE16]
[BITS 16]
RAELMODEBEGIN:
	MOV	AX,CS
	MOV	DS,AX
	MOV	AX,TopOfStack
	MOV	SP,AX


;加载内核KERNAL.BIN
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
	MOV	DX,0200H
	MOV	CL,02H
	MOV	SI,MESSAGE4
	CALL	DISPLAYSTR

	JMP	JUMPTOPROTECTEDMODE

RootSectionStart	DW	47
RootSectionCnt		DW	7
				;			0H~7C00H	作系统堆栈
RootDirSeg	EQU	07F0H	;加载根目录段地址	7CF0H~8D00H	7扇区
RootDirOffset	EQU	0	;加载根目录偏移

PhyAddrSeg	DW	2000H	;加载KERNAL内存段地址
PhyAddrOffset	DW	0	;加载KERNAL内存偏移

FATItemSeg	EQU	08D0H	;加载FAT表段地址	8D00H~BB00h	23扇区
FATItemOffset	EQU	0	;加载FAT表偏移
				;		
;MemoryInfoSeg	EQU	0BB0H	;内存信息段地址		BB04H~C0000H	
;MemoryInfoOffset	EQU	4	;内存信息偏移	
				
;MemoryBlockCount	EQU	0C000H		;C000H~C003H	内存块数，4字节表示
;
;CursorPos	EQU	0C000h	;存储光标位置，4字节	C000H～C003H
				;C000H～C200H 	存储各种小变量
;		;C200H~10000H	空闲
;Page
NH		EQU	2	;磁头数
NS		EQU	36	;每道扇区数
DATABEGIN	EQU	52	;加上簇数便是数据扇区

TopOfStack	EQU	7C00H

INFOLOADER	DB	'KERNAL  BIN'

MESSAGE3	DB	'NO KERNAL!',0
MESSAGE4	DB	'LOAD KERNAL SUCCESSFULLY',0

;调用

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

;此处跳入保护模式，不开启分页
JUMPTOPROTECTEDMODE:
	LGDT	[GDTREG]
	CLI
	IN	AL,92H
	OR	AL,00000010B
	OUT	92H,AL
	MOV	EAX,CR0
	OR	EAX,1
	MOV	CR0,EAX
	JMP	DWORD	SELECTOR_CODE32:(PROTECTED_BEGIN+LOADERADDR)



[SECTION .gdt]
;GDT
;				段基址		段界限	段属性
GDT:		Descriptor	0,		0,	0
GDT_DATA:	Descriptor	0,		0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW
GDT_STACK:	Descriptor	0,		0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW
GDT_CODE32:	Descriptor	0,		0FFFFFH,DA_CCOR|DA_DPL0|DA_32|DA_LIMIT_4K
GDT_VEDIO:	Descriptor	0B8000H,	0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW

GDTLEN	EQU	$-GDT
GDTREG	DW	GDTLEN-1	;加载GDTR时的变量地址;段界限
	DD	LOADERADDR+GDT		;段基址

;选择子
SELECTOR_DATA	EQU	GDT_DATA-GDT
SELECTOR_STACK	EQU	GDT_STACK-GDT
SELECTOR_CODE32	EQU	GDT_CODE32-GDT
SELECTOR_VEDIO	EQU	GDT_VEDIO-GDT

[SECTION .DATA]
ALIGN	32
_MESSAGE_PROTECTEDDMODE	DB	'WELCOME TO PROTECTED MODE!!!',0



;保护模式中使用一下标志
MESSAGE_PROTECTEDDMODE	EQU	_MESSAGE_PROTECTEDDMODE+LOADERADDR

[SECTION STACK]
STACKSPACE:
TIMES	1024	DB	0	;栈空间初定为1K
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
	MOV	ESI,MESSAGE_PROTECTEDDMODE
	CALL	DISPLAYSTR32

	JMP	SELECTOR_CODE32:20000H

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
