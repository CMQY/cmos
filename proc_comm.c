/************************************************************************
 * FILENAME : proc_comm.c
 * FUNCTION : 进程通讯
 * 实现进程间通讯
 * 使用内存空间，0x701000起 总大小0x10004字节
 * 使用邮槽实现
 * 邮槽块用链栈链接
 ************************************************************************/
#include "inc/type.h"
#define	STAMPTOP	0x701000
#define STAMPTOTALSIZE	0x10000
#define	STAMPSIZE	0x40
#define	STAMPEND	0x711004-64
#define CURPCB 0x503230

#define MAIL_NULL 1

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


typedef struct _data{
	b32 data[14];
}DATA;

//邮件结构，64字节
typedef struct _mail{
	b32 srcproc;
	b32 flags;
	DATA data;
}MAIL;


//定义在proc.c line 226
b32 user2phy(b32 useraddr);

b32 popstampblock(b32 * des);	//弹出邮箱，参数为接收邮箱地址的地址，进程初始化时调用，注意用户地址到内核地址的转换。

b32 pushstampblock(b32 * addr);	//压进邮箱，参数为邮箱地址，成功返回1,失败返回0，进程结束事调用

/*注释，需要为进程控制块pcb添加进程名*/

b32 sendmail(PCB* des,DATA *data); //des为目的进程，mailaddr为邮箱结构地址，注意用户地址到内核地址的转换

b32 recvmail(MAIL * mailaddr); //mailaddr为接收邮件的地址，注意用户地址到内核地址的转换，注意需要获取调用此函数进程的pcb的可靠方式
//proc.c line 34,#define CURPCB 0x503230


b32 initstampblock()
{
	b32 *stamptop=(b32 *)STAMPTOP;	//初始化栈顶
	*stamptop=STAMPTOP+4;

	b32* temp=(b32 *)(STAMPTOP+4);
	int i=0;
	for(;i<STAMPTOTALSIZE;i+=STAMPSIZE)
	{
		*temp==(b32)temp+STAMPSIZE;
		temp+=STAMPSIZE/4;	
	}
	return 0;
}

b32	popstampblock(b32 *des)	//此函数只允许在内核态调用
{
	b32	* stamptop=(b32 *)STAMPTOP;
	if(*stamptop==STAMPEND)
	{
		print("Not enough stampblock \n");
		return 0;
	}
	else{
		*des=*stamptop;
		*stamptop=*(b32 *)(*stamptop);
		return 1;
	}
}

b32 pushstampblock(b32 *addr)	//此函数只允许在内核态调用
{								//传入stampblock地址
	b32 *stamptop=(b32 *) STAMPTOP;
	*addr=*stamptop;
	*stamptop=addr;
	return 1;
}

//此函数只能在用户态调用，进入内核态后进行地址转换
b32 sendmail(PCB * pcb,DATA *data)
{
	MAIL *srcmail=user2phy(data);
	MAIL *desmailaddr=(MAIL*)(pcb->mailblock);
	if((desmailaddr->flags)&MAIL_NULL)
	{
		desmailaddr->srcproc=*(b32 *)CURPCB;
		memcpy(&(desmailaddr->data),srcmail,sizeof(DATA));
		(desmailaddr->flags)|=MAIL_NULL;
		return 1;
	}
	else
		return 0;
}

//此函数只能在用户态调用，内部进行地址转换
b32 recvmail(MAIL *mailaddr)
{
	MAIL *desmailaddr=user2phy(mailaddr);
	PCB *pcb=(PCB *)*(b32 *)CURPCB;
	MAIL *srcmailaddr=(MAIL *)(pcb->mailblock);
	if((srcmailaddr->flags)&MAIL_NULL)
		return 0;
	memcpy(desmailaddr,srcmailaddr,sizeof(MAIL));
	return 1;
}

