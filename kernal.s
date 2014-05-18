	.file	"kernal.c"
	.section	.rodata
	.align 4
.LC0:
	.string	"c farmart kernal is executing.\n^_^"
.LC1:
	.string	"hahahahahhahaaha\n"
.LC2:
	.string	"GDTR change.\n"
	.text
	.globl	_start
	.type	_start, @function
_start:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%ebx
	subl	$68, %esp
	.cfi_offset 3, -12
	movl	$.LC0, (%esp)
	call	print
	movl	$.LC1, (%esp)
	call	print
	movl	$49664, -12(%ebp)
	movw	$0, -24(%ebp)
	movw	$0, -22(%ebp)
	movb	$0, -20(%ebp)
	movw	$0, -19(%ebp)
	movb	$0, -17(%ebp)
	movl	-12(%ebp), %ecx
	movl	-24(%ebp), %eax
	movl	-20(%ebp), %edx
	movl	%eax, (%ecx)
	movl	%edx, 4(%ecx)
	movw	$-1, -32(%ebp)
	movw	$0, -30(%ebp)
	movb	$0, -28(%ebp)
	movw	$-12398, -27(%ebp)
	movb	$0, -25(%ebp)
	movl	-12(%ebp), %eax
	leal	8(%eax), %ecx
	movl	-32(%ebp), %eax
	movl	-28(%ebp), %edx
	movl	%eax, (%ecx)
	movl	%edx, 4(%ecx)
	movw	$-1, -40(%ebp)
	movw	$0, -38(%ebp)
	movb	$0, -36(%ebp)
	movw	$-12386, -35(%ebp)
	movb	$0, -33(%ebp)
	movl	-12(%ebp), %eax
	leal	16(%eax), %ecx
	movl	-32(%ebp), %eax
	movl	-28(%ebp), %edx
	movl	%eax, (%ecx)
	movl	%edx, 4(%ecx)
	movl	-12(%ebp), %eax
	leal	24(%eax), %ecx
	movl	-40(%ebp), %eax
	movl	-36(%ebp), %edx
	movl	%eax, (%ecx)
	movl	%edx, 4(%ecx)
	movw	$-1, -48(%ebp)
	movw	$-32768, -46(%ebp)
	movb	$11, -44(%ebp)
	movw	$-12398, -43(%ebp)
	movb	$0, -41(%ebp)
	movl	-12(%ebp), %eax
	leal	32(%eax), %ecx
	movl	-48(%ebp), %eax
	movl	-44(%ebp), %edx
	movl	%eax, (%ecx)
	movl	%edx, 4(%ecx)
	movw	$-1, -54(%ebp)
	movl	$49664, -52(%ebp)
	leal	-54(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	-16(%ebp), %edx
	movl	%edx, %ebx
#APP
# 55 "kernal.c" 1
	lgdt (%ebx) 
	movw $0x7c00,%ax 
	movw %ax,%sp 
	movw $0x08,%ax
	movw %ax,%ds 
	movw $0x10,%ax
	movw %ax,%ss 
	movw $0x20,%ax
	movw %ax,%fs 
	ljmp $0x18,$1f
	1:movw $12,%ax
# 0 "" 2
#NO_APP
	movl	$.LC2, (%esp)
	call	print
	call	exit
	.cfi_endproc
.LFE0:
	.size	_start, .-_start
	.ident	"GCC: (Debian 4.7.2-5) 4.7.2"
	.section	.note.GNU-stack,"",@progbits
