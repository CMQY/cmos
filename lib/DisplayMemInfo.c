#include"inc/type.h"
void print(char *str);
void disptr(char *str);
extern disptr;
struct meminfo
{
	u32 BaseAddrLow;
	u32 BaseAddrHigh;
	u32 LengthLow;
	u32 LengthHigh;
	u32 Type;
};

void DisplayMemInfo(meminfo * mem)
{
	print("BaseAddrLow    BaseAddrHigh    LengthLow    LengthHigh    Type");
	disptr(&mem->BaseAddrLow);
	print("   ");
	disptr(&mem->BaseAddrHigh);
	print("   ");
	disptr(&mem->LengthLow);
	print("   ");
	disptr(&mem->LengthHigh);
	print("   ");
	disptr(&mem->Type);
}