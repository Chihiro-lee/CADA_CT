	.file	"secureUpdate.c"
.text
	.section	.tcm:code,"ax",@progbits
	.balign 2
	.global	INTERRUPT_ISR
	.section	__interrupt_vector_1,"ax",@progbits
	.word	INTERRUPT_ISR
		.section	.tcm:code
	.type	INTERRUPT_ISR, @function
INTERRUPT_ISR:
; start of function
; attributes: interrupt 
; framesize_regs:     8
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          8
; elim ap -> fp       12
; elim fp -> sp       0
; saved regs: R12 R13
	; start of prologue
	PUSHM.A	#2, R13
	; end of prologue
	MOVX.W	&rcvBufCount, R12
	MOV.W	R12, R13
	ADD.W	#1, R13
	MOVX.W	R13, &rcvBufCount
	MOV.W	R12, R12
	MOVX.B	&UCA1RXBUF, rcvBuf(R12)
	MOVX.W	&rcvBufCount, R12
	CMP.W	#512, R12 { JNE	.L1
	BICX.B	#1, &UCA1ICTL_L
.L1:
	; start of epilogue
	POPM.A	#2, r13
	RETI
	.size	INTERRUPT_ISR, .-INTERRUPT_ISR
	.balign 2
	.global	overWriteMemory
	.type	overWriteMemory, @function
overWriteMemory:
; start of function
; attributes: 
; framesize_regs:     12
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          12
; elim ap -> fp       16
; elim fp -> sp       0
; saved regs: R4 R6 R10
	; start of prologue
	PUSHM.A	#1, R10
	PUSHM.A	#1, R6
	PUSHM.A	#1, R4
	; end of prologue
	MOVA	R12, R4
	MOVX.W	#-23296, &FCTL3
	MOVA	R14, R12
	ANDX.B	#3, R12
	CMPA	#0, R12 { JEQ	.L5
	MOVX.W	#-23232, &FCTL1
	MOV.W	@R4+, @R14
	ADDA	#2, R14
	ADD.W	#-2, R13
.L6:
	MOV.W	R13, R15
	RRUM.W	#2, R15
	MOVA	R4, R6
	MOVA	R14, R10
	MOV.B	#0, R12
