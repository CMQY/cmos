/**************************************************************************
 * console.c 系统守护程序，处理用户命令
 *************************************************************************/
void systemcall(b32,b32,b32);
main()
{
	//在最后一行输出信息
	char msg[]="first task in c ^_^ \n";
	systemcall(2,2,2);
	for(;;)
	systemcall(3,&msg,0);
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
}
