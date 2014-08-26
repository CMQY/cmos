;/************************************************************************
; * FAT16文件系统驱动
; * 硬编码fat扇区数和地址及根目录扇区数和地址，需要时再修改
; ************************************************************************/

;#define ROOTADDR 159		//79.5 K
;#define ROOTNUM 32			//16 K
;
;#define TEMPROOTSECTION 0x700000
;#define TEMPFATSECTION 0x700200
ROOTADDR equ 0x503300   ;值159   存放根目录扇区地址
ROOTNUM  equ 0x503304	;值 32   存放根目录数	

TEMPROOTSECTION equ 0x700000
TEMPFATSECTION  equ 0x700200

DATA equ 191  ;数据开始的山区
;//void readfile(b32 *filename,b32 desaddr)
extern hdread
global readfile

readfile:
		push ebp
		mov ebp,esp
		push ebx
		push esi
		push edi
		
        mov eax,ROOTADDR
        mov dword [eax],159
        mov eax,ROOTNUM
        mov dword [eax],32

.nextread:
		push 1
		push TEMPROOTSECTION
		push dword [ROOTADDR]
		call hdread
		add esp,0xc

		mov edx,0x10
		cld
		mov edi,TEMPROOTSECTION
.continue:
		mov esi,[ebp+8]
		mov ecx,11
.cmpname:
		lodsb
		cmp byte al,[edi]
		jnz .nextitem
		loop .cmpname

		jmp .found

.nextitem:
		dec edx
		cmp edx,0
		jz .nextsection
		and edi,0xFFFFFFE0
		add edi,0x20
		jmp .continue

.nextsection:
		add dword [ROOTADDR],1
		sub dword [ROOTNUM],1
		cmp dword [ROOTNUM],0
		jz .notfind
		jmp .nextread

.notfind:
		mov eax ,0
		jmp .end

.found:
		and edi,0xFFFFFFE0
		add edi,0x1A
		mov ebx,[edi]
.nextfat:
		push ebx			;保存fat值用于读取下一个fat
		add ebx,DATA
		
		push dword 1
		push dword [ebp+0xc]
		push ebx
		call hdread
		add esp,0xc
		
		pop eax
		call getnextfat   ;ebx 低16位返回下一fat值
		mov  dx,0xFFEF
		cmp bx,dx
		ja .readend
		add dword [ebp+0xc],0x200
		jmp .nextfat
.readend:
		mov eax,1
.end:	
		pop edi
		pop esi
		pop ebx
		leave
		ret		


getnextfat:
		push ebp
		mov ebp,esp
		push edi

		xor edx,edx
		shl eax,1
		mov ebx,512
		div ebx
		inc eax
		push edx
		push 1
		push TEMPFATSECTION
		push eax
		call hdread
		add esp,0xc
		pop edi
		mov bx,[edi+TEMPFATSECTION]
		
		pop edi
		leave
		ret
