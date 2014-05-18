%include "inc/protectedasm.inc"
;----------------------------------------------------------------------------------------------------------------------------
;������	���Ƿ�	˵��						����				�����		����Դ
;------------------------------------------------------------------------------------------------------------------------
;0		;DE		������						����		��		DIV��IDIVָ��
;1		;DB		����						����/����	��		�κδ�����������ã�����INT 1ָ��
;2		--		NMI�ж�						�ж�		��		�������ⲿ�ж�
;3		;BP		�ϵ�						����		��		INT 3ָ��
;4		;OF		���						����		��		INTOָ��
;5		;BR		�߽緶Χ����				����		��		BOUNDָ��
;6		;UD		��Ч�����루δ��������룩	����		��		UD2ָ������Ĳ����롣��Pentium Pro�м������ָ�
;7		;NM		�豸�����ڣ�����ѧЭ������������		��		�����WAIT/FWAITָ��
;8		;DF		˫�ش���					�쳣��ֹ	�У�0��	�κοɲ����쳣��NMI��INTR��ָ��
;9		--		Э�������γ�Խ��������		����		��		����ָ�386�Ժ��CPU���������쳣��
;10		;TS		��Ч������״̬��TSS			����		��		���񽻻������TSS
;11		;NP		�β�����					����		��		���ضμĴ��������ϵͳ��
;12		;SS		��ջ�δ���					����		��		��ջ������SS�Ĵ�������
;13		;GP		һ�㱣������				����		��		�κ��ڴ����ú������������
;14		;PF		ҳ�����					����		��		�κ��ڴ�����
;15		--		��Intel����������ʹ�ã�					�� 
;16		;MF		x87 FPU���������ѧ����	����		��		x87 FPU�����WAIT/FWAITָ��
;17		;AC		������					����		�У�0��	���ڴ����κ����ݵ�����
;18		;MC		�������					�쳣��ֹ	��		�����루���У��Ͳ���Դ��CPU�����йأ����ڴ�����������
;19		;XF		SIMD�����쳣				����		��		SSE��SSE2����ָ�PIII������������
;20-31	--		��Intel����������ʹ�ã�
;32-255	--		�û����壨�Ǳ������ж�		�ж�				�ⲿ�жϻ���INT nָ��
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
; �жϴ�������У������ȼ������仯���Ὣԭss,espѹ��ջ��  
; �û����򣨽��̣�������Ȩ�����жϴ������֮ǰCPU������12�ֽڣ�EFLAGS��CS��EIP��  
; ѹ���жϴ�����򣨶����Ǳ��жϴ��룩�Ķ�ջ�У������̵��ں�̬ջ�У����������Զ��������  
; ��Щ�쳣�����ж�ʱ��CPU�ڲ������һ��������ѹ���ջ  
; Ȼ���жϴ�������ַ��ջ����ջָ��ָ��esp_isr��  
; Ȼ������32λ�Ĵ�����ջ  
; Ȼ��ds��es��fs��gs��ջ����ʱ��ջָ��ָ��esp_push_all_regs  
;   
; ��ջ���ݣ�  
; -------------------�׶�1�����ȼ��ı䣬����ԭ���Ķ�ջ---------------------------  
; 72 - ԭss  
; 66 - ԭesp  
; -------------------�׶�2������Ȩ�����жϴ������֮ǰ��CPU�Զ�ѹջ--------------  
; 64 - ԭeflags  
; 60 - cs                   <- �����ѡ���  
; 56 - eip                  <- ���ص�ַ  
; 52 - error_code/0         <- ���������û�У���û���жϴ�������Լ�ѹ��0��������  
; -------------------�׶�3-------------------------------------------------------  
; 48 - �жϷ�������ַ     <- ��������������Լ�ѹջ  
; -------------------�׶�4-------------------------------------------------------  
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
	add	esp,8	;�����������ʹ�����
	iret