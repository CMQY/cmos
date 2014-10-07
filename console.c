/**************************************************************************
 * console.c 系统守护程序，处理用户命令
 *************************************************************************/
#include "inc/type.h"
b32 systemcall(b32,b32,b32,b32);
void printc(char c);
main()
{
	b8 filename[12];
	b8 filename2[12];
	b32 dd=0;
		while(1)
		{
			char cmd[80];
			cmd[79]='\0';
			b32 i=0;
			for(i=0;i<80;i++){
				while(!systemcall(4,&cmd[i],0,0));
				if(cmd[i]=='\n'){
					cmd[i]='\0';
					break;
				}
				printc(cmd[i]);
			}
			systemcall(3,"\n",0,0);
			if(cmd[0]=='l'&&cmd[1]=='s'&&cmd[2]==0)
			{
				dd=systemcall(6,&filename,0,0);
				systemcall(3,&filename,0,0);
				systemcall(3,"\n",0,0);
				while((dd=systemcall(7,dd,&filename2,0))>0)
				{
					systemcall(3,&filename2,0,0);
					systemcall(3,"\n",0,0);
				}
			}
			else if(cmd[0]==0)
				continue;
			else
			{
				systemcall(3,"unknown command\n",0,0);
			}
		}
}

/******************************************************************************
 * void printc(char c)
 * 打印单个字符 内部调用print函数
 ******************************************************************************/

void printc(char c)
{
    char p[2];
	p[0]=c;
    p[1]='\0';
    systemcall(3,(b32) p,0,0);
}
