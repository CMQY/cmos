ORG	0x7c00

mov	ax,0x4f01
mov	cx,0x0111
mov	bx,0x2000
mov	es,bx
mov	di,0
int	10h

mov	bx,0x8000
mov	ds,bx
mov	ax,word[es:40]
mov	word [0x0000],ax

mov	ax,0x4f02
mov	bx,0x4111
int	10h
mov	ax,0
mov	ds,ax
jmp boot

GDT:
none:	dw 0x0000,0x0000,0x0000,0x0000
code:	dw 0xffff,0x0000,0x9a00,0x00cf
data:	dw 0xffff,0x0000,0x9200,0x00cf
GDT_END:

GDT_POINTER:
linit	dw GDT_END - GDT
base	dd GDT

boot:
;frist	disable all IRQs and NMI
cli				; disable all IRQs

;second	load GDT into GDTR
lgdt [GDT_POINTER]		; load temp GDT into gdtr

;third	enable proected mode
mov	eax,cr0
bts	eax,0			; CR0.PE = 1
mov	cr0,eax			; enable protected mode

; fourth: far jmp proected mode code
jmp	dword 0x08:entry

bits 32
entry:
mov	ax,0x10
mov	ds,ax
mov	es,ax
mov	ss,ax
mov	fs,ax
mov	gs,ax
mov	esp,0x9ffff

mov	ebx,0xe0000000
mov	ecx,640*480
display:
mov	word [ebx],0xf800
add	ebx,2
loop	display

jmp	$

times	510-$+$$ db 0x00
dw	0xaa55
