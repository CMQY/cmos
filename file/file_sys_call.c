//文件系统的调用---->守护进程使用
//获得目录列表
//判断是否存在文件
//获取文件大小
//读取文件---->通过高速缓冲区，逐扇区传递--->需要获取进程pcb->cr3->物理地址（逐页获取）
#include "../inc/type.h"
#define EOF -1

b32 printdword(b32);

#define ROOTSECTION 159
#define ROOTNUM  32

#define TEMPROOTSECTION	0x700000
#define TEMPFATSECTION  0x700200

#define FILEBLOCKADDR 0x800000
#define FILENODELEN   24
#define FILEBLOCKLEN  FILENODELEN*30		//一个进程最多打开30个文件

#define FILEBUFFERADDR 0x810000	//文件缓冲区开始位置
#define FILEBUFFLEN 0x3C00		//单个进程文件缓冲区大小

#define PCBAddr 0x500100	//PCB起始地址
#define PCBSIZE 0x4c		//PCB大小

#define HEAD 1
#define TAIL 2
#define MIDDLE 3

#define DATA 189	//数据开始的扇区

#define PCBAddr 0x500100  //界限：0x501100
#define CURPCB 0x503230
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

void hdread(b32 lba,b32 des,b32 count);
void memcpy(void *destin,void *source,unsigned n);

b32 getfileitem(b8 *filename_);	//返回一个目录描述符,filename_为存放文件名的地址
b32 nextfileitem(b32 dd,b8 *filename_);	//dd为一个目录描述符

b32 isfileexit(b8 * filename_);
b32 getfilesize(b8 *filename_);
b32 readf(b32 fd,b8 *buffer,b32 count);	//fd为文件描述符
b32 openfile(b8 *filename_);	//返回一个文件描述符
b32 adjustfilecur(b32 fd,b32 locate);	
b32 resetfilecur(b32 fd,b32 flag);	//flag为设置位置


b32 isfileexit(b8 *filename_)
{
	b8 *filename=(b8 *)user2phy(filename_); //视情况转换
	b32 rootsec=ROOTSECTION;
	b8 *rootaddr=0;
	b32 i=0;
	b32 j=0;
	b32 k=0;
	b32 flag=0;
	b32 l=0;
	for(l=0;l<ROOTNUM;l++)
	{
		rootaddr=(b8 *)TEMPROOTSECTION;
		hdread(rootsec,TEMPROOTSECTION,1);
		for(i=0;i<0x10;i++)
		{
			if(rootaddr[0x20]==0||rootaddr[0x20]==0xE5)
				continue;
			for(j=0;j<11;j++)
			{
				if(rootaddr[0x20+j]!=filename[0x20+j])
					break;
			}
			if(j==11)
			{
				flag=1;
				return 1;
			}
			else
			{
				rootaddr+=0x40;
			}
		}
		rootsec++;
	}
	return 0;
}

b32 getfileitem(b8 *filename_)
{
	//b8 *filename=(b8 *)user2phy(filename_);
	b8 *filename=filename_;
	b32 rootsec=ROOTSECTION;
	b8 *rootaddr=0;
	b32 i=0;
	b32 l=0;
	b32 dd=0;
	for(l=0;l<ROOTNUM;l++)
	{
		rootaddr=(b8 *)TEMPROOTSECTION;
		hdread(rootsec,TEMPROOTSECTION,1);
		for(i=0;i<8;i++)
		{
			dd++;

			if(*(rootaddr+0x20)==0||(rootaddr+0x20)==0xE5)
			{
				rootaddr+=0x40;
				continue;
			}
			memcpy(filename,rootaddr+0x20,11);
			return dd;
		}
		rootsec++;
	}
	return 0;
}

