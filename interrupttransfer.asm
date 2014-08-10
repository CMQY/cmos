%include "inc/protectedasm.inc"
;----------------------------------------------------------------------------------------------------------------------------
;ÏòÁ¿ºÅ	ÖúŒÇ·û	ËµÃ÷						ÀàÐÍ				ŽíÎóºÅ		²úÉúÔŽ
;------------------------------------------------------------------------------------------------------------------------
;0		;DE		³ý³öŽí						¹ÊÕÏ		ÎÞ		DIV»òIDIVÖžÁî
;1		;DB		µ÷ÊÔ						¹ÊÕÏ/ÏÝÚå	ÎÞ		ÈÎºÎŽúÂë»òÊýŸÝÒýÓÃ£¬»òÊÇINT 1ÖžÁî
;2		--		NMIÖÐ¶Ï						ÖÐ¶Ï		ÎÞ		·ÇÆÁ±ÎÍâ²¿ÖÐ¶Ï
;3		;BP		¶Ïµã						ÏÝÚå		ÎÞ		INT 3ÖžÁî
;4		;OF		Òç³ö						ÏÝÚå		ÎÞ		INTOÖžÁî
;5		;BR		±ßœç·¶Î§³¬³ö				¹ÊÕÏ		ÎÞ		BOUNDÖžÁî
;6		;UD		ÎÞÐ§²Ù×÷Âë£šÎŽ¶šÒå²Ù×÷Âë£©	¹ÊÕÏ		ÎÞ		UD2ÖžÁî»ò±£ÁôµÄ²Ù×÷Âë¡££šPentium ProÖÐŒÓÈëµÄÐÂÖžÁî£©
;7		;NM		Éè±ž²»ŽæÔÚ£šÎÞÊýÑ§Ð­ŽŠÀíÆ÷£©¹ÊÕÏ		ÎÞ		ž¡µã»òWAIT/FWAITÖžÁî
;8		;DF		Ë«ÖØŽíÎó					Òì³£ÖÕÖ¹	ÓÐ£š0£©	ÈÎºÎ¿É²úÉúÒì³£¡¢NMI»òINTRµÄÖžÁî
;9		--		Ð­ŽŠÀíÆ÷¶Î³¬Ôœ£š±£Áô£©		¹ÊÕÏ		ÎÞ		ž¡µãÖžÁî£š386ÒÔºóµÄCPU²»²úÉúžÃÒì³££©
;10		;TS		ÎÞÐ§µÄÈÎÎñ×ŽÌ¬¶ÎTSS			¹ÊÕÏ		ÓÐ		ÈÎÎñœ»»»»ò·ÃÎÊTSS
;11		;NP		¶Î²»ŽæÔÚ					¹ÊÕÏ		ÓÐ		ŒÓÔØ¶ÎŒÄŽæÆ÷»ò·ÃÎÊÏµÍ³¶Î
;12		;SS		¶ÑÕ»¶ÎŽíÎó					¹ÊÕÏ		ÓÐ		¶ÑÕ»²Ù×÷ºÍSSŒÄŽæÆ÷ŒÓÔØ
;13		;GP		Ò»°ã±£»€ŽíÎó				¹ÊÕÏ		ÓÐ		ÈÎºÎÄÚŽæÒýÓÃºÍÆäËû±£»€Œì²é
;14		;PF		Ò³ÃæŽíÎó					¹ÊÕÏ		ÓÐ		ÈÎºÎÄÚŽæÒýÓÃ
;15		--		£šIntel±£Áô£¬ÇëÎðÊ¹ÓÃ£©					ÎÞ 
;16		;MF		x87 FPUž¡µãŽíÎó£šÊýÑ§ŽíÎó£©	¹ÊÕÏ		ÎÞ		x87 FPUž¡µã»òWAIT/FWAITÖžÁî
;17		;AC		¶ÔÆðŒì²é					¹ÊÕÏ		ÓÐ£š0£©	¶ÔÄÚŽæÖÐÈÎºÎÊýŸÝµÄÒýÓÃ
;18		;MC		»úÆ÷Œì²é					Òì³£ÖÕÖ¹	ÎÞ		ŽíÎóÂë£šÈôÓÐ£©ºÍ²úÉúÔŽÓëCPUÀàÐÍÓÐ¹Ø£š±ŒÌÚŽŠÀíÆ÷Òýœø£©
;19		;XF		SIMDž¡µãÒì³£				¹ÊÕÏ		ÎÞ		SSEºÍSSE2ž¡µãÖžÁî£šPIIIŽŠÀíÆ÷Òýœø£©
;20-31	--		£šIntel±£Áô£¬ÇëÎðÊ¹ÓÃ£©
;32-255	--		ÓÃ»§¶šÒå£š·Ç±£Áô£©ÖÐ¶Ï		ÖÐ¶Ï				Íâ²¿ÖÐ¶Ï»òÕßINT nÖžÁî
;----------------------------------------------------------------------------------------------------------------------------

