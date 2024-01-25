;----------------------------------------------------
; Object 0E - Sonic and Tails from the title screen
;----------------------------------------------------

Obj0E:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj0E_Index(pc,d0.w),d1
		jmp	Obj0E_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj0E_Index:	dc.w Obj0E_Init-Obj0E_Index
		dc.w Obj0E_Display-Obj0E_Index
		dc.w Obj0E_Move-Obj0E_Index
		dc.w Obj0E_Display2-Obj0E_Index
; ---------------------------------------------------------------------------

Obj0E_Init:
		addq.b	#2,obRoutine(a0)
		move.w	#$148,obX(a0)
		move.w	#$C4,obScreenY(a0)
		move.l	#Map_Obj0E,obMap(a0)
		move.w	#$4200,obGfx(a0)
		move.b	#1,obPriority(a0)
		move.b	#$1D,obDelayAni(a0)
		tst.b	obFrame(a0)
		beq.s	Obj0E_Display
		move.w	#$FC,obX(a0)
		move.w	#$CC,obScreenY(a0)
		move.w	#$2200,obGfx(a0)

Obj0E_Display:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
		subq.b	#1,obDelayAni(a0)		; Leftover Sonic 1 code
		bpl.s	locret_B3E2
		addq.b	#2,obRoutine(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

locret_B3E2:
		rts
; ---------------------------------------------------------------------------

Obj0E_Move:						; Leftover from Sonic 1 - scrolls infinitely due to different Y position
		subi.w	#8,obScreenY(a0)	
		cmpi.w	#$96,obScreenY(a0)
		bne.s	loc_B3F6
		addq.b	#2,obRoutine(a0)

loc_B3F6:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

Obj0E_Display2:
		bra.w	DisplaySprite
