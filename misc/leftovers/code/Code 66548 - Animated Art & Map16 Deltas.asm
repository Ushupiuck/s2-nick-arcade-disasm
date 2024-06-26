; ---------------------------------------------------------------------------

struc_1		struc ;	(sizeof=0x8)
size:		dc.w ?
field_2:	dc.l ?
field_6:	dc.w ?
struc_1		ends


;
; +-------------------------------------------------------------------------+
; |	This file is generated by The Interactive Disassembler (IDA)	    |
; |	Copyright (c) 2007 by DataRescue sa/nv,	<ida@datarescue.com>	    |
; |	    Licensed to: GVU, Gerhard Uphoff, 1	user, adv, 10/2007	    |
; +-------------------------------------------------------------------------+
;
; Input	MD5   :	A75CA48FE8DCF4A064A2E23324A80C10

; ---------------------------------------------------------------------------
; File Name   :	Z:\emu\gen\s2a\sym\copies\code_66548
; Format      :	Binary file
; Base Address:	0000h Range: 0000h - 0648h Loaded length: 0648h

; Processor:	    68000
; Target Assembler: 680x0 Assembler in MRI compatible mode
; This file should be compiled with "as	-M"

; ===========================================================================

; Segment type:	Pure code
; segment "ROM"

efectwrt:
		bsr.w	sub_1BE
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	off_20+2(pc,d0.w),d1
		lea	off_20(pc,d1.w),a2
		move.w	off_20(pc,d0.w),d0
		jmp	off_20(pc,d0.w)
; ---------------------------------------------------------------------------
		rts
; ---------------------------------------------------------------------------
off_20:		dc.w return_62-off_20,efecttbl0-off_20;	0 ; DATA XREF: ROM:off_20o
					; ROM:off_20+2o ...
		dc.w return_60-off_20,efecttbl1-off_20;	2
		dc.w loc_64-off_20,efecttbl1-off_20; 4
		dc.w loc_64-off_20,efecttbl0-off_20; 6
		dc.w loc_64-off_20,efecttbl4-off_20; 8
		dc.w return_60-off_20,efecttbl1-off_20;	10
		dc.w return_60-off_20,efecttbl1-off_20;	12
		dc.w return_60-off_20,efecttbl1-off_20;	14
		dc.w loc_64-off_20,efecttbl4-off_20; 16
		dc.w return_60-off_20,efecttbl1-off_20;	18
		dc.w return_60-off_20,efecttbl1-off_20;	20
		dc.w return_60-off_20,efecttbl1-off_20;	22
		dc.w return_60-off_20,efecttbl1-off_20;	24
		dc.w loc_64-off_20,efecttbl1-off_20; 26
		dc.w return_60-off_20,efecttbl1-off_20;	28
		dc.w return_60-off_20,efecttbl1-off_20;	30
; ---------------------------------------------------------------------------

return_60:				; DATA XREF: ROM:off_20o
		rts
; ---------------------------------------------------------------------------

return_62:				; DATA XREF: ROM:off_20o
		rts
; ---------------------------------------------------------------------------

loc_64:					; DATA XREF: ROM:off_20o
		lea	($FFFFF7F0).w,a3
		move.w	(a2)+,d6

loc_6A:					; CODE XREF: ROM:000000C6j
		subq.b	#1,(a3)
		bpl.s	loc_B0
		moveq	#0,d0
		move.b	1(a3),d0
		cmp.b	6(a2),d0
		bcs.s	_jump$neba
		moveq	#0,d0
		move.b	d0,1(a3)

_jump$neba:				; CODE XREF: ROM:00000078j
		addq.b	#1,1(a3)
		move.b	(a2),(a3)
		bpl.s	loc_8E
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)

loc_8E:					; CODE XREF: ROM:00000086j
		move.b	8(a2,d0.w),d0
		lsl.w	#5,d0
		move.w	4(a2),d2
		move.l	(a2),d1
		and.l	#$FFFFFF,d1
		add.l	d0,d1
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3
		jsr	($13A0).l	; XREF:	dmactrset

loc_B0:					; CODE XREF: ROM:0000006Cj
		move.b	6(a2),d0
		tst.b	(a2)
		bpl.s	loc_BA
		add.b	d0,d0

loc_BA:					; CODE XREF: ROM:000000B6j
		addq.b	#1,d0
		and.w	#$FE,d0	; '�'
		lea	8(a2,d0.w),a2
		addq.w	#2,a3
		dbf	d6,loc_6A
		rts
