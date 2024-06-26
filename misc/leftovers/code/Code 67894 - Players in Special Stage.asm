

;
; +-------------------------------------------------------------------------+
; |	This file is generated by The Interactive Disassembler (IDA)	    |
; |	Copyright (c) 2007 by DataRescue sa/nv,	<ida@datarescue.com>	    |
; |	    Licensed to: GVU, Gerhard Uphoff, 1	user, adv, 10/2007	    |
; +-------------------------------------------------------------------------+
;
; Input	MD5   :	541276D55358182B77C48B057566851A

; ---------------------------------------------------------------------------
; File Name   :	Z:\emu\gen\s2a\sym\copies\code_67894
; Format      :	Binary file
; Base Address:	0000h Range: 0000h - 06A4h Loaded length: 06A4h

; Processor:	    68000
; Target Assembler: 680x0 Assembler in MRI compatible mode
; This file should be compiled with "as	-M"

; ===========================================================================

; Segment type:	Pure code
; segment "ROM"

play01:
		tst.w	($FFFFFE08).w
		beq.s	_jump$neba
		bsr.w	playscr
		bra.w	$1780		; XREF:	edit
; ---------------------------------------------------------------------------

_jump$neba:				; CODE XREF: ROM:00000004j
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	play01_move_tbl(pc,d0.w),d1
		jmp	play01_move_tbl(pc,d1.w)
; ---------------------------------------------------------------------------
play01_move_tbl:dc.w play01init-play01_move_tbl	; DATA XREF: ROM:play01_move_tblo
					; ROM:0000001Eo ...
		dc.w play01move-play01_move_tbl
		dc.w play01gole-play01_move_tbl
		dc.w play01gole2-play01_move_tbl
; ---------------------------------------------------------------------------

play01init:				; DATA XREF: ROM:play01_move_tblo
		addq.b	#2,$24(a0)
		move.b	#$E,$16(a0)
		move.b	#7,$17(a0)
		move.l	#$914C0,4(a0)	; XREF:	playpat
		move.w	#$780,2(a0)
		bsr.w	$6A4		; XREF:	dualmodesub
		move.b	#4,1(a0)
		move.b	#0,$18(a0)
		move.b	#2,$1C(a0)
		bset	#2,$22(a0)
		bset	#1,$22(a0)

play01move:				; DATA XREF: ROM:0000001Eo
		tst.w	($FFFFFFFA).w
		beq.s	_jump5$qeba
		btst	#4,($FFFFF605).w
		beq.s	_jump5$qeba
		move.w	#1,($FFFFFE08).w

_jump5$qeba:				; CODE XREF: ROM:00000068j
					; ROM:00000070j
		move.b	#0,$30(a0)
		moveq	#0,d0
		move.b	$22(a0),d0
		and.w	#2,d0
		move.w	play01move_tbl(pc,d0.w),d1
		jsr	play01move_tbl(pc,d1.w)
		jsr	$1029A		; XREF:	playwrt
		jmp	$C758		; XREF:	actionsub
; ---------------------------------------------------------------------------
play01move_tbl:	dc.w play01walk-play01move_tbl ; DATA XREF: ROM:play01move_tblo
					; ROM:0000009Eo
		dc.w play01jump-play01move_tbl
; ---------------------------------------------------------------------------

play01walk:				; DATA XREF: ROM:play01move_tblo
		bsr.w	spjumpchk
		bsr.w	splevermove
		bsr.w	rotspdset
		bra.s	play01sub
; ---------------------------------------------------------------------------

play01jump:				; DATA XREF: ROM:0000009Eo
		bsr.w	spjumpchk2
		bsr.w	splevermove
		bsr.w	rotspdset

play01sub:				; CODE XREF: ROM:000000ACj
		bsr.w	spcol_ev
		bsr.w	bobinchk
		jsr	$C732		; XREF:	speedset2
		bsr.w	playscr
		move.w	($FFFFF780).w,d0
		add.w	($FFFFF782).w,d0
		move.w	d0,($FFFFF780).w
		jsr	$FF82		; XREF:	patchgmain
		rts

; =============== S U B	R O U T	I N E =======================================


splevermove:				; CODE XREF: ROM:000000A4p
					; ROM:000000B2p
		btst	#2,($FFFFF602).w
		beq.s	_jump5$veba
		bsr.w	spplwalk_l

