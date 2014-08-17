/**************************************************************************
 * FILENAME : proc_link_stack.c
 * FUNCTION : 管理进程控制块和分页表
 *************************************************************************/

void initlinkstack(b32 base_,b32 block)
{
	b32 count=0x1000/block;
	b32 i=0;
	b32 *base=(b32*)base_;
	for(i=0;i<count;i++)
	{
		*base=base+block;
		base+=block;
	}
}