b32 nextfileitem(b32 dd,b8 *filename_)
{
//	b8 *filename=(b8 *)user2phy(filename_);
	b8 *filename=filename_;
	b32 rootsec=ROOTSECTION;
	b8 *rootaddr=0;
	b32 i=0;
	b32 l=0;
	b32 ndd=dd;
	b32 flag=1;

	rootsec+=dd/8;
	for(l=0;l<(ROOTNUM-dd/8);l++)
	{
		rootaddr=(b8 *)TEMPROOTSECTION;
		hdread(rootsec,TEMPROOTSECTION,1);
		for(i=0;i<8;i++)
		{
			if(flag==1)
			{
				i=dd%8;
				flag=0;
				rootaddr+=i*0x40;
				i--;
				continue;
			}
			ndd++;
			b8 cmp=*(rootaddr+0x20);
			if(cmp==(b8)0xE5||cmp==(b8)0x00)
			{
				rootaddr+=0x40;
				continue;
			}
			else
			{
				memcpy(filename,rootaddr+0x20,11);
				return ndd;
			}
		}
		rootsec++;
	}
	return 0;
}


b16 getnextfat2(b16 fat)
{
	b16 temp=fat*2/512;
	b16 temp2=fat*2%512;
	temp++;
	temp&=0x00FF;
	hdread(temp,TEMPFATSECTION,1);
	b16 *tempfatsection=(b16 *)(TEMPFATSECTION+temp2);
	return *tempfatsection;
}

b32 getfilesize(b8 *filename_)
{
	b8 *filename=(b8 *)user2phy(filename_);
	b32 rootsec=ROOTSECTION;
	b8 *rootaddr=0;
	b32 i=0;
	b32 l=0;
	b16 fat=0;
	b32 j=0;
	b32 sum=0;
	
	for(l=0;l<ROOTNUM;l++)
	{
		rootaddr=(b8*)TEMPROOTSECTION;
		hdread(rootsec,TEMPROOTSECTION,1);
		for(i=0;i<0x10;i++)
		{
			if(rootaddr[0]==0||rootaddr[0]==0xE5)
				continue;
			for(j=0;j<11;j++)
			{
				if(rootaddr[j]!=filename[j])
					break;
			}
			if(j==11)
			{
				sum=*(b32*)(&rootaddr[0x1c]);
				return sum;
			}
			rootaddr+=0x20;
		}
	}
	return 0;
}


typedef struct filenode_{	//使用前须清0
	b32 cursor;
	b8 filename[12];		//最后一个字节存0x00
	b32 flags;
	b32 filesize;
}FILENODE;

//获取文件节点地址
b32 getfileblock(b32 pcbbaseaddr,b32 pcbaddr,b32 pcbsize,b32 *blockaddr)
{
	b32 num=(pcbaddr-pcbbaseaddr)/pcbsize;
	*blockaddr=num*FILEBLOCKLEN+FILEBLOCKADDR;
	return 1;
}

//获取文件高速缓冲区地址
b32 getbufferaddr(b32 pcbbaseaddr,b32 pcbaddr,b32 pcbsize,b32 fd)
{
	b32 num=(pcbaddr-pcbbaseaddr)/pcbsize;
	b32 bufferaddr=num*FILEBUFFLEN+FILEBUFFERADDR;
	return bufferaddr+fd*0x200;
}

//在openfile中调用
b32 readfirstsection(b8 *filename,b32 addr)
{
	b32 rootsec=ROOTSECTION;
	b8 *rootaddr=0;
	b32 i=0;
	b32 j=0;
	b32 l=0;
	b16 fat=0;
	for(l=0;l<ROOTNUM;l++)
	{
		rootaddr=(b8 *)TEMPROOTSECTION;
		hdread(rootsec,TEMPROOTSECTION,1);
		for(i=0;i<0x10;i++)
		{
			if(rootaddr[0]==0||rootaddr[0]==0xE5)
				continue;
			for(j=0;j<11;j++)
			{
				if(rootaddr[j]!=filename[j])
					break;
			}
			if(j==11)
			{
				fat=*(b16*)(rootaddr+0x1A);
				fat+=DATA;
				fat&=0xFF;
				hdread(fat,addr,1);
				return 1;
			}
			else
				rootaddr+=0x20;
		}
		rootsec++;
	}
	return 0;
}


