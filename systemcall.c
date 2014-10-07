/**************************************************************************
 * 提供系统调用的c语言形式
 *************************************************************************/
#include "inc/type.h"
#define PCBAddr 0x500100  //界限：0x501100
#define PAGEAddr 0x600000 //界限：0x700000
#define READYAddr 0x501100 //界限：0x502100
#define WAITAddr 0x502100 //界限：0x503100

#define READYBottom 0x502100
#define WAITBottom 0x503100
#define WAIThead 0x503210
#define WAITtail 0x503214
#define READYhead 0x503220
#define READYtail 0x503224

//进程状态
#define READY 1
#define BUSY 2
#define RUN 0

//PID地址
#define PID 0x503228

//存放当前运行的程序的pcb地址
#define CURPCB 0x503230

//用户态选择子
#define user_data 0x30
#define user_code 0x40
#define user_stack 0x38
#define systemcall  0x50
#define selector_systemcall 0x58
//函数声明
void initlinkstack(b32,b32); //in proc_link_stack.c
b32 getpageaddr(b32,b32,b32,b32);
b32 procpop(b32 *);
b32 procpush(b32 *);

b32 quenein(b32,b32,b32,b32,b32); //in quene.h
b32 queneout(b32,b32,b32,b32,b32);

void hdraed(b32,b32,b32);  //in lib/hd_drive.asm
void hdwrite(b32,b32,b32);

void readfile(b32 *,b32);  //in fat16_driver.asm
void loaddescriptor(int,b32,b16,b16);
void memset(b32,b32);
b32 initpage(b32);
void printdword(b32);

void gateload(int index, b32 addr, b16 attribute);
void int_80_systemcall();
//进程控制块内容
//CPU环境上下文-->保存在堆栈，包括各寄存器
//堆栈地址
//运行状态
//cr3
//已使用的内存空间-->由缺页中断和虚拟内存管理程序维护
typedef struct
{
		b32 cr3;		//0x0
		b32 eip;		//0x4
		b32 eflags;		//0x8
		b32 eax;		//0xc
		b32 ecx;		//0x10
		b32 edx;		//0x14
		b32 ebx;		//0x18
		b32 esp;		//0x1c
		b32 ebp;		//0x20
		b32 esi;		//0x24
		b32 edi;		//0x28
		b32 status;		//0x2c
		b32 pid;		//0x30
		b32 cs;			//0x34
		b32 ss;			//0x38
		b8 name[8];		//0x3c
		b32 mailblock;		//0x44
		b32 fileblock;		//0x48
} PCB;
void exec(b32 *filename)
{
	b32 pcb_;
	b32 page;
	asm volatile(
			"jmp . \n\t"
			:::
			);
	procpop(&pcb_);
	getpageaddr(PCBAddr,pcb_,0x4c,&page);	//需要pcb块大小
	initpage(page);
	PCB * pcb=(PCB *)pcb_;
	printdword((b32)(pcb));
	pcb->esp=0x13FFFF0;
	pcb->status=READY;
	pcb->cr3=page;
	pcb->pid=(*(b32 *)PID)+4;
	pcb->edi=0;
	pcb->esi=0;
	pcb->ebx=0;
	pcb->edx=0;
	pcb->eflags=0;
	pcb->ss=user_stack;
	pcb->cs=user_code;
	pcb->eip=0;

	*(b32 *)PID=*(b32 *)PID+4;
	b32 phymem;
	filename[11]=0;				//得到格式化后的文件名
	mempop(&phymem);

	readfile(filename,phymem);
	linkpage(pcb->cr3,0x1000000,phymem);
	quenein(READYAddr,READYBottom,READYhead,READYtail,pcb_);
}