_jump5$veba:				; CODE XREF: splevermove+6j
		btst	#3,($FFFFF602).w
		beq.s	_jump6$veba
		bsr.w	spplwalk_r

_jump6$veba:				; CODE XREF: splevermove+12j
		move.b	($FFFFF602).w,d0
		and.b	#$C,d0
		bne.s	_jump7$veba
		move.w	$14(a0),d0
		beq.s	_jump7$veba
		bmi.s	_left$veba

_right$veba:
		sub.w	#$C,d0
		bcc.s	_right2$veba
		move.w	#0,d0

_right2$veba:				; CODE XREF: splevermove+2Ej
		move.w	d0,$14(a0)
		bra.s	_jump7$veba
; ---------------------------------------------------------------------------

_left$veba:				; CODE XREF: splevermove+28j
		add.w	#$C,d0
		bcc.s	_left2$veba
		move.w	#0,d0

_left2$veba:				; CODE XREF: splevermove+3Ej
		move.w	d0,$14(a0)

_jump7$veba:				; CODE XREF: splevermove+20j
					; splevermove+26j ...
		move.b	($FFFFF780).w,d0
		add.b	#$20,d0	; ' '
		and.b	#$C0,d0
		neg.b	d0
		jsr	($2B16).l	; XREF:	sinset
		muls.w	$14(a0),d1
		add.l	d1,8(a0)
		muls.w	$14(a0),d0
		add.l	d0,$C(a0)
		movem.l	d0-d1,-(sp)
		move.l	$C(a0),d2
		move.l	8(a0),d3
		bsr.w	spcol
		beq.s	_jump$veba
		movem.l	(sp)+,d0-d1
		sub.l	d1,8(a0)
		sub.l	d0,$C(a0)
		move.w	#0,$14(a0)
		rts
; ---------------------------------------------------------------------------

_jump$veba:				; CODE XREF: splevermove+7Cj
		movem.l	(sp)+,d0-d1
		rts
; End of function splevermove


; =============== S U B	R O U T	I N E =======================================


spplwalk_l:				; CODE XREF: splevermove+8p
		bset	#0,$22(a0)
		move.w	$14(a0),d0
		beq.s	_left$weba
		bpl.s	_right$weba

_left$weba:				; CODE XREF: spplwalk_l+Aj
		sub.w	#$C,d0
		cmp.w	#$F800,d0
		bgt.s	_left2$weba
		move.w	#$F800,d0

_left2$weba:				; CODE XREF: spplwalk_l+16j
		move.w	d0,$14(a0)
		rts
; ---------------------------------------------------------------------------

_right$weba:				; CODE XREF: spplwalk_l+Cj
		sub.w	#$40,d0	; '@'
		bcc.s	_right2$weba
		nop

_right2$weba:				; CODE XREF: spplwalk_l+26j
		move.w	d0,$14(a0)
		rts
; End of function spplwalk_l


; =============== S U B	R O U T	I N E =======================================


spplwalk_r:				; CODE XREF: splevermove+14p
		bclr	#0,$22(a0)
		move.w	$14(a0),d0
		bmi.s	_left$xeba

_right$xeba:
		add.w	#$C,d0
		cmp.w	#$800,d0
		blt.s	_right2$xeba
		move.w	#$800,d0

_right2$xeba:				; CODE XREF: spplwalk_r+14j
		move.w	d0,$14(a0)
		bra.s	_rightcol$xeba
; ---------------------------------------------------------------------------

_left$xeba:				; CODE XREF: spplwalk_r+Aj
		add.w	#$40,d0	; '@'
		bcc.s	_left2$xeba
		nop

_left2$xeba:				; CODE XREF: spplwalk_r+24j
		move.w	d0,$14(a0)

_rightcol$xeba:				; CODE XREF: spplwalk_r+1Ej
		rts
; End of function spplwalk_r


; =============== S U B	R O U T	I N E =======================================


spjumpchk:				; CODE XREF: ROM:play01walkp
		move.b	($FFFFF603).w,d0
		and.b	#$70,d0	; 'p'
		beq.s	_end$yeba
		move.b	($FFFFF780).w,d0
		and.b	#$FC,d0
		neg.b	d0
		sub.b	#$40,d0	; '@'
		jsr	($2B16).l	; XREF:	sinset
		muls.w	#$680,d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		muls.w	#$680,d0
		asr.l	#8,d0
		move.w	d0,$12(a0)
		bset	#1,$22(a0)
		move.w	#$A0,d0	; '�'
		jsr	($12FC).l	; XREF:	soundset

