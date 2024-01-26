S1Obj47:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj47_Index(pc,d0.w),d1
		jmp	S1Obj47_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj47_Index:	dc.w S1Obj47_Init-S1Obj47_Index
		dc.w S1Obj47_Main-S1Obj47_Index
; ---------------------------------------------------------------------------

S1Obj47_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_S1Obj47,obMap(a0)
		move.w	#$380,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#1,obPriority(a0)
		move.b	#$D7,obColType(a0)

S1Obj47_Main:
		move.b	obColProp(a0),d0
		beq.w	loc_13976
		lea	(v_player).w,a1
		bclr	#0,obColProp(a0)
		beq.s	loc_138CA
		bsr.s	S1Obj47_Bump

loc_138CA:
		lea	(v_2ndplayer).w,a1
		bclr	#1,obColProp(a0)
		beq.s	loc_138D8
		bsr.s	S1Obj47_Bump

loc_138D8:
		clr.b	obColProp(a0)
		bra.w	loc_13976

; =============== S U B	R O U T	I N E =======================================


S1Obj47_Bump:
		move.w	obX(a0),d1
		move.w	obY(a0),d2
		sub.w	obX(a1),d1
		sub.w	obY(a1),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#$F900,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a1)
		muls.w	#$F900,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a1)
		bset	#1,obStatus(a1)
		bclr	#4,obStatus(a1)
		bclr	#5,obStatus(a1)
		clr.b	$3C(a1)
		move.b	#1,obAnim(a0)
		move.w	#sfx_Bumper,d0
		jsr	(PlaySound_Special).l
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_1394E
		cmpi.b	#$8A,2(a2,d0.w)
		bcc.s	locret_13974
		addq.b	#1,2(a2,d0.w)

loc_1394E:
		moveq	#1,d0
		jsr	(AddPoints).l
		bsr.w	FindFreeObj
		bne.s	locret_13974
		_move.b	#$29,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#4,obFrame(a1)

locret_13974:
		rts
; End of function S1Obj47_Bump

; ---------------------------------------------------------------------------

loc_13976:
		lea	(Ani_S1Obj47).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone