;FILENAME : scrollscreen.asm
;FUNCTION : scroll screen a line
;USAGE	  : scrollscreen ()
;调用后必须手动重新获取CursorPos值
%include "inc/selector.inc"
global scrollscreen

CursorPos EQU 0BE00H

[SECTION .CODE32]

scrollscreen:
	push ebp
	mov ebp,esp
	push ecx
	push esi
	push edi
	push ds

	mov ax,SELECTOR_VEDIO
	mov DS,ax

	mov ecx,80*23
	mov edi,0
	mov esi,160
	mov al,02
	cld
.L1
	movsb
	stosb
	inc esi
	loop .L1

	mov ecx,80
	mov ax,0
.L2
	stosw
	loop .L2

	pop ds
	mov eax,[CursorPos]
	sub eax,160
	mov [CursorPos],eax
	pop edi
	pop esi
	pop ecx
	leave
	ret