extern	do_div_invalid,do_debug,do_nmi_interrupt,do_breakpoint,do_overflow,do_bounds_check
extern	do_invalid_opcode,do_device_unexit,do_double_error,do_coprocessor_seg_error
extern	do_invalid_tss,do_seg_dispresent,do_stack_error,do_general_protection,do_page_fault
extern	do_reserved,do_coprocessor_error,do_timer,do_keyboard


global	int_0_div_invalid,int_1_debug,int_2_nmi_interrupt,int_3_breakpoint,int_4_overflow,int_5_bounds_check
global	int_6_invalid_opcode,int_7_device_unexit,int_8_double_error,int_9_coprocessor_seg_error
global	int_10_invalid_tss,int_11_seg_dispresent,int_12_stack_error,int_13_general_protection,int_14_page_fault
global	int_15_reserved,int_16_coprocessor_error,int_32_timer,int_33_keyboard
;----------------------------------------------------------------------
;处理函数在interrupt.c中定义
;----------------------------------------------------------------------
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
	push	do_nmi_interrupt
	jmp	interrupt_server_route

int_3_breakpoint:
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
	push	do_coprocessor_error
	jmp	interrupt_server_route


;------------------------------------------------------------
;外部中断服务
;-----------------------------------------------------------
int_32_timer:	;时钟中断
	push	0;
	push	do_timer
	jmp	interrupt_server_route

int_33_keyboard:	;键盘中断
	push	0;
	push	do_keyboard
	jmp	interrupt_server_route

;--------------------------------------------------------
;interrupt_server_route
;
;
; ÖÐ¶ÏŽŠÀí¹ý³ÌÖÐ£¬ÈôÓÅÏÈŒ¶·¢Éú±ä»¯£¬»áœ«Ô­ss,espÑ¹ÈëÕ»ÖÐ  
; ÓÃ»§³ÌÐò£šœø³Ì£©œ«¿ØÖÆÈšœ»žøÖÐ¶ÏŽŠÀí³ÌÐòÖ®Ç°CPUœ«ÖÁÉÙ12×ÖœÚ£šEFLAGS¡¢CS¡¢EIP£©  
; Ñ¹ÈëÖÐ¶ÏŽŠÀí³ÌÐò£š¶ø²»ÊÇ±»ÖÐ¶ÏŽúÂë£©µÄ¶ÑÕ»ÖÐ£¬ŒŽœø³ÌµÄÄÚºËÌ¬Õ»ÖÐ£¬ÕâÖÖÇé¿öÓëÔ¶µ÷ÓÃÏàËÆ  
; ÓÐÐ©Òì³£ÒýÆðÖÐ¶ÏÊ±£¬CPUÄÚ²¿»á²úÉúÒ»žö³öŽíÂëÑ¹Èë¶ÑÕ»  
; È»ºóœ«ÖÐ¶ÏŽŠÀí³ÌÐòµØÖ·ÈëÕ»£¬¶ÑÕ»ÖžÕëÖžÏòesp_isrŽŠ  
; È»ºóËùÓÐ32Î»ŒÄŽæÆ÷ÈëÕ»  
; È»ºóds£¬es£¬fs£¬gsÈëÕ»£¬ŽËÊ±¶ÑÕ»ÖžÕëÖžÏòesp_push_all_regs  
;   
; ¶ÑÕ»ÄÚÈÝ£º  
; -------------------œ×¶Î1£¬ÓÅÏÈŒ¶žÄ±ä£¬±£»€Ô­ÀŽµÄ¶ÑÕ»---------------------------  
; 72 - Ô­ss  
; 66 - Ô­esp  
; -------------------œ×¶Î2£¬¿ØÖÆÈšœ»žøÖÐ¶ÏŽŠÀí³ÌÐòÖ®Ç°£¬CPU×Ô¶¯Ñ¹Õ»--------------  
; 64 - Ô­eflags  
; 60 - cs                   <- ŽúÂë¶ÎÑ¡Ôñ·û  
; 56 - eip                  <- ·µ»ØµØÖ·  
; 52 - error_code/0         <- ŽíÎóÂë¿ÉÄÜÃ»ÓÐ£¬ÈôÃ»ÓÐÖÐ¶ÏŽŠÀí³ÌÐò×ÔŒºÑ¹Èë0£¬ŒûÏÂÃæ  
; -------------------œ×¶Î3-------------------------------------------------------  
; 48 - ÖÐ¶Ï·þÎñ³ÌÐòµØÖ·     <- ÓÉÏÂÃæž÷žöŽŠÀí×ÔŒºÑ¹Õ»  
; -------------------œ×¶Î4-------------------------------------------------------  
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
	call	eax    ;中断处理程序的参数在[esp+52]处
	mov	al,0x20
	out	0x20,al
	pop	gs
	pop	fs
	pop	es
	pop	ds
	popad
	add	esp,8	;Ìø¹ý·þÎñ³ÌÐòºÍŽíÎóÂë
	iret
