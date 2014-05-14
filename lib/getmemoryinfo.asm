;nasm	-o getmemoryinfo.o getmemoryinfo.asm
;函数调用惯例
;惯例指明寄存器EAX、EDX和ECX的内容必须有调用者自己负责保存，#被调用函数可以随意破坏
;EBX、ESI、EDI、ESP、EBP必须由被调用者保存
;获取内存信息
;结构体存放地址：MemoryInfoSeg:MemoryInfoOffset
;在头文件中定义
;
;内存段数存放地址：
;MemoryBlockCount
;头文件中定义
;
;使用外部函数 displaystr16，调用时注意链接
;
MemoryInfoSeg		EQU	0BB0H
MemoryInfoOffset	EQU	4H
MemoryBlockCount	EQU	0H


EXTERN	displaystr16
GLOBAL	getmemoryinfo
[SECTION .CODE16]
[BITS	16]
getmemoryinfo:
	MOV		DI,MemoryInfoOffset
	MOV		CX,MemoryInfoSeg
	MOV		ES,CX
	MOV	DWORD	[ES:MemoryBlockCount],0
	MOV		EAX,0E820H
	XOR		EBX,EBX

.GMI_MEM:
	MOV		ECX,20
	MOV		EDX,0534D4150H
	INT		15H

	JC		.GMI_FAIL
	CMP		EBX,0
	JE		.GMI_END

	ADD		DI,20H
	INC	DWORD	[ES:MemoryBlockCount]
	JMP		.GMI_MEM
.GMI_FAIL:
	MOV		DX,0400H
	MOV		CL,02H
	MOV		AX,CS
	MOV		DS,AX
	MOV		SI,GMI_MSG
	CALL		displaystr16
.GMI_END:
	RET

[SECTION .DATA]
GMI_MSG	DB	'Get memory information error.',0
	
