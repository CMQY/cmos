#include"inc/type.h"
void print(char * str);
void do_div_invalid()
{
	print("int 0\n");
}
void do_debug()
{
	print("int 1\n");
}
void do_nmi_interrupt()
{
	print("int 2\n");
}
void do_breakpoint()
{
	print("int 3\n");
}
void do_overflow()
{
	print("int 4\n");
}
void do_bounds_check()
{
	print("int 5\n");
}
void do_invalid_opcode()
{
	print("int 6\n");
}
void do_device_unexit()
{
	print("int 7\n");
}
void do_double_error()
{
	print("int 8\n");
}
void do_coprocessor_seg_error()
{
	print("int 9\n");
}
void do_invalid_tss()
{
	print("int 10\n");
}
void do_seg_dispresent()
{
	print("int 11\n");
}
void do_stack_error()
{
	print("int 12\n");
}
void do_general_protection()
{
	print("int 13\n");
}
void do_page_fault()
{
	print("int 14\n");
}
void do_reserved()
{
	print("int 15\n");
}
void do_coprocessor_error()
{
	print("int 16\n");
}

/********************************************************************
外部中断处理程序
*********************************************************************/
/*void do_keyboard()
{
	readkey();    //link keyboard_ctl.asm
} */
//void do_timer()
//{
//	print("#time ahahaha\n");
//}
