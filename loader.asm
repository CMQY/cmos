%include	"inc/loader.inc"
	ORG	0H
	JMP	RAELMODEBEGIN
;由JMP跳入，16位段，设置好GDT及IDT后跳入保护模式
[SECTION .CODE16]
[BITS 16]
RAELMODEBEGIN:
	MOV AX,0BE0H          ;初始化光标位置
	MOV DS,AX
	MOV word [2],2*160

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
	PUSH MESSAGE3
	CALL print16 
	ADD SP,2
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
	PUSH MESSAGE4
	CALL	print16	
	ADD	SP,2
	CALL	getmemoryinfo

	JMP	JUMPTOPROTECTEDMODE

RootSectionStart	DW	47
RootSectionCnt		DW	7
				;			0H~7C00H	作系统堆栈
RootDirSeg	EQU	07F0H	;加载根目录段地址	7CF0H~8D00H	7扇区
RootDirOffset	EQU	0	;加载根目录偏移

PhyAddrSeg	DW	2000H	;加载KERNAL内存段地址		20000H
PhyAddrOffset	DW	0	;加载KERNAL内存偏移

FATItemSeg	EQU	08D0H	;加载FAT表段地址	8D00H~BB00h	23扇区
FATItemOffset	EQU	0	;加载FAT表偏移
				;		
;MemoryInfoSeg	EQU	0BB0H	;内存信息段地址			
;MemoryInfoOffset	EQU	0	;内存信息偏移	
;由于INT 15H 0E802H 号功能不能调用，改使用0E201H号功能
;占用  0BB00H～0BB04H 存储内存大小，单位为MB              BB04H~C000H   空闲
;
CursorPos	EQU	0BE00h	;存储光标位置，4字节	BE00H～BE03H
				;C000H～C200H 	存储各种小变量
;		;C200H~10000H	空闲
;Page
NH		EQU	2	;磁头数
NS		EQU	36	;每道扇区数
DATABEGIN	EQU	52	;加上簇数便是数据扇区

TopOfStack	EQU	7C00H

INFOLOADER	DB	'KERNEL  BIN'

MESSAGE3	DB	'NO KERNAL!',0
MESSAGE4	DB	'LOAD KERNAL SUCCESSFULLY',0AH,0


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

;与2014.8.12.16.10 抛弃使用
;功能为显示一个用0结束的字符串
;参数：
;(dh)=行号
;(dl)=列号
;(cl)=颜色
;ds:si指向字符串首地址。
;
;DISPLAYSTR:	      
;	PUSH AX       
;	PUSH BX
;	PUSH DI
;	MOV BX,0B800H
;	MOV ES,BX
;	MOV AL,160D
;	MUL DH
;	MOV DI,AX
;	MOV AL,2        
;	MUL DL          
;	ADD DI,AX
;	MOV BL,CL
;.AGAIN:	
;	MOV CX,[SI]
;	MOV CH,0
;	JCXZ .NO7CRET
;	MOV [ES:DI],CL
;	MOV [ES:DI+1],BL
;	INC SI
;	ADD DI,2
;	JMP SHORT .AGAIN
;	
;.NO7CRET:        
;	POP DI
;       POP BX
;        POP AX
;	RET
;
;
;
;2014.8.11.20.14修正
;--------------------------------------------------------------------
;getmemoryinfo
;获取内存信息，便显示时调用
;获取的容量会大于实际容量1M左右
;可确保分页物理内存有效
;
;MemoryInfoSeg		EQU	0BB0H
;MemoryInfoOffset	EQU	0H
;
;getmemoryinfo:
;	MOV	AX,0E801H
;	MOV	CX,MemoryInfoSeg
;	MOV	ES,CX
;	XOR	CX,CX
;	XOR	BX,BX
;	XOR	DX,DX
;	INT	15H
;	JC	.FAIL
;
;	XOR	DX,DX
;	MOV	CX,1024
;	DIV	CX
;	CMP	AH,0H
;
;	MOV	CL,AL
;	MOV	AX,BX
;	MOV	DL,16
;	DIV	DL
;	XOR	AH,AH
;	ADD	AL,CL
;	ADC	AH,0
;	MOV	[ES:MemoryInfoOffset],AX
;	MOV	SI,GMI_MSG2
;	MOV	DX,0600H
;	MOV	CL,02H
;	CALL	DISPLAYSTR
;	JMP	.END
;.FAIL:
;	MOV	SI,GMI_MSG1
;	MOV	DX,0600H
;	MOV	CL,02H
;	CALL	DISPLAYSTR
;.END:
;	RET
;-----------------------------------------------------------------
;此处跳入保护模式
MemoryInfoSeg       EQU 0BB0H
MemoryInfoOffset    EQU 0H

