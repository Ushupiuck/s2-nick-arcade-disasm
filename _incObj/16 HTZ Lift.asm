;----------------------------------------------------
; Object 16 - the HTZ platform that goes down diagonally
;	      and stops	after a	while (in final, it falls)
;----------------------------------------------------

Obj16:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj16_Index(pc,d0.w),d1
		jmp	Obj16_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj16_Index:	dc.w Obj16_Init-Obj16_Index
		dc.w Obj16_Main-Obj16_Index
; ---------------------------------------------------------------------------

Obj16_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj16,obMap(a0)
		move.w	#$43E6,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$20,obActWid(a0)
		move.b	#0,obFrame(a0)
		move.b	#1,obPriority(a0)
		move.w	obX(a0),$30(a0)
		move.w	obY(a0),$32(a0)

Obj16_Main:
		move.w	obX(a0),-(sp)
		bsr.w	sub_15184
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	#$FFD8,d3
		move.w	(sp)+,d4
		bsr.w	sub_F78A
		move.w	$30(a0),d0
		out_of_range.w	loc_152AA
		bra.w	loc_152A4

; =============== S U B	R O U T	I N E =======================================


sub_15184:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj16_SubIndex(pc,d0.w),d1
		jmp	Obj16_SubIndex(pc,d1.w)
; End of function sub_15184

; ---------------------------------------------------------------------------
Obj16_SubIndex:	dc.w Obj16_InitMove-Obj16_SubIndex
		dc.w Obj16_Move-Obj16_SubIndex
		dc.w Obj16_NoMove-Obj16_SubIndex
; ---------------------------------------------------------------------------

Obj16_InitMove:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		beq.s	locret_151BE
		addq.b	#1,obSubtype(a0)
		move.w	#$200,obVelX(a0)
		move.w	#$100,obVelY(a0)
		move.w	#$A0,$34(a0)

locret_151BE:
		rts
; ---------------------------------------------------------------------------

Obj16_Move:
		bsr.w	j_ObjectMove_0
		subq.w	#1,$34(a0)
		bne.s	locret_151CE
		addq.b	#1,obSubtype(a0)

locret_151CE:
		rts
; ---------------------------------------------------------------------------

Obj16_NoMove:
		rts