b32 openfile(b8 *filename_)
{
	b8 *filename=user2phy(filename_);
	b32 i=0;

	PCB *pcb=*(b32 *)CURPCB;
	FILENODE *fn=(FILENODE*)(pcb->fileblock);
	for(i=0;i<30;i++)
	{
		if(fn->flags==0)
			break;
		fn++;
	}
	if(i==30)
		return 0;
	b32 bufferaddr=getbufferaddr(PCBAddr,pcb,PCBSIZE,i);
	readfirstsection(filename,bufferaddr);
	fn->flags=1;
	fn->cursor=0;
	memcpy(fn->filename,filename,11);
	fn->filename[11]=0x00;
	fn->filesize=getfilesize(filename_);
	return i;
	
}

//在readf等函数中调用
b32 readsection(b8 *filename,b32 num,b32 addr)
{
	b32 rootsec=ROOTSECTION;
	b8 *rootaddr=0;
	b32 i=0;
	b32 j=0;
	b32 l=0;
	b16 fat=0;
	b32 k=0;
	for(l=0;l<ROOTNUM;l++)
	{
		rootaddr=(b8 *)TEMPROOTSECTION;
		hdread(rootsec,TEMPROOTSECTION,1);
		for(i=0;i<0x10;i++)
		{
			if(rootaddr[0]==0||rootaddr[0]==0xE5)
				continue;
			for(j=0;j<11;j++)
				{
					if(rootaddr[j]!=filename[j])
						break;
				}
			if(j==11)
			{
				fat=*(b16*)(rootaddr+0x1A);
				for(k=0;k<num;k++)
					fat=getnextfat2(fat);
				fat+=DATA;
				fat&=0xFF;
				hdread(fat,addr,1);
				return 1;
			}
			rootaddr+=0x20;
		}
		rootsec++;
	}
	return 0;
}



b32 readf(b32 fd,b8 *buffer_,b32 count)
{
	PCB *pcb=(PCB *)*(b32 *)CURPCB;
	b8 *buffer=user2phy(buffer_);
	b8 *filebuffer;
	b32 i=0;
	getbufferaddr(PCBAddr,pcb,PCBSIZE,&filebuffer);
	FILENODE *fn=(FILENODE *)(pcb->fileblock+FILENODELEN*fd);
	
	b32 size=fn->filesize;
	b32 cursor=fn->cursor;
	count+=cursor;
	for(i=cursor;i<count;i++)
	{	
		if(i>size)
		{
			buffer[i-cursor]=EOF;
			fn->cursor=i;
			return 1;
		}
		if(i%512==0)
		{
			readsection(fn->filename,i/512,filebuffer);
		}
			

		buffer[i-cursor]=filebuffer[i%512];
	}
	fn->cursor=i;
	return 1;
}

b32 adjustfilecur(b32 fd,b32 locate)
{
	PCB *pcb=(PCB*)*(b32 *)CURPCB;
	b8 *filebuffer;
	getbufferaddr(PCBAddr,pcb,PCBSIZE,&filebuffer);
	FILENODE *fn=(FILENODE*)(pcb->fileblock+FILENODELEN*fd);
	b32 size=fn->filesize;
	b32 cursor=fn->cursor;
	b32 hd=0;

	cursor+=locate;
	if(cursor<0)
		cursor=0;
	if(cursor>size)
		cursor=size;
	hd=cursor/512;
	readsection(fn->filename,hd,filebuffer);
	fn->cursor=cursor;
	return 1;
}

b32 resetfilecur(b32 fd,b32 flag)
{
	PCB *pcb=(PCB*)*(b32 *)CURPCB;
	b8 *filebuffer;
	getbufferaddr(PCBAddr,pcb,PCBSIZE,&filebuffer);
	FILENODE *fn=(FILENODE*)(pcb->fileblock+FILENODELEN*fd);
	b32 size=fn->filesize;
	b32 cursor=fn->cursor;

	if(flag==HEAD)
		cursor=0;
	else if(flag==TAIL)
		cursor=size;
	else if(flag==MIDDLE)
		cursor=size/2;
	readsection(fn->filename,cursor/512,filebuffer);
	fn->cursor=cursor;
	return 1;
}
