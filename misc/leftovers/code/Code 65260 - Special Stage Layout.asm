

;
; +-------------------------------------------------------------------------+
; |	This file is generated by The Interactive Disassembler (IDA)	    |
; |	Copyright (c) 2007 by DataRescue sa/nv,	<ida@datarescue.com>	    |
; |	    Licensed to: GVU, Gerhard Uphoff, 1	user, adv, 10/2007	    |
; +-------------------------------------------------------------------------+
;
; Input	MD5   :	FE82E68B2F6F131371CA137FE1472DA0

; ---------------------------------------------------------------------------
; File Name   :	Z:\emu\gen\s2a\sym\copies\code_65260
; Format      :	Binary file
; Base Address:	0000h Range: 0000h - 0890h Loaded length: 0890h

; Processor:	    68000
; Target Assembler: 680x0 Assembler in MRI compatible mode
; This file should be compiled with "as	-M"

; ===========================================================================

; Segment type:	Pure code
; segment "ROM"

sprscr:
		bsr.w	sprscractcnt
		bsr.w	scrcnt
		move.w	d5,-(sp)
		lea	($FFFF8000).w,a1
		move.b	($FFFFF780).w,d0
		and.b	#$FC,d0
		jsr	($2B16).l	; XREF:	sinset
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	($FFFFEE00).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		add.w	#-$B4,d2
		moveq	#0,d3
		move.w	($FFFFEE04).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		add.w	#-$B4,d3
		move.w	#$F,d7

_loop$ndba:				; CODE XREF: ROM:0000008Ej
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$F,d6

_loop2$ndba:				; CODE XREF: ROM:00000082j
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,_loop2$ndba
		movem.w	(sp)+,d0-d2
		add.w	#$18,d3
		dbf	d7,_loop$ndba
		move.w	(sp)+,d5

sprscre:
		lea	($FFFF0000).l,a0
		moveq	#0,d0
		move.w	($FFFFEE04).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0	; '�'
		add.l	d0,a0
		moveq	#0,d0
		move.w	($FFFFEE00).w,d0
		divu.w	#$18,d0
		add.w	d0,a0
		lea	($FFFF8000).w,a4
		move.w	#$F,d7

_loop$pdba:				; CODE XREF: ROM:00000124j
		move.w	#$F,d6

_loop2$pdba:				; CODE XREF: ROM:0000011Cj
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	_jump$pdba
		cmp.b	#$4E,d0	; 'N'
		bhi.s	_jump$pdba
		move.w	(a4),d3
		add.w	#$120,d3
		cmp.w	#$70,d3	; 'p'
		bcs.s	_jump$pdba
		cmp.w	#$1D0,d3
		bcc.s	_jump$pdba
		move.w	2(a4),d2
		add.w	#$F0,d2	; '�'
		cmp.w	#$70,d2	; 'p'
		bcs.s	_jump$pdba
		cmp.w	#$170,d2
		bcc.s	_jump$pdba
		lea	($FFFF4000).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		move.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		add.w	(a1,d1.w),a1
		move.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	_jump$pdba
		jsr	$CB26		; XREF:	spatsetsub

_jump$pdba:				; CODE XREF: ROM:000000C6j
					; ROM:000000CCj ...
		addq.w	#4,a4
		dbf	d6,_loop2$pdba
		lea	$70(a0),a0
		dbf	d7,_loop$pdba
		move.b	d5,($FFFFF62C).w
		cmp.b	#$50,d5	; 'P'
		beq.s	_end$pdba
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

_end$pdba:				; CODE XREF: ROM:00000130j
		move.b	#0,-5(a2)
		rts

; =============== S U B	R O U T	I N E =======================================


sprscractcnt:				; CODE XREF: ROM:sprscrp
		lea	($FFFF400C).l,a1
		moveq	#0,d0
		move.b	($FFFFF780).w,d0
		lsr.b	#2,d0
		and.w	#$F,d0
		moveq	#$23,d1	; '#'

_loop$qdba:				; CODE XREF: sprscractcnt+18j
		move.w	d0,(a1)
		addq.w	#8,a1
		dbf	d1,_loop$qdba
		lea	($FFFF4005).l,a1
		subq.b	#1,($FFFFFEC2).w
		bpl.s	_jump2$qdba
		move.b	#7,($FFFFFEC2).w
		addq.b	#1,($FFFFFEC3).w
		and.b	#3,($FFFFFEC3).w