_end$yeba:				; CODE XREF: spjumpchk+8j
		rts
; End of function spjumpchk


; =============== S U B	R O U T	I N E =======================================


spjumpchk2:				; CODE XREF: ROM:play01jumpp
		rts
; End of function spjumpchk2

; ---------------------------------------------------------------------------
		move.w	#$FC00,d1
		cmp.w	$12(a0),d1
		ble.s	_end$zeba
		move.b	($FFFFF602).w,d0
		and.b	#$70,d0	; 'p'
		bne.s	_end$zeba
		move.w	d1,$12(a0)

_end$zeba:				; CODE XREF: ROM:00000224j
					; ROM:0000022Ej
		rts

; =============== S U B	R O U T	I N E =======================================


playscr:				; CODE XREF: ROM:00000006p
					; ROM:000000C8p ...
		move.w	$C(a0),d2
		move.w	8(a0),d3
		move.w	($FFFFEE00).w,d0
		sub.w	#$A0,d3	; '�'
		bcs.s	_jump$afba
		sub.w	d3,d0
		sub.w	d0,($FFFFEE00).w

_jump$afba:				; CODE XREF: playscr+10j
		move.w	($FFFFEE04).w,d0
		sub.w	#$70,d2	; 'p'
		bcs.s	_jump2$afba
		sub.w	d2,d0
		sub.w	d0,($FFFFEE04).w

_jump2$afba:				; CODE XREF: playscr+20j
		rts
; End of function playscr


; =============== S U B	R O U T	I N E =======================================


play01gole:				; DATA XREF: ROM:00000020o
		add.w	#$40,($FFFFF782).w ; '@'
		cmp.w	#$1800,($FFFFF782).w
		bne.s	_jump0$bfba
		move.b	#$C,($FFFFF600).w

_jump0$bfba:				; CODE XREF: play01gole+Cj
		cmp.w	#$3000,($FFFFF782).w
		blt.s	_jump$bfba
		move.w	#0,($FFFFF782).w
		move.w	#$4000,($FFFFF780).w
		addq.b	#2,$24(a0)
		move.w	#$3C,$38(a0) ; '<'

_jump$bfba:				; CODE XREF: play01gole+1Aj
		move.w	($FFFFF780).w,d0
		add.w	($FFFFF782).w,d0
		move.w	d0,($FFFFF780).w
		jsr	$FF82		; XREF:	patchgmain
		jsr	$1029A		; XREF:	playwrt
		bsr.w	playscr
		jmp	$C758		; XREF:	actionsub
; End of function play01gole


; =============== S U B	R O U T	I N E =======================================


play01gole2:				; DATA XREF: ROM:00000022o
		subq.w	#1,$38(a0)
		bne.s	_end$cfba
		move.b	#$C,($FFFFF600).w

_end$cfba:				; CODE XREF: play01gole2+4j
		jsr	$FF82		; XREF:	patchgmain
		jsr	$1029A		; XREF:	playwrt
		bsr.w	playscr
		jmp	$C758		; XREF:	actionsub
; End of function play01gole2


; =============== S U B	R O U T	I N E =======================================


