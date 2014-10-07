#include "inc/type.h"
b32 systemcall(b32,b32,b32);
main()
{
	systemcall(4,"the second proc is running \n",0);
	for(;;);
}
