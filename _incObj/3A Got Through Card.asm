; ---------------------------------------------------------------------------
; Object 3A - End of level results screen
; ---------------------------------------------------------------------------

Obj3A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj3A_Index(pc,d0.w),d1
		jmp	Obj3A_Index(pc,d1.w)
; ===========================================================================
Obj3A_Index:	dc.w Obj3A_ChkPLC-Obj3A_Index
		dc.w Obj3A_ChkPos-Obj3A_Index
		dc.w Obj3A_Wait-Obj3A_Index
		dc.w Obj3A_NextLevel-Obj3A_Index
; ===========================================================================
; loc_BB5C:
Obj3A_ChkPLC:
		tst.l	(v_plc_buffer).w
		beq.s	Obj3A_Config
		rts
; ---------------------------------------------------------------------------
; loc_BB64:
Obj3A_Config:
		movea.l	a0,a1
		lea	(Obj3A_Conf).l,a2
		moveq	#6,d1
; loc_BB6E:
Obj3A_Init:
		_move.b	#$3A,obID(a1)
		move.w	(a2),obX(a1)
		move.w	(a2)+,$32(a1)
		move.w	(a2)+,$30(a1)
		move.w	(a2)+,$A(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,d0
		cmpi.b	#6,d0
		bne.s	loc_BB94
		add.b	(Current_Act).w,d0

loc_BB94:
		move.b	d0,obFrame(a1)
		move.l	#Map_Obj3A,obMap(a1)
		move.w	#$8580,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#0,obRender(a1)
		lea	$40(a1),a1
		dbf	d1,Obj3A_Init
; loc_BBB8:
Obj3A_ChkPos:
		moveq	#$10,d1
		move.w	$30(a0),d0
		cmp.w	obX(a0),d0
		beq.s	loc_BBEA
		bge.s	Obj3A_Move
		neg.w	d1
; loc_BBC8:
Obj3A_Move
		add.w	d1,obX(a0)

loc_BBCC:
		move.w	obX(a0),d0
		bmi.s	locret_BBDE
		cmpi.w	#$200,d0
		bcc.s	locret_BBDE
		rts					; This return instruction makes the object not display.
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite
; ===========================================================================

locret_BBDE:
		rts
; ===========================================================================

loc_BBE0:
		move.b	#$E,obRoutine(a0)
		bra.w	loc_BCF8
; ===========================================================================

loc_BBEA:
		cmpi.b	#$E,(v_objspace+$700+obRoutine).w
		beq.s	loc_BBE0
		cmpi.b	#4,obFrame(a0)
		bne.s	loc_BBCC
		addq.b	#2,obRoutine(a0)
		move.w	#$B4,obTimeFrame(a0)
; loc_BC04:
Obj3A_Wait:
		subq.w	#1,obTimeFrame(a0)
		bne.s	locret_BC0E
		addq.b	#2,obRoutine(a0)

locret_BC0E:
		rts					; This return instruction makes the object not display.
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite			; A pointless branch due to the return above...
							; though, if you attempt to restore the original functionality,
							; it does not get enough time to count down all the way.
; ===========================================================================
; Obj3A_TimeBonus:
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w
		moveq	#0,d0
		tst.w	(v_timebonus).w
		beq.s	Obj3A_RingBonus
		addi.w	#10,d0
		subi.w	#10,(v_timebonus).w
; loc_BC30:
Obj3A_RingBonus:
		tst.w	(v_ringbonus).w
		beq.s	Obj3A_ChkBonus
		addi.w	#10,d0
		subi.w	#10,(v_ringbonus).w
; loc_BC40:
Obj3A_ChkBonus:
		tst.w	d0
		bne.s	Obj3A_AddBonus
		move.w	#sfx_Cash,d0
		jsr	(PlaySound_Special).l
		addq.b	#2,obRoutine(a0)
		cmpi.w	#$501,(Current_ZoneAndAct).w
		bne.s	Obj3A_SetDelay
		addq.b	#4,obRoutine(a0)
; loc_BC5E:
Obj3A_SetDelay:
		move.w	#$B4,obTimeFrame(a0)

locret_BC64:
		rts
; ===========================================================================
; loc_BC66:
Obj3A_AddBonus:
		jsr	(AddPoints).l
		move.b	($FFFFFE0F).w,d0
		andi.b	#3,d0
		bne.s	locret_BC64
		move.w	#sfx_Switch,d0
		jmp	(PlaySound_Special).l
; ===========================================================================
; loc_BC80:
Obj3A_NextLevel:
		move.b	(Current_Zone).w,d0
		andi.w	#7,d0
		lsl.w	#3,d0
		move.b	(Current_Act).w,d1
		andi.w	#3,d1
		add.w	d1,d1
		add.w	d1,d0
		move.w	LevelOrder(pc,d0.w),d0
		move.w	d0,(Current_ZoneAndAct).w
		tst.w	d0
		bne.s	Obj3A_ChkSS
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		bra.s	locret_BCC2
; ===========================================================================
; loc_BCAA:
Obj3A_ChkSS:
		clr.b	(v_lastlamp).w
		tst.b	(f_bigring).w
		beq.s	loc_BCBC
		move.b	#GameModeID_SpecialStage,(v_gamemode).w
		bra.s	locret_BCC2
; ===========================================================================

loc_BCBC:
		move.w	#1,(Level_Inactive_flag).w

locret_BCC2:
		rts					; This return instruction makes the object not display.
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
LevelOrder:	dc.w	 1,    2, $200,	   0		; 0
		dc.w  $101, $102, $300,	$502		; 4
		dc.w  $201, $202, $400,	   0		; 8
		dc.w  $301, $302, $500,	   0		; 12
		dc.w  $401, $402, $100,	   0		; 16
		dc.w  $501, $103,    0,	   0		; 20
; ---------------------------------------------------------------------------

loc_BCF8:
		moveq	#$20,d1
		move.w	$32(a0),d0
		cmp.w	obX(a0),d0
		beq.s	loc_BD1E
		bge.s	loc_BD08
		neg.w	d1

loc_BD08:
		add.w	d1,obX(a0)
		move.w	obX(a0),d0
		bmi.s	locret_BD1C
		cmpi.w	#$200,d0
		bcc.s	locret_BD1C
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

locret_BD1C:
		rts
; ---------------------------------------------------------------------------

loc_BD1E:
		cmpi.b	#4,obFrame(a0)
		bne.w	DeleteObject
		addq.b	#2,obRoutine(a0)
		clr.b	(f_lockctrl).w
		move.w	#bgm_FZ,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------
		addq.w	#2,(Camera_Max_X_pos).w
		cmpi.w	#$2100,(Camera_Max_X_pos).w
		beq.w	DeleteObject
		rts
; ---------------------------------------------------------------------------
Obj3A_Conf:	dc.w	 4, $124,  $BC,	$200		; 0
		dc.w $FEE0, $120,  $D0,	$201		; 4
		dc.w  $40C, $14C,  $D6,	$206		; 8
		dc.w  $520, $120,  $EC,	$202		; 12
		dc.w  $540, $120,  $FC,	$203		; 16
		dc.w  $560, $120, $10C,	$204		; 20
		dc.w  $20C, $14C,  $CC,	$205		; 24
