/*********************************************************************
 * FINENAME : mem_mgr.c
 * FUNCTION : 此文件负责内存信息的显示，开启分页和内存管理的实现细节以及缺页中断的实现及加载。
 * *******************************************************************/
#include "inc/type.h"
#define MemoryInfoAddr	0xBB00		//此为内存信息存放地址，16位下为MemoryInfoSeg 和MemoryInfoOffset

#define PageDirAddr $0x100000
#define PageAddr    $0x101000
#define P_P     $0x1
#define P_RW    $0x2

#define MEMORYTOPADDR 0x500000
#define MEMBOTTOMADDR 0x500004  //暂定5M内存处，此处必空闲

void displaymemoryinfo();
void printdword(b32);
void print(void *);

typedef struct
{
    b32 BaseAddrLow;
    b32 BaseAddrHigh;                                                           
    b32 LengthLow;
    b32 LengthHigh;
    b32 Type;
} meminfo;

int memsize=0;
int memavalidsize=0;
void memmgr()
{
	b32 * meminfoaddr=(b32 *)0xBB00;
	b32 count=(* meminfoaddr)>>16;         //取高16位为块数
	b32 i=0;
	meminfoaddr+=1;      //使用1而不是4是因为编译器认为这是个指针变量加了1×4
	for(i=0;i<count;i++)
	{
		displaymemoryinfo(meminfoaddr);
		if(i==count-1)
		{
			meminfo * mem=(meminfo *)meminfoaddr;
			memsize=mem->BaseAddrLow+mem->LengthLow;
		}
		meminfoaddr+=5;  //同上 5×4
	}

	print("Total memory size :");
	printdword(memsize);
	print("      ");
	print("Avalid memory size :");
	printdword(memavalidsize);
	print("\n");

/**************************************************************************
 * 以下为开启分页汇编，ring0下为直接内存全局映射
 * 4G共占用4M,映射所有内存，剩余的空闲
 *
 * 页目录表及页表属性
 * -------------------------------------------------
 * P_P    EQU 01B ;存在位P=0表示不存在于内存中
 * P_RW   EQU 010B    ;读写权限，P/W=0表示只读
 * P_US   EQU 0100B   ;U/S=0表示系统权限
 * P_PWT  EQU 01000B  ;控制缓冲策略，PWT=0时使用Write-back策略，=1使用Write-through策略
 * P_PCD  EQU 010000B ;PCD=0表示可以被缓冲
 * P_A    EQU 0100000B    ;表示是否被访问
 * P_D    EQU 01000000B   ;是否被写入
 * P_PS   EQU 010000000B  ;决定页大小
 * P_PAT  EQU 010000000B  ;
 * P_G    EQU 0100000000B ;全局页
 *
 *************************************************************************/

	asm volatile(
			"cld \n\t"
			"xor %%edx,%%edx \n\t"
			"movl %0,%%eax \n\t"          //内存大小
			"movl $0x40000,%%ebx \n\t"
			"div %%ebx \n\t"
			"incl %%eax \n\t"		//保证内存页足够映射所有物理内存
			"movl %%eax,%%ecx \n\t"
			"push %%ecx \n\t"
			"movw $0x08,%%ax \n\t"
			"movw %%ax,%%es \n\t"
			"movl $0x100000,%%edi \n\t"  //PageDirAddr=0x100000
			"movl $0x101000,%%eax \n\t"     //PageAddr=0x101000
			"or $0x3,%%eax \n\t"  //P_P|P_RW=0x3
			"L1: \n\t"
			"stosl \n\t"
			"add $0x1000,%%eax \n\t"
			"loop L1 \n\t"

			"pop %%eax \n\t"
			"movl $1024,%%ebx \n\t"
			"mul %%ebx \n\t"
			"movl %%eax,%%ecx \n\t"
			"movl $0x101000,%%edi \n\t"  //PageAddr=0x101000
			"xor %%eax,%%eax \n\t"
			"or $0x3,%%eax \n\t"  //P_P|P_RW
			"L2: \n\t"
			"stosl \n\t"
			"add $0x1000,%%eax \n\t"
			"loop L2 \n\t"

			"movl $0x100000,%%eax \n\t"  //PageDirAddr=0x100000
			"movl %%eax,%%cr3 \n\t"
			"movl %%cr0,%%eax \n\t"
			"or $0x80000000,%%eax \n\t"
			"mov %%eax,%%cr0 \n\t"
			"ljmp $0x18,$3f \n\t"
			"3: \n\t"
			::"r"(memsize):"%eax","%ecx","%edi","%ebx","%edx"
			);
	print("page on\n");
	
/*************************************************************************
 * 以下实现内存的链栈方式管理，初拟16M以上为ring3内存，共32M内存
 ***********************************************************************/
	InitQuene();

}


