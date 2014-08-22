/************************************************************************
 * FAT16文件系统驱动
 * 硬编码fat扇区数和地址及根目录扇区数和地址，需要时再修改
 ************************************************************************/

#define ROOTADDR 159		//79.5 K
#define ROOTNUM 32			//16 K

#define TEMPROOTSECTION 0x700000
#define TEMPFATSECTION 0x700200
ROOTADDR equ 0x503300   ;值159   存放根目录扇区地址
ROOTNUM  equ 0x503304	;值 32   存放根目录数	

TEMPROOTSECTION equ 0x700000
TEMPFATSECTION  eau 0x700200

DATA equ 191  ;数据开始的山区
//void readfile(b8 *filename)

readfile:
		push ebp
		mov ebp,esp
.nextread:
		push 1
		push TEMPROOTSECTION
		push [ROOTADDR]
		call hdread

		mov eax,ROOTADDR
		mov [eax],159
		mov eax,ROOTNUM
		mov [eax],32

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
		mov eax
		jmp .end

.found:
		and edi,0xFFFFFFE0
		add edi,0x1A
		mov ebx,[edi]
.nextfat:
		mov eax,ebx
		add ebx,DATA
		
		push 1
		push TEMPFATADDR
		push ebx
		call hdread

		call getnextfat
		mov 
