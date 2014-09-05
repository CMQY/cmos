/**************************************************************************
 * 提供系统调用的c语言形式
 *************************************************************************/
b32 getoageaddr(b32,b32,b32,b32);
b32 initpage(b32);
void readfile(b8 *,b32);
void linkpage(b32,b32,b32);
b32 mempop(b32 *);
b32 quenein(b32,b32,b32,b32,b32);

void exec(b32 *filename)
{
	b32 pcb_;
	b32 page;
	procpop(&pcb_);
	getpageaddr(PCBAddr,pcb_,0x3c,&page);	//需要pcb块大小
	initpage(page);
	PCB * pcb=(PCB *)pcb_;

	pcb->esp=0x13FFFF0;
	pcb->status=READY;
	pcb->cr3=page;
	pcb_>pid=(*(b32 *)PID)+4;
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

	readfile(&filename,phymem);
	linkpage(pcb->cr3,0x1000000,phymem);
	quenein(READYAddr,RAEDYBottom,READYhead,READYtail,pcb_);
}