_jump2$qdba:				; CODE XREF: sprscractcnt+26j
		move.b	($FFFFFEC3).w,$1D0(a1)
		subq.b	#1,($FFFFFEC4).w
		bpl.s	_jump4$qdba
		move.b	#7,($FFFFFEC4).w
		addq.b	#1,($FFFFFEC5).w
		and.b	#1,($FFFFFEC5).w

_jump4$qdba:				; CODE XREF: sprscractcnt+42j
		move.b	($FFFFFEC5).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,($FFFFFEC6).w
		bpl.s	_jump5$qdba
		move.b	#4,($FFFFFEC6).w
		addq.b	#1,($FFFFFEC7).w
		and.b	#3,($FFFFFEC7).w

_jump5$qdba:				; CODE XREF: sprscractcnt+84j
		move.b	($FFFFFEC7).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,($FFFFFEC0).w
		bpl.s	_jump3$qdba
		move.b	#7,($FFFFFEC0).w
		subq.b	#1,($FFFFFEC1).w
		and.b	#7,($FFFFFEC1).w

_jump3$qdba:				; CODE XREF: sprscractcnt+AEj
		lea	($FFFF4016).l,a1
		lea	($18E34).l,a0
		moveq	#0,d0
		move.b	($FFFFFEC1).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		add.w	#$20,a0	; ' '
		add.w	#$48,a1	; 'H'
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		add.w	#$20,a0	; ' '
		add.w	#$48,a1	; 'H'
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		add.w	#$20,a0	; ' '
		add.w	#$48,a1	; 'H'
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		add.w	#$20,a0	; ' '
		add.w	#$48,a1	; 'H'
		rts
; End of function sprscractcnt

; ---------------------------------------------------------------------------
scractofftbl:	dc.w  $142,$6142, $142,	$142; 0
		dc.w  $142, $142, $142,$6142; 4
		dc.w  $142,$6142, $142,	$142; 8
		dc.w  $142, $142, $142,$6142; 12
		dc.w $2142, $142,$2142,$2142; 16
		dc.w $2142,$2142,$2142,	$142; 20
		dc.w $2142, $142,$2142,$2142; 24
		dc.w $2142,$2142,$2142,	$142; 28
		dc.w $4142,$2142,$4142,$4142; 32
		dc.w $4142,$4142,$4142,$2142; 36
		dc.w $4142,$2142,$4142,$4142; 40
		dc.w $4142,$4142,$4142,$2142; 44
		dc.w $6142,$4142,$6142,$6142; 48
		dc.w $6142,$6142,$6142,$4142; 52
		dc.w $6142,$4142,$6142,$6142; 56
		dc.w $6142,$6142,$6142,$4142; 60
; ---------------------------------------------------------------------------

scrwkchk:
		lea	($FFFF4400).l,a2
		move.w	#$1F,d0

_loop$sdba:				; CODE XREF: ROM:0000037Cj
		tst.b	(a2)
		beq.s	_jump$sdba
		addq.w	#8,a2
		dbf	d0,_loop$sdba

_jump$sdba:				; CODE XREF: ROM:00000378j
		rts

; =============== S U B	R O U T	I N E =======================================


scrcnt:					; CODE XREF: ROM:00000004p
		lea	($FFFF4400).l,a0
		move.w	#$1F,d7

_loop$tdba:				; CODE XREF: scrcnt:loc_39Cj
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	_jump$tdba
		lsl.w	#2,d0
		move.l	loc_39C+2(pc,d0.w),a1
		jsr	(a1)

_jump$tdba:				; CODE XREF: scrcnt+Ej
		addq.w	#8,a0

loc_39C:
		dbf	d7,_loop$tdba
		rts
; End of function scrcnt

; ---------------------------------------------------------------------------
scracttbl:	dc.l $18F02
		dc.l $18F32
		dc.l $18F68
		dc.l $18F98
		dc.l $18FCE
		dc.l $1900E
; ---------------------------------------------------------------------------

