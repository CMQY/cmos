/**************************************************************************
 * FILENAME : proc.c
 * FUNCTION : 处理进程调度
 *************************************************************************/
//初始化进程调度程序
//进程控制块基地址 PCBAddr   大小4K--->需要控制块管理程序
//进程页表基地址   PAGEAddr  大小1M,足以支持1K个进程
//就绪程序队列地址   READYAddr 大小4K--->需要队列管理程序
//需要存储队头和队尾
//阻塞程序队列地址   WAITAddr  大小4K
//创建第一个进程

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

//函数声明
void initlinkstack(b32,b32); //in proc_link_stack.c
b32 getpageaddr(b32,b32,b32,b32);
b32 procpop(b32 *);
b32 procpush(b32 *);

b32 quenein(b32,b32,b32,b32,b32); //in quene.h
b32 queneout(b32,b32,b32,b32,b32);

void hdraed(b32,b32,b32);  //in lib/hd_drive.asm
void hdwrite(b32,b32,b32);

void readfile(b8 *,b32);  //in fat16_driver.asm
void loaddescriptor(int,b32,b16,b16);
void memset(b32,b32);
b32 initpage(b32);

//进程控制块内容
//CPU环境上下文-->保存在堆栈，包括各寄存器
//堆栈地址
//运行状态
//cr3
//已使用的内存空间-->由缺页中断和虚拟内存管理程序维护
typedef struct
{
		b32 esp0;
		b32 ss0;
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
		b32 status;
		b32 pid;    //页表结构，使用4M页
} PCB;

void initproc()
{
	initlinkstack(PCBAddr,0x54);
	initquenes();
	addgdt();//添加用户GDT，所有用户进程使用同一类GDT选择子
	*(b32 *)PID=0; //初始化PID池

	//添加第一进程
	b32 pcb_;
	b32 page;
	procpop(&pcb_);
	*(b32 *)CURPCB=pcb_;   //初始化当前PCB
/*	asm volatile(
			"jmp . \n\t"
			:::
			);   */
	getpageaddr(PCBAddr,pcb_,16,&page);
	initpage(page);     //初始化分页，平坦映射内核空间
	PCB * pcb=(PCB *)pcb_;
	pcb->esp=0x13FFFF0;
	pcb->status=RUN;
	pcb->cr3=page;
	pcb->pid=(*(b32 *)PID)+4;
	*(b32 *)PID=*(b32 *)PID+4;
	b32 phymem;
	b8 filename[11]="PROGRAM BIN";
	mempop(&phymem);

	readfile(&filename,phymem);
	linkpage(pcb->cr3,0x1000000,phymem);// 处理页表
	asm volatile(
			"jmp . \n\t"
			"movl %%cr4,%%eax \n\t"
			"or $0x10,%%eax \n\t"
			"movl %%eax,%%cr4 \n\t"      //修改cr4.pse
			"movl %0,%%cr3\n\t"
			"push $0x3b \n\t"
			"push $0x13FFFFE \n\t"
			"push $0x43 \n\t"//处理堆栈 user_code

			"push $0x1000000 \n\t"
			"retf \n\t"
			::"r"(page):"%eax"
			);

}


//void linkpage(b32 cr3_,b32 visualaddr,b32 phyaddr)
//链接物理页和虚拟页，并添加属性（硬编码），
void linkpage(b32 cr3_,b32 visualaddr,b32 phyaddr)
{
	visualaddr=visualaddr/0x400000;
	b32 * cr3;
	cr3=(b32 *)(cr3_ + visualaddr*4);
	*cr3=phyaddr | 0x87;
}

void addgdt()
{
	loaddescriptor(6,0,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_DRW ,0xFFFF);
	//user_data
	loaddescriptor(7,0,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_DRW ,0xFFFF);
	//user_stack
	loaddescriptor(8,0,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_CCOR,0xFFFF);
	//user_code
	loaddescriptor(9,0xB8000,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_DRW,0xFFFF);
	//user_vedio
}

