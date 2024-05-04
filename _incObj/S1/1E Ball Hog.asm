;----------------------------------------------------
; Sonic	1 Object 1E - leftover Ballhog object
;----------------------------------------------------

S1Obj_1E:						; leftover from Sonic 1
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj_1E_Index(pc,d0.w),d1
		jmp	S1Obj_1E_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj_1E_Index:	dc.w loc_966E-S1Obj_1E_Index
		dc.w loc_96C2-S1Obj_1E_Index
; ---------------------------------------------------------------------------

loc_966E:
		move.b	#$13,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.l	#Map_S1Obj1E,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ball_Hog,1,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#5,obColType(a0)
		move.b	#$C,obActWid(a0)
		bsr.w	ObjectMoveAndFall
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_96C0
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)

locret_96C0:
		rts
; ---------------------------------------------------------------------------

loc_96C2:
		lea	(Ani_S1Obj1E).l,a1
		bsr.w	AnimateSprite
		cmpi.b	#1,obFrame(a0)
		bne.s	loc_96DC
		tst.b	$32(a0)
		beq.s	loc_96E4
		bra.s	loc_96E0
; ---------------------------------------------------------------------------

loc_96DC:
		clr.b	$32(a0)

loc_96E0:
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------

loc_96E4:
		move.b	#1,$32(a0)
		bsr.w	FindFreeObj
		bne.s	loc_972E
		_move.b	#$20,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$FF00,obVelX(a1)
		move.w	#0,obVelY(a1)
		moveq	#-4,d0
		btst	#0,obStatus(a0)
		beq.s	loc_971E
		neg.w	d0
		neg.w	obVelX(a1)

loc_971E:
		add.w	d0,obX(a1)
		addi.w	#$C,obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)

loc_972E:
		bra.s	loc_96E0