scr_ring:
		subq.b	#1,2(a0)
		bpl.s	_end$vdba
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		move.l	4(a0),a1
		move.b	scr_ringtbl(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	_end$vdba
		clr.l	(a0)
		clr.l	4(a0)

_end$vdba:				; CODE XREF: ROM:000003BEj
					; ROM:000003DAj
		rts
; ---------------------------------------------------------------------------
scr_ringtbl:	dc.b $42,$43,$44,$45,  0,  0; 0
; ---------------------------------------------------------------------------

scr_bobin:
		subq.b	#1,2(a0)
		bpl.s	_end$xdba
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		move.l	4(a0),a1
		move.b	scr_bobintbl(pc,d0.w),d0
		bne.s	_jump$xdba
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1) ; '%'
		rts
; ---------------------------------------------------------------------------

_jump$xdba:				; CODE XREF: ROM:00000408j
		move.b	d0,(a1)

_end$xdba:				; CODE XREF: ROM:000003EEj
		rts
; ---------------------------------------------------------------------------
scr_bobintbl:	dc.b $32,$33,$32,$33,  0,  0; 0
; ---------------------------------------------------------------------------

scr_1up:
		subq.b	#1,2(a0)
		bpl.s	_end$zdba
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		move.l	4(a0),a1
		move.b	scr_1uptbl(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	_end$zdba
		clr.l	(a0)
		clr.l	4(a0)

_end$zdba:				; CODE XREF: ROM:00000424j
					; ROM:00000440j
		rts
; ---------------------------------------------------------------------------
scr_1uptbl:	dc.b $46,$47,$48,$49,  0,  0; 0
; ---------------------------------------------------------------------------

scr_revers:
		subq.b	#1,2(a0)
		bpl.s	_end$beba
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		move.l	4(a0),a1
		move.b	scr_reverstbl(pc,d0.w),d0
		bne.s	_jump$beba
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1) ; '+'
		rts
; ---------------------------------------------------------------------------

_jump$beba:				; CODE XREF: ROM:0000046Ej
		move.b	d0,(a1)

_end$beba:				; CODE XREF: ROM:00000454j
		rts
; ---------------------------------------------------------------------------
scr_reverstbl:	dc.b $2B,$31,$2B,$31,  0,  0; 0
; ---------------------------------------------------------------------------

