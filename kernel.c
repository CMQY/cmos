/*********************************************************************************************
进入内核后，0xC200～0x100000将成为空闲空间。用作新的GDT和IDT表和安装中断
0xC200 ~ 0x1C1FF 作为GDT表 大小 10000H
0x1C200 ~ 0x1C9FF 作为IDT表，大小 800H
0x1CA00 ~ 0x1EE00 作为TSS位置  大小9K
0x100000～0x500000为分页空间

0～0xBB00将作为系统栈空间 共46K

0xBB00～0xC200存储各种变量
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
void set_tss();
void setgdt();
void memmgr();
void hd_write();
void initkeyquene();
void initproc();
typedef struct _gdtr{
	b16 gdtlimit;
	b32 gdtrbase;
}gdtr;

void _start()
{
	print("c farmart kernal is executing.\n^_^");
	print("hahahahahhahaaha\n");
	//重置GDT  预留4K bits 空间
	setgdt();

	gdtr gdtrtemp = { 0xffff, GDTADDR };
	gdtr * pgdtr = &gdtrtemp;
	asm volatile(
		"lgdt (%%ebx) \n\t"
		"movw $0xBB00,%%eax \n\t"
		"movw $0x10,%%cx \n\t"
		"movw %%cx,%%ss \n\t"
		"movw %%eax,%%esp \n\t"		//修改系统栈，只能在此处内联汇编
		"ljmp $0x18,$1f\n\t"             //选择子属性，顺序未变
		"1:"
		::"b"(pgdtr) : "%eax", "%cx"
		);
	print("GDTR change.\n");

/**/	set_tss(); 
	print("tss load successfully.\n");


	initkeyquene();//初始化键盘缓冲区
	initidt();      //设置IDT并加载中断
	print("IDTR load successfully.\n");

	memmgr();
	print("memory have been control\n");

	asm volatile(
		"int $80\n\t"
		:::
		);
	initproc();
	exit();
}
