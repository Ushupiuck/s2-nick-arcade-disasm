Obj1C:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj1C_Index(pc,d0.w),d1
		jmp	Obj1C_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj1C_Index:	dc.w loc_93F4-Obj1C_Index
		dc.w loc_9442-Obj1C_Index
		dc.w loc_9464-Obj1C_Index
Obj1C_Conf:	dc.l Map_obj11_HPZ
		dc.w $6300
		dc.b   3,  4,  1,  0			; 0
		dc.l Map_Obj1C_01
		dc.w $E35A
		dc.b   0,$10,  1,  0			; 0
		dc.l Map_obj11
		dc.w $43C6
		dc.b   1,  4,  1,  0			; 0
		dc.l Map_obj11_GHZ
		dc.w $44C6
		dc.b   1,$10,  1,  0			; 0
		dc.l Map_Obj16
		dc.w $43E6
		dc.b   1,  8,  4,  0			; 0
		dc.l Map_Obj16
		dc.w $43E6
		dc.b   2,  8,  4,  0			; 0
; ---------------------------------------------------------------------------

loc_93F4:
		addq.b	#2,obRoutine(a0)
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		mulu.w	#10,d0
		lea	Obj1C_Conf(pc,d0.w),a1
		move.l	(a1)+,obMap(a0)
		move.w	(a1)+,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obActWid(a0)
		move.b	(a1)+,obPriority(a0)
		move.b	(a1)+,obColType(a0)
		move.b	obSubtype(a0),d0
		andi.w	#$F0,d0
		beq.s	loc_9442
		addq.b	#2,obRoutine(a0)
		lsr.b	#4,d0
		subq.b	#1,d0
		move.b	d0,obAnim(a0)
		bra.s	loc_9464
; ---------------------------------------------------------------------------

loc_9442:
		tst.w	(Two_player_mode).w
		beq.s	loc_944C
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_944C:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9464:
		lea	(Ani_Obj1C).l,a1
		bsr.w	AnimateSprite
		tst.w	(Two_player_mode).w
		beq.s	loc_9478
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9478:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite