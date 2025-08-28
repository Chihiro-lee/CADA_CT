	.file	"main.c"
.text
	.balign 2
	.global	initUART
	.type	initUART, @function
initUART:
	; NOP slide!
	NOP
	NOP
	; End NOP slide
	







	
	
	MOVX.W	#23168, &WDTCTL
 
	dint 
	nop
 
	BISX.B	#48, &PBSEL_H
	BISX.B	#1, &UCA1CTLW0_L
	BISX.B	#64, &UCA1CTLW0_L
	MOVX.B	#3, &UCA1BRW_L
	MOVX.B	#-42, &UCA1MCTL
	MOVX.B	#0, &UCA1CTLW0_H
	BICX.B	#1, &UCA1CTLW0_L
	BISX.B	#1, &UCA1ICTL_L
 
	nop 
	bis.w #8, SR 
	nop
 
	


; Old Instruction: RETA

	MOV SR, R4
	DINT
	NOP
	BRA #safe_reta_fun
;End safe sequence

	.size	initUART, .-initUART
	.section	.lowtext,"awx",@progbits
	.balign 2
	.global	USCI_A1_ISR
	.section	__interrupt_vector_47,"ax",@progbits
	.word	USCI_A1_ISR
		.section	.lowtext
	.type	USCI_A1_ISR, @function
USCI_A1_ISR:
	; NOP slide!
	NOP
	NOP
	; End NOP slide
	








	
		PUSHX.A R12

	
	MOVX.W	&UCA1IV, R12
	CMP.W	#2, R12 
	JEQ	.L7
.L3:
	
	POPM.A	#1, r12


; Old Instruction: RETI

	MOV SR, R4
	DINT
	NOP
	BRA #safe_reti_fun
;End safe sequence

.L7:
	MOVX.B	&UCA1RXBUF, R12
	CMP.B	#120, R12 
	JEQ	.L8
	MOVX.B	&UCA1RXBUF, R12
	CMP.B	#114, R12 
	JEQ	.L9
	MOVX.B	&UCA1RXBUF, R12
	CMP.B	#115, R12 
	JNE	.L3
	MOVX.W	#6, &WDTCTL
	BRA	#.L3
.L9:
 
	BR #0xff12
 
	BRA	#.L3
.L8:
 
	BR #0xff16
 
	
	POPM.A	#1, r12


; Old Instruction: RETI

	MOV SR, R4
	DINT
	NOP
	BRA #safe_reti_fun
;End safe sequence

	.size	USCI_A1_ISR, .-USCI_A1_ISR
.text
	.balign 2
	.global	func
	.type	func, @function
func:
	; NOP slide!
	NOP
	NOP
	; End NOP slide
	







	
	
	MOV.B	#3, R12
	


; Old Instruction: RETA

	MOV SR, R4
	DINT
	NOP
	BRA #safe_reta_fun
;End safe sequence

	.size	func, .-func
	.balign 2
	.global	main
	.type	main, @function
main:
	; NOP slide!
	NOP
	NOP
	; End NOP slide
	







	
	
 
	BR #0xff12
 
	MOV.B	#0, R12
	
	.refsym	__crt0_call_exit


; Old Instruction: RETA

	MOV SR, R4
	DINT
	NOP
	BRA #safe_reta_fun
;End safe sequence

	.size	main, .-main
	.ident	"GCC: (lee) 9.2.0"
	.mspabi_attribute 4, 2
	.mspabi_attribute 6, 2
	.mspabi_attribute 8, 2
	.gnu_attribute 4, 2
