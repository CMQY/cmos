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
#define PCBAddr 0x500100  //界限：0x501100
#define PAGEAddr 0x600000 //界限：0x700000
#define READYAddr 0x501100 //界限：0x502100
#define WAITAddr 0x502100 //界限：0x503100

#define WAIThead 0x503210
#define WAITtail 0x503214
#define READYhead 0x503220
#define READYtail 0x503224

//进程状态
#define RAEDY 1
#define BUSY 2
#define RUN 0

//PID地址
#define PID 0x503228

//存放当前运行的程序的pcb地址
#define CURPCB 0x503230

void initproc()
{
	initlinkstack(PCBAddr,4*4);
	initquenes();
	addgdt();//添加用户GDT，所有用户进程使用同一类GDT选择子
	*(b32 *)PID=0; //初始化PID池
	*(b32 *)CURPCB=0; //初始化当前PCB存储
}

void addgdt()
{
	loaddescriptor(6,0,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_DRW ,0xFFFF);
	//user_data
	loaddescriptor(7,0,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_DRW ,0xFFFF);
	//user_stack
	loaddescriptor(8,0,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_CCOR,0xFFFF);
	//user_code
	loaddesctiptor(9,0xB8000,0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL3 | DA_DRW,0xFFFF);
	//user_vedio
}

//分页初始化函数
//初始化分页，4M页
//把所有分页初始化为unpresent,其余装载时决定
//实际上是把内存清0
b32 initpage(b32 pageaddr);
{
	memset(pageaddr,0x1000);
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
b32 loadfile();
{}




//分派程序
//由时钟中断直接调用和系统调用内部调用
//填充保存进程控制块内容
//从将当前程序挂入就绪链表或挂起链表
//从就绪链表中取出程序，无则循环检测
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
	
	asm volatile(
			"movl CURPCB,%%eax \n\t"
			"movl %%esp,(%%eax) \n\t"
			"movl $READY,$4(%%eax) \n\t"
			"movl %%cr3,$8(%%eax) \n\t"
			:::
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

//进程控制块内容
//CPU环境上下文-->保存在堆栈，包括各寄存器
//堆栈地址
//运行状态
//CR3
//已使用的内存空间-->由缺页中断和虚拟内存管理程序维护
struct PCB
{
	b32 esp;
	b32 status;
	b32 CR3;
	b32 pid;    //页表结构，使用4M页
}



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
	pcb->CR3=page;
	pcb->pid=*(b32 *)PID+4;			//填充PCB
	*(b32 *)PID+=4;

	loadfile();				//装载程序
	changerinand exe		//加入就绪队列

}

//退出进程的系统调用
//从队列移出
//回收空间，使用遍历页表的形式
void exit();

