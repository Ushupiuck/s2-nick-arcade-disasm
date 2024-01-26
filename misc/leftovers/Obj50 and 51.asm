; ---------------------------------------------------------------------------
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	off_557C6(pc,d0.w),d1
		jmp	off_557C6(pc,d1.w)
; ---------------------------------------------------------------------------
off_557C6:	dc.w loc_557D2-*
		dc.w loc_5588A-off_557C6
		dc.w loc_558B6-off_557C6
		dc.w loc_558E0-off_557C6
		dc.w sub_55AC2-off_557C6
		dc.w loc_55AFE-off_557C6
; ---------------------------------------------------------------------------

loc_557D2:
		addq.b	#2,obRoutine(a0)
		move.l	#$1542C,4(a0)
		move.w	#$2570,2(a0)
		ori.b	#4,1(a0)
		move.b	#$A,$20(a0)
		move.b	#4,$18(a0)
		move.b	#$10,$19(a0)
		move.w	#$FF00,$10(a0)
		move.b	$28(a0),d0
		move.b	d0,d1
		andi.w	#$F0,d1
		lsl.w	#4,d1
		move.w	d1,$2E(a0)
		move.w	d1,$30(a0)
		andi.w	#$F,d0
		lsl.w	#4,d0
		subq.w	#1,d0
		move.w	d0,$32(a0)
		move.w	d0,$34(a0)
		move.w	$C(a0),$2A(a0)
		bsr.w	$4E2FE
		bne.s	loc_5588A
		move.b	#$50,0(a1) ; 'P'
		move.b	#4,obRoutine(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$A,8(a1)
		addi.w	#-6,$C(a1)
		move.l	#$1542C,4(a1)
		move.w	#$24E0,2(a1)
		ori.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	$22(a0),$22(a1)
		move.b	#3,$1C(a1)
		move.l	a1,$36(a0)
		move.l	a0,$36(a1)
		bset	#6,$22(a0)

loc_5588A:
		lea	($153F4).l,a1
		bsr.w	unk_5602A
		move.w	#$39C,($FFF646).w
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	off_558B0(pc,d0.w),d1
		jsr	off_558B0(pc,d1.w)
		bsr.w	sub_55A88
		bra.w	unk_56024
; ---------------------------------------------------------------------------
off_558B0:	dc.w loc_558F6-*
		dc.w loc_55908-off_558B0
		dc.w loc_55916-off_558B0
; ---------------------------------------------------------------------------

loc_558B6:
		movea.l $36(a0),a1
		tst.b	(a1)
		beq.w	unk_5601E
		cmpi.b	#$50,(a1) ; 'P'
		bne.w	unk_5601E
		btst	#7,$22(a1)
		bne.w	unk_5601E
		lea	($153F4).l,a1
		bsr.w	unk_5602A
		bra.w	unk_56018
; ---------------------------------------------------------------------------

loc_558E0:
		bsr.w	loc_55BAC
		bsr.w	unk_56036
		lea	($153F4).l,a1
		bsr.w	unk_5602A
		bra.w	unk_56024
; ---------------------------------------------------------------------------

loc_558F6:
		bsr.w	unk_56036
		bsr.w	loc_55B8E
		bsr.w	sub_55A34
		bsr.w	sub_559CC
		rts
; ---------------------------------------------------------------------------

loc_55908:					; DATA XREF: ROM:000558B2↑o
		bsr.w	unk_56036
		bsr.w	loc_55B8E
		bsr.w	sub_55A56
		rts
; ---------------------------------------------------------------------------

loc_55916:					; DATA XREF: ROM:000558B4↑o
		bsr.w	unk_56030
		bsr.w	loc_55B8E
		bsr.w	sub_55928
		bsr.w	sub_559A4
		rts

; =============== S U B R O U T I N E =======================================


sub_55928:					; CODE XREF: ROM:0005591E↑p
		tst.b	$2D(a0)
		bne.s	locret_55934
		tst.w	$12(a0)
		bpl.s	loc_55936

locret_55934:				; CODE XREF: sub_55928+4↑j
		rts
; ---------------------------------------------------------------------------

