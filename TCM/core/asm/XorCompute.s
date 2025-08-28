	.file	"XorCompute.c"
.text
	.section	.tcm:codeUpper,"ax",@progbits
	.balign 2
	.global	uint8_to_bytes
	.type	uint8_to_bytes, @function
uint8_to_bytes:
; start of function
; attributes: 
; framesize_regs:     0
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          0
; elim ap -> fp       4
; elim fp -> sp       0
; saved regs:(none)
	; start of prologue
	; end of prologue
	; start of epilogue
	RETA
	.size	uint8_to_bytes, .-uint8_to_bytes
	.balign 2
	.global	uint16_to_bytes
	.type	uint16_to_bytes, @function
uint16_to_bytes:
; start of function
; attributes: 
; framesize_regs:     0
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          0
; elim ap -> fp       4
; elim fp -> sp       0
; saved regs:(none)
	; start of prologue
	; end of prologue
	MOVA	R13, R14
	MOV.W	R12, R13
	RPT	#8 { RRUX.W	R13
	MOV.B	R13, @R14
	MOV.B	R12, 1(R14)
	; start of epilogue
	RETA
	.size	uint16_to_bytes, .-uint16_to_bytes
	.balign 2
	.global	uint32_to_bytes
	.type	uint32_to_bytes, @function
