;gcc -c -m32 -fno-builtin -o displaymeminfo.o  displaymeminfo.asm
#include"../inc/type.h"
void print(char *str);
void disbin(char *str);
struct meminfo
{
	u32 BaseAddrLow;
	u32 BaseAddrHigh;
	u32 LengthLow;
	u32 LengthHigh;
	u32 Type;
};

void displaymeminfo(meminfo * mem)
{
	print("BaseAddrLow    BaseAddrHigh    LengthLow    LengthHigh    Type\n");
	disbin(&mem->BaseAddrLow);
	print("H   ");
	disbin(&mem->BaseAddrHigh);
	print("H   ");
	disbin(&mem->LengthLow);
	print("H   ");
	disbin(&mem->LengthHigh);
	print("H   ");
	disbin(&mem->Type);
	print("H");
}