message1 db 'Get memory information error!',0AH,0
message2 db 'Get memory information successfully',0AH,0


getmemoryinfo:
		push bp
		mov bp,sp
		push es
		push di
		push bx
		push cx
		push dx
		xor dx,dx

		mov ax,MemoryInfoSeg
		mov es,ax
		mov di,MemoryInfoOffset+4
		mov ebx,0
.next:
		mov eax,0E820h
		mov ecx,20
		mov edx,0534d4150h
		int 0x15
		jc .err
		inc dx
		cmp ebx,0
		jz .end5
		add di,20
		jmp .next

.err:	
		push message1
		call print16
		add sp,2

.end5:	
		mov word [es:2],dx ;存放内存块数

		push message2
		call print16
		add sp,2
		pop dx
		pop cx
		pop bx
		pop di
		pop es
		leave 
		ret

CursorPos16   EQU 0BE0h  ;4 BITS  16位下光标位置，进入32位后修正

print16:
		push bp
		mov bp,sp

		push es
		push si
		push di
		push ds
		mov ax,CursorPos16
		mov ds,ax
		mov di,[2]
		pop ds
		mov ax,0b800h
		mov es,ax
		mov si,[bp+4]
		cld
.next:
		lodsb
		cmp al,0
		jz .end
		cmp al,0ah
		jnz .con
		mov ax,di
		mov cl,160
		div cl
		inc al
		mul cl
		mov di,ax
		jmp .next


.con:
		stosb 

		mov al,02
		stosb
		
		jmp .next

.end:	
		push ds
		mov ax,CursorPos16
		mov ds,ax
		mov [2],di
		pop ds
		pop di
		pop si
		pop es
		leave
		ret

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
GDT_DATA:	Descriptor	0,		0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW	;DS
GDT_STACK:	Descriptor	0,		0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW	;SS
GDT_CODE32:	Descriptor	0,		0FFFFFH,DA_CCOR|DA_DPL0|DA_32|DA_LIMIT_4K	;CS
GDT_VEDIO:	Descriptor	0B8000H,	0FFFFFH,DA_32|DA_LIMIT_4K|DA_DPL0|DA_DRW	;FS

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
_MESSAGE_LOADFINSH	DB	'KERNAL DISPART FINISH',0
_MESSAGE_PAGE		DB	'PAGE SUCCESSFULLY',0


;保护模式中使用一下标志
MESSAGE_PROTECTEDDMODE	EQU	_MESSAGE_PROTECTEDDMODE+LOADERADDR
MESSAGE_LOADFINSH	EQU	_MESSAGE_LOADFINSH+LOADERADDR
MESSAGE_PAGE		EQU	_MESSAGE_PAGE+LOADERADDR
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

	;CALL	setuppage			;开启分页，内核分页平坦映射
	;MOV	DX,0700H
	;MOV	CL,02H
	;MOV	ESI,MESSAGE_PAGE
	;CALL	DISPLAYSTR32


	MOV	DWORD [CursorPos],7*160	;初始化指针位置
	CALL	loadkernal
	MOV	ESI,MESSAGE_LOADFINSH
	MOV	DX,0800H
	MOV	CL,02H
	CALL	DISPLAYSTR32
	JMP	SELECTOR_CODE32:40000H

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

