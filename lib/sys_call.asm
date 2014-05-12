

;函数调用惯例
;惯例指明寄存器EAX、EDX和ECX的内容必须有调用者自己负责保存，被调用函数可以随意破坏
;EBX、ESI、EDI、ESP、EBP必须由被调用者保存
.globl	mem
.text
mem:
	push	%ebp
	mov	%esp,%ebp
	mov	0x4(%esp),%edi   
	mov	0x8(%esp),%esi    ;
	mov	0xc(%esp),%ecx	;
	cld	                 ;
.1	cmp	$0,%ecx
	jz	.2
	movsb	%ds:(%esi),%es:(%edi)
	dec	%ecx
	jz	.1
.2	mov	0xc(%esp),%eax
	leave
	ret