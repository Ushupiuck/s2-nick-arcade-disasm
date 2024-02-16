S1Obj_53:						; leftover object from Sonic 1
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj_53_Index(pc,d0.w),d1
		jmp	S1Obj_53_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj_53_Index:	dc.w loc_8D6A-S1Obj_53_Index
		dc.w loc_8DB4-S1Obj_53_Index
		dc.w loc_8DEA-S1Obj_53_Index
; ---------------------------------------------------------------------------

loc_8D6A:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_S1Obj53,obMap(a0)
		move.w	#$42B8,obGfx(a0)
		cmpi.b	#3,(Current_Zone).w
		bne.s	loc_8D8E
		move.w	#$44E0,obGfx(a0)
		addq.b	#2,obFrame(a0)

loc_8D8E:
		cmpi.b	#5,(Current_Zone).w
		bne.s	loc_8D9C
		move.w	#$43F5,obGfx(a0)

loc_8D9C:
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#7,$38(a0)
		move.b	#$44,obActWid(a0)

loc_8DB4:
		tst.b	$3A(a0)
		beq.s	loc_8DC6
		tst.b	$38(a0)
		beq.w	loc_8E3E
		subq.b	#1,$38(a0)

loc_8DC6:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		beq.s	sub_8DD6
		move.b	#1,$3A(a0)

; =============== S U B	R O U T	I N E =======================================


sub_8DD6:
		move.w	#$20,d1
		move.w	#8,d3
		move.w	obX(a0),d4
		bsr.w	sub_F78A
		bra.w	MarkObjGone
; End of function sub_8DD6

; ---------------------------------------------------------------------------

loc_8DEA:
		tst.b	$38(a0)
		beq.s	loc_8E2E
		tst.b	$3A(a0)
		bne.s	loc_8DFE
		subq.b	#1,$38(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8DFE:
		bsr.w	sub_8DD6
		subq.b	#1,$38(a0)
		bne.s	locret_8E2C
		lea	(v_player).w,a1
		bsr.s	sub_8E12
		lea	(v_2ndplayer).w,a1

; =============== S U B	R O U T	I N E =======================================


sub_8E12:
		btst	#3,obStatus(a1)
		beq.s	locret_8E2C
		bclr	#3,obStatus(a1)
		bclr	#5,obStatus(a1)
		move.b	#1,obPrevAni(a1)

locret_8E2C:
		rts
; End of function sub_8E12

; ---------------------------------------------------------------------------

loc_8E2E:
		bsr.w	ObjectMoveAndFall
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8E3E:
		lea	(byte_8F17).l,a4
		btst	#0,obSubtype(a0)
		beq.s	loc_8E52
		lea	(byte_8F1F).l,a4

loc_8E52:
		addq.b	#1,obFrame(a0)
		bra.s	loc_8E70
; ---------------------------------------------------------------------------

loc_8E58:
		lea	(byte_8EF2).l,a4
		cmpi.b	#4,(Current_Zone).w
		bne.s	loc_8E6C
		lea	(byte_8F0B).l,a4

loc_8E6C:
		addq.b	#2,obFrame(a0)

loc_8E70:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3
		move.w	(a3)+,d1
		subq.w	#1,d1
		bset	#5,obRender(a0)
		_move.b	obID(a0),d4
		move.b	obRender(a0),d5
		movea.l	a0,a1
		bra.s	loc_8E9E
; ---------------------------------------------------------------------------

loc_8E96:
		bsr.w	FindFreeObj
		bne.s	loc_8EE4
		addq.w	#8,a3

loc_8E9E:
		move.b	#4,obRoutine(a1)
		_move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.b	obHeight(a0),obHeight(a1)
		move.b	(a4)+,$38(a1)
		cmpa.l	a0,a1
		bcc.s	loc_8EE0
		bsr.w	DisplaySprite2

loc_8EE0:
		dbf	d1,loc_8E96

loc_8EE4:
		bsr.w	DisplaySprite
		move.w	#sfx_Collapse,d0
		jmp	(PlaySound_Special).l