//分页初始化函数
//初始化分页，4M页
//映射内核空间低16M
b32 initpage(b32 pageaddr_)
{
	memset(pageaddr_,0x1000);
	b32 * pageaddr=(b32 *) pageaddr_;
	b32 size=0;
	for(;size<0x1000000;size+=0x400000){
		*pageaddr=size | 0x83;
		pageaddr+=0x1;   //编译器*4
	}		
}

//阻塞和就绪队列初始化程序
//初始化存储对头和队尾
void initquenes()
{
	b32 * waithead = (b32*) WAIThead;
	b32 * waittail = (b32*) WAITtail;
	b32 * readyhead = (b32*) READYhead;
	b32 * readytail = (b32*) READYtail;

	*waithead=WAITAddr;
	*waittail=WAITAddr+4;
	*readyhead=READYAddr;
	*readytail=READYAddr+4;
}
//程序装载函数
//装载函数并跳入执行
//需内存管理和文件系统支持
b32 loadfile()
{}




//分派程序
//由时钟中断直接调用和系统调用内部调用
//填充保存进程控制块内容
//从将当前程序挂入就绪链表或挂起链表
//从就绪链表中取出程序，无则循环检测
/*
void dispatcher()
{
	asm volatile(
			"cli \n\t"
			"push eax \n\t"
			"push ebx \n\t"
			"push ecx \n\t"
			"push edx \n\t"
			"push ebp \n\t"
			"push esi \n\t"
			"push edi \n\t"
			"push ds \n\t"
			"push es \n\t"
			"push fs \n\t"
			"push gs \n\t"
			"pushf \n\t"
			:::
			);
	
	asm volatile(							//保存PCB
			"movl CURPCB,%%eax \n\t"
			"movl %%esp,(%%eax) \n\t"		//pcb->esp
//			"movl $1,4(%%eax) \n\t"	//pcb->status  READY = 1
			"movl %%cr3,8(%%eax) \n\t"		//pcb->cr3
			:::"%eax"
			);
	
	//pcb加入就绪队列
	b32 * pcbaddr=(b32 *)CURPCB;
	((PCB *)* pcbaddr)->status=READY;
	quenein(READYAddr,READYBottom,READYhead,READYtail,*pcbaddr);
	
	//获取下一就绪进程
	
	PCB * nextpcb;
	queneout(READYAddr,READYBottom,READYhead,READYtail,&nextpcb);

	//修改当前CURPCB,修改pcb->status，切换分页，切换堆栈
	nextpcb->status=RUN;
	*pcbaddr=nextpcb;

	asm volatile(
			"movl %0,%%eax \n\t"
			"movl (%%eax),%%esp \n\t"
			"movl 8(%%eax),%%cr3 \n\t"
			::"r"((b32)nextpcb):"%eax","%esp"
			);

	asm volatile(
			"popf \n\t"
			"pop gs \n\t"
			"pop fs \n\t"
			"pop es \n\t"
			"pop ds \n\t"
			"pop edi \n\t"
			"pop esi \n\t"
			"pop ebp \n\t"
			"pop edx \n\t"
			"pop ecx \n\t"
			"pop ebx \n\t"
			"pop eax \n\t"
			"sti \n\t"
			"iret \n\t"
			:::
			);
}
*/



//创建进程的系统调用
//分配空间
//装载程序，此过程填充页表
//加入就绪队列
//
//define READY 1
//define BUSY 2
//define RUN 0
void exce()
{
	b32 pcb_;		//存放PCB地址
	b32 page;		//存放PAGE地址
	procpop(&pcb_);	//获取PCB地址
	getpageaddr(PCBAddr,pcb_,16,&page);	//获取PAGE地址
	PCB * pcb=(PCB *)pcb_;
	pcb->esp=0x3FFFF0;
	pcb->status=READY;
	pcb->cr3=page;
	pcb->pid=*(b32 *)PID+4;			//填充PCB
	*(b32 *)PID+=4;

	//填充用户堆栈
//	loadfile();				//装载程序
//	changerinand exe		//加入就绪队列

}

//退出进程的系统调用
//从队列移出
//回收空间，使用遍历页表的形式
void exit();

