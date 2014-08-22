;**************************************************************
;FILENAME	:keyboard_ctl.asm
;USAGE		:nasm -o keyboard_ctl.o keyboard.ctl.asm
;			 
;	遵循_cdecl,手动保存 EBX,ESI,EDI,EBP


;扫描码 http://www.computer-engineering.org/ps2keyboard/scancodes1.html
;适用兼容机采用 8042控制器
;编程方法
;------------------------------------------------------------------
;寄存器名称		寄存器大小		端口	R/W		用法
;--------------------------------------------------------------
;输出缓冲区		1 BYTE			0x60	R		读输出缓冲区
;输入缓冲区		1 BYTE			0x60	W		写输入缓冲区
;状态寄存器		1 BYTE			0x64	R		读取状态
;控制寄存器		1 BYTE			0x64	W		发送命令
;-------------------------------------------------------------------
;
;把接收到的字符经过处理后存进一个循环队列，所有字符在取出缓冲区时回显，
keyq_addr	equ	200000h	;键盘队列基址，暂定
keyq_size	equ 10h		;键盘队列大小，暂定



;keyboard interrupt load in IRQ1
;read the key and use 8255A to reset the 8042


[SECTION .DATA]
message1	db	'read key successaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',0

[SECTION .CODE32]
extern printdword
extern printbyte
extern key_handle

global do_keyboard
do_keyboard:
			push ebx
			push esi
			push edi
			push ebp	;stord the resgesters
			
			xor eax,eax	;存放扫描码
			in	al,0x60
			call key_handle1	;处理扫描码

;key_reset:
;			in al,0x61  ;使用8255A对8042进行复位
;			jmp $+2
;			jmp $+2
;			or al,0x80
;			jmp $+2
;			jmp $+2
;			out 0x61,al
;			jmp $+2
;			jmp $+2
;			and al,0x7f
;			out 0x61,al

			pop ebp   ;中断结束
			pop edi
			pop esi
			pop ebx
			ret


key_handle1:
			push eax
			call key_handle
			add esp,4
			ret
