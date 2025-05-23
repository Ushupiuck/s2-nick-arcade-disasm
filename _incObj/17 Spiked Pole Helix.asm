; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)
; ---------------------------------------------------------------------------

Obj17:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj17_Index(pc,d0.w),d1
		jmp	Obj17_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj17_Index:	dc.w Hel_Main-Obj17_Index	; 0
		dc.w Hel_Action-Obj17_Index	; 2
		dc.w Hel_Display-Obj17_Index	; 4

hel_frame = objoff_3E		; start frame (different for each spike)

;		$29-38 are used for child object addresses
; ---------------------------------------------------------------------------

Hel_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)	; -> Hel_Action
		move.l	#Map_Obj17,obMap(a0)
		move.w	#$4398,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#7,obStatus(a0)
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		_move.b	obID(a0),d4
		lea	obSubtype(a0),a2 ; move helix length to a2
		moveq	#0,d1
		move.b	(a2),d1		; move helix length to d1
		move.b	#0,(a2)+	; clear subtype
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3		; d3 is x-axis position of leftmost spike
		subq.b	#2,d1
		bcs.s	Hel_Action	; skip to action if length is only 1
		moveq	#0,d6

Hel_Build:
		bsr.w	FindNextFreeObj
		bne.s	Hel_Action
		addq.b	#1,obSubtype(a0)
		move.w	a1,d5
		subi.w	#v_objspace,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+	; copy child address to parent RAM
		move.b	#4,obRoutine(a1)	; -> Hel_Display
		_move.b	d4,obID(a1)
		move.w	d2,obY(a1)
		move.w	d3,obX(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	#$4398,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#4,obRender(a1)
		move.b	#3,obPriority(a1)
		move.b	#8,obActWid(a1)
		move.b	d6,hel_frame(a1)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		cmp.w	obX(a0),d3	; is this spike in the centre?
		bne.s	Hel_NotCentre	; if not, branch

		move.b	d6,hel_frame(a0) ; set parent spike frame
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3		; skip to next spike
		addq.b	#1,obSubtype(a0)

Hel_NotCentre:
		dbf	d1,Hel_Build ; repeat d1 times (helix length)

Hel_Action:	; Routine 2, 4
		bsr.w	Hel_RotateSpikes
		out_of_range.s	Hel_DelAll
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

Hel_DelAll:
		moveq	#0,d2
		lea	obSubtype(a0),a2 ; move helix length to a2
		move.b	(a2)+,d2	; move helix length to d2
		subq.b	#2,d2
		bcs.s	Hel_Delete

Hel_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace,d0
		movea.l	d0,a1		; get child address
		bsr.w	DeleteObject2	; delete object
		dbf	d2,Hel_DelLoop ; repeat d2 times (helix length)

Hel_Delete:
		bra.w	DeleteObject

; =============== S U B	R O U T	I N E =======================================


Hel_RotateSpikes:
		move.b	(v_ani0_frame).w,d0
		move.b	#0,obColType(a0) ; make object harmless
		add.b	hel_frame(a0),d0
		andi.b	#7,d0
		move.b	d0,obFrame(a0)	; change current frame
		bne.s	locret_87AA
		move.b	#$84,obColType(a0) ; make object harmful

locret_87AA:
		rts
; End of function Hel_RotateSpikes
; ---------------------------------------------------------------------------

Hel_Display:
		bsr.w	Hel_RotateSpikes
		bra.w	DisplaySprite