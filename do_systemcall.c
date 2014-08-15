/* FILENAME : do_systemcall.c
 * FUNCTION : 提供系统调用，int 80,注意是十进制80，在void do_systemcall()中添加需要执行的c语言程序即可，可使用系统调用暂有void print(void *),参数为NULL结尾的字符串地址和void memcpy(void *desin,void *source,unsigned size)
 */
void do_systemcall()
{
	print("system call test");
}
