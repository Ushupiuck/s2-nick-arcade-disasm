;----------------------------------------------------
; Object 12 - Master Emerald from HPZ
;----------------------------------------------------

Obj12:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj12_Index(pc,d0.w),d1
		jmp	Obj12_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj12_Index:	dc.w Obj12_Init-Obj12_Index
		dc.w Obj12_Display-Obj12_Index
; ---------------------------------------------------------------------------

Obj12_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj12,obMap(a0)
		move.w	#$6392,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$20,obActWid(a0)
		move.b	#4,obPriority(a0)

Obj12_Display:
		move.w	#$20,d1
		move.w	#$10,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		out_of_range.w  DeleteObject
		bra.w	DisplaySprite
