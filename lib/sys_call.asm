

;�������ù���
;����ָ���Ĵ���EAX��EDX��ECX�����ݱ����е������Լ����𱣴棬�����ú������������ƻ�
;EBX��ESI��EDI��ESP��EBP�����ɱ������߱���
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