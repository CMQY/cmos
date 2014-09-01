#include "inc/type.h"
#define TSSADDR 0x1CA00
typedef struct
{
		b32 esp0;		//0x0
		b32 ss0;		//0x4
		b32 cr3;		//0x8
		b32 eip;		//0xc
		b32 eflags;		//0x10
		b32 eax;		//0x14
		b32 ecx;		//0x18
		b32 edx;		//0x1c
		b32 ebx;		//0x20
		b32 esp;		//0x24
		b32 ebp;		//0x28
		b32 esi;		//0x2c
		b32 edi;		//0x30
		b32 es;			//0x34
		b32 cs;			//0x38
		b32 ss;			//0x3c
		b32 ds;			//0x40
		b32 fs;			//0x44
		b32 gs;			//0x48
		b32 status;		//0x4c
		b32 pid;		//0x50  
} PCB;

typedef struct _tss
{
	b32	link;
	b32 esp0;
	b32 ss0;
	b32 esp1;
	b32 ss1;
	b32 esp2;
	b32 ss2;
	b32 cr3;
	b32 eip;
	b32 eflags;
	b32 eax;
	b32 ecx;
	b32 edx;
	b32 ebx;
	b32 esp;
	b32 ebp;
	b32 esi;
	b32 edi;
	b32 es;
	b32 cs;
	b32 ss;
	b32 ds;
	b32 fs;
	b32 gs;
	b32 ldt;
	b32 io_map;      //高16位为i/o位图相对于TSS段起始的16位偏移。第0位为调试陷阱位。如果置位，则在任务切换后新任务第一条指令执行前产生调试陷阱


}tss;

void loaddescriptor();
void set_tss()
{
	tss *tssaddr=(tss *)TSSADDR;
	tssaddr->esp0=0xBB00;
	tssaddr->ss0=selector_stack;
	tssaddr->esp2=0x10FFFE0;
	tssaddr->ss2=selector_stack;
	tssaddr->esp1=0;
	tssaddr->ss1=0;
	tssaddr->cr3=0x100000;
	tssaddr->ldt=0;
	b32 io_map=TSSADDR+0x64;
	tssaddr->io_map=(io_map <<16)|1;
	b32 *set_0=(b32 *)(io_map+4);
	b32 i=0;
	while(i<2048)
	{
		*(set_0+i)=0xFFFFFFFF;
		i++;
	}
	loaddescriptor(5,TSSADDR,0x0000|DA_LIMIT_4K|DA_386TSS,0x2044);
	asm volatile(
		"mov	$0x28,%%ax \n\t"
		"ltr	%%ax \n\t"
		:::"%ax");
}

//为任务调度提供TSS操作函数

void loadtss(tss *tssaddr,PCB *pcb)
{
	tssaddr->esp0=pcb->esp0;
	tssaddr->ss0=pcb->ss0;
	tssaddr->cr3=pcb->cr3;
	tssaddr->eip=pcb->eip;
	tssaddr->eflags=pcb->eflags;
	tssaddr->eax=pcb->eax;
	tssaddr->ecx=pcb->ecx;
	tssaddr->edx=pcb->edx;
	tssaddr->ebx=pcb->ebx;
	tssaddr->esp=pcb->esp;
	tssaddr->ebp=pcb->ebp;
	tssaddr->esi=pcb->esi;
	tssaddr->edi=pcb->edi;
	tssaddr->es=pcb->es;
	tssaddr->cs=pcb->cs;
	tssaddr->ss=pcb->ss;
	tssaddr->ds=pcb->ds;
	tssaddr->fs=pcb->fs;
	tssaddr->gs=pcb->gs;
}


