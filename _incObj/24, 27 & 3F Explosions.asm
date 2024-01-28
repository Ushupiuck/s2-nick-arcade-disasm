;----------------------------------------------------
; Object 24 - explosion	from a hit monitor
;----------------------------------------------------

Obj24:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj24_Index(pc,d0.w),d1
		jmp	Obj24_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj24_Index:	dc.w loc_981A-Obj24_Index
		dc.w loc_985E-Obj24_Index
; ---------------------------------------------------------------------------

loc_981A:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj24,obMap(a0)
		move.w	#$41C,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#9,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		move.w	#sfx_A5,d0
		jsr	(PlaySound_Special).l

loc_985E:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9878
		move.b	#9,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#4,obFrame(a0)
		beq.w	DeleteObject

loc_9878:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 27 - explosion	from a hit enemy
;----------------------------------------------------

Obj27:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj27_Index(pc,d0.w),d1
		jmp	Obj27_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj27_Index:	dc.w loc_9890-Obj27_Index
		dc.w loc_98B2-Obj27_Index
		dc.w loc_98F6-Obj27_Index
; ---------------------------------------------------------------------------

loc_9890:
		addq.b	#2,obRoutine(a0)
		bsr.w	FindFreeObj
		bne.s	loc_98B2
		_move.b	#$28,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	$3E(a0),$3E(a1)

loc_98B2:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj27,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		move.w	#sfx_BreakItem,d0
		jsr	(PlaySound_Special).l

loc_98F6:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9910
		move.b	#7,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#5,obFrame(a0)
		beq.w	DeleteObject

loc_9910:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 3F - Explosion
;----------------------------------------------------

Obj3F:
		moveq	#0,d0				; explosion object
		move.b	obRoutine(a0),d0
		move.w	Obj3F_Index(pc,d0.w),d1
		jmp	Obj3F_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj3F_Index:	dc.w loc_9926-Obj3F_Index
		dc.w loc_98F6-Obj3F_Index
; ---------------------------------------------------------------------------

loc_9926:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj3F,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		move.w	#sfx_Bomb,d0
		jmp	(PlaySound_Special).l