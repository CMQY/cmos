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
void key_handle(b32 scancodel)
{
	b8 keys[]={'*','1','2','3',}
	b8 scancode =scancodel & 0xFF;
	if(scancode&0x80){}
	else{
		
