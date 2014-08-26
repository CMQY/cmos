/**************************************************************************
 * FILENAME : proc_link_stack.c
 * FUNCTION : 管理进程控制块和分页表
 *************************************************************************/
//需要空间来存储 栈头和栈尾
//PROCSTACKTOP
//PROCSTACKBOTTOM
//
#include "inc/type.h"
#define PROCSTACKTOP 0x503200
#define PROCSTACKBOTTOM 0x503204
#define PROCBLOCKCONUT 0x503208  //存放已使用控制块数量
#define PAGEAddr 0x600000
void initlinkstack(b32 base_,b32 block) //第一参数为控制块基址，第二为单个控制块大小，单位为字节
{
	b32 *stacktop=(b32 *)PROCSTACKTOP;
	b32 *stackbottom=(b32 *)PROCSTACKBOTTOM;
	*stacktop=base_;
	b32 count=(b32)(0x1000/block-1);
	b32 i=0;
	b32 *base=(b32*)base_;
	for(i=0;i<count;i++)
	{
		*base=base+block;
		base+=block;
	}
	*stackbottom=base-block;

}

//获取页表的基址，第一参数为pcb基址，第二为pcb地址，第三为pcb大小，单位为
//字节,第四参数为接受page地址的地址
b32 getpageaddr(b32 pcbbaseaddr,b32 pcbaddr,b32 pcbsize,b32 *pageaddr)
{
	b32 num=(pcbaddr-pcbbaseaddr)/pcbsize;
	*pageaddr=num*0x1000+PAGEAddr;
	return 1;
}

b32 procpop(b32 * addr)      //返回0表示失败，返回1表示成功,参数为接受进程块地址的地址
{
	b32 * stacktop=(b32 *)PROCSTACKTOP;
	b32 * stackbottom=(b32 *)PROCSTACKBOTTOM;
	if(*stacktop==*stackbottom){
		return 0;
	}
	else{
		*addr=*stacktop;
		*stacktop=*(b32 *)(*stacktop);
		return 1;
	}
}


b32 procpush(b32 *addr)    //参数为传入进程块地址的地址
{
	b32 * stacktop=(b32 *)PROCSTACKTOP;
	b32 * stackbottom=(b32 *)PROCSTACKBOTTOM;
	*(b32 *)(*addr)=*stackbottom;
	*stacktop=*addr;
	return 1;
}
