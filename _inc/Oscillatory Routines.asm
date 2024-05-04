; =============== S U B	R O U T	I N E =======================================


OscillateNumInit:
		lea	(v_oscillate).w,a1
		lea	(.baselines).l,a2
		moveq	#bytesToWcnt(.baselines_end-.baselines),d1

	.loop:
		move.w	(a2)+,(a1)+			; copy baseline values to RAM
		dbf	d1,.loop
		rts
; ===========================================================================
.baselines:	dc.w %0000000001111100			; oscillation direction bitfield
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $50F0, $11E
		dc.w $2080, $B4
		dc.w $3080, $10E
		dc.w $5080, $1C2
		dc.w $7080, $276
		dc.w $80, 0
		dc.w $80, 0
.baselines_end:	even

; =============== S U B	R O U T	I N E =======================================


OscillateNumDo:
		cmpi.b	#6,(v_player+obRoutine).w
		bcc.s	locret_46FC
		lea	(v_oscillate).w,a1
		lea	(OscData2).l,a2
		move.w	(a1)+,d3
		moveq	#$F,d1

loc_46BC:
		move.w	(a2)+,d2
		move.w	(a2)+,d4
		btst	d1,d3
		bne.s	loc_46DC
		move.w	2(a1),d0
		add.w	d2,d0
		move.w	d0,2(a1)
		_add.w	d0,0(a1)
		_cmp.b	0(a1),d4
		bhi.s	loc_46F2
		bset	d1,d3
		bra.s	loc_46F2
; ---------------------------------------------------------------------------

loc_46DC:
		move.w	2(a1),d0
		sub.w	d2,d0
		move.w	d0,2(a1)
		_add.w	d0,0(a1)
		_cmp.b	0(a1),d4
		bls.s	loc_46F2
		bclr	d1,d3

loc_46F2:
		addq.w	#4,a1
		dbf	d1,loc_46BC
		move.w	d3,(v_oscillate).w

locret_46FC:
		rts
; End of function OscillateNumDo

; ---------------------------------------------------------------------------
OscData2:	dc.w	 2,  $10			; 0
		dc.w	 2,  $18			; 2
		dc.w	 2,  $20			; 4
		dc.w	 2,  $30			; 6
		dc.w	 4,  $20			; 8
		dc.w	 8,    8			; 10
		dc.w	 8,  $40			; 12
		dc.w	 4,  $40			; 14
		dc.w	 2,  $50			; 16
		dc.w	 2,  $50			; 18
		dc.w	 2,  $20			; 20
		dc.w	 3,  $30			; 22
		dc.w	 5,  $50			; 24
		dc.w	 7,  $70			; 26
		dc.w	 2,  $10			; 28
		dc.w	 2,  $10			; 30