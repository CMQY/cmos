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
#define systemcall  0x50
#define selector_systemcall 0x58
//函数声明
void initlinkstack(b32,b32); //in proc_link_stack.c
b32 getpageaddr(b32,b32,b32,b32);
b32 procpop(b32 *);
b32 procpush(b32 *);

b32 quenein(b32,b32,b32,b32,b32); //in quene.h
b32 queneout(b32,b32,b32,b32,b32);

void hdread(b32,b32,b32);  //in lib/hd_drive.asm
void hdwrite(b32,b32,b32);

void readfile(b8 *,b32);  //in fat16_driver.asm
void loaddescriptor(int,b32,b16,b16);
void memset(b32,b32);
b32 initpage(b32);

void gateload(int index, b32 addr, b16 attribute);
void int_80_systemcall();

b32 popstampblock(b32 *des);

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

typedef struct
{
	b32 edi;
	b32 esi;
	b32 ebp;
	b32 temp;
	b32 ebx;
	b32 edx;
	b32 ecx;
	b32 eax;
	b32 eip;
	b32 cs;
	b32 eflags;
	b32 esp;
	b32 ss;
} CONTEXT;

void savecontext(CONTEXT * stack,PCB * pcb)
{
	pcb->eip=stack->eip;
	pcb->eflags=stack->eflags;
	pcb->eax=stack->eax;
	pcb->ecx=stack->ecx;
	pcb->edx=stack->edx;
	pcb->ebx=stack->ebx;
	pcb->esp=stack->esp;
	pcb->ebp=stack->ebp;
	pcb->esi=stack->esi;
	pcb->edi=stack->edi;
	pcb->cs=stack->cs;
	pcb->ss=stack->ss;
}


void initproc()
{
	initlinkstack(PCBAddr,0x4c);
	initquenes();
	addgdt();//添加用户GDT，所有用户进程使用同一类GDT选择子
	*(b32 *)PID=0; //初始化PID池

	//添加第一进程
	b32 pcb_;
	b32 page;

	b32 mailblock;			//获得进程邮箱地址
	popstampblock(&mailblock);

	procpop(&pcb_);
	*(b32 *)CURPCB=pcb_;   //初始化当前PCB

	b32 fileblock;			//获取文件块地址
	getfileblock(PCBAddr,pcb_,0x4c,&fileblock);

	getpageaddr(PCBAddr,pcb_,0x4c,&page);
	initpage(page);     //初始化分页，平坦映射内核空间
	PCB * pcb=(PCB *)pcb_;
	pcb->esp=0x13FFFF0;
	pcb->status=RUN;
	pcb->cr3=page;
	pcb->pid=(*(b32 *)PID)+4;
	pcb->mailblock=mailblock;
	pcb->fileblock=fileblock;
	*(b32 *)PID=*(b32 *)PID+4;
	b32 phymem;
	b8 filename[11]="PROGRAM BIN";
	mempop(&phymem);

	readfile(&filename,phymem);
	linkpage(pcb->cr3,0x1000000,phymem);// 处理页表
	asm volatile(
			"movl %%cr4,%%eax \n\t"
			"or $0x10,%%eax \n\t"
			"movl %%eax,%%cr4 \n\t"      //修改cr4.pse
			"movl %0,%%cr3\n\t"
			"movw $0x33,%%ax \n\t"
			"movw %%ax,%%ds \n\t"
			"movw %%ax,%%es \n\t"
			"movw %%ax,%%gs \n\t"
			"movw %%ax,%%fs \n\t"
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
	
	gateload(10,&int_80_systemcall,DA_386CGate | 4 | IA_DPL3); //386调用门 4个参数
	//systemcall
	
	loaddescriptor(11,0,0x0F00 | DA_32 |DA_LIMIT_4K |0x9A,0xFFFF);
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


b32 user2phy(b32 useraddr)
{
	b32 temp=0;
	b32 *pcurpcb=(b32 *)CURPCB;
	PCB *pcb=(PCB*)(*pcurpcb);
	b32 *cr3=(b32*)(pcb->cr3);
	temp=useraddr/0x400000;
	cr3+=temp;
	return *cr3+useraddr%0x400000;
}

//遍历就绪和阻塞队列，查找所需程序


//在quene.c中定义
b32 add4(b32 top,b32 bottom,b32 add);


b32 tracequene(b32 top_,b32 bottom_,b32 front_,b32 back_,b32 *elemt_)
{
	b32 top=(b32)top_;
	b32 bottom=(b32)bottom_;
	b32 *front=(b32 *)front_;
	b32 *back=(b32 *)back_;

	b32 *add=add4(top,bottom,*front);
	if(add==*back){
		return 0;
	}
	else
	{
		b32 *temp=(b32 *)add;
		*elemt_=*temp;
		*front=add;
		return 1;
	}
}


//用户态调用，进行地址转换
b32 findproc(b8 *name_,b32 *pcb_)
{
	b8 *name=user2phy(name_);
	b32 *pcb=user2phy(pcb_);

	b32 *waithead=(b32 *)WAIThead;
	b32 *waittail=(b32 *)WAITtail;
	b32 *readyhead=(b32 *)READYhead;
	b32 *readytail=(b32 *)READYtail;
	
	b32 waitfront=*waithead;
	b32 waitback=*waittail;
	b32 readyfront=*readyhead;
	b32 readyback=*readytail;
	
	b32 elemt=0;
	//遍历ready队列

	while(tracequene(READYAddr,READYBottom,&readyfront,&readyback,&elemt)!=0)
	{
		PCB *pcbtemp=(PCB*)elemt;
		if(strcmp(&(pcbtemp->name),name))
		{
			*pcb=pcbtemp;
			return 1;
		}
	}

	//遍历wait队列
	while(tracequene(WAITAddr,WAITBottom,&waitfront,&waitback,&elemt)!=0)
	{
		PCB *pcbtemp=(PCB *)elemt;
		if(strcmp(&(pcbtemp->name),name))
		{
			*pcb=pcbtemp;
			return 1;
		}
	}

	PCB *curpcb=(PCB *)CURPCB;
	if(strcmp(&(curpcb->name),name))
	{
		*pcb=curpcb;
		return 1;
	}
	else
		return 0;
}