loc_55936:					; CODE XREF: sub_55928+A↑j
		st	$2D(a0)
		bsr.w	$4E2FE
		bne.s	locret_559A2
		move.b	#$50,0(a1) ; 'P'
		move.b	#6,obRoutine(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	#$1542C,4(a1)
		move.w	#$24E0,2(a1)
		ori.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#$E5,$20(a1)
		move.b	#2,$1C(a1)
		move.w	#$C,d0
		move.w	#$10,d1
		move.w	#$FD00,d2
		btst	#0,$22(a0)
		beq.s	loc_55996
		neg.w	d1
		neg.w	d2

loc_55996:					; CODE XREF: sub_55928+68↑j
		sub.w	d0,$C(a1)
		sub.w	d1,8(a1)
		move.w	d2,$10(a1)

locret_559A2:				; CODE XREF: sub_55928+16↑j
		rts
; End of function sub_55928


; =============== S U B R O U T I N E =======================================


sub_559A4:					; CODE XREF: ROM:00055922↑p
		move.w	$C(a0),d0
		cmp.w	($FFF646).w,d0
		blt.s	locret_559CA
		move.b	#2,$25(a0)
		move.b	#0,$1C(a0)
		move.w	$30(a0),$2E(a0)
		move.w	#$40,$12(a0) ; '@'
		sf	$2D(a0)

locret_559CA:				; CODE XREF: sub_559A4+8↑j
		rts
; End of function sub_559A4


; =============== S U B R O U T I N E =======================================


sub_559CC:					; CODE XREF: ROM:00055902↑p
		tst.b	$2C(a0)
		beq.s	locret_55A32
		move.w	($FFB008).w,d0
		move.w	($FFB00C).w,d1
		sub.w	$C(a0),d1
		bpl.s	locret_55A32
		cmpi.w	#$FFD0,d1
		blt.s	locret_55A32
		sub.w	8(a0),d0
		cmpi.w	#$48,d0 ; 'H'
		bgt.s	locret_55A32
		cmpi.w	#$FFB8,d0
		blt.s	locret_55A32
		tst.w	d0
		bpl.s	loc_55A0A
		cmpi.w	#$FFD8,d0
		bgt.s	locret_55A32
		btst	#0,$22(a0)
		bne.s	locret_55A32
		bra.s	loc_55A18
; ---------------------------------------------------------------------------

loc_55A0A:					; CODE XREF: sub_559CC+2C↑j
		cmpi.w	#$28,d0 ; '('
		blt.s	locret_55A32
		btst	#0,$22(a0)
		beq.s	locret_55A32

loc_55A18:					; CODE XREF: sub_559CC+3C↑j
		moveq	#$20,d0 ; ' '
		cmp.w	$32(a0),d0
		bgt.s	locret_55A32
		move.b	#4,$25(a0)
		move.b	#1,$1C(a0)
		move.w	#$FC00,$12(a0)

locret_55A32:				; CODE XREF: sub_559CC+4↑j
						; sub_559CC+12↑j ...
		rts
; End of function sub_559CC


; =============== S U B R O U T I N E =======================================


sub_55A34:					; CODE XREF: ROM:000558FE↑p
		subq.w	#1,$2E(a0)
		bne.s	locret_55A54
		move.w	$30(a0),$2E(a0)
		addq.b	#2,$25(a0)
		move.w	#$FFC0,d0
		tst.b	$2C(a0)
		beq.s	loc_55A50
		neg.w	d0

loc_55A50:					; CODE XREF: sub_55A34+18↑j
		move.w	d0,$12(a0)

locret_55A54:				; CODE XREF: sub_55A34+4↑j
		rts
; End of function sub_55A34


; =============== S U B R O U T I N E =======================================


sub_55A56:					; CODE XREF: ROM:00055910↑p
		move.w	$C(a0),d0
		tst.b	$2C(a0)
		bne.s	loc_55A74
		cmp.w	($FFF646).w,d0
		bgt.s	locret_55A72
		subq.b	#2,$25(a0)
		st	$2C(a0)
		clr.w	$12(a0)

locret_55A72:				; CODE XREF: sub_55A56+E↑j
						; sub_55A56+22↓j
		rts
; ---------------------------------------------------------------------------

loc_55A74:					; CODE XREF: sub_55A56+8↑j
		cmp.w	$2A(a0),d0
		blt.s	locret_55A72
		subq.b	#2,$25(a0)
		sf	$2C(a0)
		clr.w	$12(a0)
		rts
; End of function sub_55A56


; =============== S U B R O U T I N E =======================================