.L7:
	MOV.W	@R6+, @R10
	MOV.W	@R6+, 2(R10)
	ADDA	#4, R10
	ADD.W	#1, R12
	CMP.W	R15, R12 { JLO	.L7
	CMP.W	#0, R15 { JEQ	.L8
	MOV.W	R15, R10
.L9:
	BIT.W	#3, R13 { JEQ	.L10
	MOVX.W	#-23232, &FCTL1
	ADD.W	R10, R10
	MOV.W	R10, R10
	ADDA	R10, R10
	ADDA	R10, R4
	ADDA	R10, R14
	MOV.W	@R4, @R14
.L10:
	MOV.B	#1, R12
	; start of epilogue
	POPM.A	#1, r4
	POPM.A	#1, r6
	POPM.A	#1, r10
	RETA
.L8:
	MOV.B	#1, R10
	BRA	#.L9
.L5:
	MOVX.W	#-23168, &FCTL1
	BRA	#.L6
	.size	overWriteMemory, .-overWriteMemory
	.section	.tcm:codeUpper,"ax",@progbits
	.balign 2
	.global	deploy
	.type	deploy, @function
deploy:
; start of function
; attributes: 
; framesize_regs:     20
; framesize_locals:   64
; framesize_outgoing: 0
; framesize:          84
; elim ap -> fp       24
; elim fp -> sp       64
; saved regs: R4 R5 R6 R9 R10
	; start of prologue
	PUSHM.A	#2, R10
	PUSHM.A	#3, R6
	SUBA	#64, R1
	; end of prologue
	MOVA	R12, 16(R1)
	MOV.B	R13, R11
	MOVX.W	&elfAddress, R12
	MOVX.W	&elfAddress+2, R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R10
	MOV.B	@R10, R12
	CMP.B	#0, @R10 { JEQ	.L55
	MOVX.W	&elfAddress, R14
	ADD	#1, R14 ; cy
	MOVX.W	&elfAddress+2, R15
	ADDC	#0, R15
	PUSH.W	R15 { PUSH.W	R14 { POPM.A	#1, R6
	ADD.B	#-1, R12
	MOV.B	R12, R12
	MOVA	R12, R14
	RLAM.A	#3, R14
	ADDA	R14, R12
	MOVA	R6, R14
	ADDA	#9, R14
	MOVA	R12, R9
	ADDA	R14, R9
	MOVX.W	&appTopText, R13
	MOV.W	#0,R14
	MOV.W	R13, 8(R1)
	MOV.W	R14, 10(R1)
	MOV.W	R13, 26(R1)
	MOVX.W	&appTopRam, R12
	MOV.W	#0,R13
	MOV.W	R12, 12(R1)
	MOV.W	R13, 14(R1)
	MOV.W	R12, 28(R1)
.L54:
	CMP.W	#1, R11 { JEQ	.L87
	CMP.W	#0, R11 { JNE	.L20
	CMP.B	#0, 6(R6) { JEQ	.L20
	MOV.B	3(R6), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	2(R6), R4
	BIS.W	R12, R4
	MOV.B	5(R6), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	4(R6), R5
	BIS.W	R12, R5
	MOVX.W	&appBottomText, R14
	MOV.W	R14,R12 { MOV.W	#0,R13
	MOV.W	R5, R10
	CMP.W	R5, R11 { JNE	.L58
	CMP.W	R12, R4 { JHS	.L58
.L21:
	MOV.B	1(R6), R15
	RPT	#8 { RLAX.W	R15
	MOV.B	@R6, R14
	BIS.W	R14, R15
	CMP.W	#0, R15 { JEQ	.L20
	MOV.B	8(R6), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	7(R6), R10
	BIS.W	R12, R10
	MOV.W	R10, 22(R1)
	MOVX.W	&appBottomRam, R14
	MOV.W	R14,R12 { MOV.W	#0,R13
	CMP.W	#0, R5 { JNE	.L59
	CMP.W	R12, R4 { JHS	.L59
.L26:
	MOVX.W	&appBottomText, R14
	MOV.W	R14,R12 { MOV.W	#0,R13
	MOV.W	R5, R10
	CMP.W	#0, R5 { JNE	.L61
	CMP.W	R12, R4 { JHS	.L61
.L29:
	CMPX.W	&appBottomROdata+2, R5 { JLO	.L39
	CMPX.W	R5, &appBottomROdata+2 { JEQ	.L88
	MOV.W	R15,R12 { MOV.W	#0,R13
	MOV.W	R4, R10
	ADD	R12, R10 ; cy
	MOV.W	R5, R12
	ADDC	R13, R12
	CMPX.W	R12, &appTopROdata+2 { JHS	.L89
.L39:
	CMPX.W	&vectorBottom+2, R5 { JLO	.L57
	CMPX.W	R5, &vectorBottom+2 { JEQ	.L90
.L66:
	MOV.W	R15,R12 { MOV.W	#0,R13
	MOV.W	R4, R10
	ADD	R12, R10 ; cy
	MOV.W	R5, R12
	ADDC	R13, R12
	CMPX.W	R12, &vectorTop+2 { JHS	.L91
.L57:
	MOV.B	#0, R12
.L95:
	; start of epilogue
	ADDA	#64, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
.L58:
	MOVX.W	&appTopText, R14
	MOV.W	R14,R12 { MOV.W	#0,R13
	MOV.W	R5, R10
	CMP.W	#0, R5 { JNE	.L21
	CMP.W	#0, R13 { JEQ	.L92
.L20:
	ADDA	#9, R6
	CMPA	R9, R6 { JNE	.L54
.L55:
	MOV.B	#1, R12
	; start of epilogue
	ADDA	#64, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
.L59:
	MOV.W	R15,R12 { MOV.W	#0,R13
	MOV.W	R4, R10
	ADD	R12, R10 ; cy
	MOV.W	R5, R12
	ADDC	R13, R12
	CMP.W	#0, R12 { JNE	.L26
	CMP.W	#0, 14(R1) { JNE	.L60
	CMP.W	R10, 28(R1) { JLO	.L26
.L60:
	PUSH.W	R5 { PUSH.W	R4 { POPM.A	#1, R4
	MOV.W	22(R1), R10
	MOV.W	R10,R12 { MOV.W	#0,R13
	MOV.W	R12, R14
	ADDX	&elfAddress, R14 ; cy
	MOV.W	R14, 60(R1)
	MOV.W	R13, R10
	ADDCX	&elfAddress+2, R10
	MOV.W	R10, 62(R1)
	MOV.W	60(R1), R12
	MOV.W	62(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R10
	MOV.W	R15, R14
	MOVA	R10, R13
	MOVA	R4, R12
	MOVA	R11, @R1
	CALLA	#memcpy
	MOVA	@R1, R11
	ADDA	#9, R6
	CMPA	R9, R6 { JNE	.L54
	BRA	#.L55
.L61:
	MOV.W	R15,R12 { MOV.W	#0,R13
	MOV.W	R4, R14
	MOV.W	R4, R10
	ADD	R12, R14 ; cy
	MOV.W	R14, 20(R1)
	MOV.W	R5, R14
	ADDC	R13, R14
	MOV.W	R14, 4(R1)
	CMP.W	#0, R14 { JNE	.L29
	CMP.W	#0, 10(R1) { JNE	.L62
	CMP.W	20(R1), 26(R1) { JLO	.L29
.L62:
	MOV.W	22(R1), R10
	MOV.W	R10,R12 { MOV.W	#0,R13
	MOV.W	R12, R14
	ADDX	&elfAddress, R14 ; cy
	MOV.W	R14, 34(R1)
	MOV.W	R13, R10
	ADDCX	&elfAddress+2, R10
	MOV.W	R10, 36(R1)
	MOV.W	34(R1), R12
	MOV.W	36(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R12
	MOVA	R12, 30(R1)
	PUSH.W	R5 { PUSH.W	R4 { POPM.A	#1, R13
	MOVA	R13, 22(R1)
	MOVX.W	#-23296, &FCTL3
	MOV.W	R4, R14
	AND.B	#3, R14
	MOV.W	R14, 38(R1)
	MOV.W	#0, 40(R1)
	MOV.W	38(R1), R13
	MOV.W	40(R1), R14
	PUSH.W	R14 { PUSH.W	R13 { POPM.A	#1, R12
	CMPA	#0, R12 { JNE	.L93
	MOVX.W	#-23168, &FCTL1
	MOV.W	R15, 42(R1)
	MOV.W	R15, R10
.L33:
	RRUM.W	#2, R10
	MOVA	30(R1), R14
	MOVA	22(R1), R12
	MOV.B	#0, R13
.L34:
	MOV.W	@R14+, @R12
	MOV.W	@R14+, 2(R12)
	ADDA	#4, R12
	ADD.W	#1, R13
	CMP.W	R10, R13 { JLO	.L34
	CMP.W	#0, R10 { JNE	.L36
	MOV.B	#1, R10
.L36:
	BITX.W	#3, 42(R1) { JEQ	.L37
	MOVX.W	#-23232, &FCTL1
	ADD.W	R10, R10
	MOV.W	R10, R12
	ADDA	R12, R12
	MOVA	30(R1), R14
	ADDA	R12, R14
	ADDX.A	22(R1), R12
	MOV.W	@R14, @R12
.L37:
	MOVA	16(R1), R14
	MOV.W	@R14, R14
	MOV.W	R14,R12 { MOV.W	#0,R13
	CMP.W	#0, 4(R1) { JEQ	.L94
.L63:
	MOV.W	R4, R13
	ADD.W	R15, R13
	MOVA	16(R1), R12
	MOV.W	R13, @R12
	BRA	#.L20
.L87:
	CMP.B	#1, 6(R6) { JNE	.L20
	MOV.B	3(R6), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	2(R6), R4
	BIS.W	R12, R4
	MOV.B	5(R6), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	4(R6), R5
	BIS.W	R12, R5
	MOVX.W	&appTopText, R14
	MOV.W	R14,R12 { MOV.W	#0,R13
	MOV.W	R5, R10
	CMP.W	#0, R5 { JNE	.L20
	CMP.W	R12, R4 { JLO	.L21
	ADDA	#9, R6
	CMPA	R9, R6 { JNE	.L54
	BRA	#.L55
.L92:
	CMP.W	R4, R12 { JLO	.L21
	ADDA	#9, R6
	CMPA	R9, R6 { JNE	.L54
	BRA	#.L55
.L88:
	CMPX.W	&appBottomROdata, R4 { JLO	.L39
	MOV.W	R15,R12 { MOV.W	#0,R13
	MOV.W	R4, R10
	ADD	R12, R10 ; cy
	MOV.W	R5, R12
	ADDC	R13, R12
	CMPX.W	R12, &appTopROdata+2 { JLO	.L39
	BRA	#.L89
.L90:
	CMPX.W	&vectorBottom, R4 { JHS	.L66
	MOV.B	#0, R12
	BRA	#.L95
.L89:
	CMPX.W	R12, &appTopROdata+2 { JNE	.L65
	CMPX.W	R10, &appTopROdata { JLO	.L39
.L65:
	MOV.W	22(R1), R10
	MOV.W	R10,R12 { MOV.W	#0,R13
	MOV.W	R12, R14
	ADDX	&elfAddress, R14 ; cy
	MOV.W	R14, 44(R1)
	MOV.W	R13, R10
	ADDCX	&elfAddress+2, R10
	MOV.W	R10, 46(R1)
	MOV.W	44(R1), R12
	MOV.W	46(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R12
	MOVA	R12, 4(R1)
	PUSH.W	R5 { PUSH.W	R4 { POPM.A	#1, R5
	MOVX.W	#-23296, &FCTL3
	MOV.W	R4, R13
	AND.B	#3, R13
	MOV.W	R13, 48(R1)
	MOV.W	#0, 50(R1)
	MOV.W	48(R1), R13
	MOV.W	50(R1), R14
	PUSH.W	R14 { PUSH.W	R13 { POPM.A	#1, R12
	CMPA	#0, R12 { JNE	.L96
	MOVX.W	#-23168, &FCTL1
.L43:
	MOV.W	R15, R10
	RRUM.W	#2, R10
	MOVA	4(R1), R14
	MOVA	R5, R12
	MOV.B	#0, R13
.L44:
	MOV.W	@R14+, @R12
	MOV.W	@R14+, 2(R12)
	ADDA	#4, R12
	ADD.W	#1, R13
	CMP.W	R10, R13 { JLO	.L44
	CMP.W	#0, R10 { JNE	.L46
	MOV.B	#1, R10
.L46:
	BIT.W	#3, R15 { JEQ	.L20
	MOVX.W	#-23232, &FCTL1
	ADD.W	R10, R10
	MOV.W	R10, R12
.L84:
	ADDA	R12, R12
	MOVA	4(R1), R14
	ADDA	R12, R14
	ADDA	R5, R12
	MOV.W	@R14, @R12
	ADDA	#9, R6
	CMPA	R9, R6 { JNE	.L54
	BRA	#.L55
.L91:
	CMPX.W	R12, &vectorTop+2 { JNE	.L67
	CMPX.W	R10, &vectorTop { JLO	.L57
.L67:
	MOV.W	22(R1), R10
	MOV.W	R10,R12 { MOV.W	#0,R13
	MOV.W	R12, R14
	ADDX	&elfAddress, R14 ; cy
	MOV.W	R14, 52(R1)
	MOV.W	R13, R10
	ADDCX	&elfAddress+2, R10
	MOV.W	R10, 54(R1)
	MOV.W	52(R1), R12
	MOV.W	54(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R12
	MOVA	R12, 4(R1)
	PUSH.W	R5 { PUSH.W	R4 { POPM.A	#1, R5
	MOVX.W	#-23296, &FCTL3
	MOV.W	R4, R13
	AND.B	#3, R13
	MOV.W	R13, 56(R1)
	MOV.W	#0, 58(R1)
	MOV.W	56(R1), R13
	MOV.W	58(R1), R14
	PUSH.W	R14 { PUSH.W	R13 { POPM.A	#1, R12
	CMPA	#0, R12 { JNE	.L97
	MOVX.W	#-23168, &FCTL1
.L50:
	MOV.W	R15, R10
	RRUM.W	#2, R10
	MOVA	4(R1), R14
	MOVA	R5, R12
	MOV.B	#0, R13
.L51:
	MOV.W	@R14+, @R12
	MOV.W	@R14+, 2(R12)
	ADDA	#4, R12
	ADD.W	#1, R13
	CMP.W	R10, R13 { JLO	.L51
	CMP.W	#0, R10 { JEQ	.L52
	MOV.W	R10, R12
.L53:
	BIT.W	#3, R15 { JEQ	.L20
	MOVX.W	#-23232, &FCTL1
	ADD.W	R12, R12
	MOV.W	R12, R12
	BRA	#.L84
.L93:
	MOVX.W	#-23232, &FCTL1
	MOVA	22(R1), R12
	MOVA	30(R1), R13
	ADDX.A	#2, 30(R1)
	MOV.W	@R13+, @R12
	ADDA	#2, R12
	MOVA	R12, 22(R1)
	MOV.W	R15, R14
	ADD.W	#-2, R14
	MOV.W	R14, 42(R1)
	MOV.W	R14, R10
	BRA	#.L33
.L96:
	MOVX.W	#-23232, &FCTL1
	MOVA	4(R1), R12
	ADDX.A	#2, 4(R1)
	MOV.W	@R12+, @R5
	ADDA	#2, R5
	ADD.W	#-2, R15
	BRA	#.L43
.L97:
	MOVX.W	#-23232, &FCTL1
	MOVA	4(R1), R12
	ADDX.A	#2, 4(R1)
	MOV.W	@R12+, @R5
	ADDA	#2, R5
	ADD.W	#-2, R15
	BRA	#.L50
.L94:
	CMP.W	#0, R13 { JNE	.L20
	CMP.W	20(R1), R12 { JHS	.L20
	BRA	#.L63
.L52:
	MOV.B	#1, R12
	BRA	#.L53
	.size	deploy, .-deploy
	.balign 2
	.global	load_elf_segment
	.type	load_elf_segment, @function
load_elf_segment:
; start of function
; attributes: 
; framesize_regs:     20
; framesize_locals:   22
; framesize_outgoing: 0
; framesize:          42
; elim ap -> fp       24
; elim fp -> sp       22
; saved regs: R4 R5 R6 R9 R10
	; start of prologue
	PUSHM.A	#2, R10
	PUSHM.A	#3, R6
	SUBA	#22, R1
	; end of prologue
	MOV.W	R12, R9
	MOV.W	R13, R6
	MOVA	R15, @R1
	MOV.B	1(R14), R15
	RPT	#8 { RLAX.W	R15
	MOV.B	@R14, R10
	BIS.W	R10, R15
	CMP.W	#0, R15 { JEQ	.L153
	MOV.B	3(R14), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	2(R14), R10
	BIS.W	R12, R10
	MOV.B	5(R14), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	4(R14), R11
	BIS.W	R12, R11
	MOV.B	8(R14), R13
	RPT	#8 { RLAX.W	R13
	MOV.B	7(R14), R14
	BIS.W	R14, R13
	MOVX.W	&appBottomRam, R12
	MOV.W	R12,R4 { MOV.W	#0,R5
	CMP.W	#0, R11 { JEQ	.L160
.L132:
	MOV.W	R15,R4 { MOV.W	#0,R5
	MOV.W	R4, R12
	ADD	R10, R12 ; cy
	MOV.W	R12, 8(R1)
	MOV.W	R5, R14
	ADDC	R11, R14
	MOVX.W	&appTopRam, R12
	MOV.W	R12,R4 { MOV.W	#0,R5
	CMP.W	#0, R14 { JEQ	.L161
.L101:
	MOVX.W	&appBottomText, R12
	MOV.W	R12,R4 { MOV.W	#0,R5
	CMP.W	#0, R11 { JNE	.L134
	CMP.W	R4, R10 { JHS	.L134
.L104:
	CMPX.W	&appBottomROdata+2, R11 { JLO	.L115
	CMPX.W	R11, &appBottomROdata+2 { JEQ	.L162
.L137:
	MOV.W	R15,R4 { MOV.W	#0,R5
	MOV.W	R4, R12
	ADD	R10, R12 ; cy
	MOV.W	R5, R14
	ADDC	R11, R14
	CMPX.W	R14, &appTopROdata+2 { JHS	.L163
.L115:
	CMPX.W	&vectorBottom+2, R11 { JLO	.L131
	CMPX.W	R11, &vectorBottom+2 { JEQ	.L164
.L139:
	MOV.W	R15,R4 { MOV.W	#0,R5
	MOV.W	R4, R12
	ADD	R10, R12 ; cy
	MOV.W	R5, R14
	ADDC	R11, R14
	CMPX.W	R14, &vectorTop+2 { JHS	.L165
.L131:
	MOV.B	#0, R12
.L169:
	; start of epilogue
	ADDA	#22, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
.L165:
	CMPX.W	R14, &vectorTop+2 { JNE	.L140
	CMPX.W	R12, &vectorTop { JLO	.L131
.L140:
	MOV.W	R13,R12 { MOV.W	#0,R13
	ADD	R12, R9 ; cy
	MOV.W	R9, 18(R1)
	ADDC	R13, R6
	MOV.W	R6, 20(R1)
	MOV.W	18(R1), R12
	MOV.W	20(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R6
	PUSH.W	R11 { PUSH.W	R10 { POPM.A	#1, R14
	MOVX.W	#-23296, &FCTL3
	MOV.W	R10, R12
	AND.B	#3, R12
	MOV.B	#0, R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R12
	CMPA	#0, R12 { JNE	.L166
	MOVX.W	#-23168, &FCTL1
.L126:
	MOV.W	R15, R9
	RRUM.W	#2, R9
	MOVA	R6, R10
	MOVA	R14, R12
	MOV.B	#0, R13
.L127:
	MOV.W	@R10+, @R12
	MOV.W	@R10+, 2(R12)
	ADDA	#4, R12
	ADD.W	#1, R13
	CMP.W	R9, R13 { JLO	.L127
.L158:
	CMP.W	#0, R9 { JEQ	.L128
	MOV.W	R9, R12
.L129:
	BIT.W	#3, R15 { JEQ	.L153
	MOVX.W	#-23232, &FCTL1
	ADD.W	R12, R12
	MOV.W	R12, R12
	ADDA	R12, R12
	ADDA	R12, R6
	ADDA	R12, R14
	MOV.W	@R6, @R14
.L153:
	MOV.B	#1, R12
.L100:
	; start of epilogue
	ADDA	#22, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
.L134:
	MOV.W	R15,R4 { MOV.W	#0,R5
	MOV.W	R4, R12
	ADD	R10, R12 ; cy
	MOV.W	R12, 8(R1)
	MOV.W	R5, R14
	ADDC	R11, R14
	MOV.W	R14, 4(R1)
	MOVX.W	&appTopText, R12
	MOV.W	R12,R4 { MOV.W	#0,R5
	CMP.W	#0, R14 { JNE	.L104
	CMP.W	#0, R5 { JNE	.L135
	CMP.W	8(R1), R4 { JLO	.L104
.L135:
	MOV.W	R13,R12 { MOV.W	#0,R13
	ADD	R12, R9 ; cy
	MOV.W	R9, 10(R1)
	ADDC	R13, R6
	MOV.W	R6, 12(R1)
	MOV.W	10(R1), R12
	MOV.W	12(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R9
	PUSH.W	R11 { PUSH.W	R10 { POPM.A	#1, R4
	MOVX.W	#-23296, &FCTL3
	MOV.W	R10, R12
	AND.B	#3, R12
	MOV.B	#0, R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R12
	CMPA	#0, R12 { JNE	.L167
	MOVX.W	#-23168, &FCTL1
	MOV.W	R15, R5
.L108:
	MOV.W	R5, R6
	RRUM.W	#2, R6
	MOVA	R9, R14
	MOVA	R4, R12
	MOV.B	#0, R13
.L109:
	MOV.W	@R14+, @R12
	MOV.W	@R14+, 2(R12)
	ADDA	#4, R12
	ADD.W	#1, R13
	CMP.W	R6, R13 { JLO	.L109
	CMP.W	#0, R6 { JEQ	.L110
	MOV.W	R6, R12
.L111:
	BIT.W	#3, R5 { JEQ	.L112
	MOVX.W	#-23232, &FCTL1
	ADD.W	R12, R12
	MOV.W	R12, R12
	ADDA	R12, R12
	MOVA	R9, R14
	ADDA	R12, R14
	ADDA	R4, R12
	MOV.W	@R14, @R12
.L112:
	MOVA	@R1, R14
	MOV.W	@R14, R14
	MOV.W	R14,R12 { MOV.W	#0,R13
	CMP.W	#0, 4(R1) { JEQ	.L168
.L136:
	ADD.W	R10, R15
	MOVA	@R1, R12
	MOV.W	R15, @R12
	MOV.B	#1, R12
	BRA	#.L100
.L160:
	CMP.W	R4, R10 { JLO	.L101
	BRA	#.L132
.L162:
	CMPX.W	&appBottomROdata, R10 { JLO	.L115
	BRA	#.L137
.L164:
	CMPX.W	&vectorBottom, R10 { JHS	.L139
	MOV.B	#0, R12
	BRA	#.L169
.L163:
	CMPX.W	R14, &appTopROdata+2 { JNE	.L138
	CMPX.W	R12, &appTopROdata { JLO	.L115
.L138:
	MOV.W	R13,R12 { MOV.W	#0,R13
	ADD	R12, R9 ; cy
	MOV.W	R9, 14(R1)
	ADDC	R13, R6
	MOV.W	R6, 16(R1)
	MOV.W	14(R1), R13
	MOV.W	16(R1), R14
	PUSH.W	R14 { PUSH.W	R13 { POPM.A	#1, R6
	PUSH.W	R11 { PUSH.W	R10 { POPM.A	#1, R14
	MOVX.W	#-23296, &FCTL3
	MOV.W	R10, R12
	AND.B	#3, R12
	MOV.B	#0, R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R12
	CMPA	#0, R12 { JNE	.L170
	MOVX.W	#-23168, &FCTL1
.L119:
	MOV.W	R15, R9
	RRUM.W	#2, R9
	MOVA	R6, R10
	MOVA	R14, R12
	MOV.B	#0, R13
.L120:
	MOV.W	@R10+, @R12
	MOV.W	@R10+, 2(R12)
	ADDA	#4, R12
	ADD.W	#1, R13
	CMP.W	R9, R13 { JLO	.L120
	BRA	#.L158
.L161:
	CMP.W	#0, R5 { JNE	.L133
	CMP.W	8(R1), R4 { JLO	.L101
.L133:
	PUSH.W	R11 { PUSH.W	R10 { POPM.A	#1, R12
	MOV.W	R13,R4 { MOV.W	#0,R5
	MOV.W	R4, R10
	ADD	R9, R10 ; cy
	MOV.W	R10, 4(R1)
	MOV.W	R5, R11
	ADDC	R6, R11
	MOV.W	R11, 6(R1)
	MOV.W	4(R1), R10
	MOV.W	6(R1), R11
	PUSH.W	R11 { PUSH.W	R10 { POPM.A	#1, R13
	MOV.W	R15, R14
	CALLA	#memcpy
	MOV.B	#1, R12
	BRA	#.L100
.L167:
	MOVX.W	#-23232, &FCTL1
	MOV.W	@R9+, @R4
	ADDA	#2, R4
	MOV.W	R15, R5
	ADD.W	#-2, R5
	BRA	#.L108
.L170:
	MOVX.W	#-23232, &FCTL1
	MOV.W	@R6+, @R14
	ADDA	#2, R14
	ADD.W	#-2, R15
	BRA	#.L119
.L166:
	MOVX.W	#-23232, &FCTL1
	MOV.W	@R6+, @R14
	ADDA	#2, R14
	ADD.W	#-2, R15
	BRA	#.L126
.L128:
	MOV.B	#1, R12
	BRA	#.L129
.L110:
	MOV.B	#1, R12
	BRA	#.L111
.L168:
	CMP.W	#0, R13 { JNE	.L153
	CMP.W	8(R1), R12 { JHS	.L153
	BRA	#.L136
	.size	load_elf_segment, .-load_elf_segment
	.section	.tcm:code
	.balign 2
	.global	launchVerification
	.type	launchVerification, @function
launchVerification:
; start of function
; attributes: 
; framesize_regs:     20
; framesize_locals:   10
; framesize_outgoing: 0
; framesize:          30
; elim ap -> fp       24
; elim fp -> sp       10
; saved regs: R4 R5 R6 R9 R10
	; start of prologue
	PUSHM.A	#2, R10
	PUSHM.A	#3, R6
	SUBA	#10, R1
	; end of prologue
	MOV.W	R12, R9
	BISX.B	#1, &PAOUT_L
	MOVX.W	&appBottomText, R5
	MOVA	#verify, R6
	MOV.B	#0, R14
	MOV.W	R12, R13
	MOV.W	R5, R12
	CALLA	R6
	MOV.B	R12, R10
	MOV.B	#1, R14
	MOV.W	R9, R13
	MOV.W	R5, R12
	CALLA	R6
	BIS.B	R10, R12
	CMP.B	#0, R12 { JNE	.L172
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23292, &FCTL1
	MOVA	&appBottomROdata, R12
	MOV.W	#0, @R12
.L173:
	BITX.W	#1, &FCTL3 { JNE	.L173
	MOV.W	R9, R6
	MOVX.W	&elfAddress, R13
	MOVX.W	&elfAddress+2, R14
	PUSH.W	R14 { PUSH.W	R13 { POPM.A	#1, R12
	MOV.B	@R12, R10
	CMP.B	#0, @R12 { JEQ	.L175
	ADD	#1, R13 ; cy
	MOV.W	R13, @R1
	ADDC	#0, R14
	MOV.W	R14, 2(R1)
	MOV.W	@R1, R12
	MOV.W	2(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R4
	ADD.B	#-1, R10
	MOV.B	R10, R10
	MOVA	R10, R12
	RLAM.A	#3, R12
	ADDA	R12, R10
	MOVA	R4, R12
	ADDA	#9, R12
	ADDA	R12, R10
	MOV.W	R5,R13 { MOV.W	#0,R14
	MOV.W	R13, @R1
	MOV.W	R14, 2(R1)
	MOVA	#load_elf_segment, R9
	MOVX.W	&appTopText, R12
	MOV.W	#0,R13
	MOV.W	R12, 4(R1)
	MOV.W	R13, 6(R1)
	MOV.W	R12, 8(R1)
.L177:
	CMP.B	#0, 6(R4) { JEQ	.L181
	MOV.B	3(R4), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	2(R4), R13
	BIS.W	R12, R13
	MOV.B	5(R4), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	4(R4), R14
	BIS.W	R14, R12
	CMP.W	2(R1), R12 { JLO	.L179
	CMP.W	#0, R12 { JNE	.L179
	CMP.W	R5, R13 { JHS	.L188
.L179:
	MOVA	R6, R15
	MOVA	R4, R14
	MOVX.W	&elfAddress, R12
	MOVX.W	&elfAddress+2, R13
	CALLA	R9
	CMP.B	#0, R12 { JEQ	.L189
.L181:
	ADDA	#9, R4
	CMPA	R10, R4 { JNE	.L177
.L175:
	CALLA	#launchAppCode
.L190:
	; start of epilogue
	ADDA	#10, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
.L172:
 ; 318 "core/src_compile/secureUpdate.c" 1
	
	BR #secureUpdate
 ; 0 "" 2
	; start of epilogue
	ADDA	#10, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
.L188:
	CMP.W	#0, R12 { JNE	.L179
	CMP.W	6(R1), R12 { JNE	.L181
	CMP.W	R13, 8(R1) { JHS	.L181
	BRA	#.L179
.L189:
	MOVX.W	#6, &WDTCTL
	CALLA	#launchAppCode
	BRA	#.L190
	.size	launchVerification, .-launchVerification
	.balign 2
	.global	secureUpdate
	.type	secureUpdate, @function
secureUpdate:
; start of function
; attributes: 
; framesize_regs:     20
; framesize_locals:   616
; framesize_outgoing: 0
; framesize:          636
; elim ap -> fp       24
; elim fp -> sp       616
; saved regs: R4 R5 R6 R9 R10
	; start of prologue
	PUSHM.A	#2, R10
	PUSHM.A	#3, R6
	SUBA	#616, R1
	; end of prologue
	MOVX.W	#23168, &WDTCTL
 ; 56 "core/src_compile/secureUpdate.c" 1
	dint { nop
 ; 0 "" 2
	MOVX.B	&update_cnt, R12
	MOV.B	#16, R13
	CMP.B	R12, R13 { JHS	.L260
	; start of epilogue
	ADDA	#616, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
.L260:
 ; 60 "core/src_compile/secureUpdate.c" 1
	mov.w r8, &write_count_lee_secureUpdate
 ; 0 "" 2
	ADDX.W	&write_count_lee_secureUpdate, &tmp_write_count_lee_value
	MOVX.W	#0, &rcvBufCount
	MOV.W	#512, R14
	MOV.B	#0, R13
	MOVA	#rcvBuf, R12
	CALLA	#memset
	BISX.B	#48, &PBSEL_H
	BISX.B	#1, &UCA1CTLW0_L
	BISX.B	#64, &UCA1CTLW0_L
	MOVX.B	#3, &UCA1BRW_L
	MOVX.B	#-42, &UCA1MCTL
	MOVX.B	#0, &UCA1CTLW0_H
	BICX.B	#1, &UCA1CTLW0_L
	BISX.B	#1, &UCA1ICTL_L
	BISX.B	#-128, &PBDIR_H
	ANDX.B	#127, &PBOUT_H
	BICX.B	#1, &PAOUT_L
	MOVA	#write_count_lee_secureUpdate_bytes, R13
	MOVX.W	&write_count_lee_secureUpdate, R12
	CALLA	#uint16_to_bytes
	MOV.B	#2, R13
	MOVA	#write_count_lee_secureUpdate_bytes, R12
	CALLA	#uart_send_hex_data
 ; 97 "core/src_compile/secureUpdate.c" 1
	mov.w &tmp_write_count_lee_value, r8
 ; 0 "" 2
	MOVX.W	&elfAddress, R14
	MOVX.W	&elfAddress+2, R15
	PUSH.W	R15 { PUSH.W	R14 { POPM.A	#1, R12
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23292, &FCTL1
	MOV.W	#0, @R12
.L193:
	BITX.W	#1, &FCTL3 { JNE	.L193
	MOVA	R1, R15
	ADDA	#44, R15
	MOVA	R15, @R1
	MOVA	R1, R6
	ADDA	#330, R6
	MOVA	R15, R14
	MOV.W	#65024, R10
	SUBA	R15, R10
.L194:
	MOVA	R14, R12
	ADDA	R10, R12
	MOV.W	@R12, @R14
	ADDA	#2, R14
	CMPA	R6, R14 { JNE	.L194
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23294, &FCTL1
	MOV.W	#0, &65024
.L195:
	MOVX.W	&FCTL3, R12
	AND.B	#1, R12
	MOV.W	R12, 40(R1)
	BITX.W	#1, &FCTL3 { JNE	.L195
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23232, &FCTL1
	MOVA	#INTERRUPT_ISR, R12
	MOV.W	R12, &65500
	MOV.W	#-15360, &65534
	MOVA	R1, R14
	ADDA	#44, R14
.L196:
	MOVA	R10, R12
	ADDA	R14, R12
	MOV.W	@R14+, @R12
	CMPA	R14, R6 { JNE	.L196
 ; 152 "core/src_compile/secureUpdate.c" 1
	nop { eint { nop
 ; 0 "" 2
	BISX.B	#-128, &PBOUT_H
	MOV.W	40(R1), R5
	MOV.W	#-512, R11
	MOV.W	#0, 4(R1)
	MOV.W	#0, 6(R1)
	MOVX	&appBottomText, R13
	MOVA	R13, 30(R1)
	MOVA	@R1, R14
	MOVX	R14, 34(R1)
	MOVA	#oldISR+128, R4
	MOVX.W	&appTopText, R12
	MOV.W	#0,R13
	MOV.W	R12, 8(R1)
	MOV.W	R13, 10(R1)
	MOVX.W	&elfAddress, R13
	ADD	#1, R13 ; cy
	MOV.W	R13, 36(R1)
	MOVX.W	&elfAddress+2, R14
	ADDC	#0, R14
	MOV.W	R14, 38(R1)
.L197:
	MOVX.W	&rcvBufCount, R12
	CMP.W	#2, R12 { JEQ	.L261
	MOV.W	#0, 12(R1)
.L198:
	MOV.W	R5,R12 { MOV.W	#0,R13
	MOV.W	R12, 14(R1)
	MOV.W	R13, 16(R1)
.L200:
	MOVX.W	&rcvBufCount, R12
	CMP.W	#512, R12 { JEQ	.L202
	MOVX.W	&rcvBufCount, R12
	MOV.W	#0,R13
	ADDX	4(R1), R12 ; cy
	ADDCX	6(R1), R13
	CMP.W	R5, R12 { JEQ	.L262
.L203:
	CMP.W	#0, 12(R1) { JEQ	.L197
	MOV.W	6(R1), R12
	CMP.W	16(R1), R12 { JLO	.L200
	CMP.W	#0, R12 { JNE	.L228
	MOV.W	4(R1), R12
	CMP.W	14(R1), R12 { JLO	.L200
.L228:
	ANDX.B	#127, &PBOUT_H
	MOV.W	#0, 42(R1)
	BICX.B	#1, &UCA1ICTL_L
 ; 208 "core/src_compile/secureUpdate.c" 1
	dint { nop
 ; 0 "" 2
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23292, &FCTL1
	MOVA	30(R1), R12
	MOV.W	#0, @R12
.L214:
	MOVX.W	&FCTL3, R13
	AND.B	#1, R13
	BITX.W	#1, &FCTL3 { JNE	.L214
	MOVX.W	&appBottomROdata, R14
	MOVX.W	&appBottomROdata+2, R15
	PUSH.W	R15 { PUSH.W	R14 { POPM.A	#1, R12
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23292, &FCTL1
	MOV.W	R13, @R12
.L215:
	MOVX.W	&FCTL3, R13
	AND.B	#1, R13
	BITX.W	#1, &FCTL3 { JNE	.L215
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23294, &FCTL1
	MOV.W	R11, R12
	MOV.W	R13, @R12
.L216:
	BITX.W	#1, &FCTL3 { JNE	.L216
	MOVX.W	#-23296, &FCTL3
	MOVX.W	#-23168, &FCTL1
	MOVA	R1, R12
	ADDA	#44, R12
	SUB.W	34(R1), R11
.L217:
	MOVX	R12, R14
	ADD.W	R11, R14
	MOV.W	R14, R14
	MOV.W	@R12+, @R14
	CMPA	R6, R12 { JNE	.L217
	MOVA	#oldISR, R14
	MOVX	R14, R12
	MOV.W	#-128, R13 { SUB.W	R12, R13
.L218:
	MOVX	R14, R12
	ADD.W	R13, R12
	MOV.W	R12, R12
	MOV.W	@R14+, @R12
	MOV.W	@R14+, 2(R12)
	CMPA	R14, R4 { JNE	.L218
	MOVX.W	&elfAddress, R12
	MOVX.W	&elfAddress+2, R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R14
	MOV.B	@R14, R12
	CMP.B	#0, @R14 { JEQ	.L220
	MOV.W	36(R1), R13
	MOV.W	38(R1), R14
	PUSH.W	R14 { PUSH.W	R13 { POPM.A	#1, R10
	ADD.B	#-1, R12
	MOV.B	R12, R12
	MOVA	R12, R14
	RLAM.A	#3, R14
	ADDA	R14, R12
	MOVA	R10, R14
	ADDA	#9, R14
	MOVA	R12, R9
	ADDA	R14, R9
.L222:
	CMP.B	#1, 6(R10) { JEQ	.L221
.L224:
	ADDA	#9, R10
	CMPA	R10, R9 { JNE	.L222
.L220:
	MOV.W	42(R1), R12
	CALLA	#launchVerification
	MOV.W	#-128, R11
	BRA	#.L200
.L221:
	MOV.B	3(R10), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	2(R10), R13
	BIS.W	R12, R13
	MOV.B	5(R10), R12
	RPT	#8 { RLAX.W	R12
	MOV.B	4(R10), R14
	BIS.W	R14, R12
	CMP.W	10(R1), R12 { JLO	.L229
	MOV.B	#0, R15
	CMP.W	R12, R15 { JNE	.L224
	CMP.W	8(R1), R13 { JHS	.L224
.L229:
	MOVA	R1, R15
	ADDA	#42, R15
	MOVA	R10, R14
	MOVX.W	&elfAddress, R12
	MOVX.W	&elfAddress+2, R13
	CALLA	#load_elf_segment
	CMP.B	#0, R12 { JNE	.L224
 ; 259 "core/src_compile/secureUpdate.c" 1
	
	BR #secureUpdate
 ; 0 "" 2
	MOV.W	42(R1), R12
	CALLA	#launchVerification
	MOV.W	#-128, R11
	BRA	#.L200
.L262:
	CMP.W	16(R1), R13 { JNE	.L203
	CMP.W	#0, 12(R1) { JEQ	.L197
.L202:
	MOVX.W	&rcvBufCount, R10
	MOV.W	4(R1), R13
	ADDX	&elfAddress, R13 ; cy
	MOV.W	R13, 18(R1)
	MOV.W	6(R1), R14
	ADDCX	&elfAddress+2, R14
	MOV.W	R14, 20(R1)
	MOV.W	18(R1), R12
	MOV.W	20(R1), R13
	PUSH.W	R13 { PUSH.W	R12 { POPM.A	#1, R9
	MOVX.W	#-23296, &FCTL3
	AND.B	#3, R12
	MOV.W	R12, 22(R1)
	MOV.W	#0, 24(R1)
	MOV.W	22(R1), R13
	MOV.W	24(R1), R14
	PUSH.W	R14 { PUSH.W	R13 { POPM.A	#1, R12
	CMPA	#0, R12 { JEQ	.L205
	MOVX.W	#-23232, &FCTL1
	MOVX.B	&rcvBuf+1, R12
	RPT	#8 { RLAX.W	R12
	MOVA	#rcvBuf, R14
	MOV.B	@R14, R15
	BIS.W	R12, R15
	MOV.W	R15, @R9
	ADDA	#2, R9
	ADD.W	#-2, R10
	MOVX.A	#rcvBuf+2, 26(R1)
.L206:
	MOV.W	R10, R15
	RRUM.W	#2, R15
	MOVA	26(R1), R14
	MOVA	R9, R12
	MOV.W	40(R1), R13
.L207:
	MOV.W	@R14+, @R12
	MOV.W	@R14+, 2(R12)
	ADDA	#4, R12
	ADD.W	#1, R13
	CMP.W	R15, R13 { JLO	.L207
	CMP.W	#0, R15 { JEQ	.L208
	MOV.W	R15, R12
.L209:
	BIT.W	#3, R10 { JEQ	.L210
	MOVX.W	#-23232, &FCTL1
	ADD.W	R12, R12
	MOV.W	R12, R12
	ADDA	R12, R12
	MOVA	26(R1), R14
	ADDA	R12, R14
	ADDA	R9, R12
	MOV.W	@R14, @R12
.L210:
	MOVX.W	&rcvBufCount, R12
	MOV.W	#0,R13
	MOV.W	4(R1), R14
	MOV.W	6(R1), R15
	ADD	R12, R14 ; cy
	ADDC	R13, R15
	MOV.W	R14, 4(R1)
	MOV.W	R15, 6(R1)
	MOVX.W	#0, &rcvBufCount
	BISX.B	#1, &UCA1ICTL_L
	MOVX.B	#84, &UCA1TXBUF
.L211:
	BITX.B	#2, &UCA1ICTL_H { JNE	.L203
	BITX.B	#1, &UCA1STAT { JNE	.L211
	BRA	#.L203
.L208:
	MOV.B	#1, R12
	BRA	#.L209
.L205:
	MOVX.W	#-23168, &FCTL1
	MOVX.A	#rcvBuf, 26(R1)
	BRA	#.L206
.L261:
	MOVA	#rcvBuf, R15
	MOV.B	@R15, R13
	MOVX.B	&rcvBuf+1, R12
	RPT	#8 { RLAX.W	R13
	MOV.W	R13, R5
	BIS.W	R12, R5
	MOVX.W	#0, &rcvBufCount
	MOVX.B	#84, &UCA1TXBUF
.L201:
	BITX.B	#2, &UCA1ICTL_H { JNE	.L259
	BITX.B	#1, &UCA1STAT { JNE	.L201
.L259:
	MOV.W	#1, 12(R1)
	BRA	#.L198
	.size	secureUpdate, .-secureUpdate
	.global	write_count_lee_secureUpdate_bytes
	.section .bss
	.type	write_count_lee_secureUpdate_bytes, @object
	.size	write_count_lee_secureUpdate_bytes, 2
write_count_lee_secureUpdate_bytes:
	.zero	2
	.global	tmp_write_count_lee_value
	.balign 2
	.type	tmp_write_count_lee_value, @object
	.size	tmp_write_count_lee_value, 2
tmp_write_count_lee_value:
	.zero	2
	.global	write_count_lee_secureUpdate
	.balign 2
	.type	write_count_lee_secureUpdate, @object
	.size	write_count_lee_secureUpdate, 2
write_count_lee_secureUpdate:
	.zero	2
	.global	rcvBufCount
	.balign 2
	.type	rcvBufCount, @object
	.size	rcvBufCount, 2
rcvBufCount:
	.zero	2
	.global	rcvBuf
	.type	rcvBuf, @object
	.size	rcvBuf, 512
rcvBuf:
	.zero	512
	.global	oldISR
	.section	.tcm:rodata,"a"
	.balign 2
	.type	oldISR, @object
	.size	oldISR, 128
oldISR:
	.long	-133629952
	.long	-132581360
	.long	-131532768
	.long	-130484176
	.long	-129435584
	.long	-128386992
	.long	-127338400
	.long	-126289808
	.long	-125241216
	.long	-124192624
	.long	-123144032
	.long	-122095440
	.long	-121046848
	.long	-119998256
	.long	-118949664
	.long	-117901072
	.long	-116852480
	.long	-115803888
	.long	-114755296
	.long	-113706704
	.long	-112658112
	.long	-111609520
	.long	-110560928
	.long	-109512336
	.long	-108463744
	.long	-107415152
	.long	-106366560
	.long	-105317968
	.long	-104269376
	.long	-103220784
	.long	-102172192
	.long	-1006568976
	.global	dataLengthBytes
	.type	dataLengthBytes, @object
	.size	dataLengthBytes, 1
dataLengthBytes:
	.byte	2
	.global	update_cnt
	.section .bss
	.type	update_cnt, @object
	.size	update_cnt, 1
update_cnt:
	.zero	1
	.ident	"GCC: (Mitto Systems Limited - msp430-gcc 9.2.0.50) 9.2.0"
	.mspabi_attribute 4, 2
	.mspabi_attribute 6, 2
	.mspabi_attribute 8, 2
	.gnu_attribute 4, 2
