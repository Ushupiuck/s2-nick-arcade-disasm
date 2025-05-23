

;
; +-------------------------------------------------------------------------+
; |	This file is generated by The Interactive Disassembler (IDA)	    |
; |	Copyright (c) 2007 by DataRescue sa/nv,	<ida@datarescue.com>	    |
; |	    Licensed to: GVU, Gerhard Uphoff, 1	user, adv, 10/2007	    |
; +-------------------------------------------------------------------------+
;
; Input	MD5   :	5499FE0A5B0D627EBAA1152AD298F583

; ---------------------------------------------------------------------------
; File Name   :	Z:\emu\gen\s2a\sym\copies\code_5a718
; Format      :	Binary file
; Base Address:	0000h Range: 0000h - 07DCh Loaded length: 07DCh

; Processor:	    68000
; Target Assembler: 680x0 Assembler in MRI compatible mode
; This file should be compiled with "as	-M"

; ===========================================================================

; Segment type:	Pure code
; segment "ROM"
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	off_E(pc,d0.w),d1
		jmp	off_E(pc,d1.w)
; ---------------------------------------------------------------------------
off_E:		dc.w loc_1C-off_E	; DATA XREF: ROM:off_Eo ROM:00000010o	...
		dc.w loc_8C-off_E
		dc.w loc_32A-off_E
		dc.w loc_37C-off_E
unk_16:		dc.b   2		; DATA XREF: ROM:loc_1Co
		dc.b   0
		dc.b   4
		dc.b   1
		dc.b   6
		dc.b   7
; ---------------------------------------------------------------------------

loc_1C:					; DATA XREF: ROM:off_Eo
		lea	unk_16,a2
		move.l	a0,a1
		moveq	#2,d1
		bra.s	loc_2E
; ---------------------------------------------------------------------------

loc_26:					; CODE XREF: ROM:00000070j
		jsr	$DAB8
		bne.s	loc_74

loc_2E:					; CODE XREF: ROM:00000024j
		move.b	(a2)+,$24(a1)
		move.b	#$3D,0(a1) ; '='
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	#$182DC,4(a1)
		move.w	#$400,2(a1)
		bsr.w	$7DC
		move.b	#4,1(a1)
		move.b	#$20,$19(a1) ; ' '
		move.b	#3,$18(a1)
		move.b	(a2)+,$1C(a1)
		move.l	a0,$34(a1)
		dbf	d1,loc_26

loc_74:					; CODE XREF: ROM:0000002Cj
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)

loc_8C:					; DATA XREF: ROM:00000010o
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	off_BE(pc,d0.w),d1
		jsr	off_BE(pc,d1.w)
		lea	($18290).l,a1
		jsr	$C89C
		move.b	$22(a0),d0
		and.b	#3,d0
		and.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	$C758		; XREF:	actionsub
; ---------------------------------------------------------------------------
off_BE:		dc.w loc_CC-off_BE	; DATA XREF: ROM:off_BEo ROM:000000C0o ...
		dc.w sub_1CC-off_BE
		dc.w sub_21C-off_BE
		dc.w sub_256-off_BE
		dc.w sub_27C-off_BE
		dc.w sub_2AE-off_BE
		dc.w sub_2FA-off_BE
; ---------------------------------------------------------------------------

loc_CC:					; DATA XREF: ROM:off_BEo
		move.w	#$100,$12(a0)
		bsr.w	sub_1A6
		cmp.w	#$338,$38(a0)
		bne.s	loc_E8
		move.w	#0,$12(a0)
		addq.b	#2,$25(a0)
; START	OF FUNCTION CHUNK FOR sub_1CC