rotspdset:				; CODE XREF: ROM:000000A8p
					; ROM:000000B6p
		move.l	$C(a0),d2
		move.l	8(a0),d3
		move.b	($FFFFF780).w,d0
		and.b	#$FC,d0
		jsr	($2B16).l	; XREF:	sinset
		move.w	$10(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d0	; '*'
		add.l	d4,d0
		move.w	$12(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d1	; '*'
		add.l	d4,d1
		add.l	d0,d3
		bsr.w	spcol
		beq.s	_jump2$dfba
		sub.l	d0,d3
		moveq	#0,d0
		move.w	d0,$10(a0)
		bclr	#1,$22(a0)
		add.l	d1,d2
		bsr.w	spcol
		beq.s	_jump3$dfba
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,$12(a0)
		rts
; ---------------------------------------------------------------------------

_jump2$dfba:				; CODE XREF: rotspdset+38j
		add.l	d1,d2
		bsr.w	spcol
		beq.s	_jump4$dfba
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,$12(a0)
		bclr	#1,$22(a0)

_jump3$dfba:				; CODE XREF: rotspdset+4Ej
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,$10(a0)
		move.w	d1,$12(a0)
		rts
; ---------------------------------------------------------------------------

_jump4$dfba:				; CODE XREF: rotspdset+60j
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,$10(a0)
		move.w	d1,$12(a0)
		bset	#1,$22(a0)
		rts
; End of function rotspdset


; =============== S U B	R O U T	I N E =======================================


spcol:					; CODE XREF: splevermove+78p
					; rotspdset+34p ...
		lea	($FFFF0000).l,a1
		moveq	#0,d4
		swap	d2
		move.w	d2,d4
		swap	d2
		add.w	#$44,d4	; 'D'
		divu.w	#$18,d4
		mulu.w	#$80,d4	; '�'
		add.l	d4,a1
		moveq	#0,d4
		swap	d3
		move.w	d3,d4
		swap	d3
		add.w	#$14,d4
		divu.w	#$18,d4
		add.w	d4,a1
		moveq	#0,d5
		move.b	(a1)+,d4
		bsr.s	spcolsub
		move.b	(a1)+,d4
		bsr.s	spcolsub
		add.w	#$7E,a1	; '~'
		move.b	(a1)+,d4
		bsr.s	spcolsub
		move.b	(a1)+,d4
		bsr.s	spcolsub
		tst.b	d5
		rts
; End of function spcol


; =============== S U B	R O U T	I N E =======================================


spcolsub:				; CODE XREF: spcol+32p	spcol+36p ...
		beq.s	_end$gfba
		cmp.b	#$28,d4	; '('
		beq.s	_end$gfba
		cmp.b	#$3A,d4	; ':'
		bcs.s	_jump2$gfba
		cmp.b	#$4B,d4	; 'K'
		bcc.s	_jump2$gfba

_end$gfba:				; CODE XREF: spcolsubj	spcolsub+6j
		rts
; ---------------------------------------------------------------------------

_jump2$gfba:				; CODE XREF: spcolsub+Cj spcolsub+12j
		move.b	d4,$30(a0)
		move.l	a1,$32(a0)
		moveq	#$FFFFFFFF,d5
		rts
; End of function spcolsub


; =============== S U B	R O U T	I N E =======================================


spcol_ev:				; CODE XREF: ROM:play01subp
		lea	($FFFF0000).l,a1
		moveq	#0,d4
		move.w	$C(a0),d4
		add.w	#$50,d4	; 'P'
		divu.w	#$18,d4
		mulu.w	#$80,d4	; '�'
		add.l	d4,a1
		moveq	#0,d4
		move.w	8(a0),d4
		add.w	#$20,d4	; ' '
		divu.w	#$18,d4
		add.w	d4,a1
		move.b	(a1),d4
		bne.s	spcolsub_ev
		tst.b	$3A(a0)
		bne.w	derusub
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

spcolsub_ev:				; CODE XREF: spcol_ev+2Cj
		cmp.b	#$3A,d4	; ':'
		bne.s	_jump2$ifba
		bsr.w	$FFFFFB34	; XREF:	scrwkchk
		bne.s	_worknai$ifba
		move.b	#1,(a2)
		move.l	a1,4(a2)

_worknai$ifba:				; CODE XREF: spcol_ev+44j
		jsr	$A236		; XREF:	ringgetsub
		cmp.w	#$32,($FFFFFE20).w ; '2'
		bcs.s	_jump$ifba
		bset	#0,($FFFFFE1B).w
		bne.s	_jump$ifba
		addq.b	#1,($FFFFFE18).w
		move.w	#$BF,d0	; '�'
		jsr	($12F6).l	; XREF:	bgmset

_jump$ifba:				; CODE XREF: spcol_ev+5Aj spcol_ev+62j
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

_jump2$ifba:				; CODE XREF: spcol_ev+3Ej
		cmp.b	#$28,d4	; '('
		bne.s	_jump3$ifba
		bsr.w	$FFFFFB34	; XREF:	scrwkchk
		bne.s	_worknai2$ifba
		move.b	#3,(a2)
		move.l	a1,4(a2)

_worknai2$ifba:				; CODE XREF: spcol_ev+80j
		addq.b	#1,($FFFFFE12).w
		addq.b	#1,($FFFFFE1C).w
		move.w	#$88,d0	; '�'
		jsr	($12F6).l	; XREF:	bgmset
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

_jump3$ifba:				; CODE XREF: spcol_ev+7Aj
		cmp.b	#$3B,d4	; ';'
		bcs.s	_jump4$ifba
		cmp.b	#$40,d4	; '@'
		bhi.s	_jump4$ifba
		bsr.w	$FFFFFB34	; XREF:	scrwkchk
		bne.s	_worknai3$ifba
		move.b	#5,(a2)
		move.l	a1,4(a2)

_worknai3$ifba:				; CODE XREF: spcol_ev+B0j
		cmp.b	#6,($FFFFFE57).w
		beq.s	_jump33$ifba
		sub.b	#$3B,d4	; ';'
		moveq	#0,d0
		move.b	($FFFFFE57).w,d0
		lea	($FFFFFE58).w,a2
		move.b	d4,(a2,d0.w)
		addq.b	#1,($FFFFFE57).w

_jump33$ifba:				; CODE XREF: spcol_ev+C0j
		move.w	#$93,d0	; '�'
		jsr	($12FC).l	; XREF:	soundset
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

_jump4$ifba:				; CODE XREF: spcol_ev+A4j spcol_ev+AAj
		cmp.b	#$41,d4	; 'A'
		bne.s	_jump5$ifba
		move.b	#1,$3A(a0)

_jump5$ifba:				; CODE XREF: spcol_ev+EAj
		cmp.b	#$4A,d4	; 'J'
		bne.s	_jump6$ifba
		cmp.b	#1,$3A(a0)
		bne.s	_jump6$ifba
		move.b	#2,$3A(a0)

_jump6$ifba:				; CODE XREF: spcol_ev+F6j spcol_ev+FEj
		moveq	#$FFFFFFFF,d4
		rts
; ---------------------------------------------------------------------------

derusub:				; CODE XREF: spcol_ev+32j
		cmp.b	#2,$3A(a0)
		bne.s	_end$jfba
		lea	($FFFF1020).l,a1
		moveq	#$3F,d1	; '?'

_loop1$jfba:				; CODE XREF: spcol_ev+130j
		moveq	#$3F,d2	; '?'

_loop2$jfba:				; CODE XREF: spcol_ev+128j
		cmp.b	#$41,(a1) ; 'A'
		bne.s	_jump$jfba
		move.b	#$2C,(a1) ; ','

_jump$jfba:				; CODE XREF: spcol_ev+120j
		addq.w	#1,a1
		dbf	d2,_loop2$jfba
		lea	$40(a1),a1
		dbf	d1,_loop1$jfba

_end$jfba:				; CODE XREF: spcol_ev+110j
		clr.b	$3A(a0)
		moveq	#0,d4
		rts
; End of function spcol_ev


; =============== S U B	R O U T	I N E =======================================


bobinchk:				; CODE XREF: ROM:000000BEp
		move.b	$30(a0),d0
		bne.s	_jump$kfba
		subq.b	#1,$36(a0)
		bpl.s	_jmp$kfba
		move.b	#0,$36(a0)

_jmp$kfba:				; CODE XREF: bobinchk+Aj
		subq.b	#1,$37(a0)
		bpl.s	_jmp2$kfba
		move.b	#0,$37(a0)

_jmp2$kfba:				; CODE XREF: bobinchk+16j
		rts
; ---------------------------------------------------------------------------

_jump$kfba:				; CODE XREF: bobinchk+4j
		cmp.b	#$25,d0	; '%'
		bne.s	_jump2$kfba
		move.l	$32(a0),d1
		sub.l	#$FFFF0001,d1
		move.w	d1,d2
		and.w	#$7F,d1	; ''
		mulu.w	#$18,d1
		sub.w	#$14,d1
		lsr.w	#7,d2
		and.w	#$7F,d2	; ''
		mulu.w	#$18,d2
		sub.w	#$44,d2	; 'D'
		sub.w	8(a0),d1
		sub.w	$C(a0),d2
		jsr	($2DAE).l	; XREF:	atan
		jsr	($2B16).l	; XREF:	sinset
		muls.w	#$F900,d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		muls.w	#$F900,d0
		asr.l	#8,d0
		move.w	d0,$12(a0)
		bset	#1,$22(a0)
		bsr.w	$FFFFFB34	; XREF:	scrwkchk
		bne.s	_worknai$kfba
		move.b	#2,(a2)
		move.l	$32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

_worknai$kfba:				; CODE XREF: bobinchk+7Ej
		move.w	#$B4,d0	; '�'
		jmp	($12FC).l	; XREF:	soundset
; ---------------------------------------------------------------------------

_jump2$kfba:				; CODE XREF: bobinchk+24j
		cmp.b	#$27,d0	; '''
		bne.s	_jump3$kfba
		addq.b	#2,$24(a0)
		move.w	#$A8,d0	; '�'
		jsr	($12FC).l	; XREF:	soundset
		rts
; ---------------------------------------------------------------------------

_jump3$kfba:				; CODE XREF: bobinchk+9Cj
		cmp.b	#$29,d0	; ')'
		bne.s	_jump4$kfba
		tst.b	$36(a0)
		bne.w	_end$kfba
		move.b	#$1E,$36(a0)
		btst	#6,($FFFFF783).w
		beq.s	_jump33$kfba
		asl	($FFFFF782).w
		move.l	$32(a0),a1
		subq.l	#1,a1
		move.b	#$2A,(a1) ; '*'

_jump33$kfba:				; CODE XREF: bobinchk+C8j
		move.w	#$A9,d0	; '�'
		jmp	($12FC).l	; XREF:	soundset
; ---------------------------------------------------------------------------

_jump4$kfba:				; CODE XREF: bobinchk+B2j
		cmp.b	#$2A,d0	; '*'
		bne.s	_jump5$kfba
		tst.b	$36(a0)
		bne.w	_end$kfba
		move.b	#$1E,$36(a0)
		btst	#6,($FFFFF783).w
		bne.s	_jump44$kfba
		asr	($FFFFF782).w
		move.l	$32(a0),a1
		subq.l	#1,a1
		move.b	#$29,(a1) ; ')'

_jump44$kfba:				; CODE XREF: bobinchk+FCj
		move.w	#$A9,d0	; '�'
		jmp	($12FC).l	; XREF:	soundset
; ---------------------------------------------------------------------------

_jump5$kfba:				; CODE XREF: bobinchk+E6j
		cmp.b	#$2B,d0	; '+'
		bne.s	_jump6$kfba
		tst.b	$37(a0)
		bne.w	_end$kfba
		move.b	#$1E,$37(a0)
		bsr.w	$FFFFFB34	; XREF:	scrwkchk
		bne.s	_worknai2$kfba
		move.b	#4,(a2)
		move.l	$32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

_worknai2$kfba:				; CODE XREF: bobinchk+12Ej
		neg.w	($FFFFF782).w
		move.w	#$A9,d0	; '�'
		jmp	($12FC).l	; XREF:	soundset
; ---------------------------------------------------------------------------

_jump6$kfba:				; CODE XREF: bobinchk+11Aj
		cmp.b	#$2D,d0	; '-'
		beq.s	_jump66$kfba
		cmp.b	#$2E,d0	; '.'
		beq.s	_jump66$kfba
		cmp.b	#$2F,d0	; '/'
		beq.s	_jump66$kfba
		cmp.b	#$30,d0	; '0'
		bne.s	_end$kfba

_jump66$kfba:				; CODE XREF: bobinchk+150j
					; bobinchk+156j ...
		bsr.w	$FFFFFB34	; XREF:	scrwkchk
		bne.s	_worknai3$kfba
		move.b	#6,(a2)
		move.l	$32(a0),a1
		subq.l	#1,a1
		move.l	a1,4(a2)
		move.b	(a1),d0
		addq.b	#1,d0
		cmp.b	#$30,d0	; '0'
		bls.s	_jump666$kfba
		clr.b	d0

_jump666$kfba:				; CODE XREF: bobinchk+180j
		move.b	d0,4(a2)

_worknai3$kfba:				; CODE XREF: bobinchk+168j
		move.w	#$BA,d0	; '�'
		jmp	($12FC).l	; XREF:	soundset
; ---------------------------------------------------------------------------

_end$kfba:				; CODE XREF: bobinchk+B8j bobinchk+ECj ...
		rts
; End of function bobinchk

; ---------------------------------------------------------------------------

play02:
		rts
; end of 'ROM'


		END
