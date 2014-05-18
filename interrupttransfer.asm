%include "inc/protectedasm.inc"
;----------------------------------------------------------------------------------------------------------------------------
;向量号	助记符	说明						类型				错误号		产生源
;------------------------------------------------------------------------------------------------------------------------
;0		;DE		除出错						故障		无		DIV或IDIV指令
;1		;DB		调试						故障/陷阱	无		任何代码或数据引用，或是INT 1指令
;2		--		NMI中断						中断		无		非屏蔽外部中断
;3		;BP		断点						陷阱		无		INT 3指令
;4		;OF		溢出						陷阱		无		INTO指令
;5		;BR		边界范围超出				故障		无		BOUND指令
;6		;UD		无效操作码（未定义操作码）	故障		无		UD2指令或保留的操作码。（Pentium Pro中加入的新指令）
;7		;NM		设备不存在（无数学协处理器）故障		无		浮点或WAIT/FWAIT指令
;8		;DF		双重错误					异常终止	有（0）	任何可产生异常、NMI或INTR的指令
;9		--		协处理器段超越（保留）		故障		无		浮点指令（386以后的CPU不产生该异常）
;10		;TS		无效的任务状态段TSS			故障		有		任务交换或访问TSS
;11		;NP		段不存在					故障		有		加载段寄存器或访问系统段
;12		;SS		堆栈段错误					故障		有		堆栈操作和SS寄存器加载
;13		;GP		一般保护错误				故障		有		任何内存引用和其他保护检查
;14		;PF		页面错误					故障		有		任何内存引用
;15		--		（Intel保留，请勿使用）					无 
;16		;MF		x87 FPU浮点错误（数学错误）	故障		无		x87 FPU浮点或WAIT/FWAIT指令
;17		;AC		对起检查					故障		有（0）	对内存中任何数据的引用
;18		;MC		机器检查					异常终止	无		错误码（若有）和产生源与CPU类型有关（奔腾处理器引进）
;19		;XF		SIMD浮点异常				故障		无		SSE和SSE2浮点指令（PIII处理器引进）
;20-31	--		（Intel保留，请勿使用）
;32-255	--		用户定义（非保留）中断		中断				外部中断或者INT n指令
;----------------------------------------------------------------------------------------------------------------------------

extern	do_div_invalid,do_debug,do_NMI_interrupt,do_breakpoint,do_overflow,do_bounds_check
extern	do_invalid_opcode,do_device_unexit,do_double_error,do_coprocessor_seg_error
extern	do_invalid_tss,do_seg_dispresent,do_stack_error,do_general_protection,do_page_fault
extern	do_reserved,do_coprocesstor_error


global	int_0_div_invalid,int_1_debug,int_2_NMI_interrupt,int_3_breakpoint,int_4_overflow,int_5_bounds_check
global	int_6_invalid_opcode,int_7_device_unexit,int_8_int_1uble_error,int_9_coprocessor_seg_error
global	int_10_invalid_tss,int_11_seg_dispresent,int_12_stack_error,int_13_general_protection,int_14_page_fault
global	int_15_reserved,int_16_coprocesstor_error

int_0_div_invalid:
	push	0
	push	do_div_invalid
	jmp	interrupt_server_route

int_1_debug:
	push	0
	push	do_debug
	jmp	interrupt_server_route

int_2_nmi_interrupt:
	push	0
	push	do_NMI_interrupt
	jmp	interrupt_server_route

int_3_brekpoint:
	push	0
	push	do_breakpoint
	jmp	interrupt_server_route

int_4_overflow:
	push	0
	push	do_overflow
	jmp	interrupt_server_route

int_5_bounds_check:
	push	0
	push	do_bounds_check
	jmp	interrupt_server_route

int_6_invalid_opcode:
	push	0
	push	do_invalid_opcode
	jmp	interrupt_server_route

int_7_device_unexit:
	push	0
	push	do_device_unexit
	jmp	interrupt_server_route

int_8_double_error:
	push	do_double_error
	jmp	interrupt_server_route

int_9_coprocessor_seg_error:
	push	0
	push	do_coprocessor_seg_error
	jmp	interrupt_server_route

int_10_invalid_tss:
	push	do_invalid_tss
	jmp	interrupt_server_route

int_11_seg_dispresent:
	push	do_seg_dispresent
	jmp	interrupt_server_route

int_12_stack_error:
	push	do_stack_error
	jmp	interrupt_server_route

int_13_general_protection:
	push	do_general_protection
	jmp	interrupt_server_route

int_14_page_fault:
	push do_page_fault
	jmp	interrupt_server_route

int_15_reserved:
	push	0
	push	do_reserved
	jmp	interrupt_server_route

int_16_coprocessor_error:
	push	0
	push	do_coprocesstor_error
	jmp	interrupt_server_route


;--------------------------------------------------------
;interrupt_server_route
;
;
; 中断处理过程中，若优先级发生变化，会将原ss,esp压入栈中  
; 用户程序（进程）将控制权交给中断处理程序之前CPU将至少12字节（EFLAGS、CS、EIP）  
; 压入中断处理程序（而不是被中断代码）的堆栈中，即进程的内核态栈中，这种情况与远调用相似  
; 有些异常引起中断时，CPU内部会产生一个出错码压入堆栈  
; 然后将中断处理程序地址入栈，堆栈指针指向esp_isr处  
; 然后所有32位寄存器入栈  
; 然后ds，es，fs，gs入栈，此时堆栈指针指向esp_push_all_regs  
;   
; 堆栈内容：  
; -------------------阶段1，优先级改变，保护原来的堆栈---------------------------  
; 72 - 原ss  
; 66 - 原esp  
; -------------------阶段2，控制权交给中断处理程序之前，CPU自动压栈--------------  
; 64 - 原eflags  
; 60 - cs                   <- 代码段选择符  
; 56 - eip                  <- 返回地址  
; 52 - error_code/0         <- 错误码可能没有，若没有中断处理程序自己压入0，见下面  
; -------------------阶段3-------------------------------------------------------  
; 48 - 中断服务程序地址     <- 由下面各个处理自己压栈  
; -------------------阶段4-------------------------------------------------------  
; 44 - eax  
; 40 - ecx  
; 36 - edx  
; 32 - ebx  
; 28 - esp  
; 24 - ebp  
; 20 - esi  
; 16 - edi                  <- pushad  
; 12 - ds  
; 08 - es  
; 04 - fs  
; 00 - gs  
;
;--------------------------------------------------------

interrupt_server_route:
	pushad
	push	ds
	push	es
	push	fs
	push	gs

	mov	ax,selector_data
	mov	ds,ax
	mov	es,ax
	mov	gs,ax
	mov	ax,selector_vedio
	mov	fs,ax
	
	mov	eax,[esp+48]
	call	eax
	pop	gs
	pop	fs
	pop	es
	pop	ds
	popad
	add	esp,8	;跳过服务程序和错误码
	iret