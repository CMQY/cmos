#include "inc/type.h"
#define GDTADDR 0xc200
typedef struct _gdt{
	b16 limitl;
	b16 basel16;
	b8 basem8;
	b16 attribute;             //含段界限高4位  bit8 - bit12 
	b8 baseh8;
}gdt;


void loaddescriptor(int index,b32 base,b16 attr,b16 limit)
{
	gdt * gdtaddr=(gdt *)GDTADDR;
	gdtaddr[index].limitl=limit;
	gdtaddr[index].basel16=base & 0xFFFF;
	gdtaddr[index].basem8=(base >> 16) &0xFF;
	gdtaddr[index].baseh8=(base >> 24) &0xFF;
	gdtaddr[index].attribute=attr;
}

void setgdt()
{
	loaddescriptor(0,0,0,0);
	loaddescriptor(1,0, 0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL0 | DA_DRW, 0xFFFF);
	loaddescriptor(2,0, 0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL0 | DA_DRW,0xFFFF); //selector_stack	
	loaddescriptor(3,0, 0x0F00 | DA_CCOR | DA_DPL0 | DA_32 | DA_LIMIT_4K,0xFFFF); //selector_code	 
	loaddescriptor(4,0xB8000, 0x0F00 | DA_32 | DA_LIMIT_4K | DA_DPL0 | DA_DRW,0xFFFF);	//selector_vedio


}