loc_E8:					; CODE XREF: ROM:000000DCj
					; sub_1CC:loc_218j ...
		move.b	$3F(a0),d0
		jsr	($2B16).l
		asr.w	#6,d0
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		addq.b	#2,$3F(a0)
		cmp.b	#8,$25(a0)
		bcc.s	return_14C
		tst.b	$22(a0)
		bmi.s	loc_14E
		tst.b	$20(a0)
		bne.s	return_14C
		tst.b	$3E(a0)
		bne.s	loc_130
		move.b	#$20,$3E(a0) ; ' '
		move.w	#$AC,d0	; '�'
		jsr	($12FC).l	; XREF:	soundset

loc_130:				; CODE XREF: sub_1CC-AEj
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_13E
		move.w	#$EEE,d0

loc_13E:				; CODE XREF: sub_1CC-94j
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	return_14C
		move.b	#$F,$20(a0)

return_14C:				; CODE XREF: sub_1CC-C0j sub_1CC-B4j ...
		rts
; ---------------------------------------------------------------------------

loc_14E:				; CODE XREF: sub_1CC-BAj
		moveq	#$64,d0	; 'd'
		bsr.w	$2584
		move.b	#8,$25(a0)
		move.w	#$B3,$3C(a0) ; '�'
		rts
; END OF FUNCTION CHUNK	FOR sub_1CC

; =============== S U B	R O U T	I N E =======================================


