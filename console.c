/**************************************************************************
 * console.c 系统守护程序，处理用户命令
 *************************************************************************/

_start()
{
	//在最后一行输出信息
	b8 bin[80];
	//开时钟中断
	asm volatile(
			"push $0x2 \n\t"   //systemcall(1,0,0),,procunlock
			"push $0x2 \n\t"
			"push $0x2 \n\t"
			"int $80 \n\t"
			:::
			);
	while(1)
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
			print("file no find\n");
		setcursor();
	}
}