;
;把ELF格式内核加载进内存地址
;进入保护模式后调用
;
;
;
;
KernalAddr	EQU	20000H	;加载KERNAL内存段地址

loadkernal:
	XOR	ESI,ESI
	MOV	CX,[KernalAddr+2CH]
	MOVZX	ECX,CX
	MOV	ESI,[KernalAddr+1CH]
	ADD	ESI,KernalAddr
.LKMOVE:
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
;堆栈传递参数
;DS:ESI->ES:EDI
;------------------------------------------------------
memcpyasm:		;void *memcpy(void *destin, void *source, unsigned n); 
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	EDI
	PUSH	ESI
	PUSH	ECX
	PUSH	EAX
	MOV	EDI,[EBP+8]
	MOV	ESI,[EBP+12]
	MOV	ECX,[EBP+16]
	MOV	AX,SELECTOR_DATA
	MOV	ES,AX
        CLD
.1	CMP	ECX,0
	JZ	.2
	MOVSB
	DEC	ECX
	JMP	.1
.2	MOV	EAX,[EBP+16]
	POP	EAX
	POP	ECX
	POP	ESI
	POP	EDI
	LEAVE
	RET	12

;于2014.8.13.18.52抛弃使用
;-------------------------------------------------
;开启分页
;页目录表地址为1M
;内存大小存在BB00H～0BB04H 存储内存大小，单位为MB 
;在保护模式下开启
;平坦内存空间
;
;页目录表及页表属性
;-------------------------------------------------
;P_P	EQU	01B	;存在位P=0表示不存在于内存中
;P_RW	EQU	010B	;读写权限，P/W=0表示只读
;P_US	EQU	0100B	;U/S=0表示系统权限
;P_PWT	EQU	01000B	;控制缓冲策略，PWT=0时使用Write-back策略，=1使用Write-through策略
;P_PCD	EQU	010000B	;PCD=0表示可以被缓冲
;P_A	EQU	0100000B	;表示是否被访问
;P_D	EQU	01000000B	;是否被写入
;P_PS	EQU	010000000B	;决定页大小
;P_PAT	EQU	010000000B	;
;P_G	EQU	0100000000B	;全局页

;-------------------------------------------------
;-------------------------------------------------
;MemoryInfoAddr	EQU	0BB00H  ;4 BITS
;PageDirAddr	EQU	100000H
;PageAddr	EQU	101000H
;
;setuppage:
;	XOR	EDX,EDX
;	MOV	EAX,[MemoryInfoAddr]
;	MOV	EBX,4H
;	DIV	EBX
;	MOV	ECX,EAX
;	TEST	EAX,EAX
;	JZ	.CON
;	INC	ECX			;计算需分页表数。存在ECX
;.CON:
;	PUSH	ECX
;	MOV	AX,SELECTOR_DATA
;	MOV	ES,AX
;	MOV	EDI,100000H		;目录表地址为100000H
;	MOV	EAX,101000H		;第一个页表地址
;	OR	EAX,P_P|P_RW
;.1:
;	STOSD
;	ADD	EAX,1000H
;	LOOP	.1			;填充页目录表
;
;	
;	POP	EAX
;	MOV	EBX,1024
;	MUL	EBX
;	MOV	ECX,EAX			;装载次数，因为目录表连续，所以连续装载
;	MOV	EDI,101000H
;	XOR	EAX,EAX
;	MOV	EAX,P_P|P_RW
;.2:
;	STOSD	
;	ADD	EAX,1000H
;	LOOP	.2			;页表装载完成
;
;	MOV	EAX,100000H
;	MOV	CR3,EAX
;	MOV	EAX,CR0
;	OR	EAX,80000000H
;	MOV	CR0,EAX
;
;	JMP	SHORT	.3
;
;.3:
;	RET