sub_162:				; CODE XREF: sub_27C+6j ROM:000005B2p
		move.b	($FFFFFE0F).w,d0
		and.b	#7,d0
		bne.s	return_1A4
		jsr	$DAA2		; XREF:	actwkchk
		bne.s	return_1A4
		move.b	#$3F,0(a1) ; '?'
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	($2AF0).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		sub.w	#$20,d1	; ' '
		add.w	d1,8(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,$C(a1)

return_1A4:				; CODE XREF: sub_162+8j sub_162+10j
		rts
; End of function sub_162


; =============== S U B	R O U T	I N E =======================================


sub_1A6:				; CODE XREF: ROM:000000D2p sub_1CC+Cp	...
		move.l	$30(a0),d2
		move.l	$38(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,$30(a0)
		move.l	d3,$38(a0)
		rts
; End of function sub_1A6


; =============== S U B	R O U T	I N E =======================================


sub_1CC:				; DATA XREF: ROM:000000C0o

; FUNCTION CHUNK AT 000000E8 SIZE 0000007A BYTES

		move.w	#$FF00,$10(a0)
		move.w	#$FFC0,$12(a0)
		bsr.w	sub_1A6
		cmp.w	#$2A00,$30(a0)
		bne.s	loc_218
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		addq.b	#2,$25(a0)
		jsr	$DAB8
		bne.s	loc_212
		move.b	#$48,0(a1) ; 'H'
		move.w	$30(a0),8(a1)
		move.w	$38(a0),$C(a1)
		move.l	a0,$34(a1)

loc_212:				; CODE XREF: sub_1CC+2Ej
		move.w	#$77,$3C(a0) ; 'w'

loc_218:				; CODE XREF: sub_1CC+16j
		bra.w	loc_E8
; End of function sub_1CC


; =============== S U B	R O U T	I N E =======================================


sub_21C:				; DATA XREF: ROM:000000C2o
		subq.w	#1,$3C(a0)
		bpl.s	loc_246
		addq.b	#2,$25(a0)
		move.w	#$3F,$3C(a0) ; '?'
		move.w	#$100,$10(a0)
		cmp.w	#$2A00,$30(a0)
		bne.s	loc_246
		move.w	#$7F,$3C(a0) ; ''
		move.w	#$40,$10(a0) ; '@'

loc_246:				; CODE XREF: sub_21C+4j sub_21C+1Cj
		btst	#0,$22(a0)
		bne.s	loc_252
		neg.w	$10(a0)

loc_252:				; CODE XREF: sub_21C+30j
		bra.w	loc_E8
; End of function sub_21C


; =============== S U B	R O U T	I N E =======================================


sub_256:				; DATA XREF: ROM:000000C4o
		subq.w	#1,$3C(a0)
		bmi.s	loc_262
		bsr.w	sub_1A6
		bra.s	loc_278
; ---------------------------------------------------------------------------

loc_262:				; CODE XREF: sub_256+4j
		bchg	#0,$22(a0)
		move.w	#$3F,$3C(a0) ; '?'
		subq.b	#2,$25(a0)
		move.w	#0,$10(a0)

loc_278:				; CODE XREF: sub_256+Aj
		bra.w	loc_E8
; End of function sub_256


; =============== S U B	R O U T	I N E =======================================


sub_27C:				; DATA XREF: ROM:000000C6o
		subq.w	#1,$3C(a0)
		bmi.s	loc_286
		bra.w	sub_162
; ---------------------------------------------------------------------------

loc_286:				; CODE XREF: sub_27C+4j
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		addq.b	#2,$25(a0)
		move.w	#$FFDA,$3C(a0)
		tst.b	($FFFFF7A7).w
		bne.s	return_2AC
		move.b	#1,($FFFFF7A7).w

return_2AC:				; CODE XREF: sub_27C+28j
		rts
; End of function sub_27C


; =============== S U B	R O U T	I N E =======================================


sub_2AE:				; DATA XREF: ROM:000000C8o
		addq.w	#1,$3C(a0)
		beq.s	loc_2BE
		bpl.s	loc_2C4
		add.w	#$18,$12(a0)
		bra.s	loc_2F2
; ---------------------------------------------------------------------------

loc_2BE:				; CODE XREF: sub_2AE+4j
		clr.w	$12(a0)
		bra.s	loc_2F2
; ---------------------------------------------------------------------------

loc_2C4:				; CODE XREF: sub_2AE+6j
		cmp.w	#$30,$3C(a0) ; '0'
		bcs.s	loc_2DC
		beq.s	loc_2E4
		cmp.w	#$38,$3C(a0) ; '8'
		bcs.s	loc_2F2
		addq.b	#2,$25(a0)
		bra.s	loc_2F2
; ---------------------------------------------------------------------------

loc_2DC:				; CODE XREF: sub_2AE+1Cj
		sub.w	#8,$12(a0)
		bra.s	loc_2F2
; ---------------------------------------------------------------------------

loc_2E4:				; CODE XREF: sub_2AE+1Ej
		clr.w	$12(a0)
		move.w	#$81,d0	; '�'
		jsr	($12F6).l	; XREF:	bgmset

loc_2F2:				; CODE XREF: sub_2AE+Ej sub_2AE+14j ...
		bsr.w	sub_1A6
		bra.w	loc_E8
; End of function sub_2AE


; =============== S U B	R O U T	I N E =======================================


sub_2FA:				; DATA XREF: ROM:000000CAo
		move.w	#$400,$10(a0)
		move.w	#$FFC0,$12(a0)
		cmp.w	#$2AC0,($FFFFEECA).w
		beq.s	loc_314
		addq.w	#2,($FFFFEECA).w
		bra.s	loc_31A
; ---------------------------------------------------------------------------

loc_314:				; CODE XREF: sub_2FA+12j
		tst.b	1(a0)
		bpl.s	loc_322

loc_31A:				; CODE XREF: sub_2FA+18j
		bsr.w	sub_1A6
		bra.w	loc_E8
; ---------------------------------------------------------------------------

loc_322:				; CODE XREF: sub_2FA+1Ej
		addq.l	#4,sp
		jmp	$C88E		; XREF:	frameout
; End of function sub_2FA

; ---------------------------------------------------------------------------

loc_32A:				; DATA XREF: ROM:00000012o
		moveq	#0,d0
		moveq	#1,d1
		move.l	$34(a0),a1
		move.b	$25(a1),d0
		subq.b	#4,d0
		bne.s	loc_344
		cmp.w	#$2A00,$30(a1)
		bne.s	loc_34C
		moveq	#4,d1

loc_344:				; CODE XREF: ROM:00000338j
		subq.b	#6,d0
		bmi.s	loc_34C
		moveq	#$A,d1
		bra.s	loc_360
; ---------------------------------------------------------------------------

loc_34C:				; CODE XREF: ROM:00000340j
					; ROM:00000346j
		tst.b	$20(a1)
		bne.s	loc_356
		moveq	#5,d1
		bra.s	loc_360
; ---------------------------------------------------------------------------

loc_356:				; CODE XREF: ROM:00000350j
		cmp.b	#4,($FFFFB024).w
		bcs.s	loc_360
		moveq	#4,d1

loc_360:				; CODE XREF: ROM:0000034Aj
					; ROM:00000354j ...
		move.b	d1,$1C(a0)
		subq.b	#2,d0
		bne.s	loc_374
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.s	loc_376

loc_374:				; CODE XREF: ROM:00000366j
		bra.s	loc_3B0
; ---------------------------------------------------------------------------

loc_376:				; CODE XREF: ROM:00000372j
		jmp	$C88E		; XREF:	frameout
; ---------------------------------------------------------------------------

loc_37C:				; DATA XREF: ROM:00000014o
		move.b	#7,$1C(a0)
		move.l	$34(a0),a1
		cmp.b	#$C,$25(a1)
		bne.s	loc_39C
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	loc_3AA
		bra.s	loc_3A8
; ---------------------------------------------------------------------------

loc_39C:				; CODE XREF: ROM:0000038Cj
		move.w	$10(a1),d0
		beq.s	loc_3A8
		move.b	#8,$1C(a0)

loc_3A8:				; CODE XREF: ROM:0000039Aj
					; ROM:000003A0j
		bra.s	loc_3B0
; ---------------------------------------------------------------------------

loc_3AA:				; CODE XREF: ROM:00000398j
		jmp	$C88E		; XREF:	frameout
; ---------------------------------------------------------------------------

loc_3B0:				; CODE XREF: ROM:loc_374j ROM:loc_3A8j
		move.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		lea	($18290).l,a1
		jsr	$C89C
		move.b	$22(a0),d0
		and.b	#3,d0
		and.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	$C758		; XREF:	actionsub
; ---------------------------------------------------------------------------
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	off_3F8(pc,d0.w),d1
		jmp	off_3F8(pc,d1.w)
; ---------------------------------------------------------------------------
off_3F8:	dc.w loc_402-off_3F8	; DATA XREF: ROM:off_3F8o
					; ROM:000003FAo ...
		dc.w loc_4CA-off_3F8
		dc.w loc_52A-off_3F8
		dc.w loc_578-off_3F8
		dc.w loc_594-off_3F8
; ---------------------------------------------------------------------------

loc_402:				; DATA XREF: ROM:off_3F8o
		addq.b	#2,$24(a0)
		move.w	#$4080,$26(a0)
		move.w	#$FE00,$3E(a0)
		move.l	#$18410,4(a0)
		move.w	#$46C,2(a0)
		bsr.w	$7E2
		lea	$28(a0),a2
		move.b	#0,(a2)+
		moveq	#5,d1
		move.l	a0,a1
		bra.s	loc_46E
; ---------------------------------------------------------------------------

loc_432:				; CODE XREF: ROM:00000494j
		jsr	$DAB8
		bne.s	loc_498
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#$48,0(a1) ; 'H'
		move.b	#6,$24(a1)
		move.l	#$7EAE,4(a1)
		move.w	#$380,2(a1)
		bsr.w	$7DC
		move.b	#1,$1A(a1)
		addq.b	#1,$28(a0)

loc_46E:				; CODE XREF: ROM:00000430j
		move.w	a1,d5
		sub.w	#$B000,d5
		lsr.w	#6,d5
		and.w	#$7F,d5	; ''
		move.b	d5,(a2)+
		move.b	#4,1(a1)
		move.b	#8,$19(a1)
		move.b	#6,$18(a1)
		move.l	$34(a0),$34(a1)
		dbf	d1,loc_432

loc_498:				; CODE XREF: ROM:00000438j
		move.b	#8,$24(a1)
		move.l	#$7F4A,4(a1)	; XREF:	ballpat
		move.w	#$43AA,2(a1)
		bsr.w	$7DC
		move.b	#1,$1A(a1)
		move.b	#5,$18(a1)
		move.b	#$81,$20(a1)
		rts
; ---------------------------------------------------------------------------
unk_4C4:	dc.b   0		; DATA XREF: ROM:loc_4CAo
		dc.b $10
		dc.b $20
		dc.b $30 ; 0
		dc.b $40 ; @
		dc.b $60 ; `
; ---------------------------------------------------------------------------

loc_4CA:				; DATA XREF: ROM:000003FAo
		lea	unk_4C4,a3
		lea	$28(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_4D6:				; CODE XREF: ROM:loc_4F0j
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		add.l	#-$5000,d4
		move.l	d4,a1
		move.b	(a3)+,d0
		cmp.b	$3C(a1),d0
		beq.s	loc_4F0
		addq.b	#1,$3C(a1)

loc_4F0:				; CODE XREF: ROM:000004EAj
		dbf	d6,loc_4D6
		cmp.b	$3C(a1),d0
		bne.s	loc_50A
		move.l	$34(a0),a1
		cmp.b	#6,$25(a1)
		bne.s	loc_50A
		addq.b	#2,$24(a0)

loc_50A:				; CODE XREF: ROM:000004F8j
					; ROM:00000504j
		cmp.w	#$20,$32(a0) ; ' '
		beq.s	loc_516
		addq.w	#1,$32(a0)

loc_516:				; CODE XREF: ROM:00000510j
		bsr.w	sub_53A
		move.b	$26(a0),d0
		jsr	($7DAE).l	; XREF:	burankoposiset2
		jmp	$C758		; XREF:	actionsub
; ---------------------------------------------------------------------------

loc_52A:				; DATA XREF: ROM:000003FCo
		bsr.w	sub_53A
		jsr	($7D6A).l
		jmp	$C758		; XREF:	actionsub

; =============== S U B	R O U T	I N E =======================================


sub_53A:				; CODE XREF: ROM:loc_516p ROM:loc_52Ap
		move.l	$34(a0),a1
		add.b	#$20,$1B(a0) ; ' '
		bcc.s	loc_54C
		bchg	#0,$1A(a0)

loc_54C:				; CODE XREF: sub_53A+Aj
		move.w	8(a1),$3A(a0)
		move.w	$C(a1),d0
		add.w	$32(a0),d0
		move.w	d0,$38(a0)
		move.b	$22(a1),$22(a0)
		tst.b	$22(a1)
		bpl.s	return_576
		move.b	#$3F,0(a0) ; '?'
		move.b	#0,$24(a0)

return_576:				; CODE XREF: sub_53A+2Ej
		rts
; End of function sub_53A

; ---------------------------------------------------------------------------

loc_578:				; DATA XREF: ROM:000003FEo
		move.l	$34(a0),a1
		tst.b	$22(a1)
		bpl.s	loc_58E
		move.b	#$3F,0(a0) ; '?'
		move.b	#0,$24(a0)

loc_58E:				; CODE XREF: ROM:00000580j
		jmp	$C758		; XREF:	actionsub
; ---------------------------------------------------------------------------

loc_594:				; DATA XREF: ROM:00000400o
		moveq	#0,d0
		tst.b	$1A(a0)
		bne.s	loc_59E
		addq.b	#1,d0

loc_59E:				; CODE XREF: ROM:0000059Aj
		move.b	d0,$1A(a0)
		move.l	$34(a0),a1
		tst.b	$22(a1)
		bpl.s	loc_5C6
		move.b	#0,$20(a0)
		bsr.w	sub_162
		subq.b	#1,$3C(a0)
		bpl.s	loc_5C6
		move.b	#$3F,(a0) ; '?'
		move.b	#0,$24(a0)

loc_5C6:				; CODE XREF: ROM:000005AAj
					; ROM:000005BAj
		jmp	$C758		; XREF:	actionsub
; ---------------------------------------------------------------------------
off_5CC:	dc.w byte_5E4-off_5CC	; DATA XREF: ROM:off_5CCo
					; ROM:000005CEo ...
		dc.w byte_5E7-off_5CC
		dc.w byte_5EB-off_5CC
		dc.w byte_5EF-off_5CC
		dc.w byte_5F3-off_5CC
		dc.w byte_5F7-off_5CC
		dc.w byte_5FB-off_5CC
		dc.w byte_5FF-off_5CC
		dc.w byte_602-off_5CC
		dc.w byte_606-off_5CC
		dc.w byte_60A-off_5CC
		dc.w byte_60D-off_5CC
byte_5E4:	dc.b  $F		; 0 ; DATA XREF: ROM:off_5CCo
		dc.b   0,$FF		; 0
byte_5E7:	dc.b   5,  1,  2,$FF	; 0 ; DATA XREF: ROM:000005CEo
byte_5EB:	dc.b   3,  1,  2,$FF	; 0 ; DATA XREF: ROM:000005D0o
byte_5EF:	dc.b   1,  1,  2,$FF	; 0 ; DATA XREF: ROM:000005D2o
byte_5F3:	dc.b   4,  3,  4,$FF	; 0 ; DATA XREF: ROM:000005D4o
byte_5F7:	dc.b $1F,  5,  1,$FF	; 0 ; DATA XREF: ROM:000005D6o
byte_5FB:	dc.b   3,  6,  1,$FF	; 0 ; DATA XREF: ROM:000005D8o
byte_5FF:	dc.b  $F, $A,$FF	; 0 ; DATA XREF: ROM:000005DAo
byte_602:	dc.b   3,  8,  9,$FF	; 0 ; DATA XREF: ROM:000005DCo
byte_606:	dc.b   1,  8,  9,$FF	; 0 ; DATA XREF: ROM:000005DEo
byte_60A:	dc.b  $F,  7,$FF	; 0 ; DATA XREF: ROM:000005E0o
byte_60D:	dc.b   2,  9,  8, $B	; 0 ; DATA XREF: ROM:000005E2o
		dc.b  $C, $B, $C,  9	; 4
		dc.b   8,$FE,  2	; 8
off_618:	dc.w word_632-off_618	; DATA XREF: ROM:off_618o
					; ROM:0000061Ao ...
		dc.w word_664-off_618
		dc.w word_676-off_618
		dc.w word_688-off_618
		dc.w word_6A2-off_618
		dc.w word_6BC-off_618
		dc.w word_6D6-off_618
		dc.w word_6F0-off_618
		dc.w word_712-off_618
		dc.w word_71C-off_618
		dc.w word_726-off_618
		dc.w word_728-off_618
		dc.w word_73A-off_618
word_632:	dc.w 6			; DATA XREF: ROM:off_618o
		dc.w $EC01,   $A,    5,$FFE4; 0
		dc.w $EC05,   $C,    6,	  $C; 4
		dc.w $FC0E,$2010,$2008,$FFE4; 8
		dc.w $FC0E,$201C,$200E,	   4; 12
		dc.w $140C,$2028,$2014,$FFEC; 16
		dc.w $1400,$202C,$2016,	  $C; 20
word_664:	dc.w 2			; DATA XREF: ROM:0000061Ao
		dc.w $E404,    0,    0,$FFF4; 0
		dc.w $EC0D,    2,    1,$FFEC; 4
word_676:	dc.w 2			; DATA XREF: ROM:0000061Co
		dc.w $E404,    0,    0,$FFF4; 0
		dc.w $EC0D,  $35,  $1A,$FFEC; 4
word_688:	dc.w 3			; DATA XREF: ROM:0000061Eo
		dc.w $E408,  $3D,  $1E,$FFF4; 0
		dc.w $EC09,  $40,  $20,$FFEC; 4
		dc.w $EC05,  $46,  $23,	   4; 8
word_6A2:	dc.w 3			; DATA XREF: ROM:00000620o
		dc.w $E408,  $4A,  $25,$FFF4; 0
		dc.w $EC09,  $4D,  $26,$FFEC; 4
		dc.w $EC05,  $53,  $29,	   4; 8
word_6BC:	dc.w 3			; DATA XREF: ROM:00000622o
		dc.w $E408,  $57,  $2B,$FFF4; 0
		dc.w $EC09,  $5A,  $2D,$FFEC; 4
		dc.w $EC05,  $60,  $30,	   4; 8
word_6D6:	dc.w 3			; DATA XREF: ROM:00000624o
		dc.w $E404,  $64,  $32,	   4; 0
		dc.w $E404,    0,    0,$FFF4; 4
		dc.w $EC0D,  $35,  $1A,$FFEC; 8
word_6F0:	dc.w 4			; DATA XREF: ROM:00000626o
		dc.w $E409,  $66,  $33,$FFF4; 0
		dc.w $E408,  $57,  $2B,$FFF4; 4
		dc.w $EC09,  $5A,  $2D,$FFEC; 8
		dc.w $EC05,  $60,  $30,	   4; 12
word_712:	dc.w 1			; DATA XREF: ROM:00000628o
		dc.w  $405,  $2D,  $16,	 $22; 0
word_71C:	dc.w 1			; DATA XREF: ROM:0000062Ao
		dc.w  $405,  $31,  $18,	 $22; 0
word_726:	dc.w 0			; DATA XREF: ROM:0000062Co
word_728:	dc.w 2			; DATA XREF: ROM:0000062Eo
		dc.w	 8, $12A, $195,	 $22; 0
		dc.w  $808,$112A,$1995,	 $22; 4
word_73A:	dc.w 2			; DATA XREF: ROM:00000630o
		dc.w $F80B, $12D, $199,	 $22; 0
		dc.w	 1, $139, $1AB,	 $3A; 4
off_74C:	dc.w word_75C-off_74C	; DATA XREF: ROM:off_74Co
					; ROM:0000074Eo ...
		dc.w word_766-off_74C
		dc.w word_778-off_74C
		dc.w word_782-off_74C
		dc.w word_78C-off_74C
		dc.w word_796-off_74C
		dc.w word_7B8-off_74C
		dc.w word_7CA-off_74C
word_75C:	dc.w 1			; DATA XREF: ROM:off_74Co
		dc.w $F805,    0,    0,$FFF8; 0
word_766:	dc.w 2			; DATA XREF: ROM:0000074Eo
		dc.w $FC04,    4,    2,$FFF8; 0
		dc.w $F805,    0,    0,$FFF8; 4
word_778:	dc.w 1			; DATA XREF: ROM:00000750o
		dc.w $FC00,    6,    3,$FFFC; 0
word_782:	dc.w 1			; DATA XREF: ROM:00000752o
		dc.w $1409,    7,    3,$FFF4; 0
word_78C:	dc.w 1			; DATA XREF: ROM:00000754o
		dc.w $1405,   $D,    6,$FFF8; 0
word_796:	dc.w 4			; DATA XREF: ROM:00000756o
		dc.w $F004,  $11,    8,$FFF8; 0
		dc.w $F801,  $13,    9,$FFF8; 4
		dc.w $F801, $813, $809,	   0; 8
		dc.w  $804,  $15,   $A,$FFF8; 12
word_7B8:	dc.w 2			; DATA XREF: ROM:00000758o
		dc.w	 5,  $17,   $B,	   0; 0
		dc.w	 0,  $1B,   $D,	 $10; 4
word_7CA:	dc.w 2			; DATA XREF: ROM:0000075Ao
		dc.w $1804,  $1C,   $E,	   0; 0
		dc.w	$B,  $1E,   $F,	 $10; 4
; end of 'ROM'


		END
