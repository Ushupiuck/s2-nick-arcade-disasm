;----------------------------------------------------
; Object 29 - points that appear when you destroy something
;----------------------------------------------------

Obj29:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj29_Index(pc,d0.w),d1
		jmp	Obj29_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj29_Index:	dc.w Obj29_Init-Obj29_Index
		dc.w Obj29_Display-Obj29_Index
; ---------------------------------------------------------------------------

Obj29_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj29,obMap(a0)
		move.w	#$4AC,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	#$FD00,obVelY(a0)

Obj29_Display:
		tst.w	obVelY(a0)
		bpl.w	DeleteObject
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		bra.w	DisplaySprite