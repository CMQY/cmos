#include"inc/type.h"
#define IDTADDR 0x1C200
#define IDTLIMIT 0x800
/***********************************************************************************
ÖÐ¶Ï³õÊŒ»¯³ÌÐò¡£
ÖÐ¶ÏÏòÁ¿±í·ÅÔÚ0x1C200H¡£
ËùÓÐÖÐ¶Ï·œ·šÎÞŽíÎóÂëÔòÑ¹Èë0£¬ÔÙÑ¹ÈëÖÐ¶ÏŽŠÀíº¯ÊýµØÖ·ºóÌø×ªÖÁÖÐ¶Ï·þÎñ³ÌÐò
ÓÉÖÐ¶Ï·þÎñ³ÌÐò±£ŽæCPUÉÏÏÂÎÄºóºôœÐÕ»ÖÐÖžÊŸµÄÖÐ¶ÏŽŠÀí³ÌÐò¡£
·µ»Øºó»ÖžŽÉÏÏÂÎÄºóIRET
È«²¿ÖžÏòÖÐ¶Ï·þÎñ³ÌÐò

************************************************************************************/
void interup_server_route();   //ÖÐ¶ÏŽŠÀí³ÌÐò
/**************************************************
×°ÔØIDTR
***************************************************/
void lidt(b32 base, b32 limit)
{
	b32 temp[2];
	temp[0] = limit << 16;
	temp[1] = base;
	asm volatile(
		"lidt (%0)"
		::"p"(((char *)temp) + 2)
		);

}
/***************************************************
ÉèÖÃinterrupt

ÖÐ¶ÏÈ«ÓÃinterrupt
***********************************************
×°ÔØidt..........ÎŽÍê³É
****************************************************/
typedef struct _idt
{
	b16 offsetl16;
	b16 seg;
	b16 attribute;
	b16 offseth16;
} idt;
void idtload(int index, b32 addr, b16 attribute)
{
	idt * idtbase = (idt *)IDTADDR;
	idtbase[index].offseth16 = (addr >> 16) & 0xFFFF;
	idtbase[index].offsetl16 = addr & 0xFFFF;
	idtbase[index].seg = selector_code;
	idtbase[index].attribute = attribute;
}


/*************************************************************
函数声明，在interrupttransfer.asm中定义
**************************************************************/
void int_0_div_invalid();
void int_1_debug();
void int_2_nmi_interrupt();
void int_3_breakpoint();
void int_4_overflow();
void int_5_bounds_check();
void int_6_invalid_opcode();
void int_7_device_unexit();
void int_8_double_error();
void int_9_coprocessor_seg_error();
void int_10_invalid_tss();
void int_11_seg_dispresent();
void int_12_stack_error();
void int_13_general_protection();
void int_14_page_fault();
void int_15_reserved();
void int_16_coprocessor_error();
void int_32_timer();
void int_33_keyboard();
/******************************************************************
初始化中断
在内核中被调用
*******************************************************************/
void initidt()
{
	idtload(0, (b32) &int_0_div_invalid, DA_386IGate);
	idtload(1, (b32) &int_1_debug, DA_386IGate);
	idtload(2, (b32) &int_2_nmi_interrupt, DA_386IGate);
	idtload(3, (b32) &int_3_breakpoint, DA_386IGate);
	idtload(4, (b32) &int_4_overflow, DA_386IGate);
	idtload(5, (b32) &int_5_bounds_check, DA_386IGate);
	idtload(6, (b32) &int_6_invalid_opcode, DA_386IGate);
	idtload(7, (b32) &int_7_device_unexit, DA_386IGate);
	idtload(8, (b32) &int_8_double_error, DA_386IGate);
	idtload(9, (b32) &int_9_coprocessor_seg_error, DA_386IGate);
	idtload(10, (b32) &int_10_invalid_tss, DA_386IGate);
	idtload(11, (b32) &int_11_seg_dispresent, DA_386IGate);
	idtload(12, (b32) &int_12_stack_error, DA_386IGate);
	idtload(13, (b32) &int_13_general_protection, DA_386IGate);
	idtload(14, (b32) &int_14_page_fault, DA_386IGate);
	idtload(15, (b32) &int_15_reserved, DA_386IGate);
	idtload(16, (b32) &int_16_coprocessor_error, DA_386IGate);
/*****************************************************************************
外部中断装载
******************************************************************************/
	idtload(32, (b32) &int_32_timer, DA_386IGate);
	idtload(33, (b32) &int_33_keyboard, DA_386IGate);




/*****************************************************************************
装载IDTR
******************************************************************************/
	b32 base = IDTADDR;
	b32 limit = IDTLIMIT;
	lidt(base, limit);

/*****************************************************************************
设置8253定时芯片
******************************************************************************/
	asm volatile (
		"movb	$0x36,%%al \n\t"
		"movl	$0x43,%%edx \n\t"
		"outb	%%al,%%dx \n\t"
		".word	0x00eb,0x00eb \n\t"
		"movl	$11930,%%eax \n\t"
		"movl	$0x40,%%edx \n\t"
		"outb	%%al,%%dx \n\t"
		".word	0x00eb,0x00eb \n\t"
		"movb	%%ah,%%al \n\t"
		"outb	%%al,%%dx \n\t"
		".word	0x00eb,0x00eb \n\t"
		:::"%eax","%edx");
}
