/*********************************************************************************************
进入内核后，0xC200H～0x100000H将成为空闲空间。用作新的GDT和IDT表和安装中断
0xC200H ~ 0x1C1FFH 作为GDT表 大小 10000H
0x1C200H ~ 0x1C9FF 作为IDT表，大小 800H
0x100000H～0x500000H为分页空间

0～0xBB00H将作为系统栈空间 共46K

0xBB00H～0xC200H存储各种变量
其中

CursorPos	EQU	0C000h	;存储光标位置，4字节	C000H～C003H
MemoryInfoAddr	EQU	0BB00H	;0BB00H～0BB03H 存储内存大小，单位为MB
PageDirAddr	EQU	100000H	;页目录表
PageAddr	EQU	101000H	;第一张页表


**********************************************************************************************/
#include"inc/type.h"
#define GDTADDR 0xc200
void print(char *c);
void exit();
void initidt();

typedef struct _gdt{
	b16 limitl;
	b16 basel16;
	b8 basem8;
	b16 attribute;             //含段界限高4位  bit8 - bit12 
	b8 baseh8;
}gdt;
typedef struct _gdtr{
	b16 gdtlimit;
	b32 gdtrbase;
}gdtr;



void _start()
{
	print("c farmart kernal is executing.\n^_^");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");
	print("hahahahahhahaaha\n");

	//重置GDT  预留4K bits 空间
	gdt * gdttemp = GDTADDR;

	gdt descriptor = { 0, 0, 0, 0, 0 };
	*gdttemp = descriptor;
	gdt descriptor2 = { 0xffff, 0, 0, 0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL0 | DA_DRW, 0 };
	*(gdttemp + 1) = descriptor2;//selector_data
	gdt descriptor3 = { 0xffff, 0, 0, 0x0F00 | DA_CCOR | DA_DPL0 | DA_32 | DA_LIMIT_4K, 0 }; 
	*(gdttemp + 2) = descriptor2;	//selector_stack	
	*(gdttemp + 3) = descriptor3;		 //selector_code
	gdt descriptor4 = { 0xffff, 0x8000, 0xB, 0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL0 | DA_DRW, 0 };
	*(gdttemp + 4) = descriptor4;		//selector_vedio

	gdtr gdtrtemp = { 0xffff, GDTADDR };
	gdtr * pgdtr = &gdtrtemp;
	asm volatile(
		"lgdt (%%ebx) \n\t"
		"movw $0x7c00,%%cx \n\t"
		"movw $0x10,%%ax\n\t"
		"movw %%ax,%%ss \n\t"
		"movw %%cx,%%sp \n\t"
		"movw $0x08,%%ax\n\t"
		"movw %%ax,%%ds \n\t"
		"movw $0x20,%%ax\n\t"
		"movw %%ax,%%fs \n\t"
		"ljmp $0x18,$1f\n\t"
		"1:"
		"movw $12,%%ax"
		::"b"(pgdtr) : "%ax", "%cx"
		);
	print("GDTR change.\n");

	initidt();      //设置IDT并加载中断
	print("IDTR load successfully.");
/******************************************************************
设置8259A

1,往端口20H（主片）或A0H（从片）写入ICW1
2,往端口21H（主片）或A1H（从片）写入ICW2
3,往端口21H（主片）或A1H（从片）写入ICW3
4,往端口21H（主片）或A1H（从片）写入ICW4
5,往端口21H（主片）或A1H（从片）写入OCW1
注意次序不能颠倒


****************************************************************/

	asm volatile(	
	"movb	$0x11,%%al \n\t"
	"outb	%%al,$0x20 \n\t"		
	"nop	\n\t"
	"nop	\n\t"
	"outb	%%al,$0xa0 \n\t"		
	"nop	\n\t"
	"nop	\n\t"
	"movb	$0x20,%%al \n\t"		
	"outb	%%al,$0x21 \n\t"		
	"nop	\n\t"
	"nop	\n\t"
	"movb	$0x28,%%al \n\t"		
	"outb	%%al,$0xa1 \n\t"		
	"nop	\n\t"
	"nop	\n\t"

	"movb	$0x04,%%al \n\t"		
	"outb	%%al,$0x21 \n\t"		
	"nop	\n\t"
	"nop	\n\t"

	"movb	$0x02,%%al \n\t"		
	"outb	%%al,$0xa1 \n\t"		
	"nop	\n\t"
	"nop	\n\t"

	"movb	$0x01,%%al \n\t"		
	"outb	%%al,$0x21 \n\t"
	"nop	\n\t"
	"nop	\n\t"

	"outb	%%al,$0xa1 \n\t"		
	"nop	\n\t"
	"nop	\n\t"

	"movb	$0xff,%%al \n\t"		
	"outb	%%al,$0x21 \n\t"
	"nop	\n\t"
	"nop	\n\t"

	"movb	$0xff,%%al \n\t"		
	"outb	%%al,$0xa1 \n\t"
	"nop	\n\t"
	"nop	\n\t"

	:::"%ax"	
);

	exit();
}