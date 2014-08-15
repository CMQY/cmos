;FILE NAME : printbin.asm
;FUNCTION  : 打印十六进制寄存器数字
;ARG       : void printbin(char)
CursorPos	EQU	0BE00H	;4Bits

SELECTOR_DATA   EQU 8H                                                          
SELECTOR_STACK  EQU 10H
SELECTOR_CODE32 EQU 18H
SELECTOR_VEDIO  EQU 20H

extern scrollscreen
global printbyte,printword,printdword

printbyte:
		push ebp
		mov ebp,esp
		mov eax,[ebp+8]
		push eax
		call printb
		add esp,4
		call printh
		leave
		ret

printword:
		push ebp
		mov ebp,esp
		mov eax,[ebp+8]
		push eax
		call printw
		add esp,4
		call printh
		leave
		ret

printdword:
		push ebp
		mov ebp,esp
		mov eax,[ebp+8]
		push eax
		call printd
		add esp,4
		call printh
		leave
		ret


print:	
		push ebp
		mov ebp,esp	
		push esi
		push edi
		mov ax,SELECTOR_VEDIO
		mov ES,ax
		cld
		mov edi,[CursorPos]
		cmp edi,0FA0H
		jb .NEXT
		call scrollscreen
		mov edi,[CursorPos]
.NEXT:
		mov eax,[ebp+8]
		and eax,0FH
		cmp al,9
		ja	.BIG
		add al,'0'
		mov [ES:edi],al
		inc edi
		mov al,02
		mov [ES:edi],al
		inc edi
		
		jmp .END
.BIG:
		sub al,10
		add al,'A'
		mov [ES:edi],al
		inc edi
		mov al,02
		mov [ES:edi],al
		inc edi

.END:
		mov [CursorPos],edi
		pop edi
		pop esi
		leave
		ret

;printbyte(int)
;打印低字节十六进制
;
;

printb:
		push ebp
		mov ebp,esp
		push ebx
		mov ebx,[ebp+8]
		ror bl,4
		push ebx
		call print
		add esp,4
		ror bl,4
		push ebx
		call print
		add esp,4

		pop ebx
		leave
		ret

printw:
		push ebp
		mov ebp,esp
		push ebx
		mov ebx,[ebp+8]
		ror bx,8
		push ebx
		call printb
		add esp,4
		ror bx,8
		push ebx
		call printb
		add esp,4

		pop ebx
		leave 
		ret

printd:
		push ebp
		mov ebp,esp
		push ebx
		mov ebx,[ebp+8]
		ror ebx,16
		push ebx
		call printw
		add esp,4
		
		ror ebx,16
		push ebx
		call printw
		add esp,4

		pop ebx
		leave 
		ret


printh:
		push ebp
		mov ebp,esp
		push edi
		mov ax,SELECTOR_VEDIO
		mov ES,ax

		mov edi,[CursorPos]
		cmp edi,0FA0H
		jb .NEXT2
		call scrollscreen
		mov edi,[CursorPos]
.NEXT2:
		mov al,'H'
		mov [ES:edi],al
		inc edi
		mov dword [ES:edi],02
		inc edi
		mov [CursorPos],edi
		pop edi
		leave 
		ret

