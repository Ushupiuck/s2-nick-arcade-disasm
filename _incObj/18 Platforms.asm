; ---------------------------------------------------------------------------

Obj18:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj18_Index(pc,d0.w),d1
		jmp	Obj18_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj18_Index:	dc.w loc_882C-Obj18_Index
		dc.w loc_88A2-Obj18_Index
		dc.w loc_8908-Obj18_Index
		dc.w loc_88E0-Obj18_Index
Obj18_Conf:	dc.w $2000
		dc.w $2001
		dc.w $2002
		dc.w $4003
		dc.w $3004
; ---------------------------------------------------------------------------

loc_882C:
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj18_Conf(pc,d0.w),a2
		move.b	(a2)+,obActWid(a0)
		move.b	(a2)+,obFrame(a0)
		move.w	#$4000,obGfx(a0)
		move.l	#Map_Obj18,obMap(a0)
		cmpi.b	#3,(Current_Zone).w
		beq.s	loc_8866
		cmpi.b	#5,(Current_Zone).w
		bne.s	loc_8874

loc_8866:
		move.l	#Map_obj18_EHZ,obMap(a0)
		move.w	#$4000,obGfx(a0)

loc_8874:
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.w	obY(a0),$2C(a0)
		move.w	obY(a0),$34(a0)
		move.w	obX(a0),$32(a0)
		move.w	#$80,obAngle(a0)
		andi.b	#$F,obSubtype(a0)

loc_88A2:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		bne.s	loc_88B8
		tst.b	$38(a0)
		beq.s	loc_88C4
		subq.b	#4,$38(a0)
		bra.s	loc_88C4
; ---------------------------------------------------------------------------

loc_88B8:
		cmpi.b	#$40,$38(a0)
		beq.s	loc_88C4
		addq.b	#4,$38(a0)

loc_88C4:
		move.w	obX(a0),-(sp)
		bsr.w	sub_8926
		bsr.w	sub_890C
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#8,d3
		move.w	(sp)+,d4
		bsr.w	sub_F78A
		bra.s	loc_88E8
; ---------------------------------------------------------------------------

loc_88E0:
		bsr.w	sub_8926
		bsr.w	sub_890C

loc_88E8:
		tst.w	(Two_player_mode).w
		beq.s	loc_88F2
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_88F2:
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		sub.w	(v_screenposx_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_8908
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8908:
		bra.w	DeleteObject

; =============== S U B	R O U T	I N E =======================================


sub_890C:
		move.b	$38(a0),d0
		bsr.w	CalcSine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	$2C(a0),d0
		move.w	d0,obY(a0)
		rts
; End of function sub_890C


; =============== S U B	R O U T	I N E =======================================


sub_8926:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	off_893A(pc,d0.w),d1
		jmp	off_893A(pc,d1.w)
; End of function sub_8926

; ---------------------------------------------------------------------------
off_893A:	dc.w locret_8956-off_893A
		dc.w loc_8968-off_893A
		dc.w loc_89AE-off_893A
		dc.w loc_89C6-off_893A
		dc.w loc_89EE-off_893A
		dc.w loc_8958-off_893A
		dc.w loc_899E-off_893A
		dc.w loc_8A5C-off_893A
		dc.w loc_8A88-off_893A
		dc.w locret_8956-off_893A
		dc.w loc_8AA0-off_893A
		dc.w loc_8ABA-off_893A
		dc.w loc_8990-off_893A
		dc.w loc_8980-off_893A
; ---------------------------------------------------------------------------

locret_8956:
		rts
; ---------------------------------------------------------------------------

loc_8958:
		move.w	$32(a0),d0
		move.b	obAngle(a0),d1
		neg.b	d1
		addi.b	#$40,d1
		bra.s	loc_8974
; ---------------------------------------------------------------------------

loc_8968:
		move.w	$32(a0),d0
		move.b	obAngle(a0),d1
		subi.b	#$40,d1

loc_8974:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,obX(a0)
		bra.w	loc_8AD2
; ---------------------------------------------------------------------------

loc_8980:
		move.w	$34(a0),d0
		move.b	(v_oscillate+$E).w,d1
		neg.b	d1
		addi.b	#$30,d1
		bra.s	loc_89BA
; ---------------------------------------------------------------------------

loc_8990:
		move.w	$34(a0),d0
		move.b	(v_oscillate+$E).w,d1
		subi.b	#$30,d1
		bra.s	loc_89BA
; ---------------------------------------------------------------------------

loc_899E:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		neg.b	d1
		addi.b	#$40,d1
		bra.s	loc_89BA
; ---------------------------------------------------------------------------

loc_89AE:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		subi.b	#$40,d1

loc_89BA:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,$2C(a0)
		bra.w	loc_8AD2
; ---------------------------------------------------------------------------

loc_89C6:
		tst.w	$3A(a0)
		bne.s	loc_89DC
		btst	#3,obStatus(a0)
		beq.s	locret_89DA
		move.w	#$1E,$3A(a0)

locret_89DA:
		rts
; ---------------------------------------------------------------------------

loc_89DC:
		subq.w	#1,$3A(a0)
		bne.s	locret_89DA
		move.w	#$20,$3A(a0)
		addq.b	#1,obSubtype(a0)
		rts
; ---------------------------------------------------------------------------

loc_89EE:
		tst.w	$3A(a0)
		beq.s	loc_8A2E
		subq.w	#1,$3A(a0)
		bne.s	loc_8A2E
		btst	#3,obStatus(a0)
		beq.s	loc_8A28
		lea	(v_player).w,a1
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		clr.b	ob2ndRout(a0)
		move.w	obVelY(a0),obVelY(a1)

loc_8A28:
		move.b	#6,obRoutine(a0)

loc_8A2E:
		move.l	$2C(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d3,$2C(a0)
		addi.w	#$38,obVelY(a0)
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$2C(a0),d0
		bcc.s	locret_8A5A
		move.b	#4,obRoutine(a0)

locret_8A5A:
		rts
; ---------------------------------------------------------------------------

loc_8A5C:
		tst.w	$3A(a0)
		bne.s	loc_8A7C
		lea	(f_switch).w,a2
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsr.w	#4,d0
		tst.b	(a2,d0.w)
		beq.s	locret_8A7A
		move.w	#$3C,$3A(a0)

locret_8A7A:
		rts
; ---------------------------------------------------------------------------

loc_8A7C:
		subq.w	#1,$3A(a0)
		bne.s	locret_8A7A
		addq.b	#1,obSubtype(a0)
		rts
; ---------------------------------------------------------------------------

loc_8A88:
		subq.w	#2,$2C(a0)
		move.w	$34(a0),d0
		subi.w	#$200,d0
		cmp.w	$2C(a0),d0
		bne.s	locret_8A9E
		clr.b	obSubtype(a0)

locret_8A9E:
		rts
; ---------------------------------------------------------------------------

loc_8AA0:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		subi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,$2C(a0)
		bra.w	loc_8AD2
; ---------------------------------------------------------------------------

loc_8ABA:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		neg.b	d1
		addi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,$2C(a0)

loc_8AD2:
		move.b	(v_oscillate+$1A).w,obAngle(a0)
		rts