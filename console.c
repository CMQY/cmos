/**************************************************************************
 * console.c 系统守护程序，处理用户命令
 *************************************************************************/
#include "inc/type.h"
b32 systemcall(b32,b32,b32);
void printc(char c);
main()
{
	//在最后一行输出信息
//	systemcall(2,2,2);
	asm volatile(
		"jmp . \n\t"
		:::
		);
	for(;;){
		char cmd[80];
		int i=0;
		for(i=0;i<80;i++){
			if(systemcall(4,&cmd[i],0)!=0){
				if(cmd[i]!='\n')
					printc(cmd[i]);
				else{
		//			exec(cmd);
					break;
				}
			}
		}
	//	systemcall(3,"\n",0);
	}
}
/*	while(1)
	{
		int i=0;
		fot(i=0;i<80;){
			if(keyout(&bin[i])){
				if(bin[i]==0xd)
					break;
				printchar(bin[i]); //输出字符
				i++;
			}
		}
		formart(&bin);
		if(findfile(bin))
			exec(bin);
		else
			print("file not find\n");
		setcursor();
	} */

/******************************************************************************
 * void printc(char c)
 * 打印单个字符 内部调用print函数
 ******************************************************************************/

void printc(char c)
{
    char p[2];
	p[0]=c;
    p[1]='\0';
    systemcall(3,p,0);
}