; ---------------------------------------------------------------------------
efecttbl0:	dc.w 4			; DATA XREF: ROM:off_20o
		dc.l $FF026D98		; XREF:	efect00acg
		dc.w $7280
		dc.b 6
		dc.b 2
		dc.b   0
		dc.b $7F ; 
		dc.b   2
		dc.b $13
		dc.b   0
		dc.b   7
		dc.b   2
		dc.b   7
		dc.b   0
		dc.b   7
		dc.b   2
		dc.b   7
		dc.b $FF		; XREF:	efect00bcg
		dc.b   2
		dc.b $6E ; n
		dc.b $18
		dc.b $72 ; r
		dc.b $C0 ; �
		dc.b   8
		dc.b   2
		dc.b   2
		dc.b $7F ; 
		dc.b   0
		dc.b  $B
		dc.b   2
		dc.b  $B
		dc.b   0
		dc.b  $B
		dc.b   2
		dc.b   5
		dc.b   0
		dc.b   5
		dc.b   2
		dc.b   5
		dc.b   0
		dc.b   5
		dc.b   7		; XREF:	efect00ccg
		dc.b   2
		dc.b $6E ; n
		dc.b $98 ; �
		dc.b $73 ; s
		dc.b   0
		dc.b   2
		dc.b   2
		dc.b   0
		dc.b   2
		dc.b $FF		; XREF:	efect00dcg
		dc.b   2
		dc.b $6F ; o
		dc.b $18
		dc.b $73 ; s
		dc.b $40 ; @
		dc.b   8
		dc.b   2
		dc.b   0
		dc.b $7F ; 
		dc.b   2
		dc.b   7
		dc.b   0
		dc.b   7
		dc.b   2
		dc.b   7
		dc.b   0
		dc.b   7
		dc.b   2
		dc.b  $B
		dc.b   0
		dc.b  $B
		dc.b   2
		dc.b  $B
		dc.b   1		; XREF:	efect00ecg
		dc.b   2
		dc.b $6F ; o
		dc.b $98 ; �
		dc.b $73 ; s
		dc.b $80 ; �
		dc.b   6
		dc.b   2
		dc.b   0
		dc.b   2
		dc.b   4
		dc.b   6
		dc.b   4
		dc.b   2
efecttbl4:	dc.b   0		; DATA XREF: ROM:off_20o
		dc.b   2
		dc.b   8		; XREF:	efect08bcg
		dc.b   2
		dc.b $74 ; t
		dc.b $98 ; �
		dc.b $5D ; ]
		dc.b   0
		dc.b   6
		dc.b   8
		dc.b   0
		dc.b   0
		dc.b   8
		dc.b $10
		dc.b $10
		dc.b   8
		dc.b   8		; XREF:	efect08bcg
		dc.b   2
		dc.b $74 ; t
		dc.b $98 ; �
		dc.b $5E ; ^
		dc.b   0
		dc.b   6
		dc.b   8
		dc.b   8
		dc.b $10
		dc.b $10
		dc.b   8
		dc.b   0
		dc.b   0
		dc.b   8		; XREF:	efect08bcg
		dc.b   2
		dc.b $74 ; t
		dc.b $98 ; �
		dc.b $5F ; _
		dc.b   0
		dc.b   6
		dc.b   8
		dc.b $10
		dc.b   8
		dc.b   0
		dc.b   0
		dc.b   8
		dc.b $10
efecttbl1:	dc.w 7			; DATA XREF: ROM:off_20o
		dc.l $7027798		; XREF:	efect0dacg
		dc.w $9000
		dc.b   2
		dc.b   4
		dc.b   0
		dc.b   4
		dc.l $7027898		; XREF:	efect0dbcg
		dc.w $9080
		dc.b   3
		dc.b   8
		dc.b   0
		dc.b   8
		dc.b $10
		dc.b   0
		dc.l $7027B98		; XREF:	efect0dccg
		dc.w $9180
		dc.b   4
		dc.b   2
		dc.b   0
		dc.b   2
		dc.b   0
		dc.b   4
		dc.l $B027C58		; XREF:	efect0ddcg
		dc.w $91C0
		dc.b   4
		dc.b   2
		dc.b   0
		dc.b   2
		dc.b   4
		dc.b   2
		dc.l $F027D18		; XREF:	efect0decg
		dc.w $9200
		dc.b  $A
		dc.b   1
		dc.b   0
		dc.b   0
		dc.b   1
		dc.b   2
		dc.b   3
		dc.b   4
		dc.b   5
		dc.b   4
		dc.b   5
		dc.b   4
		dc.l $3027DD8		; XREF:	efect0dfcg
		dc.w $9220
		dc.b   4
		dc.b   4
		dc.b   0
		dc.b   4
		dc.b   8
		dc.b   4
		dc.l $7027F58		; XREF:	efect0dgcg
		dc.w $92A0
		dc.b   6
		dc.b   3
		dc.b   0
		dc.b   3
		dc.b   6
		dc.b   9
		dc.b  $C
		dc.b  $F
		dc.l $7028198		; XREF:	efect0dhcg
		dc.w $9300
		dc.b   4
		dc.b   1
		dc.b   0
		dc.b   1
		dc.b   2
		dc.b   3