uint32_to_bytes:
; start of function
; attributes: 
; framesize_regs:     4
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          4
; elim ap -> fp       8
; elim fp -> sp       0
; saved regs: R10
	; start of prologue
	PUSHM.A	#1, R10
	; end of prologue
	MOV.W	R13, R15
	RPT	#8 { RRUX.W	R15
	MOV.B	R15, @R14
	MOV.B	R13, 1(R14)
	MOV.W	R12, R10
	MOV.W	R13, R11
	CLRC { RRC.W	R11 { RRC.W	R10
	CLRC { RRC.W	R11 { RRC.W	R10
	CLRC { RRC.W	R11 { RRC.W	R10
	CLRC { RRC.W	R11 { RRC.W	R10
	CLRC { RRC.W	R11 { RRC.W	R10
	CLRC { RRC.W	R11 { RRC.W	R10
	CLRC { RRC.W	R11 { RRC.W	R10
	CLRC { RRC.W	R11 { RRC.W	R10
	MOV.B	R10, 2(R14)
	MOV.B	R12, 3(R14)
	; start of epilogue
	POPM.A	#1, r10
	RETA
	.size	uint32_to_bytes, .-uint32_to_bytes
	.balign 2
	.global	uint64_to_bytes
	.type	uint64_to_bytes, @function
uint64_to_bytes:
; start of function
; attributes: 
; framesize_regs:     20
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          20
; elim ap -> fp       24
; elim fp -> sp       0
; saved regs: R4 R5 R6 R9 R10
	; start of prologue
	PUSHM.A	#2, R10
	PUSHM.A	#3, R6
	; end of prologue
	MOV.W	R12, R6
	MOV.W	R15, R5
	MOVA	24(R1), R4
	MOV.W	R12, R8
	MOV.W	R13, R9
	MOV.W	R14, R10
	MOV.W	R15, R11
	MOV.B	#56, R12
	CALLA	#__mspabi_srlll
	MOV.B	R12, @R4
	MOV.W	R6, R8
	MOV.W	R5, R11
	MOV.B	#48, R12
	CALLA	#__mspabi_srlll
	MOV.B	R12, 1(R4)
	MOV.W	R6, R8
	MOV.W	R5, R11
	MOV.B	#40, R12
	CALLA	#__mspabi_srlll
	MOV.B	R12, 2(R4)
	MOV.W	R6, R8
	MOV.W	R5, R11
	MOV.B	#32, R12
	CALLA	#__mspabi_srlll
	MOV.B	R12, 3(R4)
	MOV.W	R6, R8
	MOV.W	R5, R11
	MOV.B	#24, R12
	CALLA	#__mspabi_srlll
	MOV.B	R12, 4(R4)
	MOV.W	R6, R8
	MOV.W	R5, R11
	MOV.B	#16, R12
	CALLA	#__mspabi_srlll
	MOV.B	R12, 5(R4)
	MOV.W	R6, R8
	MOV.W	R5, R11
	MOV.B	#8, R12
	CALLA	#__mspabi_srlll
	MOV.B	R12, 6(R4)
	MOV.B	R6, 7(R4)
	; start of epilogue
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
	.size	uint64_to_bytes, .-uint64_to_bytes
	.balign 2
	.global	combine_uint32_to_uint64
	.type	combine_uint32_to_uint64, @function
combine_uint32_to_uint64:
; start of function
; attributes: 
; framesize_regs:     16
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          16
; elim ap -> fp       20
; elim fp -> sp       0
; saved regs: R5 R6 R9 R10
	; start of prologue
	PUSHM.A	#2, R10
	PUSHM.A	#2, R6
	; end of prologue
	MOV.W	R13, R9
	MOV.W	R14, R5
	MOV.W	R15, R6
	MOV.W	R12, R8
	MOV.B	#0, R10
	MOV.W	R10, R11
	MOV.B	#32, R12
	CALLA	#__mspabi_sllll
	BIS.W	R5, R12
	BIS.W	R6, R13
	; start of epilogue
	POPM.A	#2, r6
	POPM.A	#2, r10
	RETA
	.size	combine_uint32_to_uint64, .-combine_uint32_to_uint64
	.balign 2
	.global	uart_send_byte
	.type	uart_send_byte, @function
uart_send_byte:
; start of function
; attributes: 
; framesize_regs:     0
; framesize_locals:   0
; framesize_outgoing: 0
; framesize:          0
; elim ap -> fp       4
; elim fp -> sp       0
; saved regs:(none)
	; start of prologue
	; end of prologue
	AND	#0xff, R12
.L8:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L8
	MOVX.B	R12, &UCA1TXBUF
	; start of epilogue
	RETA
	.size	uart_send_byte, .-uart_send_byte
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"0123456789ABCDEF"
	.section	.tcm:codeUpper
	.balign 2
	.global	uart_send_hex_data
	.type	uart_send_hex_data, @function
uart_send_hex_data:
; start of function
; attributes: 
; framesize_regs:     8
; framesize_locals:   18
; framesize_outgoing: 0
; framesize:          26
; elim ap -> fp       12
; elim fp -> sp       18
; saved regs: R6 R10
	; start of prologue
	PUSHM.A	#1, R10
	PUSHM.A	#1, R6
	SUBA	#18, R1
	; end of prologue
	MOVA	R12, R6
	MOV.B	R13, R10
	MOV.B	#17, R14
	MOVA	#.LC0, R13
	MOVA	R1, R12
	ADDA	#1, R12
	CALLA	#memcpy
	CMP.W	#0, R10 { JEQ	.L16
	ADD.B	#-1, R10
	MOV.B	R10, R10
	MOVA	R6, R12
	ADDA	#1, R12
	ADDA	R12, R10
.L15:
	MOV.B	@R6+, R12
	RRUM.W	#4, R12
	RLAM.A #4, R12 { RRAM.A #4, R12
	MOV.B	#1, R13
	ADDA	R1, R13
	ADDA	R13, R12
	MOV.B	@R12, R12
.L13:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L13
	MOVX.B	R12, &UCA1TXBUF
	MOV.B	-1(R6), R12
	AND.B	#15, R12
	RLAM.A #4, R12 { RRAM.A #4, R12
	MOV.B	#1, R13
	ADDA	R1, R13
	ADDA	R13, R12
	MOV.B	@R12, R12
.L14:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L14
	MOVX.B	R12, &UCA1TXBUF
	CMPA	R10, R6 { JNE	.L15
.L16:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L16
	MOVX.B	#32, &UCA1TXBUF
	; start of epilogue
	ADDA	#18, R1
	POPM.A	#1, r6
	POPM.A	#1, r10
	RETA
	.size	uart_send_hex_data, .-uart_send_hex_data
	.balign 2
	.global	XorResult
	.type	XorResult, @function
XorResult:
; start of function
; attributes: 
; framesize_regs:     20
; framesize_locals:   20
; framesize_outgoing: 0
; framesize:          40
; elim ap -> fp       24
; elim fp -> sp       20
; saved regs: R4 R5 R6 R9 R10
	; start of prologue
	PUSHM.A	#2, R10
	PUSHM.A	#3, R6
	SUBA	#20, R1
	; end of prologue
	MOVX.W	#23168, &WDTCTL
 ; 68 "core/src_compile/XorCompute.c" 1
	dint { nop
 ; 0 "" 2
 ; 70 "core/src_compile/XorCompute.c" 1
	mov.w r8, &write_count_lee
 ; 0 "" 2
	BISX.B	#48, &PBSEL_H
	BISX.B	#1, &UCA1CTLW0_L
	BISX.B	#64, &UCA1CTLW0_L
	MOVX.B	#3, &UCA1BRW_L
	MOVX.B	#-42, &UCA1MCTL
	MOVX.B	#0, &UCA1CTLW0_H
	BICX.B	#1, &UCA1CTLW0_L
	BISX.B	#1, &UCA1ICTL_L
	MOVX.W	&address_sr, R12
	MOVX.W	&address_sr+2, R13
	MOVX.W	&address_xor, R4
	MOVX.W	&address_xor+2, R5
	MOV.W	R13, R9
	MOV.W	R12, R8
	MOV.B	#0, R10
	MOV.W	R10, R11
	MOV.B	#32, R12
	CALLA	#__mspabi_sllll
	MOV.W	R15, R6
	MOV.W	R5, R9
	MOV.W	R12, R5
	BIS.W	R4, R5
	MOVA	#combined_bytes, R4
	MOV.W	R5, R8
	BIS.W	R13, R9
	MOV.W	R14, R10
	MOV.W	R15, R11
	MOV.B	#56, R12
	CALLA	#__mspabi_srlll
	AND	#0xff, R12
	MOV.W	R12, @R1
	MOV.W	R5, R8
	MOV.W	R6, R11
	MOV.B	#48, R12
	CALLA	#__mspabi_srlll
	RPT	#8 { RLAX.W	R12
	BIS.W	@R1, R12
	MOV.W	R12, @R4
	MOV.W	R5, R8
	MOV.W	R6, R11
	MOV.B	#40, R12
	CALLA	#__mspabi_srlll
	AND	#0xff, R12
	MOV.W	R12, @R1
	MOV.W	R5, R8
	MOV.W	R6, R11
	MOV.B	#32, R12
	CALLA	#__mspabi_srlll
	RPT	#8 { RLAX.W	R12
	BIS.W	@R1, R12
	MOV.W	R12, 2(R4)
	MOV.W	R5, R8
	MOV.W	R6, R11
	MOV.B	#24, R12
	CALLA	#__mspabi_srlll
	AND	#0xff, R12
	MOV.W	R12, @R1
	MOV.W	R5, R8
	MOV.W	R6, R11
	MOV.B	#16, R12
	CALLA	#__mspabi_srlll
	RPT	#8 { RLAX.W	R12
	BIS.W	@R1, R12
	MOV.W	R12, 4(R4)
	MOV.W	R5, R8
	MOV.W	R6, R11
	MOV.B	#8, R12
	CALLA	#__mspabi_srlll
	RPT	#8 { RLAX.W	R5
	AND	#0xff, R12
	BIS.W	R5, R12
	MOV.W	R12, 6(R4)
	MOVX.W	&verify_count, R12
	MOV.W	R12, R13
	RPT	#8 { RLAX.W	R13
	RPT	#8 { RRUX.W	R12
	MOV.W	R12, 8(R4)
	BIS.W	R13, 8(R4)
	MOVX.W	&write_count_lee, R6
	MOV.W	R6, R5
	RPT	#8 { RRUX.W	R5
	MOVA	#write_count_lee_bytes, R12
	MOV.B	R5, @R12
	AND	#0xff, R6
	MOV.B	R6, 1(R12)
	MOVA	#memcpy, R9
	MOV.B	#17, R14
	MOVA	#.LC0, R13
	MOVA	R1, R12
	ADDA	#3, R12
	CALLA	R9
	MOVA	R4, R14
	MOVA	R4, R10
	ADDA	#10, R10
.L30:
	MOV.B	@R14+, R12
	MOV.W	R12, R4
	RRUM.W	#4, R4
	RLAM.A #4, R4 { RRAM.A #4, R4
	MOV.B	#3, R13
	ADDA	R1, R13
	ADDA	R13, R4
	MOV.B	@R4, R13
.L28:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L28
	MOVX.B	R13, &UCA1TXBUF
	AND.B	#15, R12
	RLAM.A #4, R12 { RRAM.A #4, R12
	MOV.B	#3, R13
	ADDA	R1, R13
	ADDA	R13, R12
	MOV.B	@R12, R12
.L29:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L29
	MOVX.B	R12, &UCA1TXBUF
	CMPA	R14, R10 { JNE	.L30
.L31:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L31
	MOVX.B	#32, &UCA1TXBUF
	MOV.B	#17, R14
	MOVA	#.LC0, R13
	MOVA	R1, R12
	ADDA	#3, R12
	CALLA	R9
	MOV.W	R5, R12
	RRUM.W	#4, R12
	RLAM.A #4, R12 { RRAM.A #4, R12
	MOV.B	#3, R13
	ADDA	R1, R13
	ADDA	R13, R12
	MOV.B	@R12, R12
.L32:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L32
	MOVX.B	R12, &UCA1TXBUF
	MOV.W	R5, R12
	AND.B	#15, R12
	RLAM.A #4, R12 { RRAM.A #4, R12
	MOV.B	#3, R13
	ADDA	R1, R13
	ADDA	R13, R12
	MOV.B	@R12, R12
.L33:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L33
	MOVX.B	R12, &UCA1TXBUF
	MOV.W	R6, R12
	RRUM.W	#4, R12
	RLAM.A #4, R12 { RRAM.A #4, R12
	MOV.B	#3, R13
	ADDA	R1, R13
	ADDA	R13, R12
	MOV.B	@R12, R12
.L34:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L34
	MOVX.B	R12, &UCA1TXBUF
	AND.B	#15, R6
	RLAM.A #4, R6 { RRAM.A #4, R6
	MOV.B	#3, R12
	ADDA	R1, R12
	ADDA	R12, R6
	MOV.B	@R6, R12
.L35:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L35
	MOVX.B	R12, &UCA1TXBUF
.L36:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L36
	MOVX.B	#32, &UCA1TXBUF
.L37:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L37
	MOVX.B	#84, &UCA1TXBUF
.L38:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L38
	MOVX.B	#10, &UCA1TXBUF
.L39:
	BITX.B	#2, &UCA1ICTL_H { JEQ	.L39
	MOVX.B	#13, &UCA1TXBUF
 ; 118 "core/src_compile/XorCompute.c" 1
	mov.w &write_count_lee, r8
 ; 0 "" 2
	; start of epilogue
	ADDA	#20, R1
	POPM.A	#3, r6
	POPM.A	#2, r10
	RETA
	.size	XorResult, .-XorResult
	.global	combined_bytes
	.section .bss
	.balign 2
	.type	combined_bytes, @object
	.size	combined_bytes, 10
combined_bytes:
	.zero	10
	.global	write_count_lee_bytes
	.type	write_count_lee_bytes, @object
	.size	write_count_lee_bytes, 2
write_count_lee_bytes:
	.zero	2
	.global	write_count_lee
	.balign 2
	.type	write_count_lee, @object
	.size	write_count_lee, 2
write_count_lee:
	.zero	2
	.global	tmp_r6
	.balign 2
	.type	tmp_r6, @object
	.size	tmp_r6, 4
tmp_r6:
	.zero	4
	.global	tmp_r5
	.balign 2
	.type	tmp_r5, @object
	.size	tmp_r5, 4
tmp_r5:
	.zero	4
	.global	tmp_r4
	.balign 2
	.type	tmp_r4, @object
	.size	tmp_r4, 4
tmp_r4:
	.zero	4
	.global	address_sr
	.balign 2
	.type	address_sr, @object
	.size	address_sr, 4
address_sr:
	.zero	4
	.global	address_xor
	.balign 2
	.type	address_xor, @object
	.size	address_xor, 4
address_xor:
	.zero	4
	.ident	"GCC: (Mitto Systems Limited - msp430-gcc 9.2.0.50) 9.2.0"
	.mspabi_attribute 4, 2
	.mspabi_attribute 6, 2
	.mspabi_attribute 8, 2
	.gnu_attribute 4, 2
