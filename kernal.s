	.file	"kernal.c"
	.section	.rodata
	.align 8
.LC0:
	.string	"c farmart kernal is executing.\n^_^"
.LC1:
	.string	"hahahahahhahaaha\n"
.LC2:
	.string	"GDTR change.\n"
.LC3:
	.string	"IDTR load successfully.\n"
	.text
	.globl	_start
	.type	_start, @function
_start:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$104, %rsp
	.cfi_offset 3, -24
	movl	$.LC0, %edi
	call	print
	movl	$.LC1, %edi
	call	print
	movq	$49664, -24(%rbp)
	movw	$0, -48(%rbp)
	movw	$0, -46(%rbp)
	movb	$0, -44(%rbp)
	movw	$0, -43(%rbp)
	movb	$0, -41(%rbp)
	movq	-24(%rbp), %rax
	movq	-48(%rbp), %rdx
	movq	%rdx, (%rax)
	movw	$-1, -64(%rbp)
	movw	$0, -62(%rbp)
	movb	$0, -60(%rbp)
	movw	$-12398, -59(%rbp)
	movb	$0, -57(%rbp)
	movq	-24(%rbp), %rax
	leaq	8(%rax), %rdx
	movq	-64(%rbp), %rax
	movq	%rax, (%rdx)
	movw	$-1, -80(%rbp)
	movw	$0, -78(%rbp)
	movb	$0, -76(%rbp)
	movw	$-12386, -75(%rbp)
	movb	$0, -73(%rbp)
	movq	-24(%rbp), %rax
	leaq	16(%rax), %rdx
	movq	-64(%rbp), %rax
	movq	%rax, (%rdx)
	movq	-24(%rbp), %rax
	leaq	24(%rax), %rdx
	movq	-80(%rbp), %rax
	movq	%rax, (%rdx)
	movw	$-1, -96(%rbp)
	movw	$-32768, -94(%rbp)
	movb	$11, -92(%rbp)
	movw	$-12398, -91(%rbp)
	movb	$0, -89(%rbp)
	movq	-24(%rbp), %rax
	leaq	32(%rax), %rdx
	movq	-96(%rbp), %rax
	movq	%rax, (%rdx)
	movw	$-1, -112(%rbp)
	movl	$49664, -110(%rbp)
	leaq	-112(%rbp), %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rdx
	movq	%rdx, %rbx
#APP
# 58 "kernal.c" 1
	lgdt (%ebx) 
	movw $0x7c00,%cx 
	movw $0x10,%ax
	movw %ax,%ss 
	movw %cx,%sp 
	movw $0x08,%ax
	movw %ax,%ds 
	movw $0x20,%ax
	movw %ax,%fs 
	ljmp $0x18,$1f
	1:movw $12,%ax
# 0 "" 2
#NO_APP
	movl	$.LC2, %edi
	call	print
	movl	$0, %eax
	call	initidt
	movl	$.LC3, %edi
	call	print
#APP
# 90 "kernal.c" 1
	movb	$0x11,%al 
	outb	%al,$0x20 
	.word	0x00eb,0x00eb 
	outb	%al,$0xa0 
	.word	0x00eb,0x00eb 
	movb	$0x20,%al 
	outb	%al,$0x21 
	.word	0x00eb,0x00eb 
	movb	$0x28,%al 
	outb	%al,$0xa1 
	.word	0x00eb,0x00eb 
	movb	$0x04,%al 
	outb	%al,$0x21 
	.word	0x00eb,0x00eb 
	movb	$0x02,%al 
	outb	%al,$0xa1 
	.word	0x00eb,0x00eb 
	movb	$0x01,%al 
	outb	%al,$0x21 
	.word	0x00eb,0x00eb 
	outb	%al,$0xa1 
	.word	0x00eb,0x00eb 
	movb	$0xfe,%al 
	outb	%al,$0x21 
	.word	0x00eb,0x00eb 
	movb	$0xff,%al 
	outb	%al,$0xa1 
	.word	0x00eb,0x00eb 
	sti	
	
# 0 "" 2
#NO_APP
	call	exit
	.cfi_endproc
.LFE0:
	.size	_start, .-_start
	.ident	"GCC: (Debian 4.7.2-5) 4.7.2"
	.section	.note.GNU-stack,"",@progbits