scr_houseki:
		subq.b	#1,2(a0)
		bpl.s	_jump$deba
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		move.l	4(a0),a1
		move.b	scr_housekitbl(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	_jump$deba
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,($FFFFB024).w
		move.w	#$A8,d0	; '�'
		jsr	($12FC).l	; XREF:	soundset

_jump$deba:				; CODE XREF: ROM:0000048Aj
					; ROM:000004A6j
		rts
; ---------------------------------------------------------------------------
scr_housekitbl:	dc.b $46,$47,$48,$49,  0,  0; 0
; ---------------------------------------------------------------------------

scr_break:
		subq.b	#1,2(a0)
		bpl.s	_jump$feba
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		move.l	4(a0),a1
		move.b	scr_breaktbl(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	_jump$feba
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

_jump$feba:				; CODE XREF: ROM:000004CAj
					; ROM:000004E6j
		rts
; ---------------------------------------------------------------------------
scr_breaktbl:	dc.b $4B,$4C,$4D,$4E,$4B,$4C,$4D,$4E; 0
		dc.b   0,  0		; 8
sprmapsettbl:	dc.l $25734		; XREF:	rotmaptbl0
		dc.l $259AE		; XREF:	rotmaptbl1
		dc.l $25DC0		; XREF:	rotmaptbl2
		dc.l $2611C		; XREF:	rotmaptbl3
		dc.l $265F6		; XREF:	rotmaptbl4
		dc.l $26AA6		; XREF:	rotmaptbl5
sprplaypositbl:	dc.w  $3D0, $2E0	; 0
		dc.w  $328, $574	; 2
		dc.w  $4E4, $2E0	; 4
		dc.w  $3AD, $2E0	; 6
		dc.w  $340, $6B8	; 8
		dc.w  $49B, $358	; 10
; ---------------------------------------------------------------------------

sprmapset:				; CODE XREF: ROM:00000562j
		moveq	#0,d0
		move.b	($FFFFFE16).w,d0
		addq.b	#1,($FFFFFE16).w
		cmp.b	#6,($FFFFFE16).w
		bcs.s	_jump$jeba
		move.b	#0,($FFFFFE16).w

_jump$jeba:				; CODE XREF: ROM:0000053Ej
		cmp.b	#6,($FFFFFE57).w
		beq.s	_jump2$jeba
		moveq	#0,d1
		move.b	($FFFFFE57).w,d1
		subq.b	#1,d1
		bcs.s	_jump2$jeba
		lea	($FFFFFE58).w,a3

_loop0$jeba:				; CODE XREF: ROM:_jump0$jebaj
		cmp.b	(a3,d1.w),d0
		bne.s	_jump0$jeba
		bra.s	sprmapset
; ---------------------------------------------------------------------------

_jump0$jeba:				; CODE XREF: ROM:00000560j
		dbf	d1,_loop0$jeba

_jump2$jeba:				; CODE XREF: ROM:0000054Cj
					; ROM:00000556j
		lsl.w	#2,d0
		lea	sprplaypositbl(pc,d0.w),a1
		move.w	(a1)+,($FFFFB008).w
		move.w	(a1)+,($FFFFB00C).w
		move.l	sprmapsettbl(pc,d0.w),a0
		lea	($FFFF4000).l,a1
		move.w	#0,d0
		jsr	($170E).l	; XREF:	mapdevr
		lea	($FFFF0000).l,a1
		move.w	#$FFF,d0

_loop$jeba:				; CODE XREF: ROM:00000596j
		clr.l	(a1)+
		dbf	d0,_loop$jeba
		lea	($FFFF1020).l,a1
		lea	($FFFF4000).l,a0
		moveq	#$3F,d1	; '?'

_loop1$jeba:				; CODE XREF: ROM:000005B4j
		moveq	#$3F,d2	; '?'

_loop2$jeba:				; CODE XREF: ROM:000005ACj
		move.b	(a0)+,(a1)+
		dbf	d2,_loop2$jeba
		lea	$40(a1),a1
		dbf	d1,_loop1$jeba

scrpatset:
		lea	($FFFF4008).l,a1
		lea	($19132).l,a0
		moveq	#$4D,d1	; 'M'

_loop$keba:				; CODE XREF: ROM:000005D4j
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,_loop$keba

scrcntclr:
		lea	($FFFF4400).l,a1
		move.w	#$3F,d1	; '?'

_loop$leba:				; CODE XREF: ROM:000005E4j
		clr.l	(a1)+
		dbf	d1,_loop$leba
		rts
; ---------------------------------------------------------------------------
scrpattbl:	dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $2142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $4142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $19306
		dc.w $6142
		dc.l $13002		; XREF:	bobinpat
		dc.w $23B
		dc.l $19306
		dc.w $570
		dc.l $19306
		dc.w $251
		dc.l $19306
		dc.w $370
		dc.l $1933A
		dc.w $263
		dc.l $1934A
		dc.w $263
		dc.l $19306
		dc.w $22F0
		dc.l $1931A
		dc.w $470
		dc.l $1931A
		dc.w $5F0
		dc.l $1931A
		dc.w $65F0
		dc.l $1931A
		dc.w $25F0
		dc.l $1931A
		dc.w $45F0
		dc.l $19306
		dc.w $2F0
		dc.l $1013002		; XREF:	bobinpat
		dc.w $23B
		dc.l $2013002		; XREF:	bobinpat
		dc.w $23B
		dc.l $19306
		dc.w $797
		dc.l $19306
		dc.w $7A0
		dc.l $19306
		dc.w $7A9
		dc.l $19306
		dc.w $797
		dc.l $19306
		dc.w $7A0
		dc.l $19306
		dc.w $7A9
		dc.l $A54A		; XREF:	ringpat
		dc.w $27B2
		dc.l $19362
		dc.w $770
		dc.l $19362
		dc.w $2770
		dc.l $19362
		dc.w $4770
		dc.l $19362
		dc.w $6770
		dc.l $1935A
		dc.w $770
		dc.l $1935E
		dc.w $770
		dc.l $19306
		dc.w $4F0
		dc.l $400A54A		; XREF:	ringpat
		dc.w $27B2
		dc.l $500A54A		; XREF:	ringpat
		dc.w $27B2
		dc.l $600A54A		; XREF:	ringpat
		dc.w $27B2
		dc.l $700A54A		; XREF:	ringpat
		dc.w $27B2
		dc.l $1931A
		dc.w $23F0
		dc.l $101931A
		dc.w $23F0
		dc.l $201931A
		dc.w $23F0
		dc.l $301931A
		dc.w $23F0
		dc.l $2019306
		dc.w $4F0
		dc.l $1931A
		dc.w $5F0
		dc.l $1931A
		dc.w $65F0
		dc.l $1931A
		dc.w $25F0
		dc.l $1931A
		dc.w $45F0
metpat:		dc.w golesp0-metpat	; DATA XREF: ROM:metpato ROM:000007C0o ...
		dc.w golesp1-metpat
		dc.w derusp2-metpat
golesp0:	dc.b 1			; DATA XREF: ROM:metpato
		dc.b $F4, $A,  0,  0,$F4; 0
golesp1:	dc.b 1			; DATA XREF: ROM:000007C0o
		dc.b $F4, $A,  0,  9,$F4; 0
derusp2:	dc.w 0			; DATA XREF: ROM:000007C2o
sphashpat:	dc.w koukasp0-sphashpat	; DATA XREF: ROM:sphashpato
					; ROM:000007D4o ...
		dc.w koukasp1-sphashpat
		dc.w koukasp2-sphashpat
		dc.w koukasp3-sphashpat
koukasp0:	dc.b 1			; DATA XREF: ROM:sphashpato
		dc.b $F4, $A,  0,  0,$F4; 0
koukasp1:	dc.b 1			; DATA XREF: ROM:000007D4o
		dc.b $F4, $A,  8,  0,$F4; 0
koukasp2:	dc.b 1			; DATA XREF: ROM:000007D6o
		dc.b $F4, $A,$18,  0,$F4; 0
koukasp3:	dc.b 1			; DATA XREF: ROM:000007D8o
		dc.b $F4, $A,$10,  0,$F4; 0
spuppat:	dc.w spupsp0-spuppat	; DATA XREF: ROM:spuppato
					; ROM:000007F4o
		dc.w spupsp1-spuppat
spupsp0:	dc.b 1			; DATA XREF: ROM:spuppato
		dc.b $F4, $A,  0,  0,$F4; 0
spupsp1:	dc.b 1			; DATA XREF: ROM:000007F4o
		dc.b $F4, $A,  0,$12,$F4; 0
spdownpat:	dc.w spdownsp0-spdownpat ; DATA	XREF: ROM:spdownpato
					; ROM:00000804o
		dc.w spdownsp1-spdownpat
spdownsp0:	dc.b 1			; DATA XREF: ROM:spdownpato
		dc.b $F4, $A,  0,  9,$F4; 0
spdownsp1:	dc.b 1			; DATA XREF: ROM:00000804o
		dc.b $F4, $A,  0,$12,$F4; 0
hous0pat:	dc.w sphoussp0-hous0pat	; DATA XREF: ROM:hous0pato
					; ROM:00000814o
		dc.w sphoussp3-hous0pat
hous1pat:	dc.w sphoussp1-hous1pat	; DATA XREF: ROM:hous1pato
					; ROM:00000818o
		dc.w sphoussp3-hous1pat
hous2pat:	dc.w sphoussp2-hous2pat	; DATA XREF: ROM:hous2pato
					; ROM:0000081Co
		dc.w sphoussp3-hous2pat
sphoussp0:	dc.b 1			; DATA XREF: ROM:hous0pato
byte_81F:	dc.b $F8,  5,  0,  0,$F8; 0
sphoussp1:	dc.b 1			; DATA XREF: ROM:hous1pato
byte_825:	dc.b $F8,  5,  0,  4,$F8; 0
sphoussp2:	dc.b 1			; DATA XREF: ROM:hous2pato
		dc.b $F8,  5,  0,  8,$F8; 0
sphoussp3:	dc.b 1			; DATA XREF: ROM:00000814o
					; ROM:00000818o ...
		dc.b $F8,  5,  0, $C,$F8; 0
; ---------------------------------------------------------------------------
		nop
; end of 'ROM'


		END