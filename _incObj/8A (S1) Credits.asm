; ---------------------------------------------------------------------------
; Object 8A - "SONIC TEAM PRESENTS" screen and credits
; ---------------------------------------------------------------------------

Obj8A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj8A_Index(pc,d0.w),d1
		jmp	Obj8A_Index(pc,d1.w)
; ===========================================================================
; off_185EE:
Obj8A_Index:	dc.w Obj8A_Init-Obj8A_Index
		dc.w Obj8A_Display-Obj8A_Index
; ===========================================================================
; loc_185F2:
Obj8A_Init:
		addq.b	#2,obRoutine(a0)
		move.w	#$120,obX(a0)
		move.w	#$F0,$A(a0)
		move.l	#Map_obj8A,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_4

; Obj8A_Credits:
		move.w	(v_creditsnum).w,d0		; load credits index number
		move.b	d0,obFrame(a0)			; display appropriate credits
		move.b	#0,obRender(a0)
		move.b	#0,obPriority(a0)

		cmpi.b	#GameModeID_TitleScreen,(v_gamemode).w ; is this the title screen?
		bne.s	Obj8A_Display			; if not, branch

; Obj8A_SonicTeam:
		move.w	#$300,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_4
		move.b	#$A,obFrame(a0)
		tst.b	(f_creditscheat).w		; is the Sonic 1 hidden credits cheat activated?
		beq.s	Obj8A_Display			; if not, branch
		cmpi.b	#$72,(v_jpadhold1).w		; has the player pressed A+B+C+Down?
		bne.s	Obj8A_Display			; if not, branch
		move.w	#$EEE,($FFFFFBC0).w		; 3rd palette, 1st entry = white
		move.w	#$880,($FFFFFBC2).w		; 2nd palette, 1st entry = cyan
		jmp	(DeleteObject).l
; ===========================================================================
; loc_18660:
Obj8A_Display:
		jmp	(DisplaySprite).l