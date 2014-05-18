/*********************************************************************************************
进入内核后，0xC200H～0x100000H将成为空闲空间。用作新的GDT和IDT表和安装中断
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
		"movw $0x7c00,%%ax \n\t"
		"movw %%ax,%%sp \n\t"
		"movw $0x08,%%ax\n\t"
		"movw %%ax,%%ds \n\t"
		"movw $0x10,%%ax\n\t"
		"movw %%ax,%%ss \n\t"
		"movw $0x20,%%ax\n\t"
		"movw %%ax,%%fs \n\t"
		"ljmp $0x18,$1f\n\t"
		"1:"
		"movw $12,%%ax"
		::"b"(pgdtr):"%ax"
		);
	print("GDTR change.\n");
	exit();
}