sub_55A88:					; CODE XREF: ROM:000558A8↑p
		moveq	#$A,d0
		moveq	#$FFFFFFFA,d1
		movea.l $36(a0),a1
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$22(a0),$22(a1)
		move.b	$23(a0),$23(a1)
		move.b	1(a0),1(a1)
		btst	#0,$22(a1)
		beq.s	loc_55AB8
		neg.w	d0

loc_55AB8:					; CODE XREF: sub_55A88+2C↑j
		add.w	d0,8(a1)
		add.w	d1,$C(a1)
		rts
; End of function sub_55A88


; =============== S U B R O U T I N E =======================================


sub_55AC2:					; DATA XREF: ROM:000557CE↑o
		bsr.w	unk_56030
		bsr.w	sub_55AD8
		lea	($153F4).l,a1
		bsr.w	unk_5602A
		bra.w	unk_56024
; End of function sub_55AC2


; =============== S U B R O U T I N E =======================================


sub_55AD8:					; CODE XREF: sub_55AC2+4↑p

; FUNCTION CHUNK AT 0005601E SIZE 00000056 BYTES

		jsr	$128C6
		tst.w	d1
		bpl.s	loc_55AF2
		add.w	d1,$C(a0)
		move.w	$12(a0),d0
		asr.w	#1,d0
		neg.w	d0
		move.w	d0,$12(a0)

loc_55AF2:					; CODE XREF: sub_55AD8+8↑j
		subi.b	#1,$21(a0)
		beq.w	unk_5601E
		rts
; ---------------------------------------------------------------------------

loc_55AFE:					; DATA XREF: ROM:000557D0↑o
		bsr.w	loc_55B4E
		tst.b	$25(a0)
		beq.s	locret_55B3E
		subi.w	#1,$2C(a0)
		beq.w	unk_5601E
		move.w	($FFB008).w,8(a0)
		move.w	($FFB00C).w,$C(a0)
		addi.w	#$C,$C(a0)
		subi.b	#1,$2A(a0)
		bne.s	loc_55B40
		move.b	#3,$2A(a0)
		bchg	#0,$22(a0)
		bchg	#0,1(a0)

locret_55B3E:				; CODE XREF: sub_55AD8+2E↑j
		rts
; ---------------------------------------------------------------------------

loc_55B40:					; CODE XREF: sub_55AD8+52↑j
		lea	($153F4).l,a1
		bsr.w	unk_5602A
		bra.w	unk_56018
; ---------------------------------------------------------------------------

loc_55B4E:					; CODE XREF: sub_55AD8:loc_55AFE↑p
		tst.b	$25(a0)
		bne.s	locret_55B8C
		move.b	($FFB024).w,d0
		cmpi.b	#2,d0
		bne.s	locret_55B8C
		move.w	($FFB008).w,8(a0)
		move.w	($FFB00C).w,$C(a0)
		ori.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#5,$1C(a0)
		st	$25(a0)
		move.w	#$12C,$2C(a0)
		move.b	#3,$2A(a0)

locret_55B8C:				; CODE XREF: sub_55AD8+7A↑j
						; sub_55AD8+84↑j
		rts
; ---------------------------------------------------------------------------

loc_55B8E:					; CODE XREF: ROM:000558FA↑p
						; ROM:0005590C↑p ...
		subq.w	#1,$32(a0)
		bpl.s	locret_55BAA
		move.w	$34(a0),$32(a0)
		neg.w	$10(a0)
		bchg	#0,$22(a0)
		move.b	#1,$1D(a0)

locret_55BAA:				; CODE XREF: sub_55AD8+BA↑j
		rts
; ---------------------------------------------------------------------------

loc_55BAC:					; CODE XREF: ROM:loc_558E0↑p
						; ROM:loc_55E70↓p
		tst.b	$21(a0)
		beq.w	locret_55C4E
		moveq	#2,d3

loc_55BB6:					; CODE XREF: sub_55AD8:loc_55C28↓j
		bsr.w	$4E2FE
		bne.s	loc_55C28
		move.b	0(a0),0(a1)
		move.b	#8,obRoutine(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	4(a0),4(a1)
		move.w	#$24E0,2(a1)
		ori.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.w	#$FF00,$12(a1)
		move.b	#4,$1C(a1)
		move.b	#$78,$21(a1) ; 'x'
		cmpi.w	#1,d3
		beq.s	loc_55C22
		blt.s	loc_55C14
		move.w	#$C0,$10(a1)
		addi.w	#-$C0,$12(a1)
		bra.s	loc_55C28
