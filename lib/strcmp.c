/***********************************************************
 * 实现字符串比较函数
 ***********************************************************/
#include "../inc/type.h"
b32 strcmp(b8 *str1,b8* str2)
{
	int i=0;
	while(str1[i]!=0&&str2[i]!=0)
	{
		if(str1[i]!=str2[i])
			return 0;
		else
			i++;
	}
	if(str1[i]==str2[i])
		return 1;
	else
		return 0;
}
