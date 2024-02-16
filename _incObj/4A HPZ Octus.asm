; ---------------------------------------------------------------------------
; Object 4A - Octopus badnik
; ---------------------------------------------------------------------------

Obj4A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj4A_Index(pc,d0.w),d1
		jmp	Obj4A_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj4A_Index:	dc.w loc_16ADE-Obj4A_Index
		dc.w loc_16B44-Obj4A_Index
		dc.w loc_16AD2-Obj4A_Index
		dc.w loc_16AB6-Obj4A_Index
; ---------------------------------------------------------------------------

loc_16AB6:
		subi.w	#1,$2C(a0)
		bmi.s	loc_16AC0
		rts
; ---------------------------------------------------------------------------

loc_16AC0:
		bsr.w	j_ObjectMoveAndFall_3
		lea	(Ani_Obj4A).l,a1
		bsr.w	j_AnimateSprite_5
		bra.w	loc_16D3C
; ---------------------------------------------------------------------------

loc_16AD2:
		subq.w	#1,$2C(a0)
		beq.w	loc_16D36
		bra.w	loc_16D30
; ---------------------------------------------------------------------------

loc_16ADE:
		move.l	#Map_Obj4A,obMap(a0)
		move.w	#$238A,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
		bsr.w	j_ObjectMoveAndFall_3
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_16B3C
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0
		bpl.s	loc_16B3C
		bchg	#0,obStatus(a0)

loc_16B3C:
		move.w	obY(a0),$2A(a0)
		rts
; ---------------------------------------------------------------------------

loc_16B44:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj4A_SubIndex(pc,d0.w),d1
		jsr	Obj4A_SubIndex(pc,d1.w)
		lea	(Ani_Obj4A).l,a1
		bsr.w	j_AnimateSprite_5
		bra.w	loc_16D3C
; ---------------------------------------------------------------------------
Obj4A_SubIndex:	dc.w Obj4A_Init-Obj4A_SubIndex
		dc.w Obj4A_Main-Obj4A_SubIndex
		dc.w loc_16BAA-Obj4A_SubIndex
		dc.w loc_16C7C-Obj4A_SubIndex
; ---------------------------------------------------------------------------

Obj4A_Init:
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0
		cmpi.w	#$80,d0
		bgt.s	locret_16B86
		cmpi.w	#$FF80,d0
		blt.s	locret_16B86
		addq.b	#2,ob2ndRout(a0)
		move.b	#1,obAnim(a0)

locret_16B86:
		rts
; ---------------------------------------------------------------------------

Obj4A_Main:
		subi.l	#$18000,obY(a0)
		move.w	$2A(a0),d0
		sub.w	obY(a0),d0
		cmpi.w	#$20,d0
		ble.s	locret_16BA8
		addq.b	#2,ob2ndRout(a0)
		move.w	#0,$2C(a0)

locret_16BA8:
		rts
; ---------------------------------------------------------------------------

loc_16BAA:
		subi.w	#1,$2C(a0)
		beq.w	loc_16C76
		bpl.w	locret_16C74
		move.w	#$1E,$2C(a0)
		jsr	(FindFreeObj).l
		bne.s	loc_16C10
		_move.b	#$4A,obID(a1)
		move.b	#4,obRoutine(a1)
		move.l	#Map_Obj4A,obMap(a1)
		move.b	#4,obFrame(a1)
		move.w	#$24C6,obGfx(a1)
		move.b	#3,obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$1E,$2C(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	obStatus(a0),obStatus(a1)

loc_16C10:
		jsr	(FindFreeObj).l
		bne.s	locret_16C74
		_move.b	#$4A,obID(a1)
		move.b	#6,obRoutine(a1)
		move.l	#Map_Obj4A,obMap(a1)
		move.w	#$24C6,obGfx(a1)
		move.b	#4,obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$F,$2C(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)
		move.w	#$FA80,obVelX(a1)
		btst	#0,obRender(a1)
		beq.s	locret_16C74
		neg.w	obVelX(a1)

locret_16C74:
		rts
; ---------------------------------------------------------------------------

loc_16C76:
		addq.b	#2,ob2ndRout(a0)
		rts
; ---------------------------------------------------------------------------

loc_16C7C:
		move.w	#$FFFA,d0
		btst	#0,obRender(a0)
		beq.s	loc_16C8A
		neg.w	d0

loc_16C8A:
		add.w	d0,obX(a0)
		bra.w	loc_16D3C