; ---------------------------------------------------------------------------

loc_55C14:					; CODE XREF: sub_55AD8+12C↑j
		move.w	#$FF00,$10(a1)
		addi.w	#-$40,$12(a1)
		bra.s	loc_55C28
; ---------------------------------------------------------------------------

loc_55C22:					; CODE XREF: sub_55AD8+12A↑j
		move.w	#$40,$10(a1) ; '@'

loc_55C28:					; CODE XREF: sub_55AD8+E2↑j
						; sub_55AD8+13A↑j ...
		dbf	d3,loc_55BB6
		bsr.w	$4E2FE
		bne.s	loc_55C4A
		move.b	0(a0),0(a1)
		move.b	#$A,obRoutine(a1)
		move.l	4(a0),4(a1)
		move.w	#$24E0,2(a1)

loc_55C4A:					; CODE XREF: sub_55AD8+158↑j
		bra.w	unk_5601E
; ---------------------------------------------------------------------------

locret_55C4E:				; CODE XREF: sub_55AD8+D8↑j
		rts
; End of function sub_55AD8

; ---------------------------------------------------------------------------
unk_55C50:	dc.b	0		; DATA XREF: ROM:loc_55E4C↓o
						; ROM:00055E78↓o
		dc.b $10
		dc.b	0
		dc.b $13
		dc.b	0
		dc.b $1B
		dc.b	0
		dc.b $21 ; !
		dc.b	0
		dc.b $25 ; %
		dc.b	0
		dc.b $28 ; (
		dc.b	0
		dc.b $2B ; +
		dc.b	0
		dc.b $2F ; /
		dc.b	$E
		dc.b	0
		dc.b $FF
		dc.b	5
		dc.b	3
		dc.b	4
		dc.b	3
		dc.b	4
		dc.b	3
		dc.b	4
		dc.b $FF
		dc.b	3
		dc.b	5
		dc.b	6
		dc.b	7
		dc.b	6
		dc.b $FF
		dc.b	3
		dc.b	1
		dc.b	2
		dc.b $FF
		dc.b	1
		dc.b	5
		dc.b $FF
		dc.b	$E
		dc.b	8
		dc.b $FF
		dc.b	1
		dc.b	9
		dc.b	$A
		dc.b $FF
		dc.b	5
		dc.b	$B
		dc.b	$C
		dc.b	$B
		dc.b	$C
		dc.b	$B
		dc.b	$C
		dc.b $FF
		dc.b	0
		dc.b	0
		dc.b $1A
		dc.b	0
		dc.b $34 ; 4
		dc.b	0
		dc.b $3E ; >
		dc.b	0
		dc.b $48 ; H
		dc.b	0
		dc.b $6A ; j
		dc.b	0
		dc.b $8C
		dc.b	0
		dc.b $96
		dc.b	0
		dc.b $A0
		dc.b	0
		dc.b $AA
		dc.b	0
		dc.b $B4
		dc.b	0
		dc.b $D6
		dc.b	0
		dc.b $F8
		dc.b	1
		dc.b $22 ; "
		dc.b	0
		dc.b	3
		dc.b $E8
		dc.b	$D
		dc.b	0
		dc.b	0
		dc.b	0
		dc.b	0
		dc.b $FF
		dc.b $F0
		dc.b $F8
		dc.b	9
		dc.b	0
		dc.b $16
		dc.b	0
		dc.b	$B
		dc.b $FF
		dc.b $F8
		dc.b	8
		dc.b	5
		dc.b	0
		dc.b $24 ; $
		dc.b	0
		dc.b $12
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	1
		dc.b $F8
		dc.b	5
		dc.b	0
		dc.b $28 ; (
		dc.b	0
		dc.b $14
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	1
		dc.b $F8
		dc.b	5
		dc.b	0
		dc.b $2C ; ,
		dc.b	0
		dc.b $16
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	4
		dc.b $E8
		dc.b	9
		dc.b	0
		dc.b	8
		dc.b	0
		dc.b	4
		dc.b $FF
		dc.b $F0
		dc.b $E8
		dc.b	1
		dc.b	0
		dc.b	$E
		dc.b	0
		dc.b	7
		dc.b	0
		dc.b	8
		dc.b $F8
		dc.b	9
		dc.b	0
		dc.b $16
		dc.b	0
		dc.b	$B
		dc.b $FF
		dc.b $F8
		dc.b	8
		dc.b	5
		dc.b	0
		dc.b $24 ; $
		dc.b	0
		dc.b $12
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	4
		dc.b $E8
		dc.b	9
		dc.b	0
		dc.b $10
		dc.b	0
		dc.b	8
		dc.b $FF
		dc.b $F0
		dc.b $E8
		dc.b	1
		dc.b	0
		dc.b	$E
		dc.b	0
		dc.b	7
		dc.b	0
		dc.b	8
		dc.b $F8
		dc.b	9
		dc.b	0
		dc.b $16
		dc.b	0
		dc.b	$B
		dc.b $FF
		dc.b $F8
		dc.b	8
		dc.b	5
		dc.b	0
		dc.b $24 ; $
		dc.b	0
		dc.b $12
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	1
		dc.b $F8
		dc.b	1
		dc.b	0
		dc.b $30 ; 0
		dc.b	0
		dc.b $18
		dc.b $FF
		dc.b $FC
		dc.b	0
		dc.b	1
		dc.b $F8
		dc.b	1
		dc.b	0
		dc.b $32 ; 2
		dc.b	0
		dc.b $19
		dc.b $FF
		dc.b $FC
		dc.b	0
		dc.b	1
		dc.b $F8
		dc.b	1
		dc.b	0
		dc.b $34 ; 4
		dc.b	0
		dc.b $1A
		dc.b $FF
		dc.b $FC
		dc.b	0
		dc.b	1
		dc.b $F8
		dc.b	$D
		dc.b	0
		dc.b $36 ; 6
		dc.b	0
		dc.b $1B
		dc.b $FF
		dc.b $F0
		dc.b	0
		dc.b	4
		dc.b $E8
		dc.b	$D
		dc.b	0
		dc.b	0
		dc.b	0
		dc.b	0
		dc.b $FF
		dc.b $F0
		dc.b $F8
		dc.b	5
		dc.b	0
		dc.b $1C
		dc.b	0
		dc.b	$E
		dc.b $FF
		dc.b $F8
		dc.b $F8
		dc.b	1
		dc.b	0
		dc.b $20
		dc.b	0
		dc.b $10
		dc.b	0
		dc.b	8
		dc.b	8
		dc.b	5
		dc.b	0
		dc.b $24 ; $
		dc.b	0
		dc.b $12
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	4
		dc.b $E8
		dc.b	$D
		dc.b	0
		dc.b	0
		dc.b	0
		dc.b	0
		dc.b $FF
		dc.b $F0
		dc.b $F8
		dc.b	5
		dc.b	0
		dc.b $1C
		dc.b	0
		dc.b	$E
		dc.b $FF
		dc.b $F8
		dc.b $F8
		dc.b	1
		dc.b	0
		dc.b $22 ; "
		dc.b	0
		dc.b $11
		dc.b	0
		dc.b	8
		dc.b	8
		dc.b	5
		dc.b	0
		dc.b $24 ; $
		dc.b	0
		dc.b $12
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	5
		dc.b $E8
		dc.b	9
		dc.b	0
		dc.b	8
		dc.b	0
		dc.b	4
		dc.b $FF
		dc.b $F0
		dc.b $E8
		dc.b	1
		dc.b	0
		dc.b	$E
		dc.b	0
		dc.b	7
		dc.b	0
		dc.b	8
		dc.b $F8
		dc.b	5
		dc.b	0
		dc.b $1C
		dc.b	0
		dc.b	$E
		dc.b $FF
		dc.b $F8
		dc.b $F8
		dc.b	1
		dc.b	0
		dc.b $20
		dc.b	0
		dc.b $10
		dc.b	0
		dc.b	8
		dc.b	8
		dc.b	5
		dc.b	0
		dc.b $24 ; $
		dc.b	0
		dc.b $12
		dc.b $FF
		dc.b $F8
		dc.b	0
		dc.b	5
		dc.b $E8
		dc.b	9
		dc.b	0
		dc.b $10
		dc.b	0
		dc.b	8
		dc.b $FF
		dc.b $F0
		dc.b $E8
		dc.b	1
		dc.b	0
		dc.b	$E
		dc.b	0
		dc.b	7
		dc.b	0
		dc.b	8
		dc.b $F8
		dc.b	5
		dc.b	0
		dc.b $1C
		dc.b	0
		dc.b	$E
		dc.b $FF
		dc.b $F8
		dc.b $F8
		dc.b	1
		dc.b	0
		dc.b $22 ; "
		dc.b	0
		dc.b $11
		dc.b	0
		dc.b	8
		dc.b	8
		dc.b	5
		dc.b	0
		dc.b $24 ; $
		dc.b	0
		dc.b $12
		dc.b $FF
		dc.b $F8
; ---------------------------------------------------------------------------
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	off_55DE2(pc,d0.w),d1
		jmp	off_55DE2(pc,d1.w)
; ---------------------------------------------------------------------------
off_55DE2:	dc.w loc_55DEE-*		; CODE XREF: ROM:00055DDE↑j
						; DATA XREF: ROM:00055DDA↑r ...
		dc.w loc_55E4C-off_55DE2
		dc.w loc_55E70-off_55DE2
		dc.w 0
		dc.w $FCE0
		dc.w $FD1C
; ---------------------------------------------------------------------------

loc_55DEE:					; DATA XREF: ROM:off_55DE2↑o
		addq.b	#2,obRoutine(a0)
		move.l	#$1542C,4(a0)
		move.w	#$2570,2(a0)
		ori.b	#4,1(a0)
		move.b	#$A,$20(a0)
		move.b	#4,$18(a0)
		move.b	#$10,$19(a0)
		move.b	#6,$1C(a0)
		move.b	$28(a0),d0
		andi.w	#$F,d0
		move.w	d0,d1
		lsl.w	#5,d1
		subq.w	#1,d1
		move.w	d1,$32(a0)
		move.w	d1,$34(a0)
		move.w	$C(a0),$2A(a0)
		move.w	$C(a0),$2E(a0)
		addi.w	#$60,$2E(a0) ; '`'
		move.w	#$FF00,$10(a0)

loc_55E4C:					; DATA XREF: ROM:00055DE4↑o
		lea	unk_55C50(pc),a1
		bsr.w	unk_5602A
		move.w	#$39C,($FFF646).w
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	off_55E6C(pc,d0.w),d1
		jsr	off_55E6C(pc,d1.w)
		bra.w	unk_56024
; ---------------------------------------------------------------------------
off_55E6C:	dc.w loc_55E84-*		; CODE XREF: ROM:00055E64↑p
						; DATA XREF: ROM:00055E60↑r ...
		dc.w loc_55E9A-off_55E6C
; ---------------------------------------------------------------------------

loc_55E70:					; DATA XREF: ROM:00055DE6↑o
		bsr.w	loc_55BAC
		bsr.w	unk_56036
		lea	unk_55C50(pc),a1
		bsr.w	unk_5602A
		bra.w	unk_56024
; ---------------------------------------------------------------------------

loc_55E84:					; DATA XREF: ROM:off_55E6C↑o
		bsr.w	unk_56036
		bsr.w	loc_55B8E
		bsr.w	sub_55ED6
		bsr.w	sub_55FB8
		bsr.w	sub_55F28
		rts
; ---------------------------------------------------------------------------

loc_55E9A:					; DATA XREF: ROM:00055E6E↑o
		bsr.w	unk_56036
		bsr.w	loc_55B8E
		bsr.w	sub_55ED6
		bsr.w	sub_55FB8
		bsr.w	sub_55EB0
		rts

; =============== S U B R O U T I N E =======================================


sub_55EB0:					; CODE XREF: ROM:00055EAA↑p

; FUNCTION CHUNK AT 00055F4E SIZE 0000006A BYTES

		subq.w	#1,$30(a0)
		beq.s	loc_55EC4
		move.w	$30(a0),d0
		cmpi.w	#$12,d0
		beq.w	loc_55F4E
		rts
; ---------------------------------------------------------------------------

loc_55EC4:					; CODE XREF: sub_55EB0+4↑j
		subq.b	#2,$25(a0)
		move.b	#6,$1C(a0)
		move.w	#$B4,$30(a0)
		rts
; End of function sub_55EB0


; =============== S U B R O U T I N E =======================================


sub_55ED6:					; CODE XREF: ROM:00055E8C↑p
						; ROM:00055EA2↑p
		sf	$2D(a0)
		sf	$2C(a0)
		sf	$36(a0)
		move.w	($FFB008).w,d0
		sub.w	8(a0),d0
		bpl.s	loc_55EF6
		btst	#0,$22(a0)
		bne.s	loc_55EFE
		bra.s	loc_55F02
; ---------------------------------------------------------------------------

loc_55EF6:					; CODE XREF: sub_55ED6+14↑j
		btst	#0,$22(a0)
		bne.s	loc_55F02

loc_55EFE:					; CODE XREF: sub_55ED6+1C↑j
		st	$2C(a0)

loc_55F02:					; CODE XREF: sub_55ED6+1E↑j
						; sub_55ED6+26↑j
		move.w	($FFB00C).w,d0
		sub.w	$C(a0),d0
		cmpi.w	#$FFFC,d0
		blt.s	locret_55F26
		cmpi.w	#4,d0
		bgt.s	loc_55F22
		st	$2D(a0)
		move.w	#0,$12(a0)
		rts
; ---------------------------------------------------------------------------

loc_55F22:					; CODE XREF: sub_55ED6+3E↑j
		st	$36(a0)

locret_55F26:				; CODE XREF: sub_55ED6+38↑j
		rts
; End of function sub_55ED6


; =============== S U B R O U T I N E =======================================


sub_55F28:					; CODE XREF: ROM:00055E94↑p
		tst.b	$2C(a0)
		bne.s	locret_55F4C
		subq.w	#1,$30(a0)
		bgt.s	locret_55F4C
		tst.b	$2D(a0)
		beq.s	locret_55F4C
		move.b	#7,$1C(a0)
		move.w	#$24,$30(a0) ; '$'
		addi.b	#2,$25(a0)

locret_55F4C:				; CODE XREF: sub_55F28+4↑j
						; sub_55F28+A↑j ...
		rts
; End of function sub_55F28

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR sub_55EB0

loc_55F4E:					; CODE XREF: sub_55EB0+E↑j
		bsr.w	$4E2FE
		bne.s	locret_55FB6
		move.b	#$51,0(a1) ; 'Q'
		move.b	#4,obRoutine(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	#$1542C,4(a1)
		move.w	#$24E0,2(a1)
		ori.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#2,$1C(a1)
		move.b	#$E5,$20(a1)
		move.w	#$C,d0
		move.w	#$10,d1
		move.w	#$FD00,d2
		btst	#0,$22(a0)
		beq.s	loc_55FAA
		neg.w	d1
		neg.w	d2

loc_55FAA:					; CODE XREF: sub_55EB0+F4↑j
		sub.w	d0,$C(a1)
		sub.w	d1,8(a1)
		move.w	d2,$10(a1)

locret_55FB6:				; CODE XREF: sub_55EB0+A2↑j
		rts
; END OF FUNCTION CHUNK FOR sub_55EB0

; =============== S U B R O U T I N E =======================================


sub_55FB8:					; CODE XREF: ROM:00055E90↑p
						; ROM:00055EA6↑p
		tst.b	$2D(a0)
		bne.s	locret_56016
		tst.b	$36(a0)
		beq.s	loc_55FE8
		move.w	$2E(a0),d0
		cmp.w	$C(a0),d0
		ble.s	loc_5600C
		tst.b	$2C(a0)
		beq.s	loc_55FE0
		move.w	$2A(a0),d0
		cmp.w	$C(a0),d0
		bge.s	loc_5600C
		rts
; ---------------------------------------------------------------------------

loc_55FE0:					; CODE XREF: sub_55FB8+1A↑j
		move.w	#$180,$12(a0)
		rts
; ---------------------------------------------------------------------------

loc_55FE8:					; CODE XREF: sub_55FB8+A↑j
		move.w	$2A(a0),d0
		cmp.w	$C(a0),d0
		bge.s	loc_5600C
		tst.b	$2C(a0)
		beq.s	loc_56004
		move.w	$2E(a0),d0
		cmp.w	$C(a0),d0
		ble.s	loc_5600C
		rts
; ---------------------------------------------------------------------------

loc_56004:					; CODE XREF: sub_55FB8+3E↑j
		move.w	#$FE80,$12(a0)
		rts
; ---------------------------------------------------------------------------

loc_5600C:					; CODE XREF: sub_55FB8+14↑j
						; sub_55FB8+24↑j ...
		move.w	d0,$C(a0)
		move.w	#0,$12(a0)

locret_56016:				; CODE XREF: sub_55FB8+4↑j
		rts
; End of function sub_55FB8
