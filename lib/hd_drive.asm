;FILENAME : dh_drive.asm
;FUNCTION : 
%include "inc/selector.inc"
C equ 20
H equ 16
S equ 63
global hdread,hdwrite
extern ltoc
;void hdread(b32 lba,b32 des,b32 count)
;参数说明
;lba为从0开始的LBA块数，des为目标内存地址，count为扇区数
[bits 32]
hdread:
		push ebp
		mov ebp,esp
		push edi
		push es
		sub esp,0x10
		lea eax,[ebp-0x10]
		push eax           ;S
		lea eax,[ebp-0xc]
		push eax		   ;H
		lea eax,[ebp-0x8]
		push eax		   ;C
		mov eax,[ebp+0x8]
		push eax		   ;lba
		call ltoc
		add esp,0x10

		mov eax,[ebp-0xc]
		or al,10100000b    ;H
		and al,10101111b
		mov dx,1f6h
		out dx,al
		
		mov dx,1f2h
		mov eax,[ebp+0x10]
		out dx,al             ;count
		
		mov dx,1f3h
		mov eax,[ebp-0x10]     ;S
		out dx,al

		mov dx,1f4h
		mov eax,[ebp-0x8]
		out dx,al

		mov al,ah
		and al,00000011b
		mov dx,1f5h
		out dx,al

		mov dx,1f7h
		mov al,20h
		out dx,al
ready:
		in al,dx
		test al,8
		jz ready
		
		mov eax,[ebp+0x10]
		mov ecx,0x100
		mul ecx
		mov ecx,eax
		mov edi,[ebp+0xc]
		cld
		mov dx,0x1f0
		mov ax,SELECTOR_DATA
		mov es,ax
.L:
		in ax,dx
		stosw
		loop .L
		
		add esp,0x10
		pop es
		pop edi
		leave
		ret

;void hdwrite(b32 src,b32 lba,b32 bytes)
;参数说明，src为源内存地址，lba为0开始的LBA扇区数，bytes*2 为写入单个
;扇区字节数，注意只写入一个扇区，注意写入字节数必为偶数，bytes必须小于等
;于256,否则出错
hdwrite:
		jmp $
		push ebp
		mov ebp,esp
		push esi

		sub esp,0x10
		lea eax,[ebp-0x10]
		push eax           ;S
		lea eax,[ebp-0xc]
		push eax		   ;H
		lea eax,[ebp-0x8]
		push eax		   ;C
		mov eax,[ebp+0xc]
		push eax		   ;lba
		call ltoc
		add esp,0x10

		mov eax,[ebp-0xc]
		or al,10100000b    ;H
		and al,10101111b
		mov dx,1f6h
		out dx,al
		
		mov dx,1f2h
		mov eax,1
		out dx,al             ;count
		
		mov dx,1f3h
		mov eax,[ebp-0x10]     ;S
		out dx,al

		mov dx,1f4h
		mov eax,[ebp-0x8]
		out dx,al

		mov al,ah
		and al,00000011b
		mov dx,1f5h
		out dx,al

		mov dx,1f7h
		mov al,30h
		out dx,al
read:
		in al,dx
		test al,8
		jz read
		
		mov ecx,[ebp+0x10]
		mov esi,[ebp+0x8]
		cld
		mov dx,0x1f0
.M:
		lodsw
		out dx,ax
		loop .M
		
		add esp,0x10
		pop esi
		leave
		ret


;void  ltoc(b32 lba,b32 *C,b32 *H,b32 *S)
;ltoc:
;		push ebp
;		mov ebp,esp
;
;		mov eax,[ebp+0x8]
;		mov cx,H*S
;		div cx
;		mov ecx,[ebp+0xC]
;		mov [ecx],eax
;		mov eax,edx
;		mov cx,S
;		div cx
;		mov ecx,[ebp+0x10]
;		mov [ecx],eax
;		add edx,1
;		mov ecx,[ebp+0x14]
;		mov [ecx],edx
;
;		leave
;		ret
;
