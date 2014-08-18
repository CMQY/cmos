/**************************************************************************
 * FILENAME : proc_link_stack.c
 * FUNCTION : 管理进程控制块和分页表
 *************************************************************************/
//需要空间来存储 栈头和栈尾
//PROCSTACKTOP
//PROCSTACKBOTTOM
//
#define PROCSTACKTOP 0x503200
#define PROCSTACKBOTTOM 0x503204
void initlinkstack(b32 base_,b32 block)
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

void procpop(b32 * addr)
{
	
}

void procpush(b32 *block)
{}