; =============== S U B	R O U T	I N E =======================================


sub_1BE:				; CODE XREF: ROM:efectwrtp
		cmp.b	#2,($FFFFFE10).w
		beq.s	_jump$efba

return_1C6:				; CODE XREF: sub_1BE+12j sub_1BE+18j ...
		rts
; ---------------------------------------------------------------------------

_jump$efba:				; CODE XREF: sub_1BE+6j
		move.w	($FFFFEE00).w,d0
		cmp.w	#$1940,d0
		bcs.s	return_1C6
		cmp.w	#$1F80,d0
		bcc.s	return_1C6
		subq.b	#1,($FFFFF721).w
		bpl.s	return_1C6
		move.b	#7,($FFFFF721).w
		move.b	#1,($FFFFF720).w
		lea	($FFFF7500).l,a1
		bsr.s	sub_1F8
		lea	($FFFF7D00).l,a1
; End of function sub_1BE


; =============== S U B	R O U T	I N E =======================================


sub_1F8:				; CODE XREF: sub_1BE+32p
		move.w	#7,d1

loc_1FC:				; CODE XREF: sub_1F8+94j
		move.w	(a1),d0
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		add.w	#$70,a1	; 'p'
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		add.w	#$70,a1	; 'p'
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		add.w	#$70,a1	; 'p'
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	d0,(a1)+
		suba.w	#$180,a1
		dbf	d1,loc_1FC
		rts
; End of function sub_1F8

; ---------------------------------------------------------------------------

efectblockset:
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	off_2D4(pc,d0.w),d0
		lea	off_2D4(pc,d0.w),a0
		tst.w	(a0)
		beq.s	return_2BA
		lea	($FFFF9000).w,a1
		add.w	(a0)+,a1
		move.w	(a0)+,d1
		tst.w	($FFFFFFE8).w
		bne.s	loc_2BC

loc_2B4:				; CODE XREF: ROM:000002B6j
		move.w	(a0)+,(a1)+
		dbf	d1,loc_2B4

return_2BA:				; CODE XREF: ROM:000002A4j
		rts
; ---------------------------------------------------------------------------

loc_2BC:				; CODE XREF: ROM:000002B2j
					; ROM:000002CEj
		move.w	(a0)+,d0
		move.w	d0,d1
		and.w	#$F800,d0
		and.w	#$7FF,d1
		lsr.w	#1,d1
		or.w	d1,d0
		move.w	d0,(a1)+
		dbf	d1,loc_2BC
		rts
; ---------------------------------------------------------------------------
off_2D4:	dc.w word_2F4-off_2D4	; DATA XREF: ROM:off_2D4o
					; ROM:000002D6o ...
		dc.w zone0apcblk-off_2D4
		dc.w zone0dpcblk-off_2D4
		dc.w word_2F4-off_2D4
		dc.w word_552-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w word_552-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w zone0dpcblk-off_2D4
		dc.w zone0apcblk-off_2D4
		dc.w zone0apcblk-off_2D4
word_2F4:	dc.w $17C8,  $1B,$439C,$4B9C,$439D,$4B9D,$4158,$439C,$4159,$439D,$4B9C,$4958,$4B9D,$4959,$6394,$6B94; 0
					; DATA XREF: ROM:off_2D4o
					; ROM:000002DAo
		dc.w $6395,$6B95,$E396,$EB96,$E397,$EB97,$6398,$6B98,$6399,$6B99,$E39A,$EB9A,$E39B,$EB9B; 16