/***********************************************************************
 * 成链栈
 ***********************************************************************/
void InitQuene()
{
/*	asm volatile(
		   "jmp . \n\t"
		   :::
		   );  */
	b32 memblock;
	b32 * meminfoaddr=(b32 *) MemoryInfoAddr; //需要取内存信息以获取那些可用
	memblock=(* meminfoaddr) >> 16;    //获取内存块数
	b32 i=0;
	meminfo * mem=meminfoaddr+1;		//获取内存信息基址
	
	for(i=0;i<memblock;i++){
		if(mem->BaseAddrLow+mem->LengthLow>0x1000000)
			break;
		mem++;
	}

	if(i==memblock){
		print("Not enough memory\n");
		for(;;);
	}
	
	b32 flag=1;    //首次链接初始化MEMORYTOPADDR和MEMBOTTOMADDR
	for(;i<memblock;i++){
		if(mem->Type==1){
			if(flag==1){
				if(mem->BaseAddrLow<0x1000000)
				{
					*((b32 *)MEMORYTOPADDR)=0x1000000;
					*((b32 *)MEMBOTTOMADDR)=0x1000000;
				}
				else
				{
					*((b32 *)MEMORYTOPADDR)=mem->BaseAddrLow;
					*((b32 *)MEMBOTTOMADDR)=mem->BaseAddrLow;
				flag=0;
				}
			}
			LinkMemory(mem);
		}
		else
			print("Skip system memory\n");
	}
	
	print("Memory Link successfully\n");


	
}

/**************************************************************************
 * LinkMemory(meminfo *)
 * 此函数使用两个系统变量栈顶和栈底，地址暂定，使用宏定义MEMORYTOPADDR和
 * MEMBOTTOMADDR
 *************************************************************************/
void LinkMemory(meminfo * mem)
{
	b32 * membottomaddr=(b32 *)MEMBOTTOMADDR;  //获取当前栈底地址，未存放下一链接地址
	b32 * membottom=(b32 *)(* membottomaddr);

	if(mem->BaseAddrLow<0x1000000)
		* membottom=0x1000000;
	else
		* membottom=mem->BaseAddrLow;  //衔接

	for(;(b32) membottom<(mem->BaseAddrLow+mem->LengthLow);){
		* membottom = (b32) membottom+0x1000;  //编译器处理时会进行乘4操作
		membottom +=0x400;
	}
	* membottomaddr=(b32) membottom;     //填充回新的栈底地址
	print("link memblock sucessfully");
}

/**************************************************************************
 * b32 mempop(b32 *) 参数为存放地址的32bits变量
 * b32 mempush(b32 *)
 * 内存页出入栈操作，MEMORYTOP被用作栈顶指针，因为不存在栈满这一说法，另需
 * MENUSEDCOUNT记录已使用的内存块
 *************************************************************************/

b32 mempop(b32 * memblock)
{
	b32 * memtop=(b32*) MEMORYTOPADDR;
	b32 * membottom=(b32 *)MEMBOTTOMADDR;

	if(*memtop==*membottom){
		print("Not enough memory");
		return 0;
	}
	else{
		*memblock=*memtop;
		*memtop=*(b32 *)(*memtop);
		return 1;
	}
}

b32 mempush(b32 * memblock)
{
	b32 *memtop=(b32*) MEMORYTOPADDR;
	b32 * membottom=(b32*)MEMBOTTOMADDR;
	**memblock=*memtop;
	*memtop=*memblock;
	return 1;
}

/**************************************************************************
 * 缺页中断处理函数和装载缺页中断
 *************************************************************************/

void displaymemoryinfo(meminfo * mem)
{
	print("BaseAddrLow   BaseAddrHigh   LengthLow     LengthHigh    Type\n");
	printdword(mem->BaseAddrLow);
	print("     ");
	printdword(mem->BaseAddrHigh);
	print("      ");
	printdword(mem->LengthLow);
	print("     ");
	printdword(mem->LengthHigh);
	print("     ");
	printdword(mem->Type);
	print("\n");
	if(mem->Type==1)
	{
		memavalidsize+=mem->LengthLow;
	}
}

