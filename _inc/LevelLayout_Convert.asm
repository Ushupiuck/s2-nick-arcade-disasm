; ---------------------------------------------------------------------------

LevelLayout_Convert:	; leftover level layout converting function (from raw to the way it's stored in the game)
		lea	(v_startofram).l,a1		; Set up input buffer pointer
		lea	(v_startofram+$80).l,a2		; Set up offset for intermediate processing
		lea	(v_startofram+$2000).l,a3	; Set up pointer to the output buffer address
		move.w	#$3F,d1				; Initialize loop counter

loc_747A:	; Main Loop
		bsr.w	sub_750C			; Copy data from a3 to a1 and a2
		bsr.w	sub_750C			; ...Twice
		dbf	d1,loc_747A			; Repeat loop until d1 becomes zero
		lea	(v_startofram).l,a1		; Reset input buffer pointer
		lea	(v_startofram&$FFFFFF).l,a2	; Reset output buffer pointer
		move.w	#$3F,d1				; Reset loop counter

loc_7496:	; Clearing Output Buffer
		move.w	#0,(a2)+			; Clear the output buffer
		dbf	d1,loc_7496			; Repeat until d1 becomes zero

		move.w	#$3FBF,d1			; Initialize loop counter for copying remaining data

loc_74A2:	; Copying Remaining Data
		move.w	(a1)+,(a2)+		; Copy data from input buffer to output buffer
		dbf	d1,loc_74A2		; Repeat until d1 becomes zero
		rts

; =============== S U B	R O U T	I N E =======================================

sub_750C:
		moveq	#7,d0				; Initialize loop counter

loc_750E:	; Copying Data Block
		move.l	(a3)+,(a1)+		; Copy block of data from a3 to a1
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a2)+		; Copy block of data from a3 to a2
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		dbf	d0,loc_750E		; Repeat until d0 becomes zero

		adda.w	#$80,a1				; Increment input buffer pointer
		adda.w	#$80,a2				; Increment output buffer pointer
		rts