zone0apcblk:	dc.w	 0, $C80,  $9B,$43A1,$43A2,$43A3,$43A4,$43A5,$43A6,$43A7,$43A8,$43A9,$43AA,$43AB,$43AC,$43AD; 0
					; DATA XREF: ROM:000002D6o
					; ROM:000002DEo ...
		dc.w $43AE,$43AF,$43B0,$43B1,$43B2,$43B3,$43B4,$43B5,$43B6,$43B7,$43B8,$43B9,$43BA,$43BB,$43BC,$43BD; 16
		dc.w $43BE,$43BF,$43C0,$43C1,$43C2,$43C3,$43C4,$63A0,$63A0,$63A0,$63A0,$63A0,$63A0,$63A0,$63A0,	   0; 32
		dc.w	 0,$6340,$6344,	   0,	 0,$6348,$634C,$6341,$6345,$6342,$6346,$6349,$634D,$634A,$634E,$6343; 48
		dc.w $6347,$4358,$4359,$634B,$634F,$435A,$435B,$6380,$6384,$6381,$6385,$6388,$638C,$6389,$638D,$6382; 64
		dc.w $6386,$6383,$6387,$638A,$638E,$638B,$638F,$6390,$6394,$6391,$6395,$6398,$639C,$6399,$639D,$6392; 80
		dc.w $6396,$6393,$6397,$639A,$639E,$639B,$639F,$4378,$4379,$437A,$437B,$437C,$437D,$437E,$437F,$235C; 96
		dc.w $235D,$235E,$235F,$2360,$2361,$2362,$2363,$2364,$2365,$2366,$2367,$2368,$2369,$236A,$236B,	   0; 112
		dc.w	 0,$636C,$636D,	   0,	 0,$636E,    0,$636F,$6370,$6371,$6372,$6373,	 0,$6374,    0,$6375; 128
		dc.w $6376,$4358,$4359,$6377,	 0,$435A,$435B,$C378,$C379,$C37A,$C37B,$C37C,$C37D,$C37E,$C37F;	144
zone0dpcblk:	dc.w $1708,  $6F,$448F,$43D2,$43D3,$43D2,$43D4,$43D5,$4480,$4481,$4BD5,$4BD4,$4482,$4483,$4484,$4485; 0
					; DATA XREF: ROM:000002D8o
					; ROM:000002EEo
		dc.w $4486,$4487,$4488,$4489,$448A,$448B,$E48C,$E48D,$E3DE,$E3DF,$4498,$4C98,$4498,$4C98,$43E1,$448D; 16
		dc.w $43E1,$43DF,$448C,$448D,$43DE,$43DF,$E3D4,$E3D5,$E480,$E481,$EBD5,$EBD4,$E482,$E483,$E484,$E485; 32
		dc.w $E486,$E487,$E48C,$E48D,$E3DE,$E3DF,$E3E2,$E48E,$E3E4,$EBD3,$E48F,$E3D2,$E3D3,$E3D2,$E3E5,$E3E6; 48
		dc.w $E3E7,$E490,$E3E7,$F490,$E3E5,$E3E6,$E3E5,$E3E6,$E3E9,$E48E,$EBE6,$E3EA,$E48F,$E3E9,$E491,$E492; 64
		dc.w $E3D0,$E3ED,$E493,$E494,$EBED,$E3D0,$E488,$E489,$E48A,$E48B,$43E2,$448E,$43E4,$4BD3,$E495,$E496; 80
		dc.w $E3F2,$E3F2,$E497,$E3F3,$E3F2,$E3F4,$43E5,$43E6,$43E9,$448E,$4BE6,$43EA,$448F,$43E9,$E3E1,$E48D; 96
		dc.w $E3E1,$E3DF	; 112
word_552:	dc.w $1710,  $77,$62E8,$62E9,$62EA,$62EB,$62EC,$62ED,$62EE,$62EF,$62F0,$62F1,$62F2,$62F3,$62F4,$62F5; 0
					; DATA XREF: ROM:000002DCo
					; ROM:000002E4o
		dc.w $62F6,$62F7,$62F8,$62F9,$62FA,$62FB,$62FC,$62FD,$62FE,$62FF,$42E8,$42E9,$42EA,$42EB,$42EC,$42ED; 16
		dc.w $42EE,$42EF,$42F0,$42F1,$42F2,$42F3,$42F4,$42F5,$42F6,$42F7,$42F8,$42F9,$42FA,$42FB,$42FC,$42FD; 32
		dc.w $42FE,$42FF,    0,$62E8,	 0,$62EA,$62E9,$62EC,$62EB,$62EE,$62ED,	   0,$62EF,    0,    0,$62F0; 48
		dc.w	 0,$62F2,$62F1,$62F4,$62F3,$62F6,$62F5,	   0,$62F7,    0,    0,$62F8,	 0,$62FA,$62F9,$62FC; 64
		dc.w $62FB,$62FE,$62FD,	   0,$62FF,    0,    0,$42E8,	 0,$42EA,$42E9,$42EC,$42EB,$42EE,$42ED,	   0; 80
		dc.w $42EF,    0,    0,$42F0,	 0,$42F2,$42F1,$42F4,$42F3,$42F6,$42F5,	   0,$42F7,    0,    0,$42F8; 96
		dc.w	 0,$42FA,$42F9,$42FC,$42FB,$42FE,$42FD,	   0,$42FF,    0; 112
; ---------------------------------------------------------------------------
		nop
; end of 'ROM'


		END
