S1Obj64:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj64_Index(pc,d0.w),d1
		jmp	S1Obj64_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj64_Index:	dc.w S1Obj64_Init-S1Obj64_Index
		dc.w S1Obj64_Animate-S1Obj64_Index
		dc.w S1Obj64_ChkWater-S1Obj64_Index
		dc.w S1Obj64_Display-S1Obj64_Index
		dc.w S1Obj64_Delete-S1Obj64_Index
		dc.w S1Obj64_BblMaker-S1Obj64_Index
; ---------------------------------------------------------------------------

S1Obj64_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj0A_Bubbles,obMap(a0)
		move.w	#$8348,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#$84,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#1,obPriority(a0)
		move.b	obSubtype(a0),d0
		bpl.s	loc_13A32
		addq.b	#8,obRoutine(a0)
		andi.w	#$7F,d0
		move.b	d0,$32(a0)
		move.b	d0,$33(a0)
		move.b	#6,obAnim(a0)
		bra.w	S1Obj64_BblMaker
; ---------------------------------------------------------------------------

loc_13A32:
		move.b	d0,obAnim(a0)
		move.w	obX(a0),$30(a0)
		move.w	#$FF78,obVelY(a0)
		jsr	(RandomNumber).l
		move.b	d0,obAngle(a0)

S1Obj64_Animate:
		lea	(Ani_S1Obj64).l,a1
		jsr	(AnimateSprite).l
		cmpi.b	#6,obFrame(a0)
		bne.s	S1Obj64_ChkWater
		move.b	#1,$2E(a0)

S1Obj64_ChkWater:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bcs.s	loc_13A7E

loc_13A70:
		move.b	#6,obRoutine(a0)
		addq.b	#3,obAnim(a0)
		bra.w	S1Obj64_Display
; ---------------------------------------------------------------------------

loc_13A7E:
		move.b	obAngle(a0),d0
		addq.b	#1,obAngle(a0)
		andi.w	#$7F,d0
		lea	(Obj0A_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$30(a0),d0
		move.w	d0,obX(a0)
		tst.b	$2E(a0)
		beq.s	loc_13B0A
		bsr.w	S1Obj64_ChkSonic
		beq.s	loc_13B0A
		bsr.w	ResumeMusic
		move.w	#sfx_Bubble,d0
		jsr	(PlaySound_Special).l
		lea	(v_player).w,a1
		clr.w	obVelX(a1)
		clr.w	obVelY(a1)
		clr.w	obInertia(a1)
		move.b	#$15,obAnim(a1)
		move.w	#$23,$2E(a1)
		move.b	#0,$3C(a1)
		bclr	#5,obStatus(a1)
		bclr	#4,obStatus(a1)
		btst	#2,obStatus(a1)
		beq.w	loc_13A70
		bclr	#2,obStatus(a1)
		move.b	#$13,obHeight(a1)
		move.b	#9,obWidth(a1)
		subq.w	#5,obY(a1)
		bra.w	loc_13A70
; ---------------------------------------------------------------------------

loc_13B0A:
		bsr.w	ObjectMove
		tst.b	obRender(a0)
		bpl.s	loc_13B1A
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_13B1A:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

S1Obj64_Display:
		lea	(Ani_S1Obj64).l,a1
		jsr	(AnimateSprite).l
		tst.b	obRender(a0)
		bpl.s	loc_13B38
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_13B38:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

S1Obj64_Delete:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------

S1Obj64_BblMaker:
		tst.w	$36(a0)
		bne.s	loc_13BA4
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bcc.w	loc_13C50
		tst.b	obRender(a0)
		bpl.w	loc_13C50
		subq.w	#1,$38(a0)
		bpl.w	loc_13C44
		move.w	#1,$36(a0)

loc_13B6A:
		jsr	(RandomNumber).l
		move.w	d0,d1
		andi.w	#7,d0
		cmpi.w	#6,d0
		bcc.s	loc_13B6A
		move.b	d0,$34(a0)
		andi.w	#$C,d1
		lea	(S1Obj64_BblTypes).l,a1
		adda.w	d1,a1
		move.l	a1,$3C(a0)
		subq.b	#1,$32(a0)
		bpl.s	loc_13BA2
		move.b	$33(a0),$32(a0)
		bset	#7,$36(a0)

loc_13BA2:
		bra.s	loc_13BAC
; ---------------------------------------------------------------------------

loc_13BA4:
		subq.w	#1,$38(a0)
		bpl.w	loc_13C44

loc_13BAC:
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		move.w	d0,$38(a0)
		bsr.w	FindFreeObj
		bne.s	loc_13C28
		_move.b	#$64,obID(a1)
		move.w	obX(a0),obX(a1)
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	d0,obX(a1)
		move.w	obY(a0),obY(a1)
		moveq	#0,d0
		move.b	$34(a0),d0
		movea.l	$3C(a0),a2
		move.b	(a2,d0.w),obSubtype(a1)
		btst	#7,$36(a0)
		beq.s	loc_13C28
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	loc_13C14
		bset	#6,$36(a0)
		bne.s	loc_13C28
		move.b	#2,obSubtype(a1)

loc_13C14:
		tst.b	$34(a0)
		bne.s	loc_13C28
		bset	#6,$36(a0)
		bne.s	loc_13C28
		move.b	#2,obSubtype(a1)

loc_13C28:
		subq.b	#1,$34(a0)
		bpl.s	loc_13C44
		jsr	(RandomNumber).l
		andi.w	#$7F,d0
		addi.w	#$80,d0
		add.w	d0,$38(a0)
		clr.w	$36(a0)

loc_13C44:
		lea	(Ani_S1Obj64).l,a1
		jsr	(AnimateSprite).l

loc_13C50:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bcs.w	DisplaySprite
		rts
; ---------------------------------------------------------------------------
S1Obj64_BblTypes:dc.b	0,  1,	0,  0,	0,  0,	1,  0,	0 ; 0
		dc.b   0,  0,  1,  0,  1,  0,  0,  1,  0 ; 9

; =============== S U B	R O U T	I N E =======================================


S1Obj64_ChkSonic:
		tst.b	(f_playerctrl).w
		bmi.s	loc_13CBE
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		move.w	obX(a0),d1
		subi.w	#$10,d1
		cmp.w	d0,d1
		bcc.s	loc_13CBE
		addi.w	#$20,d1
		cmp.w	d0,d1
		bcs.s	loc_13CBE
		move.w	obY(a1),d0
		move.w	obY(a0),d1
		cmp.w	d0,d1
		bcc.s	loc_13CBE
		addi.w	#$10,d1
		cmp.w	d0,d1
		bcs.s	loc_13CBE
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

loc_13CBE:
		moveq	#0,d0
		rts
; End of function S1Obj64_ChkSonic