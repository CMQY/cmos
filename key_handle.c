/**************************************************************************
 * FILENAME : key_handle.c
 * FUNCTION : 处理由中断接收到的scan code，提供函数调用void key_handle(b32)
 * 参数中，仅低1字节有效
 *************************************************************************/
/*************************************************************************
 * 需几个系统变量
 * Key_Shift_p  ：存放Shift是否处于按下状态
 * Key_Ctrl_p	：存放Ctrl是否处于按下状态
 * Caps			：存放大小写状态
 * E0			：存放是否E0前缀
 *************************************************************************/
#define E0 0x503240
#define KEYADDR 0x503250
#define KEYEND 0x503260
#define KEYFRONT 0x503264
#define KEYBACK 0x503268
#include "inc/type.h"
void printbyte(b32);
void key_handle(b32 scancodel)
{
	b8 keys[]={'*','*','1','2','3','4','5','6','7','8','9','0','-','=',8,'*','q','w','e','r','t','y','u','i','o','p','[',']',13,'*','a','s','d','f','g','h','j','k','l',';',39,'`','*',92,'z','x','c','v','b','n','m',',','.','/','*','*','*',' ','*'};
/*	asm volatile(
			"jmp . \n\t"
			:::
			);  */
	b32 scancode =(b32)(scancodel & 0xFF);
	if(scancode==0xe0){
		b32 * e0=(b32 *)E0;
		if(*e0!=0)
			*e0=0;
		else
			*e0=1;
	}
	else if((scancode&0x80)!=0){}
	else{
		if(scancode<=0x38)
		keyin(keys[scancode]);
	}
}

b32 add(b32 addr)
{
	if((addr+1)>=KEYEND)
		return (addr+1)-KEYEND+KEYADDR;
	else
		return addr+1;
}
		
void initkeyquene()
{
	b32 * front=(b32 *)KEYFRONT;
	b32 * back=(b32 *)KEYBACK;
	*front=KEYADDR;
	*back =KEYADDR + 4;
}

b32 keyin(b8 key)
{
	b32 * front=(b32 *)KEYFRONT;
	b32 * back =(b32 *)KEYBACK;
	b32 addr=add(*back);
	if(addr==*front)
		return 0;
	else{
			b8 * temp=(b8 *)addr;
			*temp=key;
			*back=addr;
			return 1;
	}
}

b32 keyout(b8 * key)
{
	asm volatile(
			"cli \n\t"
			:::
			);
	b32 *front=(b32 *)KEYFRONT;
	b32 *back =(b32 *)KEYBACK;
	b32 addr=add(*front);
	if(addr = *back)
		return 0;
	else{
		b8 *temp=(b8 *)addr;
		*key=*temp;
		*front=addr;
		return 1;
	}
	asm volatile(
			"sti \n\t"
			:::
			);
}
