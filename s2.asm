; Disassembly originally created by drx
; thanks to Hivebrain and Rika_Chou

; Updated by Alex Field, BetaFilter, and RepellantMold

zeroOffsetOptimization = 0

	CPU 68000
	include	"s2.macrosetup.asm"
	include	"s2.macros.asm"
	include	"s2.constants.asm"

StartOfRom:
Vectors:	dc.l v_systemstack,EntryPoint,BusError,AddressError
		dc.l IllegalInstr,ZeroDivide,ChkInstr,TrapvInstr
		dc.l PrivilegeViol,Trace,Line1010Emu,Line1111Emu
		dc.l ErrorExcept,ErrorExcept,ErrorExcept,ErrorExcept
		dc.l ErrorExcept,ErrorExcept,ErrorExcept,ErrorExcept
		dc.l ErrorExcept,ErrorExcept,ErrorExcept,ErrorExcept
		dc.l ErrorExcept,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l H_Int,ErrorTrap,V_Int,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.b "SEGA MEGA DRIVE "			; Console name
		dc.b "(C)SEGA 1991.APR"			; Copyright holder and release year (leftover from Sonic 1)
		dc.b "SONIC THE             HEDGEHOG 2                " ; Domestic name
		dc.b "SONIC THE             HEDGEHOG 2                " ; International name
		dc.b "GM 00004049-01"			; Version (leftover from Sonic 1)
Checksum:	dc.w $AFC7				; Checksum (patched later if incorrect)
		dc.b "J               "			; I/O support
		dc.l StartOfRom				; Start address of ROM
ROMEndLoc:	dc.l $7FFFF				; End address of ROM (leftover from Sonic 1)
		dc.l v_startofram&$FFFFFF		; Start address of RAM
		dc.l (v_endofram-1)&$FFFFFF		; End address of RAM
		dc.l $20202020				; Backup RAM ID
		dc.l $20202020				; Backup RAM start address
		dc.l $20202020				; Backup RAM end address
		dc.l $20202020				; Modem support
		dc.b "                                                " ; Notes (unused, anything can be put in this space, but it has to be 48 bytes.)
		dc.b "JUE             "			; Country code (region)
EndOfHeader:

; ---------------------------------------------------------------------------

ErrorTrap:
		nop
		nop
		bra.s	ErrorTrap
; ---------------------------------------------------------------------------

EntryPoint:
		tst.l	($A10008).l			; test Port A Ctrl
		bne.s	PortA_OK
		tst.w	($A1000C).l			; test Port C Ctrl

PortA_OK:
		bne.s	PortC_OK
		lea	InitValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0			; get hardware version
		andi.b	#$F,d0
		beq.s	SkipSecurity
		move.l	#'SEGA',$2F00(a1)

SkipSecurity:
		move.w	(a4),d0
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp
		moveq	#$17,d1

VDPInitLoop:
		move.b	(a5)+,d5
		move.w	d5,(a4)
		add.w	d7,d5
		dbf	d1,VDPInitLoop
		move.l	(a5)+,(a4)
		move.w	d0,(a3)
		move.w	d7,(a1)
		move.w	d7,(a2)

WaitForZ80:
		btst	d0,(a1)
		bne.s	WaitForZ80
		moveq	#$25,d2

Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf	d2,Z80InitLoop
		move.w	d0,(a2)
		move.w	d0,(a1)
		move.w	d7,(a2)

ClearRAMLoop:
		move.l	d0,-(a6)
		dbf	d6,ClearRAMLoop
		move.l	(a5)+,(a4)
		move.l	(a5)+,(a4)
		moveq	#$1F,d3

ClearCRAMLoop:
		move.l	d0,(a3)
		dbf	d3,ClearCRAMLoop
		move.l	(a5)+,(a4)
		moveq	#$13,d4

ClearVSRAMLoop:
		move.l	d0,(a3)
		dbf	d4,ClearVSRAMLoop
		moveq	#3,d5

PSGInitLoop:
		move.b	(a5)+,$11(a3)
		dbf	d5,PSGInitLoop
		move.w	d0,(a2)
		movem.l	(a6),d0-a6
		move	#$2700,sr

PortC_OK:
		bra.s	GameProgram
; ---------------------------------------------------------------------------
InitValues:	dc.w $8000
		dc.w $3FFF
		dc.w $100

		dc.l z80_ram				; Z80 RAM start	location
dword_29E:	dc.l z80_bus_request			; Z80 bus request
		dc.l z80_reset				; Z80 reset
		dc.l vdp_data_port			; VDP data port
		dc.l vdp_control_port			; VDP control port

		dc.b   4,$14,$30,$3C			; 0 ; values for VDP registers
		dc.b   7,$6C,  0,  0			; 4
		dc.b   0,  0,$FF,  0			; 8
		dc.b $81,$37,  0,  1			; 12
		dc.b   1,  0,  0,$FF			; 16
		dc.b $FF,  0,  0,$80			; 20

		dc.l $40000080				; value	for VRAM fill

		dc.b $AF,  1,$D9,$1F,$11,$27,  0,$21,$26,  0,$F9,$77,$ED,$B0,$DD,$E1 ; 0	; Z80 instructions
		dc.b $FD,$E1,$ED,$47,$ED,$4F,$D1,$E1,$F1,  8,$D9,$C1,$D1,$E1,$F1,$F9 ; 16
		dc.b $F3,$ED,$56,$36,$E9,$E9		; 32

		dc.w $8104				; VDP display mode
		dc.w $8F02				; VDP increment
		dc.l $C0000000				; value	for CRAM Write mode
		dc.l $40000010				; value	for VSRAM write	mode

		dc.b  $9F, $BF,	$DF, $FF		; 0 ; values for PSG channel volumes
; ---------------------------------------------------------------------------

GameProgram:
		tst.w	(vdp_control_port).l
		btst	#6,(HW_Expansion_Control).l
		beq.s	ChecksumTest
		cmpi.l	#'init',(v_init).w
		beq.w	GameInit

ChecksumTest:
		movea.l	#ErrorTrap,a0			; start checking bytes after header ($200)
		movea.l	#ROMEndLoc,a1			; stop at end of ROM (but not really since it's half the ROM, leftover from Sonic 1)
		move.l	(a1),d0
		move.l	#$7FFFF,d0
		moveq	#0,d1

ChecksumLoop:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bcc.s	ChecksumLoop
		movea.l	#Checksum,a1			; read the checksum
		cmp.w	(a1),d1				; compare correct checksum to one in ROM...
		nop					; ...and do nothing since this has been noped out...
		nop
		lea	(v_systemstack).w,a6
		moveq	#0,d7
		move.w	#$7F,d6

loc_350:
		move.l	d7,(a6)+
		dbf	d6,loc_350
		move.b	(HW_Version).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_megadrive).w
		move.l	#'init',(v_init).w

GameInit:
		lea	(v_startofram&$FFFFFF).l,a6
		moveq	#0,d7
		move.w	#$3F7F,d6

GameClrRAM:
		move.l	d7,(a6)+
		dbf	d6,GameClrRAM
		bsr.w	VDPSetupGame
		bsr.w	SoundDriverLoad
		bsr.w	JoypadInit
		move.b	#GameModeID_SegaScreen,(v_gamemode).w

MainGameLoop:
		move.b	(v_gamemode).w,d0
		andi.w	#$1C,d0
		jsr	GameModeArray(pc,d0.w)
		bra.s	MainGameLoop
; ===========================================================================
; loc_3A8:
GameModeArray:
GameMode_SegaScreen:	bra.w	SegaScreen		; SEGA screen mode
GameMode_TitleScreen:	bra.w	TitleScreen		; Title screen mode
GameMode_Demo:		bra.w	Level			; Demo mode
GameMode_Level:		bra.w	Level			; Zone play mode
GameMode_SpecialStage:	bra.w	SpecialStage		; Special Stage play mode
; ===========================================================================
; Leftover from Sonic 1, turns the screen red if the checksum check fails
ChecksumError:
		bsr.w	VDPSetupGame
		move.l	#$C0000000,(vdp_control_port).l
		moveq	#$3F,d7

Checksum_Red:
		move.w	#$E,(vdp_data_port).l
		dbf	d7,Checksum_Red

ChecksumFailed_Loop:
		bra.s	ChecksumFailed_Loop
; ===========================================================================

BusError:
		move.b	#2,(v_errortype).w
		bra.s	ErrorMsg_TwoAddresses
; ---------------------------------------------------------------------------

AddressError:
		move.b	#4,(v_errortype).w
		bra.s	ErrorMsg_TwoAddresses
; ---------------------------------------------------------------------------

IllegalInstr:
		move.b	#6,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ZeroDivide:
		move.b	#8,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ChkInstr:
		move.b	#$A,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

TrapvInstr:
		move.b	#$C,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

PrivilegeViol:
		move.b	#$E,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

Trace:
		move.b	#$10,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

Line1010Emu:
		move.b	#$12,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

Line1111Emu:
		move.b	#$14,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ErrorExcept:
		move.b	#0,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ErrorMsg_TwoAddresses:
		move	#$2700,sr
		addq.w	#2,sp
		move.l	(sp)+,(v_spbuffer).w
		addq.w	#2,sp
		movem.l	d0-a7,(v_regbuffer).w
		bsr.w	ShowErrorMsg
		move.l	2(sp),d0
		bsr.w	ShowErrAddress
		move.l	(v_spbuffer).w,d0
		bsr.w	ShowErrAddress
		bra.s	ErrorMsg_Wait
; ---------------------------------------------------------------------------

ErrorMessage:
		move	#$2700,sr
		movem.l	d0-a7,(v_regbuffer).w
		bsr.w	ShowErrorMsg
		move.l	2(sp),d0
		bsr.w	ShowErrAddress

ErrorMsg_Wait:
		bsr.w	Error_WaitForC
		movem.l	(v_regbuffer).w,d0-a7
		move	#$2300,sr
		rte

; =============== S U B	R O U T	I N E =======================================


ShowErrorMsg:
		lea	(vdp_data_port).l,a6
		move.l	#$78000003,(vdp_control_port).l
		lea	(Art_Text).l,a0
		move.w	#$27F,d1

Error_LoadGfx:
		move.w	(a0)+,(a6)
		dbf	d1,Error_LoadGfx
		moveq	#0,d0
		move.b	(v_errortype).w,d0

loc_4A6:
		move.w	ErrorText(pc,d0.w),d0
		lea	ErrorText(pc,d0.w),a0
		move.l	#$46040003,(vdp_control_port).l
		moveq	#$12,d1

Error_CharsLoop:
		moveq	#0,d0
		move.b	(a0)+,d0
		addi.w	#$790,d0
		move.w	d0,(a6)
		dbf	d1,Error_CharsLoop
		rts
; End of function ShowErrorMsg

; ---------------------------------------------------------------------------
ErrorText:	dc.w ErrText_Exept-ErrorText
		dc.w ErrText_BusErr-ErrorText
		dc.w ErrText_AddrErr-ErrorText
		dc.w ErrText_IllInstr-ErrorText
		dc.w ErrText_ZeroDiv-ErrorText
		dc.w ErrText_ChkInstr-ErrorText
		dc.w ErrText_TrapV-ErrorText
		dc.w ErrText_PrivViol-ErrorText
		dc.w ErrText_Trace-ErrorText
		dc.w ErrText_Line1010-ErrorText
		dc.w ErrText_Line1111-ErrorText
ErrText_Exept:		dc.b 'ERROR EXCEPTION    '
ErrText_BusErr:		dc.b 'BUS ERROR          '
ErrText_AddrErr:	dc.b 'ADDRESS ERROR      '
ErrText_IllInstr:	dc.b 'ILLEGAL INSTRUCTION'
ErrText_ZeroDiv:	dc.b '@ERO DIVIDE        '
ErrText_ChkInstr:	dc.b 'CHK INSTRUCTION    '
ErrText_TrapV:		dc.b 'TRAPV INSTRUCTION  '
ErrText_PrivViol:	dc.b 'PRIVILEGE VIOLATION'
ErrText_Trace:		dc.b 'TRACE              '
ErrText_Line1010:	dc.b 'LINE 1010 EMULATOR '
ErrText_Line1111:	dc.b 'LINE 1111 EMULATOR '
		even

; =============== S U B	R O U T	I N E =======================================


ShowErrAddress:
		move.w	#$7CA,(a6)
		moveq	#7,d2

ShowErrAddress_DigitLoop:
		rol.l	#4,d0
		bsr.s	ShowErrDigit
		dbf	d2,ShowErrAddress_DigitLoop
		rts
; End of function ShowErrAddress


; =============== S U B	R O U T	I N E =======================================


ShowErrDigit:
		move.w	d0,d1
		andi.w	#$F,d1
		cmpi.w	#$A,d1
		bcs.s	ShowErrDigit_NoOverflow
		addq.w	#7,d1

ShowErrDigit_NoOverflow:
		addi.w	#$7C0,d1
		move.w	d1,(a6)
		rts
; End of function ShowErrDigit


; =============== S U B	R O U T	I N E =======================================


Error_WaitForC:
		bsr.w	ReadJoypads
		cmpi.b	#$20,(v_jpadpress1).w
		bne.w	Error_WaitForC
		rts
; End of function Error_WaitForC

; ---------------------------------------------------------------------------
Art_Text:	binclude	"art/uncompressed/Level select and Debug Mode text.bin"
		even
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; vertical and horizontal interrupt handlers
; VERTICAL INTERRUPT HANDLER:
V_Int:
		movem.l	d0-a6,-(sp)
		tst.b	(v_vbla_routine).w
		beq.s	Vint_Lag

loc_B12:
		move.w	(vdp_control_port).l,d0
		andi.w	#8,d0
		beq.s	loc_B12
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l
		btst	#6,(v_megadrive).w
		beq.s	loc_B40
		move.w	#$700,d0
		dbf	d0,*

loc_B40:
		move.b	(v_vbla_routine).w,d0
		move.b	#VintID_Lag,(v_vbla_routine).w
		move.w	#1,(f_hbla_pal).w
		andi.w	#$3E,d0
		move.w	Vint_SwitchTbl(pc,d0.w),d0
		jsr	Vint_SwitchTbl(pc,d0.w)
; loc_B5C:
Vint_SoundDriver:
		jsr	(UpdateMusic).l
; loc_B62:
VintRet:
		addq.l	#1,(Vint_runcount).w
		movem.l	(sp)+,d0-a6
		rte
; ===========================================================================
; off_B6C:
Vint_SwitchTbl:
Vint_Lag_ptr:		dc.w Vint_Lag-Vint_SwitchTbl	; 0
Vint_SEGA_ptr:		dc.w Vint_SEGA-Vint_SwitchTbl	; 2
Vint_Title_ptr:		dc.w Vint_Title-Vint_SwitchTbl	; 4
Vint_Unused6_ptr:	dc.w Vint_Unused6-Vint_SwitchTbl ; 6
Vint_Level_ptr:		dc.w Vint_Level-Vint_SwitchTbl	; 8
Vint_S1SS_ptr:		dc.w Vint_S1SS-Vint_SwitchTbl	; $A
Vint_TitleCard_ptr:	dc.w Vint_TitleCard-Vint_SwitchTbl ; $C
Vint_UnusedE_ptr:	dc.w Vint_UnusedE-Vint_SwitchTbl ; $E
Vint_Pause_ptr:		dc.w Vint_Pause-Vint_SwitchTbl	; $10
Vint_Fade_ptr:		dc.w Vint_Fade-Vint_SwitchTbl	; $12
Vint_PCM_ptr:		dc.w Vint_PCM-Vint_SwitchTbl	; $14
Vint_SSResults_ptr:	dc.w Vint_SSResults-Vint_SwitchTbl ; $16
Vint_TitleCard2_ptr:	dc.w Vint_TitleCard-Vint_SwitchTbl ; $18
; ===========================================================================
; loc_B86: VintSub0:
Vint_Lag:
		cmpi.b	#GameModeID_TitleCard|GameModeID_Level,(v_gamemode).w
		beq.s	loc_BA0
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		beq.s	loc_BA0
		cmpi.b	#GameModeID_Level,(v_gamemode).w
		bne.w	Vint_SoundDriver

loc_BA0:
		tst.b	(Water_flag).w
		beq.w	Vint0_noWater
		move.w	(vdp_control_port).l,d0
		btst	#6,(v_megadrive).w
		beq.s	loc_BBE
		move.w	#$700,d0
		dbf	d0,*

loc_BBE:
		move.w	#1,(f_hbla_pal).w
		stopZ80
		waitZ80
		tst.b	(f_wtr_state).w
		bne.s	loc_C02
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bra.s	loc_C26
; ---------------------------------------------------------------------------

loc_C02:
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)

loc_C26:
		move.w	(v_hbla_hreg).w,(a5)
		move.w	#$8230,(vdp_control_port).l
		startZ80
		bra.w	Vint_SoundDriver
; ---------------------------------------------------------------------------
; loc_C3E:
Vint0_noWater:
		move.w	(vdp_control_port).l,d0
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l
		btst	#6,(v_megadrive).w
		beq.s	loc_C66
		move.w	#$700,d0
		dbf	d0,*

loc_C66:
		move.w	#1,(f_hbla_pal).w
		move.w	(v_hbla_hreg).w,(vdp_control_port).l
		move.w	#$8230,(vdp_control_port).l
		move.l	(v_bg3scrposy_vdp).w,(Camera_X_pos_copy).w
		lea	(vdp_control_port).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bra.w	Vint_SoundDriver
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_CAA: VintSub2:
Vint_SEGA:
		bsr.w	Do_ControllerPal
; loc_CAE: VintSub14:
Vint_PCM:
		tst.w	(v_demolength).w
		beq.w	locret_CBA
		subq.w	#1,(v_demolength).w

locret_CBA:
		rts
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_CBC: VintSub4:
Vint_Title:
		bsr.w	Do_ControllerPal
		bsr.w	ProcessDPLC
		tst.w	(v_demolength).w
		beq.w	locret_CD0

loc_CCC:
		subq.w	#1,(v_demolength).w

locret_CD0:
		rts
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_CD2: VintSub6:
Vint_Unused6:
		bsr.w	Do_ControllerPal
		rts
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_CD8: VintSub10:
Vint_Pause:
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w
		beq.w	Vint_S1SS
; loc_CE2: VintSub8:
Vint_Level:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	loc_D24

		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bra.s	loc_D48
; ---------------------------------------------------------------------------

loc_D24:
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)

loc_D48:
		move.w	(v_hbla_hreg).w,(a5)
		move.w	#$8230,(vdp_control_port).l
		lea	(vdp_control_port).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bsr.w	ProcessDMAQueue
		startZ80
		movem.l	(Camera_RAM).w,d0-d7
		movem.l	d0-d7,(Camera_RAM_copy).w
		movem.l	(Camera_X_pos_P2).w,d0-d7
		movem.l	d0-d7,(Camera_P2_copy).w
		movem.l	(Scroll_flags).w,d0-d3
		movem.l	d0-d3,(Scroll_flags_copy).w
		move.l	(v_bg3scrposy_vdp).w,(Camera_X_pos_copy).w
		cmpi.b	#92,(v_hbla_line).w
		bcc.s	Do_Updates
		move.b	#1,(f_doupdatesinhblank).w
		addq.l	#4,sp
		bra.w	VintRet

; ---------------------------------------------------------------------------
; Subroutine to run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Demo_Time:
Do_Updates:
		bsr.w	LoadTilesAsYouMove
		jsr	(HudUpdate).l
		bsr.w	ProcessDPLC2
		tst.w	(v_demolength).w
		beq.w	Do_Updates_End
		subq.w	#1,(v_demolength).w

Do_Updates_End:
		rts
; End of function Do_Updates

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_E02: VintSubA:
Vint_S1SS:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bsr.w	ProcessDMAQueue
		startZ80
		bsr.w	PalCycle_S1SS
		tst.w	(v_demolength).w
		beq.w	locret_EA0
		subq.w	#1,(v_demolength).w

locret_EA0:
		rts
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_EA2: VintSubC: VintSub18:
Vint_TitleCard:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	loc_EE4
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bra.s	loc_F08
; ---------------------------------------------------------------------------

loc_EE4:
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)

loc_F08:
		move.w	(v_hbla_hreg).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bsr.w	ProcessDMAQueue
		startZ80
		movem.l	(Camera_RAM).w,d0-d7
		movem.l	d0-d7,(Camera_RAM_copy).w
		movem.l	(Scroll_flags).w,d0-d1
		movem.l	d0-d1,(Scroll_flags_copy).w
		bsr.w	LoadTilesAsYouMove
		jsr	(HudUpdate).l
		bsr.w	ProcessDPLC
		rts
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_F88: VintSubE:
Vint_UnusedE:
		bsr.w	Do_ControllerPal
		addq.b	#1,(v_vbla_0e_counter).w
		move.b	#$E,(v_vbla_routine).w
		rts
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_F98: VintSub12:
Vint_Fade:
		bsr.w	Do_ControllerPal
		move.w	(v_hbla_hreg).w,(a5)
		bra.w	ProcessDPLC
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loc_FA4: VintSub16:
Vint_SSResults:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		startZ80
		tst.w	(v_demolength).w
		beq.w	locret_103A
		subq.w	#1,(v_demolength).w

locret_103A:
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_103C:
Do_ControllerPal:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	loc_107E
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		bra.s	loc_10A2
; ---------------------------------------------------------------------------

loc_107E:
		lea	(vdp_control_port).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)

loc_10A2:
		lea	(vdp_control_port).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		lea	(vdp_control_port).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		startZ80
		rts
; End of function Do_ControllerPal

; ||||||||||||||| E N D   O F   V - I N T |||||||||||||||||||||||||||||||||||

; ===========================================================================
; Start of H-INT code
H_Int:
		tst.w	(f_hbla_pal).w
		beq.w	locret_1184
		tst.w	(Two_player_mode).w
		beq.w	PalToCRAM
		move.w	#0,(f_hbla_pal).w
		move.l	a5,-(sp)
		move.l	d0,-(sp)

loc_110E:
		move.w	(vdp_control_port).l,d0
		andi.w	#4,d0
		beq.s	loc_110E
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		move.w	#$8228,(vdp_control_port).l
		move.l	#$40000010,(vdp_control_port).l
		move.l	(Camera_X_pos_copy).w,(vdp_data_port).l
		lea	(vdp_control_port).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96EE9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)

loc_1166:
		move.w	(vdp_control_port).l,d0
		andi.w	#4,d0
		beq.s	loc_1166
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		move.l	(sp)+,d0
		movea.l	(sp)+,a5

locret_1184:
		rte

; ---------------------------------------------------------------------------
; loc_1188:
PalToCRAM:
		move	#$2700,sr
		move.w	#0,(f_hbla_pal).w
		movem.l	a0-a1,-(sp)
		lea	(vdp_data_port).l,a1
		lea	(v_pal_water).w,a0		; load palette from RAM
		move.l	#$C0000000,4(a1)		; set VDP to write to CRAM address $00
	rept 32
		move.l	(a0)+,(a1)			; move palette to CRAM (all 64 colors at once)
	endr
		move.w	#$8ADF,4(a1)			; write %1101 %1111 to register 10 (interrupt every 224th line)
		movem.l	(sp)+,a0-a1
		tst.b	(f_doupdatesinhblank).w
		bne.s	Hint_SoundDriver
		rte
; ===========================================================================
; loc_11F8:
Hint_SoundDriver:
		clr.b	(f_doupdatesinhblank).w
		movem.l	d0-a6,-(sp)
		bsr.w	Do_Updates
		jsr	(UpdateMusic).l
		movem.l	(sp)+,d0-a6
		rte

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; game code
; ---------------------------------------------------------------------------
; Subroutine to initialize joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:
		stopZ80
		waitZ80
		moveq	#$40,d0
		move.b	d0,(HW_Port_1_Control).l
		move.b	d0,(HW_Port_2_Control).l
		move.b	d0,(HW_Expansion_Control).l
		startZ80
		rts
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	(v_jpadhold1).w,a0		; address where joypad states are written
		lea	(HW_Port_1_Data).l,a1		; first joypad port
		bsr.s	Joypad_Read			; do the first joypad
		addq.w	#2,a1				; do the second joypad

Joypad_Read:
		move.b	#0,(a1)
		nop
		nop
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop
		nop
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts
; End of function ReadJoypads


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:
		lea	(vdp_control_port).l,a0
		lea	(vdp_data_port).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#$12,d7

VDP_Loop:
		move.w	(a2)+,(a0)
		dbf	d7,VDP_Loop
		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_buffer1).w
		move.w	#$8ADF,(v_hbla_hreg).w
		moveq	#0,d0
		move.l	#$40000010,(vdp_control_port).l
		move.w	d0,(a1)
		move.w	d0,(a1)
		move.l	#$C0000000,(vdp_control_port).l
		move.w	#$3F,d7

VDP_ClrCRAM:
		move.w	d0,(a1)
		dbf	d7,VDP_ClrCRAM
		clr.l	(v_scrposy_vdp).w
		clr.l	(v_scrposx_vdp).w
		move.l	d1,-(sp)
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5)
		move.l	#$94FF93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080,(a5)
		move.w	#0,(vdp_data_port).l

VDP_WaitDMA:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	VDP_WaitDMA
		move.w	#$8F02,(a5)
		move.l	(sp)+,d1
		rts
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004
		dc.w $8134
		dc.w $8230
		dc.w $8328
		dc.w $8407
		dc.w $857C
		dc.w $8600
		dc.w $8700
		dc.w $8800
		dc.w $8900
		dc.w $8A00
		dc.w $8B00
		dc.w $8C81
		dc.w $8D3F
		dc.w $8E00
		dc.w $8F02
		dc.w $9001
		dc.w $9100
		dc.w $9200

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,(vdp_data_port).l

ClearScreen_DMAWait:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	ClearScreen_DMAWait
		move.w	#$8F02,(a5)
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000083,(a5)
		move.w	#0,(vdp_data_port).l

ClearScreen_DMAWait2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	ClearScreen_DMAWait2
		move.w	#$8F02,(a5)
		clr.l	(v_scrposy_vdp).w
		clr.l	(v_scrposx_vdp).w
		clearRAM Sprite_Table,Sprite_Table_End+4
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded+4
		rts
; End of function ClearScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load the compressed DAC driver
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_380
SoundDriverLoad:
		nop
		stopZ80
		resetZ80
		lea	(DACDriver).l,a0
		lea	(z80_ram).l,a1
		bsr.w	KosDec
		resetZ80a
		nop
		nop
		nop
		nop
		resetZ80
		startZ80
		rts
; End of function SoundDriverLoad


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PlaySound:
		move.b	d0,(v_snddriver_ram+v_soundqueue0).w
		rts
; End of function PlaySound


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PlaySound_Special:
		move.b	d0,(v_snddriver_ram+v_soundqueue1).w
		rts
; End of function PlaySound_Special


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PlaySound_Unk:
		move.b	d0,(v_snddriver_ram+v_soundqueue2).w
		rts
; End of functions PlaySound_Unk


; ---------------------------------------------------------------------------
; Subroutine to pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:
		nop
		tst.b	(v_lives).w
		beq.s	Unpause
		tst.w	(f_pause).w
		bne.s	Pause_AlreadyPaused
		btst	#7,(v_jpadpress1).w
		beq.s	Pause_DoNothing

Pause_AlreadyPaused:
		move.w	#1,(f_pause).w
		move.b	#1,(v_snddriver_ram+f_pausemusic).w

Pause_Loop:
		move.b	#VintID_Pause,(v_vbla_routine).w
		bsr.w	WaitForVint
		tst.b	(f_slomocheat).w
		beq.s	Pause_ChkStart
		btst	#6,(v_jpadpress1).w
		beq.s	Pause_ChkBC
		move.b	#GameModeID_TitleScreen,(v_gamemode).w
		nop
		bra.s	Pause_Resume
; ===========================================================================

Pause_ChkBC:
		btst	#4,(v_jpadhold1).w
		bne.s	Pause_SlowMo
		btst	#5,(v_jpadpress1).w
		bne.s	Pause_SlowMo

Pause_ChkStart:
		btst	#7,(v_jpadpress1).w
		beq.s	Pause_Loop
; loc_1464:
Pause_Resume:
		move.b	#$80,(v_snddriver_ram+f_pausemusic).w

Unpause:
		move.w	#0,(f_pause).w

Pause_DoNothing:
		rts
; ===========================================================================
; loc_1472:
Pause_SlowMo:
		move.w	#1,(f_pause).w
		move.b	#$80,(v_snddriver_ram+f_pausemusic).w
		rts
; End of function PauseGame

; ---------------------------------------------------------------------------
; Subroutine to transfer a plane map to VRAM
; ---------------------------------------------------------------------------

; control register:
;    CD1 CD0 A13 A12 A11 A10 A09 A08     (D31-D24)
;    A07 A06 A05 A04 A03 A02 A01 A00     (D23-D16)
;     ?   ?   ?   ?   ?   ?   ?   ?      (D15-D8)
;    CD5 CD4 CD3 CD2  ?   ?  A15 A14     (D7-D0)
;
;	A00-A15 - address
;	CD0-CD3 - code
;	CD4 - 1 if VRAM copy DMA mode. 0 otherwise.
;	CD5 - DMA operation
;
;	Bits CD3-CD0:
;	0000 - VRAM read
;	0001 - VRAM write
;	0011 - CRAM write
;	0100 - VSRAM read
;	0101 - VSRAM write
;	1000 - CRAM read
;
; d0 = control register
; d1 = width
; d2 = heigth
; a1 = source address

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ShowVDPGraphics: PlaneMapToVRAM:
PlaneMapToVRAM_H40:
		lea	(vdp_data_port).l,a6
		move.l	#$800000,d4

PlaneMapToVRAM_H40_LineLoop:
		move.l	d0,4(a6)
		move.w	d1,d3

PlaneMapToVRAM_H40_TileLoop:
		move.w	(a1)+,(a6)
		dbf	d3,PlaneMapToVRAM_H40_TileLoop
		add.l	d4,d0
		dbf	d2,PlaneMapToVRAM_H40_LineLoop
		rts
; End of function PlaneMapToVRAM_H40

; ---------------------------------------------------------------------------
; Subroutine for queueing VDP commands (seems to only queue transfers to VRAM),
; to be issued the next time ProcessDMAQueue is called.
; Can be called a maximum of 18 times before the buffer needs to be cleared
; by issuing the commands (this subroutine DOES check for overflow)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DMA_68KtoVRAM: QueueCopyToVRAM: QueueVDPCommand: Add_To_DMA_Queue:
QueueDMATransfer:
		movea.l	(VDP_Command_Buffer_Slot).w,a1
		cmpa.w	#VDP_Command_Buffer_Slot,a1
		beq.s	QueueDMATransfer_Done		; return if there's no more room in the buffer

		; piece together some VDP commands and store them for later...
		move.w	#$9300,d0			; command to specify DMA transfer length & $00FF
		move.b	d3,d0
		move.w	d0,(a1)+			; store command

		move.w	#$9400,d0			; command to specify DMA transfer length & $FF00
		lsr.w	#8,d3
		move.b	d3,d0
		move.w	d0,(a1)+			; store command

		move.w	#$9500,d0			; command to specify source address & $0001FE
		lsr.l	#1,d1
		move.b	d1,d0
		move.w	d0,(a1)+			; store command

		move.w	#$9600,d0			; command to specify source address & $01FE00
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+			; store command

		move.w	#$9700,d0			; command to specify source address & $FE0000
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+			; store command

		andi.l	#$FFFF,d2			; command to specify destination address and begin DMA
		lsl.l	#2,d2
		lsr.w	#2,d2
		swap	d2
		ori.l	#$40000080,d2			; set bits to specify VRAM transfer
		move.l	d2,(a1)+			; store command

		move.l	a1,(VDP_Command_Buffer_Slot).w	; set the next free slot address
		cmpa.w	#VDP_Command_Buffer_Slot,a1
		beq.s	QueueDMATransfer_Done		; return if there's no more room in the buffer
		move.w	#0,(a1)				; put a stop token at the end of the used part of the buffer

QueueDMATransfer_Done:
		rts
; End of function QueueDMATransfer

; ---------------------------------------------------------------------------
; Subroutine for issuing all VDP commands that were queued
; (by earlier calls to QueueDMATransfer)
; Resets the queue when it's done
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; CopyToVRAM: IssueVDPCommands: Process_DMA: Process_DMA_Queue:
ProcessDMAQueue:
		lea	(vdp_control_port).l,a5
		lea	(VDP_Command_Buffer).w,a1

ProcessDMAQueue_Loop:
		move.w	(a1)+,d0
		beq.s	ProcessDMAQueue_Done		; branch if we reached a stop token
		; issue a set of VDP commands
		move.w	d0,(a5)				; transfer length
		move.w	(a1)+,(a5)			; transfer length
		move.w	(a1)+,(a5)			; source address
		move.w	(a1)+,(a5)			; source address
		move.w	(a1)+,(a5)			; source address
		move.w	(a1)+,(a5)			; destination
		move.w	(a1)+,(a5)			; destination
		cmpa.w	#VDP_Command_Buffer_Slot,a1
		bne.s	ProcessDMAQueue_Loop		; loop if we haven't reached end of buffer

ProcessDMAQueue_Done:
		move.w	#0,(VDP_Command_Buffer).w
		move.l	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w
		rts
; End of function ProcessDMAQueue

		include "_inc\Nemesis Decompression.asm"

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; Subroutine to load pattern load cues (aka to queue pattern load requests)
; ---------------------------------------------------------------------------

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;	  (or hacker) is responsible for making sure that no more than
;	  16 load requests are copied into the buffer.
;    _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of v_plc_buffer, the limit becomes (v_plc_buffer_Only_End-v_plc_buffer)/6)

; PLCLoad:
LoadPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		lea	(v_plc_buffer).w,a2

loc_1688:
		tst.l	(a2)
		beq.s	loc_1690
		addq.w	#6,a2
		bra.s	loc_1688
; ---------------------------------------------------------------------------

loc_1690:
		move.w	(a1)+,d0
		bmi.s	loc_169C

loc_1694:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_1694

loc_169C:
		movem.l	(sp)+,a1-a2
		rts
; End of function LoadPLC


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Queue pattern load requests, but clear the PLQ first

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;	  (or hacker) is responsible for making sure that no more than
;	  16 load requests are copied into the buffer.
;	  _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of v_plc_buffer, the limit becomes (v_plc_buffer_Only_End-v_plc_buffer)/6)

LoadPLC2:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		bsr.s	ClearPLC
		lea	(v_plc_buffer).w,a2
		move.w	(a1)+,d0
		bmi.s	loc_16C8

loc_16C0:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_16C0

loc_16C8:
		movem.l	(sp)+,a1-a2
		rts
; End of function LoadPLC2


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Clear the pattern load queue ($FFF680 - $FFF700)

ClearPLC:
		lea	(v_plc_buffer).w,a2
		moveq	#$1F,d0

loc_16D4:
		clr.l	(a2)+
		dbf	d0,loc_16D4
		rts
; End of function ClearPLC


; ---------------------------------------------------------------------------
; Subroutine to use graphics listed in a pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; RunPLC:
RunPLC_RAM:
		tst.l	(v_plc_buffer).w
		beq.s	locret_1730
		tst.w	(v_plc_patternsleft).w
		bne.s	locret_1730
		movea.l	(v_plc_buffer).w,a0
		lea	NemPCD_WriteRowToVDP(pc),a3
		nop
		lea	(v_ngfx_buffer).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_16FE
		adda.w	#NemPCD_WriteRowToVDP_XOR-NemPCD_WriteRowToVDP,a3

loc_16FE:
		andi.w	#$7FFF,d2
		move.w	d2,(v_plc_patternsleft).w
		bsr.w	NemDec_BuildCodeTable
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_plc_ptrnemcode).w
		move.l	d0,(v_plc_repeatcount).w
		move.l	d0,(v_plc_paletteindex).w
		move.l	d0,(v_plc_previousrow).w
		move.l	d5,(v_plc_dataword).w
		move.l	d6,(v_plc_shiftvalue).w

locret_1730:
		rts
; End of function RunPLC_RAM


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Process one PLC from the queue

; sub_1732:
ProcessDPLC:
		tst.w	(v_plc_patternsleft).w
		beq.w	locret_17CA
		move.w	#9,(v_plc_framepatternsleft).w
		moveq	#0,d0
		move.w	(v_plc_buffer+4).w,d0
		addi.w	#$120,(v_plc_buffer+4).w
		bra.s	ProcessDPLC_Main

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Process one PLC from the queue

; loc_174E:
ProcessDPLC2:
		tst.w	(v_plc_patternsleft).w
		beq.s	locret_17CA
		move.w	#3,(v_plc_framepatternsleft).w
		moveq	#0,d0
		move.w	(v_plc_buffer+4).w,d0
		addi.w	#$60,(v_plc_buffer+4).w
; loc_1766:
ProcessDPLC_Main:
		lea	(vdp_control_port).l,a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		movea.l	(v_plc_buffer).w,a0
		movea.l	(v_plc_ptrnemcode).w,a3
		move.l	(v_plc_repeatcount).w,d0
		move.l	(v_plc_paletteindex).w,d1
		move.l	(v_plc_previousrow).w,d2
		move.l	(v_plc_dataword).w,d5
		move.l	(v_plc_shiftvalue).w,d6
		lea	(v_ngfx_buffer).w,a1

loc_179A:
		movea.w	#8,a5
		bsr.w	NemPCD_NewRow
		subq.w	#1,(v_plc_patternsleft).w
		beq.s	ProcessDPLC_Pop
		subq.w	#1,(v_plc_framepatternsleft).w
		bne.s	loc_179A
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_plc_ptrnemcode).w
		move.l	d0,(v_plc_repeatcount).w
		move.l	d1,(v_plc_paletteindex).w
		move.l	d2,(v_plc_previousrow).w
		move.l	d5,(v_plc_dataword).w
		move.l	d6,(v_plc_shiftvalue).w

locret_17CA:
		rts
; ===========================================================================
; pop one request off the buffer so that the next one can be filled
; loc_17CC:
ProcessDPLC_Pop:
		lea	(v_plc_buffer).w,a0
		moveq	#$15,d0

loc_17D2:
		move.l	6(a0),(a0)+
		dbf	d0,loc_17D2
		rts
; End of function ProcessDPLC


; ---------------------------------------------------------------------------
; Subroutine to execute a pattern load cue directly from the ROM
; rather than loading them into the queue first
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


RunPLC_ROM:
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d1

loc_17EE:
		movea.l	(a1)+,a0
		moveq	#0,d0
		move.w	(a1)+,d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(vdp_control_port).l
		bsr.w	NemDec
		dbf	d1,loc_17EE
		rts
; End of function RunPLC_ROM

		include "_inc/Enigma Decompression.asm"
		include "_inc/Kosinski Decompression.asm"
		include "_inc/Kid Chameleon Decompression.asm"

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Load:
		moveq	#0,d2
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	PalCycle(pc,d0.w),d0
		jmp	PalCycle(pc,d0.w)
; ---------------------------------------------------------------------------
		rts
; End of function PalCycle_Load

; ===========================================================================
PalCycle:	dc.w PalCycle_GHZ-PalCycle
		dc.w PalCycle_CPZ-PalCycle
		dc.w PalCycle_CPZ-PalCycle
		dc.w PalCycle_EHZ-PalCycle
		dc.w PalCycle_HPZ-PalCycle
		dc.w PalCycle_HTZ-PalCycle
		dc.w PalCycle_GHZ-PalCycle
; ===========================================================================

PalCycle_S1TitleScreen:
		lea	(Pal_S1TitleCyc).l,a0
		bra.s	loc_1E7C
; ===========================================================================

PalCycle_GHZ:
		lea	(Pal_GHZCyc).l,a0

loc_1E7C:
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1EA2
		move.w	#5,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addq.w	#1,(v_pcyc_num).w
		andi.w	#3,d0
		lsl.w	#3,d0
		lea	(v_pal_dry+$50).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)

locret_1EA2:
		rts
; ===========================================================================

PalCycle_CPZ:
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1F14
		move.w	#7,(v_pcyc_time).w
		lea	(Pal_CPZCyc1).l,a0
		move.w	(v_pcyc_num).w,d0
		addq.w	#6,(v_pcyc_num).w
		cmpi.w	#$36,(v_pcyc_num).w
		bcs.s	loc_1ECC
		move.w	#0,(v_pcyc_num).w

loc_1ECC:
		lea	(v_pal_dry+$78).w,a1
		move.l	(a0,d0.w),(a1)+
		move.w	4(a0,d0.w),(a1)
		lea	(Pal_CPZCyc2).l,a0
		move.w	(v_pal_buffer+2).w,d0
		addq.w	#2,(v_pal_buffer+2).w
		cmpi.w	#$2A,(v_pal_buffer+2).w
		bcs.s	loc_1EF4
		move.w	#0,(v_pal_buffer+2).w

loc_1EF4:
		move.w	(a0,d0.w),(v_pal_dry+$7E).w
		lea	(Pal_CPZCyc3).l,a0
		move.w	(v_pal_buffer+4).w,d0
		addq.w	#2,(v_pal_buffer+4).w
		andi.w	#$1E,(v_pal_buffer+4).w
		move.w	(a0,d0.w),(v_pal_dry+$5E).w

locret_1F14:
		rts
; ===========================================================================

PalCycle_HPZ:
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1F56
		move.w	#4,(v_pcyc_time).w
		lea	(Pal_HPZCyc1).l,a0
		move.w	(v_pcyc_num).w,d0
		subq.w	#2,(v_pcyc_num).w
		bcc.s	loc_1F38
		move.w	#6,(v_pcyc_num).w

loc_1F38:
		lea	(v_pal_dry+$72).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		lea	(Pal_HPZCyc2).l,a0
		lea	(v_pal_water+$72).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)

locret_1F56:
		rts
; ===========================================================================

PalCycle_EHZ:
		lea	(Pal_EHZCyc).l,a0
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1F84
		move.w	#7,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addq.w	#1,(v_pcyc_num).w
		andi.w	#3,d0
		lsl.w	#3,d0
		move.l	(a0,d0.w),(v_pal_dry+$26).w
		move.l	4(a0,d0.w),(v_pal_dry+$3C).w

locret_1F84:
		rts
; ===========================================================================

PalCycle_HTZ:
		lea	(Pal_HTZCyc1).l,a0
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1FB8
		move.w	#0,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addq.w	#1,(v_pcyc_num).w
		andi.w	#$F,d0
		move.b	Pal_HTZCyc2(pc,d0.w),(v_pcyc_time+1).w
		lsl.w	#3,d0
		move.l	(a0,d0.w),(v_pal_dry+$26).w
		move.l	4(a0,d0.w),(v_pal_dry+$3C).w

locret_1FB8:
		rts
; ===========================================================================
Pal_HTZCyc2:	binclude "art/palettes/Hill Top Lava Delay.bin"
Pal_S1TitleCyc:	binclude "art/palettes/S1 Title Water.bin"
Pal_GHZCyc:	binclude "art/palettes/GHZ Water.bin"
Pal_EHZCyc:	binclude "art/palettes/EHZ Water.bin"
Pal_HTZCyc1:	binclude "art/palettes/Hill Top Lava.bin"
Pal_CPZCyc1:	binclude "art/palettes/CPZ Cycle 1.bin"
Pal_CPZCyc2:	binclude "art/palettes/CPZ Cycle 2.bin"
Pal_CPZCyc3:	binclude "art/palettes/CPZ Cycle 3.bin"
Pal_HPZCyc1:	binclude "art/palettes/HPZ Water Cycle.bin"
Pal_HPZCyc2:	binclude "art/palettes/HPZ Underwater Cycle.bin"

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to fade in from black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Pal_FadeTo:
Pal_FadeFromBlack:
		move.w	#$3F,(v_pfade_start).w
; Pal_FadeTo2:
Pal_FadeFromBlack2:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#0,d1
		move.b	(v_pfade_size).w,d0

loc_2162:
		move.w	d1,(a0)+
		dbf	d0,loc_2162			; fill palette with $000 (black)
		move.w	#$15,d4

loc_216C:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_FadeIn
		bsr.w	RunPLC_RAM
		dbf	d4,loc_216C
		rts
; End of function Pal_FadeFromBlack

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeIn:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		lea	(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_2198:
		bsr.s	Pal_AddColor
		dbf	d0,loc_2198
		tst.b	(Water_flag).w
		beq.s	locret_21C0
		moveq	#0,d0
		lea	(v_pal_water).w,a0
		lea	(v_pal_water_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_21BA:
		bsr.s	Pal_AddColor
		dbf	d0,loc_21BA

locret_21C0:
		rts
; End of function Pal_FadeIn

; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	Pal_AddNone
		move.w	d3,d1
		addi.w	#$200,d1
		cmp.w	d2,d1
		bhi.s	Pal_AddGreen
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_AddGreen:
		move.w	d3,d1
		addi.w	#$20,d1
		cmp.w	d2,d1
		bhi.s	Pal_AddRed
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_AddRed:
		addq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------
; Pal_NoAdd:
Pal_AddNone:
		addq.w	#2,a0
		rts
; End of function Pal_AddColor


; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Pal_FadeFrom:
Pal_FadeToBlack:
		move.w	#$3F,(v_pfade_start).w
		move.w	#$15,d4

loc_21F8:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_FadeOut
		bsr.w	RunPLC_RAM
		dbf	d4,loc_21F8
		rts
; End of function Pal_FadeFrom

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeOut:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_221E:
		bsr.s	Pal_DecColor
		dbf	d0,loc_221E
		moveq	#0,d0
		lea	(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_2234:
		bsr.s	Pal_DecColor
		dbf	d0,loc_2234
		rts
; End of function Pal_FadeOut


; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor:
		move.w	(a0),d2
		beq.s	Pal_NoDec
		move.w	d2,d1
		andi.w	#$E,d1
		beq.s	Pal_DecGreen
		subq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_DecGreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		beq.s	Pal_DecBlue
		subi.w	#$20,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_DecBlue:
		move.w	d2,d1
		andi.w	#$E00,d1
		beq.s	Pal_NoDec
		subi.w	#$200,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_NoDec:
		addq.w	#2,a0
		rts
; End of function Pal_DecColor


; =============== S U B	R O U T	I N E =======================================


Pal_MakeWhite:
		move.w	#$3F,(v_pfade_start).w
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#$EEE,d1
		move.b	(v_pfade_size).w,d0

loc_2286:
		move.w	d1,(a0)+
		dbf	d0,loc_2286
		move.w	#$15,d4

loc_2290:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_WhiteToBlack
		bsr.w	RunPLC_RAM
		dbf	d4,loc_2290
		rts
; End of function Pal_MakeWhite


; =============== S U B	R O U T	I N E =======================================


Pal_WhiteToBlack:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		lea	(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_22BC:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_22BC
		tst.b	(Water_flag).w
		beq.s	locret_22E4
		moveq	#0,d0
		lea	(v_pal_water).w,a0
		lea	(v_pal_water_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_22DE:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_22DE

locret_22E4:
		rts
; End of function Pal_WhiteToBlack


; =============== S U B	R O U T	I N E =======================================


Pal_DecColor2:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_2312
		move.w	d3,d1
		subi.w	#$200,d1
		bcs.s	loc_22FE
		cmp.w	d2,d1
		bcs.s	loc_22FE
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_22FE:
		move.w	d3,d1
		subi.w	#$20,d1
		bcs.s	loc_230E
		cmp.w	d2,d1
		bcs.s	loc_230E
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_230E:
		subq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_2312:
		addq.w	#2,a0
		rts
; End of function Pal_DecColor2


; =============== S U B	R O U T	I N E =======================================


Pal_MakeFlash:
		move.w	#$3F,(v_pfade_start).w
		move.w	#$15,d4

loc_2320:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_ToWhite
		bsr.w	RunPLC_RAM
		dbf	d4,loc_2320
		rts
; End of function Pal_MakeFlash


; =============== S U B	R O U T	I N E =======================================


Pal_ToWhite:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_2346:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_2346
		moveq	#0,d0

loc_234E:
		lea	(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_235C:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_235C
		rts
; End of function Pal_ToWhite


; =============== S U B	R O U T	I N E =======================================


Pal_AddColor2:
		move.w	(a0),d2
		cmpi.w	#$EEE,d2
		beq.s	loc_23A0
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#$E,d1
		beq.s	loc_237C
		addq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_237C:
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#$E0,d1
		beq.s	loc_238E

loc_2388:
		addi.w	#$20,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_238E:
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#$E00,d1
		beq.s	loc_23A0
		addi.w	#$200,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_23A0:
		addq.w	#2,a0
		rts
; End of function Pal_AddColor2


; =============== S U B	R O U T	I N E =======================================


PalCycle_Sega:
		tst.b	(v_pcyc_time+1).w
		bne.s	loc_2404
		lea	(v_pal_dry+$20).w,a1
		lea	(Pal_Sega1).l,a0
		moveq	#5,d1
		move.w	(v_pcyc_num).w,d0

loc_23BA:
		bpl.s	loc_23C4
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_23BA
; ---------------------------------------------------------------------------

loc_23C4:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_23CE
		addq.w	#2,d0

loc_23CE:
		cmpi.w	#$60,d0
		bcc.s	loc_23D8
		move.w	(a0)+,(a1,d0.w)

loc_23D8:
		addq.w	#2,d0
		dbf	d1,loc_23C4
		move.w	(v_pcyc_num).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_23EE
		addq.w	#2,d0

loc_23EE:
		cmpi.w	#$64,d0
		blt.s	loc_23FC
		move.w	#$401,(v_pcyc_time).w
		moveq	#$FFFFFFF4,d0

loc_23FC:
		move.w	d0,(v_pcyc_num).w
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

loc_2404:
		subq.b	#1,(v_pcyc_time).w
		bpl.s	loc_2456
		move.b	#4,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addi.w	#$C,d0
		cmpi.w	#$30,d0
		bcs.s	loc_2422
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_2422:
		move.w	d0,(v_pcyc_num).w
		lea	(Pal_Sega2).l,a0
		lea	(a0,d0.w),a0
		lea	(v_pal_dry+4).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	(v_pal_dry+$20).w,a1
		moveq	#0,d0
		moveq	#$2C,d1

loc_2442:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_244C
		addq.w	#2,d0

loc_244C:
		move.w	(a0),(a1,d0.w)
		addq.w	#2,d0
		dbf	d1,loc_2442

loc_2456:
		moveq	#1,d0
		rts
; End of function PalCycle_Sega

; ---------------------------------------------------------------------------
Pal_Sega1:	dc.w  $EEE, $EEA, $EE4,	$EC0, $EE4, $EEA ; 0
Pal_Sega2:	dc.w  $EEC, $EEA, $EEA,	$EEA, $EEA, $EEA, $EEC,	$EEA, $EE4, $EC0, $EC0,	$EC0, $EEC, $EEA, $EE4,	$EC0
		dc.w  $EA0, $E60, $EEA,	$EE4, $EC0, $EA0, $E80,	$E00

; =============== S U B	R O U T	I N E =======================================


PalLoad1:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		adda.w	#v_pal_dry_dup-v_pal_dry,a3
		move.w	(a1)+,d7

loc_24AA:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_24AA
		rts
; End of function PalLoad1


; =============== S U B	R O U T	I N E =======================================


PalLoad2:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		move.w	(a1)+,d7

loc_24C2:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_24C2
		rts
; End of function PalLoad2


; =============== S U B	R O U T	I N E =======================================


PalLoad3_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#v_pal_dry-v_pal_water,a3
		move.w	(a1)+,d7

loc_24DE:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_24DE
		rts
; End of function PalLoad3_Water


; =============== S U B	R O U T	I N E =======================================


PalLoad4_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#v_pal_dry-v_pal_water_dup,a3
		move.w	(a1)+,d7

loc_24FA:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_24FA
		rts
; End of function PalLoad4_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Palette pointers
; (PALETTE DESCRIPTOR ARRAY)
; This struct array defines the palette to use for each level.
; ---------------------------------------------------------------------------

palptr	macro	ptr,ram,size
	dc.l ptr					; Pointer to palette
	dc.w ram					; Location in ram to load palette into
	dc.w size					; Size of palette in (bytes / 4)
	endm

PalPointers:	palptr	Pal_SegaBG,v_pal_dry,$1F
		palptr	Pal_Title,v_pal_dry,$1F
		palptr	Pal_LevelSelect,v_pal_dry,$1F
		palptr	Pal_SonicTails,v_pal_dry,7
		palptr	Pal_GHZ,v_pal_dry+$20,$17
		palptr	Pal_CPZ,v_pal_dry+$20,$17
		palptr	Pal_CPZ,v_pal_dry+$20,$17
		palptr	Pal_EHZ,v_pal_dry+$20,$17
		palptr	Pal_HPZ,v_pal_dry+$20,$17
		palptr	Pal_HTZ,v_pal_dry+$20,$17
		palptr	Pal_S1SpecialStage,v_pal_dry,$1F
		palptr	Pal_HPZWater,v_pal_dry,$1F
		; the following are leftover Sonic 1 entries
		palptr	Pal_LZ4,v_pal_dry+$20,$17
		palptr	Pal_LZ4Water,v_pal_dry,$1F
		palptr	Pal_HTZ,v_pal_dry+$20,$17
		palptr	Pal_LZSonicWater,v_pal_dry,7
		palptr	Pal_LZ4SonicWater,v_pal_dry,7
		palptr	Pal_S1SpeResults,v_pal_dry,$1F
		palptr	Pal_S1Continue,v_pal_dry,$F
		palptr	Pal_S1Ending,v_pal_dry,$1F
; ---------------------------------------------------------------------------
Pal_SegaBG:		binclude	"art/palettes/Sega screen background.bin"
Pal_Title:		binclude	"art/palettes/Title screen.bin"
Pal_LevelSelect:	binclude	"art/palettes/Level select.bin"
Pal_SonicTails:		binclude	"art/palettes/Sonic and Tails.bin"
Pal_GHZ:		binclude	"art/palettes/GHZ.bin"
Pal_HPZWater:		binclude	"art/palettes/HPZ underwater.bin"
Pal_CPZ:		binclude	"art/palettes/CPZ.bin"
Pal_EHZ:		binclude	"art/palettes/EHZ.bin"
Pal_HPZ:		binclude	"art/palettes/HPZ.bin"
Pal_HTZ:		binclude	"art/palettes/HTZ.bin"
Pal_S1SpecialStage:	binclude	"art/palettes/S1 Special Stage.bin"
Pal_LZ4:		binclude	"art/palettes/LZ4.bin"
Pal_LZ4Water:		binclude	"art/palettes/LZ4 underwater.bin"
Pal_LZSonicWater:	binclude	"art/palettes/LZ Sonic underwater.bin"
Pal_LZ4SonicWater:	binclude	"art/palettes/LZ4 Sonic underwater.bin"
Pal_S1SpeResults:	binclude	"art/palettes/S1 Special Stage results.bin"
Pal_S1Continue:		binclude	"art/palettes/S1 Continue screen.bin"
Pal_S1Ending:		binclude	"art/palettes/S1 Ending.bin"
; ===========================================================================
		nop
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to perform vertical synchronization
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DelayProgram:
WaitForVint:
		move	#$2300,sr

loc_2C88:
		tst.b	(v_vbla_routine).w
		bne.s	loc_2C88
		rts
; End of function WaitForVint

; ---------------------------------------------------------------------------
; Subroutine to generate a pseudo-random number in d0
; d0 = (RNG & $FFFF0000) | ((RNG*41 & $FFFF) + ((RNG*41 & $FFFF0000) >> 16))
; RNG = ((RNG*41 + ((RNG*41 & $FFFF) << 16)) & $FFFF0000) | (RNG*41 & $FFFF)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; PseudoRandomNumber:
RandomNumber:
		move.l	(v_random).w,d1
		bne.s	loc_2C9C
		move.l	#$2A6D365A,d1

loc_2C9C:
		; set the high word of d0 to be the high word of the RNG
		; and multiply the RNG by 41
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1

		; add the low word of the RNG to the high word of the RNG
		; and set the low word of d0 to be the result
		move.w	d1,d0
		swap	d1
		add.w	d1,d0
		move.w	d0,d1
		swap	d1

		move.l	d1,(v_random).w
		rts
; End of function RandomNumber

; ---------------------------------------------------------------------------
; Subroutine to calculate sine and cosine of an angle
; d0 = input byte = angle (360 degrees == 256)
; d0 = output word = 255 * sine(angle)
; d1 = output word = 255 * cosine(angle)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


CalcSine:
		andi.w	#$FF,d0
		add.w	d0,d0
		addi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d1		; cos
		subi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d0		; sin
		rts
; End of function CalcSine

; ===========================================================================
Sine_Data:	dc.w	  0,	 6,    $C,   $12,   $19,   $1F,	  $25,	 $2B ; 0
		dc.w	$31,   $38,   $3E,   $44,   $4A,   $50,	  $56,	 $5C ; 8
		dc.w	$61,   $67,   $6D,   $73,   $78,   $7E,	  $83,	 $88 ; 16
		dc.w	$8E,   $93,   $98,   $9D,   $A2,   $A7,	  $AB,	 $B0 ; 24
		dc.w	$B5,   $B9,   $BD,   $C1,   $C5,   $C9,	  $CD,	 $D1 ; 32
		dc.w	$D4,   $D8,   $DB,   $DE,   $E1,   $E4,	  $E7,	 $EA ; 40
		dc.w	$EC,   $EE,   $F1,   $F3,   $F4,   $F6,	  $F8,	 $F9 ; 48
		dc.w	$FB,   $FC,   $FD,   $FE,   $FE,   $FF,	  $FF,	 $FF ; 56
		dc.w   $100,   $FF,   $FF,   $FF,   $FE,   $FE,	  $FD,	 $FC ; 64
		dc.w	$FB,   $F9,   $F8,   $F6,   $F4,   $F3,	  $F1,	 $EE ; 72
		dc.w	$EC,   $EA,   $E7,   $E4,   $E1,   $DE,	  $DB,	 $D8 ; 80
		dc.w	$D4,   $D1,   $CD,   $C9,   $C5,   $C1,	  $BD,	 $B9 ; 88
		dc.w	$B5,   $B0,   $AB,   $A7,   $A2,   $9D,	  $98,	 $93 ; 96
		dc.w	$8E,   $88,   $83,   $7E,   $78,   $73,	  $6D,	 $67 ; 104
		dc.w	$61,   $5C,   $56,   $50,   $4A,   $44,	  $3E,	 $38 ; 112
		dc.w	$31,   $2B,   $25,   $1F,   $19,   $12,	   $C,	   6 ; 120
		dc.w	  0,	-6,   -$C,  -$12,  -$19,  -$1F,	 -$25,	-$2B ; 128
		dc.w   -$31,  -$38,  -$3E,  -$44,  -$4A,  -$50,	 -$56,	-$5C ; 136
		dc.w   -$61,  -$67,  -$6D,  -$75,  -$78,  -$7E,	 -$83,	-$88 ; 144
		dc.w   -$8E,  -$93,  -$98,  -$9D,  -$A2,  -$A7,	 -$AB,	-$B0 ; 152
		dc.w   -$B5,  -$B9,  -$BD,  -$C1,  -$C5,  -$C9,	 -$CD,	-$D1 ; 160
		dc.w   -$D4,  -$D8,  -$DB,  -$DE,  -$E1,  -$E4,	 -$E7,	-$EA ; 168
		dc.w   -$EC,  -$EE,  -$F1,  -$F3,  -$F4,  -$F6,	 -$F8,	-$F9 ; 176
		dc.w   -$FB,  -$FC,  -$FD,  -$FE,  -$FE,  -$FF,	 -$FF,	-$FF ; 184
		dc.w  -$100,  -$FF,  -$FF,  -$FF,  -$FE,  -$FE,	 -$FD,	-$FC ; 192
		dc.w   -$FB,  -$F9,  -$F8,  -$F6,  -$F4,  -$F3,	 -$F1,	-$EE ; 200
		dc.w   -$EC,  -$EA,  -$E7,  -$E4,  -$E1,  -$DE,	 -$DB,	-$D8 ; 208
		dc.w   -$D4,  -$D1,  -$CD,  -$C9,  -$C5,  -$C1,	 -$BD,	-$B9 ; 216
		dc.w   -$B5,  -$B0,  -$AB,  -$A7,  -$A2,  -$9D,	 -$98,	-$93 ; 224
		dc.w   -$8E,  -$88,  -$83,  -$7E,  -$78,  -$75,	 -$6D,	-$67 ; 232
		dc.w   -$61,  -$5C,  -$56,  -$50,  -$4A,  -$44,	 -$3E,	-$38 ; 240
		dc.w   -$31,  -$2B,  -$25,  -$1F,  -$19,  -$12,	  -$C,	  -6 ; 248
		dc.w	  0,	 6,    $C,   $12,   $19,   $1F,	  $25,	 $2B ; 256
		dc.w	$31,   $38,   $3E,   $44,   $4A,   $50,	  $56,	 $5C ; 264
		dc.w	$61,   $67,   $6D,   $73,   $78,   $7E,	  $83,	 $88 ; 272
		dc.w	$8E,   $93,   $98,   $9D,   $A2,   $A7,	  $AB,	 $B0 ; 280
		dc.w	$B5,   $B9,   $BD,   $C1,   $C5,   $C9,	  $CD,	 $D1 ; 288
		dc.w	$D4,   $D8,   $DB,   $DE,   $E1,   $E4,	  $E7,	 $EA ; 296
		dc.w	$EC,   $EE,   $F1,   $F3,   $F4,   $F6,	  $F8,	 $F9 ; 304
		dc.w	$FB,   $FC,   $FD,   $FE,   $FE,   $FF,	  $FF,	 $FF ; 312

; ---------------------------------------------------------------------------
; Subroutine to calculate arctangent of y/x
; d1 = input x
; d2 = input y
; d0 = output angle (360 degrees == 256)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


CalcAngle:
		movem.l	d3-d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3
		move.w	d2,d4
		or.w	d3,d4
		beq.s	CalcAngle_Zero			; special case return if x and y are both 0
		move.w	d2,d4
		tst.w	d3				; calculate absolute value of x
		bpl.w	loc_2F68
		neg.w	d3

loc_2F68:
		tst.w	d4				; calculate absolute value of y
		bpl.w	loc_2F70
		neg.w	d4

loc_2F70:
		cmp.w	d3,d4
		bcc.w	loc_2F82
		lsl.l	#8,d4
		divu.w	d3,d4
		moveq	#0,d0
		move.b	AngleData(pc,d4.w),d0
		bra.s	loc_2F8C
; ---------------------------------------------------------------------------

loc_2F82:
		lsl.l	#8,d3
		divu.w	d4,d3
		moveq	#$40,d0
		sub.b	AngleData(pc,d3.w),d0

loc_2F8C:
		tst.w	d1
		bpl.w	loc_2F98
		neg.w	d0
		addi.w	#$80,d0

loc_2F98:
		tst.w	d2
		bpl.w	loc_2FA4
		neg.w	d0
		addi.w	#$100,d0

loc_2FA4:
		movem.l	(sp)+,d3-d4
		rts
; ===========================================================================
; loc_2FAA:
CalcAngle_Zero:
		move.w	#$40,d0
		movem.l	(sp)+,d3-d4
		rts
; End of function CalcAngle

; ===========================================================================
AngleData:	dc.b   0,  0,  0,  0,  1,  1,  1,  1	; 0
		dc.b   1,  1,  2,  2,  2,  2,  2,  2	; 8
		dc.b   3,  3,  3,  3,  3,  3,  3,  4	; 16
		dc.b   4,  4,  4,  4,  4,  5,  5,  5	; 24
		dc.b   5,  5,  5,  6,  6,  6,  6,  6	; 32
		dc.b   6,  6,  7,  7,  7,  7,  7,  7	; 40
		dc.b   8,  8,  8,  8,  8,  8,  8,  9	; 48
		dc.b   9,  9,  9,  9,  9, $A, $A, $A	; 56
		dc.b  $A, $A, $A, $A, $B, $B, $B, $B	; 64
		dc.b  $B, $B, $B, $C, $C, $C, $C, $C	; 72
		dc.b  $C, $C, $D, $D, $D, $D, $D, $D	; 80
		dc.b  $D, $E, $E, $E, $E, $E, $E, $E	; 88
		dc.b  $F, $F, $F, $F, $F, $F, $F,$10	; 96
		dc.b $10,$10,$10,$10,$10,$10,$11,$11	; 104
		dc.b $11,$11,$11,$11,$11,$11,$12,$12	; 112
		dc.b $12,$12,$12,$12,$12,$13,$13,$13	; 120
		dc.b $13,$13,$13,$13,$13,$14,$14,$14	; 128
		dc.b $14,$14,$14,$14,$14,$15,$15,$15	; 136
		dc.b $15,$15,$15,$15,$15,$15,$16,$16	; 144
		dc.b $16,$16,$16,$16,$16,$16,$17,$17	; 152
		dc.b $17,$17,$17,$17,$17,$17,$17,$18	; 160
		dc.b $18,$18,$18,$18,$18,$18,$18,$18	; 168
		dc.b $19,$19,$19,$19,$19,$19,$19,$19	; 176
		dc.b $19,$19,$1A,$1A,$1A,$1A,$1A,$1A	; 184
		dc.b $1A,$1A,$1A,$1B,$1B,$1B,$1B,$1B	; 192
		dc.b $1B,$1B,$1B,$1B,$1B,$1C,$1C,$1C	; 200
		dc.b $1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C	; 208
		dc.b $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D	; 216
		dc.b $1D,$1D,$1D,$1E,$1E,$1E,$1E,$1E	; 224
		dc.b $1E,$1E,$1E,$1E,$1E,$1E,$1F,$1F	; 232
		dc.b $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F	; 240
		dc.b $1F,$1F,$20,$20,$20,$20,$20,$20	; 248
		dc.b $20				; 256
		even
; ===========================================================================
		nop
; ===========================================================================
; ---------------------------------------------------------------------------
; Sega logo, exact same as Sonic 1's
; ---------------------------------------------------------------------------

SegaScreen:
		move.b	#bgm_Stop,d0
		bsr.w	PlaySound_Special
		bsr.w	ClearPLC
		bsr.w	Pal_FadeToBlack
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$8700,(a6)
		move.w	#$8B00,(a6)
		move.w	#$8C81,(a6)
		clr.b	(f_wtr_state).w
		move	#$2700,sr
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		move.l	#$40000000,(vdp_control_port).l
		lea	(Nem_SegaLogo).l,a0
		bsr.w	NemDec
		lea	(v_startofram).l,a1
		lea	(Eni_SegaLogo).l,a0
		move.w	#0,d0
		bsr.w	EniDec
		lea	(v_startofram).l,a1
		move.l	#$65100003,d0
		moveq	#$17,d1
		moveq	#7,d2
		bsr.w	PlaneMapToVRAM_H40
		lea	($FFFF0180).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	PlaneMapToVRAM_H40
		tst.b	(v_megadrive).w			; is console Japanese?
		bmi.s	loc_316A			; if not, branch
		; hide 'TM' symbol
		lea	($FFFF0A40).l,a1
		move.l	#$453A0003,d0
		moveq	#2,d1
		moveq	#1,d2
		bsr.w	PlaneMapToVRAM_H40

loc_316A:
		moveq	#0,d0
		bsr.w	PalLoad2
		move.w	#-$A,(v_pcyc_num).w
		move.w	#0,(v_pcyc_time).w
		move.w	#0,($FFFFF662).w
		move.w	#0,($FFFFF660).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l

Sega_WaitPalette:
		move.b	#VintID_SEGA,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPalette

		move.b	#sfx_Sega,d0
		bsr.w	PlaySound_Special
		move.b	#VintID_PCM,(v_vbla_routine).w
		bsr.w	WaitForVint
		move.w	#$1E,(v_demolength).w

Sega_WaitEnd:
		move.b	#VintID_SEGA,(v_vbla_routine).w
		bsr.w	WaitForVint
		tst.w	(v_demolength).w
		beq.s	Sega_GoToTitleScreen
		andi.b	#$80,(v_jpadpress1).w
		beq.s	Sega_WaitEnd

Sega_GoToTitleScreen:
		move.b	#GameModeID_TitleScreen,(v_gamemode).w
		rts
; ===========================================================================
		dc.w 0
; ===========================================================================

TitleScreen:
		move.b	#bgm_Stop,d0
		bsr.w	PlaySound_Special
		bsr.w	ClearPLC
		bsr.w	Pal_FadeToBlack
		move	#$2700,sr
		bsr.w	SoundDriverLoad
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	(f_wtr_state).w
		move.w	#$8C81,(a6)
		bsr.w	ClearScreen
		clearRAM v_spritequeue,v_spritequeue_end
		clearRAM v_objspace,v_objspace_end
		clearRAM v_levelvariables,v_levelvariables_end
		clearRAM Camera_RAM,Camera_RAM_End
		clearRAM v_pal_dry_dup,v_pal_dry_dup+16*4*2
		moveq	#3,d0
		bsr.w	PalLoad1
		bsr.w	Pal_FadeFromBlack
		move	#$2700,sr
		move.l	#$40000000,(vdp_control_port).l
		lea	(Nem_Title).l,a0
		bsr.w	NemDec
		move.l	#$40000001,(vdp_control_port).l
		lea	(Nem_TitleSonicTails).l,a0
		bsr.w	NemDec
		lea	(vdp_data_port).l,a6
		move.l	#$50000003,4(a6)
		lea	(Art_Text).l,a5
		move.w	#$28F,d1

loc_32C4:
		move.w	(a5)+,(a6)
		dbf	d1,loc_32C4
		nop
		move.b	#0,(v_lastlamp).w
		move.w	#0,(Debug_placement_mode).w
		move.w	#0,(f_demo).w
		move.w	#0,(word_FFFFFFEA).w
		move.w	#0,(Current_ZoneAndAct).w
		move.w	#0,(v_pcyc_time).w
		bsr.w	Pal_FadeToBlack
		move	#$2700,sr
		lea	(v_startofram).l,a1
		lea	(Eni_TitleMap).l,a0
		move.w	#0,d0
		bsr.w	EniDec
		lea	(v_startofram).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	PlaneMapToVRAM_H40
		lea	(v_startofram).l,a1
		lea	(Eni_TitleBg1).l,a0
		move.w	#0,d0
		bsr.w	EniDec
		lea	(v_startofram).l,a1
		move.l	#$60000003,d0
		moveq	#$1F,d1
		moveq	#$1B,d2
		bsr.w	PlaneMapToVRAM_H40
		lea	(v_startofram).l,a1
		lea	(Eni_TitleBg2).l,a0
		move.w	#0,d0
		bsr.w	EniDec
		lea	(v_startofram).l,a1
		move.l	#$60400003,d0
		moveq	#$1F,d1
		moveq	#$1B,d2
		bsr.w	PlaneMapToVRAM_H40
		moveq	#1,d0
		bsr.w	PalLoad1
		move.b	#bgm_Title,d0
		bsr.w	PlaySound_Special
		move.b	#0,(Debug_mode_flag).w
		move.w	#0,(Two_player_mode).w
		move.w	#$178,(v_demolength).w
		lea	(v_objspace+$80).w,a1
		moveq	#0,d0
		move.w	#$F,d1

loc_339A:
		move.l	d0,(a1)+
		dbf	d1,loc_339A
		move.b	#$E,(v_objspace+$40).w
		move.b	#$E,(v_objspace+$80).w
		move.b	#1,(v_objspace+$9A).w
		jsr	(RunObjects).l
		jsr	(BuildSprites).l
		moveq	#0,d0
		bsr.w	LoadPLC2
		move.w	#0,(v_title_dcount).w
		move.w	#0,(v_title_ccount).w
		move.w	#$300,(Current_ZoneAndAct).w
		move.w	#4,(Sonic_Pos_Record_Index).w
		move.w	#0,(Sonic_Pos_Record_Buf).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	Pal_FadeFromBlack

TitleScreen_Loop:
		move.b	#VintID_Title,(v_vbla_routine).w
		bsr.w	WaitForVint
		jsr	(RunObjects).l
		bsr.w	Deform_TitleScreen
		jsr	(BuildSprites).l
		bsr.w	RunPLC_RAM
		tst.b	(v_megadrive).w
		bpl.s	Title_RegionJ
		lea	(LvlSelCode_US).l,a0
		bra.s	LevelSelectCheat
; ---------------------------------------------------------------------------

Title_RegionJ:
		lea	(LvlSelCode_J).l,a0

LevelSelectCheat:
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
		move.b	(v_jpadpress1).w,d0
		andi.b	#$F,d0
		cmp.b	(a0),d0
		bne.s	Title_Cheat_NoMatch
		addq.w	#1,(v_title_dcount).w
		tst.b	d0
		bne.s	Title_Cheat_CountC
		lea	(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Title_Cheat_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Title_Cheat_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)

Title_Cheat_PlayRing:
		move.b	#1,(a0,d1.w)
		move.b	#sfx_Ring,d0
		bsr.w	PlaySound_Special
		bra.s	Title_Cheat_CountC
; ---------------------------------------------------------------------------

Title_Cheat_NoMatch:
		tst.b	d0
		beq.s	Title_Cheat_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Title_Cheat_CountC
		move.w	#0,(v_title_dcount).w

Title_Cheat_CountC:
		move.b	(v_jpadpress1).w,d0
		andi.b	#$20,d0
		beq.s	Title_Cheat_NoC
		addq.w	#1,(v_title_ccount).w

Title_Cheat_NoC:
		tst.w	(v_demolength).w
		beq.w	Demo
		andi.b	#$80,(v_jpadpress1).w
		beq.w	TitleScreen_Loop

Title_CheckLvlSel:
		tst.b	(f_levselcheat).w
		beq.w	PlayLevel
		moveq	#2,d0
		bsr.w	PalLoad2
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end
		move.l	d0,(v_scrposy_vdp).w
		move	#$2700,sr
		lea	(vdp_data_port).l,a6
		move.l	#$60000003,(vdp_control_port).l
		move.w	#$3FF,d1

LevelSelect_ClearVRAM:
		move.l	d0,(a6)
		dbf	d1,LevelSelect_ClearVRAM
		bsr.w	LevelSelect_TextLoad

LevelSelect_Loop:
		move.b	#VintID_Title,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	LevelSelect_Controls
		bsr.w	RunPLC_RAM
		tst.l	(v_plc_buffer).w
		bne.s	LevelSelect_Loop
		andi.b	#$F0,(v_jpadpress1).w
		beq.s	LevelSelect_Loop
		move.w	#0,(Two_player_mode).w
		btst	#4,(v_jpadhold1).w
		beq.s	loc_3516
		move.w	#1,(Two_player_mode).w

loc_3516:
		move.w	(v_levselitem).w,d0
		cmpi.w	#$14,d0
		bne.s	loc_3570
		move.w	(v_levselsound).w,d0
		addi.w	#$80,d0
		tst.b	(f_creditscheat).w
		beq.s	loc_353A
		cmpi.w	#$9F,d0
		beq.s	loc_354C
		cmpi.w	#$9E,d0
		beq.s	loc_355A

loc_353A:
		cmpi.w	#bgm__Last+1,d0
		bcs.s	loc_3546
		cmpi.w	#sfx__First,d0
		bcs.s	LevelSelect_Loop

loc_3546:
		bsr.w	PlaySound_Special
		bra.s	LevelSelect_Loop
; ---------------------------------------------------------------------------

loc_354C:
		move.b	#GameModeID_S1Ending,(v_gamemode).w
		move.w	#$600,(Current_ZoneAndAct).w
		rts
; ---------------------------------------------------------------------------

loc_355A:
		move.b	#GameModeID_S1Credits,(v_gamemode).w
		move.b	#bgm_Credits,d0
		bsr.w	PlaySound_Special
		move.w	#0,(v_creditsnum).w
		rts
; ---------------------------------------------------------------------------

loc_3570:
		add.w	d0,d0
		move.w	LevelSelect_LevelOrder(pc,d0.w),d0
		bmi.w	LevelSelect_Loop
		cmpi.w	#$700,d0
		bne.s	LevelSelect_Level
		move.b	#GameModeID_SpecialStage,(v_gamemode).w
		clr.w	(Current_ZoneAndAct).w
		move.b	#3,(v_lives).w
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.l	d0,(v_score).w
		move.l	#5000,(v_scorelife).w
		rts
; ---------------------------------------------------------------------------
LevelSelect_LevelOrder:dc.w	0,    1,    2		; 0
		dc.w  $200, $201, $202			; 3
		dc.w  $400, $401, $402			; 6
		dc.w  $100, $101, $102			; 9
		dc.w  $300, $301, $302			; 12
		dc.w  $500, $501, $103			; 15
		dc.w  $502, $700,$8000			; 18
; ---------------------------------------------------------------------------

LevelSelect_Level:
		andi.w	#$3FFF,d0
		move.w	d0,(Current_ZoneAndAct).w

PlayLevel:
		move.b	#GameModeID_Level,(v_gamemode).w
		move.b	#3,(v_lives).w
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.l	d0,(v_score).w
		move.b	d0,(v_lastspecial).w
		move.b	d0,(v_emeralds).w
		move.l	d0,(v_emldlist).w
		move.l	d0,($FFFFFE5C).w
		move.b	d0,(v_continues).w
		move.l	#5000,(v_scorelife).w
		move.b	#bgm_Fade,d0
		bsr.w	PlaySound_Special
		rts
; ---------------------------------------------------------------------------
LvlSelCode_J:	dc.b   1,  2,  2,  2,  2,  1,  0,$FF	; up, down, down, down, down, up
LvlSelCode_US:	dc.b   1,  2,  2,  2,  2,  1,  0,$FF	; up, down, down, down, down, up
; ---------------------------------------------------------------------------

Demo:
		move.w	#$1E,(v_demolength).w

loc_3630:
		move.b	#VintID_Title,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	RunPLC_RAM
		move.w	(v_objspace+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_objspace+obX).w
		cmpi.w	#$1C00,d0
		bcs.s	RunDemo
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		rts
; ---------------------------------------------------------------------------

RunDemo:
		andi.b	#$80,(v_jpadpress1).w
		bne.w	Title_CheckLvlSel
		tst.w	(v_demolength).w
		bne.w	loc_3630
		move.b	#bgm_Fade,d0
		bsr.w	PlaySound_Special
		move.w	(v_demonum).w,d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Demo_Levels(pc,d0.w),d0
		move.w	d0,(Current_ZoneAndAct).w
		addq.w	#1,(v_demonum).w
		cmpi.w	#4,(v_demonum).w
		bcs.s	loc_3694
		move.w	#0,(v_demonum).w

loc_3694:
		move.w	#1,(f_demo).w
		move.b	#GameModeID_Demo,(v_gamemode).w
		cmpi.w	#$300,d0
		bne.s	loc_36AC
		move.w	#1,(Two_player_mode).w

loc_36AC:
		cmpi.w	#$600,d0
		bne.s	loc_36C0
		move.b	#GameModeID_SpecialStage,(v_gamemode).w
		clr.w	(Current_ZoneAndAct).w
		clr.b	(v_lastspecial).w

loc_36C0:
		move.b	#3,(v_lives).w
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.l	d0,(v_score).w
		move.l	#5000,(v_scorelife).w
		rts
; ---------------------------------------------------------------------------
Demo_Levels:	dc.w  $200, $300			; 0
		dc.w  $400, $500			; 2
		dc.w  $500, $500			; 4
		dc.w  $500, $500			; 6
		dc.w  $400, $400			; 8
		dc.w  $400, $400			; 10

; =============== S U B	R O U T	I N E =======================================


LevelSelect_Controls:
		move.b	(v_jpadpress1).w,d1
		andi.b	#3,d1
		bne.s	loc_3706
		subq.w	#1,(v_levseldelay).w
		bpl.s	loc_3740

loc_3706:
		move.w	#$B,(v_levseldelay).w
		move.b	(v_jpadhold1).w,d1
		andi.b	#3,d1
		beq.s	loc_3740
		move.w	(v_levselitem).w,d0
		btst	#0,d1
		beq.s	loc_3726
		subq.w	#1,d0
		bcc.s	loc_3726
		moveq	#$14,d0

loc_3726:
		btst	#1,d1
		beq.s	loc_3736
		addq.w	#1,d0
		cmpi.w	#$15,d0
		bcs.s	loc_3736
		moveq	#0,d0

loc_3736:
		move.w	d0,(v_levselitem).w
		bsr.w	LevelSelect_TextLoad
		rts
; ---------------------------------------------------------------------------

loc_3740:
		cmpi.w	#$14,(v_levselitem).w
		bne.s	locret_377A
		move.b	(v_jpadpress1).w,d1
		andi.b	#$C,d1
		beq.s	locret_377A
		move.w	(v_levselsound).w,d0
		btst	#2,d1
		beq.s	loc_3762
		subq.w	#1,d0
		bcc.s	loc_3762
		moveq	#$4F,d0

loc_3762:
		btst	#3,d1
		beq.s	loc_3772
		addq.w	#1,d0
		cmpi.w	#$50,d0
		bcs.s	loc_3772
		moveq	#0,d0

loc_3772:
		move.w	d0,(v_levselsound).w
		bsr.w	LevelSelect_TextLoad

locret_377A:
		rts
; End of function LevelSelect_Controls


; =============== S U B	R O U T	I N E =======================================


LevelSelect_TextLoad:
		lea	(LevelSelect_Text).l,a1
		lea	(vdp_data_port).l,a6
		move.l	#$62100003,d4
		move.w	#$8680,d3
		moveq	#$14,d1

loc_3794:
		move.l	d4,4(a6)
		bsr.w	sub_381C
		addi.l	#$800000,d4
		dbf	d1,loc_3794
		moveq	#0,d0
		move.w	(v_levselitem).w,d0
		move.w	d0,d1
		move.l	#$62100003,d4
		lsl.w	#7,d0
		swap	d0
		add.l	d0,d4
		lea	(LevelSelect_Text).l,a1
		lsl.w	#3,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		adda.w	d1,a1
		move.w	#$C680,d3
		move.l	d4,4(a6)
		bsr.w	sub_381C
		move.w	#$8680,d3
		cmpi.w	#$14,(v_levselitem).w
		bne.s	loc_37E6
		move.w	#$C680,d3

loc_37E6:
		move.l	#$6C300003,(vdp_control_port).l
		move.w	(v_levselsound).w,d0
		addi.w	#$80,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.w	sub_3808
		move.b	d2,d0
		bsr.w	sub_3808
		rts
; End of function LevelSelect_TextLoad


; =============== S U B	R O U T	I N E =======================================


sub_3808:
		andi.w	#$F,d0
		cmpi.b	#$A,d0
		bcs.s	loc_3816
		addi.b	#7,d0

loc_3816:
		add.w	d3,d0
		move.w	d0,(a6)
		rts
; End of function sub_3808


; =============== S U B	R O U T	I N E =======================================


sub_381C:
		moveq	#$17,d2

loc_381E:
		moveq	#0,d0
		move.b	(a1)+,d0
		bpl.s	loc_382E
		move.w	#0,(a6)
		dbf	d2,loc_381E
		rts
; ---------------------------------------------------------------------------

loc_382E:
		add.w	d3,d0
		move.w	d0,(a6)
		dbf	d2,loc_381E
		rts
; End of function sub_381C

; ---------------------------------------------------------------------------
LevelSelect_Text:	binclude	"mappings/misc/Level select text.bin"
		even
; ---------------------------------------------------------------------------

UnknownSub_1:
		lea	(v_startofram).l,a1
		move.w	#$2EB,d2

loc_3A3A:
		move.w	(a1),d0
		move.w	d0,d1
		andi.w	#$F800,d1
		andi.w	#$7FF,d0
		lsr.w	#1,d0
		or.w	d0,d1
		move.w	d1,(a1)+
		dbf	d2,loc_3A3A
		rts
; ---------------------------------------------------------------------------

UnknownSub_2:
		lea	($FE0000).l,a1
		lea	($FE0080).l,a2
		lea	(v_startofram).l,a3
		move.w	#$3F,d1

loc_3A68:
		bsr.w	UnknownSub_4
		bsr.w	UnknownSub_4
		dbf	d1,loc_3A68
		lea	($FE0000).l,a1
		lea	($FF0000).l,a2
		move.w	#$3F,d1

loc_3A84:
		move.w	#0,(a2)+
		dbf	d1,loc_3A84
		move.w	#$3FBF,d1

loc_3A90:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_3A90
		rts
; ---------------------------------------------------------------------------

UnknownSub_3:
		lea	($FE0000).l,a1
		lea	(v_startofram).l,a3
		moveq	#$1F,d0

loc_3AA6:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_3AA6
		moveq	#0,d7
		lea	($FE0000).l,a1
		move.w	#$FF,d5

loc_3AB8:
		lea	(v_startofram).l,a3
		move.w	d7,d6

loc_3AC0:
		movem.l	a1-a3,-(sp)
		move.w	#$3F,d0

loc_3AC8:
		cmpm.w	(a1)+,(a3)+
		bne.s	loc_3ADE
		dbf	d0,loc_3AC8
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a1
		dbf	d5,loc_3AB8
		bra.s	loc_3AF8
; ---------------------------------------------------------------------------

loc_3ADE:
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a3
		dbf	d6,loc_3AC0
		moveq	#$1F,d0

loc_3AEC:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_3AEC
		addq.l	#1,d7
		dbf	d5,loc_3AB8

loc_3AF8:
		bra.s	*

; =============== S U B	R O U T	I N E =======================================


UnknownSub_4:
		moveq	#7,d0

loc_3AFC:
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		dbf	d0,loc_3AFC
		adda.w	#$80,a1
		adda.w	#$80,a2
		rts
; End of function UnknownSub_4

; ---------------------------------------------------------------------------
		nop
; ---------------------------------------------------------------------------
MusicList:	dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		dc.b $8D
		dc.b 0
; ===========================================================================
; ---------------------------------------------------------------------------
; Level
; DEMO AND ZONE LOOP (MLS values $08, $0C; bit 7 set indicates that load routine is running)
; ---------------------------------------------------------------------------

Level:
		bset	#GameModeFlag_TitleCard,(v_gamemode).w
		tst.w	(f_demo).w
		bmi.s	loc_3B38
		move.b	#bgm_Fade,d0
		bsr.w	PlaySound_Special

loc_3B38:
		bsr.w	ClearPLC
		bsr.w	Pal_FadeToBlack
		tst.w	(f_demo).w
		bmi.s	loc_3BB6
		move	#$2700,sr
		move.l	#$70000002,(vdp_control_port).l
		lea	(Nem_S1TitleCard).l,a0
		bsr.w	NemDec
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000082,(a5)
		move.w	#0,(vdp_data_port).l

loc_3B84:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_3B84
		move.w	#$8F02,(a5)
		move	#$2300,sr
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#4,d0
		lea	(LevelArtPointers).l,a2
		lea	(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_3BB0
		bsr.w	LoadPLC

loc_3BB0:
		moveq	#1,d0
		bsr.w	LoadPLC

loc_3BB6:
		clearRAM v_spritequeue,v_spritequeue_end
		clearRAM v_objspace,v_objspace_end
		clearRAM v_misc_variables,v_misc_variables_end
		clearRAM v_levelvariables,v_levelvariables_end
		clearRAM v_timingvariables,v_timingvariables_end
		cmpi.b	#4,(Current_Zone).w
		bne.s	loc_3C1A
		move.b	#1,(Water_flag).w
		move.w	#0,(Two_player_mode).w

loc_3C1A:
		lea	(vdp_control_port).l,a6
		move.w	#$8B03,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$857C,(a6)
		move.w	#$9001,(a6)
		move.w	#$8004,(a6)
		move.w	#$8720,(a6)
		move.w	#$8ADF,(v_hbla_hreg).w
		tst.w	(Two_player_mode).w
		beq.s	loc_3C56
		move.w	#$8A6B,(v_hbla_hreg).w
		move.w	#$8014,(a6)
		move.w	#$8C87,(a6)

loc_3C56:
		move.w	(v_hbla_hreg).w,(a6)
		move.l	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w
		tst.b	(Water_flag).w
		beq.s	LevelInit_NoWater
		move.w	#$8014,(a6)
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		lea	(WaterHeight).l,a1
		move.w	(a1,d0.w),d0
		move.w	d0,(v_waterpos1).w
		move.w	d0,(v_waterpos2).w
		move.w	d0,(v_waterpos3).w
		clr.b	(v_wtr_routine).w
		clr.b	(f_wtr_state).w
		move.b	#1,(f_water).w

LevelInit_NoWater:
		move.w	#$1E,(v_air).w
		moveq	#3,d0
		bsr.w	PalLoad2
		tst.b	(Water_flag).w
		beq.s	loc_3CC6
		moveq	#$F,d0
		cmpi.b	#3,(Current_Act).w
		bne.s	loc_3CB6
		moveq	#$10,d0

loc_3CB6:
		bsr.w	PalLoad3_Water
		tst.b	(v_lastlamp).w
		beq.s	loc_3CC6
		move.b	(v_lamp_wtrstat).w,(f_wtr_state).w

loc_3CC6:
		tst.w	(f_demo).w
		bmi.s	loc_3D2A
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		cmpi.w	#$103,(Current_ZoneAndAct).w
		bne.s	loc_3CDC
		moveq	#5,d0

loc_3CDC:
		cmpi.w	#$502,(Current_ZoneAndAct).w
		bne.s	loc_3CE6
		moveq	#6,d0

loc_3CE6:
		lea	MusicList(pc),a1
		nop
		move.b	(a1,d0.w),d0
		bsr.w	PlaySound
		move.b	#$34,(v_objspace+$80).w

LevelInit_TitleCard:
		move.b	#VintID_TitleCard,(v_vbla_routine).w
		bsr.w	WaitForVint
		jsr	(RunObjects).l
		jsr	(BuildSprites).l
		bsr.w	RunPLC_RAM
		move.w	(v_objspace+$100+obX).w,d0
		cmp.w	(v_objspace+$100+$30).w,d0
		bne.s	LevelInit_TitleCard
		tst.l	(v_plc_buffer).w
		bne.s	LevelInit_TitleCard
		jsr	(HUD_Base).l

loc_3D2A:
		moveq	#3,d0
		bsr.w	PalLoad1
		bsr.w	LevelSizeLoad
		bsr.w	DeformBGLayer
		bset	#2,(Scroll_flags).w
		bsr.w	MainLevelLoadBlock
		jsr	(LoadAnimatedBlocks).l
		bsr.w	LoadTilesFromStart
		jsr	(ApplySonic1Collision).l
		bsr.w	LoadCollisionIndexes
		bsr.w	WaterEffects
		move.b	#1,(v_objspace).w
		tst.w	(f_demo).w
		bmi.s	loc_3D6C
		move.b	#$21,(v_objspace+$380).w

loc_3D6C:
		tst.w	(Two_player_mode).w
		bne.s	LevelInit_LoadTails
		cmpi.b	#3,(Current_Zone).w
		beq.s	LevelInit_SkipTails		; funny how they skipped Tails in EHZ for the Nick Arcade show

LevelInit_LoadTails:
		move.b	#2,(v_objspace+$40).w
		move.w	(v_objspace+obX).w,(v_objspace+$40+obX).w
		move.w	(v_objspace+obY).w,(v_objspace+$40+obY).w
		subi.w	#$20,(v_objspace+$40+obX).w

LevelInit_SkipTails:
		tst.b	(f_debugcheat).w
		beq.s	loc_3DA6
		btst	#6,(v_jpadhold1).w
		beq.s	loc_3DA6
		move.b	#1,(Debug_mode_flag).w

loc_3DA6:
		move.w	#0,(v_jpadhold2).w
		move.w	#0,(v_jpadhold1).w
		tst.b	(Water_flag).w
		beq.s	loc_3DD0
		move.b	#4,(v_objspace+$780).w
		move.w	#$60,(v_objspace+$780+obX).w
		move.b	#4,(v_objspace+$7C0).w
		move.w	#$120,(v_objspace+$7C0+obX).w

loc_3DD0:
		jsr	(ObjectsManager).l
		jsr	(RingsManager).l
		jsr	(RunObjects).l
		jsr	(BuildSprites).l
		bsr.w	j_AniArt_Load
		moveq	#0,d0
		tst.b	(v_lastlamp).w
		bne.s	loc_3E00
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.b	d0,(v_lifecount).w

loc_3E00:
		move.b	d0,(f_timeover).w
		move.b	d0,(v_shield).w
		move.b	d0,(v_invinc).w
		move.b	d0,(v_shoes).w
		move.b	d0,(v_unused1).w
		move.w	d0,(Debug_placement_mode).w
		move.w	d0,(Level_Inactive_flag).w
		move.w	d0,(Timer_frames).w
		bsr.w	OscillateNumInit
		move.b	#1,(f_scorecount).w
		move.b	#1,(f_ringcount).w
		move.b	#1,(f_timecount).w
		move.w	#4,(Sonic_Pos_Record_Index).w
		move.w	#0,(Sonic_Pos_Record_Buf).w
		move.w	#0,(Demo_button_index).w
		move.w	#0,(Demo_button_index_2P).w
		lea	(Demo_Index).l,a1
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		tst.w	(f_demo).w
		bpl.s	loc_3E78
		lea	(Demo_S1EndIndex).l,a1		; garbage, leftover from Sonic 1's ending sequence demos
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1

loc_3E78:
		move.b	1(a1),(Demo_press_counter).w
		subq.b	#1,(Demo_press_counter).w
		lea	(Demo_2P).l,a1
		move.b	1(a1),(Demo_press_counter_2P).w
		subq.b	#1,(Demo_press_counter_2P).w
		move.w	#$668,(v_demolength).w
		tst.w	(f_demo).w
		bpl.s	loc_3EB2
		move.w	#$21C,(v_demolength).w
		cmpi.w	#4,(v_creditsnum).w
		bne.s	loc_3EB2
		move.w	#$1FE,(v_demolength).w

loc_3EB2:
		tst.b	(Water_flag).w
		beq.s	loc_3EC8
		moveq	#$B,d0
		cmpi.b	#3,(Current_Act).w
		bne.s	loc_3EC4
		moveq	#$D,d0

loc_3EC4:
		bsr.w	PalLoad4_Water

loc_3EC8:
		move.w	#3,d1

loc_3ECC:
		move.b	#VintID_Level,(v_vbla_routine).w
		bsr.w	WaitForVint
		dbf	d1,loc_3ECC
		move.w	#$202F,(v_pfade_start).w
		bsr.w	Pal_FadeFromBlack2
		tst.w	(f_demo).w
		bmi.s	Level_ClrTitleCard
		addq.b	#2,(v_objspace+$80+obRoutine).w
		addq.b	#4,(v_objspace+$C0+obRoutine).w
		addq.b	#4,(v_objspace+$100+obRoutine).w
		addq.b	#4,(v_objspace+$140+obRoutine).w
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrTitleCard:
		moveq	#2,d0
		jsr	(LoadPLC).l
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		addi.w	#$15,d0
		jsr	(LoadPLC).l

Level_StartGame:
		bclr	#GameModeFlag_TitleCard,(v_gamemode).w

; ---------------------------------------------------------------------------
; Main level loop (when all title card and loading sequences are finished)
; ---------------------------------------------------------------------------
Level_MainLoop:
		bsr.w	PauseGame
		move.b	#VintID_Level,(v_vbla_routine).w
		bsr.w	WaitForVint
		addq.w	#1,(Timer_frames).w
		bsr.w	MoveSonicInDemo
		bsr.w	WaterEffects
		jsr	(RunObjects).l
		tst.w	(Level_Inactive_flag).w
		bne.w	Level
		tst.w	(Debug_placement_mode).w
		bne.s	loc_3F50
		cmpi.b	#6,(v_objspace+obRoutine).w
		bcc.s	loc_3F54

loc_3F50:
		bsr.w	DeformBGLayer

loc_3F54:
		bsr.w	ChangeWaterSurfacePos
		jsr	(RingsManager).l
		bsr.w	j_AniArt_Load
		bsr.w	PalCycle_Load
		bsr.w	RunPLC_RAM
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		bsr.w	SignpostArtLoad
		jsr	(BuildSprites).l
		jsr	(ObjectsManager).l
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		beq.s	loc_3F96
		cmpi.b	#GameModeID_Level,(v_gamemode).w
		beq.w	Level_MainLoop
		rts
; ---------------------------------------------------------------------------

loc_3F96:
		tst.w	(Level_Inactive_flag).w
		bne.s	loc_3FB4
		tst.w	(v_demolength).w
		beq.s	loc_3FB4
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		beq.w	Level_MainLoop
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		rts
; ---------------------------------------------------------------------------

loc_3FB4:
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		bne.s	loc_3FCE
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		tst.w	(f_demo).w
		bpl.s	loc_3FCE
		move.b	#GameModeID_S1Credits,(v_gamemode).w

loc_3FCE:
		move.w	#$3C,(v_demolength).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(PalChangeSpeed).w

loc_3FDE:
		move.b	#VintID_Level,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	MoveSonicInDemo
		jsr	(RunObjects).l
		jsr	(BuildSprites).l
		jsr	(ObjectsManager).l
		subq.w	#1,(PalChangeSpeed).w
		bpl.s	loc_400E
		move.w	#2,(PalChangeSpeed).w
		bsr.w	Pal_FadeOut

loc_400E:
		tst.w	(v_demolength).w
		bne.s	loc_3FDE
		rts

; =============== S U B	R O U T	I N E =======================================


ChangeWaterSurfacePos:
		tst.b	(Water_flag).w
		beq.s	locret_403E
		move.w	(Camera_RAM).w,d1
		btst	#0,($FFFFFE05).w
		beq.s	loc_402C
		addi.w	#$20,d1

loc_402C:
		move.w	d1,d0
		addi.w	#$60,d0
		move.w	d0,(v_objspace+$788).w
		addi.w	#$120,d1
		move.w	d1,(v_objspace+$7C8).w

locret_403E:
		rts
; End of function ChangeWaterSurfacePos


; =============== S U B	R O U T	I N E =======================================


WaterEffects:
		tst.b	(Water_flag).w
		beq.s	locret_4094
		tst.b	(Deform_lock).w
		bne.s	loc_4058
		cmpi.b	#6,(v_objspace+obRoutine).w
		bcc.s	loc_4058
		bsr.w	DynamicWaterHeight

loc_4058:
		clr.b	(f_wtr_state).w
		moveq	#0,d0
		move.b	($FFFFFE60).w,d0
		lsr.w	#1,d0
		add.w	(v_waterpos2).w,d0
		move.w	d0,(v_waterpos1).w
		move.w	(v_waterpos1).w,d0
		sub.w	(Camera_Y_pos).w,d0
		bcc.s	loc_4086
		tst.w	d0
		bpl.s	loc_4086
		move.b	#$DF,(v_hbla_line).w
		move.b	#1,(f_wtr_state).w

loc_4086:
		cmpi.w	#$DF,d0
		bcs.s	loc_4090
		move.w	#$DF,d0

loc_4090:
		move.b	d0,(v_hbla_line).w

locret_4094:
		rts
; End of function WaterEffects

; ---------------------------------------------------------------------------
WaterHeight:	dc.w  $600, $328, $900,	$228		; 0

; =============== S U B	R O U T	I N E =======================================


DynamicWaterHeight:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynWater_Index(pc,d0.w),d0
		jsr	DynWater_Index(pc,d0.w)
		moveq	#0,d1
		move.b	(f_water).w,d1
		move.w	(v_waterpos3).w,d0
		sub.w	(v_waterpos2).w,d0
		beq.s	locret_40C6
		bcc.s	loc_40C2
		neg.w	d1

loc_40C2:
		add.w	d1,(v_waterpos2).w

locret_40C6:
		rts
; End of function DynamicWaterHeight

; ---------------------------------------------------------------------------
DynWater_Index:	dc.w DynWater_HPZ1-DynWater_Index	; 0
		dc.w DynWater_HPZ2-DynWater_Index	; 1 ; leftover from Sonic 1's LZ2
		dc.w DynWater_HPZ3-DynWater_Index	; 2 ; leftover from Sonic 1's LZ3
		dc.w DynWater_HPZ4-DynWater_Index	; 3
; ---------------------------------------------------------------------------

DynWater_HPZ1:						; This uses the 2nd controller to make the water level move up or down
		btst	#0,(v_2Pjpadhold1).w
		beq.s	loc_40E2
		tst.w	(v_waterpos3).w
		beq.s	loc_40E2
		subq.w	#1,(v_waterpos3).w

loc_40E2:
		btst	#1,(v_2Pjpadhold1).w
		beq.s	locret_40F6
		cmpi.w	#$700,(v_waterpos3).w
		beq.s	locret_40F6
		addq.w	#1,(v_waterpos3).w

locret_40F6:
		rts
; ---------------------------------------------------------------------------

S1DynWater_LZ1:						; leftover from Sonic 1
		move.w	(Camera_RAM).w,d0
		move.b	(v_wtr_routine).w,d2
		bne.s	loc_4164
		move.w	#$B8,d1
		cmpi.w	#$600,d0
		bcs.s	loc_4148
		move.w	#$108,d1
		cmpi.w	#$200,(v_objspace+obY).w
		bcs.s	loc_414E
		cmpi.w	#$C00,d0
		bcs.s	loc_4148
		move.w	#$318,d1
		cmpi.w	#$1080,d0
		bcs.s	loc_4148
		move.b	#$80,(f_switch+5).w
		move.w	#$5C8,d1
		cmpi.w	#$1380,d0
		bcs.s	loc_4148
		move.w	#$3A8,d1
		cmp.w	(v_waterpos2).w,d1
		bne.s	loc_4148
		move.b	#1,(v_wtr_routine).w

loc_4148:
		move.w	d1,(v_waterpos3).w
		rts
; ---------------------------------------------------------------------------

loc_414E:
		cmpi.w	#$C80,d0
		bcs.s	loc_4148
		move.w	#$E8,d1
		cmpi.w	#$1500,d0
		bcs.s	loc_4148
		move.w	#$108,d1
		bra.s	loc_4148
; ---------------------------------------------------------------------------

loc_4164:
		subq.b	#1,d2
		bne.s	locret_4188
		cmpi.w	#$2E0,(v_objspace+obY).w
		bcc.s	locret_4188
		move.w	#$3A8,d1
		cmpi.w	#$1300,d0
		bcs.s	loc_4184
		move.w	#$108,d1
		move.b	#2,(v_wtr_routine).w

loc_4184:
		move.w	d1,(v_waterpos3).w

locret_4188:
		rts
; ---------------------------------------------------------------------------

DynWater_HPZ2:
		move.w	(Camera_RAM).w,d0		; leftover from Sonic 1's LZ2
		move.w	#$328,d1
		cmpi.w	#$500,d0
		bcs.s	loc_41A6
		move.w	#$3C8,d1
		cmpi.w	#$B00,d0
		bcs.s	loc_41A6
		move.w	#$428,d1

loc_41A6:
		move.w	d1,(v_waterpos3).w
		rts
; ---------------------------------------------------------------------------

DynWater_HPZ3:
		move.w	(Camera_RAM).w,d0		; Leftover from Sonic 1's LZ3
		move.b	(v_wtr_routine).w,d2
		bne.s	loc_41F2
		move.w	#$900,d1
		cmpi.w	#$600,d0
		bcs.s	loc_41E8
		cmpi.w	#$3C0,(v_objspace+obY).w
		bcs.s	loc_41E8
		cmpi.w	#$600,(v_objspace+obY).w
		bcc.s	loc_41E8
		move.w	#$4C8,d1
		move.b	#$4B,($FFFF8206).w
		move.b	#1,(v_wtr_routine).w
		move.w	#sfx_Rumbling,d0
		bsr.w	PlaySound_Special

loc_41E8:
		move.w	d1,(v_waterpos3).w
		move.w	d1,(v_waterpos2).w
		rts
; ---------------------------------------------------------------------------

loc_41F2:
		subq.b	#1,d2
		bne.s	loc_423C
		move.w	#$4C8,d1
		cmpi.w	#$770,d0
		bcs.s	loc_4236
		move.w	#$308,d1
		cmpi.w	#$1400,d0
		bcs.s	loc_4236
		cmpi.w	#$508,(v_waterpos3).w
		beq.s	loc_4222
		cmpi.w	#$600,(v_objspace+obY).w
		bcc.s	loc_4222
		cmpi.w	#$280,(v_objspace+obY).w
		bcc.s	loc_4236

loc_4222:
		move.w	#$508,d1
		move.w	d1,(v_waterpos2).w
		cmpi.w	#$1770,d0
		bcs.s	loc_4236
		move.b	#2,(v_wtr_routine).w

loc_4236:
		move.w	d1,(v_waterpos3).w
		rts
; ---------------------------------------------------------------------------

loc_423C:
		subq.b	#1,d2
		bne.s	loc_4266
		move.w	#$508,d1
		cmpi.w	#$1860,d0
		bcs.s	loc_4260
		move.w	#$188,d1
		cmpi.w	#$1AF0,d0
		bcc.s	loc_425A
		cmp.w	(v_waterpos2).w,d1
		bne.s	loc_4260

loc_425A:
		move.b	#3,(v_wtr_routine).w

loc_4260:
		move.w	d1,(v_waterpos3).w
		rts
; ---------------------------------------------------------------------------

loc_4266:
		subq.b	#1,d2
		bne.s	loc_42A2
		move.w	#$188,d1
		cmpi.w	#$1AF0,d0
		bcs.s	loc_4298
		move.w	#$900,d1
		cmpi.w	#$1BC0,d0
		bcs.s	loc_4298
		move.b	#4,(v_wtr_routine).w
		move.w	#$608,(v_waterpos3).w
		move.w	#$7C0,(v_waterpos2).w
		move.b	#1,(f_switch+8).w
		rts
; ---------------------------------------------------------------------------

loc_4298:
		move.w	d1,(v_waterpos3).w
		move.w	d1,(v_waterpos2).w
		rts
; ---------------------------------------------------------------------------

loc_42A2:
		cmpi.w	#$1E00,d0
		bcs.s	locret_42AE
		move.w	#$128,(v_waterpos3).w

locret_42AE:
		rts
; ---------------------------------------------------------------------------

DynWater_HPZ4:
		move.w	#$228,d1			; Leftover from Sonic 1's SBZ3
		cmpi.w	#$F00,(Camera_RAM).w
		bcs.s	loc_42C0
		move.w	#$4C8,d1

loc_42C0:
		move.w	d1,(v_waterpos3).w
		rts
; ---------------------------------------------------------------------------

S1_LZWindTunnels:					; leftover from Sonic 1's LZ
		tst.w	(Debug_placement_mode).w
		bne.w	locret_43A2
		lea	(S1LZWind_Data).l,a2
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		lsl.w	#3,d0
		adda.w	d0,a2
		moveq	#0,d1
		tst.b	(Current_Act).w
		bne.s	loc_42EA
		moveq	#1,d1
		subq.w	#8,a2

loc_42EA:
		lea	(v_objspace).w,a1

loc_42EE:
		move.w	obX(a1),d0
		cmp.w	(a2),d0
		bcs.w	loc_438C
		cmp.w	4(a2),d0
		bcc.w	loc_438C
		move.w	obY(a1),d2
		cmp.w	2(a2),d2
		bcs.w	loc_438C
		cmp.w	6(a2),d2
		bcc.s	loc_438C
		move.b	($FFFFFE0F).w,d0
		andi.b	#$3F,d0
		bne.s	loc_4326
		move.w	#sfx_Waterfall,d0
		jsr	(PlaySound_Special).l

loc_4326:
		tst.b	(f_wtunnelallow).w
		bne.w	locret_43A2
		cmpi.b	#4,obRoutine(a1)
		bcc.s	loc_439E
		move.b	#1,(f_wtunnelmode).w
		subi.w	#$80,d0
		cmp.w	(a2),d0
		bcc.s	loc_4354
		moveq	#2,d0
		cmpi.b	#1,(Current_Act).w
		bne.s	loc_4350
		neg.w	d0

loc_4350:
		add.w	d0,obY(a1)

loc_4354:
		addi.w	#4,obX(a1)
		move.w	#$400,obVelX(a1)
		move.w	#0,obVelY(a1)
		move.b	#$F,obAnim(a1)
		bset	#1,obStatus(a1)
		btst	#0,(v_jpadhold1).w
		beq.s	loc_437E
		subq.w	#1,obY(a1)

loc_437E:
		btst	#1,(v_jpadhold1).w
		beq.s	locret_438A
		addq.w	#1,obY(a1)

locret_438A:
		rts
; ---------------------------------------------------------------------------

loc_438C:
		addq.w	#8,a2
		dbf	d1,loc_42EE
		tst.b	(f_wtunnelmode).w
		beq.s	locret_43A2
		move.b	#0,obAnim(a1)

loc_439E:
		clr.b	(f_wtunnelmode).w

locret_43A2:
		rts
; ---------------------------------------------------------------------------
		dc.w  $A80, $300, $C10,	$380		; 0
S1LZWind_Data:	dc.w  $F80, $100,$1410,	$180, $460, $400, $710,	$480, $A20, $600,$1610,	$6E0, $C80, $600,$13D0,	$680 ; 0
; ---------------------------------------------------------------------------

S1_LZWaterSlides:
		lea	(v_objspace).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_4400
		move.w	obY(a1),d0
		andi.w	#$700,d0
		move.b	obX(a1),d1

loc_43E4:
		andi.w	#$7F,d1
		add.w	d1,d0
		lea	(v_lvllayout).w,a2
		move.b	(a2,d0.w),d0
		lea	byte_4465(pc),a2
		moveq	#6,d1

loc_43F8:
		cmp.b	-(a2),d0
		dbeq	d1,loc_43F8
		beq.s	loc_4412

loc_4400:
		tst.b	(f_slidemode).w
		beq.s	locret_4410
		move.w	#5,$2E(a1)
		clr.b	(f_slidemode).w

locret_4410:
		rts
; ---------------------------------------------------------------------------

loc_4412:
		cmpi.w	#3,d1
		bcc.s	loc_441A
		nop

loc_441A:
		bclr	#0,obStatus(a1)
		move.b	byte_4456(pc,d1.w),d0
		move.b	d0,obInertia(a1)
		bpl.s	loc_4430
		bset	#0,obStatus(a1)

loc_4430:
		clr.b	$15(a1)
		move.b	#$1B,obAnim(a1)
		move.b	#1,(f_slidemode).w
		move.b	($FFFFFE0F).w,d0
		andi.b	#$1F,d0
		bne.s	locret_4454
		move.w	#sfx_Waterfall,d0
		jsr	(PlaySound_Special).l

locret_4454:
		rts
; ---------------------------------------------------------------------------
byte_4456:	dc.b  $A,$F5, $A,$F6,$F5,$F4, $B,  0,  2,  7,  3,$4C,$4B,  8,  4 ; 0
byte_4465:	dc.b 0

; =============== S U B	R O U T	I N E =======================================


MoveSonicInDemo:
		tst.w	(f_demo).w
		bne.s	MoveDemo_On
		rts
; ---------------------------------------------------------------------------

MoveSonic_DemoRecord:					; unused subroutine for	recording demos
		lea	($FE8000).l,a1

loc_4474:
		move.w	(Demo_button_index).w,d0
		adda.w	d0,a1
		move.b	(v_jpadhold1).w,d0
		cmp.b	(a1),d0
		bne.s	loc_4490
		addq.b	#1,1(a1)
		cmpi.b	#$FF,1(a1)
		beq.s	loc_4490
		bra.s	loc_44A4
; ---------------------------------------------------------------------------

loc_4490:
		move.b	d0,2(a1)
		move.b	#0,3(a1)
		addq.w	#2,(Demo_button_index).w
		andi.w	#$3FF,(Demo_button_index).w

loc_44A4:
		cmpi.b	#3,(Current_Zone).w		; are we on Hidden Palace?
		bne.s	locret_44E2			; if not, branch
		lea	($FEC000).l,a1
		move.w	(Demo_button_index_2P).w,d0
		adda.w	d0,a1
		move.b	(v_2Pjpadhold1).w,d0
		cmp.b	(a1),d0
		bne.s	loc_44CE
		addq.b	#1,1(a1)
		cmpi.b	#$FF,1(a1)
		beq.s	loc_44CE
		bra.s	locret_44E2
; ---------------------------------------------------------------------------

loc_44CE:
		move.b	d0,2(a1)
		move.b	#0,3(a1)
		addq.w	#2,(Demo_button_index_2P).w
		andi.w	#$3FF,(Demo_button_index_2P).w

locret_44E2:
		rts
; ---------------------------------------------------------------------------

MoveDemo_On:
		tst.b	(v_jpadhold1).w
		bpl.s	loc_44F6
		tst.w	(f_demo).w
		bmi.s	loc_44F6
		move.b	#GameModeID_TitleScreen,(v_gamemode).w

loc_44F6:
		lea	(Demo_Index).l,a1
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w
		bne.s	loc_450C
		moveq	#6,d0

loc_450C:
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.w	(Demo_button_index).w,d0
		adda.w	d0,a1
		move.b	(a1),d0
		lea	(v_jpadhold1).w,a0
		move.b	d0,d1
		moveq	#0,d2
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,(Demo_press_counter).w
		bcc.s	loc_453A
		move.b	3(a1),(Demo_press_counter).w
		addq.w	#2,(Demo_button_index).w

loc_453A:
		cmpi.b	#3,(Current_Zone).w
		bne.s	loc_4572
		lea	(Demo_2P).l,a1
		move.w	(Demo_button_index_2P).w,d0
		adda.w	d0,a1
		move.b	(a1),d0
		lea	(v_2Pjpadhold1).w,a0
		move.b	d0,d1
		moveq	#0,d2
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,(Demo_press_counter_2P).w
		bcc.s	locret_4570
		move.b	3(a1),(Demo_press_counter_2P).w
		addq.w	#2,(Demo_button_index_2P).w

locret_4570:
		rts
; ---------------------------------------------------------------------------

loc_4572:
		move.w	#0,(v_2Pjpadhold1).w
		rts
; End of function MoveSonicInDemo

; ---------------------------------------------------------------------------
Demo_Index:	dc.l Demo_S1GHZ				; leftover demo	from Sonic 1 GHZ
		dc.l Demo_S1GHZ				; leftover demo	from Sonic 1 GHZ
		dc.l Demo_CPZ
		dc.l Demo_EHZ
		dc.l Demo_HPZ
		dc.l Demo_HTZ
		dc.l Demo_S1SS				; leftover demo	from Sonic 1 Special Stage
		dc.l Demo_S1SS				; leftover demo	from Sonic 1 Special Stage
		dc.l $FE8000
		dc.l $FE8000
		dc.l $FE8000
		dc.l $FE8000
		dc.l $FE8000
		dc.l $FE8000
		dc.l $FE8000
		dc.l $FE8000
		dc.l $FE8000
Demo_S1EndIndex:dc.l $8B0837				; garbage, leftover from Sonic 1's ending sequence demos
		dc.l $42085C
		dc.l $6A085F
		dc.l $2F082C
		dc.l $210803
		dc.l $28300808
		dc.l $2E0815
		dc.l $F0846
		dc.l $1A08FF
		dc.l $8CA0000
		dc.l 0
		dc.l 0

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ColIndexLoad:
LoadCollisionIndexes:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#2,d0
		move.l	#v_colladdr1,(Collision_addr).w
		movea.l	ColP_Index(pc,d0.w),a1
		lea	(v_colladdr1).w,a2
		bsr.s	Col_Load
		movea.l	ColS_Index(pc,d0.w),a1
		lea	(v_colladdr2).w,a2
; End of function LoadCollisionIndexes


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Col_Load:
		move.w	#$2FF,d1
		moveq	#0,d2

loc_4616:
		move.b	(a1)+,d2
		move.w	d2,(a2)+
		dbf	d1,loc_4616
		rts
; End of function Col_Load

; ===========================================================================
; ---------------------------------------------------------------------------
; Pointers to primary collision indexes

; Contains an array of pointers to the primary collision index data for each
; level. 1 pointer for each level, pointing the primary collision index.
; ---------------------------------------------------------------------------
ColP_Index:	dc.l ColP_GHZ				; 0
		dc.l ColP_CPZ				; 1
		dc.l ColP_CPZ				; 2
		dc.l ColP_EHZ				; 3
		dc.l ColP_HPZ				; 4
		dc.l ColP_EHZ				; 5

; ---------------------------------------------------------------------------
; Pointers to secondary collision indexes

; Contains an array of pointers to the secondary collision index data for
; each level. 1 pointer for each level, pointing the secondary collision
; index.
; ---------------------------------------------------------------------------
ColS_Index:	dc.l ColS_GHZ				; 0
		dc.l ColS_CPZ				; 1
		dc.l ColS_CPZ				; 2
		dc.l ColS_EHZ				; 3
		dc.l ColS_HPZ				; 4
		dc.l ColS_EHZ				; 5

; =============== S U B	R O U T	I N E =======================================


OscillateNumInit:
		lea	(v_oscillate).w,a1
		lea	(Osc_Data).l,a2
		moveq	#$20,d1

loc_465C:
		move.w	(a2)+,(a1)+
		dbf	d1,loc_465C
		rts
; End of function OscillateNumInit

; ---------------------------------------------------------------------------
Osc_Data:	dc.w   $7C,  $80			; 0
		dc.w	 0,  $80			; 2
		dc.w	 0,  $80			; 4
		dc.w	 0,  $80			; 6
		dc.w	 0,  $80			; 8
		dc.w	 0,  $80			; 10
		dc.w	 0,  $80			; 12
		dc.w	 0,  $80			; 14
		dc.w	 0,  $80			; 16
		dc.w	 0,$50F0			; 18
		dc.w  $11E,$2080			; 20
		dc.w   $B4,$3080			; 22
		dc.w  $10E,$5080			; 24
		dc.w  $1C2,$7080			; 26
		dc.w  $276,  $80			; 28
		dc.w	 0,  $80			; 30
		dc.w 0

; =============== S U B	R O U T	I N E =======================================


OscillateNumDo:
		cmpi.b	#6,(v_objspace+obRoutine).w
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

; =============== S U B	R O U T	I N E =======================================


ChangeRingFrame:
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_4754
		move.b	#$B,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_4754:
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_476A
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

loc_476A:
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_4788
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		cmpi.b	#6,(v_ani2_frame).w
		bcs.s	loc_4788
		move.b	#0,(v_ani2_frame).w

loc_4788:
		tst.b	(v_ani3_time).w
		beq.s	locret_47AA
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0
		add.w	(v_ani3_buf).w,d0
		move.w	d0,(v_ani3_buf).w
		rol.w	#7,d0
		andi.w	#3,d0
		move.b	d0,(v_ani3_frame).w
		subq.b	#1,(v_ani3_time).w

locret_47AA:
		rts
; End of function ChangeRingFrame


; =============== S U B	R O U T	I N E =======================================


SignpostArtLoad:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_47E2
		cmpi.b	#1,(Current_Act).w
		beq.s	locret_47E2
		move.w	(Camera_RAM).w,d0
		move.w	(Camera_Max_X_pos).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0
		blt.s	locret_47E2
		tst.b	(f_timecount).w
		beq.s	locret_47E2
		cmp.w	(Camera_Min_X_pos).w,d1
		beq.s	locret_47E2
		move.w	d1,(Camera_Min_X_pos).w
		moveq	#$12,d0
		bra.w	LoadPLC2
; ---------------------------------------------------------------------------

locret_47E2:
		rts
; End of function SignpostArtLoad

; ---------------------------------------------------------------------------
Demo_EHZ:	dc.b   0,$44,  8,  0,$28,  5,  8,$59,$28,  4,  8,$35,$28,  6,  8,$42 ; 0
		dc.b $28,  4,  8,$19,  0, $F,  8, $A,$28,  9,  8,$4A,$28,  9,  8,$10 ; 16
		dc.b   0,  5,  4,$1B,  2,  0,  8,$4B,$28,$2D,  8,$55,$28,  9,  8,$26 ; 32
		dc.b $28,$1C,  8,$19,$28,  8,  8,$FF,  8,$96,$28,$13,  8,$1D,$28,$19 ; 48
		dc.b   8,$2A,$28,  7,  9,  0,  1,  0,  5,$20,  4,  2,  5,  1,  0,  0 ; 64
		dc.b   8,$3A,  0,$25,  4, $A,$24,  9,  4,$1C,  0,  3,  8,$3A,$28,  6 ; 80
		dc.b   8, $C,  0,$16,  8,  0,$28, $F,  8,$33,$28,  7,  8,  4,  0,$46 ; 96
		dc.b   8,$6A,  0,$29,$80,  0,$C0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 112
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 128
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 144
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 160
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 176
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 192
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 208
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 224
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 240
Demo_2P:	dc.b   0,$46,  8,$1E,$28, $A,  8,$5E,$28,$30,  8,$66,  0, $F,  8, $F ; 0
		dc.b $28,$2E,  8,  0,  0,$1F,  8,$12,  0,$13,  8, $A,  0,$16,  4, $D ; 16
		dc.b   0,  8,  4,$10,  0,$30,  8,$6B,$28,$14,  8,$80, $A,  2,  2,$23 ; 32
		dc.b   0,  7,  8,$13,$28,$17,  8,  0,  0,  3,  4,  3,  5,  0,  1,  0 ; 48
		dc.b   9,  1,  8,$3C,$28,  7,  0,$18,  8,$4D,$28,$12,  8,  1,  0,  4 ; 64
		dc.b   8, $B,  0,  7,  8,$1B,  0,  9,$20,  5,$28,$13,  8,  4,  0,$21 ; 80
		dc.b   8,$11,  0,$20,  8,$51,  0, $B,  4,$57,  0, $D,  2,$27, $A,  0 ; 96
		dc.b   0,  2,  9,  1,  8,$2A,$28,$15,  8,  3,$28,$19,  8, $A,  0, $A ; 112
		dc.b   8,  2,$28,$1B,  8,$33,  0,$27,  8,$3A,  9,$12,  1,  7,  0,$13 ; 128
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 144
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 160
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 176
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 192
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 208
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 224
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 240
Demo_HTZ:	dc.b   0,  5,  1,$1D,  9,  3,$29,  5,  9,$10,  1,  0,  0,$13,  4,  0 ; 0
		dc.b   5, $A,$25,  7,  5,$10,  4,  1,  0, $C,  8,  4,  9, $C,$29, $A ; 16
		dc.b   9,$10,  8,  3,  0,$1C,$20,  7,  0, $B,  4,  6,  0,$25,$20,  6 ; 32
		dc.b   0,$22,  8,  5,  0,$25,  4, $E,  0,$33,  8,  7,  0,$39,  8, $A ; 48
		dc.b $28,  8,  8,$16,  0,$24,  8,$74,$28,  2,$29,  7,  9,  3,  0, $F ; 64
		dc.b   8, $D,  0,  5,  4, $C,  0,  1,$20,  2,$28,  0,$2A,  8,$28,  2 ; 80
		dc.b   8,$1E,  0,  4,  4,$13,  0,$12,  8,$18,$28, $B,  8,$11,  0,$2C ; 96
		dc.b   8, $C,  0, $D,$20,  4,$28,  3,  8,  5,  0,$22,  4,$12,  0,  4 ; 112
		dc.b   8,$1A,  0, $D,  4,  6,  0,$37,  8, $C,  0,$19,  8, $D,  0, $C ; 128
		dc.b   4,  9,  0,  3,  8,$20,  0,$1A,  4,  6,  0,$22,  8,  9,  0,  9 ; 144
		dc.b   8,$16,  0,$2F,  8, $E,$28,  4,$20,  2,  0,  8,  4,$19,  0,  5 ; 160
		dc.b   8,  6,$28,  8,  8,  8,  0,$24,  8,$72, $A,  9,  2, $E, $A,$6B ; 176
		dc.b $8A,  0,$40,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 192
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 208
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 224
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 240
Demo_HPZ:	dc.b   0,$40,  8,$33,$28,  6,  8,$39,$28,  5,  8, $D,  0,$25,  8,$10 ; 0
		dc.b $28,$2A,  8,$1C,  2,  0,$26,  3,$22,  0,$2A,  0,$28,  6,  8,$22 ; 16
		dc.b   2,  0,  6, $F,  4,  8,  6,  0,  2, $E,  6,$2F,  2,$79,  6,  1 ; 32
		dc.b   4,$43,$24, $F,  4,$17,  0,  9,  8,$1C,$28,  3,  8,$45,  0,  5 ; 48
		dc.b   8,$1A,$28,$33,  8,$72,  0, $F,  4,$15,$24,$10,  4, $B,  0,$24 ; 64
		dc.b   4,  1,$24,  8,  4,  7,  0,  6,  4,  4,  0,$1E,$24, $E,  4,$15 ; 80
		dc.b   0,$1E,$20,  3,$24, $F,  4,  0,  0,  7,  8,$12,  4,  9,$24, $F ; 96
		dc.b   4,  6,  0, $A,  4,$62,$24,$12,$20,  4,  0,$21,$28, $E,  8,$16 ; 112
		dc.b   0,$19,  8,$29,  0,$63,  4,$15,$24,  9,  4,$39,  0,$31,  8,$25 ; 128
		dc.b $28,  2,  8,$12,  0,$93,$80,  0,$C0,  0,  0,  0,  0,  0,  0,  0 ; 144
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 160
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 176
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 192
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 208
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 224
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 240
Demo_CPZ:	dc.b   0,$1B,  1,$30,  0,$19,  8,$29,$28,$13,  8,  3,  0,$1D,$20,  3 ; 0
		dc.b $28,$1E,  8,  2,  0,  9,  4,  5,  0,$2E,  8,$1E,$28,  5,$20,  3 ; 16
		dc.b   0, $B,  4,  1,  5,  7,  4,  0,  0,$2F,$28,  3,$2A,  4, $A,  0 ; 32
		dc.b   8,  6,  0,$24,  8,  2,$28,  6,  8,  1,  0,$26,  8,$FF,  8,$14 ; 48
		dc.b $28, $A,  8,  3,  0,$60,  8, $E,$28,  7,  8, $C,  0,  8,  4, $B ; 64
		dc.b   0,$23,  8,  5,  0,$93,  8,$19,$28,$11,  8,$78,$28, $F,  8,$FF ; 80
		dc.b   8,$83,$28, $D,  8,$82,  0,$1F,$80,  0,$40,  0,  0,  0,  0,  0 ; 96
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 112
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 128
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 144
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 160
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 176
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 192
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 208
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 224
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 240
Demo_S1GHZ:	dc.b   0,$4A,  8,$61,$28, $B,  8,$47,$28,  7,  8,$3B,$28,  8,  8,$D1 ; 0
		dc.b $28,$10,  8, $A,  0, $E,$20,$12,$28,  4,  8,$1F,  0, $B,  6,  5 ; 16 ; leftover demo from Sonic 1 GHZ
		dc.b   4,  5,  0,  4,$20, $B,$28, $E,  8,$20,  0,  5,$20,  2,$28,$12 ; 32
		dc.b   8, $F,  0, $F,  8, $B,  0,  0,$20, $E,$28,  4,  8, $B,  0,$1A ; 48
		dc.b   8, $C,  0,  6,$20,$12,$28,  7,  8,$77,$28,  0,$20, $C,$24,  4 ; 64
		dc.b $20,  7,$28,  6,  8,  4,  0, $F,  8,$39,  0,$11,  8, $D,$28, $A ; 80
		dc.b   8,$50,$28, $F,  8,  5,  0,$14,  8,$FF,  8,$56,  0,$FF,  0,$3F ; 96
		dc.b   8,  0,$28, $E,  8,$17,  0,$17,  8,  5,  0,  0,  0,  0,  0,  0 ; 112
		dc.b   0,  9,  8,$78,  0,  6,  8,  6,  0,  3,$20,  5,$28,$11,  8, $D ; 128
		dc.b   0,$2B,  8,  2,$29,  7,  9,  2,  0,  7,  5, $F,  0,  8,  8, $D ; 144
		dc.b $28,  7,  8, $B,  0,$28,  8,  0,  9,  2,$29,  2,$28,  4,  8,$12 ; 160
		dc.b   0,  9,  8,  0,$29,  2,$28,  4,  8,  9,  0, $F,  8, $C,  0, $E ; 176
		dc.b   9,  0,$29,  8,  9,  2,  8,$18,  0,  9,$28,  0,$29, $A,  9,$12 ; 192
		dc.b   8,  0,  0,$18,$29,$10,  9,$10,  8,  3,  0,$2F,  5,  6,  0,  9 ; 208
		dc.b   8,  0,  9,  1,$29,$12,  9,  0,  8,  5,  0,$24,  8,  0,  9,  0 ; 224
		dc.b $29,  9,$28,  6,  8, $A,  0,$2A,  8,$1B,  0,$17,  4,  5,  0, $C ; 240
		dc.b   8,$20,  0,  4,$20,  3,  0, $E,  9,  4,  1,  0,  0,$1E,  8,  5 ; 256
		dc.b   0,  1,$20,  6,$29,  1,  5,  7,  0,$13,  8,  5,  0,$15,$20,  1 ; 272
		dc.b $28,  2,$29,  4,  9,  1,  8,  0,  0,  7,  8, $B,  0,$19,  8, $B ; 288
		dc.b $28,  6,  8,  5,  0,$12,  8,$11,  0, $C,$20,  2,$28,  4,  8,  4 ; 304
		dc.b   0,$15,  8, $C,  0,$14,$20,  4,$28,  0,  8,  2,  0,$18,  8,  3 ; 320
		dc.b   0,$2C,$20,  2,$28,  7,  8,  4,  0,$24,  6,$48,  4,$47,  0, $A ; 336
		dc.b   4,  7,  0,$14,  4,$44,  5,  0,  4,  0,  0,$15,  8,$15, $A,  1 ; 352
		dc.b   0,  8,  4,  2,  5,$14,  0,  1,  5,  1,$25, $D,  5,$1B,  0,  7 ; 368
		dc.b   8,$23,  9,  0,  0,  7,  5,$22,$25, $B,  5,$52,  0,  6,  8,$26 ; 384
		dc.b   9,  1,  1,  0,  0,  0,  1,  0,  5,$17,$25,  8,  5,$1A,  0, $C ; 400
		dc.b   8,  6,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 416
		dc.b   0,$11,  8,$37,$28,  4,  8, $A,  0,$12,  8, $B,  0,$1F,  8,$1B ; 432
		dc.b   0,  9,  8,$20,  0,$14,  4,$16,$24,  0,$20, $F,  0,$13,  4,$17 ; 448
		dc.b   6,  4,  2,  0,  0,$24,  8, $D,  0,$46,  8,$77,  0,$60,  8,$17 ; 464
		dc.b   0,$16,  4,  3,  0,$22,  8,$19,$28,  2,$20,  1,  0,$26,$20,  9 ; 480
		dc.b   0,$3A,$20,$23,  0,  3,  8,  1,  0,$29,  4,$13,  0,$19,  4,$1B ; 496
		dc.b   0,$91,  8,$21,  0,$19,  4,  4,  0,$67,  4,$23,  0, $A,  8,  5 ; 512
		dc.b   0,$87,  8,$21,  0,$2C,  8,$27,  0, $F,  8,$35,$28,  8,  8,$45 ; 528
		dc.b $28,  9,  8,$31,  0,$99,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 544
Demo_S1SS:	dc.b   0,$26,  4,  5,  0,$2A,  8,$1B,  0,  6,  4,  9,  0,  6,$20,  1 ; 0
		dc.b $28,  1,$29,  2,  9,  0,  8,  8,  0,  6,  8,  7,  0,$49,  8, $B ; 16 ; leftover demo from Sonic 1 Special Stage
		dc.b   0,  2,$20,  3,  0, $D,  8,$1D,  0,$13,  8,  6,  0,$21,  8,$21 ; 32
		dc.b   0,  6,  8,$36,  0,$1E,  8,$1A,  0,  6,$20,  0,$28,  4,  8,$19 ; 48
		dc.b   0,  4,  4,$11,  0,$1F,  4, $D,  0, $C,  4,$1E,  5,  1,  4,  0 ; 64
		dc.b   0,  9,  8, $C,  0,  6,  4,  5,  5,  1,  4,$87,$24,  7,  4,  4 ; 80
		dc.b   0,  4,  8, $D,  9,$14,  8,  4,  0,  3,  4,$17,$24,$13,  4, $A ; 96
		dc.b   0,  4,  9,  9,  8,  2,  0,  6,  4,$18,$24, $B,$20,  4,  0,  2 ; 112
		dc.b   4,$2E,  5,  1,  4,  0,  0,$13,$20,$14,  0,  4,  8,$19,  0,$10 ; 128
		dc.b $20,$1D,$24,  7,  4, $E,  0, $B,$20,$1B,$24,  5,  4,$17,$24,  0 ; 144
		dc.b $20,$18,$24,  5,  4, $B,  0,  8,$20,$1F,$24,  1,  4,  8,  0, $B ; 160
		dc.b $20,$12,$28,  7,$29, $C,$20,  0,  4,$18,  0,$1A,  8,  0,  9,  7 ; 176
		dc.b   8,  9,  9,$31,  8,  0,  0,  7,$20,  8,$24,$15,  4,  8,  0,$27 ; 192
		dc.b $20,  9,$24,$12,  4, $E,$24, $E,  4, $A,  0,  9,  8,$16,$28,  0 ; 208
		dc.b $20, $F,$28,  4,$29,$1B,  9,  5,$29, $C,  9,  0,  8,  7,  0,$A0 ; 224
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 240
; ---------------------------------------------------------------------------

j_AniArt_Load:
		jmp	(AniArt_Load).l

; ---------------------------------------------------------------------------
		align 4

; ===========================================================================
; Sonic 1 Special Stage; crashes due to bad PLCs and missing pointers, but
; is otherwise identical
; GameMode10:
SpecialStage:
		move.w	#sfx_EnterSS,d0
		bsr.w	PlaySound_Special
		bsr.w	Pal_MakeFlash
		move	#$2700,sr
		lea	(vdp_control_port).l,a6
		move.w	#$8B03,(a6)
		move.w	#$8004,(a6)
		move.w	#$8AAF,(v_hbla_hreg).w
		move.w	#$9011,(a6)
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		move	#$2300,sr
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5)
		move.l	#$946F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$50000081,(a5)
		move.w	#0,(vdp_data_port).l

loc_507C:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_507C
		move.w	#$8F02,(a5)
		bsr.w	S1_SSBGLoad
		moveq	#$14,d0
		bsr.w	RunPLC_ROM
		lea	(v_colladdr1).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

loc_509C:
		move.l	d0,(a1)+
		dbf	d1,loc_509C
		clearRAM v_levelvariables,v_levelvariables_end
		lea	($FFFFFE60).w,a1
		moveq	#0,d0
		move.w	#$27,d1

loc_50BC:
		move.l	d0,(a1)+
		dbf	d1,loc_50BC
		clearRAM v_ngfx_buffer,v_ngfx_buffer_end
		clr.b	(f_wtr_state).w
		clr.w	(Level_Inactive_flag).w
		moveq	#$A,d0
		bsr.w	PalLoad1
		jsr	(S1SS_Load).l
		move.l	#0,(Camera_X_pos).w
		move.l	#0,(Camera_Y_pos).w
		move.b	#9,(v_objspace).w
		bsr.w	PalCycle_S1SS
		clr.w	($FFFFF780).w
		move.w	#$40,($FFFFF782).w
		move.w	#bgm_SS,d0
		bsr.w	PlaySound
		move.w	#0,(Demo_button_index).w
		lea	(Demo_Index).l,a1
		moveq	#6,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.b	1(a1),(Demo_press_counter).w
		subq.b	#1,(Demo_press_counter).w
		clr.w	(v_rings).w
		clr.b	(v_lifecount).w
		move.w	#0,(Debug_placement_mode).w
		move.w	#$708,(v_demolength).w
		tst.b	(f_debugcheat).w
		beq.s	loc_5158
		btst	#6,(v_jpadhold1).w
		beq.s	loc_5158
		move.b	#1,(Debug_mode_flag).w

loc_5158:
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	Pal_MakeWhite

loc_516A:
		bsr.w	PauseGame
		move.b	#VintID_S1SS,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr	(RunObjects).l
		jsr	(BuildSprites).l
		jsr	(S1SS_ShowLayout).l
		bsr.w	S1SS_BgAnimate
		tst.w	(f_demo).w
		beq.s	loc_51A6
		tst.w	(v_demolength).w
		beq.w	loc_52D4

loc_51A6:
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w
		beq.w	loc_516A
		tst.w	(f_demo).w
		bne.w	loc_52DC
		move.b	#GameModeID_Level,(v_gamemode).w
		cmpi.w	#$503,(Current_ZoneAndAct).w
		bcs.s	loc_51CA
		clr.w	(Current_ZoneAndAct).w

loc_51CA:
		move.w	#$3C,(v_demolength).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(PalChangeSpeed).w

loc_51DA:
		move.b	#VintID_SSResults,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr	(RunObjects).l
		jsr	(BuildSprites).l
		jsr	(S1SS_ShowLayout).l
		bsr.w	S1SS_BgAnimate
		subq.w	#1,(PalChangeSpeed).w
		bpl.s	loc_5214
		move.w	#2,(PalChangeSpeed).w
		bsr.w	Pal_ToWhite

loc_5214:
		tst.w	(v_demolength).w
		bne.s	loc_51DA
		move	#$2700,sr
		lea	(vdp_control_port).l,a6
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		bsr.w	ClearScreen
		move.l	#$70000002,(vdp_control_port).l
		lea	(Nem_S1TitleCard).l,a0
		bsr.w	NemDec
		jsr	(HUD_Base).l
		move	#$2300,sr
		moveq	#$11,d0
		bsr.w	PalLoad2
		moveq	#0,d0
		bsr.w	LoadPLC2
		moveq	#$1B,d0
		bsr.w	LoadPLC
		move.b	#1,(f_scorecount).w
		move.b	#1,(f_endactbonus).w
		move.w	(v_rings).w,d0
		mulu.w	#10,d0
		move.w	d0,(v_ringbonus).w
		move.w	#bgm_GotThrough,d0
		jsr	(PlaySound_Special).l
		clearRAM v_objspace,v_objspace_end
		move.b	#$7E,(v_objspace+$5C0).w

loc_529C:
		bsr.w	PauseGame
		move.b	#VintID_TitleCard,(v_vbla_routine).w
		bsr.w	WaitForVint
		jsr	(RunObjects).l
		jsr	(BuildSprites).l
		bsr.w	RunPLC_RAM
		tst.w	(Level_Inactive_flag).w
		beq.s	loc_529C
		tst.l	(v_plc_buffer).w
		bne.s	loc_529C
		move.w	#sfx_EnterSS,d0
		bsr.w	PlaySound_Special
		bsr.w	Pal_MakeFlash
		rts
; ---------------------------------------------------------------------------

loc_52D4:
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		rts
; ---------------------------------------------------------------------------

loc_52DC:
		cmpi.b	#GameModeID_Level,(v_gamemode).w
		beq.s	loc_52D4
		rts

; =============== S U B	R O U T	I N E =======================================


S1_SSBGLoad:
		lea	(v_ssbuffer1).l,a1
		move.w	#$4051,d0
		bsr.w	EniDec
		move.l	#$50000001,d3
		lea	($FFFF0080).l,a2
		moveq	#6,d7

loc_5302:
		move.l	d3,d0
		moveq	#3,d6
		moveq	#0,d4
		cmpi.w	#3,d7
		bcc.s	loc_5310
		moveq	#1,d4

loc_5310:
		moveq	#7,d5

loc_5312:
		movea.l	a2,a1
		eori.b	#1,d4
		bne.s	loc_5326
		cmpi.w	#6,d7
		bne.s	loc_5336
		lea	(v_ssbuffer1).l,a1

loc_5326:
		movem.l	d0-d4,-(sp)
		moveq	#7,d1
		moveq	#7,d2
		bsr.w	PlaneMapToVRAM_H40
		movem.l	(sp)+,d0-d4

loc_5336:
		addi.l	#$100000,d0
		dbf	d5,loc_5312
		addi.l	#$3800000,d0
		eori.b	#1,d4
		dbf	d6,loc_5310
		addi.l	#$10000000,d3
		bpl.s	loc_5360
		swap	d3
		addi.l	#$C000,d3
		swap	d3

loc_5360:
		adda.w	#$80,a2
		dbf	d7,loc_5302
		lea	(v_startofram).l,a1
		move.w	#$4000,d0
		bsr.w	EniDec
		lea	(v_startofram).l,a1
		move.l	#$40000003,d0
		moveq	#$3F,d1
		moveq	#$1F,d2
		bsr.w	PlaneMapToVRAM_H40
		lea	(v_startofram).l,a1
		move.l	#$50000003,d0
		moveq	#$3F,d1
		moveq	#$3F,d2
		bsr.w	PlaneMapToVRAM_H40
		rts
; End of function S1_SSBGLoad


; =============== S U B	R O U T	I N E =======================================


PalCycle_S1SS:
		tst.w	($FFFFF63A).w
		bne.s	locret_5424
		subq.w	#1,(v_palss_time).w
		bpl.s	locret_5424
		lea	(vdp_control_port).l,a6
		move.w	(v_palss_num).w,d0
		addq.w	#1,(v_palss_num).w
		andi.w	#$1F,d0
		lsl.w	#2,d0
		lea	(word_547A).l,a0
		adda.w	d0,a0
		move.b	(a0)+,d0
		bpl.s	loc_53D0
		move.w	#$1FF,d0

loc_53D0:
		move.w	d0,(v_palss_time).w
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,(v_ssbganim).w
		lea	(word_54FA).l,a1
		lea	(a1,d0.w),a1
		move.w	#$8200,d0
		move.b	(a1)+,d0
		move.w	d0,(a6)
		move.b	(a1),(v_scrposy_vdp).w
		move.w	#$8400,d0
		move.b	(a0)+,d0
		move.w	d0,(a6)
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_5426
		lea	(Pal_S1SSCyc1).l,a1
		adda.w	d0,a1
		lea	($FFFFFB4E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

locret_5424:
		rts
; ---------------------------------------------------------------------------

loc_5426:
		move.w	(v_palss_index).w,d1
		cmpi.w	#$8A,d0
		bcs.s	loc_5432
		addq.w	#1,d1

loc_5432:
		mulu.w	#$2A,d1
		lea	(Pal_S1SSCyc2).l,a1
		adda.w	d1,a1
		andi.w	#$7F,d0
		bclr	#0,d0
		beq.s	loc_5456
		lea	($FFFFFB6E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+

loc_5456:
		adda.w	#$C,a1
		lea	($FFFFFB5A).w,a2
		cmpi.w	#$A,d0
		bcs.s	loc_546C
		subi.w	#$A,d0
		lea	($FFFFFB7A).w,a2

loc_546C:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		rts
; End of function PalCycle_S1SS

; ---------------------------------------------------------------------------
word_547A:	dc.w  $300, $792, $300,	$790, $300, $78E, $300,	$78C, $300, $78B, $300,	$780, $300, $782, $300,	$784 ; 0
		dc.w  $300, $786, $300,	$788, $708, $700, $70A,	$70C,$FF0C, $718,$FF0C,	$718, $70A, $70C, $708,	$700 ; 16
		dc.w  $300, $688, $300,	$686, $300, $684, $300,	$682, $300, $681, $300,	$68A, $300, $68C, $300,	$68E ; 32
		dc.w  $300, $690, $300,	$692, $702, $624, $704,	$630,$FF06, $63C,$FF06,	$63C, $704, $630, $702,	$624 ; 48
word_54FA:	dc.w $1001,$1800,$1801,$2000,$2001,$2800,$2801 ;	0
Pal_S1SSCyc1:	dc.w  $400, $600, $620,	$624, $664, $666, $600,	$820, $A64, $A68, $AA6,	$AAA, $800, $C42, $E86,	$ECA ; 0
		dc.w  $EEC, $EEE, $400,	$420, $620, $620, $864,	$666, $420, $620, $842,	$842, $A86, $AAA, $620,	$842 ; 16
		dc.w  $A64, $C86, $EA8,	$EEE		; 32
Pal_S1SSCyc2:	dc.w  $EEA, $EE0, $AA0,	$880, $660, $440, $EE0,	$AA0, $440, $AA0, $AA0,	$AA0, $860, $860, $860,	$640 ; 0
		dc.w  $640, $640, $400,	$400, $400, $AEC, $6EA,	$4C6, $2A4,  $82,  $60,	$6EA, $4C6,  $60, $4C6,	$4C6 ; 16
		dc.w  $4C6, $484, $484,	$484, $442, $442, $442,	$400, $400, $400, $ECC,	$E8A, $C68, $A46, $824,	$602 ; 32
		dc.w  $E8A, $C68, $602,	$C68, $C68, $C68, $846,	$846, $846, $624, $624,	$624, $400, $400, $400,	$AEC ; 48
		dc.w  $8CA, $6A8, $486,	$264,  $42, $8CA, $6A8,	 $42, $6A8, $6A8, $6A8,	$684, $684, $684, $442,	$442 ; 64
		dc.w  $442, $400, $400,	$400, $EEC, $CCA, $AA8,	$886, $664, $442, $CCA,	$AA8, $442, $AA8, $AA8,	$AA8 ; 80
		dc.w  $864, $864, $864,	$642, $642, $642, $400,	$400, $400 ; 96

; =============== S U B	R O U T	I N E =======================================


S1SS_BgAnimate:
		move.w	(v_ssbganim).w,d0
		bne.s	loc_5634
		move.w	#0,(Camera_BG_Y_pos).w
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w

loc_5634:
		cmpi.w	#8,d0
		bcc.s	loc_568C
		cmpi.w	#6,d0
		bne.s	loc_564E
		addq.w	#1,(Camera_BG3_X_pos).w
		addq.w	#1,(Camera_BG_Y_pos).w
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w

loc_564E:
		moveq	#0,d0
		move.w	(Camera_BG_X_pos).w,d0
		neg.w	d0
		swap	d0
		lea	(byte_5709).l,a1
		lea	(v_ngfx_buffer).w,a3
		moveq	#9,d3

loc_5664:
		move.w	2(a3),d0
		bsr.w	CalcSine
		moveq	#0,d2
		move.b	(a1)+,d2
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,(a3)+
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d2,(a3)+
		dbf	d3,loc_5664
		lea	(v_ngfx_buffer).w,a3
		lea	(byte_56F6).l,a2
		bra.s	loc_56BC
; ---------------------------------------------------------------------------

loc_568C:
		cmpi.w	#$C,d0
		bne.s	loc_56B2
		subq.w	#1,(Camera_BG3_X_pos).w
		lea	($FFFFAB00).w,a3
		move.l	#$18000,d2
		moveq	#6,d1

loc_56A2:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf	d1,loc_56A2

loc_56B2:
		lea	($FFFFAB00).w,a3
		lea	(byte_5701).l,a2

loc_56BC:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	(Camera_BG_Y_pos).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

loc_56D8:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

loc_56E2:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf	d1,loc_56E2
		dbf	d3,loc_56D8
		rts
; End of function S1SS_BgAnimate

; ---------------------------------------------------------------------------
byte_56F6:	dc.b   9,$28,$18,$10,$28,$18,$10,$30,$18,  8,$10 ; 0
byte_5701:	dc.b   6,$30,$30,$30,$28,$18,$18,$18	; 0
byte_5709:	dc.b   8,  2,  4,$FF,  2,  3,  8,$FF,  4,  2,  2,  3,  8,$FD,  4,  2 ; 0
		dc.b   2,  3,  2,$FF,  0		; 16
; ---------------------------------------------------------------------------
		nop

; =============== S U B	R O U T	I N E =======================================


LevelSizeLoad:
		clr.w	(Scroll_flags).w
		clr.w	(Scroll_flags_BG).w
		clr.w	(Scroll_flags_BG2).w
		clr.w	(Scroll_flags_BG3).w
		clr.w	(Scroll_flags_P2).w
		clr.w	(Scroll_flags_BG_P2).w
		clr.w	(Scroll_flags_BG2_P2).w
		clr.w	(Scroll_flags_BG3_P2).w
		clr.w	(Scroll_flags_copy).w
		clr.w	(Scroll_flags_BG_copy).w
		clr.w	(Scroll_flags_BG2_copy).w
		clr.w	(Scroll_flags_BG3_copy).w
		clr.w	(Scroll_flags_copy_P2).w
		clr.w	(Scroll_flags_BG_copy_P2).w
		clr.w	(Scroll_flags_BG2_copy_P2).w
		clr.w	(Scroll_flags_BG3_copy_P2).w
		clr.b	(Deform_lock).w
		moveq	#0,d0
		move.b	d0,(Dynamic_Resize_Routine).w
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#3,d0
		lea	LevelSizeArray(pc,d0.w),a0
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_X_pos).w
		move.l	d0,(Camera_Min_X_pos_target).w
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_Y_pos).w
		move.l	d0,(Camera_Min_Y_pos_target).w
		move.w	#$1010,(Horiz_block_crossed_flag).w
		move.w	#$60,(Camera_Y_pos_bias).w
		bra.w	LevelSize_CheckLamp
; ===========================================================================
LevelSizeArray:
		dc.w	 0,  $24BF,     0,	$300	; GHZ1
		dc.w	 0,  $1EBF,     0,	$300	; GHZ2
		dc.w	 0,  $2960,     0,	$300	; GHZ3
		dc.w	 0,  $2ABF,     0,	$300	; GHZ4
		dc.w	 0,  $3FFF,     0,	$720	; LZ1
		dc.w	 0,  $3FFF,     0,	$720	; LZ2
		dc.w	 0,  $3FFF,     0,	$720	; LZ3
		dc.w	 0,  $3FFF,     0,	$720	; LZ4
		dc.w	 0,  $3FFF,     0,	$720	; CPZ1
		dc.w	 0,  $3FFF,     0,	$720	; CPZ2
		dc.w	 0,  $3FFF,     0,	$720	; CPZ3
		dc.w	 0,  $3FFF,     0,	$720	; CPZ4
		dc.w	 0,  $29A0,     0,	$320	; EHZ1
		dc.w	 0,  $2940,     0,	$420	; EHZ2
		dc.w	 0,  $25C0,     0,	$720	; EHZ3
		dc.w	 0,  $3FFF,     0,	$720	; EHZ4
		dc.w	 0,  $3FFF,     0,	$720	; HPZ1
		dc.w	 0,  $3FFF,     0,	$720	; HPZ2
		dc.w	 0,  $3FFF,     0,	$720	; HPZ3
		dc.w	 0,  $3FFF,     0,	$720	; HPZ4
		dc.w	 0,  $3FFF,     0,	$720	; HTZ1
		dc.w	 0,  $3FFF, -$100,	$720	; HTZ2
		dc.w $2080,  $3FFF,  $510,	$720	; HTZ3
		dc.w	 0,  $3FFF,     0,	$720	; HTZ4
		dc.w	 0,  $500,   $110,	$110	; S1 Ending 1
		dc.w	 0,  $DC0,   $110,	$110	; S1 Ending 2
		dc.w	 0,  $2FFF,     0,	$320	; S1 Ending 3
		dc.w	 0,  $2FFF,     0,	$320	; S1 Ending 4
; ===========================================================================
S1EndingStartLoc:dc.w	$50, $3B0, $EA0, $46C,$1750,  $BD, $A00, $62C
		dc.w  $BB0,  $4C,$1570,	$16C, $1B0, $72C,$1400,	$2AC
; ===========================================================================

LevelSize_CheckLamp:
		tst.b	(v_lastlamp).w
		beq.s	LevelSize_StartLoc
		jsr	(Lamppost_LoadInfo).l
		move.w	(v_objspace+obX).w,d1
		move.w	(v_objspace+obY).w,d0
		bra.s	LevelSize_StartLocLoaded
; ---------------------------------------------------------------------------

LevelSize_StartLoc:
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	StartLocArray(pc,d0.w),a1
		tst.w	(f_demo).w
		bpl.s	loc_58CE

		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	S1EndingStartLoc(pc,d0.w),a1

loc_58CE:
		moveq	#0,d1
		move.w	(a1)+,d1
		move.w	d1,(v_objspace+obX).w
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(v_objspace+obY).w

LevelSize_StartLocLoaded:
		subi.w	#$A0,d1
		bcc.s	loc_58E6
		moveq	#0,d1

loc_58E6:
		move.w	(Camera_Max_X_pos).w,d2
		cmp.w	d2,d1
		bcs.s	loc_58F0
		move.w	d2,d1

loc_58F0:
		move.w	d1,(Camera_X_pos).w
		move.w	d1,(Camera_X_pos_P2).w
		subi.w	#$60,d0
		bcc.s	loc_5900
		moveq	#0,d0

loc_5900:
		cmp.w	(Camera_Max_Y_pos).w,d0
		blt.s	loc_590A
		move.w	(Camera_Max_Y_pos).w,d0

loc_590A:
		move.w	d0,(Camera_Y_pos).w
		move.w	d0,(Camera_Y_pos_P2).w
		bsr.w	BgScrollSpeed
		rts
; End of function LevelSizeLoad

; ---------------------------------------------------------------------------
StartLocArray:	dc.w   $50, $3B0			; GHZ1
		dc.w   $50,  $FC			; GHZ2
		dc.w   $50, $3B0			; GHZ3
		dc.w   $80,  $A8			; GHZ4
		dc.w   $60,  $6C			; LZ1
		dc.w   $50,  $EC			; LZ2
		dc.w   $50, $2EC			; LZ3
		dc.w   $B80,   0			; LZ4
		binclude	"startpos/CPZ_1.bin"	; CPZ1
		dc.w   $30, $266			; CPZ2
		dc.w   $30, $166			; CPZ3
		dc.w   $80,  $A8			; CPZ4
		binclude	"startpos/EHZ_1.bin"	; EHZ1
		binclude	"startpos/EHZ_2.bin"	; EHZ2
		dc.w   $40, $370			; EHZ3
		dc.w   $80,  $A8			; EHZ4
		binclude	"startpos/HPZ_1.bin"	; HPZ1
		dc.w   $30, $1BD			; HPZ2
		dc.w   $30,  $EC			; HPZ3
		dc.w   $80,  $A8			; HPZ4
		binclude	"startpos/HTZ_1.bin"	; HTZ1
		binclude	"startpos/HTZ_2.bin"	; HTZ2
		dc.w $2140, $5AC			; HTZ3
		dc.w   $80,  $A8			; HTZ4
		dc.w  $620, $16B			; S1 Ending 1
		dc.w  $EE0, $16C			; S1 Ending 2
		dc.w   $80,  $A8			; S1 Ending 3
		dc.w   $80,  $A8			; S1 Ending 4

; =============== S U B	R O U T	I N E =======================================


BgScrollSpeed:
		tst.b	(v_lastlamp).w
		bne.s	loc_59B6
		move.w	d0,(Camera_BG_Y_pos).w
		move.w	d0,(Camera_BG2_Y_pos).w
		move.w	d1,(Camera_BG_X_pos).w
		move.w	d1,(Camera_BG2_X_pos).w
		move.w	d1,(Camera_BG3_X_pos).w
		move.w	d0,(Camera_BG_Y_pos_P2).w
		move.w	d0,(Camera_BG2_Y_pos_P2).w
		move.w	d1,(Camera_BG_X_pos_P2).w
		move.w	d1,(Camera_BG2_X_pos_P2).w
		move.w	d1,(Camera_BG3_X_pos_P2).w

loc_59B6:
		moveq	#0,d2
		move.b	(Current_Zone).w,d2
		add.w	d2,d2
		move.w	BgScroll_Index(pc,d2.w),d2
		jmp	BgScroll_Index(pc,d2.w)
; End of function BgScrollSpeed

; ---------------------------------------------------------------------------
BgScroll_Index:	dc.w BgScroll_GHZ-BgScroll_Index	; 0
		dc.w BgScroll_LZ-BgScroll_Index		; 1
		dc.w BgScroll_CPZ-BgScroll_Index	; 2
		dc.w BgScroll_EHZ-BgScroll_Index	; 3
		dc.w BgScroll_HPZ-BgScroll_Index	; 4
		dc.w BgScroll_EHZ-BgScroll_Index	; 5
		dc.w BgScroll_S1Ending-BgScroll_Index	; 6
; ---------------------------------------------------------------------------

BgScroll_GHZ:
		clr.l	(Camera_BG_X_pos).w
		clr.l	(Camera_BG_Y_pos).w
		clr.l	(Camera_BG2_Y_pos).w
		clr.l	(Camera_BG3_Y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(Camera_BG_X_pos_P2).w
		clr.l	(Camera_BG_Y_pos_P2).w
		clr.l	(Camera_BG2_Y_pos_P2).w
		clr.l	(Camera_BG3_Y_pos_P2).w
		rts
; ---------------------------------------------------------------------------

BgScroll_LZ:
		asr.l	#1,d0
		move.w	d0,(Camera_BG_Y_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_CPZ:
		lsr.w	#2,d0
		move.w	d0,(Camera_BG_Y_pos).w
		move.w	d0,(Camera_BG_Y_pos_P2).w
		clr.l	(Camera_BG_X_pos).w
		clr.l	(Camera_BG2_X_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_EHZ:
		clr.l	(Camera_BG_X_pos).w
		clr.l	(Camera_BG_Y_pos).w
		clr.l	(Camera_BG2_Y_pos).w
		clr.l	(Camera_BG3_Y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(Camera_BG_X_pos_P2).w
		clr.l	(Camera_BG_Y_pos_P2).w
		clr.l	(Camera_BG2_Y_pos_P2).w
		clr.l	(Camera_BG3_Y_pos_P2).w
		rts
; ---------------------------------------------------------------------------

BgScroll_HPZ:
		asr.w	#1,d0
		move.w	d0,(Camera_BG_Y_pos).w
		clr.l	(Camera_BG_X_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_S1SYZ:						; leftover from Sonic 1
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		addq.w	#1,d0
		move.w	d0,(Camera_BG_Y_pos).w
		clr.l	(Camera_BG_X_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_S1Ending:
		move.w	(Camera_RAM).w,d0
		asr.w	#1,d0
		move.w	d0,(Camera_BG_X_pos).w
		move.w	d0,(Camera_BG2_X_pos).w
		asr.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(Camera_BG3_X_pos).w
		clr.l	(Camera_BG_Y_pos).w
		clr.l	(Camera_BG2_Y_pos).w
		clr.l	(Camera_BG3_Y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts

; =============== S U B	R O U T	I N E =======================================


DeformBGLayer:
		tst.b	(Deform_lock).w
		beq.s	loc_5AA4
		rts
; ---------------------------------------------------------------------------

loc_5AA4:
		clr.w	(Scroll_flags).w
		clr.w	(Scroll_flags_BG).w
		clr.w	(Scroll_flags_BG2).w
		clr.w	(Scroll_flags_BG3).w
		clr.w	(Scroll_flags_P2).w
		clr.w	(Scroll_flags_BG_P2).w
		clr.w	(Scroll_flags_BG2_P2).w
		clr.w	(Scroll_flags_BG3_P2).w
		lea	(v_objspace).w,a0
		lea	(Camera_RAM).w,a1
		lea	(Horiz_block_crossed_flag).w,a2
		lea	(Scroll_flags).w,a3
		lea	(Camera_X_pos_diff).w,a4
		lea	(Horiz_scroll_delay_val).w,a5
		lea	(Sonic_Pos_Record_Buf).w,a6
		bsr.w	ScrollHorizontal
		lea	(Camera_Y_pos).w,a1
		lea	(Verti_block_crossed_flag).w,a2
		lea	(Camera_Y_pos_diff).w,a4
		bsr.w	ScrollVertical
		tst.w	(Two_player_mode).w
		beq.s	loc_5B2A
		lea	(v_objspace+$40).w,a0
		lea	(Camera_X_pos_P2).w,a1
		lea	(Horiz_block_crossed_flag_P2).w,a2
		lea	(Scroll_flags_P2).w,a3
		lea	(Camera_BG_Y_pos_diff).w,a4
		lea	(Horiz_scroll_delay_val_P2).w,a5
		lea	(Tails_Pos_Record_Buf_Dup).w,a6
		bsr.w	ScrollHorizontal
		lea	(Camera_Y_pos_P2).w,a1
		lea	(Verti_block_crossed_flag_P2).w,a2
		lea	(Camera_X_pos_diff_P2).w,a4
		bsr.w	ScrollVertical

loc_5B2A:
		bsr.w	DynScreenResizeLoad
		move.w	(Camera_Y_pos).w,(v_scrposy_vdp).w
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	Deform_Index(pc,d0.w),d0
		jmp	Deform_Index(pc,d0.w)
; End of function DeformBGLayer

; ---------------------------------------------------------------------------
Deform_Index:	dc.w Deform_GHZ-Deform_Index		; 0
		dc.w Deform_LZ-Deform_Index		; 1
		dc.w Deform_CPZ-Deform_Index		; 2
		dc.w Deform_EHZ-Deform_Index		; 3
		dc.w Deform_HPZ-Deform_Index		; 4
		dc.w Deform_HTZ-Deform_Index		; 5
		dc.w Deform_GHZ-Deform_Index		; 6
; ---------------------------------------------------------------------------

Deform_GHZ:
		tst.w	(Two_player_mode).w
		bne.w	loc_5C5A
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d6
		bsr.w	ScrollBlock6
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#0,d6
		bsr.w	ScrollBlock5
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_Y_pos).w,d0
		andi.w	#$7FF,d0
		lsr.w	#5,d0
		neg.w	d0
		addi.w	#$20,d0
		bpl.s	loc_5B9A
		moveq	#0,d0

loc_5B9A:
		move.w	d0,d4
		move.w	d0,($FFFFF618).w
		move.w	(Camera_RAM).w,d0
		cmpi.b	#GameModeID_TitleScreen,(v_gamemode).w
		bne.s	loc_5BAE
		moveq	#0,d0

loc_5BAE:
		neg.w	d0
		swap	d0
		lea	(v_bgscroll_buffer).w,a2
		addi.l	#$10000,(a2)+
		addi.l	#$C000,(a2)+
		addi.l	#$8000,(a2)+
		move.w	(v_bgscroll_buffer).w,d0
		add.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		move.w	#$1F,d1
		sub.w	d4,d1
		bcs.s	loc_5BE0

loc_5BDA:
		move.l	d0,(a1)+
		dbf	d1,loc_5BDA

loc_5BE0:
		move.w	($FFFFA804).w,d0
		add.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		move.w	#$F,d1

loc_5BEE:
		move.l	d0,(a1)+
		dbf	d1,loc_5BEE
		move.w	($FFFFA808).w,d0
		add.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		move.w	#$F,d1

loc_5C02:
		move.l	d0,(a1)+
		dbf	d1,loc_5C02
		move.w	#$2F,d1
		move.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0

loc_5C12:
		move.l	d0,(a1)+
		dbf	d1,loc_5C12
		move.w	#$27,d1
		move.w	(Camera_BG2_X_pos).w,d0
		neg.w	d0

loc_5C22:
		move.l	d0,(a1)+
		dbf	d1,loc_5C22
		move.w	(Camera_BG2_X_pos).w,d0
		move.w	(Camera_RAM).w,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2
		moveq	#0,d3
		move.w	d0,d3
		move.w	#$47,d1
		add.w	d4,d1

loc_5C48:
		move.w	d3,d0
		neg.w	d0
		move.l	d0,(a1)+
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf	d1,loc_5C48
		rts
; ---------------------------------------------------------------------------

loc_5C5A:
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d6
		bsr.w	ScrollBlock6
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#0,d6
		bsr.w	ScrollBlock5
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_Y_pos).w,d0
		andi.w	#$7FF,d0
		lsr.w	#5,d0
		neg.w	d0
		addi.w	#$20,d0
		bpl.s	loc_5C94
		moveq	#0,d0

loc_5C94:
		andi.w	#$FFFE,d0
		move.w	d0,d4
		lsr.w	#1,d4
		move.w	d0,($FFFFF618).w
		andi.l	#$FFFEFFFE,(v_scrposy_vdp).w
		move.w	(Camera_RAM).w,d0
		cmpi.b	#GameModeID_TitleScreen,(v_gamemode).w
		bne.s	loc_5CB6
		moveq	#0,d0

loc_5CB6:
		neg.w	d0
		swap	d0
		lea	(v_bgscroll_buffer).w,a2
		addi.l	#$10000,(a2)+
		addi.l	#$C000,(a2)+
		addi.l	#$8000,(a2)+
		move.w	(v_bgscroll_buffer).w,d0
		add.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		move.w	#$F,d1
		sub.w	d4,d1
		bcs.s	loc_5CE8

loc_5CE2:
		move.l	d0,(a1)+
		dbf	d1,loc_5CE2

loc_5CE8:
		move.w	($FFFFA804).w,d0
		add.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		move.w	#7,d1

loc_5CF6:
		move.l	d0,(a1)+
		dbf	d1,loc_5CF6
		move.w	($FFFFA808).w,d0
		add.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		move.w	#7,d1

loc_5D0A:
		move.l	d0,(a1)+
		dbf	d1,loc_5D0A
		move.w	#$17,d1
		move.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0

loc_5D1A:
		move.l	d0,(a1)+
		dbf	d1,loc_5D1A
		move.w	#$17,d1
		move.w	(Camera_BG2_X_pos).w,d0
		neg.w	d0

loc_5D2A:
		move.l	d0,(a1)+
		dbf	d1,loc_5D2A
		move.w	(Camera_BG2_X_pos).w,d0
		move.w	(Camera_RAM).w,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2
		add.l	d2,d2
		moveq	#0,d3
		move.w	d0,d3
		move.w	#$23,d1
		add.w	d4,d1

loc_5D52:
		move.w	d3,d0
		neg.w	d0
		move.l	d0,(a1)+
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf	d1,loc_5D52
		move.w	(Camera_BG_Y_pos_diff).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		add.l	d4,(Camera_BG3_X_pos_P2).w
		move.w	(Camera_BG_Y_pos_diff).w,d4
		ext.l	d4
		asl.l	#7,d4
		add.l	d4,(Camera_BG2_X_pos_P2).w
		lea	($FFFFE1C0).w,a1
		move.w	(Camera_Y_pos_P2).w,d0
		andi.w	#$7FF,d0
		lsr.w	#5,d0
		neg.w	d0
		addi.w	#$20,d0
		bpl.s	loc_5D98
		moveq	#0,d0

loc_5D98:
		andi.w	#$FFFE,d0
		move.w	d0,d4
		lsr.w	#1,d4
		move.w	d0,($FFFFF620).w
		subi.w	#$E0,($FFFFF620).w
		move.w	(Camera_Y_pos_P2).w,($FFFFF61E).w
		subi.w	#$E0,($FFFFF61E).w
		andi.l	#$FFFEFFFE,($FFFFF61E).w
		move.w	(Camera_X_pos_P2).w,d0
		cmpi.b	#GameModeID_TitleScreen,(v_gamemode).w
		bne.s	loc_5DCC
		moveq	#0,d0

loc_5DCC:
		neg.w	d0
		swap	d0
		move.w	(v_bgscroll_buffer).w,d0
		add.w	(Camera_BG3_X_pos_P2).w,d0
		neg.w	d0
		move.w	#$F,d1
		sub.w	d4,d1
		bcs.s	loc_5DE8

loc_5DE2:
		move.l	d0,(a1)+
		dbf	d1,loc_5DE2

loc_5DE8:
		move.w	($FFFFA804).w,d0
		add.w	(Camera_BG3_X_pos_P2).w,d0
		neg.w	d0
		move.w	#7,d1

loc_5DF6:
		move.l	d0,(a1)+
		dbf	d1,loc_5DF6
		move.w	($FFFFA808).w,d0
		add.w	(Camera_BG3_X_pos_P2).w,d0
		neg.w	d0
		move.w	#7,d1

loc_5E0A:
		move.l	d0,(a1)+
		dbf	d1,loc_5E0A
		move.w	#$17,d1
		move.w	(Camera_BG3_X_pos_P2).w,d0
		neg.w	d0

loc_5E1A:
		move.l	d0,(a1)+
		dbf	d1,loc_5E1A
		move.w	#$17,d1
		move.w	(Camera_BG2_X_pos_P2).w,d0
		neg.w	d0

loc_5E2A:
		move.l	d0,(a1)+
		dbf	d1,loc_5E2A
		move.w	(Camera_BG2_X_pos_P2).w,d0
		move.w	(Camera_X_pos_P2).w,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2
		add.l	d2,d2
		moveq	#0,d3
		move.w	d0,d3
		move.w	#$23,d1
		add.w	d4,d1

loc_5E52:
		move.w	d3,d0
		neg.w	d0
		move.l	d0,(a1)+
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf	d1,loc_5E52
		rts
; ---------------------------------------------------------------------------

Deform_LZ:
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#7,d4
		move.w	(Camera_Y_pos_diff).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	ScrollBlock1
		move.w	(Camera_BG_Y_pos).w,(v_bgscrposy_vdp).w
		lea	(Deform_LZ_Data1).l,a3
		lea	(Obj0A_WobbleData).l,a2
		move.b	(v_lz_deform).w,d2
		move.b	d2,d3
		addi.w	#$80,(v_lz_deform).w
		add.w	(Camera_BG_Y_pos).w,d2
		andi.w	#$FF,d2
		add.w	(Camera_Y_pos).w,d3
		andi.w	#$FF,d3
		lea	(v_hscrolltablebuffer).w,a1
		move.w	#$DF,d1
		move.w	(Camera_RAM).w,d0
		neg.w	d0
		move.w	d0,d6
		swap	d0
		move.w	(Camera_BG_X_pos).w,d0
		neg.w	d0
		move.w	(v_waterpos1).w,d4
		move.w	(Camera_Y_pos).w,d5

loc_5EC6:
		cmp.w	d4,d5
		bge.s	loc_5ED8
		move.l	d0,(a1)+
		addq.w	#1,d5
		addq.b	#1,d2
		addq.b	#1,d3
		dbf	d1,loc_5EC6
		rts
; ---------------------------------------------------------------------------

loc_5ED8:
		move.b	(a3,d3.w),d4
		ext.w	d4
		add.w	d6,d4
		move.w	d4,(a1)+
		move.b	(a2,d2.w),d4
		ext.w	d4
		add.w	d0,d4
		move.w	d4,(a1)+
		addq.b	#1,d2
		addq.b	#1,d3
		dbf	d1,loc_5ED8
		rts
; ---------------------------------------------------------------------------
Deform_LZ_Data1:dc.b   1,  1,  2,  2,  3,  3,  3,  3,  2,  2,  1,  1,  0,  0,  0,  0 ; 0
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 16
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 32
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 48
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 64
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 80
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 96
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 112
		dc.b $FF,$FF,$FE,$FE,$FD,$FD,$FD,$FD,$FE,$FE,$FF,$FF,  0,  0,  0,  0 ; 128
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 144
		dc.b   1,  1,  2,  2,  3,  3,  3,  3,  2,  2,  1,  1,  0,  0,  0,  0 ; 160
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 176
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 192
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 208
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 224
		dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 240
; ---------------------------------------------------------------------------

Deform_CPZ:
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.w	(Camera_Y_pos_diff).w,d5
		ext.l	d5
		asl.l	#6,d5
		bsr.w	ScrollBlock1
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		lea	(v_hscrolltablebuffer).w,a1
		move.w	#$DF,d1
		move.w	(Camera_RAM).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_BG_X_pos).w,d0
		neg.w	d0

loc_6026:
		move.l	d0,(a1)+
		dbf	d1,loc_6026
		rts
; ---------------------------------------------------------------------------

Deform_Unk:						; unknown BG deform
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.w	(Camera_Y_pos_diff).w,d5
		ext.l	d5
		asl.l	#6,d5
		bsr.w	ScrollBlock1
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#4,d6
		bsr.w	ScrollBlock5
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		move.b	(Scroll_flags_BG).w,d0
		or.b	(Scroll_flags_BG2).w,d0
		move.b	d0,(Scroll_flags_BG3).w
		clr.b	(Scroll_flags_BG).w
		clr.b	(Scroll_flags_BG2).w
		lea	(v_bgscroll_buffer).w,a1
		move.w	(Camera_BG_X_pos).w,d0
		neg.w	d0
		move.w	#$12,d1

loc_6078:
		move.w	d0,(a1)+
		dbf	d1,loc_6078
		move.w	(Camera_BG2_X_pos).w,d0
		neg.w	d0
		move.w	#$1C,d1

loc_6088:
		move.w	d0,(a1)+
		dbf	d1,loc_6088
		lea	(v_bgscroll_buffer).w,a2
		move.w	(Camera_BG_Y_pos).w,d0
		andi.w	#$3F0,d0
		lsr.w	#3,d0
		lea	(a2,d0.w),a2
		bra.w	loc_6306

; =============== S U B	R O U T	I N E =======================================


Deform_TitleScreen:
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		move.w	(Camera_RAM).w,d0
		cmpi.w	#$1C00,d0
		bcc.s	loc_60B6
		addq.w	#8,d0

loc_60B6:
		move.w	d0,(Camera_RAM).w
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_RAM).w,d2
		neg.w	d2
		moveq	#0,d0
		bra.s	loc_60E4
; ---------------------------------------------------------------------------

Deform_EHZ:
		tst.w	(Two_player_mode).w
		bne.w	loc_620E
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_RAM).w,d0
		neg.w	d0
		move.w	d0,d2
		swap	d0

loc_60E4:
		move.w	#0,d0
		move.w	#$15,d1

loc_60EC:
		move.l	d0,(a1)+
		dbf	d1,loc_60EC
		move.w	d2,d0
		asr.w	#6,d0
		move.w	#$39,d1

loc_60FA:
		move.l	d0,(a1)+
		dbf	d1,loc_60FA
		move.w	d0,d3
		move.b	($FFFFFE0F).w,d1
		andi.w	#7,d1
		bne.s	loc_6110
		subq.w	#1,(v_bgscroll_buffer).w

loc_6110:
		move.w	(v_bgscroll_buffer).w,d1
		andi.w	#$1F,d1
		lea	(Deform_EHZ_Data).l,a2
		lea	(a2,d1.w),a2
		move.w	#$14,d1

loc_6126:
		move.b	(a2)+,d0
		ext.w	d0
		add.w	d3,d0
		move.l	d0,(a1)+
		dbf	d1,loc_6126
		move.w	#0,d0
		move.w	#$A,d1

loc_613A:
		move.l	d0,(a1)+
		dbf	d1,loc_613A
		move.w	d2,d0
		asr.w	#4,d0
		move.w	#$F,d1

loc_6148:
		move.l	d0,(a1)+
		dbf	d1,loc_6148
		move.w	d2,d0
		asr.w	#4,d0
		move.w	d0,d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	#$F,d1

loc_615C:
		move.l	d0,(a1)+
		dbf	d1,loc_615C
		move.l	d0,d4
		swap	d4
		move.w	d2,d0
		asr.w	#1,d0
		move.w	d2,d1
		asr.w	#3,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$30,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#3,d3
		move.w	#$E,d1

loc_6188:
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,loc_6188
		move.w	#8,d1

loc_619A:
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		add.l	d0,d3
		swap	d3
		dbf	d1,loc_619A
		move.w	#$E,d1

loc_61B2:
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap	d3
		dbf	d1,loc_61B2
		rts
; End of function Deform_TitleScreen

; ---------------------------------------------------------------------------
Deform_EHZ_Data:dc.b   1,  2,  1,  3,  1,  2,  2,  1,  2,  3,  1,  2,  1,  2,  0,  0 ; 0
		dc.b   2,  0,  3,  2,  2,  3,  2,  2,  1,  3,  0,  0,  1,  0,  1,  3 ; 16
		dc.b   1,  2,  1,  3,  1,  2,  2,  1,  2,  3,  1,  2,  1,  2,  0,  0 ; 32
		dc.b   2,  0,  3,  2,  2,  3,  2,  2,  1,  3,  0,  0,  1,  0,  1,  3 ; 48
; ---------------------------------------------------------------------------

loc_620E:
		move.b	($FFFFFE0F).w,d1
		andi.w	#7,d1
		bne.s	loc_621C
		subq.w	#1,(v_bgscroll_buffer).w

loc_621C:
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		andi.l	#$FFFEFFFE,(v_scrposy_vdp).w
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_RAM).w,d0
		move.w	#$A,d1
		bsr.s	sub_6264
		moveq	#0,d0
		move.w	d0,($FFFFF620).w
		subi.w	#$E0,($FFFFF620).w
		move.w	(Camera_Y_pos_P2).w,($FFFFF61E).w

loc_624A:
		subi.w	#$E0,($FFFFF61E).w
		andi.l	#$FFFEFFFE,($FFFFF61E).w
		lea	($FFFFE1B0).w,a1
		move.w	(Camera_X_pos_P2).w,d0
		move.w	#$E,d1

; =============== S U B	R O U T	I N E =======================================


sub_6264:
		neg.w	d0
		move.w	d0,d2
		swap	d0
		move.w	#0,d0

loc_626E:
		move.l	d0,(a1)+
		dbf	d1,loc_626E
		move.w	d2,d0
		asr.w	#6,d0
		move.w	#$1C,d1

loc_627C:
		move.l	d0,(a1)+
		dbf	d1,loc_627C
		move.w	d0,d3
		move.w	(v_bgscroll_buffer).w,d1
		andi.w	#$1F,d1
		lea	Deform_EHZ_Data(pc),a2
		lea	(a2,d1.w),a2
		move.w	#$A,d1

loc_6298:
		move.b	(a2)+,d0
		ext.w	d0
		add.w	d3,d0
		move.l	d0,(a1)+
		dbf	d1,loc_6298
		move.w	#0,d0
		move.w	#4,d1

loc_62AC:
		move.l	d0,(a1)+
		dbf	d1,loc_62AC
		move.w	d2,d0
		asr.w	#4,d0
		move.w	#7,d1

loc_62BA:
		move.l	d0,(a1)+
		dbf	d1,loc_62BA
		move.w	d2,d0
		asr.w	#4,d0
		move.w	d0,d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	#7,d1

loc_62CE:
		move.l	d0,(a1)+
		dbf	d1,loc_62CE
		move.w	d2,d0
		asr.w	#1,d0
		move.w	d2,d1
		asr.w	#3,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$30,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#3,d3
		move.w	#$27,d1

loc_62F6:
		move.w	d2,(a1)+
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,loc_62F6
		rts
; End of function sub_6264

; ---------------------------------------------------------------------------

loc_6306:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	#$E,d1
		move.w	(Camera_RAM).w,d0
		neg.w	d0
		swap	d0
		andi.w	#$F,d2
		add.w	d2,d2
		move.w	(a2)+,d0
		jmp	loc_6324(pc,d2.w)
; ---------------------------------------------------------------------------

loc_6322:
		move.w	(a2)+,d0

loc_6324:
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,loc_6322
		rts
; ---------------------------------------------------------------------------

Deform_HPZ:
		move.w	(Camera_X_pos_diff).w,d4
		ext.l	d4
		asl.l	#6,d4
		moveq	#2,d6
		bsr.w	ScrollBlock4
		move.w	(Camera_Y_pos_diff).w,d5
		ext.l	d5
		asl.l	#7,d5
		moveq	#6,d6
		bsr.w	ScrollBlock2
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		lea	(v_bgscroll_buffer).w,a1
		move.w	(Camera_RAM).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#1,d0
		move.w	#7,d1

loc_637E:
		move.w	d0,(a1)+
		dbf	d1,loc_637E
		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#8,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3
		lea	($FFFFA860).w,a2
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	(Camera_BG_X_pos).w,d0
		neg.w	d0
		move.w	#$19,d1

loc_63E0:
		move.w	d0,(a1)+
		dbf	d1,loc_63E0
		adda.w	#$E,a1
		move.w	d2,d0
		asr.w	#1,d0
		move.w	#$17,d1

loc_63F2:
		move.w	d0,(a1)+
		dbf	d1,loc_63F2
		lea	(v_bgscroll_buffer).w,a2
		move.w	(Camera_BG_Y_pos).w,d0
		move.w	d0,d2
		andi.w	#$3F0,d0
		lsr.w	#3,d0
		lea	(a2,d0.w),a2
		bra.w	loc_6306
; ---------------------------------------------------------------------------

Deform_HTZ:
		move.w	(Camera_BG_Y_pos).w,($FFFFF618).w
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_RAM).w,d0
		neg.w	d0
		move.w	d0,d2
		swap	d0
		move.w	d2,d0
		asr.w	#3,d0
		move.w	#$7F,d1

loc_642C:
		move.l	d0,(a1)+
		dbf	d1,loc_642C
		move.l	d0,d4
		move.w	d2,d0
		asr.w	#1,d0
		move.w	d2,d1
		asr.w	#3,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$18,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#3,d3
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,d4
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,d4
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,d4
		move.w	#6,d1

loc_647E:
		move.l	d4,(a1)+
		dbf	d1,loc_647E
		swap	d3
		add.l	d0,d3
		add.l	d0,d3
		swap	d3
		move.w	d3,d4
		move.w	#7,d1

loc_6492:
		move.l	d4,(a1)+
		dbf	d1,loc_6492
		swap	d3
		add.l	d0,d3
		add.l	d0,d3
		swap	d3
		move.w	d3,d4
		move.w	#9,d1

loc_64A6:
		move.l	d4,(a1)+
		dbf	d1,loc_64A6
		swap	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap	d3
		move.w	d3,d4
		move.w	#$E,d1

loc_64BC:
		move.l	d4,(a1)+
		dbf	d1,loc_64BC
		swap	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap	d3
		move.w	#2,d2

loc_64D0:
		move.w	d3,d4
		move.w	#$F,d1

loc_64D6:
		move.l	d4,(a1)+
		dbf	d1,loc_64D6
		swap	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap	d3
		dbf	d2,loc_64D0
		rts

; =============== S U B	R O U T	I N E =======================================


ScrollHorizontal:
		move.w	(a1),d4
		bsr.s	sub_6514
		move.w	(a1),d0
		andi.w	#$10,d0
		move.b	(a2),d1
		eor.b	d1,d0
		bne.s	locret_6512
		eori.b	#$10,(a2)
		move.w	(a1),d0
		sub.w	d4,d0
		bpl.s	loc_650E
		bset	#2,(a3)
		rts
; ---------------------------------------------------------------------------

loc_650E:
		bset	#3,(a3)

locret_6512:
		rts
; End of function ScrollHorizontal


; =============== S U B	R O U T	I N E =======================================


sub_6514:
		move.w	(a5),d1
		beq.s	loc_6536
		subi.w	#$100,d1
		move.w	d1,(a5)
		moveq	#0,d1
		move.b	(a5),d1
		lsl.b	#2,d1
		addq.b	#4,d1
		move.w	2(a5),d0
		sub.b	d1,d0
		move.w	(a6,d0.w),d0
		andi.w	#$3FFF,d0
		bra.s	loc_653A
; ---------------------------------------------------------------------------

loc_6536:
		move.w	obX(a0),d0

loc_653A:
		sub.w	(a1),d0
		subi.w	#$90,d0
		blt.s	loc_654C
		subi.w	#$10,d0
		bge.s	loc_6564
		clr.w	(a4)
		rts
; ---------------------------------------------------------------------------

loc_654C:
		cmpi.w	#$FFF0,d0
		bgt.s	loc_6556
		move.w	#$FFF0,d0

loc_6556:
		add.w	(a1),d0
		cmp.w	(Camera_Min_X_pos).w,d0
		bgt.s	loc_657A
		move.w	(Camera_Min_X_pos).w,d0
		bra.s	loc_657A
; ---------------------------------------------------------------------------

loc_6564:
		cmpi.w	#$10,d0
		bcs.s	loc_656E
		move.w	#$10,d0

loc_656E:
		add.w	(a1),d0
		cmp.w	(Camera_Max_X_pos).w,d0
		blt.s	loc_657A
		move.w	(Camera_Max_X_pos).w,d0

loc_657A:
		move.w	d0,d1
		sub.w	(a1),d1
		asl.w	#8,d1
		move.w	d0,(a1)
		move.w	d1,(a4)
		rts
; End of function sub_6514


; =============== S U B	R O U T	I N E =======================================


ScrollVertical:
		moveq	#0,d1
		move.w	obY(a0),d0
		sub.w	(a1),d0
		btst	#2,obStatus(a0)
		beq.s	loc_6598
		subq.w	#5,d0

loc_6598:
		btst	#1,obStatus(a0)
		beq.s	loc_65B8
		addi.w	#$20,d0
		sub.w	(Camera_Y_pos_bias).w,d0
		bcs.s	loc_6602
		subi.w	#$40,d0
		bcc.s	loc_6602
		tst.b	(Camera_Max_Y_Pos_Changing).w
		bne.s	loc_6614
		bra.s	loc_65C4
; ---------------------------------------------------------------------------

loc_65B8:
		sub.w	(Camera_Y_pos_bias).w,d0
		bne.s	loc_65C8
		tst.b	(Camera_Max_Y_Pos_Changing).w
		bne.s	loc_6614

loc_65C4:
		clr.w	(a4)
		rts
; ---------------------------------------------------------------------------

loc_65C8:
		cmpi.w	#$60,(Camera_Y_pos_bias).w
		bne.s	loc_65F0
		move.w	obInertia(a0),d1
		bpl.s	loc_65D8
		neg.w	d1

loc_65D8:
		cmpi.w	#$800,d1
		bcc.s	loc_6602
		move.w	#$600,d1
		cmpi.w	#6,d0
		bgt.s	loc_665C
		cmpi.w	#$FFFA,d0
		blt.s	loc_662A
		bra.s	loc_661A
; ---------------------------------------------------------------------------

loc_65F0:
		move.w	#$200,d1
		cmpi.w	#2,d0
		bgt.s	loc_665C
		cmpi.w	#$FFFE,d0
		blt.s	loc_662A
		bra.s	loc_661A
; ---------------------------------------------------------------------------

loc_6602:
		move.w	#$1000,d1
		cmpi.w	#$10,d0
		bgt.s	loc_665C
		cmpi.w	#$FFF0,d0
		blt.s	loc_662A
		bra.s	loc_661A
; ---------------------------------------------------------------------------

loc_6614:
		moveq	#0,d0
		move.b	d0,(Camera_Max_Y_Pos_Changing).w

loc_661A:
		moveq	#0,d1
		move.w	d0,d1
		add.w	(a1),d1
		tst.w	d0
		bpl.w	loc_6664
		bra.w	loc_6634
; ---------------------------------------------------------------------------

loc_662A:
		neg.w	d1
		ext.l	d1
		asl.l	#8,d1
		add.l	(a1),d1
		swap	d1

loc_6634:
		cmp.w	(Camera_Min_Y_pos).w,d1
		bgt.s	loc_6686
		cmpi.w	#$FF00,d1
		bgt.s	loc_6656
		andi.w	#$7FF,d1
		andi.w	#$7FF,obY(a0)
		andi.w	#$7FF,(a1)
		andi.w	#$3FF,obX(a1)
		bra.s	loc_6686
; ---------------------------------------------------------------------------

loc_6656:
		move.w	(Camera_Min_Y_pos).w,d1
		bra.s	loc_6686
; ---------------------------------------------------------------------------

loc_665C:
		ext.l	d1
		asl.l	#8,d1
		add.l	(a1),d1
		swap	d1

loc_6664:
		cmp.w	(Camera_Max_Y_pos).w,d1
		blt.s	loc_6686
		subi.w	#$800,d1
		bcs.s	loc_6682
		andi.w	#$7FF,obY(a0)
		subi.w	#$800,(a1)
		andi.w	#$3FF,obX(a1)
		bra.s	loc_6686
; ---------------------------------------------------------------------------

loc_6682:
		move.w	(Camera_Max_Y_pos).w,d1

loc_6686:
		move.w	(a1),d4
		swap	d1
		move.l	d1,d3
		sub.l	(a1),d3
		ror.l	#8,d3
		move.w	d3,(a4)
		move.l	d1,(a1)
		move.w	(a1),d0
		andi.w	#$10,d0
		move.b	(a2),d1
		eor.b	d1,d0
		bne.s	locret_66B4
		eori.b	#$10,(a2)
		move.w	(a1),d0
		sub.w	d4,d0
		bpl.s	loc_66B0
		bset	#0,(a3)
		rts
; ---------------------------------------------------------------------------

loc_66B0:
		bset	#1,(a3)

locret_66B4:
		rts
; End of function ScrollVertical


; =============== S U B	R O U T	I N E =======================================


ScrollBlock1:
		move.l	(Camera_BG_X_pos).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(Camera_BG_X_pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Horiz_block_crossed_flag_BG).w,d3
		eor.b	d3,d1
		bne.s	loc_66EA
		eori.b	#$10,(Horiz_block_crossed_flag_BG).w
		sub.l	d2,d0
		bpl.s	loc_66E4
		bset	#2,(Scroll_flags_BG).w
		bra.s	loc_66EA
; ---------------------------------------------------------------------------

loc_66E4:
		bset	#3,(Scroll_flags_BG).w

loc_66EA:
		move.l	(Camera_BG_Y_pos).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(Camera_BG_Y_pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Verti_block_crossed_flag_BG).w,d2
		eor.b	d2,d1
		bne.s	locret_671E
		eori.b	#$10,(Verti_block_crossed_flag_BG).w
		sub.l	d3,d0
		bpl.s	loc_6718
		bset	#0,(Scroll_flags_BG).w
		rts
; ---------------------------------------------------------------------------

loc_6718:
		bset	#1,(Scroll_flags_BG).w

locret_671E:
		rts
; End of function ScrollBlock1


; =============== S U B	R O U T	I N E =======================================


ScrollBlock2:
		move.l	(Camera_BG_Y_pos).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(Camera_BG_Y_pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Verti_block_crossed_flag_BG).w,d2
		eor.b	d2,d1
		bne.s	locret_6752
		eori.b	#$10,(Verti_block_crossed_flag_BG).w
		sub.l	d3,d0
		bpl.s	loc_674C
		bset	d6,(Scroll_flags_BG).w
		rts
; ---------------------------------------------------------------------------

loc_674C:
		addq.b	#1,d6
		bset	d6,(Scroll_flags_BG).w

locret_6752:
		rts
; End of function ScrollBlock2

; ---------------------------------------------------------------------------

ScrollBlock3:
		move.w	(Camera_BG_Y_pos).w,d3
		move.w	d0,(Camera_BG_Y_pos).w
		move.w	d0,d1
		andi.w	#$10,d1
		move.b	(Verti_block_crossed_flag_BG).w,d2
		eor.b	d2,d1
		bne.s	locret_6782
		eori.b	#$10,(Verti_block_crossed_flag_BG).w
		sub.w	d3,d0
		bpl.s	loc_677C
		bset	#0,(Scroll_flags_BG).w
		rts
; ---------------------------------------------------------------------------

loc_677C:
		bset	#1,(Scroll_flags_BG).w

locret_6782:
		rts

; =============== S U B	R O U T	I N E =======================================


ScrollBlock4:
		move.l	(Camera_BG_X_pos).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(Camera_BG_X_pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Horiz_block_crossed_flag_BG).w,d3
		eor.b	d3,d1
		bne.s	locret_67B6
		eori.b	#$10,(Horiz_block_crossed_flag_BG).w
		sub.l	d2,d0
		bpl.s	loc_67B0
		bset	d6,(Scroll_flags_BG).w
		bra.s	locret_67B6
; ---------------------------------------------------------------------------

loc_67B0:
		addq.b	#1,d6
		bset	d6,(Scroll_flags_BG).w

locret_67B6:
		rts
; End of function ScrollBlock4


; =============== S U B	R O U T	I N E =======================================


ScrollBlock5:
		move.l	(Camera_BG2_X_pos).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(Camera_BG2_X_pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Horiz_block_crossed_flag_BG2).w,d3
		eor.b	d3,d1
		bne.s	locret_67EA
		eori.b	#$10,(Horiz_block_crossed_flag_BG2).w
		sub.l	d2,d0
		bpl.s	loc_67E4
		bset	d6,(Scroll_flags_BG2).w
		bra.s	locret_67EA
; ---------------------------------------------------------------------------

loc_67E4:
		addq.b	#1,d6
		bset	d6,(Scroll_flags_BG2).w

locret_67EA:
		rts
; End of function ScrollBlock5


; =============== S U B	R O U T	I N E =======================================


ScrollBlock6:
		move.l	(Camera_BG3_X_pos).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(Camera_BG3_X_pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Horiz_block_crossed_flag_BG3).w,d3
		eor.b	d3,d1
		bne.s	locret_681E
		eori.b	#$10,(Horiz_block_crossed_flag_BG3).w
		sub.l	d2,d0
		bpl.s	loc_6818
		bset	d6,(Scroll_flags_BG3).w
		bra.s	locret_681E
; ---------------------------------------------------------------------------

loc_6818:
		addq.b	#1,d6
		bset	d6,(Scroll_flags_BG3).w

locret_681E:
		rts
; End of function ScrollBlock6

; ---------------------------------------------------------------------------
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(Scroll_flags_BG).w,a2
		lea	(Camera_BG_X_pos).w,a3
		lea	(v_lvllayoutbg).w,a4
		move.w	#$6000,d2
		bsr.w	sub_69B2
		lea	(Scroll_flags_BG2).w,a2
		lea	(Camera_BG2_X_pos).w,a3
		bra.w	sub_6A82

; =============== S U B	R O U T	I N E =======================================


LoadTilesAsYouMove:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(Scroll_flags_BG_copy).w,a2
		lea	(Camera_BG_copy).w,a3
		lea	(v_lvllayoutbg).w,a4
		move.w	#$6000,d2
		bsr.w	sub_69B2
		lea	(Scroll_flags_BG2_copy).w,a2
		lea	(Camera_BG2_copy).w,a3
		bsr.w	sub_6A82
		lea	(Scroll_flags_BG3_copy).w,a2
		lea	(Camera_BG3_copy).w,a3
		bsr.w	sub_6B7C
		tst.w	(Two_player_mode).w
		beq.s	loc_689E
		lea	(Scroll_flags_copy_P2).w,a2
		lea	(Camera_P2_copy).w,a3
		lea	(v_lvllayout).w,a4
		move.w	#$6000,d2
		bsr.w	sub_694C

loc_689E:
		lea	(Scroll_flags_copy).w,a2
		lea	(Camera_RAM_copy).w,a3
		lea	(v_lvllayout).w,a4
		move.w	#$4000,d2
		tst.b	(byte_FFFFF720).w
		beq.s	loc_68E6
		move.b	#0,(byte_FFFFF720).w
		moveq	#$FFFFFFF0,d4
		moveq	#$F,d6

loc_68BE:
		movem.l	d4-d6,-(sp)
		moveq	#$FFFFFFF0,d5
		move.w	d4,d1
		bsr.w	sub_7084
		move.w	d1,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6D8C
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_68BE
		move.b	#0,(Scroll_flags_copy).w
		rts
; ---------------------------------------------------------------------------

loc_68E6:
		tst.b	(a2)
		beq.s	locret_694A
		bclr	#0,(a2)
		beq.s	loc_6900
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6D8C

loc_6900:
		bclr	#1,(a2)
		beq.s	loc_691A
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6D8C

loc_691A:
		bclr	#2,(a2)
		beq.s	loc_6930
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6CFE

loc_6930:
		bclr	#3,(a2)
		beq.s	locret_694A
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	sub_7084
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	sub_6CFE

locret_694A:
		rts
; End of function LoadTilesAsYouMove


; =============== S U B	R O U T	I N E =======================================


sub_694C:
		tst.b	(a2)
		beq.s	locret_69B0
		bclr	#0,(a2)
		beq.s	loc_6966
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_70C0
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6D8C

loc_6966:
		bclr	#1,(a2)
		beq.s	loc_6980
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_70C0
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6D8C

loc_6980:
		bclr	#2,(a2)
		beq.s	loc_6996
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_70C0
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6CFE

loc_6996:
		bclr	#3,(a2)
		beq.s	locret_69B0
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	sub_70C0
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	sub_6CFE

locret_69B0:
		rts
; End of function sub_694C


; =============== S U B	R O U T	I N E =======================================


sub_69B2:
		tst.b	(a2)
		beq.w	locret_6A80
		bclr	#0,(a2)
		beq.s	loc_69CE
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6D8C

loc_69CE:
		bclr	#1,(a2)
		beq.s	loc_69E8
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6D8C

loc_69E8:
		bclr	#2,(a2)
		beq.s	loc_69FE
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_6CFE

loc_69FE:
		bclr	#3,(a2)
		beq.s	loc_6A18
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	sub_7084
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	sub_6CFE

loc_6A18:
		bclr	#4,(a2)
		beq.s	loc_6A30
		moveq	#$FFFFFFF0,d4
		moveq	#0,d5
		bsr.w	sub_7086
		moveq	#$FFFFFFF0,d4
		moveq	#0,d5
		moveq	#$1F,d6
		bsr.w	sub_6D90

loc_6A30:
		bclr	#5,(a2)
		beq.s	loc_6A4C
		move.w	#$E0,d4
		moveq	#0,d5
		bsr.w	sub_7086
		move.w	#$E0,d4
		moveq	#0,d5
		moveq	#$1F,d6
		bsr.w	sub_6D90

loc_6A4C:
		bclr	#6,(a2)
		beq.s	loc_6A64
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		moveq	#$1F,d6
		bsr.w	sub_6D84

loc_6A64:
		bclr	#7,(a2)
		beq.s	locret_6A80
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		moveq	#$1F,d6
		bsr.w	sub_6D84

locret_6A80:
		rts
; End of function sub_69B2


; =============== S U B	R O U T	I N E =======================================


sub_6A82:
		tst.b	(a2)
		beq.w	locret_6ACE
		cmpi.b	#5,(Current_Zone).w
		beq.w	loc_6AF2
		bclr	#0,(a2)
		beq.s	loc_6AAE
		move.w	#$70,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		move.w	#$70,d4
		moveq	#$FFFFFFF0,d5
		moveq	#2,d6
		bsr.w	sub_6D00

loc_6AAE:
		bclr	#1,(a2)
		beq.s	locret_6ACE
		move.w	#$70,d4
		move.w	#$140,d5
		bsr.w	sub_7084
		move.w	#$70,d4
		move.w	#$140,d5
		moveq	#2,d6
		bsr.w	sub_6D00

locret_6ACE:
		rts
; ---------------------------------------------------------------------------
byte_6AD0:	dc.b 0
byte_6AD1:	dc.b   0,  0,  0,  0,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  4 ; 0
		dc.b   4,  4,  4,  4,  4,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2 ; 16
		dc.b 0
; ---------------------------------------------------------------------------

loc_6AF2:
		moveq	#$FFFFFFF0,d4
		bclr	#0,(a2)
		bne.s	loc_6B04
		bclr	#1,(a2)
		beq.s	loc_6B4C
		move.w	#$E0,d4

loc_6B04:
		lea	byte_6AD1(pc),a0
		move.w	(Camera_BG_Y_pos).w,d0
		add.w	d4,d0
		andi.w	#$1F0,d0
		lsr.w	#4,d0
		move.b	(a0,d0.w),d0
		lea	(word_6C78).l,a3
		movea.w	(a3,d0.w),a3
		beq.s	loc_6B38
		moveq	#$FFFFFFF0,d5
		movem.l	d4-d5,-(sp)
		bsr.w	sub_7084
		movem.l	(sp)+,d4-d5
		bsr.w	sub_6D8C
		bra.s	loc_6B4C
; ---------------------------------------------------------------------------

loc_6B38:
		moveq	#0,d5
		movem.l	d4-d5,-(sp)
		bsr.w	sub_7086
		movem.l	(sp)+,d4-d5
		moveq	#$1F,d6
		bsr.w	sub_6D90

loc_6B4C:
		tst.b	(a2)
		bne.s	loc_6B52
		rts
; ---------------------------------------------------------------------------

loc_6B52:
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		move.b	(a2),d0
		andi.b	#$A8,d0
		beq.s	loc_6B66
		lsr.b	#1,d0
		move.b	d0,(a2)
		move.w	#$140,d5

loc_6B66:
		lea	byte_6AD0(pc),a0
		move.w	(Camera_BG_Y_pos).w,d0
		andi.w	#$1F0,d0
		lsr.w	#4,d0
		lea	(a0,d0.w),a0
		bra.w	loc_6C80
; End of function sub_6A82


; =============== S U B	R O U T	I N E =======================================


sub_6B7C:
		tst.b	(a2)
		beq.w	locret_6BC8
		cmpi.b	#2,(Current_Zone).w
		beq.w	loc_6C0C
		bclr	#0,(a2)
		beq.s	loc_6BA8
		move.w	#$40,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	sub_7084
		move.w	#$40,d4
		moveq	#$FFFFFFF0,d5
		moveq	#2,d6
		bsr.w	sub_6D00

loc_6BA8:
		bclr	#1,(a2)
		beq.s	locret_6BC8
		move.w	#$40,d4
		move.w	#$140,d5
		bsr.w	sub_7084
		move.w	#$40,d4
		move.w	#$140,d5
		moveq	#2,d6
		bsr.w	sub_6D00

locret_6BC8:
		rts
; ---------------------------------------------------------------------------
byte_6BCA:	dc.b 0
byte_6BCB:	dc.b   2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2 ; 0
		dc.b   2,  2,  2,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4 ; 16
		dc.b   4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4 ; 32
		dc.b   4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4 ; 48
		dc.b 0
; ---------------------------------------------------------------------------

loc_6C0C:
		moveq	#$FFFFFFF0,d4
		bclr	#0,(a2)
		bne.s	loc_6C1E
		bclr	#1,(a2)
		beq.s	loc_6C48
		move.w	#$E0,d4

loc_6C1E:
		lea	byte_6BCB(pc),a0
		move.w	(Camera_BG_Y_pos).w,d0
		add.w	d4,d0
		andi.w	#$3F0,d0
		lsr.w	#4,d0
		move.b	(a0,d0.w),d0
		movea.w	word_6C78(pc,d0.w),a3
		moveq	#$FFFFFFF0,d5
		movem.l	d4-d5,-(sp)
		bsr.w	sub_7084
		movem.l	(sp)+,d4-d5
		bsr.w	sub_6D8C

loc_6C48:
		tst.b	(a2)
		bne.s	loc_6C4E
		rts
; ---------------------------------------------------------------------------

loc_6C4E:
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		move.b	(a2),d0
		andi.b	#$A8,d0
		beq.s	loc_6C62
		lsr.b	#1,d0
		move.b	d0,(a2)
		move.w	#$140,d5

loc_6C62:
		lea	byte_6BCA(pc),a0
		move.w	(Camera_BG_Y_pos).w,d0
		andi.w	#$7F0,d0
		lsr.w	#4,d0
		lea	(a0,d0.w),a0
		bra.w	loc_6C80
; ---------------------------------------------------------------------------
word_6C78:	dc.w $EE68,$EE68,$EE70,$EE78		; 0
; ---------------------------------------------------------------------------

loc_6C80:
		tst.w	(Two_player_mode).w
		bne.s	loc_6CC2
		moveq	#$F,d6
		move.l	#$800000,d7

loc_6C8E:
		moveq	#0,d0
		move.b	(a0)+,d0
		btst	d0,(a2)
		beq.s	loc_6CB6
		movea.w	word_6C78(pc,d0.w),a3
		movem.l	d4-d5/a0,-(sp)
		movem.l	d4-d5,-(sp)
		bsr.w	sub_7040
		movem.l	(sp)+,d4-d5
		bsr.w	sub_7084
		bsr.w	sub_6F70
		movem.l	(sp)+,d4-d5/a0

loc_6CB6:
		addi.w	#$10,d4
		dbf	d6,loc_6C8E
		clr.b	(a2)
		rts
; ---------------------------------------------------------------------------

loc_6CC2:
		moveq	#$F,d6
		move.l	#$800000,d7

loc_6CCA:
		moveq	#0,d0
		move.b	(a0)+,d0
		btst	d0,(a2)
		beq.s	loc_6CF2
		movea.w	word_6C78(pc,d0.w),a3
		movem.l	d4-d5/a0,-(sp)
		movem.l	d4-d5,-(sp)
		bsr.w	sub_7040
		movem.l	(sp)+,d4-d5
		bsr.w	sub_7084
		bsr.w	sub_6FF6
		movem.l	(sp)+,d4-d5/a0

loc_6CF2:
		addi.w	#$10,d4
		dbf	d6,loc_6CCA
		clr.b	(a2)
		rts
; End of function sub_6B7C


; =============== S U B	R O U T	I N E =======================================


sub_6CFE:
		moveq	#$F,d6
; End of function sub_6CFE


; =============== S U B	R O U T	I N E =======================================


sub_6D00:
		add.w	(a3),d5
		add.w	4(a3),d4
		move.l	#$800000,d7
		move.l	d0,d1
		bsr.w	sub_6E98
		tst.w	(Two_player_mode).w
		bne.s	loc_6D4E

loc_6D18:
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		lea	(v_16x16).w,a1
		adda.w	d3,a1
		move.l	d1,d0
		bsr.w	sub_6F70
		adda.w	#$10,a0
		addi.w	#$100,d1
		andi.w	#$FFF,d1
		addi.w	#$10,d4
		move.w	d4,d0
		andi.w	#$70,d0
		bne.s	loc_6D48
		bsr.w	sub_6E98

loc_6D48:
		dbf	d6,loc_6D18
		rts
; ---------------------------------------------------------------------------

loc_6D4E:
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		lea	(v_16x16).w,a1
		adda.w	d3,a1
		move.l	d1,d0
		bsr.w	sub_6FF6
		adda.w	#$10,a0
		addi.w	#$80,d1
		andi.w	#$FFF,d1
		addi.w	#$10,d4
		move.w	d4,d0
		andi.w	#$70,d0
		bne.s	loc_6D7E
		bsr.w	sub_6E98

loc_6D7E:
		dbf	d6,loc_6D4E
		rts
; End of function sub_6D00


; =============== S U B	R O U T	I N E =======================================


sub_6D84:
		add.w	(a3),d5
		add.w	4(a3),d4
		bra.s	loc_6D94
; End of function sub_6D84


; =============== S U B	R O U T	I N E =======================================


sub_6D8C:
		moveq	#$15,d6
		add.w	(a3),d5
; End of function sub_6D8C


; =============== S U B	R O U T	I N E =======================================


sub_6D90:
		add.w	4(a3),d4

loc_6D94:
		tst.w	(Two_player_mode).w
		bne.s	loc_6E12
		move.l	a2,-(sp)
		move.w	d6,-(sp)
		lea	(Block_cache).w,a2
		move.l	d0,d1
		or.w	d2,d1
		swap	d1
		move.l	d1,-(sp)
		move.l	d1,(a5)
		swap	d1
		bsr.w	sub_6E98

loc_6DB2:
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		lea	(v_16x16).w,a1
		adda.w	d3,a1
		bsr.w	sub_6ED0
		addq.w	#2,a0
		addq.b	#4,d1
		bpl.s	loc_6DD4
		andi.b	#$7F,d1
		swap	d1
		move.l	d1,(a5)
		swap	d1

loc_6DD4:
		addi.w	#$10,d5
		move.w	d5,d0
		andi.w	#$70,d0
		bne.s	loc_6DE4
		bsr.w	sub_6E98

loc_6DE4:
		dbf	d6,loc_6DB2
		move.l	(sp)+,d1
		addi.l	#$800000,d1
		lea	(Block_cache).w,a2
		move.l	d1,(a5)
		swap	d1
		move.w	(sp)+,d6

loc_6DFA:
		move.l	(a2)+,(a6)
		addq.b	#4,d1
		bmi.s	loc_6E0A
		ori.b	#$80,d1
		swap	d1
		move.l	d1,(a5)
		swap	d1

loc_6E0A:
		dbf	d6,loc_6DFA
		movea.l	(sp)+,a2
		rts
; ---------------------------------------------------------------------------

loc_6E12:
		move.l	d0,d1
		or.w	d2,d1
		swap	d1
		move.l	d1,(a5)
		swap	d1
		tst.b	d1
		bmi.s	loc_6E5C
		bsr.w	sub_6E98

loc_6E24:
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		lea	(v_16x16).w,a1
		adda.w	d3,a1
		bsr.w	sub_6F32
		addq.w	#2,a0
		addq.b	#4,d1
		bpl.s	loc_6E46
		andi.b	#$7F,d1
		swap	d1
		move.l	d1,(a5)
		swap	d1

loc_6E46:
		addi.w	#$10,d5
		move.w	d5,d0
		andi.w	#$70,d0
		bne.s	loc_6E56
		bsr.w	sub_6E98

loc_6E56:
		dbf	d6,loc_6E24
		rts
; ---------------------------------------------------------------------------

loc_6E5C:
		bsr.w	sub_6E98

loc_6E60:
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		lea	(v_16x16).w,a1
		adda.w	d3,a1
		bsr.w	sub_6F32
		addq.w	#2,a0
		addq.b	#4,d1
		bmi.s	loc_6E82
		ori.b	#$80,d1
		swap	d1
		move.l	d1,(a5)
		swap	d1

loc_6E82:
		addi.w	#$10,d5
		move.w	d5,d0
		andi.w	#$70,d0
		bne.s	loc_6E92
		bsr.w	sub_6E98

loc_6E92:
		dbf	d6,loc_6E60
		rts
; End of function sub_6D90


; =============== S U B	R O U T	I N E =======================================


sub_6E98:
		movem.l	d4-d5,-(sp)
		move.w	d4,d3
		add.w	d3,d3
		andi.w	#$F00,d3
		lsr.w	#3,d5
		move.w	d5,d0
		lsr.w	#4,d0
		andi.w	#$7F,d0
		add.w	d3,d0
		moveq	#$FFFFFFFF,d3
		move.b	(a4,d0.w),d3
		andi.w	#$FF,d3
		lsl.w	#7,d3
		andi.w	#$70,d4
		andi.w	#$E,d5
		add.w	d4,d3
		add.w	d5,d3
		movea.l	d3,a0
		movem.l	(sp)+,d4-d5
		rts
; End of function sub_6E98


; =============== S U B	R O U T	I N E =======================================


sub_6ED0:
		btst	#3,(a0)
		bne.s	loc_6EFC
		btst	#2,(a0)
		bne.s	loc_6EE2
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a2)+
		rts
; ---------------------------------------------------------------------------

loc_6EE2:
		move.l	(a1)+,d3
		eori.l	#$8000800,d3
		swap	d3
		move.l	d3,(a6)
		move.l	(a1)+,d3
		eori.l	#$8000800,d3
		swap	d3
		move.l	d3,(a2)+
		rts
; ---------------------------------------------------------------------------

loc_6EFC:
		btst	#2,(a0)
		bne.s	loc_6F18
		move.l	(a1)+,d0
		move.l	(a1)+,d3
		eori.l	#$10001000,d3
		move.l	d3,(a6)
		eori.l	#$10001000,d0
		move.l	d0,(a2)+
		rts
; ---------------------------------------------------------------------------

loc_6F18:
		move.l	(a1)+,d0
		move.l	(a1)+,d3
		eori.l	#$18001800,d3
		swap	d3
		move.l	d3,(a6)
		eori.l	#$18001800,d0
		swap	d0
		move.l	d0,(a2)+
		rts
; End of function sub_6ED0


; =============== S U B	R O U T	I N E =======================================


sub_6F32:
		btst	#3,(a0)
		bne.s	loc_6F50
		btst	#2,(a0)
		bne.s	loc_6F42
		move.l	(a1)+,(a6)
		rts
; ---------------------------------------------------------------------------

loc_6F42:
		move.l	(a1)+,d3
		eori.l	#$8000800,d3
		swap	d3
		move.l	d3,(a6)
		rts
; ---------------------------------------------------------------------------

loc_6F50:
		btst	#2,(a0)
		bne.s	loc_6F62
		move.l	(a1)+,d3
		eori.l	#$10001000,d3
		move.l	d3,(a6)
		rts
; ---------------------------------------------------------------------------

loc_6F62:
		move.l	(a1)+,d3
		eori.l	#$18001800,d3
		swap	d3
		move.l	d3,(a6)
		rts
; End of function sub_6F32


; =============== S U B	R O U T	I N E =======================================


sub_6F70:
		or.w	d2,d0
		swap	d0
		btst	#3,(a0)
		bne.s	loc_6FAC
		btst	#2,(a0)
		bne.s	loc_6F8C
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		rts
; ---------------------------------------------------------------------------

loc_6F8C:
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eori.l	#$8000800,d3
		swap	d3
		move.l	d3,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eori.l	#$8000800,d3
		swap	d3
		move.l	d3,(a6)
		rts
; ---------------------------------------------------------------------------

loc_6FAC:
		btst	#2,(a0)
		bne.s	loc_6FD2
		move.l	d5,-(sp)
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d3
		eori.l	#$10001000,d3
		move.l	d3,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		move.l	(sp)+,d5
		rts
; ---------------------------------------------------------------------------

loc_6FD2:
		move.l	d5,-(sp)
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d3
		eori.l	#$18001800,d3
		swap	d3
		move.l	d3,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		move.l	(sp)+,d5
		rts
; End of function sub_6F70


; =============== S U B	R O U T	I N E =======================================


sub_6FF6:
		or.w	d2,d0
		swap	d0
		btst	#3,(a0)
		bne.s	loc_701C
		btst	#2,(a0)
		bne.s	loc_700C
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		rts
; ---------------------------------------------------------------------------

loc_700C:
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eori.l	#$8000800,d3
		swap	d3
		move.l	d3,(a6)
		rts
; ---------------------------------------------------------------------------

loc_701C:
		btst	#2,(a0)
		bne.s	loc_7030
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eori.l	#$10001000,d3
		move.l	d3,(a6)
		rts
; ---------------------------------------------------------------------------

loc_7030:
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eori.l	#$18001800,d3
		swap	d3
		move.l	d3,(a6)
		rts
; End of function sub_6FF6


; =============== S U B	R O U T	I N E =======================================


sub_7040:
		add.w	(a3),d5
		add.w	4(a3),d4
		lea	(v_16x16).w,a1
		move.w	d4,d3
		add.w	d3,d3
		andi.w	#$F00,d3
		lsr.w	#3,d5
		move.w	d5,d0
		lsr.w	#4,d0
		andi.w	#$7F,d0
		add.w	d3,d0
		moveq	#-1,d3
		move.b	(a4,d0.w),d3
		andi.w	#$FF,d3
		lsl.w	#7,d3
		andi.w	#$70,d4
		andi.w	#$E,d5
		add.w	d4,d3
		add.w	d5,d3
		movea.l	d3,a0
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1
		rts
; End of function sub_7040


; =============== S U B	R O U T	I N E =======================================


sub_7084:
		add.w	(a3),d5
; End of function sub_7084


; =============== S U B	R O U T	I N E =======================================


sub_7086:
		tst.w	(Two_player_mode).w
		bne.s	loc_70A6
		add.w	4(a3),d4
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0
		swap	d0
		move.w	d4,d0
		rts
; ---------------------------------------------------------------------------

loc_70A6:
		add.w	4(a3),d4
		andi.w	#$1F0,d4
		andi.w	#$1F0,d5
		lsl.w	#3,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0
		swap	d0
		move.w	d4,d0
		rts
; End of function sub_7086


; =============== S U B	R O U T	I N E =======================================


sub_70C0:
		tst.w	(Two_player_mode).w
		bne.s	loc_70E2
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap	d0
		move.w	d4,d0
		rts
; ---------------------------------------------------------------------------

loc_70E2:
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$1F0,d4
		andi.w	#$1F0,d5
		lsl.w	#3,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap	d0
		move.w	d4,d0
		rts
; End of function sub_70C0


; =============== S U B	R O U T	I N E =======================================


LoadTilesFromStart:

; FUNCTION CHUNK AT 000071A0 SIZE 0000002A BYTES

		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		tst.w	(Two_player_mode).w
		beq.s	loc_711E
		lea	(Camera_X_pos_P2).w,a3
		lea	(v_lvllayout).w,a4
		move.w	#$6000,d2
		bsr.s	LoadTilesFromStart_2p

loc_711E:
		lea	(Camera_RAM).w,a3
		lea	(v_lvllayout).w,a4
		move.w	#$4000,d2
		bsr.s	LoadTilesFromStart2
		lea	(Camera_BG_X_pos).w,a3
		lea	(v_lvllayoutbg).w,a4
		move.w	#$6000,d2
		tst.b	(Current_Zone).w
		beq.w	loc_71A0
; End of function LoadTilesFromStart


; =============== S U B	R O U T	I N E =======================================


LoadTilesFromStart2:
		moveq	#$FFFFFFF0,d4
		moveq	#$F,d6

loc_7144:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	sub_7084
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		move	#$2700,sr
		bsr.w	sub_6D84
		move	#$2300,sr
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_7144
		rts
; End of function LoadTilesFromStart2


; =============== S U B	R O U T	I N E =======================================


LoadTilesFromStart_2p:
		moveq	#$FFFFFFF0,d4
		moveq	#$F,d6

loc_7174:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	sub_70C0
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		move	#$2700,sr
		bsr.w	sub_6D84
		move	#$2300,sr
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_7174
		rts
; End of function LoadTilesFromStart_2p

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR LoadTilesFromStart

loc_71A0:
		moveq	#0,d4
		moveq	#$F,d6

loc_71A4:
		movem.l	d4-d6,-(sp)
		lea	(byte_71CA).l,a0
		move.w	(Camera_BG_Y_pos).w,d0
		add.w	d4,d0
		andi.w	#$F0,d0
		bsr.w	sub_7232
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_71A4
		rts
; END OF FUNCTION CHUNK	FOR LoadTilesFromStart
; ---------------------------------------------------------------------------
byte_71CA:	dc.b   0,  0,  0,  0,  6,  6,  6,  4,  4,  4,  0,  0,  0,  0,  0,  0 ; 0
; ---------------------------------------------------------------------------
		moveq	#$FFFFFFF0,d4
		moveq	#$F,d6

loc_71DE:
		movem.l	d4-d6,-(sp)
		lea	byte_6BCB(pc),a0
		move.w	(Camera_BG_Y_pos).w,d0
		add.w	d4,d0
		andi.w	#$3F0,d0
		bsr.w	sub_7232
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_71DE
		rts
; ---------------------------------------------------------------------------
		moveq	#$FFFFFFF0,d4
		moveq	#$F,d6

loc_7206:
		movem.l	d4-d6,-(sp)
		lea	byte_6AD1(pc),a0
		move.w	(Camera_BG_Y_pos).w,d0
		add.w	d4,d0
		andi.w	#$1F0,d0
		bsr.w	sub_7232
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_7206
		rts
; ---------------------------------------------------------------------------
word_722A:	dc.w $EE08
		dc.w $EE08
		dc.w $EE10
		dc.w $EE18

; =============== S U B	R O U T	I N E =======================================


sub_7232:
		lsr.w	#4,d0
		move.b	(a0,d0.w),d0
		movea.w	word_722A(pc,d0.w),a3
		beq.s	loc_725A
		moveq	#$FFFFFFF0,d5
		movem.l	d4-d5,-(sp)
		bsr.w	sub_7084
		movem.l	(sp)+,d4-d5
		move	#$2700,sr
		bsr.w	sub_6D8C
		move	#$2300,sr
		rts
; ---------------------------------------------------------------------------

loc_725A:
		moveq	#0,d5
		movem.l	d4-d5,-(sp)
		bsr.w	sub_7086
		movem.l	(sp)+,d4-d5
		moveq	#$1F,d6
		bsr.w	sub_6D90
		rts
; End of function sub_7232


; =============== S U B	R O U T	I N E =======================================


MainLevelLoadBlock:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#4,d0
		lea	(LevelArtPointers).l,a2
		lea	(a2,d0.w),a2
		move.l	a2,-(sp)
		addq.l	#4,a2
		movea.l	(a2)+,a0
		tst.b	(Current_Zone).w
		beq.s	MainLevelLoadBlock_Convert16
		bra.s	MainLevelLoadBlock_Convert16
; ---------------------------------------------------------------------------

MainLevelLoadBlock_Skip16Convert:			; leftover from a previous build
		lea	(v_16x16).w,a1
		move.w	#0,d0
		bsr.w	EniDec
		bra.s	loc_72C2
; ---------------------------------------------------------------------------

MainLevelLoadBlock_Convert16:
		lea	(v_16x16).w,a1
		move.w	#$BFF,d2

MainLevelLoadBlock_ConvertLoop:
		move.w	(a0)+,d0
		tst.w	(Two_player_mode).w
		beq.s	MainLevelLoadBlock_Not2p
		move.w	d0,d1
		andi.w	#$F800,d0
		andi.w	#$7FF,d1
		lsr.w	#1,d1
		or.w	d1,d0

MainLevelLoadBlock_Not2p:
		move.w	d0,(a1)+
		dbf	d2,MainLevelLoadBlock_ConvertLoop

loc_72C2:
		cmpi.b	#5,(Current_Zone).w
		bne.s	loc_72F4
		lea	($FFFF9980).w,a1
		lea	(Map16_HTZ).l,a0
		move.w	#$3FF,d2

loc_72D8:
		move.w	(a0)+,d0
		tst.w	(Two_player_mode).w
		beq.s	loc_72EE
		move.w	d0,d1
		andi.w	#$F800,d0
		andi.w	#$7FF,d1
		lsr.w	#1,d1
		or.w	d1,d0

loc_72EE:
		move.w	d0,(a1)+
		dbf	d2,loc_72D8

loc_72F4:
		movea.l	(a2)+,a0
		cmpi.b	#2,(Current_Zone).w
		beq.s	loc_7338
		cmpi.b	#3,(Current_Zone).w
		beq.s	loc_7338
		cmpi.b	#4,(Current_Zone).w
		beq.s	loc_7338
		cmpi.b	#5,(Current_Zone).w
		beq.s	loc_7338
		move.l	a2,-(sp)
		moveq	#0,d1
		moveq	#0,d2
		move.w	(a0)+,d0
		lea	(a0,d0.w),a1
		lea	(v_128x128).l,a2
		lea	(v_128x128_end).w,a3

loc_732C:
		bsr.w	KC_Dec
		tst.w	d0
		bmi.s	loc_732C
		movea.l	(sp)+,a2
		bra.s	loc_7348
; ---------------------------------------------------------------------------

loc_7338:
		lea	(v_128x128).l,a1
		move.w	#$3FFF,d0

loc_7342:
		move.w	(a0)+,(a1)+
		dbf	d0,loc_7342

loc_7348:
		bsr.w	LevelLayoutLoad
		move.w	(a2)+,d0
		move.w	(a2),d0
		andi.w	#$FF,d0
		cmpi.w	#$103,(Current_ZoneAndAct).w
		bne.s	loc_735E
		moveq	#$C,d0

loc_735E:
		cmpi.w	#$501,(Current_ZoneAndAct).w
		beq.s	loc_736E
		cmpi.w	#$502,(Current_ZoneAndAct).w
		bne.s	loc_7370

loc_736E:
		moveq	#$E,d0

loc_7370:
		bsr.w	PalLoad1
		movea.l	(sp)+,a2
		addq.w	#4,a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	locret_7382
		bsr.w	LoadPLC

locret_7382:
		rts
; End of function MainLevelLoadBlock

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load a level layout from RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LevelLayoutLoad:
		lea	(v_lvllayout).w,a3
		move.w	#$3FF,d1
		moveq	#0,d0

loc_738E:
		move.l	d0,(a3)+
		dbf	d1,loc_738E			; fill $8000-$8FFF with 0

		lea	(v_lvllayout).w,a3		; load foreground into RAM
		moveq	#0,d1
		bsr.w	LevelLayoutLoad2
		lea	(v_lvllayoutbg).w,a3		; load background into RAM
		moveq	#2,d1

LevelLayoutLoad2:
		tst.b	(Current_Zone).w
		beq.s	LevelLayoutLoad_GHZ
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0
		add.w	d1,d0
		lea	(Level_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1
		move.b	(a1)+,d2
		move.l	d1,d5
		addq.l	#1,d5
		moveq	#0,d3
		move.w	#$80,d3
		divu.w	d5,d3
		subq.w	#1,d3

loc_73DE:
		movea.l	a3,a0
		move.w	d3,d4

loc_73E2:
		move.l	a1,-(sp)
		move.w	d1,d0

loc_73E6:
		move.b	(a1)+,(a0)+
		dbf	d0,loc_73E6
		movea.l	(sp)+,a1
		dbf	d4,loc_73E2
		lea	(a1,d5.w),a1
		lea	$100(a3),a3
		dbf	d2,loc_73DE
		rts
; End of function LevelLayoutLoad

; ===========================================================================
; dynamically converts the Sonic 1 level layout into Sonic 2 Nick Arcade's,
; read more about it here: https://forums.sonicretro.org/index.php?posts/993641/
LevelLayoutLoad_GHZ:
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0
		add.w	d1,d0
		lea	(Level_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1			; load level width (in tiles)
		move.b	(a1)+,d2			; load level height (in tiles)

loc_7426:
		move.w	d1,d0
		movea.l	a3,a0

loc_742A:
		move.b	(a1)+,d3
		subq.b	#1,d3				; subtract 1 from chunk ID
		bcc.s	loc_7440			; if chunk is not $00, branch
		moveq	#0,d3				; set 'air' chunk to $00
		move.b	d3,(a0)+			; load first chunk
		move.b	d3,(a0)+			; load second chunk
		move.b	d3,$FE(a0)			; load third chunk
		move.b	d3,$FF(a0)			; load fourth chunk
		bra.s	loc_7456
; ===========================================================================

loc_7440:
		lsl.b	#2,d3
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,(a0)+			; load first chunk
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,(a0)+			; load second chunk
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,$FE(a0)			; load third chunk
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,$FF(a0)			; load fourth chunk

loc_7456:
		dbf	d0,loc_742A			; load 1 row
		lea	$200(a3),a3			; do next row
		dbf	d2,loc_7426			; repeat for number of rows
		rts
; End of function LevelLayoutLoad_GHZ

; ---------------------------------------------------------------------------

LevelLayout_Convert:					; leftover level layout	converting function (from raw to the way it's stored in the game)
		lea	($FE0000).l,a1
		lea	($FE0000+$80).l,a2
		lea	(v_startofram).l,a3
		move.w	#$3F,d1

loc_747A:
		bsr.w	sub_750C
		bsr.w	sub_750C
		dbf	d1,loc_747A
		lea	($FE0000).l,a1
		lea	(v_startofram&$FFFFFF).l,a2
		move.w	#$3F,d1

loc_7496:
		move.w	#0,(a2)+
		dbf	d1,loc_7496
		move.w	#$3FBF,d1

loc_74A2:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_74A2
		rts
; ---------------------------------------------------------------------------
		lea	($FE0000).l,a1
		lea	(v_startofram).l,a3
		moveq	#$1F,d0

loc_74B8:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_74B8
		moveq	#0,d7
		lea	($FE0000).l,a1
		move.w	#$FF,d5

loc_74CA:
		lea	(v_startofram).l,a3
		move.w	d7,d6

loc_74D2:
		movem.l	a1-a3,-(sp)
		move.w	#$3F,d0

loc_74DA:
		cmpm.w	(a1)+,(a3)+
		bne.s	loc_74F0
		dbf	d0,loc_74DA
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a1
		dbf	d5,loc_74CA
		bra.s	loc_750A
; ---------------------------------------------------------------------------

loc_74F0:
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a3
		dbf	d6,loc_74D2
		moveq	#$1F,d0

loc_74FE:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_74FE
		addq.l	#1,d7
		dbf	d5,loc_74CA

loc_750A:
		bra.s	loc_750A

; =============== S U B	R O U T	I N E =======================================


sub_750C:
		moveq	#7,d0

loc_750E:
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		dbf	d0,loc_750E
		adda.w	#$80,a1
		adda.w	#$80,a2
		rts
; End of function sub_750C


; =============== S U B	R O U T	I N E =======================================


DynScreenResizeLoad:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	DynResize_Index(pc,d0.w),d0
		jsr	DynResize_Index(pc,d0.w)
		moveq	#2,d1
		move.w	(Camera_Max_Y_pos_target).w,d0
		sub.w	(Camera_Max_Y_pos).w,d0
		beq.s	locret_756A
		bcc.s	loc_756C
		neg.w	d1
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(Camera_Max_Y_pos_target).w,d0
		bls.s	loc_7560
		move.w	d0,(Camera_Max_Y_pos).w
		andi.w	#$FFFE,(Camera_Max_Y_pos).w

loc_7560:
		add.w	d1,(Camera_Max_Y_pos).w
		move.b	#1,(Camera_Max_Y_Pos_Changing).w

locret_756A:
		rts
; ---------------------------------------------------------------------------

loc_756C:
		move.w	(Camera_Y_pos).w,d0
		addi.w	#8,d0
		cmp.w	(Camera_Max_Y_pos).w,d0
		bcs.s	loc_7586
		btst	#1,(v_objspace+obStatus).w
		beq.s	loc_7586
		add.w	d1,d1
		add.w	d1,d1

loc_7586:
		add.w	d1,(Camera_Max_Y_pos).w
		move.b	#1,(Camera_Max_Y_Pos_Changing).w
		rts
; End of function DynScreenResizeLoad

; ---------------------------------------------------------------------------
DynResize_Index:dc.w DynResize_GHZ-DynResize_Index	; 0
		dc.w DynResize_LZ-DynResize_Index	; 1
		dc.w DynResize_CPZ-DynResize_Index	; 2
		dc.w DynResize_EHZ-DynResize_Index	; 3
		dc.w DynResize_HPZ-DynResize_Index	; 4
		dc.w DynResize_HTZ-DynResize_Index	; 5
		dc.w DynResize_S1Ending-DynResize_Index	; 6
; ---------------------------------------------------------------------------

DynResize_GHZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_GHZ_Index(pc,d0.w),d0
		jmp	DynResize_GHZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_GHZ_Index:dc.w DynResize_GHZ1-DynResize_GHZ_Index ; 0
		dc.w DynResize_GHZ2-DynResize_GHZ_Index	; 1
		dc.w DynResize_GHZ3-DynResize_GHZ_Index	; 2
; ---------------------------------------------------------------------------

DynResize_GHZ1:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1780,(Camera_RAM).w
		bcs.s	locret_75CA
		move.w	#$400,(Camera_Max_Y_pos_target).w

locret_75CA:
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ2:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		cmpi.w	#$ED0,(Camera_RAM).w
		bcs.s	locret_75FC
		move.w	#$200,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1600,(Camera_RAM).w
		bcs.s	locret_75FC
		move.w	#$400,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1D60,(Camera_RAM).w
		bcs.s	locret_75FC
		move.w	#$300,(Camera_Max_Y_pos_target).w

locret_75FC:
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_GHZ3_Index(pc,d0.w),d0
		jmp	DynResize_GHZ3_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_GHZ3_Index:dc.w DynResize_GHZ3_Main-DynResize_GHZ3_Index ; 0
		dc.w DynResize_GHZ3_Boss-DynResize_GHZ3_Index ; 1
		dc.w DynResize_GHZ3_End-DynResize_GHZ3_Index ; 2
; ---------------------------------------------------------------------------

DynResize_GHZ3_Main:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		cmpi.w	#$380,(Camera_RAM).w
		bcs.s	locret_7658
		move.w	#$310,(Camera_Max_Y_pos_target).w
		cmpi.w	#$960,(Camera_RAM).w
		bcs.s	locret_7658
		cmpi.w	#$280,(Camera_Y_pos).w
		bcs.s	loc_765A
		move.w	#$400,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1380,(Camera_RAM).w
		bcc.s	loc_7650
		move.w	#$4C0,(Camera_Max_Y_pos_target).w
		move.w	#$4C0,(Camera_Max_Y_pos).w

loc_7650:
		cmpi.w	#$1700,(Camera_RAM).w
		bcc.s	loc_765A

locret_7658:
		rts
; ---------------------------------------------------------------------------

loc_765A:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ3_Boss:
		cmpi.w	#$960,(Camera_RAM).w
		bcc.s	loc_7672
		subq.b	#2,(Dynamic_Resize_Routine).w

loc_7672:
		cmpi.w	#$2960,(Camera_RAM).w
		bcs.s	locret_76AA
		bsr.w	FindFreeObj
		bne.s	loc_7692
		_move.b	#$3D,obID(a1)
		move.w	#$2A60,obX(a1)
		move.w	#$280,obY(a1)

loc_7692:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound
		move.b	#1,(f_lockscreen).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#$11,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_76AA:
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ3_End:
		move.w	(Camera_RAM).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------

DynResize_LZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_LZ_Index(pc,d0.w),d0
		jmp	DynResize_LZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_LZ_Index:dc.w	DynResize_LZ_Null-DynResize_LZ_Index ; 0
		dc.w DynResize_LZ_Null-DynResize_LZ_Index ; 1
		dc.w DynResize_LZ3-DynResize_LZ_Index	; 2
		dc.w DynResize_LZ4-DynResize_LZ_Index	; 3
; ---------------------------------------------------------------------------

DynResize_LZ_Null:
		rts
; ---------------------------------------------------------------------------

DynResize_LZ3:
		tst.b	(f_switch+$F).w
		beq.s	loc_76EA
		lea	($FFFF8206).w,a1
		cmpi.b	#7,(a1)
		beq.s	loc_76EA
		move.b	#7,(a1)
		move.w	#sfx_Rumbling,d0
		bsr.w	PlaySound_Special

loc_76EA:
		tst.b	(Dynamic_Resize_Routine).w
		bne.s	locret_7726
		cmpi.w	#$1CA0,(Camera_RAM).w
		bcs.s	locret_7724
		cmpi.w	#$600,(Camera_Y_pos).w
		bcc.s	locret_7724
		bsr.w	FindFreeObj
		bne.s	loc_770C
		_move.b	#$77,obID(a1)

loc_770C:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound
		move.b	#1,(f_lockscreen).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#$11,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_7724:
		rts
; ---------------------------------------------------------------------------

locret_7726:
		rts
; ---------------------------------------------------------------------------

DynResize_LZ4:
		cmpi.w	#$D00,(Camera_RAM).w
		bcs.s	locret_774E
		cmpi.w	#$18,(v_objspace+obY).w
		bcc.s	locret_774E
		clr.b	(v_lastlamp).w
		move.w	#1,(Level_Inactive_flag).w
		move.w	#$502,(Current_ZoneAndAct).w
		move.b	#1,(f_playerctrl).w

locret_774E:
		rts
; ---------------------------------------------------------------------------

DynResize_CPZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_CPZ_Index(pc,d0.w),d0
		jmp	DynResize_CPZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_CPZ_Index:dc.w DynResize_CPZ1-DynResize_CPZ_Index
		dc.w DynResize_CPZ2-DynResize_CPZ_Index
		dc.w DynResize_CPZ3-DynResize_CPZ_Index
; ---------------------------------------------------------------------------

DynResize_CPZ1:
		rts
; ---------------------------------------------------------------------------

S1DynResize_MZ1:					; leftover from Sonic 1
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_7776(pc,d0.w),d0
		jmp	off_7776(pc,d0.w)
; ---------------------------------------------------------------------------
off_7776:	dc.w loc_777E-off_7776
		dc.w loc_77AE-off_7776
		dc.w loc_77F2-off_7776
		dc.w loc_781C-off_7776
; ---------------------------------------------------------------------------

loc_777E:
		move.w	#$1D0,(Camera_Max_Y_pos_target).w
		cmpi.w	#$700,(Camera_RAM).w
		bcs.s	locret_77AC
		move.w	#$220,(Camera_Max_Y_pos_target).w
		cmpi.w	#$D00,(Camera_RAM).w
		bcs.s	locret_77AC
		move.w	#$340,(Camera_Max_Y_pos_target).w
		cmpi.w	#$340,(Camera_Y_pos).w
		bcs.s	locret_77AC
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_77AC:
		rts
; ---------------------------------------------------------------------------

loc_77AE:
		cmpi.w	#$340,(Camera_Y_pos).w
		bcc.s	loc_77BC
		subq.b	#2,(Dynamic_Resize_Routine).w
		rts
; ---------------------------------------------------------------------------

loc_77BC:
		move.w	#0,(Camera_Min_Y_pos).w
		cmpi.w	#$E00,(Camera_RAM).w
		bcc.s	locret_77F0
		move.w	#$340,(Camera_Min_Y_pos).w
		move.w	#$340,(Camera_Max_Y_pos_target).w
		cmpi.w	#$A90,(Camera_RAM).w
		bcc.s	locret_77F0
		move.w	#$500,(Camera_Max_Y_pos_target).w
		cmpi.w	#$370,(Camera_Y_pos).w
		bcs.s	locret_77F0
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_77F0:
		rts
; ---------------------------------------------------------------------------

loc_77F2:
		cmpi.w	#$370,(Camera_Y_pos).w
		bcc.s	loc_7800
		subq.b	#2,(Dynamic_Resize_Routine).w
		rts
; ---------------------------------------------------------------------------

loc_7800:
		cmpi.w	#$500,(Camera_Y_pos).w
		bcs.s	locret_781A
		cmpi.w	#$B80,(Camera_RAM).w
		bcs.s	locret_781A
		move.w	#$500,(Camera_Min_Y_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_781A:
		rts
; ---------------------------------------------------------------------------

loc_781C:
		cmpi.w	#$B80,(Camera_RAM).w
		bcc.s	loc_7832
		cmpi.w	#$340,(Camera_Min_Y_pos).w
		beq.s	locret_786A
		subq.w	#2,(Camera_Min_Y_pos).w
		rts
; ---------------------------------------------------------------------------

loc_7832:
		cmpi.w	#$500,(Camera_Min_Y_pos).w
		beq.s	loc_7848
		cmpi.w	#$500,(Camera_Y_pos).w
		bcs.s	locret_786A
		move.w	#$500,(Camera_Min_Y_pos).w

loc_7848:
		cmpi.w	#$E70,(Camera_RAM).w
		bcs.s	locret_786A
		move.w	#0,(Camera_Min_Y_pos).w
		move.w	#$500,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1430,(Camera_RAM).w
		bcs.s	locret_786A
		move.w	#$210,(Camera_Max_Y_pos_target).w

locret_786A:
		rts
; ---------------------------------------------------------------------------

DynResize_CPZ2:
		rts
; ---------------------------------------------------------------------------

S1DynResize_MZ2:					; leftover from Sonic 1
		move.w	#$520,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1700,(Camera_RAM).w
		bcs.s	locret_7882
		move.w	#$200,(Camera_Max_Y_pos_target).w

locret_7882:
		rts
; ===========================================================================

DynResize_CPZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_7892(pc,d0.w),d0
		jmp	off_7892(pc,d0.w)
; ===========================================================================
off_7892:	dc.w DynResize_CPZ3_BossCheck-off_7892
		dc.w DynResize_CPZ3_Null-off_7892
; ===========================================================================

DynResize_CPZ3_BossCheck:
		cmpi.w	#$480,(Camera_RAM).w
		blt.s	DynResize_CPZ3_Null
		cmpi.w	#$740,(Camera_RAM).w
		bgt.s	DynResize_CPZ3_Null
		move.w	(Camera_Max_Y_pos).w,d0
		cmp.w	(Camera_Y_pos).w,d0
		bne.s	DynResize_CPZ3_Null
		move.w	#$740,(Camera_Max_X_pos).w
		move.w	#$480,(Camera_Min_X_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		bsr.w	FindFreeObj
		bne.s	DynResize_CPZ3_Null
		_move.b	#$55,obID(a1)			; load Obj55 (EHZ boss, likely CPZ boss at one point)
		move.w	#$680,obX(a1)
		move.w	#$540,obY(a1)
		moveq	#$11,d0
		bra.w	LoadPLC
; ===========================================================================

DynResize_CPZ3_Null:
		rts

; ---------------------------------------------------------------------------

DynResize_EHZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	off_78F0(pc,d0.w),d0
		jmp	off_78F0(pc,d0.w)
; ---------------------------------------------------------------------------
off_78F0:	dc.w DynResize_EHZ1-off_78F0
		dc.w DynResize_EHZ2-off_78F0
		dc.w locret_7980-off_78F0
; ---------------------------------------------------------------------------

DynResize_EHZ1:
		rts
; ---------------------------------------------------------------------------

DynResize_EHZ2:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_EHZ2_Index(pc,d0.w),d0
		jmp	DynResize_EHZ2_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_EHZ2_Index:dc.w DynResize_EHZ2_01-DynResize_EHZ2_Index
		dc.w DynResize_EHZ2_02-DynResize_EHZ2_Index
		dc.w DynResize_EHZ2_03-DynResize_EHZ2_Index
; ---------------------------------------------------------------------------

DynResize_EHZ2_01:
		cmpi.w	#$26E0,(Camera_RAM).w
		bcs.s	locret_795A
		move.w	(Camera_RAM).w,(Camera_Min_X_pos).w
		move.w	#$390,(Camera_Max_Y_pos_target).w
		move.w	#$390,(Camera_Max_Y_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		bsr.w	FindFreeObj
		bne.s	loc_7946
		move.b	#$55,obID(a1)
		move.b	#$81,obSubtype(a1)
		move.w	#$29D0,obX(a1)
		move.w	#$426,obY(a1)

loc_7946:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound
		move.b	#1,(f_lockscreen).w
		moveq	#$11,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_795A:
		rts
; ---------------------------------------------------------------------------

DynResize_EHZ2_02:
		cmpi.w	#$2880,(Camera_RAM).w
		bcs.s	locret_796E
		move.w	#$2880,(Camera_Min_X_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_796E:
		rts
; ---------------------------------------------------------------------------

DynResize_EHZ2_03:
		tst.b	(Boss_defeated_flag).w
		beq.s	DynResize_EHZ3
		move.b	#GameModeID_SegaScreen,(v_gamemode).w

DynResize_EHZ3:
		rts
; ---------------------------------------------------------------------------
		rts
; ---------------------------------------------------------------------------

locret_7980:
		rts
; ---------------------------------------------------------------------------

S1DynResize_SLZ3:					; leftover from Sonic 1
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_7990(pc,d0.w),d0
		jmp	off_7990(pc,d0.w)
; ---------------------------------------------------------------------------
off_7990:	dc.w loc_7996-off_7990
		dc.w loc_79AA-off_7990
		dc.w loc_79D6-off_7990
; ---------------------------------------------------------------------------

loc_7996:
		cmpi.w	#$1E70,(Camera_RAM).w
		bcs.s	locret_79A8
		move.w	#$210,(Camera_Max_Y_pos_target).w
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_79A8:
		rts
; ---------------------------------------------------------------------------

loc_79AA:
		cmpi.w	#$2000,(Camera_RAM).w
		bcs.s	locret_79D4
		bsr.w	FindFreeObj
		bne.s	loc_79BC
		move.b	#$7A,(a1)

loc_79BC:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound
		move.b	#1,(f_lockscreen).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#$11,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_79D4:
		rts
; ---------------------------------------------------------------------------

loc_79D6:
		move.w	(Camera_RAM).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------
		rts
; ---------------------------------------------------------------------------

DynResize_HPZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_HPZ_Index(pc,d0.w),d0
		jmp	DynResize_HPZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HPZ_Index:dc.w DynResize_HPZ1-DynResize_HPZ_Index
		dc.w DynResize_HPZ2-DynResize_HPZ_Index
		dc.w DynResize_HPZ3-DynResize_HPZ_Index
; ---------------------------------------------------------------------------

DynResize_HPZ1:
		rts
; ---------------------------------------------------------------------------

DynResize_HPZ2:
		move.w	#$520,(Camera_Max_Y_pos_target).w
		cmpi.w	#$25A0,(Camera_RAM).w
		bcs.s	locret_7A1A
		move.w	#$420,(Camera_Max_Y_pos_target).w
		cmpi.w	#$4D0,(v_objspace+obY).w
		bcs.s	locret_7A1A
		move.w	#$520,(Camera_Max_Y_pos_target).w

locret_7A1A:
		rts
; ---------------------------------------------------------------------------

DynResize_HPZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_HPZ3_Index(pc,d0.w),d0
		jmp	DynResize_HPZ3_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HPZ3_Index:dc.w loc_7A30-DynResize_HPZ3_Index
		dc.w loc_7A48-DynResize_HPZ3_Index
		dc.w loc_7A7A-DynResize_HPZ3_Index
; ---------------------------------------------------------------------------

loc_7A30:
		cmpi.w	#$2AC0,(Camera_RAM).w
		bcs.s	locret_7A46
		bsr.w	FindFreeObj
		bne.s	locret_7A46
		move.b	#$76,(a1)
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_7A46:
		rts
; ---------------------------------------------------------------------------

loc_7A48:
		cmpi.w	#$2C00,(Camera_RAM).w
		bcs.s	locret_7A78
		move.w	#$4CC,(Camera_Max_Y_pos_target).w
		bsr.w	FindFreeObj
		bne.s	loc_7A64
		move.b	#$75,(a1)
		addq.b	#2,(Dynamic_Resize_Routine).w

loc_7A64:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound
		move.b	#1,(f_lockscreen).w
		moveq	#$11,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_7A78:
		rts
; ---------------------------------------------------------------------------

loc_7A7A:
		move.w	(Camera_RAM).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------

DynResize_HTZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_HTZ_Index(pc,d0.w),d0
		jmp	DynResize_HTZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HTZ_Index:dc.w DynResize_HTZ1-DynResize_HTZ_Index
		dc.w DynResize_HTZ2-DynResize_HTZ_Index
		dc.w DynResize_HTZ3-DynResize_HTZ_Index
; ---------------------------------------------------------------------------

DynResize_HTZ1:
		move.w	#$720,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1880,(Camera_RAM).w
		bcs.s	locret_7ABA
		move.w	#$620,(Camera_Max_Y_pos_target).w
		cmpi.w	#$2000,(Camera_RAM).w
		bcs.s	locret_7ABA
		move.w	#$2A0,(Camera_Max_Y_pos_target).w

locret_7ABA:
		rts
; ---------------------------------------------------------------------------

DynResize_HTZ2:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_HTZ2_Index(pc,d0.w),d0
		jmp	DynResize_HTZ2_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HTZ2_Index:dc.w loc_7AD2-DynResize_HTZ2_Index
		dc.w loc_7AF4-DynResize_HTZ2_Index
		dc.w loc_7B12-DynResize_HTZ2_Index
		dc.w loc_7B30-DynResize_HTZ2_Index
; ---------------------------------------------------------------------------

loc_7AD2:
		move.w	#$800,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1800,(Camera_RAM).w
		bcs.s	locret_7AF2
		move.w	#$510,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1E00,(Camera_RAM).w
		bcs.s	locret_7AF2
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_7AF2:
		rts
; ---------------------------------------------------------------------------

loc_7AF4:
		cmpi.w	#$1EB0,(Camera_RAM).w
		bcs.s	locret_7B10
		bsr.w	FindFreeObj
		bne.s	locret_7B10
		move.b	#$83,(a1)
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#$1E,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_7B10:
		rts
; ---------------------------------------------------------------------------

loc_7B12:
		cmpi.w	#$1F60,(Camera_RAM).w
		bcs.s	loc_7B2E
		bsr.w	FindFreeObj
		bne.s	loc_7B28
		move.b	#$82,(a1)
		addq.b	#2,(Dynamic_Resize_Routine).w

loc_7B28:
		move.b	#1,(f_lockscreen).w

loc_7B2E:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

loc_7B30:
		cmpi.w	#$2050,(Camera_RAM).w
		bcs.s	loc_7B3A
		rts
; ---------------------------------------------------------------------------

loc_7B3A:
		move.w	(Camera_RAM).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------

DynResize_HTZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_HTZ3_Index(pc,d0.w),d0
		jmp	DynResize_HTZ3_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HTZ3_Index:dc.w loc_7B5A-DynResize_HTZ3_Index
		dc.w loc_7B6E-DynResize_HTZ3_Index
		dc.w loc_7B8C-DynResize_HTZ3_Index
		dc.w locret_7B9A-DynResize_HTZ3_Index
		dc.w loc_7B9C-DynResize_HTZ3_Index
; ---------------------------------------------------------------------------

loc_7B5A:
		cmpi.w	#$2148,(Camera_RAM).w
		bcs.s	loc_7B6C
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#$1F,d0
		bsr.w	LoadPLC

loc_7B6C:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

loc_7B6E:
		cmpi.w	#$2300,(Camera_RAM).w
		bcs.s	loc_7B8A
		bsr.w	FindFreeObj
		bne.s	loc_7B8A
		move.b	#$85,(a1)
		addq.b	#2,(Dynamic_Resize_Routine).w
		move.b	#1,(f_lockscreen).w

loc_7B8A:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

loc_7B8C:
		cmpi.w	#$2450,(Camera_RAM).w
		bcs.s	loc_7B98
		addq.b	#2,(Dynamic_Resize_Routine).w

loc_7B98:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

locret_7B9A:
		rts
; ---------------------------------------------------------------------------

loc_7B9C:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

DynResize_S1Ending:
		rts
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 11 - Bridge
;----------------------------------------------------

Obj11:
		btst	#6,obRender(a0)
		bne.w	loc_7BB8
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj11_Index(pc,d0.w),d1
		jmp	Obj11_Index(pc,d1.w)
; ---------------------------------------------------------------------------

loc_7BB8:
		moveq	#3,d0
		bra.w	DisplaySprite3
; ---------------------------------------------------------------------------
Obj11_Index:	dc.w loc_7BC6-Obj11_Index
		dc.w loc_7CC8-Obj11_Index
		dc.w loc_7D5A-Obj11_Index
		dc.w loc_7D5E-Obj11_Index
; ---------------------------------------------------------------------------

loc_7BC6:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj11_GHZ,obMap(a0)
		move.w	#$44C6,obGfx(a0)
		move.b	#3,obPriority(a0)
		cmpi.b	#3,(Current_Zone).w
		bne.s	loc_7BFA
		move.l	#Map_obj11,obMap(a0)
		move.w	#$43C6,obGfx(a0)
		move.b	#3,obPriority(a0)

loc_7BFA:
		cmpi.b	#4,(Current_Zone).w
		bne.s	loc_7C14
		addq.b	#4,obRoutine(a0)
		move.l	#Map_obj11_HPZ,obMap(a0)
		move.w	#$6300,obGfx(a0)

loc_7C14:
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$80,obActWid(a0)
		move.w	obY(a0),d2
		move.w	d2,$3C(a0)
		move.w	obX(a0),d3
		lea	obSubtype(a0),a2
		moveq	#0,d1
		move.b	(a2),d1
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3
		swap	d1
		move.w	#8,d1
		bsr.s	sub_7C76
		move.w	obSubtype(a1),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)
		move.l	a1,$30(a0)
		swap	d1
		subq.w	#8,d1
		bls.s	loc_7C74
		move.w	d1,d4
		bsr.s	sub_7C76
		move.l	a1,$34(a0)
		move.w	d4,d0
		add.w	d0,d0
		add.w	d4,d0
		move.w	$10(a1,d0.w),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)

loc_7C74:
		bra.s	loc_7CC8

; =============== S U B	R O U T	I N E =======================================


sub_7C76:
		bsr.w	FindNextFreeObj
		bne.s	locret_7CC6
		_move.b	obID(a0),obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#6,obRender(a1)
		move.b	#$40,$E(a1)
		move.b	d1,$F(a1)
		subq.b	#1,d1
		lea	$10(a1),a2

loc_7CB6:
		move.w	d3,(a2)+
		move.w	d2,(a2)+
		move.w	#0,(a2)+
		addi.w	#$10,d3
		dbf	d1,loc_7CB6

locret_7CC6:
		rts
; End of function sub_7C76

; ---------------------------------------------------------------------------

loc_7CC8:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		bne.s	loc_7CDE
		tst.b	$3E(a0)
		beq.s	loc_7D0A
		subq.b	#4,$3E(a0)
		bra.s	loc_7D06
; ---------------------------------------------------------------------------

loc_7CDE:
		andi.b	#$10,d0
		beq.s	loc_7CFA
		move.b	$3F(a0),d0
		sub.b	$3B(a0),d0
		beq.s	loc_7CFA
		bcc.s	loc_7CF6
		addq.b	#1,$3F(a0)
		bra.s	loc_7CFA
; ---------------------------------------------------------------------------

loc_7CF6:
		subq.b	#1,$3F(a0)

loc_7CFA:
		cmpi.b	#$40,$3E(a0)
		beq.s	loc_7D06
		addq.b	#4,$3E(a0)

loc_7D06:
		bsr.w	sub_7F36

loc_7D0A:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		moveq	#8,d3
		move.w	obX(a0),d4
		bsr.w	sub_7DC0

loc_7D22:
		tst.w	(Two_player_mode).w
		beq.s	loc_7D2A
		rts
; ---------------------------------------------------------------------------

loc_7D2A:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_7D3E
		rts
; ---------------------------------------------------------------------------

loc_7D3E:
		movea.l	$30(a0),a1
		bsr.w	DeleteObject2
		cmpi.b	#8,obSubtype(a0)
		bls.s	loc_7D56
		movea.l	$34(a0),a1
		bsr.w	DeleteObject2

loc_7D56:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------

loc_7D5A:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_7D5E:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		bne.s	loc_7D74
		tst.b	$3E(a0)
		beq.s	loc_7DA0
		subq.b	#4,$3E(a0)
		bra.s	loc_7D9C
; ---------------------------------------------------------------------------

loc_7D74:
		andi.b	#$10,d0
		beq.s	loc_7D90
		move.b	$3F(a0),d0
		sub.b	$3B(a0),d0
		beq.s	loc_7D90
		bcc.s	loc_7D8C
		addq.b	#1,$3F(a0)
		bra.s	loc_7D90
; ---------------------------------------------------------------------------

loc_7D8C:
		subq.b	#1,$3F(a0)

loc_7D90:
		cmpi.b	#$40,$3E(a0)
		beq.s	loc_7D9C
		addq.b	#4,$3E(a0)

loc_7D9C:
		bsr.w	sub_7F36

loc_7DA0:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		moveq	#8,d3
		move.w	obX(a0),d4
		bsr.w	sub_7DC0
		bsr.w	sub_7E60
		bra.w	loc_7D22

; =============== S U B	R O U T	I N E =======================================


sub_7DC0:
		lea	(v_objspace+$40).w,a1
		moveq	#4,d6
		moveq	#$3B,d5
		movem.l	d1-d4,-(sp)
		bsr.s	sub_7DDA
		movem.l	(sp)+,d1-d4
		lea	(v_objspace).w,a1
		subq.b	#1,d6
		moveq	#$3F,d5
; End of function sub_7DC0


; =============== S U B	R O U T	I N E =======================================


sub_7DDA:
		btst	d6,obStatus(a0)
		beq.s	loc_7E3E
		btst	#1,obStatus(a1)
		bne.s	loc_7DFA
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_7DFA
		cmp.w	d2,d0
		bcs.s	loc_7E08

loc_7DFA:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_7E08:
		lsr.w	#4,d0
		move.b	d0,(a0,d5.w)
		movea.l	$30(a0),a2
		cmpi.w	#8,d0
		bcs.s	loc_7E20
		movea.l	$34(a0),a2
		subi.w	#8,d0

loc_7E20:
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	$12(a2,d0.w),d0
		subq.w	#8,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_7E3E:
		move.w	d1,-(sp)
		bsr.w	sub_F880
		move.w	(sp)+,d1
		btst	d6,obStatus(a0)
		beq.s	locret_7E5E
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#4,d0
		move.b	d0,(a0,d5.w)

locret_7E5E:
		rts
; End of function sub_7DDA


; =============== S U B	R O U T	I N E =======================================


sub_7E60:
		moveq	#0,d0
		tst.w	(v_objspace+obVelX).w
		bne.s	loc_7E72
		move.b	($FFFFFE0F).w,d0
		andi.w	#$1C,d0
		lsr.w	#1,d0

loc_7E72:
		moveq	#0,d2
		move.b	byte_7E9F(pc,d0.w),d2
		swap	d2
		move.b	byte_7E9E(pc,d0.w),d2
		moveq	#0,d0
		tst.w	(v_objspace+$50).w
		bne.s	loc_7E90
		move.b	($FFFFFE0F).w,d0
		andi.w	#$1C,d0
		lsr.w	#1,d0

loc_7E90:
		moveq	#0,d6
		move.b	byte_7E9F(pc,d0.w),d6
		swap	d6
		move.b	byte_7E9E(pc,d0.w),d6
		bra.s	loc_7EAE
; ---------------------------------------------------------------------------
byte_7E9E:	dc.b 1
byte_7E9F:	dc.b   2,  1,  2,  1,  2,  1,  2,  0,  1,  0,  0,  0,  0,  0,  1 ; 0
; ---------------------------------------------------------------------------

loc_7EAE:
		moveq	#$FFFFFFFE,d3
		moveq	#$FFFFFFFE,d4
		move.b	obStatus(a0),d0
		andi.b	#8,d0
		beq.s	loc_7EC0
		move.b	$3F(a0),d3

loc_7EC0:
		move.b	obStatus(a0),d0
		andi.b	#$10,d0
		beq.s	loc_7ECE
		move.b	$3B(a0),d4

loc_7ECE:
		movea.l	$30(a0),a1
		lea	$45(a1),a2
		lea	$15(a1),a1
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		subq.b	#1,d1
		moveq	#0,d5

loc_7EE4:
		moveq	#0,d0
		subq.w	#1,d3
		cmp.b	d3,d5
		bne.s	loc_7EEE
		move.w	d2,d0

loc_7EEE:
		addq.w	#2,d3
		cmp.b	d3,d5
		bne.s	loc_7EF6
		move.w	d2,d0

loc_7EF6:
		subq.w	#1,d3
		subq.w	#1,d4
		cmp.b	d4,d5
		bne.s	loc_7F00
		move.w	d6,d0

loc_7F00:
		addq.w	#2,d4
		cmp.b	d4,d5
		bne.s	loc_7F08
		move.w	d6,d0

loc_7F08:
		subq.w	#1,d4
		cmp.b	d3,d5
		bne.s	loc_7F14
		swap	d2
		move.w	d2,d0
		swap	d2

loc_7F14:
		cmp.b	d4,d5
		bne.s	loc_7F1E
		swap	d6
		move.w	d6,d0
		swap	d6

loc_7F1E:
		move.b	d0,(a1)
		addq.w	#1,d5
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	loc_7F30
		movea.l	$34(a0),a1
		lea	$15(a1),a1

loc_7F30:
		dbf	d1,loc_7EE4
		rts
; End of function sub_7E60


; =============== S U B	R O U T	I N E =======================================


sub_7F36:
		move.b	$3E(a0),d0
		bsr.w	CalcSine
		move.w	d0,d4
		lea	(Obj11_BendData2).l,a4
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsl.w	#4,d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		move.w	d3,d2
		add.w	d0,d3
		moveq	#0,d5
		lea	(Obj11_BendData-$80).l,a5
		move.b	(a5,d3.w),d5

loc_7F64:
		andi.w	#$F,d3
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		movea.l	$30(a0),a1
		lea	$42(a1),a2
		lea	obVelY(a1),a1

loc_7F7A:
		moveq	#0,d0
		move.b	(a3)+,d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a0),d0
		move.w	d0,(a1)
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	loc_7F9A
		movea.l	$34(a0),a1
		lea	obVelY(a1),a1

loc_7F9A:
		dbf	d2,loc_7F7A
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		addq.b	#1,d3
		sub.b	d0,d3
		neg.b	d3
		bmi.s	locret_7FE4
		move.w	d3,d2
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		adda.w	d2,a3
		subq.w	#1,d2
		bcs.s	locret_7FE4

loc_7FC0:
		moveq	#0,d0
		move.b	-(a3),d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a0),d0
		move.w	d0,(a1)
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	loc_7FE0
		movea.l	$34(a0),a1
		lea	obVelY(a1),a1

loc_7FE0:
		dbf	d2,loc_7FC0

locret_7FE4:
		rts
; End of function sub_7F36

; ---------------------------------------------------------------------------
Obj11_BendData:	dc.b   2,  4,  6,  8,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0 ; 0
		dc.b   2,  4,  6,  8, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0 ; 16
		dc.b   2,  4,  6,  8, $A, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0 ; 32
		dc.b   2,  4,  6,  8, $A, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0 ; 48
		dc.b   2,  4,  6,  8, $A, $C, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0 ; 64
		dc.b   2,  4,  6,  8, $A, $C, $E, $C, $A,  8,  6,  4,  2,  0,  0,  0 ; 80
		dc.b   2,  4,  6,  8, $A, $C, $E, $E, $C, $A,  8,  6,  4,  2,  0,  0 ; 96
		dc.b   2,  4,  6,  8, $A, $C, $E,$10, $E, $C, $A,  8,  6,  4,  2,  0 ; 112
		dc.b   2,  4,  6,  8, $A, $C, $E,$10,$10, $E, $C, $A,  8,  6,  4,  2 ; 128
Obj11_BendData2:dc.b $FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 0
		dc.b $B5,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 16
		dc.b $7E,$DB,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 32
		dc.b $61,$B5,$EC,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 48
		dc.b $4A,$93,$CD,$F3,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 64
		dc.b $3E,$7E,$B0,$DB,$F6,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 80
		dc.b $38,$6D,$9D,$C5,$E4,$F8,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0 ; 96
		dc.b $31,$61,$8E,$B5,$D4,$EC,$FB,$FF,  0,  0,  0,  0,  0,  0,  0,  0 ; 112
		dc.b $2B,$56,$7E,$A2,$C1,$DB,$EE,$FB,$FF,  0,  0,  0,  0,  0,  0,  0 ; 128
		dc.b $25,$4A,$73,$93,$B0,$CD,$E1,$F3,$FC,$FF,  0,  0,  0,  0,  0,  0 ; 144
		dc.b $1F,$44,$67,$88,$A7,$BD,$D4,$E7,$F4,$FD,$FF,  0,  0,  0,  0,  0 ; 160
		dc.b $1F,$3E,$5C,$7E,$98,$B0,$C9,$DB,$EA,$F6,$FD,$FF,  0,  0,  0,  0 ; 176
		dc.b $19,$38,$56,$73,$8E,$A7,$BD,$D1,$E1,$EE,$F8,$FE,$FF,  0,  0,  0 ; 192
		dc.b $19,$38,$50,$6D,$83,$9D,$B0,$C5,$D8,$E4,$F1,$F8,$FE,$FF,  0,  0 ; 208
		dc.b $19,$31,$4A,$67,$7E,$93,$A7,$BD,$CD,$DB,$E7,$F3,$F9,$FE,$FF,  0 ; 224
		dc.b $19,$31,$4A,$61,$78,$8E,$A2,$B5,$C5,$D4,$E1,$EC,$F4,$FB,$FE,$FF ; 240
; ---------------------------------------------------------------------------
; Sprite mappings - GHZ bridge
; ---------------------------------------------------------------------------
Map_obj11_GHZ:	binclude	"mappings/sprite/obj11_GHZ.bin"
; ---------------------------------------------------------------------------
; Sprite mappings - HPZ bridge
; ---------------------------------------------------------------------------
Map_obj11_HPZ:	binclude	"mappings/sprite/obj11_HPZ.bin"
; ---------------------------------------------------------------------------
; Sprite mappings - EHZ bridge
; ---------------------------------------------------------------------------
Map_obj11:	binclude	"mappings/sprite/obj11.bin"

; ===========================================================================
		nop
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 15 - swinging platforms
;----------------------------------------------------------------------------

Obj15:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj15_Index(pc,d0.w),d1
		jmp	Obj15_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj15_Index:	dc.w loc_821E-Obj15_Index
		dc.w loc_83AA-Obj15_Index
		dc.w loc_8526-Obj15_Index
		dc.w loc_8526-Obj15_Index
		dc.w loc_852A-Obj15_Index
		dc.w loc_83CA-Obj15_Index
; ---------------------------------------------------------------------------

loc_821E:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj15,obMap(a0)
		move.w	#$44D0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#8,obHeight(a0)
		move.w	obY(a0),$38(a0)
		move.w	obX(a0),$3A(a0)
		cmpi.b	#3,(Current_Zone).w
		bne.s	loc_8284
		move.l	#Map_Obj15_EHZ,obMap(a0)
		move.w	#$43DC,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#$20,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#$99,obColType(a0)

loc_8284:
		cmpi.b	#2,(Current_Zone).w
		bne.s	loc_82BE
		move.l	#Map_Obj15_CPZ,obMap(a0)
		move.w	#$2418,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#$20,obActWid(a0)
		move.b	#$10,obHeight(a0)
		lea	obSubtype(a0),a2
		move.b	(a2),d0
		lsl.w	#4,d0
		move.b	d0,$3C(a0)
		move.b	#0,(a2)+
		bra.w	loc_8388
; ---------------------------------------------------------------------------

loc_82BE:
		_move.b	obID(a0),d4
		moveq	#0,d1
		lea	obSubtype(a0),a2
		move.b	(a2),d1
		move.w	d1,-(sp)
		andi.w	#$F,d1
		move.b	#0,(a2)+
		move.w	d1,d3
		lsl.w	#4,d3
		addi.b	#8,d3
		move.b	d3,$3C(a0)
		subi.b	#8,d3
		tst.b	obFrame(a0)
		beq.s	loc_82F0
		addi.b	#8,d3
		subq.w	#1,d1

loc_82F0:
		bsr.w	FindNextFreeObj
		bne.s	loc_835C
		addq.b	#1,obSubtype(a0)
		move.w	a1,d5
		subi.w	#v_objspace,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#8,obRoutine(a1)
		_move.b	d4,obID(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		bclr	#6,2(a1)
		move.b	#4,obRender(a1)
		move.b	#4,obPriority(a1)
		move.b	#8,obActWid(a1)
		move.b	#1,obFrame(a1)
		move.b	d3,$3C(a1)
		subi.b	#$10,d3
		bcc.s	loc_8358
		move.b	#2,obFrame(a1)
		move.b	#3,obPriority(a1)
		bset	#6,2(a1)

loc_8358:
		dbf	d1,loc_82F0

loc_835C:
		move.w	(sp)+,d1
		btst	#4,d1
		beq.s	loc_8388
		move.l	#Map_Obj48,obMap(a0)
		move.w	#$43AA,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#1,obFrame(a0)
		move.b	#2,obPriority(a0)
		move.b	#$81,obColType(a0)

loc_8388:
		move.w	a0,d5
		subi.w	#v_objspace,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.w	#$4080,obAngle(a0)
		move.w	#$FE00,$3E(a0)
		cmpi.b	#5,(Current_Zone).w
		beq.s	loc_83CA

loc_83AA:
		move.w	obX(a0),-(sp)
		bsr.w	sub_83D2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		move.w	(sp)+,d4
		bsr.w	sub_F82E
		bra.w	loc_84EE
; ---------------------------------------------------------------------------

loc_83CA:
		bsr.w	sub_83D2
		bra.w	loc_84EE

; =============== S U B	R O U T	I N E =======================================


sub_83D2:
		move.b	($FFFFFE78).w,d0
		move.w	#$80,d1
		btst	#0,obStatus(a0)
		beq.s	loc_83E6
		neg.w	d0
		add.w	d1,d0

loc_83E6:
		bra.w	loc_8472
; ---------------------------------------------------------------------------

loc_83EA:
		tst.b	$3D(a0)
		bne.s	loc_840E
		move.w	$3E(a0),d0
		addi.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,obAngle(a0)
		cmpi.w	#$200,d0
		bne.s	loc_842A
		move.b	#1,$3D(a0)
		bra.s	loc_842A
; ---------------------------------------------------------------------------

loc_840E:
		move.w	$3E(a0),d0
		subi.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,obAngle(a0)
		cmpi.w	#$FE00,d0
		bne.s	loc_842A
		move.b	#0,$3D(a0)

loc_842A:
		move.b	obAngle(a0),d0

loc_842E:
		bsr.w	CalcSine
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		lea	obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_8442:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#v_objspace,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	$3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)
		move.w	d5,obX(a1)
		dbf	d6,loc_8442
		rts
; ---------------------------------------------------------------------------

loc_8472:
		bsr.w	CalcSine
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		moveq	#0,d4
		move.b	$3C(a0),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a0)
		move.w	d5,obX(a0)
		lea	obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6
		adda.w	d6,a2
		subq.b	#1,d6
		bcs.s	locret_84EC
		move.w	d6,-(sp)
		asl.w	#4,d0
		ext.l	d0
		asl.l	#8,d0
		asl.w	#4,d1
		ext.l	d1
		asl.l	#8,d1
		moveq	#0,d4
		moveq	#0,d5

loc_84BA:
		moveq	#0,d6
		move.b	-(a2),d6
		lsl.w	#6,d6
		addi.l	#v_objspace,d6
		movea.l	d6,a1
		movem.l	d4-d5,-(sp)
		swap	d4
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)
		move.w	d5,obX(a1)
		movem.l	(sp)+,d4-d5
		add.l	d0,d4
		add.l	d1,d5
		subq.w	#1,(sp)
		bcc.w	loc_84BA
		addq.w	#2,sp

locret_84EC:
		rts
; End of function sub_83D2

; ---------------------------------------------------------------------------

loc_84EE:
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_8506
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8506:
		moveq	#0,d2
		lea	obSubtype(a0),a2
		move.b	(a2)+,d2

loc_850E:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#v_objspace,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,loc_850E
		rts
; ---------------------------------------------------------------------------

loc_8526:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------

loc_852A:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Map_Obj15:	dc.w word_8534-Map_Obj15
		dc.w word_8546-Map_Obj15
		dc.w word_8550-Map_Obj15
word_8534:	dc.w 2
		dc.w $F809,    4,    2,$FFE8		; 0
		dc.w $F809,    4,    2,	   0		; 4
word_8546:	dc.w 1
		dc.w $F805,    0,    0,$FFF8		; 0
word_8550:	dc.w 1
		dc.w $F805,   $A,    5,$FFF8		; 0
Map_Obj15_CPZ:	dc.w word_855C-Map_Obj15_CPZ
word_855C:	dc.w 2
		dc.w $F00F,    8,    4,$FFE0		; 0
		dc.w $F00F, $808, $804,	   0		; 4
Map_Obj15_EHZ:	dc.w word_8574-Map_Obj15_EHZ
		dc.w word_85B6-Map_Obj15_EHZ
		dc.w word_85C0-Map_Obj15_EHZ
word_8574:	dc.w 8
		dc.w $F00F,    4,    2,$FFE0		; 0
		dc.w $F00F, $804, $802,	   0		; 4
		dc.w $F005,  $14,   $A,$FFD0		; 8
		dc.w $F005, $814, $80A,	 $20		; 12
		dc.w $1004,  $18,   $C,$FFE0		; 16
		dc.w $1004, $818, $80C,	 $10		; 20
		dc.w $1001,  $1A,   $D,$FFF8		; 24
		dc.w $1001, $81A, $80D,	   0		; 28
word_85B6:	dc.w 1
		dc.w $F805,$4000,$4000,$FFF8		; 0
word_85C0:	dc.w 1
		dc.w $F805,  $1C,   $E,$FFF8		; 0
Map_Obj48:	dc.w word_85D2-Map_Obj48
		dc.w word_8604-Map_Obj48
		dc.w word_8626-Map_Obj48
		dc.w word_8648-Map_Obj48
word_85D2:	dc.w 6
		dc.w $F004,  $24,  $12,$FFF0		; 0
		dc.w $F804,$1024,$1012,$FFF0		; 4
		dc.w $E80A,    0,    0,$FFE8		; 8
		dc.w $E80A, $800, $800,	   0		; 12
		dc.w	$A,$1000,$1000,$FFE8		; 16
		dc.w	$A,$1800,$1800,	   0		; 20
word_8604:	dc.w 4
		dc.w $E80A,    9,    4,$FFE8		; 0
		dc.w $E80A, $809, $804,	   0		; 4
		dc.w	$A,$1009,$1004,$FFE8		; 8
		dc.w	$A,$1809,$1804,	   0		; 12
word_8626:	dc.w 4
		dc.w $E80A,  $12,    9,$FFE8		; 0
		dc.w $E80A,  $1B,   $D,	   0		; 4
		dc.w	$A,$181B,$180D,$FFE8		; 8
		dc.w	$A,$1812,$1809,	   0		; 12
word_8648:	dc.w 4
		dc.w $E80A, $81B, $80D,$FFE8		; 0
		dc.w $E80A, $812, $809,	   0		; 4
		dc.w	$A,$1012,$1009,$FFE8		; 8
		dc.w	$A,$101B,$100D,	   0		; 12
; ---------------------------------------------------------------------------
		nop

Obj17:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj17_Index(pc,d0.w),d1
		jmp	Obj17_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj17_Index:	dc.w loc_8680-Obj17_Index
		dc.w loc_874A-Obj17_Index
		dc.w loc_87AC-Obj17_Index
; ---------------------------------------------------------------------------

loc_8680:
		addq.b	#2,obRoutine(a0)
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
		lea	obSubtype(a0),a2
		moveq	#0,d1
		move.b	(a2),d1
		move.b	#0,(a2)+
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3
		subq.b	#2,d1
		bcs.s	loc_874A
		moveq	#0,d6

loc_86D4:
		bsr.w	FindNextFreeObj
		bne.s	loc_874A
		addq.b	#1,obSubtype(a0)
		move.w	a1,d5
		subi.w	#v_objspace,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#4,obRoutine(a1)
		_move.b	d4,obID(a1)
		move.w	d2,obY(a1)
		move.w	d3,obX(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	#$4398,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#4,obRender(a1)
		move.b	#3,obPriority(a1)
		move.b	#8,obActWid(a1)
		move.b	d6,$3E(a1)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		cmp.w	obX(a0),d3
		bne.s	loc_8746
		move.b	d6,$3E(a0)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		addq.b	#1,obSubtype(a0)

loc_8746:
		dbf	d1,loc_86D4

loc_874A:
		bsr.w	sub_878C
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_8766
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8766:
		moveq	#0,d2
		lea	obSubtype(a0),a2
		move.b	(a2)+,d2
		subq.b	#2,d2
		bcs.s	loc_8788

loc_8772:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#v_objspace,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,loc_8772

loc_8788:
		bra.w	DeleteObject

; =============== S U B	R O U T	I N E =======================================


sub_878C:
		move.b	(v_ani0_frame).w,d0
		move.b	#0,obColType(a0)
		add.b	$3E(a0),d0
		andi.b	#7,d0
		move.b	d0,obFrame(a0)
		bne.s	locret_87AA
		move.b	#$84,obColType(a0)

locret_87AA:
		rts
; End of function sub_878C

; ---------------------------------------------------------------------------

loc_87AC:
		bsr.w	sub_878C
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Map_Obj17:	dc.w word_87C4-Map_Obj17
		dc.w word_87CE-Map_Obj17
		dc.w word_87D8-Map_Obj17
		dc.w word_87E2-Map_Obj17
		dc.w word_87EC-Map_Obj17
		dc.w word_87F6-Map_Obj17
		dc.w word_880A-Map_Obj17
		dc.w word_8800-Map_Obj17
word_87C4:	dc.w 1
		dc.w $F001,    0,    0,$FFFC		; 0
word_87CE:	dc.w 1
		dc.w $F505,    2,    1,$FFF8		; 0
word_87D8:	dc.w 1
		dc.w $F805,    6,    3,$FFF8		; 0
word_87E2:	dc.w 1
		dc.w $FB05,   $A,    5,$FFF8		; 0
word_87EC:	dc.w 1
		dc.w	 1,   $E,    7,$FFFC		; 0
word_87F6:	dc.w 1
		dc.w  $400,  $10,    8,$FFFD		; 0
word_8800:	dc.w 1
		dc.w $F400,  $11,    8,$FFFD		; 0
word_880A:	dc.w 0
; ---------------------------------------------------------------------------

Obj18:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj18_Index(pc,d0.w),d1
		jmp	Obj18_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj18_Index:	dc.w loc_882C-Obj18_Index
		dc.w loc_88A2-Obj18_Index
		dc.w loc_8908-Obj18_Index
		dc.w loc_88E0-Obj18_Index
Obj18_Conf:	dc.w $2000
		dc.w $2001
		dc.w $2002
		dc.w $4003
		dc.w $3004
; ---------------------------------------------------------------------------

loc_882C:
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj18_Conf(pc,d0.w),a2
		move.b	(a2)+,obActWid(a0)
		move.b	(a2)+,obFrame(a0)
		move.w	#$4000,obGfx(a0)
		move.l	#Map_Obj18,obMap(a0)
		cmpi.b	#3,(Current_Zone).w
		beq.s	loc_8866
		cmpi.b	#5,(Current_Zone).w
		bne.s	loc_8874

loc_8866:
		move.l	#Map_obj18_EHZ,obMap(a0)
		move.w	#$4000,obGfx(a0)

loc_8874:
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.w	obY(a0),$2C(a0)
		move.w	obY(a0),$34(a0)
		move.w	obX(a0),$32(a0)
		move.w	#$80,obAngle(a0)
		andi.b	#$F,obSubtype(a0)

loc_88A2:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		bne.s	loc_88B8
		tst.b	$38(a0)
		beq.s	loc_88C4
		subq.b	#4,$38(a0)
		bra.s	loc_88C4
; ---------------------------------------------------------------------------

loc_88B8:
		cmpi.b	#$40,$38(a0)
		beq.s	loc_88C4
		addq.b	#4,$38(a0)

loc_88C4:
		move.w	obX(a0),-(sp)
		bsr.w	sub_8926
		bsr.w	sub_890C
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#8,d3
		move.w	(sp)+,d4
		bsr.w	sub_F78A
		bra.s	loc_88E8
; ---------------------------------------------------------------------------

loc_88E0:
		bsr.w	sub_8926
		bsr.w	sub_890C

loc_88E8:
		tst.w	(Two_player_mode).w
		beq.s	loc_88F2
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_88F2:
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_8908
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8908:
		bra.w	DeleteObject

; =============== S U B	R O U T	I N E =======================================


sub_890C:
		move.b	$38(a0),d0
		bsr.w	CalcSine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	$2C(a0),d0
		move.w	d0,obY(a0)
		rts
; End of function sub_890C


; =============== S U B	R O U T	I N E =======================================


sub_8926:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	off_893A(pc,d0.w),d1
		jmp	off_893A(pc,d1.w)
; End of function sub_8926

; ---------------------------------------------------------------------------
off_893A:	dc.w locret_8956-off_893A
		dc.w loc_8968-off_893A
		dc.w loc_89AE-off_893A
		dc.w loc_89C6-off_893A
		dc.w loc_89EE-off_893A
		dc.w loc_8958-off_893A
		dc.w loc_899E-off_893A
		dc.w loc_8A5C-off_893A
		dc.w loc_8A88-off_893A
		dc.w locret_8956-off_893A
		dc.w loc_8AA0-off_893A
		dc.w loc_8ABA-off_893A
		dc.w loc_8990-off_893A
		dc.w loc_8980-off_893A
; ---------------------------------------------------------------------------

locret_8956:
		rts
; ---------------------------------------------------------------------------

loc_8958:
		move.w	$32(a0),d0
		move.b	obAngle(a0),d1
		neg.b	d1
		addi.b	#$40,d1
		bra.s	loc_8974
; ---------------------------------------------------------------------------

loc_8968:
		move.w	$32(a0),d0
		move.b	obAngle(a0),d1
		subi.b	#$40,d1

loc_8974:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,obX(a0)
		bra.w	loc_8AD2
; ---------------------------------------------------------------------------

loc_8980:
		move.w	$34(a0),d0
		move.b	($FFFFFE6C).w,d1
		neg.b	d1
		addi.b	#$30,d1
		bra.s	loc_89BA
; ---------------------------------------------------------------------------

loc_8990:
		move.w	$34(a0),d0
		move.b	($FFFFFE6C).w,d1
		subi.b	#$30,d1
		bra.s	loc_89BA
; ---------------------------------------------------------------------------

loc_899E:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		neg.b	d1
		addi.b	#$40,d1
		bra.s	loc_89BA
; ---------------------------------------------------------------------------

loc_89AE:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		subi.b	#$40,d1

loc_89BA:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,$2C(a0)
		bra.w	loc_8AD2
; ---------------------------------------------------------------------------

loc_89C6:
		tst.w	$3A(a0)
		bne.s	loc_89DC
		btst	#3,obStatus(a0)
		beq.s	locret_89DA
		move.w	#$1E,$3A(a0)

locret_89DA:
		rts
; ---------------------------------------------------------------------------

loc_89DC:
		subq.w	#1,$3A(a0)
		bne.s	locret_89DA
		move.w	#$20,$3A(a0)
		addq.b	#1,obSubtype(a0)
		rts
; ---------------------------------------------------------------------------

loc_89EE:
		tst.w	$3A(a0)
		beq.s	loc_8A2E
		subq.w	#1,$3A(a0)
		bne.s	loc_8A2E
		btst	#3,obStatus(a0)
		beq.s	loc_8A28
		lea	(v_objspace).w,a1
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		clr.b	ob2ndRout(a0)
		move.w	obVelY(a0),obVelY(a1)

loc_8A28:
		move.b	#6,obRoutine(a0)

loc_8A2E:
		move.l	$2C(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d3,$2C(a0)
		addi.w	#$38,obVelY(a0)
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$2C(a0),d0
		bcc.s	locret_8A5A
		move.b	#4,obRoutine(a0)

locret_8A5A:
		rts
; ---------------------------------------------------------------------------

loc_8A5C:
		tst.w	$3A(a0)
		bne.s	loc_8A7C
		lea	(f_switch).w,a2
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsr.w	#4,d0
		tst.b	(a2,d0.w)
		beq.s	locret_8A7A
		move.w	#$3C,$3A(a0)

locret_8A7A:
		rts
; ---------------------------------------------------------------------------

loc_8A7C:
		subq.w	#1,$3A(a0)
		bne.s	locret_8A7A
		addq.b	#1,obSubtype(a0)
		rts
; ---------------------------------------------------------------------------

loc_8A88:
		subq.w	#2,$2C(a0)
		move.w	$34(a0),d0
		subi.w	#$200,d0
		cmp.w	$2C(a0),d0
		bne.s	locret_8A9E
		clr.b	obSubtype(a0)

locret_8A9E:
		rts
; ---------------------------------------------------------------------------

loc_8AA0:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		subi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,$2C(a0)
		bra.w	loc_8AD2
; ---------------------------------------------------------------------------

loc_8ABA:
		move.w	$34(a0),d0
		move.b	obAngle(a0),d1
		neg.b	d1
		addi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,$2C(a0)

loc_8AD2:
		move.b	($FFFFFE78).w,obAngle(a0)
		rts
; ---------------------------------------------------------------------------
Map_Obj18x:	dc.w word_8ADE-Map_Obj18x
		dc.w word_8AF0-Map_Obj18x
word_8ADE:	dc.w 2
		dc.w $F40B,  $3C,  $1E,$FFE8		; 0
		dc.w $F40B,  $48,  $24,	   0		; 4
word_8AF0:	dc.w $A
		dc.w $F40F,  $CA,  $65,$FFE0		; 0
		dc.w  $40F,  $DA,  $6D,$FFE0		; 4
		dc.w $240F,  $DA,  $6D,$FFE0		; 8
		dc.w $440F,  $DA,  $6D,$FFE0		; 12
		dc.w $640F,  $DA,  $6D,$FFE0		; 16
		dc.w $F40F, $8CA, $865,	   0		; 20
		dc.w  $40F, $8DA, $86D,	   0		; 24
		dc.w $240F, $8DA, $86D,	   0		; 28
		dc.w $440F, $8DA, $86D,	   0		; 32
		dc.w $640F, $8DA, $86D,	   0		; 36
Map_Obj18:	dc.w word_8B46-Map_Obj18
		dc.w word_8B68-Map_Obj18
word_8B46:	dc.w 4
		dc.w $F40B,  $3B,  $1D,$FFE0		; 0
		dc.w $F407,  $3F,  $1F,$FFF8		; 4
		dc.w $F407,  $3F,  $1F,	   8		; 8
		dc.w $F403,  $47,  $23,	 $18		; 12
word_8B68:	dc.w $A
		dc.w $F40F,  $C5,  $62,$FFE0		; 0
		dc.w  $40F,  $D5,  $6A,$FFE0		; 4
		dc.w $240F,  $D5,  $6A,$FFE0		; 8
		dc.w $440F,  $D5,  $6A,$FFE0		; 12
		dc.w $640F,  $D5,  $6A,$FFE0		; 16
		dc.w $F40F, $8C5, $862,	   0		; 20
		dc.w  $40F, $8D5, $86A,	   0		; 24
		dc.w $240F, $8D5, $86A,	   0		; 28
		dc.w $440F, $8D5, $86A,	   0		; 32
		dc.w $640F, $8D5, $86A,	   0		; 36
		dc.w	 2,    3,$F60B,	 $49		; 40
		dc.w   $24,$FFE0,$F607,	 $51		; 44
		dc.w   $28,$FFF8,$F60B,	 $55		; 48
		dc.w   $2A,    8,    2,	   2		; 52
		dc.w $F80F,  $21,  $10,$FFE0		; 56
		dc.w $F80F,  $21,  $10,	   0		; 60
; ---------------------------------------------------------------------------
; Sprite mappings - EHZ platforms
; ---------------------------------------------------------------------------
Map_obj18_EHZ:	binclude	"mappings/sprite/obj18_EHZ.bin"

; ---------------------------------------------------------------------------
		nop

Obj1A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj1A_Index(pc,d0.w),d1
		jmp	Obj1A_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj1A_Index:	dc.w loc_8C58-Obj1A_Index
		dc.w loc_8CCA-Obj1A_Index
		dc.w loc_8D02-Obj1A_Index
; ---------------------------------------------------------------------------

loc_8C58:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj1A,obMap(a0)
		move.w	#$4000,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#7,$38(a0)
		move.b	obSubtype(a0),obFrame(a0)
		cmpi.b	#4,(Current_Zone).w
		bne.s	loc_8CB0
		move.l	#Map_Obj1A_HPZ,obMap(a0)
		move.w	#$434A,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#$30,obActWid(a0)
		move.l	#Obj1A_Conf_HPZ,$3C(a0)
		bra.s	loc_8CCA
; ---------------------------------------------------------------------------

loc_8CB0:
		move.l	#Obj1A_Conf,$3C(a0)
		move.b	#$34,obActWid(a0)
		move.b	#$38,obHeight(a0)
		bset	#4,obRender(a0)

loc_8CCA:
		tst.b	$3A(a0)
		beq.s	loc_8CDC
		tst.b	$38(a0)
		beq.w	loc_8E58
		subq.b	#1,$38(a0)

loc_8CDC:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		beq.s	sub_8CEC
		move.b	#1,$3A(a0)

; =============== S U B	R O U T	I N E =======================================


sub_8CEC:

; FUNCTION CHUNK AT 0000CE5A SIZE 00000038 BYTES
; FUNCTION CHUNK AT 0000CF3A SIZE 00000002 BYTES

		moveq	#0,d1
		move.b	obActWid(a0),d1
		movea.l	$3C(a0),a2
		move.w	obX(a0),d4
		bsr.w	sub_F7DC
		bra.w	MarkObjGone
; End of function sub_8CEC

; ---------------------------------------------------------------------------

loc_8D02:
		tst.b	$38(a0)
		beq.s	loc_8D46
		tst.b	$3A(a0)
		bne.s	loc_8D16
		subq.b	#1,$38(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8D16:
		bsr.w	sub_8CEC
		subq.b	#1,$38(a0)
		bne.s	locret_8D44
		lea	(v_objspace).w,a1
		bsr.s	sub_8D2A
		lea	(v_objspace+$40).w,a1

; =============== S U B	R O U T	I N E =======================================


sub_8D2A:
		btst	#3,obStatus(a1)
		beq.s	locret_8D44
		bclr	#3,obStatus(a1)
		bclr	#5,obStatus(a1)
		move.b	#1,obPrevAni(a1)

locret_8D44:
		rts
; End of function sub_8D2A

; ---------------------------------------------------------------------------

loc_8D46:
		bsr.w	ObjectMoveAndFall
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

S1Obj_53:						; leftover object from Sonic 1
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj_53_Index(pc,d0.w),d1
		jmp	S1Obj_53_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj_53_Index:	dc.w loc_8D6A-S1Obj_53_Index
		dc.w loc_8DB4-S1Obj_53_Index
		dc.w loc_8DEA-S1Obj_53_Index
; ---------------------------------------------------------------------------

loc_8D6A:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_S1Obj53,obMap(a0)
		move.w	#$42B8,obGfx(a0)
		cmpi.b	#3,(Current_Zone).w
		bne.s	loc_8D8E
		move.w	#$44E0,obGfx(a0)
		addq.b	#2,obFrame(a0)

loc_8D8E:
		cmpi.b	#5,(Current_Zone).w
		bne.s	loc_8D9C
		move.w	#$43F5,obGfx(a0)

loc_8D9C:
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#7,$38(a0)
		move.b	#$44,obActWid(a0)

loc_8DB4:
		tst.b	$3A(a0)
		beq.s	loc_8DC6
		tst.b	$38(a0)
		beq.w	loc_8E3E
		subq.b	#1,$38(a0)

loc_8DC6:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		beq.s	sub_8DD6
		move.b	#1,$3A(a0)

; =============== S U B	R O U T	I N E =======================================


sub_8DD6:
		move.w	#$20,d1
		move.w	#8,d3
		move.w	obX(a0),d4
		bsr.w	sub_F78A
		bra.w	MarkObjGone
; End of function sub_8DD6

; ---------------------------------------------------------------------------

loc_8DEA:
		tst.b	$38(a0)
		beq.s	loc_8E2E
		tst.b	$3A(a0)
		bne.s	loc_8DFE
		subq.b	#1,$38(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8DFE:
		bsr.w	sub_8DD6
		subq.b	#1,$38(a0)
		bne.s	locret_8E2C
		lea	(v_objspace).w,a1
		bsr.s	sub_8E12
		lea	(v_objspace+$40).w,a1

; =============== S U B	R O U T	I N E =======================================


sub_8E12:
		btst	#3,obStatus(a1)
		beq.s	locret_8E2C
		bclr	#3,obStatus(a1)
		bclr	#5,obStatus(a1)
		move.b	#1,obPrevAni(a1)

locret_8E2C:
		rts
; End of function sub_8E12

; ---------------------------------------------------------------------------

loc_8E2E:
		bsr.w	ObjectMoveAndFall
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_8E3E:
		lea	(byte_8F17).l,a4
		btst	#0,obSubtype(a0)
		beq.s	loc_8E52
		lea	(byte_8F1F).l,a4

loc_8E52:
		addq.b	#1,obFrame(a0)
		bra.s	loc_8E70
; ---------------------------------------------------------------------------

loc_8E58:
		lea	(byte_8EF2).l,a4
		cmpi.b	#4,(Current_Zone).w
		bne.s	loc_8E6C
		lea	(byte_8F0B).l,a4

loc_8E6C:
		addq.b	#2,obFrame(a0)

loc_8E70:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3
		move.w	(a3)+,d1
		subq.w	#1,d1
		bset	#5,obRender(a0)
		_move.b	obID(a0),d4
		move.b	obRender(a0),d5
		movea.l	a0,a1
		bra.s	loc_8E9E
; ---------------------------------------------------------------------------

loc_8E96:
		bsr.w	FindFreeObj
		bne.s	loc_8EE4
		addq.w	#8,a3

loc_8E9E:
		move.b	#4,obRoutine(a1)
		_move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.b	obHeight(a0),obHeight(a1)
		move.b	(a4)+,$38(a1)
		cmpa.l	a0,a1
		bcc.s	loc_8EE0
		bsr.w	DisplaySprite2

loc_8EE0:
		dbf	d1,loc_8E96

loc_8EE4:
		bsr.w	DisplaySprite
		move.w	#sfx_Collapse,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------
byte_8EF2:	dc.b $1C,$18,$14,$10			; 0
		dc.b $1A,$16,$12, $E			; 4
		dc.b  $A,  6,$18,$14			; 8
		dc.b $10, $C,  8,  4			; 12
		dc.b $16,$12, $E, $A			; 16
		dc.b   6,  2,$14,$10			; 20
		dc.b  $C				; 24
byte_8F0B:	dc.b $18,$1C,$20,$1E			; 0
		dc.b $1A,$16,  6, $E			; 4
		dc.b $14,$12, $A,  2			; 8
byte_8F17:	dc.b $1E,$16, $E,  6			; 0
		dc.b $1A,$12, $A,  2			; 4
byte_8F1F:	dc.b $16,$1E,$1A,$12			; 0
		dc.b   6, $E, $A,  2			; 4
		dc.b   0				; 8
Obj1A_Conf:	dc.b $20,$20,$20,$20			; 0
		dc.b $20,$20,$20,$20			; 4
		dc.b $21,$21,$22,$22			; 8
		dc.b $23,$23,$24,$24			; 12
		dc.b $25,$25,$26,$26			; 16
		dc.b $27,$27,$28,$28			; 20
		dc.b $29,$29,$2A,$2A			; 24
		dc.b $2B,$2B,$2C,$2C			; 28
		dc.b $2D,$2D,$2E,$2E			; 32
		dc.b $2F,$2F,$30,$30			; 36
		dc.b $30,$30,$30,$30			; 40
		dc.b $30,$30,$30,$30			; 44
Map_Obj1A:	dc.w word_8F60-Map_Obj1A
		dc.w word_8FE2-Map_Obj1A
		dc.w word_9064-Map_Obj1A
		dc.w word_912E-Map_Obj1A
word_8F60:	dc.w $10
		dc.w $C80E,  $57,  $2B,	 $10		; 0
		dc.w $D00D,  $63,  $31,$FFF0		; 4
		dc.w $E00D,  $6B,  $35,	 $10		; 8
		dc.w $E00D,  $73,  $39,$FFF0		; 12
		dc.w $D806,  $7B,  $3D,$FFE0		; 16
		dc.w $D806,  $81,  $40,$FFD0		; 20
		dc.w $F00D,  $87,  $43,	 $10		; 24
		dc.w $F00D,  $8F,  $47,$FFF0		; 28
		dc.w $F005,  $97,  $4B,$FFE0		; 32
		dc.w $F005,  $9B,  $4D,$FFD0		; 36
		dc.w	$D,  $9F,  $4F,	 $10		; 40
		dc.w	 5,  $A7,  $53,	   0		; 44
		dc.w	$D,  $AB,  $55,$FFE0		; 48
		dc.w	 5,  $B3,  $59,$FFD0		; 52
		dc.w $100D,  $AB,  $55,	 $10		; 56
		dc.w $1005,  $B7,  $5B,	   0		; 60
word_8FE2:	dc.w $10
		dc.w $C80E,  $57,  $2B,	 $10		; 0
		dc.w $D00D,  $63,  $31,$FFF0		; 4
		dc.w $E00D,  $6B,  $35,	 $10		; 8
		dc.w $E00D,  $73,  $39,$FFF0		; 12
		dc.w $D806,  $7B,  $3D,$FFE0		; 16
		dc.w $D806,  $BB,  $5D,$FFD0		; 20
		dc.w $F00D,  $87,  $43,	 $10		; 24
		dc.w $F00D,  $8F,  $47,$FFF0		; 28
		dc.w $F005,  $97,  $4B,$FFE0		; 32
		dc.w $F005,  $C1,  $60,$FFD0		; 36
		dc.w	$D,  $9F,  $4F,	 $10		; 40
		dc.w	 5,  $A7,  $53,	   0		; 44
		dc.w	$D,  $AB,  $55,$FFE0		; 48
		dc.w	 5,  $B7,  $5B,$FFD0		; 52
		dc.w $100D,  $AB,  $55,	 $10		; 56
		dc.w $1005,  $B7,  $5B,	   0		; 60
word_9064:	dc.w $19
		dc.w $C806,  $5D,  $2E,	 $20		; 0
		dc.w $C806,  $57,  $2B,	 $10		; 4
		dc.w $D005,  $67,  $33,	   0		; 8
		dc.w $D005,  $63,  $31,$FFF0		; 12
		dc.w $E005,  $6F,  $37,	 $20		; 16
		dc.w $E005,  $6B,  $35,	 $10		; 20
		dc.w $E005,  $77,  $3B,	   0		; 24
		dc.w $E005,  $73,  $39,$FFF0		; 28
		dc.w $D806,  $7B,  $3D,$FFE0		; 32
		dc.w $D806,  $81,  $40,$FFD0		; 36
		dc.w $F005,  $8B,  $45,	 $20		; 40
		dc.w $F005,  $87,  $43,	 $10		; 44
		dc.w $F005,  $93,  $49,	   0		; 48
		dc.w $F005,  $8F,  $47,$FFF0		; 52
		dc.w $F005,  $97,  $4B,$FFE0		; 56
		dc.w $F005,  $9B,  $4D,$FFD0		; 60
		dc.w	 5,  $8B,  $45,	 $20		; 64
		dc.w	 5,  $8B,  $45,	 $10		; 68
		dc.w	 5,  $A7,  $53,	   0		; 72
		dc.w	 5,  $AB,  $55,$FFF0		; 76
		dc.w	 5,  $AB,  $55,$FFE0		; 80
		dc.w	 5,  $B3,  $59,$FFD0		; 84
		dc.w $1005,  $AB,  $55,	 $20		; 88
		dc.w $1005,  $AB,  $55,	 $10		; 92
		dc.w $1005,  $B7,  $5B,	   0		; 96
word_912E:	dc.w $19
		dc.w $C806,  $5D,  $2E,	 $20		; 0
		dc.w $C806,  $57,  $2B,	 $10		; 4
		dc.w $D005,  $67,  $33,	   0		; 8
		dc.w $D005,  $63,  $31,$FFF0		; 12
		dc.w $E005,  $6F,  $37,	 $20		; 16
		dc.w $E005,  $6B,  $35,	 $10		; 20
		dc.w $E005,  $77,  $3B,	   0		; 24
		dc.w $E005,  $73,  $39,$FFF0		; 28
		dc.w $D806,  $7B,  $3D,$FFE0		; 32
		dc.w $D806,  $BB,  $5D,$FFD0		; 36
		dc.w $F005,  $8B,  $45,	 $20		; 40
		dc.w $F005,  $87,  $43,	 $10		; 44
		dc.w $F005,  $93,  $49,	   0		; 48
		dc.w $F005,  $8F,  $47,$FFF0		; 52
		dc.w $F005,  $97,  $4B,$FFE0		; 56
		dc.w $F005,  $C1,  $60,$FFD0		; 60
		dc.w	 5,  $8B,  $45,	 $20		; 64
		dc.w	 5,  $8B,  $45,	 $10		; 68
		dc.w	 5,  $A7,  $53,	   0		; 72
		dc.w	 5,  $AB,  $55,$FFF0		; 76
		dc.w	 5,  $AB,  $55,$FFE0		; 80
		dc.w	 5,  $B7,  $5B,$FFD0		; 84
		dc.w $1005,  $AB,  $55,	 $20		; 88
		dc.w $1005,  $AB,  $55,	 $10		; 92
		dc.w $1005,  $B7,  $5B,	   0		; 96
Map_S1Obj53:	dc.w word_9200-Map_S1Obj53
		dc.w word_9222-Map_S1Obj53
		dc.w word_9264-Map_S1Obj53
		dc.w word_9286-Map_S1Obj53
word_9200:	dc.w 4
		dc.w $F80D,    0,    0,$FFE0		; 0
		dc.w  $80D,    0,    0,$FFE0		; 4
		dc.w $F80D,    0,    0,	   0		; 8
		dc.w  $80D,    0,    0,	   0		; 12
word_9222:	dc.w 8
		dc.w $F805,    0,    0,$FFE0		; 0
		dc.w $F805,    0,    0,$FFF0		; 4
		dc.w $F805,    0,    0,	   0		; 8
		dc.w $F805,    0,    0,	 $10		; 12
		dc.w  $805,    0,    0,$FFE0		; 16
		dc.w  $805,    0,    0,$FFF0		; 20
		dc.w  $805,    0,    0,	   0		; 24
		dc.w  $805,    0,    0,	 $10		; 28
word_9264:	dc.w 4
		dc.w $F80D,    0,    0,$FFE0		; 0
		dc.w  $80D,    8,    4,$FFE0		; 4
		dc.w $F80D,    0,    0,	   0		; 8
		dc.w  $80D,    8,    4,	   0		; 12
word_9286:	dc.w 8
		dc.w $F805,    0,    0,$FFE0		; 0
		dc.w $F805,    4,    2,$FFF0		; 4
		dc.w $F805,    0,    0,	   0		; 8
		dc.w $F805,    4,    2,	 $10		; 12
		dc.w  $805,    8,    4,$FFE0		; 16
		dc.w  $805,   $C,    6,$FFF0		; 20
		dc.w  $805,    8,    4,	   0		; 24
		dc.w  $805,   $C,    6,	 $10		; 28
Obj1A_Conf_HPZ:	dc.b $10,$10,$10,$10			; 0
		dc.b $10,$10,$10,$10			; 4
		dc.b $10,$10,$10,$10			; 8
		dc.b $10,$10,$10,$10			; 12
		dc.b $10,$10,$10,$10			; 16
		dc.b $10,$10,$10,$10			; 20
		dc.b $10,$10,$10,$10			; 24
		dc.b $10,$10,$10,$10			; 28
		dc.b $10,$10,$10,$10			; 32
		dc.b $10,$10,$10,$10			; 36
		dc.b $10,$10,$10,$10			; 40
		dc.b $10,$10,$10,$10			; 44
Map_Obj1A_HPZ:	dc.w word_92FE-Map_Obj1A_HPZ
		dc.w word_9340-Map_Obj1A_HPZ
		dc.w word_9340-Map_Obj1A_HPZ
word_92FE:	dc.w 8
		dc.w $F00D,    0,    0,$FFD0		; 0
		dc.w	$D,    8,    4,$FFD0		; 4
		dc.w $F005,    4,    2,$FFF0		; 8
		dc.w $F005, $804, $802,	   0		; 12
		dc.w	 5,   $C,    6,$FFF0		; 16
		dc.w	 5, $80C, $806,	   0		; 20
		dc.w $F00D, $800, $800,	 $10		; 24
		dc.w	$D, $808, $804,	 $10		; 28
word_9340:	dc.w $C
		dc.w $F005,    0,    0,$FFD0		; 0
		dc.w $F005,    4,    2,$FFE0		; 4
		dc.w $F005,    4,    2,$FFF0		; 8
		dc.w $F005, $804, $802,	   0		; 12
		dc.w $F005, $804, $802,	 $10		; 16
		dc.w $F005, $800, $800,	 $20		; 20
		dc.w	 5,    8,    4,$FFD0		; 24
		dc.w	 5,   $C,    6,$FFE0		; 28
		dc.w	 5,   $C,    6,$FFF0		; 32
		dc.w	 5, $80C, $806,	   0		; 36
		dc.w	 5, $80C, $806,	 $10		; 40
		dc.w	 5, $808, $804,	 $20		; 44
; ---------------------------------------------------------------------------
		nop

Obj1C:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj1C_Index(pc,d0.w),d1
		jmp	Obj1C_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj1C_Index:	dc.w loc_93F4-Obj1C_Index
		dc.w loc_9442-Obj1C_Index
		dc.w loc_9464-Obj1C_Index
Obj1C_Conf:	dc.l Map_obj11_HPZ
		dc.w $6300
		dc.b   3,  4,  1,  0			; 0
		dc.l Map_Obj1C_01
		dc.w $E35A
		dc.b   0,$10,  1,  0			; 0
		dc.l Map_obj11
		dc.w $43C6
		dc.b   1,  4,  1,  0			; 0
		dc.l Map_obj11_GHZ
		dc.w $44C6
		dc.b   1,$10,  1,  0			; 0
		dc.l Map_Obj16
		dc.w $43E6
		dc.b   1,  8,  4,  0			; 0
		dc.l Map_Obj16
		dc.w $43E6
		dc.b   2,  8,  4,  0			; 0
; ---------------------------------------------------------------------------

loc_93F4:
		addq.b	#2,obRoutine(a0)
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		mulu.w	#$A,d0
		lea	Obj1C_Conf(pc,d0.w),a1
		move.l	(a1)+,obMap(a0)
		move.w	(a1)+,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obActWid(a0)
		move.b	(a1)+,obPriority(a0)
		move.b	(a1)+,obColType(a0)
		move.b	obSubtype(a0),d0
		andi.w	#$F0,d0
		beq.s	loc_9442
		addq.b	#2,obRoutine(a0)
		lsr.b	#4,d0
		subq.b	#1,d0
		move.b	d0,obAnim(a0)
		bra.s	loc_9464
; ---------------------------------------------------------------------------

loc_9442:
		tst.w	(Two_player_mode).w
		beq.s	loc_944C
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_944C:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9464:
		lea	(Ani_Obj1C).l,a1
		bsr.w	AnimateSprite
		tst.w	(Two_player_mode).w
		beq.s	loc_9478
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9478:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Ani_Obj1C:	dc.w byte_9494-Ani_Obj1C
		dc.w byte_949C-Ani_Obj1C
byte_9494:	dc.b   8,  3,  3,  4,  5,  5,  4,$FF	; 0
byte_949C:	dc.b   5,  0,  0,  0,  1,  2,  3,  3	; 0
		dc.b   2,  1,  2,  3,  3,  1,$FF,  0	; 8
Map_Obj1C_01:	dc.w word_94B4-Map_Obj1C_01
		dc.w word_94BE-Map_Obj1C_01
		dc.w word_94C8-Map_Obj1C_01
		dc.w word_94DA-Map_Obj1C_01
word_94B4:	dc.w 1
		dc.w $F40A,    0,    0,$FFF4		; 0
word_94BE:	dc.w 1
		dc.w $F40A,    9,    4,$FFF4		; 0
word_94C8:	dc.w 2
		dc.w $F00D,  $12,    9,$FFF0		; 0
		dc.w	$D,$1812,$1809,$FFF0		; 4
word_94DA:	dc.w 2
		dc.w $F00D,  $1A,   $D,$FFF0		; 0
		dc.w	$D,$181A,$180D,$FFF0		; 4
; ---------------------------------------------------------------------------

Obj2A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj2A_Index(pc,d0.w),d1
		jmp	Obj2A_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj2A_Index:	dc.w loc_94FE-Obj2A_Index
		dc.w loc_9526-Obj2A_Index
; ---------------------------------------------------------------------------

loc_94FE:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj2A,obMap(a0)
		move.w	#$42E8,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#8,obActWid(a0)
		move.b	#4,obPriority(a0)

loc_9526:
		move.w	#$40,d1
		clr.b	obAnim(a0)
		move.w	(v_objspace+obX).w,d0
		add.w	d1,d0
		cmp.w	obX(a0),d0
		bcs.s	loc_9564
		sub.w	d1,d0
		sub.w	d1,d0
		cmp.w	obX(a0),d0
		bcc.s	loc_9564
		add.w	d1,d0
		cmp.w	obX(a0),d0
		bcc.s	loc_9556
		btst	#0,obStatus(a0)
		bne.s	loc_9564
		bra.s	loc_955E
; ---------------------------------------------------------------------------

loc_9556:
		btst	#0,obStatus(a0)
		beq.s	loc_9564

loc_955E:
		move.b	#1,obAnim(a0)

loc_9564:
		lea	(Ani_Obj2A).l,a1
		bsr.w	AnimateSprite
		tst.b	obFrame(a0)
		bne.s	loc_9588
		move.w	#$11,d1
		move.w	#$20,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject

loc_9588:
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------
Ani_Obj2A:	dc.w byte_9590-Ani_Obj2A
		dc.w byte_959C-Ani_Obj2A
byte_9590:	dc.b   0,  8,  7,  6,  5,  4,  3,  2	; 0
		dc.b   1,  0,$FE,  1			; 8
byte_959C:	dc.b   0,  0,  1,  2,  3,  4,  5,  6	; 0
		dc.b   7,  8,$FE,  1			; 8
Map_Obj2A:	dc.w word_95BA-Map_Obj2A
		dc.w word_95CC-Map_Obj2A
		dc.w word_95DE-Map_Obj2A
		dc.w word_95F0-Map_Obj2A
		dc.w word_9602-Map_Obj2A
		dc.w word_9614-Map_Obj2A
		dc.w word_9626-Map_Obj2A
		dc.w word_9638-Map_Obj2A
		dc.w word_964A-Map_Obj2A
word_95BA:	dc.w 2
		dc.w $E007, $800, $800,$FFF8		; 0
		dc.w	 7, $800, $800,$FFF8		; 4
word_95CC:	dc.w 2
		dc.w $DC07, $800, $800,$FFF8		; 0
		dc.w  $407, $800, $800,$FFF8		; 4
word_95DE:	dc.w 2
		dc.w $D807, $800, $800,$FFF8		; 0
		dc.w  $807, $800, $800,$FFF8		; 4
word_95F0:	dc.w 2
		dc.w $D407, $800, $800,$FFF8		; 0
		dc.w  $C07, $800, $800,$FFF8		; 4
word_9602:	dc.w 2
		dc.w $D007, $800, $800,$FFF8		; 0
		dc.w $1007, $800, $800,$FFF8		; 4
word_9614:	dc.w 2
		dc.w $CC07, $800, $800,$FFF8		; 0
		dc.w $1407, $800, $800,$FFF8		; 4
word_9626:	dc.w 2
		dc.w $C807, $800, $800,$FFF8		; 0
		dc.w $1807, $800, $800,$FFF8		; 4
word_9638:	dc.w 2
		dc.w $C407, $800, $800,$FFF8		; 0
		dc.w $1C07, $800, $800,$FFF8		; 4
word_964A:	dc.w 2
		dc.w $C007, $800, $800,$FFF8		; 0
		dc.w $2007, $800, $800,$FFF8		; 4
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Sonic	1 Object 1E - leftover Ballhog object
;----------------------------------------------------

S1Obj_1E:						; leftover from Sonic 1
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj_1E_Index(pc,d0.w),d1
		jmp	S1Obj_1E_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj_1E_Index:	dc.w loc_966E-S1Obj_1E_Index
		dc.w loc_96C2-S1Obj_1E_Index
; ---------------------------------------------------------------------------

loc_966E:
		move.b	#$13,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.l	#Map_S1Obj1E,obMap(a0)
		move.w	#$2302,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#5,obColType(a0)
		move.b	#$C,obActWid(a0)
		bsr.w	ObjectMoveAndFall
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_96C0
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)

locret_96C0:
		rts
; ---------------------------------------------------------------------------

loc_96C2:
		lea	(Ani_S1Obj1E).l,a1
		bsr.w	AnimateSprite
		cmpi.b	#1,obFrame(a0)
		bne.s	loc_96DC
		tst.b	$32(a0)
		beq.s	loc_96E4
		bra.s	loc_96E0
; ---------------------------------------------------------------------------

loc_96DC:
		clr.b	$32(a0)

loc_96E0:
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------

loc_96E4:
		move.b	#1,$32(a0)
		bsr.w	FindFreeObj
		bne.s	loc_972E
		_move.b	#$20,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$FF00,obVelX(a1)
		move.w	#0,obVelY(a1)
		moveq	#$FFFFFFFC,d0
		btst	#0,obStatus(a0)
		beq.s	loc_971E
		neg.w	d0
		neg.w	obVelX(a1)

loc_971E:
		add.w	d0,obX(a1)
		addi.w	#$C,obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)

loc_972E:
		bra.s	loc_96E0
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Sonic	1 Object 20 - leftover object for the
;  ball	that S1	Ballhog	throws
;----------------------------------------------------

S1Obj20:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj20_Index(pc,d0.w),d1
		jmp	S1Obj20_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj20_Index:	dc.w loc_9742-S1Obj20_Index
		dc.w loc_978A-S1Obj20_Index
; ---------------------------------------------------------------------------

loc_9742:
		addq.b	#2,obRoutine(a0)
		move.b	#7,obHeight(a0)
		move.l	#Map_S1Obj1E,obMap(a0)
		move.w	#$2302,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#$87,obColType(a0)
		move.b	#8,obActWid(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		mulu.w	#$3C,d0
		move.w	d0,$30(a0)
		move.b	#4,obFrame(a0)

loc_978A:
		jsr	(ObjectMoveAndFall).l
		tst.w	obVelY(a0)
		bmi.s	loc_97C6
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_97C6
		add.w	d1,obY(a0)
		move.w	#$FD00,obVelY(a0)
		tst.b	d3
		beq.s	loc_97C6
		bmi.s	loc_97BC
		tst.w	obVelX(a0)
		bpl.s	loc_97C6
		neg.w	obVelX(a0)
		bra.s	loc_97C6
; ---------------------------------------------------------------------------

loc_97BC:
		tst.w	obVelX(a0)
		bmi.s	loc_97C6
		neg.w	obVelX(a0)

loc_97C6:
		subq.w	#1,$30(a0)
		bpl.s	loc_97E2
		_move.b	#$24,obID(a0)
		_move.b	#$3F,obID(a0)
		move.b	#0,obRoutine(a0)
		bra.w	Obj3F				; explosion object
; ---------------------------------------------------------------------------

loc_97E2:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_97F4
		move.b	#5,obTimeFrame(a0)
		bchg	#0,obFrame(a0)

loc_97F4:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		bcs.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 24 - explosion	from a hit monitor
;----------------------------------------------------

Obj24:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj24_Index(pc,d0.w),d1
		jmp	Obj24_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj24_Index:	dc.w loc_981A-Obj24_Index
		dc.w loc_985E-Obj24_Index
; ---------------------------------------------------------------------------

loc_981A:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj24,obMap(a0)
		move.w	#$41C,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#9,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		move.w	#sfx_A5,d0
		jsr	(PlaySound_Special).l

loc_985E:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9878
		move.b	#9,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#4,obFrame(a0)
		beq.w	DeleteObject

loc_9878:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 27 - explosion	from a hit enemy
;----------------------------------------------------

Obj27:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj27_Index(pc,d0.w),d1
		jmp	Obj27_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj27_Index:	dc.w loc_9890-Obj27_Index
		dc.w loc_98B2-Obj27_Index
		dc.w loc_98F6-Obj27_Index
; ---------------------------------------------------------------------------

loc_9890:
		addq.b	#2,obRoutine(a0)
		bsr.w	FindFreeObj
		bne.s	loc_98B2
		_move.b	#$28,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	$3E(a0),$3E(a1)

loc_98B2:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj27,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		move.w	#sfx_BreakItem,d0
		jsr	(PlaySound_Special).l

loc_98F6:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9910
		move.b	#7,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#5,obFrame(a0)
		beq.w	DeleteObject

loc_9910:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 3F - Explosion
;----------------------------------------------------

Obj3F:
		moveq	#0,d0				; explosion object
		move.b	obRoutine(a0),d0
		move.w	Obj3F_Index(pc,d0.w),d1
		jmp	Obj3F_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj3F_Index:	dc.w loc_9926-Obj3F_Index
		dc.w loc_98F6-Obj3F_Index
; ---------------------------------------------------------------------------

loc_9926:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj3F,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		move.w	#sfx_Bomb,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------
Ani_S1Obj1E:	dc.w byte_996C-Ani_S1Obj1E
byte_996C:	dc.b   9,  0,  0,  2,  2,  3,  2,  0
		dc.b   0,  2,  2,  3,  2,  0,  0,  2
		dc.b   2,  3,  2,  0,  0,  1,$FF,  0
Map_S1Obj1E:	dc.w word_9990-Map_S1Obj1E
		dc.w word_99A2-Map_S1Obj1E
		dc.w word_99B4-Map_S1Obj1E
		dc.w word_99C6-Map_S1Obj1E
		dc.w word_99D8-Map_S1Obj1E
		dc.w word_99E2-Map_S1Obj1E
word_9990:	dc.w 2
		dc.w $EF09,    0,    0,$FFF4		; 0
		dc.w $FF0A,    6,    3,$FFF4		; 4
word_99A2:	dc.w 2
		dc.w $EF09,    0,    0,$FFF4		; 0
		dc.w $FF0A,   $F,    7,$FFF4		; 4
word_99B4:	dc.w 2
		dc.w $F409,    0,    0,$FFF4		; 0
		dc.w  $409,  $18,   $C,$FFF4		; 4
word_99C6:	dc.w 2
		dc.w $E409,    0,    0,$FFF4		; 0
		dc.w $F40A,  $1E,   $F,$FFF4		; 4
word_99D8:	dc.w 1
		dc.w $F805,  $27,  $13,$FFF8		; 0
word_99E2:	dc.w 1
		dc.w $F805,  $2B,  $15,$FFF8		; 0
Map_Obj24:	dc.w word_99F4-Map_Obj24
		dc.w word_99FE-Map_Obj24
		dc.w word_9A08-Map_Obj24
		dc.w word_9A12-Map_Obj24
word_99F4:	dc.w 1
		dc.w $F40A,    0,    0,$FFF4		; 0
word_99FE:	dc.w 1
		dc.w $F40A,    9,    4,$FFF4		; 0
word_9A08:	dc.w 1
		dc.w $F40A,  $12,    9,$FFF4		; 0
word_9A12:	dc.w 1
		dc.w $F40A,  $1B,   $D,$FFF4		; 0
Map_Obj27:	dc.w word_9A26-Map_Obj27
		dc.w word_9A30-Map_Obj27
		dc.w word_9A3A-Map_Obj27
		dc.w word_9A44-Map_Obj27
		dc.w word_9A66-Map_Obj27
word_9A26:	dc.w 1
		dc.w $F809,    0,    0,$FFF4		; 0
word_9A30:	dc.w 1
		dc.w $F00F,    6,    3,$FFF0		; 0
word_9A3A:	dc.w 1
		dc.w $F00F,  $16,   $B,$FFF0		; 0
word_9A44:	dc.w 4
		dc.w $EC0A,  $26,  $13,$FFEC		; 0
		dc.w $EC05,  $2F,  $17,	   4		; 4
		dc.w  $405,$182F,$1817,$FFEC		; 8
		dc.w $FC0A,$1826,$1813,$FFFC		; 12
word_9A66:	dc.w 4
		dc.w $EC0A,  $33,  $19,$FFEC		; 0
		dc.w $EC05,  $3C,  $1E,	   4		; 4
		dc.w  $405,$183C,$181E,$FFEC		; 8
		dc.w $FC0A,$1833,$1819,$FFFC		; 12
Map_Obj3F:	dc.w word_9A26-Map_Obj3F
		dc.w word_9A92-Map_Obj3F
		dc.w word_9A9C-Map_Obj3F
		dc.w word_9A44-Map_Obj3F
		dc.w word_9A66-Map_Obj3F
word_9A92:	dc.w 1
		dc.w $F00F,  $40,  $20,$FFF0		; 0
word_9A9C:	dc.w 1
		dc.w $F00F,  $50,  $28,$FFF0		; 0
; ---------------------------------------------------------------------------
		nop
;----------------------------------------------------
; Object 28 - animals
;----------------------------------------------------

Obj28:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	off_9AB6(pc,d0.w),d1
		jmp	off_9AB6(pc,d1.w)
; ---------------------------------------------------------------------------
off_9AB6:	dc.w loc_9B92-off_9AB6,loc_9CB8-off_9AB6,loc_9D12-off_9AB6 ; 0
		dc.w loc_9D4E-off_9AB6,loc_9D12-off_9AB6,loc_9D12-off_9AB6 ; 3
		dc.w loc_9D12-off_9AB6,loc_9D4E-off_9AB6,loc_9D12-off_9AB6 ; 6
		dc.w loc_9DCE-off_9AB6,loc_9DEE-off_9AB6,loc_9DEE-off_9AB6 ; 9
		dc.w loc_9E0E-off_9AB6,loc_9E48-off_9AB6,loc_9EA2-off_9AB6 ; 12
		dc.w loc_9EC0-off_9AB6,loc_9EA2-off_9AB6,loc_9EC0-off_9AB6 ; 15
		dc.w loc_9EA2-off_9AB6,loc_9EFE-off_9AB6,loc_9E64-off_9AB6 ; 18
byte_9AE0:	dc.b   0,  5,  2,  3,  6,  3,  4,  5,  4,  1,  0,  1 ; 0
word_9AEC:	dc.w $FE00
		dc.w $FC00
		dc.l Map_Obj28a
		dc.w $FE00
		dc.w $FD00
		dc.l Map_Obj28
		dc.w $FE80
		dc.w $FD00
		dc.l Map_Obj28a
		dc.w $FEC0
		dc.w $FE80
		dc.l Map_Obj28
		dc.w $FE40
		dc.w $FD00
		dc.l Map_Obj28b
		dc.w $FD00
		dc.w $FC00
		dc.l Map_Obj28
		dc.w $FD80
		dc.w $FC80
		dc.l Map_Obj28b
word_9B24:	dc.w $FBC0,$FC00,$FBC0,$FC00		; 0
		dc.w $FBC0,$FC00,$FD00,$FC00		; 4
		dc.w $FD00,$FC00,$FE80,$FD00		; 8
		dc.w $FE80,$FD00,$FEC0,$FE80		; 12
		dc.w $FE40,$FD00,$FE00,$FD00		; 16
		dc.w $FD80,$FC80			; 20
off_9B50:	dc.l Map_Obj28,Map_Obj28		; 0
		dc.l Map_Obj28,Map_Obj28a		; 2
		dc.l Map_Obj28a,Map_Obj28a		; 4
		dc.l Map_Obj28a,Map_Obj28		; 6
		dc.l Map_Obj28b,Map_Obj28		; 8
		dc.l Map_Obj28b				; 10
word_9B7C:	dc.w  $5A5, $5A5, $5A5,	$553, $553, $573, $573,	$585, $593, $565, $5B3 ;	0
; ---------------------------------------------------------------------------

loc_9B92:
		tst.b	obSubtype(a0)
		beq.w	loc_9C00
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.b	d0,obRoutine(a0)
		subi.w	#$14,d0
		move.w	word_9B7C(pc,d0.w),obGfx(a0)
		add.w	d0,d0
		move.l	off_9B50(pc,d0.w),obMap(a0)
		lea	word_9B24(pc),a1
		move.w	(a1,d0.w),$32(a0)
		move.w	(a1,d0.w),obVelX(a0)
		move.w	2(a1,d0.w),$34(a0)
		move.w	2(a1,d0.w),obVelY(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#$C,obHeight(a0)
		move.b	#4,obRender(a0)
		bset	#0,obRender(a0)
		move.b	#6,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9C00:
		addq.b	#2,obRoutine(a0)
		bsr.w	RandomNumber
		andi.w	#1,d0
		moveq	#0,d1
		move.b	(Current_Zone).w,d1
		add.w	d1,d1
		add.w	d0,d1
		lea	byte_9AE0(pc),a1
		move.b	(a1,d1.w),d0
		move.b	d0,$30(a0)
		lsl.w	#3,d0
		lea	word_9AEC(pc),a1
		adda.w	d0,a1
		move.w	(a1)+,$32(a0)
		move.w	(a1)+,$34(a0)
		move.l	(a1)+,obMap(a0)
		move.w	#$580,obGfx(a0)
		btst	#0,$30(a0)
		beq.s	loc_9C4A
		move.w	#$592,obGfx(a0)

loc_9C4A:
		bsr.w	Adjust2PArtPointer
		move.b	#$C,obHeight(a0)
		move.b	#4,obRender(a0)
		bset	#0,obRender(a0)
		move.b	#6,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#2,obFrame(a0)
		move.w	#$FC00,obVelY(a0)
		tst.b	($FFFFF7A7).w
		bne.s	loc_9CAA
		bsr.w	FindFreeObj
		bne.s	loc_9CA6
		_move.b	#$29,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	$3E(a0),d0
		lsr.w	#1,d0
		move.b	d0,obFrame(a1)

loc_9CA6:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9CAA:
		move.b	#$12,obRoutine(a0)
		clr.w	obVelX(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9CB8:
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bsr.w	ObjectMoveAndFall
		tst.w	obVelY(a0)
		bmi.s	loc_9D0E
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_9D0E
		add.w	d1,obY(a0)
		move.w	$32(a0),obVelX(a0)
		move.w	$34(a0),obVelY(a0)
		move.b	#1,obFrame(a0)
		move.b	$30(a0),d0
		add.b	d0,d0
		addq.b	#4,d0
		move.b	d0,obRoutine(a0)
		tst.b	($FFFFF7A7).w
		beq.s	loc_9D0E
		btst	#4,($FFFFFE0F).w
		beq.s	loc_9D0E
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_9D0E:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9D12:
		bsr.w	ObjectMoveAndFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_9D3C
		move.b	#0,obFrame(a0)
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_9D3C
		add.w	d1,obY(a0)
		move.w	$34(a0),obVelY(a0)

loc_9D3C:
		tst.b	obSubtype(a0)
		bne.s	loc_9DB2
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9D4E:
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_9D8A
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_9D8A
		add.w	d1,obY(a0)
		move.w	$34(a0),obVelY(a0)
		tst.b	obSubtype(a0)
		beq.s	loc_9D8A
		cmpi.b	#$A,obSubtype(a0)
		beq.s	loc_9D8A
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_9D8A:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9DA0
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		andi.b	#1,obFrame(a0)

loc_9DA0:
		tst.b	obSubtype(a0)
		bne.s	loc_9DB2
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9DB2:
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		bcs.s	loc_9DCA
		subi.w	#$180,d0
		bpl.s	loc_9DCA
		tst.b	obRender(a0)
		bpl.w	DeleteObject

loc_9DCA:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9DCE:
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		subq.w	#1,$36(a0)
		bne.w	loc_9DEA
		move.b	#2,obRoutine(a0)
		move.b	#3,obPriority(a0)

loc_9DEA:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_9DEE:
		bsr.w	sub_9F92
		bcc.s	loc_9E0A
		move.w	$32(a0),obVelX(a0)
		move.w	$34(a0),obVelY(a0)
		move.b	#$E,obRoutine(a0)
		bra.w	loc_9D4E
; ---------------------------------------------------------------------------

loc_9E0A:
		bra.w	loc_9DB2
; ---------------------------------------------------------------------------

loc_9E0E:
		bsr.w	sub_9F92
		bpl.s	loc_9E44
		clr.w	obVelX(a0)
		clr.w	$32(a0)
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		bsr.w	sub_9F52
		bsr.w	sub_9F7A
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9E44
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		andi.b	#1,obFrame(a0)

loc_9E44:
		bra.w	loc_9DB2
; ---------------------------------------------------------------------------

loc_9E48:
		bsr.w	sub_9F92
		bpl.s	loc_9E9E
		move.w	$32(a0),obVelX(a0)
		move.w	$34(a0),obVelY(a0)
		move.b	#4,obRoutine(a0)
		bra.w	loc_9D12
; ---------------------------------------------------------------------------

loc_9E64:
		bsr.w	ObjectMoveAndFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_9E9E
		move.b	#0,obFrame(a0)
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_9E9E
		not.b	$29(a0)
		bne.s	loc_9E94
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_9E94:
		add.w	d1,obY(a0)
		move.w	$34(a0),obVelY(a0)

loc_9E9E:
		bra.w	loc_9DB2
; ---------------------------------------------------------------------------

loc_9EA2:
		bsr.w	sub_9F92
		bpl.s	loc_9EBC
		clr.w	obVelX(a0)
		clr.w	$32(a0)
		bsr.w	ObjectMoveAndFall
		bsr.w	sub_9F52
		bsr.w	sub_9F7A

loc_9EBC:
		bra.w	loc_9DB2
; ---------------------------------------------------------------------------

loc_9EC0:
		bsr.w	sub_9F92
		bpl.s	loc_9EFA
		bsr.w	ObjectMoveAndFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_9EFA
		move.b	#0,obFrame(a0)
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_9EFA
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)
		add.w	d1,obY(a0)
		move.w	$34(a0),obVelY(a0)

loc_9EFA:
		bra.w	loc_9DB2
; ---------------------------------------------------------------------------

loc_9EFE:
		bsr.w	sub_9F92
		bpl.s	loc_9F4E
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_9F38
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_9F38
		not.b	$29(a0)
		bne.s	loc_9F2E
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)

loc_9F2E:
		add.w	d1,obY(a0)
		move.w	$34(a0),obVelY(a0)

loc_9F38:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_9F4E
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		andi.b	#1,obFrame(a0)

loc_9F4E:
		bra.w	loc_9DB2

; =============== S U B	R O U T	I N E =======================================


sub_9F52:
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	locret_9F78
		move.b	#0,obFrame(a0)
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_9F78
		add.w	d1,obY(a0)
		move.w	$34(a0),obVelY(a0)

locret_9F78:
		rts
; End of function sub_9F52


; =============== S U B	R O U T	I N E =======================================


sub_9F7A:
		bset	#0,obRender(a0)
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		bcc.s	locret_9F90
		bclr	#0,obRender(a0)

locret_9F90:
		rts
; End of function sub_9F7A


; =============== S U B	R O U T	I N E =======================================


sub_9F92:
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		subi.w	#$B8,d0
		rts
; End of function sub_9F92

; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 29 - points that appear when you destroy something
;----------------------------------------------------

Obj29:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj29_Index(pc,d0.w),d1
		jmp	Obj29_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj29_Index:	dc.w loc_9FB2-Obj29_Index
		dc.w loc_9FE0-Obj29_Index
; ---------------------------------------------------------------------------

loc_9FB2:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj29,obMap(a0)
		move.w	#$4AC,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	#$FD00,obVelY(a0)

loc_9FE0:
		tst.w	obVelY(a0)
		bpl.w	DeleteObject
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Map_Obj28a:	dc.w word_A006-Map_Obj28a
		dc.w word_A010-Map_Obj28a
		dc.w word_9FFC-Map_Obj28a
word_9FFC:	dc.w 1
		dc.w $F406,    0,    0,$FFF8		; 0
word_A006:	dc.w 1
		dc.w $F406,    6,    3,$FFF8		; 0
word_A010:	dc.w 1
		dc.w $F406,   $C,    6,$FFF8		; 0
Map_Obj28:	dc.w word_A02A-Map_Obj28
		dc.w word_A034-Map_Obj28
		dc.w word_A020-Map_Obj28
word_A020:	dc.w 1
		dc.w $F406,    0,    0,$FFF8		; 0
word_A02A:	dc.w 1
		dc.w $FC05,    6,    3,$FFF8		; 0
word_A034:	dc.w 1
		dc.w $FC05,   $A,    5,$FFF8		; 0
Map_Obj28b:	dc.w word_A04E-Map_Obj28b
		dc.w word_A058-Map_Obj28b
		dc.w word_A044-Map_Obj28b
word_A044:	dc.w 1
		dc.w $F406,    0,    0,$FFF8		; 0
word_A04E:	dc.w 1
		dc.w $FC09,    6,    3,$FFF4		; 0
word_A058:	dc.w 1
		dc.w $FC09,   $C,    6,$FFF4		; 0
Map_Obj29:	dc.w word_A070-Map_Obj29
		dc.w word_A07A-Map_Obj29
		dc.w word_A084-Map_Obj29
		dc.w word_A08E-Map_Obj29
		dc.w word_A0A0-Map_Obj29
		dc.w word_A0AA-Map_Obj29
		dc.w word_A0BC-Map_Obj29
word_A070:	dc.w 1
		dc.w $F805,    2,    1,$FFF8		; 0
word_A07A:	dc.w 1
		dc.w $F805,    6,    3,$FFF8		; 0
word_A084:	dc.w 1
		dc.w $F805,   $A,    5,$FFF8		; 0
word_A08E:	dc.w 2
		dc.w $F801,    0,    0,$FFF8		; 0
		dc.w $F805,   $E,    7,	   0		; 4
word_A0A0:	dc.w 1
		dc.w $F801,    0,    0,$FFFC		; 0
word_A0AA:	dc.w 2
		dc.w $F805,    2,    1,$FFF0		; 0
		dc.w $F805,   $E,    7,	   0		; 4
word_A0BC:	dc.w 2
		dc.w $F805,   $A,    5,$FFF0		; 0
		dc.w $F805,   $E,    7,	   0		; 4

; ===========================================================================
		nop
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1F - Crabmeat from GHZ
; ---------------------------------------------------------------------------
; OST:
obj1F_timer:	equ $30					; time to wait for performing an action
obj1F_status:	equ $32					; 0 = moving, 1 = firing
; ---------------------------------------------------------------------------

Obj1F:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj1F_Index(pc,d0.w),d1
		jmp	Obj1F_Index(pc,d1.w)
; ===========================================================================
Obj1F_Index:	dc.w Obj1F_Init-Obj1F_Index
		dc.w Obj1F_Main-Obj1F_Index
		dc.w Obj1F_Delete-Obj1F_Index
		dc.w Obj1F_BallInit-Obj1F_Index
		dc.w Obj1F_BallMove-Obj1F_Index
; ===========================================================================
; loc_A0E8:
Obj1F_Init:
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.l	#Map_obj1F,obMap(a0)
		move.w	#$400,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#6,obColType(a0)
		move.b	#$15,obActWid(a0)
		bsr.w	ObjectMoveAndFall
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_A13E
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)

locret_A13E:
		rts
; ===========================================================================
; loc_A140:
Obj1F_Main:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj1F_Main_Index(pc,d0.w),d1
		jsr	Obj1F_Main_Index(pc,d1.w)
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj1F_Main_Index:	dc.w Obj1F_WaitMove-Obj1F_Main_Index
			dc.w Obj1F_WalkOnFloor-Obj1F_Main_Index
; ===========================================================================
; loc_A160:
Obj1F_WaitMove:
		subq.w	#1,obj1F_timer(a0)
		bpl.s	locret_A19A
		tst.b	obRender(a0)
		bpl.s	Obj1F_Move
		bchg	#1,obj1F_status(a0)
		bne.s	Obj1F_MakeFire
; loc_A174:
Obj1F_Move:
		addq.b	#2,ob2ndRout(a0)
		move.w	#$7F,obj1F_timer(a0)
		move.w	#$80,obVelX(a0)
		bsr.w	Obj1F_SetAni
		addq.b	#3,d0
		move.b	d0,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	locret_A19A
		neg.w	obVelX(a0)

locret_A19A:
		rts
; ===========================================================================
; loc_A19C:
Obj1F_MakeFire:
		move.w	#$3B,obj1F_timer(a0)
		move.b	#6,obAnim(a0)
		bsr.w	FindFreeObj
		bne.s	Obj1F_MakeFire2
		_move.b	#$1F,obID(a1)
		move.b	#6,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		subi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#-$100,obVelX(a1)
; loc_A1D2:
Obj1F_MakeFire2:
		bsr.w	FindFreeObj
		bne.s	locret_A1FC
		_move.b	#$1F,obID(a1)
		move.b	#6,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		addi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$100,obVelX(a1)

locret_A1FC:
		rts
; ===========================================================================
; loc_A1FE:
Obj1F_WalkOnFloor:
		subq.w	#1,obj1F_timer(a0)
		bmi.s	loc_A252
		bsr.w	ObjectMove
		bchg	#0,obj1F_status(a0)
		bne.s	loc_A238
		move.w	obX(a0),d3
		addi.w	#$10,d3
		btst	#0,obStatus(a0)
		beq.s	loc_A224
		subi.w	#$20,d3

loc_A224:
		jsr	(ObjHitFloor2).l
		cmpi.w	#-8,d1
		blt.s	loc_A252
		cmpi.w	#$C,d1
		bge.s	loc_A252
		rts
; ===========================================================================

loc_A238:
		jsr	(ObjHitFloor).l
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Obj1F_SetAni
		addq.b	#3,d0
		move.b	d0,obAnim(a0)
		rts
; ===========================================================================

loc_A252:
		subq.b	#2,ob2ndRout(a0)
		move.w	#$3B,obj1F_timer(a0)
		move.w	#0,obVelX(a0)
		bsr.w	Obj1F_SetAni
		move.b	d0,obAnim(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine to	set the	correct	animation for a	Crabmeat
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_A26C:
Obj1F_SetAni:
		moveq	#0,d0
		move.b	obAngle(a0),d3
		bmi.s	loc_A288
		cmpi.b	#6,d3
		bcs.s	locret_A286
		moveq	#1,d0
		btst	#0,obStatus(a0)
		bne.s	locret_A286
		moveq	#2,d0

locret_A286:
		rts
; ===========================================================================

loc_A288:
		cmpi.b	#-6,d3
		bhi.s	locret_A29A
		moveq	#2,d0
		btst	#0,obStatus(a0)
		bne.s	locret_A29A
		moveq	#1,d0

locret_A29A:
		rts
; End of function Obj1F_SetAni

; ===========================================================================
; loc_A29C:
Obj1F_Delete:
		bra.w	DeleteObject
; ===========================================================================
; loc_A2A0:
Obj1F_BallInit:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj1F,obMap(a0)
		move.w	#$400,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#$87,obColType(a0)
		move.b	#8,obActWid(a0)
		move.w	#$FC00,obVelY(a0)
		move.b	#7,obAnim(a0)
; loc_A2DA:
Obj1F_BallMove:
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectMoveAndFall
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		bcs.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
; animation script
Ani_obj1F:	dc.w byte_A30C-Ani_obj1F
		dc.w byte_A30F-Ani_obj1F
		dc.w byte_A312-Ani_obj1F
		dc.w byte_A315-Ani_obj1F
		dc.w byte_A31A-Ani_obj1F
		dc.w byte_A31F-Ani_obj1F
		dc.w byte_A324-Ani_obj1F
		dc.w byte_A327-Ani_obj1F
byte_A30C:	dc.b  $F,  0,$FF
byte_A30F:	dc.b  $F,  2,$FF
byte_A312:	dc.b  $F,$22,$FF
byte_A315:	dc.b  $F,  1,$21,  0,$FF
byte_A31A:	dc.b  $F,$21,  3,  2,$FF
byte_A31F:	dc.b  $F,  1,$23,$22,$FF
byte_A324:	dc.b  $F,  4,$FF
byte_A327:	dc.b   1,  5,  6,$FF,  0

; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj1F:	binclude	"mappings/sprite/obj1F.bin"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 22 - Buzz Bomber from GHZ
; ---------------------------------------------------------------------------
; OST:
obj22_time:	equ $32					; time to wait for performing an action
obj22_status:	equ $34					; 0 = still, 1 = flying, 2 = shooting
obj22_parent:	equ $3C
; ---------------------------------------------------------------------------

Obj22:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj22_Index(pc,d0.w),d1
		jmp	Obj22_Index(pc,d1.w)
; ===========================================================================
Obj22_Index:	dc.w Obj22_Init-Obj22_Index
		dc.w Obj22_Main-Obj22_Index
		dc.w Obj22_Delete-Obj22_Index
; ===========================================================================
; loc_A41C:
Obj22_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj22,obMap(a0)
		move.w	#$444,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#8,obColType(a0)
		move.b	#$18,obActWid(a0)
; loc_A44A:
Obj22_Main:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj22_Main_Index(pc,d0.w),d1
		jsr	Obj22_Main_Index(pc,d1.w)
		lea	(Ani_obj22).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj22_Main_Index:	dc.w Obj22_Move-Obj22_Main_Index
			dc.w Obj22_NearSonic-Obj22_Main_Index
; ===========================================================================
; loc_A46A:
Obj22_Move:
		subq.w	#1,obj22_time(a0)
		bpl.s	locret_A49A
		btst	#1,obj22_status(a0)
		bne.s	Obj22_LoadMissile
		addq.b	#2,ob2ndRout(a0)
		move.w	#$7F,obj22_time(a0)
		move.w	#$400,obVelX(a0)
		move.b	#1,obAnim(a0)
		btst	#0,obStatus(a0)
		bne.s	locret_A49A
		neg.w	obVelX(a0)

locret_A49A:
		rts
; ===========================================================================
; loc_A49C:
Obj22_LoadMissile:
		bsr.w	FindFreeObj
		bne.s	locret_A4FE
		_move.b	#$23,obID(a1)			; load Obj23 (Buzz Bomber/Newtron missile)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$1C,obY(a1)
		move.w	#$200,obVelY(a1)
		move.w	#$200,obVelX(a1)
		move.w	#$18,d0
		btst	#0,obStatus(a0)
		bne.s	loc_A4D8
		neg.w	d0
		neg.w	obVelX(a1)

loc_A4D8:
		add.w	d0,obX(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.w	#$E,obj22_time(a1)
		move.l	a0,obj22_parent(a1)
		move.b	#1,obj22_status(a0)
		move.w	#$3B,obj22_time(a0)
		move.b	#2,obAnim(a0)

locret_A4FE:
		rts
; ===========================================================================
; loc_A500:
Obj22_NearSonic:
		subq.w	#1,obj22_time(a0)
		bmi.s	loc_A536
		bsr.w	ObjectMove
		tst.b	obj22_status(a0)
		bne.s	locret_A558
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	loc_A51C
		neg.w	d0

loc_A51C:
		cmpi.w	#$60,d0				; is Buzz Bomber within $60 pixels of Sonic?
		bcc.s	locret_A558			; if not, branch
		tst.b	obRender(a0)
		bpl.s	locret_A558
		move.b	#2,obj22_status(a0)
		move.w	#$1D,obj22_time(a0)
		bra.s	loc_A548
; ===========================================================================

loc_A536:
		move.b	#0,obj22_status(a0)
		bchg	#0,obStatus(a0)
		move.w	#$3B,obj22_time(a0)

loc_A548:
		subq.b	#2,ob2ndRout(a0)
		move.w	#0,obVelX(a0)
		move.b	#0,obAnim(a0)

locret_A558:
		rts
; ===========================================================================
; loc_A55A:
Obj22_Delete:
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 23 - Buzz Bomber/Newtron missile
; ---------------------------------------------------------------------------
; OST:
obj23_parent:	equ $3C
; ---------------------------------------------------------------------------

Obj23:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj23_Index(pc,d0.w),d1
		jmp	Obj23_Index(pc,d1.w)
; ===========================================================================
Obj23_Index:	dc.w Obj23_Init-Obj23_Index
		dc.w Obj23_Animate-Obj23_Index
		dc.w Obj23_Move-Obj23_Index
		dc.w Obj23_Delete-Obj23_Index
		dc.w Obj23_Newtron-Obj23_Index
; ===========================================================================
; loc_A576:
Obj23_Init:
		subq.w	#1,$32(a0)
		bpl.s	Obj23_ChkDel
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj23,obMap(a0)
		move.w	#$2444,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#8,obActWid(a0)
		andi.b	#3,obStatus(a0)
		tst.b	obSubtype(a0)			; was the object created by a Newtron?
		beq.s	Obj23_Animate			; if not, branch

		move.b	#8,obRoutine(a0)
		move.b	#$87,obColType(a0)
		move.b	#1,obAnim(a0)
		bra.s	Obj23_Animate2
; ===========================================================================
; loc_A5C4:
Obj23_Animate:
		movea.l	obj23_parent(a0),a1
		_cmpi.b	#$27,obID(a1)			; is Buzz Bomber destroyed?
		beq.s	Obj23_Delete			; if yes, branch
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	check if the Buzz Bomber which fired the missile has been
; destroyed, and if it has, deletes the missile
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; loc_A5DE:
Obj23_ChkDel:
		movea.l	obj23_parent(a0),a1
		_cmpi.b	#$27,obID(a1)			; is Buzz Bomber destroyed?
		beq.s	Obj23_Delete			; if yes, branch
		rts
; End of function Obj23_ChkDel

; ===========================================================================
; loc_A5EC:
Obj23_Move:
		btst	#7,obStatus(a0)			; has the missile collided with the level? (flag never set)
		bne.s	Obj23_Explode			; if yes, branch
		move.b	#$87,obColType(a0)
		move.b	#1,obAnim(a0)
		bsr.w	ObjectMove
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		bcs.s	Obj23_Delete
		bra.w	DisplaySprite
; ===========================================================================
; loc_A620:
Obj23_Explode:
		_move.b	#$24,obID(a0)			; load Obj24 (unused Buzz Bomber missile explosion)
		move.b	#0,obRoutine(a0)
		bra.w	Obj24
; ===========================================================================
; loc_A630:
Obj23_Delete:
		bra.w	DeleteObject
; ===========================================================================
; loc_A634:
Obj23_Newtron:
		tst.b	obRender(a0)
		bpl.s	Obj23_Delete
		bsr.w	ObjectMove
; loc_A63E:
Obj23_Animate2:
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
; animation script
Ani_obj22:	dc.w byte_A652-Ani_obj22
		dc.w byte_A656-Ani_obj22
		dc.w byte_A65A-Ani_obj22
byte_A652:	dc.b   1,  0,  1,$FF
byte_A656:	dc.b   1,  2,  3,$FF
byte_A65A:	dc.b   1,  4,  5,$FF

Ani_obj23:	dc.w byte_A662-Ani_obj23
		dc.w byte_A666-Ani_obj23
byte_A662:	dc.b   7,  0,  1,$FC
byte_A666:	dc.b   1,  2,  3,$FF

; ---------------------------------------------------------------------------
; sprite mappings - Buzz Bomber
; ---------------------------------------------------------------------------
Map_obj22:	binclude	"mappings/sprite/obj22.bin"

; ---------------------------------------------------------------------------
; sprite mappings - Buzz Bomber missile
; ---------------------------------------------------------------------------
Map_obj23:	binclude	"mappings/sprite/obj23.bin"

; ===========================================================================
		nop
; ===========================================================================
;----------------------------------------------------------------------------
; Object 25 - Rings
;----------------------------------------------------------------------------

Obj25:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj25_Index(pc,d0.w),d1
		jmp	Obj25_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj25_Index:	dc.w loc_A81C-Obj25_Index
		dc.w loc_A88A-Obj25_Index
		dc.w loc_A8A6-Obj25_Index
		dc.w loc_A8CC-Obj25_Index
		dc.w loc_A8DA-Obj25_Index
		dc.b $10,  0,$18,  0			; 0
		dc.b $20,  0,  0,$10			; 4
		dc.b   0,$18,  0,$20			; 8
		dc.b $10,$10,$18,$18			; 12
		dc.b $20,$20,$F0,$10			; 16
		dc.b $E8,$18,$E0,$20			; 20
		dc.b $10,  8,$18,$10			; 24
		dc.b $F0,  8,$E8,$10			; 28
; ---------------------------------------------------------------------------

loc_A81C:
		movea.l	a0,a1
		moveq	#0,d1
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		bra.s	loc_A832
; ---------------------------------------------------------------------------

loc_A82A:
		swap	d1
		bsr.w	FindFreeObj
		bne.s	loc_A88A

loc_A832:
		_move.b	#$25,obID(a1)
		addq.b	#2,obRoutine(a1)
		move.w	d2,obX(a1)
		move.w	obX(a0),$32(a1)
		move.w	d3,obY(a1)
		move.l	#Map_Obj25,obMap(a1)
		move.w	#$26BC,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#4,obRender(a1)
		move.b	#2,obPriority(a1)
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.b	obRespawnNo(a0),obRespawnNo(a1)
		move.b	d1,$34(a1)
		addq.w	#1,d1
		add.w	d5,d2
		add.w	d6,d3
		swap	d1
		dbf	d1,loc_A82A

loc_A88A:
		move.b	(v_ani1_frame).w,obFrame(a0)
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_A8DA
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_A8A6:
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		move.b	#1,obPriority(a0)
		bsr.w	sub_A8DE
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		move.b	$34(a0),d1
		bset	d1,2(a2,d0.w)

loc_A8CC:
		lea	(Ani_Obj25).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_A8DA:
		bra.w	DeleteObject

; =============== S U B	R O U T	I N E =======================================


sub_A8DE:
		addq.w	#1,(v_rings).w
		ori.b	#1,(f_ringcount).w
		move.w	#sfx_Ring,d0
		cmpi.w	#$64,(v_rings).w
		bcs.s	loc_A918
		bset	#1,(v_lifecount).w
		beq.s	loc_A90C
		cmpi.w	#$C8,(v_rings).w
		bcs.s	loc_A918
		bset	#2,(v_lifecount).w
		bne.s	loc_A918

loc_A90C:
		addq.b	#1,(v_lives).w
		addq.b	#1,(f_lifecount).w
		move.w	#bgm_ExtraLife,d0

loc_A918:
		jmp	(PlaySound_Special).l
; End of function sub_A8DE

; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 37 - Rings flying out of you when you get hit
;----------------------------------------------------

Obj37:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj37_Index(pc,d0.w),d1
		jmp	Obj37_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj37_Index:	dc.w loc_A936-Obj37_Index
		dc.w loc_A9FA-Obj37_Index
		dc.w loc_AA4C-Obj37_Index
		dc.w loc_AA60-Obj37_Index
		dc.w loc_AA6E-Obj37_Index
; ---------------------------------------------------------------------------

loc_A936:
		movea.l	a0,a1
		moveq	#0,d5
		move.w	(v_rings).w,d5
		moveq	#$20,d0
		cmp.w	d0,d5
		bcs.s	loc_A946
		move.w	d0,d5

loc_A946:
		subq.w	#1,d5
		move.w	#$288,d4
		bra.s	loc_A956
; ---------------------------------------------------------------------------

loc_A94E:
		bsr.w	FindFreeObj
		bne.w	loc_A9DE

loc_A956:
		_move.b	#$37,obID(a1)
		addq.b	#2,obRoutine(a1)
		move.b	#8,obHeight(a1)
		move.b	#8,obWidth(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Obj25,obMap(a1)
		move.w	#$26BC,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#4,obRender(a1)
		move.b	#3,obPriority(a1)
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.b	#-1,(v_ani3_time).w
		tst.w	d4
		bmi.s	loc_A9CE
		move.w	d4,d0
		bsr.w	CalcSine
		move.w	d4,d2
		lsr.w	#8,d2
		asl.w	d2,d0
		asl.w	d2,d1
		move.w	d0,d2
		move.w	d1,d3
		addi.b	#$10,d4
		bcc.s	loc_A9CE
		subi.w	#$80,d4
		bcc.s	loc_A9CE
		move.w	#$288,d4

loc_A9CE:
		move.w	d2,obVelX(a1)
		move.w	d3,obVelY(a1)
		neg.w	d2
		neg.w	d4
		dbf	d5,loc_A94E

loc_A9DE:
		move.w	#0,(v_rings).w
		move.b	#$80,(f_ringcount).w
		move.b	#0,(v_lifecount).w
		move.w	#sfx_RingLoss,d0
		jsr	(PlaySound_Special).l

loc_A9FA:
		move.b	(v_ani3_frame).w,obFrame(a0)
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		bmi.s	loc_AA34
		move.b	($FFFFFE0F).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	loc_AA34
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_AA34
		add.w	d1,obY(a0)
		move.w	obVelY(a0),d0
		asr.w	#2,d0
		sub.w	d0,obVelY(a0)
		neg.w	obVelY(a0)

loc_AA34:
		tst.b	(v_ani3_time).w
		beq.s	loc_AA6E
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		bcs.s	loc_AA6E
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_AA4C:
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		move.b	#1,obPriority(a0)
		bsr.w	sub_A8DE

loc_AA60:
		lea	(Ani_Obj25).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_AA6E:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Sonic	1 Object 4B - leftover giant ring code
;----------------------------------------------------

S1Obj4B:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj4B_Index(pc,d0.w),d1
		jmp	S1Obj4B_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj4B_Index:	dc.w loc_AA88-S1Obj4B_Index
		dc.w loc_AAD6-S1Obj4B_Index
		dc.w loc_AAF4-S1Obj4B_Index
		dc.w loc_AB38-S1Obj4B_Index
; ---------------------------------------------------------------------------

loc_AA88:
		move.l	#Map_S1Obj4B,obMap(a0)
		move.w	#$2400,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#$40,obActWid(a0)
		tst.b	obRender(a0)
		bpl.s	loc_AAD6
		cmpi.b	#6,(v_emeralds).w
		beq.w	loc_AB38
		cmpi.w	#$32,(v_rings).w
		bcc.s	loc_AAC0
		rts
; ---------------------------------------------------------------------------

loc_AAC0:
		addq.b	#2,obRoutine(a0)
		move.b	#2,obPriority(a0)
		move.b	#$52,obColType(a0)
		move.w	#$C40,(v_gfxbigring).w

loc_AAD6:
		move.b	(v_ani1_frame).w,obFrame(a0)
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_AAF4:
		subq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.w	loc_AB2C
		_move.b	#$7C,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	a0,$3C(a1)
		move.w	(v_objspace+obX).w,d0
		cmp.w	obX(a0),d0
		bcs.s	loc_AB2C
		bset	#0,obRender(a1)

loc_AB2C:
		move.w	#sfx_GiantRing,d0
		jsr	(PlaySound_Special).l
		bra.s	loc_AAD6
; ---------------------------------------------------------------------------

loc_AB38:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Sonic	1 Object 7C - leftover giant flash when	you
;   collected the giant	ring
;----------------------------------------------------

Obj_S1Obj7C:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj_S1Obj7C_Index(pc,d0.w),d1
		jmp	Obj_S1Obj7C_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj_S1Obj7C_Index:dc.w loc_AB50-Obj_S1Obj7C_Index
		dc.w loc_AB7E-Obj_S1Obj7C_Index
		dc.w loc_ABE6-Obj_S1Obj7C_Index
; ---------------------------------------------------------------------------

loc_AB50:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_S1Obj7C,obMap(a0)
		move.w	#$2462,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#0,obPriority(a0)
		move.b	#$20,obActWid(a0)
		move.b	#$FF,obFrame(a0)

loc_AB7E:
		bsr.s	sub_AB98
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite

; =============== S U B	R O U T	I N E =======================================


sub_AB98:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_ABD6
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#8,obFrame(a0)
		bcc.s	loc_ABD8
		cmpi.b	#3,obFrame(a0)
		bne.s	locret_ABD6
		movea.l	$3C(a0),a1
		move.b	#6,obRoutine(a1)
		move.b	#$1C,(v_objspace+$1C).w
		move.b	#1,(f_bigring).w
		clr.b	(v_invinc).w
		clr.b	(v_shield).w

locret_ABD6:
		rts
; ---------------------------------------------------------------------------

loc_ABD8:
		addq.b	#2,obRoutine(a0)
		move.w	#0,(v_objspace).w
		addq.l	#4,sp
		rts
; End of function sub_AB98

; ---------------------------------------------------------------------------

loc_ABE6:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------
Ani_Obj25:	dc.w byte_ABEC-Ani_Obj25
byte_ABEC:	dc.b   5,  4,  5,  6,  7,$FC		; 0
; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_Obj25:	binclude	"mappings/sprite/obj37_a.bin"
		even

Map_S1Obj4B:	dc.w word_AC5E-Map_S1Obj4B
		dc.w word_ACB0-Map_S1Obj4B
		dc.w word_ACF2-Map_S1Obj4B
		dc.w word_AD14-Map_S1Obj4B
word_AC5E:	dc.w $A
		dc.w $E008,    0,    0,$FFE8		; 0
		dc.w $E008,    3,    1,	   0		; 4
		dc.w $E80C,    6,    3,$FFE0		; 8
		dc.w $E80C,   $A,    5,	   0		; 12
		dc.w $F007,   $E,    7,$FFE0		; 16
		dc.w $F007,  $16,   $B,	 $10		; 20
		dc.w $100C,  $1E,   $F,$FFE0		; 24
		dc.w $100C,  $22,  $11,	   0		; 28
		dc.w $1808,  $26,  $13,$FFE8		; 32
		dc.w $1808,  $29,  $14,	   0		; 36
word_ACB0:	dc.w 8
		dc.w $E00C,  $2C,  $16,$FFF0		; 0
		dc.w $E808,  $30,  $18,$FFE8		; 4
		dc.w $E809,  $33,  $19,	   0		; 8
		dc.w $F007,  $39,  $1C,$FFE8		; 12
		dc.w $F805,  $41,  $20,	   8		; 16
		dc.w  $809,  $45,  $22,	   0		; 20
		dc.w $1008,  $4B,  $25,$FFE8		; 24
		dc.w $180C,  $4E,  $27,$FFF0		; 28
word_ACF2:	dc.w 4
		dc.w $E007,  $52,  $29,$FFF4		; 0
		dc.w $E003, $852, $829,	   4		; 4
		dc.w	 7,  $5A,  $2D,$FFF4		; 8
		dc.w	 3, $85A, $82D,	   4		; 12
word_AD14:	dc.w 8
		dc.w $E00C, $82C, $816,$FFF0		; 0
		dc.w $E808, $830, $818,	   0		; 4
		dc.w $E809, $833, $819,$FFE8		; 8
		dc.w $F007, $839, $81C,	   8		; 12
		dc.w $F805, $841, $820,$FFE8		; 16
		dc.w  $809, $845, $822,$FFE8		; 20
		dc.w $1008, $84B, $825,	   0		; 24
		dc.w $180C, $84E, $827,$FFF0		; 28
Map_S1Obj7C:	dc.w word_AD66-Map_S1Obj7C
		dc.w word_AD78-Map_S1Obj7C
		dc.w word_AD9A-Map_S1Obj7C
		dc.w word_ADBC-Map_S1Obj7C
		dc.w word_ADDE-Map_S1Obj7C
		dc.w word_AE00-Map_S1Obj7C
		dc.w word_AE22-Map_S1Obj7C
		dc.w word_AE34-Map_S1Obj7C
word_AD66:	dc.w 2
		dc.w $E00F,    0,    0,	   0		; 0
		dc.w	$F,$1000,$1000,	   0		; 4
word_AD78:	dc.w 4
		dc.w $E00F,  $10,    8,$FFF0		; 0
		dc.w $E007,  $20,  $10,	 $10		; 4
		dc.w	$F,$1010,$1008,$FFF0		; 8
		dc.w	 7,$1020,$1010,	 $10		; 12
word_AD9A:	dc.w 4
		dc.w $E00F,  $28,  $14,$FFE8		; 0
		dc.w $E00B,  $38,  $1C,	   8		; 4
		dc.w	$F,$1028,$1014,$FFE8		; 8
		dc.w	$B,$1038,$101C,	   8		; 12
word_ADBC:	dc.w 4
		dc.w $E00F, $834, $81A,$FFE0		; 0
		dc.w $E00F,  $34,  $1A,	   0		; 4
		dc.w	$F,$1834,$181A,$FFE0		; 8
		dc.w	$F,$1034,$101A,	   0		; 12
word_ADDE:	dc.w 4
		dc.w $E00B, $838, $81C,$FFE0		; 0
		dc.w $E00F, $828, $814,$FFF8		; 4
		dc.w	$B,$1838,$181C,$FFE0		; 8
		dc.w	$F,$1828,$1814,$FFF8		; 12
word_AE00:	dc.w 4
		dc.w $E007, $820, $810,$FFE0		; 0
		dc.w $E00F, $810, $808,$FFF0		; 4
		dc.w	 7,$1820,$1810,$FFE0		; 8
		dc.w	$F,$1810,$1808,$FFF0		; 12
word_AE22:	dc.w 2
		dc.w $E00F, $800, $800,$FFE0		; 0
		dc.w	$F,$1800,$1800,$FFE0		; 4
word_AE34:	dc.w 4
		dc.w $E00F,  $44,  $22,$FFE0		; 0
		dc.w $E00F, $844, $822,	   0		; 4
		dc.w	$F,$1044,$1022,$FFE0		; 8
		dc.w	$F,$1844,$1822,	   0		; 12
; ---------------------------------------------------------------------------
		nop
;----------------------------------------------------
; Object 26 - monitor
;----------------------------------------------------

Obj26:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj26_Index(pc,d0.w),d1
		jmp	Obj26_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj26_Index:	dc.w loc_AE70-Obj26_Index
		dc.w loc_AED6-Obj26_Index
		dc.w loc_AFDC-Obj26_Index
		dc.w loc_AFBA-Obj26_Index
		dc.w loc_AFC4-Obj26_Index
; ---------------------------------------------------------------------------

loc_AE70:
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#$E,obWidth(a0)
		move.l	#Map_Obj26,obMap(a0)
		move.w	#$680,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#$F,obActWid(a0)
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
		beq.s	loc_AECA
		move.b	#8,obRoutine(a0)
		move.b	#$B,obFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_AECA:
		move.b	#$46,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)

loc_AED6:
		move.b	ob2ndRout(a0),d0
		beq.s	loc_AF30
		subq.b	#2,d0
		bne.s	loc_AF10
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		bsr.w	sub_F9C8
		btst	#3,obStatus(a1)
		bne.w	loc_AF00
		clr.b	ob2ndRout(a0)
		bra.w	loc_AFBA
; ---------------------------------------------------------------------------

loc_AF00:
		move.w	#$10,d3
		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	loc_AFBA
; ---------------------------------------------------------------------------

loc_AF10:
		bsr.w	ObjectMoveAndFall
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.w	loc_AFBA
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)
		bra.w	loc_AFBA
; ---------------------------------------------------------------------------

loc_AF30:
		move.w	#$1A,d1
		move.w	#$F,d2
		bsr.w	Obj26_SolidSides
		beq.w	loc_AFA0
		tst.w	obVelY(a1)
		bmi.s	loc_AF4E
		cmpi.b	#2,obAnim(a1)
		beq.s	loc_AFA0

loc_AF4E:
		tst.w	d1
		bpl.s	loc_AF64
		sub.w	d3,obY(a1)
		bsr.w	RideObject_SetRide
		move.b	#2,ob2ndRout(a0)
		bra.w	loc_AFBA
; ---------------------------------------------------------------------------

loc_AF64:
		tst.w	d0
		beq.w	loc_AF8A
		bmi.s	loc_AF74
		tst.w	obVelX(a1)
		bmi.s	loc_AF8A
		bra.s	loc_AF7A
; ---------------------------------------------------------------------------

loc_AF74:
		tst.w	obVelX(a1)
		bpl.s	loc_AF8A

loc_AF7A:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_AF8A:
		btst	#1,obStatus(a1)
		bne.s	loc_AFAE
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
		bra.s	loc_AFBA
; ---------------------------------------------------------------------------

loc_AFA0:
		btst	#5,obStatus(a0)
		beq.s	loc_AFBA
		move.w	#1,obAnim(a1)

loc_AFAE:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

loc_AFBA:
		lea	(Ani_obj26).l,a1
		bsr.w	AnimateSprite

loc_AFC4:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_AFDC:
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.s	loc_B004
		_move.b	#$2E,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obAnim(a0),obAnim(a1)

loc_B004:
		bsr.w	FindFreeObj
		bne.s	loc_B020
		_move.b	#$27,obID(a1)
		addq.b	#2,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

loc_B020:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	#0,2(a2,d0.w)
		move.b	#$A,obAnim(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 2E - monitor contents (code for power-up behavior and rising image)
;----------------------------------------------------

Obj2E:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj2E_Index(pc,d0.w),d1
		jmp	Obj2E_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj2E_Index:	dc.w loc_B04E-Obj2E_Index
		dc.w loc_B092-Obj2E_Index
		dc.w loc_B1AA-Obj2E_Index
; ---------------------------------------------------------------------------

loc_B04E:
		addq.b	#2,obRoutine(a0)
		move.w	#$680,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#$24,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	#-$300,obVelY(a0)
		moveq	#0,d0
		move.b	obAnim(a0),d0
		addq.b	#1,d0
		move.b	d0,obFrame(a0)
		movea.l	#Map_Obj26,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#2,a1
		move.l	a1,obMap(a0)

loc_B092:
		bsr.s	sub_B098
		bra.w	DisplaySprite

; =============== S U B	R O U T	I N E =======================================


sub_B098:
		tst.w	obVelY(a0)
		bpl.w	loc_B0AC
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_B0AC:
		addq.b	#2,obRoutine(a0)
		move.w	#$1D,obTimeFrame(a0)
		moveq	#0,d0
		move.b	obAnim(a0),d0
		add.w	d0,d0
		move.w	Monitor_Subroutines(pc,d0.w),d0
		jmp	Monitor_Subroutines(pc,d0.w)
; End of function sub_B098

; ---------------------------------------------------------------------------
Monitor_Subroutines:dc.w Monitor_Null-Monitor_Subroutines
		dc.w Monitor_SonicLife-Monitor_Subroutines
		dc.w Monitor_TailsLife-Monitor_Subroutines
		dc.w Monitor_Null-Monitor_Subroutines
		dc.w Monitor_Rings-Monitor_Subroutines
		dc.w Monitor_Shoes-Monitor_Subroutines
		dc.w Monitor_Shield-Monitor_Subroutines
		dc.w Monitor_Invincibility-Monitor_Subroutines
		dc.w Monitor_Null-Monitor_Subroutines
		dc.w Monitor_Null-Monitor_Subroutines
; ---------------------------------------------------------------------------

Monitor_Null:
		rts
; ---------------------------------------------------------------------------

Monitor_SonicLife:
		addq.b	#1,(v_lives).w
		addq.b	#1,(f_lifecount).w
		move.w	#bgm_ExtraLife,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------

Monitor_TailsLife:
		addq.b	#1,(v_lives).w
		addq.b	#1,(f_lifecount).w
		move.w	#bgm_ExtraLife,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------

Monitor_Rings:
		addi.w	#10,(v_rings).w
		ori.b	#1,(f_ringcount).w
		cmpi.w	#$64,(v_rings).w
		bcs.s	loc_B130
		bset	#1,(v_lifecount).w
		beq.w	Monitor_SonicLife
		cmpi.w	#$C8,(v_rings).w
		bcs.s	loc_B130
		bset	#2,(v_lifecount).w
		beq.w	Monitor_SonicLife

loc_B130:
		move.w	#sfx_Ring,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------

Monitor_Shoes:
		move.b	#1,(v_shoes).w
		move.w	#$4B0,(v_objspace+$34).w
		move.w	#$C00,(Sonic_top_speed).w
		move.w	#$18,(Sonic_acceleration).w
		move.w	#$80,(Sonic_deceleration).w
		move.w	#bgm_Speedup,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------

Monitor_Shield:
		move.b	#1,(v_shield).w
		move.b	#$38,(v_objspace+$180).w
		move.w	#sfx_Shield,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------

Monitor_Invincibility:
		move.b	#1,(v_invinc).w
		move.w	#$4B0,(v_objspace+$32).w
		move.b	#$38,(v_objspace+$200).w
		move.b	#1,(v_objspace+$21C).w
		tst.b	(f_lockscreen).w
		bne.s	locret_B1A8
		cmpi.w	#$C,(v_air).w
		bls.s	locret_B1A8
		move.w	#bgm_Invincible,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------

locret_B1A8:
		rts
; ---------------------------------------------------------------------------

loc_B1AA:
		subq.w	#1,obTimeFrame(a0)
		bmi.w	DeleteObject
		bra.w	DisplaySprite

; =============== S U B	R O U T	I N E =======================================


Obj26_SolidSides:
		lea	(v_objspace).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_B20E
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_B20E
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	obY(a0),d3
		add.w	d2,d3
		bmi.s	loc_B20E
		add.w	d2,d2
		cmp.w	d2,d3
		bcc.s	loc_B20E
		tst.b	(f_playerctrl).w
		bmi.s	loc_B20E
		cmpi.b	#6,(v_objspace+obRoutine).w
		bcc.s	loc_B20E
		tst.w	(Debug_placement_mode).w
		bne.s	loc_B20E
		cmp.w	d0,d1
		bcc.s	loc_B204
		add.w	d1,d1
		sub.w	d1,d0

loc_B204:
		cmpi.w	#$10,d3
		bcs.s	loc_B212

loc_B20A:
		moveq	#1,d1
		rts
; ---------------------------------------------------------------------------

loc_B20E:
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

loc_B212:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addq.w	#4,d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	loc_B20A
		cmp.w	d2,d1
		bcc.s	loc_B20A
		moveq	#-1,d1
		rts
; End of function Obj26_SolidSides

; ===========================================================================
; animation script
Ani_obj26:	dc.w byte_B246-Ani_obj26
		dc.w byte_B24A-Ani_obj26
		dc.w byte_B252-Ani_obj26
		dc.w byte_B25A-Ani_obj26
		dc.w byte_B262-Ani_obj26
		dc.w byte_B26A-Ani_obj26
		dc.w byte_B272-Ani_obj26
		dc.w byte_B27A-Ani_obj26
		dc.w byte_B282-Ani_obj26
		dc.w byte_B28A-Ani_obj26
		dc.w byte_B292-Ani_obj26
byte_B246:	dc.b   1,  0,  1,$FF
byte_B24A:	dc.b   1,  0,  2,  2,  1,  2,  2,$FF
byte_B252:	dc.b   1,  0,  3,  3,  1,  3,  3,$FF
byte_B25A:	dc.b   1,  0,  4,  4,  1,  4,  4,$FF
byte_B262:	dc.b   1,  0,  5,  5,  1,  5,  5,$FF
byte_B26A:	dc.b   1,  0,  6,  6,  1,  6,  6,$FF
byte_B272:	dc.b   1,  0,  7,  7,  1,  7,  7,$FF
byte_B27A:	dc.b   1,  0,  8,  8,  1,  8,  8,$FF
byte_B282:	dc.b   1,  0,  9,  9,  1,  9,  9,$FF
byte_B28A:	dc.b   1,  0, $A, $A,  1, $A, $A,$FF
byte_B292:	dc.b   2,  0,  1, $B,$FE,  1

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_Obj26:	binclude	"mappings/sprite/obj26.bin"
		even

; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 0E - Sonic and Tails from the title screen
;----------------------------------------------------

Obj0E:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj0E_Index(pc,d0.w),d1
		jmp	Obj0E_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj0E_Index:	dc.w loc_B38E-Obj0E_Index
		dc.w loc_B3D0-Obj0E_Index
		dc.w loc_B3E4-Obj0E_Index
		dc.w loc_B3FA-Obj0E_Index
; ---------------------------------------------------------------------------

loc_B38E:
		addq.b	#2,obRoutine(a0)
		move.w	#$148,obX(a0)
		move.w	#$C4,obScreenY(a0)
		move.l	#Map_Obj0E,obMap(a0)
		move.w	#$4200,obGfx(a0)
		move.b	#1,obPriority(a0)
		move.b	#$1D,obDelayAni(a0)
		tst.b	obFrame(a0)
		beq.s	loc_B3D0
		move.w	#$FC,obX(a0)
		move.w	#$CC,obScreenY(a0)
		move.w	#$2200,obGfx(a0)

loc_B3D0:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
		subq.b	#1,obDelayAni(a0)
		bpl.s	locret_B3E2
		addq.b	#2,obRoutine(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

locret_B3E2:
		rts
; ---------------------------------------------------------------------------

loc_B3E4:
		subi.w	#8,obScreenY(a0)
		cmpi.w	#$96,obScreenY(a0)
		bne.s	loc_B3F6
		addq.b	#2,obRoutine(a0)

loc_B3F6:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_B3FA:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0F - Mappings test?
; ---------------------------------------------------------------------------

Obj0F:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj0F_Index(pc,d0.w),d1
		jsr	Obj0F_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj0F_Index:	dc.w loc_B416-Obj0F_Index
		dc.w loc_B438-Obj0F_Index
		dc.w loc_B438-Obj0F_Index
; ===========================================================================

loc_B416:
		addq.b	#2,obRoutine(a0)
		move.w	#$90,obX(a0)
		move.w	#$90,$A(a0)
		move.l	#Map_Obj0F,obMap(a0)
		move.w	#$680,obGfx(a0)
		bsr.w	Adjust2PArtPointer

loc_B438:
		move.b	(v_jpadpress1).w,d0
		btst	#5,d0				; has C been pressed?
		beq.s	loc_B44C			; if not, branch
		addq.b	#1,obFrame(a0)			; increment mappings
		andi.b	#$F,obFrame(a0)			; if above $F, reset

loc_B44C:
		btst	#4,d0				; has B been pressed?
		beq.s	locret_B458			; if not, branch
		bchg	#0,(unk_FFFFFFE9).w		; this crashes the game

locret_B458:
		rts
; ---------------------------------------------------------------------------
Map_Obj0F:	dc.w word_B47A-Map_Obj0F
		dc.w word_B484-Map_Obj0F
		dc.w word_B48E-Map_Obj0F
		dc.w word_B498-Map_Obj0F
		dc.w word_B4A2-Map_Obj0F
		dc.w word_B4AC-Map_Obj0F
		dc.w word_B4B6-Map_Obj0F
		dc.w word_B4C0-Map_Obj0F
		dc.w word_B4CA-Map_Obj0F
		dc.w word_B4D4-Map_Obj0F
		dc.w word_B4DE-Map_Obj0F
		dc.w word_B4E8-Map_Obj0F
		dc.w word_B4F2-Map_Obj0F
		dc.w word_B4FC-Map_Obj0F
		dc.w word_B506-Map_Obj0F
		dc.w word_B510-Map_Obj0F
word_B47A:	dc.w 1
		dc.w	 0,    0,    0,	   0		; 0
word_B484:	dc.w 1
		dc.w	 1,    0,    0,	   0		; 0
word_B48E:	dc.w 1
		dc.w	 2,    0,    0,	   0		; 0
word_B498:	dc.w 1
		dc.w	 3,    0,    0,	   0		; 0
word_B4A2:	dc.w 1
		dc.w	 4,    0,    0,	   0		; 0
word_B4AC:	dc.w 1
		dc.w	 5,    0,    0,	   0		; 0
word_B4B6:	dc.w 1
		dc.w	 6,    0,    0,	   0		; 0
word_B4C0:	dc.w 1
		dc.w	 7,    0,    0,	   0		; 0
word_B4CA:	dc.w 1
		dc.w	 8,    0,    0,	   0		; 0
word_B4D4:	dc.w 1
		dc.w	 9,    0,    0,	   0		; 0
word_B4DE:	dc.w 1
		dc.w	$A,    0,    0,	   0		; 0
word_B4E8:	dc.w 1
		dc.w	$B,    0,    0,	   0		; 0
word_B4F2:	dc.w 1
		dc.b   0, $C,  0,  0			; 0
		dc.b   0,  0,  0,  0			; 4
word_B4FC:	dc.w 1
		dc.b   0, $D,  0,  0			; 0
		dc.b   0,  0,  0,  0			; 4
word_B506:	dc.w 1
		dc.w	$E,    0,    0,	   0		; 0
word_B510:	dc.w 1
		dc.w	$F,    0,    0,	   0		; 0
off_B51A:	dc.w byte_B51C-off_B51A
byte_B51C:	dc.b   7,  0,  1,  2,  3,  4,  5,  6	; 0
		dc.b   7,$FE,  2,  0			; 8
off_B528:	dc.w byte_B52A-off_B528
byte_B52A:	dc.b $1F,  0,  1,$FF			; 0
Map_S1Obj0F:	dc.w word_B536-Map_S1Obj0F
		dc.w word_B538-Map_S1Obj0F		; leftover from Sonic 1
		dc.w word_B56A-Map_S1Obj0F		; leftover from Sonic 1
		dc.w word_B65C-Map_S1Obj0F		; leftover from Sonic 1
word_B536:	dc.w 0
word_B538:	dc.w 6
		dc.w	$C,  $F0,  $78,	   0		; 0
		dc.w	 0,  $F3,  $79,	 $20		; 4
		dc.w	 0,  $F3,  $79,	 $30		; 8
		dc.w	$C,  $F4,  $7A,	 $38		; 12
		dc.w	 8,  $F8,  $7C,	 $60		; 16
		dc.w	 8,  $FB,  $7D,	 $78		; 20
word_B56A:	dc.w $1E
		dc.w $B80F,    0,    0,$FF80		; 0
		dc.w $B80F,    0,    0,$FF80		; 4
		dc.w $B80F,    0,    0,$FF80		; 8
		dc.w $B80F,    0,    0,$FF80		; 12
		dc.w $B80F,    0,    0,$FF80		; 16
		dc.w $B80F,    0,    0,$FF80		; 20
		dc.w $B80F,    0,    0,$FF80		; 24
		dc.w $B80F,    0,    0,$FF80		; 28
		dc.w $B80F,    0,    0,$FF80		; 32
		dc.w $B80F,    0,    0,$FF80		; 36
		dc.w $D80F,    0,    0,$FF80		; 40
		dc.w $D80F,    0,    0,$FF80		; 44
		dc.w $D80F,    0,    0,$FF80		; 48
		dc.w $D80F,    0,    0,$FF80		; 52
		dc.w $D80F,    0,    0,$FF80		; 56
		dc.w $D80F,    0,    0,$FF80		; 60
		dc.w $D80F,    0,    0,$FF80		; 64
		dc.w $D80F,    0,    0,$FF80		; 68
		dc.w $D80F,    0,    0,$FF80		; 72
		dc.w $D80F,    0,    0,$FF80		; 76
		dc.w $F80F,    0,    0,$FF80		; 80
		dc.w $F80F,    0,    0,$FF80		; 84
		dc.w $F80F,    0,    0,$FF80		; 88
		dc.w $F80F,    0,    0,$FF80		; 92
		dc.w $F80F,    0,    0,$FF80		; 96
		dc.w $F80F,    0,    0,$FF80		; 100
		dc.w $F80F,    0,    0,$FF80		; 104
		dc.w $F80F,    0,    0,$FF80		; 108
		dc.w $F80F,    0,    0,$FF80		; 112
		dc.w $F80F,    0,    0,$FF80		; 116
word_B65C:	dc.w 1
		dc.w $FC04,    0,    0,$FFF8		; 0
Map_Obj0E:	dc.w word_B66A-Map_Obj0E
		dc.w word_B6C4-Map_Obj0E
word_B66A:	dc.w $B
		dc.w $D40D,    0,    0,$FFD8		; 0
		dc.w $CC0E,    8,    4,$FFF8		; 4
		dc.w $CC07,  $14,   $A,	 $18		; 8
		dc.w $E40F,  $1C,   $E,$FFE0		; 12
		dc.w $E40B,  $2C,  $16,	   0		; 16
		dc.w $EC07,  $38,  $1C,	 $18		; 20
		dc.w  $40F,  $40,  $20,$FFD8		; 24
		dc.w  $40F,  $50,  $28,$FFF8		; 28
		dc.w  $C06,  $60,  $30,	 $18		; 32
		dc.w $2404,  $66,  $33,$FFE8		; 36
		dc.w $240D,  $68,  $34,$FFF8		; 40
word_B6C4:	dc.w $A
		dc.w $DC06,  $70,  $38,$FFEC		; 0
		dc.w $F40F,  $76,  $3B,$FFD4		; 4
		dc.w $F40F,  $86,  $43,$FFF4		; 8
		dc.w $E409,  $96,  $4B,$FFFC		; 12
		dc.w $DC0B,  $9C,  $4E,	 $14		; 16
		dc.w $FC08,  $A8,  $54,	 $14		; 20
		dc.w  $405,  $AB,  $55,	 $14		; 24
		dc.w $1404,  $AF,  $57,$FFD4		; 28
		dc.w $140D,  $B1,  $58,$FFE4		; 32
		dc.w $140D,  $B9,  $5C,	   4		; 36
		dc.w $4E71				; 40
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 2B - GHZ Chopper Badnik
;----------------------------------------------------

Obj2B:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj2B_Index(pc,d0.w),d1
		jsr	Obj2B_Index(pc,d1.w)
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------
Obj2B_Index:	dc.w loc_B72E-Obj2B_Index
		dc.w loc_B768-Obj2B_Index
; ---------------------------------------------------------------------------

loc_B72E:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj2B,obMap(a0)
		move.w	#$470,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#9,obColType(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$F900,obVelY(a0)
		move.w	obY(a0),$30(a0)

loc_B768:
		lea	(Ani_Obj2B).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectMove
		addi.w	#$18,obVelY(a0)
		move.w	$30(a0),d0
		cmp.w	obY(a0),d0
		bcc.s	loc_B790
		move.w	d0,obY(a0)
		move.w	#$F900,obVelY(a0)

loc_B790:
		move.b	#1,obAnim(a0)
		subi.w	#$C0,d0
		cmp.w	obY(a0),d0
		bcc.s	locret_B7B2
		move.b	#0,obAnim(a0)
		tst.w	obVelY(a0)
		bmi.s	locret_B7B2
		move.b	#2,obAnim(a0)

locret_B7B2:
		rts
; ---------------------------------------------------------------------------
Ani_Obj2B:	dc.w byte_B7BA-Ani_Obj2B
		dc.w byte_B7BE-Ani_Obj2B
		dc.w byte_B7C2-Ani_Obj2B
byte_B7BA:	dc.b   7,  0,  1,$FF			; 0
byte_B7BE:	dc.b   3,  0,  1,$FF			; 0
byte_B7C2:	dc.b   7,  0,$FF,  0			; 0
Map_Obj2B:	dc.w word_B7CA-Map_Obj2B
		dc.w word_B7D4-Map_Obj2B
word_B7CA:	dc.w 1
		dc.w $F00F,    0,    0,$FFF0		; 0
word_B7D4:	dc.w 1
		dc.w $F00F,  $10,    8,$FFF0		; 0
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 2C - LZ Jaws Badnik
;----------------------------------------------------

Obj2C:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj2C_Index(pc,d0.w),d1
		jmp	Obj2C_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj2C_Index:	dc.w loc_B7F0-Obj2C_Index
		dc.w loc_B842-Obj2C_Index
; ---------------------------------------------------------------------------

loc_B7F0:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj2C,obMap(a0)
		move.w	#$2486,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsl.w	#6,d0
		subq.w	#1,d0
		move.w	d0,$30(a0)
		move.w	d0,$32(a0)
		move.w	#$FFC0,obVelX(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_B842
		neg.w	obVelX(a0)

loc_B842:
		subq.w	#1,$30(a0)
		bpl.s	loc_B85E
		move.w	$32(a0),$30(a0)
		neg.w	obVelX(a0)
		bchg	#0,obStatus(a0)
		move.b	#1,obPrevAni(a0)

loc_B85E:
		lea	(Ani_Obj2C).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectMove
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------
Ani_Obj2C:	dc.b   0,  2,  7,  0,  1,  2,  3,$FF	; 0
Map_Obj2C:	dc.w word_B880-Map_Obj2C
		dc.w word_B892-Map_Obj2C
		dc.w word_B8A4-Map_Obj2C
		dc.w word_B8B6-Map_Obj2C
word_B880:	dc.w 2
		dc.w $F40E,    0,    0,$FFF0		; 0
		dc.w $F505,  $18,   $C,	 $10		; 4
word_B892:	dc.w 2
		dc.w $F40E,   $C,    6,$FFF0		; 0
		dc.w $F505,  $1C,   $E,	 $10		; 4
word_B8A4:	dc.w 2
		dc.w $F40E,    0,    0,$FFF0		; 0
		dc.w $F505,$1018,$100C,	 $10		; 4
word_B8B6:	dc.w 2
		dc.w $F40E,   $C,    6,$FFF0		; 0
		dc.w $F505,$101C,$100E,	 $10		; 4
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 34 - leftover Sonic 1 title cards
;----------------------------------------------------

Obj34:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj34_Index(pc,d0.w),d1
		jmp	Obj34_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj34_Index:	dc.w Obj34_CheckLZ4-Obj34_Index		; 0
		dc.w Obj34_CheckPos-Obj34_Index		; 1
		dc.w Obj34_Wait-Obj34_Index		; 2
		dc.w Obj34_Wait-Obj34_Index		; 3
; ---------------------------------------------------------------------------

Obj34_CheckLZ4:
		movea.l	a0,a1
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		cmpi.w	#$103,(Current_ZoneAndAct).w
		bne.s	Obj34_CheckFZ
		moveq	#5,d0

Obj34_CheckFZ:
		move.w	d0,d2
		cmpi.w	#$502,(Current_ZoneAndAct).w
		bne.s	Obj34_CheckConfig
		moveq	#6,d0
		moveq	#$B,d2

Obj34_CheckConfig:
		lea	(Obj34_Config).l,a3
		lsl.w	#4,d0
		adda.w	d0,a3
		lea	(Obj34_ItemData).l,a2
		moveq	#3,d1

Obj34_Loop:
		_move.b	#$34,obID(a1)
		move.w	(a3),obX(a1)
		move.w	(a3)+,$32(a1)
		move.w	(a3)+,$30(a1)
		move.w	(a2)+,$A(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,d0
		bne.s	Obj34_ActNumber
		move.b	d2,d0

Obj34_ActNumber:
		cmpi.b	#7,d0
		bne.s	Obj34_MakeSprite
		add.b	(Current_Act).w,d0
		cmpi.b	#3,(Current_Act).w
		bne.s	Obj34_MakeSprite
		subq.b	#1,d0

Obj34_MakeSprite:
		move.b	d0,obFrame(a1)
		move.l	#Map_Obj34,obMap(a1)
		move.w	#$8580,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#$78,obActWid(a1)
		move.b	#0,obRender(a1)
		move.b	#0,obPriority(a1)
		move.w	#$3C,obTimeFrame(a1)
		lea	$40(a1),a1
		dbf	d1,Obj34_Loop

Obj34_CheckPos:
		moveq	#$10,d1
		move.w	$30(a0),d0
		cmp.w	obX(a0),d0
		beq.s	loc_B98E
		bge.s	Obj34_Move
		neg.w	d1

Obj34_Move:
		add.w	d1,obX(a0)

loc_B98E:
		move.w	obX(a0),d0
		bmi.s	Obj34_NoDisplay
		cmpi.w	#$200,d0
		bcc.s	Obj34_NoDisplay
		rts
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

Obj34_NoDisplay:
		rts
; ---------------------------------------------------------------------------

Obj34_Wait:
		tst.w	obTimeFrame(a0)
		beq.s	Obj34_CheckPos2
		subq.w	#1,obTimeFrame(a0)
		rts
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

Obj34_CheckPos2:
		tst.b	obRender(a0)
		bpl.s	Obj34_ChangeArt
		moveq	#$20,d1
		move.w	$32(a0),d0
		cmp.w	obX(a0),d0
		beq.s	Obj34_ChangeArt
		bge.s	Obj34_Move2
		neg.w	d1

Obj34_Move2:
		add.w	d1,obX(a0)
		move.w	obX(a0),d0
		bmi.s	Obj34_NoDisplay2
		cmpi.w	#$200,d0
		bcc.s	Obj34_NoDisplay2
		rts
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

Obj34_NoDisplay2:
		rts
; ---------------------------------------------------------------------------

Obj34_ChangeArt:
		cmpi.b	#4,obRoutine(a0)
		bne.s	Obj34_Delete
		moveq	#2,d0
		jsr	(LoadPLC).l
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		addi.w	#$15,d0
		jsr	(LoadPLC).l

Obj34_Delete:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------
Obj34_ItemData:	dc.w $D0
		dc.b   2,  0				; 0
		dc.w $E4
		dc.b   2,  6				; 0
		dc.w $EA
		dc.b   2,  7				; 0
		dc.w $E0
		dc.b   2, $A				; 0
Obj34_Config:	dc.w	 0, $120,$FEFC,	$13C, $414, $154, $214,	$154 ; 0
		dc.w	 0, $120,$FEF4,	$134, $40C, $14C, $20C,	$14C ; 8
		dc.w	 0, $120,$FEE0,	$120, $3F8, $138, $1F8,	$138 ; 16
		dc.w	 0, $120,$FEFC,	$13C, $414, $154, $214,	$154 ; 24
		dc.w	 0, $120,$FF04,	$144, $41C, $15C, $21C,	$15C ; 32
		dc.w	 0, $120,$FF04,	$144, $41C, $15C, $21C,	$15C ; 40
		dc.w	 0, $120,$FEE4,	$124, $3EC, $3EC, $1EC,	$12C ; 48
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 39 - Game over	/ time over
;----------------------------------------------------

Obj39:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj39_Index(pc,d0.w),d1
		jmp	Obj39_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj39_Index:	dc.w loc_BA98-Obj39_Index
		dc.w loc_BADC-Obj39_Index
		dc.w loc_BAFE-Obj39_Index
; ---------------------------------------------------------------------------

loc_BA98:
		tst.l	(v_plc_buffer).w
		beq.s	loc_BAA0
		rts
; ---------------------------------------------------------------------------

loc_BAA0:
		addq.b	#2,obRoutine(a0)
		move.w	#$50,obX(a0)
		btst	#0,obFrame(a0)
		beq.s	loc_BAB8
		move.w	#$1F0,obX(a0)

loc_BAB8:
		move.w	#$F0,$A(a0)
		move.l	#Map_Obj39,obMap(a0)
		move.w	#$855E,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#0,obRender(a0)
		move.b	#0,obPriority(a0)

loc_BADC:
		moveq	#$10,d1
		cmpi.w	#$120,obX(a0)
		beq.s	loc_BAF2
		bcs.s	loc_BAEA
		neg.w	d1

loc_BAEA:
		add.w	d1,obX(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_BAF2:
		move.w	#$2D0,obTimeFrame(a0)
		addq.b	#2,obRoutine(a0)
		rts
; ---------------------------------------------------------------------------

loc_BAFE:
		move.b	(v_jpadpress1).w,d0
		andi.b	#$70,d0
		bne.s	loc_BB1E
		btst	#0,obFrame(a0)
		bne.s	loc_BB42
		tst.w	obTimeFrame(a0)
		beq.s	loc_BB1E
		subq.w	#1,obTimeFrame(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_BB1E:
		tst.b	(f_timeover).w
		bne.s	loc_BB38
		move.b	#GameModeID_ContinueScreen,(v_gamemode).w
		tst.b	(v_continues).w
		bne.s	loc_BB42
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		bra.s	loc_BB42
; ---------------------------------------------------------------------------

loc_BB38:
		clr.l	(v_lamp_time).w
		move.w	#1,(Level_Inactive_flag).w

loc_BB42:
		bra.w	DisplaySprite
; ===========================================================================
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
		rts
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
		rts
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite
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
		rts
; ---------------------------------------------------------------------------
		bra.w	DisplaySprite
; ===========================================================================
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
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Sonic	1 Object 7E - leftover S1 Special Stage	results
;----------------------------------------------------

S1Obj7E:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj7E_Index(pc,d0.w),d1
		jmp	S1Obj7E_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj7E_Index:	dc.w loc_BDA6-S1Obj7E_Index
		dc.w loc_BE1E-S1Obj7E_Index
		dc.w loc_BE5C-S1Obj7E_Index
		dc.w loc_BE6A-S1Obj7E_Index
		dc.w loc_BE5C-S1Obj7E_Index
		dc.w loc_BEC4-S1Obj7E_Index
		dc.w loc_BE5C-S1Obj7E_Index
		dc.w loc_BECE-S1Obj7E_Index
		dc.w loc_BE5C-S1Obj7E_Index
		dc.w loc_BEC4-S1Obj7E_Index
		dc.w loc_BEF2-S1Obj7E_Index
; ---------------------------------------------------------------------------

loc_BDA6:
		tst.l	(v_plc_buffer).w
		beq.s	loc_BDAE
		rts
; ---------------------------------------------------------------------------

loc_BDAE:
		movea.l	a0,a1
		lea	(S1Obj7E_Conf).l,a2
		moveq	#3,d1
		cmpi.w	#$32,(v_rings).w
		bcs.s	loc_BDC2
		addq.w	#1,d1

loc_BDC2:
		_move.b	#$7E,obID(a1)
		move.w	(a2)+,obX(a1)
		move.w	(a2)+,$30(a1)
		move.w	(a2)+,$A(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obFrame(a1)
		move.l	#Map_S1Obj7E,obMap(a1)
		move.w	#$8580,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#0,obRender(a1)
		lea	$40(a1),a1
		dbf	d1,loc_BDC2
		moveq	#7,d0
		move.b	(v_emeralds).w,d1
		beq.s	loc_BE1A
		moveq	#0,d0
		cmpi.b	#6,d1
		bne.s	loc_BE1A
		moveq	#8,d0
		move.w	#$18,obX(a0)
		move.w	#$118,$30(a0)

loc_BE1A:
		move.b	d0,obFrame(a0)

loc_BE1E:
		moveq	#$10,d1
		move.w	$30(a0),d0
		cmp.w	obX(a0),d0
		beq.s	loc_BE44
		bge.s	loc_BE2E
		neg.w	d1

loc_BE2E:
		add.w	d1,obX(a0)

loc_BE32:
		move.w	obX(a0),d0
		bmi.s	locret_BE42
		cmpi.w	#$200,d0
		bcc.s	locret_BE42
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

locret_BE42:
		rts
; ---------------------------------------------------------------------------

loc_BE44:
		cmpi.b	#2,obFrame(a0)
		bne.s	loc_BE32
		addq.b	#2,obRoutine(a0)
		move.w	#$B4,obTimeFrame(a0)
		move.b	#$7F,(v_objspace+$800).w

loc_BE5C:
		subq.w	#1,obTimeFrame(a0)
		bne.s	loc_BE66
		addq.b	#2,obRoutine(a0)

loc_BE66:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_BE6A:
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w
		tst.w	(v_ringbonus).w
		beq.s	loc_BE9C
		subi.w	#10,(v_ringbonus).w
		moveq	#10,d0
		jsr	(AddPoints).l
		move.b	($FFFFFE0F).w,d0
		andi.b	#3,d0
		bne.s	locret_BEC2
		move.w	#sfx_Switch,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------

loc_BE9C:
		move.w	#sfx_Cash,d0
		jsr	(PlaySound_Special).l
		addq.b	#2,obRoutine(a0)
		move.w	#$B4,obTimeFrame(a0)
		cmpi.w	#$32,(v_rings).w
		bcs.s	locret_BEC2
		move.w	#$3C,obTimeFrame(a0)
		addq.b	#4,obRoutine(a0)

locret_BEC2:
		rts
; ---------------------------------------------------------------------------

loc_BEC4:
		move.w	#1,(Level_Inactive_flag).w
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_BECE:
		move.b	#4,(v_objspace+$6DA).w
		move.b	#$14,(v_objspace+$6C0+obRoutine).w
		move.w	#sfx_Continue,d0
		jsr	(PlaySound_Special).l
		addq.b	#2,obRoutine(a0)
		move.w	#$168,obTimeFrame(a0)
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_BEF2:
		move.b	($FFFFFE0F).w,d0
		andi.b	#$F,d0
		bne.s	loc_BF02
		bchg	#0,obFrame(a0)

loc_BF02:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
S1Obj7E_Conf:	dc.w   $20, $120,  $C4,	$200		; 0
		dc.w  $320, $120, $118,	$201		; 4
		dc.w  $360, $120, $128,	$202		; 8
		dc.w  $1EC, $11C,  $C4,	$203		; 12
		dc.w  $3A0, $120, $138,	$206		; 16
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Sonic	1 Object 7F - leftover Sonic 1 SS emeralds
;----------------------------------------------------

S1Obj7F:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj7F_Index(pc,d0.w),d1
		jmp	S1Obj7F_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj7F_Index:	dc.w loc_BF4C-S1Obj7F_Index
		dc.w loc_BFA6-S1Obj7F_Index
word_BF40:	dc.w $110
		dc.w $128
		dc.w $F8
		dc.w $140
		dc.w $E0
		dc.w $158
; ---------------------------------------------------------------------------

loc_BF4C:
		movea.l	a0,a1
		lea	word_BF40(pc),a2
		moveq	#0,d2
		moveq	#0,d1
		move.b	(v_emeralds).w,d1
		subq.b	#1,d1
		bcs.w	DeleteObject

loc_BF60:
		_move.b	#$7F,obID(a1)
		move.w	(a2)+,obX(a1)
		move.w	#$F0,$A(a1)
		lea	(v_emldlist).w,a3
		move.b	(a3,d2.w),d3
		move.b	d3,obFrame(a1)
		move.b	d3,obAnim(a1)
		addq.b	#1,d2
		addq.b	#2,obRoutine(a1)
		move.l	#Map_S1Obj7F,obMap(a1)
		move.w	#$8541,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#0,obRender(a1)
		lea	$40(a1),a1
		dbf	d1,loc_BF60

loc_BFA6:
		move.b	obFrame(a0),d0
		move.b	#6,obFrame(a0)
		cmpi.b	#6,d0
		bne.s	loc_BFBC
		move.b	obAnim(a0),obFrame(a0)

loc_BFBC:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Map_Obj34:	dc.w word_BFD8-Map_Obj34
		dc.w word_C022-Map_Obj34
		dc.w word_C06C-Map_Obj34
		dc.w word_C09E-Map_Obj34
		dc.w word_C0E8-Map_Obj34
		dc.w word_C13A-Map_Obj34
		dc.w word_C18C-Map_Obj34
		dc.w word_C1AE-Map_Obj34
		dc.w word_C1C0-Map_Obj34
		dc.w word_C1D2-Map_Obj34
		dc.w word_C1E4-Map_Obj34
		dc.w word_C24E-Map_Obj34
word_BFD8:	dc.w 9
		dc.w $F805,  $18,   $C,$FFB4		; 0
		dc.w $F805,  $3A,  $1D,$FFC4		; 4
		dc.w $F805,  $10,    8,$FFD4		; 8
		dc.w $F805,  $10,    8,$FFE4		; 12
		dc.w $F805,  $2E,  $17,$FFF4		; 16
		dc.w $F805,  $1C,   $E,	 $14		; 20
		dc.w $F801,  $20,  $10,	 $24		; 24
		dc.w $F805,  $26,  $13,	 $2C		; 28
		dc.w $F805,  $26,  $13,	 $3C		; 32
word_C022:	dc.w 9
		dc.w $F805,  $26,  $13,$FFBC		; 0
		dc.w $F805,    0,    0,$FFCC		; 4
		dc.w $F805,    4,    2,$FFDC		; 8
		dc.w $F805,  $4A,  $25,$FFEC		; 12
		dc.w $F805,  $3A,  $1D,$FFFC		; 16
		dc.w $F801,  $20,  $10,	  $C		; 20
		dc.w $F805,  $2E,  $17,	 $14		; 24
		dc.w $F805,  $42,  $21,	 $24		; 28
		dc.w $F805,  $1C,   $E,	 $34		; 32
word_C06C:	dc.w 6
		dc.w $F805,  $2A,  $15,$FFCF		; 0
		dc.w $F805,    0,    0,$FFE0		; 4
		dc.w $F805,  $3A,  $1D,$FFF0		; 8
		dc.w $F805,    4,    2,	   0		; 12
		dc.w $F805,  $26,  $13,	 $10		; 16
		dc.w $F805,  $10,    8,	 $20		; 20
word_C09E:	dc.w 9
		dc.w $F805,  $3E,  $1F,$FFB4		; 0
		dc.w $F805,  $42,  $21,$FFC4		; 4
		dc.w $F805,    0,    0,$FFD4		; 8
		dc.w $F805,  $3A,  $1D,$FFE4		; 12
		dc.w $F805,  $26,  $13,	   4		; 16
		dc.w $F801,  $20,  $10,	 $14		; 20
		dc.w $F805,  $18,   $C,	 $1C		; 24
		dc.w $F805,  $1C,   $E,	 $2C		; 28
		dc.w $F805,  $42,  $21,	 $3C		; 32
word_C0E8:	dc.w $A
		dc.w $F805,  $3E,  $1F,$FFAC		; 0
		dc.w $F805,  $36,  $1B,$FFBC		; 4
		dc.w $F805,  $3A,  $1D,$FFCC		; 8
		dc.w $F801,  $20,  $10,$FFDC		; 12
		dc.w $F805,  $2E,  $17,$FFE4		; 16
		dc.w $F805,  $18,   $C,$FFF4		; 20
		dc.w $F805,  $4A,  $25,	 $14		; 24
		dc.w $F805,    0,    0,	 $24		; 28
		dc.w $F805,  $3A,  $1D,	 $34		; 32
		dc.w $F805,   $C,    6,	 $44		; 36
word_C13A:	dc.w $A
		dc.w $F805,  $3E,  $1F,$FFAC		; 0
		dc.w $F805,    8,    4,$FFBC		; 4
		dc.w $F805,  $3A,  $1D,$FFCC		; 8
		dc.w $F805,    0,    0,$FFDC		; 12
		dc.w $F805,  $36,  $1B,$FFEC		; 16
		dc.w $F805,    4,    2,	  $C		; 20
		dc.w $F805,  $3A,  $1D,	 $1C		; 24
		dc.w $F805,    0,    0,	 $2C		; 28
		dc.w $F801,  $20,  $10,	 $3C		; 32
		dc.w $F805,  $2E,  $17,	 $44		; 36
word_C18C:	dc.w 4
		dc.w $F805,  $4E,  $27,$FFE0		; 0
		dc.w $F805,  $32,  $19,$FFF0		; 4
		dc.w $F805,  $2E,  $17,	   0		; 8
		dc.w $F805,  $10,    8,	 $10		; 12
word_C1AE:	dc.w 2
		dc.w  $40C,  $53,  $29,$FFEC		; 0
		dc.w $F402,  $57,  $2B,	  $C		; 4
word_C1C0:	dc.w 2
		dc.w  $40C,  $53,  $29,$FFEC		; 0
		dc.w $F406,  $5A,  $2D,	   8		; 4
word_C1D2:	dc.w 2
		dc.w  $40C,  $53,  $29,$FFEC		; 0
		dc.w $F406,  $60,  $30,	   8		; 4
word_C1E4:	dc.w $D
		dc.w $E40C,  $70,  $38,$FFF4		; 0
		dc.w $E402,  $74,  $3A,	 $14		; 4
		dc.w $EC04,  $77,  $3B,$FFEC		; 8
		dc.w $F405,  $79,  $3C,$FFE4		; 12
		dc.w $140C,$1870,$1838,$FFEC		; 16
		dc.w  $402,$1874,$183A,$FFE4		; 20
		dc.w  $C04,$1877,$183B,	   4		; 24
		dc.w $FC05,$1879,$183C,	  $C		; 28
		dc.w $EC08,  $7D,  $3E,$FFFC		; 32
		dc.w $F40C,  $7C,  $3E,$FFF4		; 36
		dc.w $FC08,  $7C,  $3E,$FFF4		; 40
		dc.w  $40C,  $7C,  $3E,$FFEC		; 44
		dc.w  $C08,  $7C,  $3E,$FFEC		; 48
word_C24E:	dc.w 5
		dc.w $F805,  $14,   $A,$FFDC		; 0
		dc.w $F801,  $20,  $10,$FFEC		; 4
		dc.w $F805,  $2E,  $17,$FFF4		; 8
		dc.w $F805,    0,    0,	   4		; 12
		dc.w $F805,  $26,  $13,	 $14		; 16
Map_Obj39:	dc.w word_C280-Map_Obj39
		dc.w word_C292-Map_Obj39
		dc.w word_C2A4-Map_Obj39
		dc.w word_C2B6-Map_Obj39
word_C280:	dc.w 2
		dc.w $F80D,    0,    0,$FFB8		; 0
		dc.w $F80D,    8,    4,$FFD8		; 4
word_C292:	dc.w 2
		dc.w $F80D,  $14,   $A,	   8		; 0
		dc.w $F80D,   $C,    6,	 $28		; 4
word_C2A4:	dc.w 2
		dc.w $F809,  $1C,   $E,$FFC4		; 0
		dc.w $F80D,    8,    4,$FFDC		; 4
word_C2B6:	dc.w 2
		dc.w $F80D,  $14,   $A,	  $C		; 0
		dc.w $F80D,   $C,    6,	 $2C		; 4
Map_Obj3A:	dc.w word_C2DA-Map_Obj3A
		dc.w word_C31C-Map_Obj3A
		dc.w word_C34E-Map_Obj3A
		dc.w word_C380-Map_Obj3A
		dc.w word_C3BA-Map_Obj3A
		dc.w word_C1E4-Map_Obj3A
		dc.w word_C1AE-Map_Obj3A
		dc.w word_C1C0-Map_Obj3A
		dc.w word_C1D2-Map_Obj3A
word_C2DA:	dc.w 8
		dc.w $F805,  $3E,  $1F,$FFB8		; 0
		dc.w $F805,  $32,  $19,$FFC8		; 4
		dc.w $F805,  $2E,  $17,$FFD8		; 8
		dc.w $F801,  $20,  $10,$FFE8		; 12
		dc.w $F805,    8,    4,$FFF0		; 16
		dc.w $F805,  $1C,   $E,	 $10		; 20
		dc.w $F805,    0,    0,	 $20		; 24
		dc.w $F805,  $3E,  $1F,	 $30		; 28
word_C31C:	dc.w 6
		dc.w $F805,  $36,  $1B,$FFD0		; 0
		dc.w $F805,    0,    0,$FFE0		; 4
		dc.w $F805,  $3E,  $1F,$FFF0		; 8
		dc.w $F805,  $3E,  $1F,	   0		; 12
		dc.w $F805,  $10,    8,	 $10		; 16
		dc.w $F805,   $C,    6,	 $20		; 20
word_C34E:	dc.w 6
		dc.w $F80D, $14A,  $A5,$FFB0		; 0
		dc.w $F801, $162,  $B1,$FFD0		; 4
		dc.w $F809, $164,  $B2,	 $18		; 8
		dc.w $F80D, $16A,  $B5,	 $30		; 12
		dc.w $F704,  $6E,  $37,$FFCD		; 16
		dc.w $FF04,$186E,$1837,$FFCD		; 20
word_C380:	dc.w 7
		dc.w $F80D, $15A,  $AD,$FFB0		; 0
		dc.w $F80D,  $66,  $33,$FFD9		; 4
		dc.w $F801, $14A,  $A5,$FFF9		; 8
		dc.w $F704,  $6E,  $37,$FFF6		; 12
		dc.w $FF04,$186E,$1837,$FFF6		; 16
		dc.w $F80D,$FFF0,$FBF8,	 $28		; 20
		dc.w $F801, $170,  $B8,	 $48		; 24
word_C3BA:	dc.w 7
		dc.w $F80D, $152,  $A9,$FFB0		; 0
		dc.w $F80D,  $66,  $33,$FFD9		; 4
		dc.w $F801, $14A,  $A5,$FFF9		; 8
		dc.w $F704,  $6E,  $37,$FFF6		; 12
		dc.w $FF04,$186E,$1837,$FFF6		; 16
		dc.w $F80D,$FFF8,$FBFC,	 $28		; 20
		dc.w $F801, $170,  $B8,	 $48		; 24
Map_S1Obj7E:	dc.w word_C406-Map_S1Obj7E
		dc.w word_C470-Map_S1Obj7E
		dc.w word_C4A2-Map_S1Obj7E
		; for some reason, this part of the mappings references a PLR list,
		; meaning in order to use macros for it, we need this hackish fix,
		; AND we can't compile it...
;		dc.w $1C1E4-Map_S1Obj7E
		dc.w $FDF0
		dc.w word_C4DC-Map_S1Obj7E
		dc.w word_C4FE-Map_S1Obj7E
		dc.w word_C520-Map_S1Obj7E
		dc.w word_C53A-Map_S1Obj7E
		dc.w word_C59C-Map_S1Obj7E
word_C406:	dc.w $D
		dc.w $F805,    8,    4,$FF90		; 0
		dc.w $F805,  $1C,   $E,$FFA0		; 4
		dc.w $F805,    0,    0,$FFB0		; 8
		dc.w $F805,  $32,  $19,$FFC0		; 12
		dc.w $F805,  $3E,  $1F,$FFD0		; 16
		dc.w $F805,  $10,    8,$FFF0		; 20
		dc.w $F805,  $2A,  $15,	   0		; 24
		dc.w $F805,  $10,    8,	 $10		; 28
		dc.w $F805,  $3A,  $1D,	 $20		; 32
		dc.w $F805,    0,    0,	 $30		; 36
		dc.w $F805,  $26,  $13,	 $40		; 40
		dc.w $F805,   $C,    6,	 $50		; 44
		dc.w $F805,  $3E,  $1F,	 $60		; 48
word_C470:	dc.w 6
		dc.w $F80D, $14A,  $A5,$FFB0		; 0
		dc.w $F801, $162,  $B1,$FFD0		; 4
		dc.w $F809, $164,  $B2,	 $18		; 8
		dc.w $F80D, $16A,  $B5,	 $30		; 12
		dc.w $F704,  $6E,  $37,$FFCD		; 16
		dc.w $FF04,$186E,$1837,$FFCD		; 20
word_C4A2:	dc.w 7
		dc.w $F80D, $152,  $A9,$FFB0		; 0
		dc.w $F80D,  $66,  $33,$FFD9		; 4
		dc.w $F801, $14A,  $A5,$FFF9		; 8
		dc.w $F704,  $6E,  $37,$FFF6		; 12
		dc.w $FF04,$186E,$1837,$FFF6		; 16
		dc.w $F80D,$FFF8,$FBFC,	 $28		; 20
		dc.w $F801, $170,  $B8,	 $48		; 24
word_C4DC:	dc.w 4
		dc.w $F80D,$FFD1,$7FC8,$FFB0		; 0
		dc.w $F80D,$FFD9,$7FD4,$FFD0		; 4
		dc.w $F801,$FFE1,$7FE0,$FFF0		; 8
		dc.w $F806,$1FE3,$2FE3,	 $40		; 12
word_C4FE:	dc.w 4
		dc.w $F80D,$FFD1,$7FC8,$FFB0		; 0
		dc.w $F80D,$FFD9,$7FD4,$FFD0		; 4
		dc.w $F801,$FFE1,$7FE0,$FFF0		; 8
		dc.w $F806,$1FE9,$2FEC,	 $40		; 12
word_C520:	dc.w 3
		dc.w $F80D,$FFD1,$7FC8,$FFB0		; 0
		dc.w $F80D,$FFD9,$7FD4,$FFD0		; 4
		dc.w $F801,$FFE1,$7FE0,$FFF0		; 8
word_C53A:	dc.w $C
		dc.w $F805,  $3E,  $1F,$FF9C		; 0
		dc.w $F805,  $36,  $1B,$FFAC		; 4
		dc.w $F805,  $10,    8,$FFBC		; 8
		dc.w $F805,    8,    4,$FFCC		; 12
		dc.w $F801,  $20,  $10,$FFDC		; 16
		dc.w $F805,    0,    0,$FFE4		; 20
		dc.w $F805,  $26,  $13,$FFF4		; 24
		dc.w $F805,  $3E,  $1F,	 $14		; 28
		dc.w $F805,  $42,  $21,	 $24		; 32
		dc.w $F805,    0,    0,	 $34		; 36
		dc.w $F805,  $18,   $C,	 $44		; 40
		dc.w $F805,  $10,    8,	 $54		; 44
word_C59C:	dc.w $F
		dc.w $F805,  $3E,  $1F,$FF88		; 0
		dc.w $F805,  $32,  $19,$FF98		; 4
		dc.w $F805,  $2E,  $17,$FFA8		; 8
		dc.w $F801,  $20,  $10,$FFB8		; 12
		dc.w $F805,    8,    4,$FFC0		; 16
		dc.w $F805,  $18,   $C,$FFD8		; 20
		dc.w $F805,  $32,  $19,$FFE8		; 24
		dc.w $F805,  $42,  $21,$FFF8		; 28
		dc.w $F805,  $42,  $21,	 $10		; 32
		dc.w $F805,  $1C,   $E,	 $20		; 36
		dc.w $F805,  $10,    8,	 $30		; 40
		dc.w $F805,  $2A,  $15,	 $40		; 44
		dc.w $F805,    0,    0,	 $58		; 48
		dc.w $F805,  $26,  $13,	 $68		; 52
		dc.w $F805,  $26,  $13,	 $78		; 56
Map_S1Obj7F:	dc.w word_C624-Map_S1Obj7F
		dc.w word_C62E-Map_S1Obj7F
		dc.w word_C638-Map_S1Obj7F
		dc.w word_C642-Map_S1Obj7F
		dc.w word_C64C-Map_S1Obj7F
		dc.w word_C656-Map_S1Obj7F
		dc.w word_C660-Map_S1Obj7F
word_C624:	dc.w 1
		dc.w $F805,$2004,$2002,$FFF8		; 0
word_C62E:	dc.w 1
		dc.w $F805,    0,    0,$FFF8		; 0
word_C638:	dc.w 1
		dc.w $F805,$4004,$4002,$FFF8		; 0
word_C642:	dc.w 1
		dc.w $F805,$6004,$6002,$FFF8		; 0
word_C64C:	dc.w 1
		dc.w $F805,$2008,$2004,$FFF8		; 0
word_C656:	dc.w 1
		dc.w $F805,$200C,$2006,$FFF8		; 0
word_C660:	dc.w 0
; ---------------------------------------------------------------------------
		nop
;----------------------------------------------------
; Object 36 - Spikes
;----------------------------------------------------

Obj36:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj36_Index(pc,d0.w),d1
		jmp	Obj36_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj36_Index:	dc.w loc_C682-Obj36_Index
		dc.w loc_C6CE-Obj36_Index
Obj36_Conf:	dc.b   0,$10				; 0
		dc.b   0,$10				; 2
		dc.b   0,$10				; 4
		dc.b   0,$10				; 6
		dc.b   0,$10				; 8
		dc.b   0,$10				; 10
; ---------------------------------------------------------------------------

loc_C682:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj36,obMap(a0)
		move.w	#$2434,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	obSubtype(a0),d0
		andi.b	#$F,obSubtype(a0)
		andi.w	#$F0,d0
		lea	Obj36_Conf(pc),a1
		lsr.w	#3,d0
		adda.w	d0,a1
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obActWid(a0)
		move.w	obX(a0),$30(a0)
		move.w	obY(a0),$32(a0)

loc_C6CE:
		bsr.w	sub_C788
		move.w	#4,d2
		cmpi.b	#5,obFrame(a0)
		beq.s	loc_C6EA
		cmpi.b	#1,obFrame(a0)
		bne.s	loc_C70C
		move.w	#$14,d2

loc_C6EA:
		move.w	#$1B,d1
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#3,obStatus(a0)
		bne.s	loc_C766
		swap	d6
		andi.w	#3,d6
		bne.s	loc_C736
		bra.s	loc_C766
; ---------------------------------------------------------------------------

loc_C70C:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#3,obStatus(a0)
		bne.s	loc_C736
		swap	d6
		andi.w	#$C0,d6
		beq.s	loc_C766

loc_C736:
		tst.b	(v_invinc).w
		bne.s	loc_C766
		move.l	a0,-(sp)
		movea.l	a0,a2
		lea	(v_objspace).w,a0
		cmpi.b	#4,obRoutine(a0)
		bcc.s	loc_C764
		move.l	obY(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		jsr	(HurtSonic).l

loc_C764:
		movea.l	(sp)+,a0

loc_C766:
		tst.w	(Two_player_mode).w
		beq.s	loc_C770
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_C770:
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite

; =============== S U B	R O U T	I N E =======================================


sub_C788:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	off_C798(pc,d0.w),d1
		jmp	off_C798(pc,d1.w)
; End of function sub_C788

; ---------------------------------------------------------------------------
off_C798:	dc.w locret_C79E-off_C798
		dc.w loc_C7A0-off_C798
		dc.w loc_C7B4-off_C798
; ---------------------------------------------------------------------------

locret_C79E:
		rts
; ---------------------------------------------------------------------------

loc_C7A0:
		bsr.w	sub_C7C8
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	$32(a0),d0
		move.w	d0,obY(a0)
		rts
; ---------------------------------------------------------------------------

loc_C7B4:
		bsr.w	sub_C7C8
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	$30(a0),d0
		move.w	d0,obX(a0)
		rts

; =============== S U B	R O U T	I N E =======================================


sub_C7C8:
		tst.w	$38(a0)
		beq.s	loc_C7E6
		subq.w	#1,$38(a0)
		bne.s	locret_C828
		tst.b	obRender(a0)
		bpl.s	locret_C828
		move.w	#sfx_SpikesMove,d0
		jsr	(PlaySound_Special).l
		bra.s	locret_C828
; ---------------------------------------------------------------------------

loc_C7E6:
		tst.w	$36(a0)
		beq.s	loc_C808
		subi.w	#$800,$34(a0)
		bcc.s	locret_C828
		move.w	#0,$34(a0)
		move.w	#0,$36(a0)
		move.w	#$3C,$38(a0)
		bra.s	locret_C828
; ---------------------------------------------------------------------------

loc_C808:
		addi.w	#$800,$34(a0)
		cmpi.w	#$2000,$34(a0)
		bcs.s	locret_C828
		move.w	#$2000,$34(a0)
		move.w	#1,$36(a0)
		move.w	#$3C,$38(a0)

locret_C828:
		rts
; End of function sub_C7C8

; ---------------------------------------------------------------------------
Map_Obj36:	dc.w word_C836-Map_Obj36
		dc.w word_C836-Map_Obj36
		dc.w word_C836-Map_Obj36
		dc.w word_C836-Map_Obj36
		dc.w word_C836-Map_Obj36
		dc.w word_C836-Map_Obj36
word_C836:	dc.w 2
		dc.w $F007,    0,    0,$FFF0		; 0
		dc.w $F007,    0,    0,	   0		; 4
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 3B - GHZ Purple Rock
;----------------------------------------------------

Obj3B:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj3B_Index(pc,d0.w),d1
		jmp	Obj3B_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj3B_Index:	dc.w loc_C85A-Obj3B_Index
		dc.w loc_C882-Obj3B_Index
; ---------------------------------------------------------------------------

loc_C85A:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj3B,obMap(a0)
		move.w	#$66C0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$13,obActWid(a0)
		move.b	#4,obPriority(a0)

loc_C882:
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Map_Obj3B:	dc.w word_C8B0-Map_Obj3B
word_C8B0:	dc.w 2
		dc.w $F00B,    0,    0,$FFE8		; 0
		dc.w $F00B,   $C,    6,	   0		; 4
		dc.w 0
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 3C - GHZ smashable wall
;----------------------------------------------------

Obj3C:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj3C_Index(pc,d0.w),d1
		jsr	Obj3C_Index(pc,d1.w)
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------
Obj3C_Index:	dc.w loc_C8DC-Obj3C_Index
		dc.w loc_C90A-Obj3C_Index
		dc.w loc_C988-Obj3C_Index
; ---------------------------------------------------------------------------

loc_C8DC:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj3C,obMap(a0)
		move.w	#$4590,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#4,obPriority(a0)
		move.b	obSubtype(a0),obFrame(a0)

loc_C90A:
		move.w	(v_objspace+obVelX).w,$30(a0)
		move.w	#$1B,d1
		move.w	#$20,d2
		move.w	#$20,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#5,obStatus(a0)
		bne.s	loc_C92E

locret_C92C:
		rts
; ---------------------------------------------------------------------------

loc_C92E:
		lea	(v_objspace).w,a1
		cmpi.b	#2,obAnim(a1)
		bne.s	locret_C92C
		move.w	$30(a0),d0
		bpl.s	loc_C942
		neg.w	d0

loc_C942:
		cmpi.w	#$480,d0
		bcs.s	locret_C92C
		move.w	$30(a0),obVelX(a1)
		addq.w	#4,obX(a1)
		lea	(Obj3C_FragSpdRight).l,a4
		move.w	obX(a0),d0
		cmp.w	obX(a1),d0
		bcs.s	loc_C96E
		subi.w	#8,obX(a1)
		lea	(Obj3C_FragSpdLeft).l,a4

loc_C96E:
		move.w	obVelX(a1),obInertia(a1)
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)
		moveq	#7,d1
		move.w	#$70,d2
		bsr.s	sub_C99E

loc_C988:
		bsr.w	ObjectMove
		addi.w	#$70,obVelY(a0)
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite

; =============== S U B	R O U T	I N E =======================================


sub_C99E:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	4(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#2,a3
		bset	#5,obRender(a0)
		_move.b	obID(a0),d4
		move.b	obRender(a0),d5
		movea.l	a0,a1
		bra.s	loc_C9CA
; ---------------------------------------------------------------------------

loc_C9C2:
		bsr.w	FindFreeObj
		bne.s	loc_CA1C
		addq.w	#8,a3

loc_C9CA:
		move.b	#4,obRoutine(a1)
		_move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.w	(a4)+,obVelX(a1)
		move.w	(a4)+,obVelY(a1)
		cmpa.l	a0,a1
		bcc.s	loc_CA18
		move.l	a0,-(sp)
		movea.l	a1,a0
		bsr.w	ObjectMove
		add.w	d2,obVelY(a0)
		movea.l	(sp)+,a0
		bsr.w	DisplaySprite2

loc_CA18:
		dbf	d1,loc_C9C2

loc_CA1C:
		move.w	#sfx_WallSmash,d0
		jmp	(PlaySound_Special).l
; End of function sub_C99E

; ---------------------------------------------------------------------------
Obj3C_FragSpdRight:dc.w	 $400,$FB00			; 0
		dc.w  $600,$FF00			; 2
		dc.w  $600, $100			; 4
		dc.w  $400, $500			; 6
		dc.w  $600,$FA00			; 8
		dc.w  $800,$FE00			; 10
		dc.w  $800, $200			; 12
		dc.w  $600, $600			; 14
Obj3C_FragSpdLeft:dc.w $FA00,$FA00			; 0
		dc.w $F800,$FE00			; 2
		dc.w $F800, $200			; 4
		dc.w $FA00, $600			; 6
		dc.w $FC00,$FB00			; 8
		dc.w $FA00,$FF00			; 10
		dc.w $FA00, $100			; 12
		dc.w $FC00, $500			; 14
Map_Obj3C:	dc.w word_CA6C-Map_Obj3C
		dc.w word_CAAE-Map_Obj3C
		dc.w word_CAF0-Map_Obj3C
word_CA6C:	dc.w 8
		dc.w $E005,    0,    0,$FFF0		; 0
		dc.w $F005,    0,    0,$FFF0		; 4
		dc.w	 5,    0,    0,$FFF0		; 8
		dc.w $1005,    0,    0,$FFF0		; 12
		dc.w $E005,    4,    2,	   0		; 16
		dc.w $F005,    4,    2,	   0		; 20
		dc.w	 5,    4,    2,	   0		; 24
		dc.w $1005,    4,    2,	   0		; 28
word_CAAE:	dc.w 8
		dc.w $E005,    4,    2,$FFF0		; 0
		dc.w $F005,    4,    2,$FFF0		; 4
		dc.w	 5,    4,    2,$FFF0		; 8
		dc.w $1005,    4,    2,$FFF0		; 12
		dc.w $E005,    4,    2,	   0		; 16
		dc.w $F005,    4,    2,	   0		; 20
		dc.w	 5,    4,    2,	   0		; 24
		dc.w $1005,    4,    2,	   0		; 28
word_CAF0:	dc.w 8
		dc.w $E005,    4,    2,$FFF0		; 0
		dc.w $F005,    4,    2,$FFF0		; 4
		dc.w	 5,    4,    2,$FFF0		; 8
		dc.w $1005,    4,    2,$FFF0		; 12
		dc.w $E005,    8,    4,	   0		; 16
		dc.w $F005,    8,    4,	   0		; 20
		dc.w	 5,    8,    4,	   0		; 24
		dc.w $1005,    8,    4,	   0		; 28
; ---------------------------------------------------------------------------
		nop

; ===========================================================================
; ---------------------------------------------------------------------------
; This runs the code of all the objects that are in Object_RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ObjectsLoad:
RunObjects:
		lea	(v_objspace).w,a0
		moveq	#$7F,d7				; run the first $80 objects out of levels
		moveq	#0,d0
		cmpi.b	#6,(v_objspace+obRoutine).w	; is Sonic dead?
		bcc.s	RunObjectsWhenPlayerIsDead	; if yes, branch

; ---------------------------------------------------------------------------
; This is THE place where each individual object's code gets called from
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_CB44:
RunObject:
		move.b	(a0),d0				; get the object's ID
		beq.s	loc_CB54			; if it's obj00, skip it
		add.w	d0,d0
		add.w	d0,d0				; d0 = object ID * 4
		movea.l	Obj_Index-4(pc,d0.w),a1		; load the address of the object's code
		jsr	(a1)				; dynamic call! to one of the the entries in Obj_Index
		moveq	#0,d0

loc_CB54:
		lea	$40(a0),a0			; load obj address
		dbf	d7,RunObject
		rts
; ---------------------------------------------------------------------------
; this skips certain objects to make enemies and things pause when Sonic dies
; loc_CB5E:
RunObjectsWhenPlayerIsDead:
		moveq	#$1F,d7
		bsr.s	RunObject
		moveq	#$5F,d7

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_CB64:
RunObjectsDisplayOnly:
		moveq	#0,d0
		move.b	(a0),d0				; get the object's ID
		beq.s	loc_CB74			; if it's obj00, skip it
		tst.b	obRender(a0)			; should we render it?
		bpl.s	loc_CB74			; if not, skip it
		bsr.w	DisplaySprite

loc_CB74:
		lea	$40(a0),a0			; load obj address
		dbf	d7,RunObjectsDisplayOnly
		rts
; End of function RunObjects

; ===========================================================================
; ---------------------------------------------------------------------------
; OBJECT POINTER ARRAY ; object pointers ; sprite pointers ; object list ; sprite list
;
; This array contains the pointers to all the objects used in the game.
; ---------------------------------------------------------------------------
Obj_Index:
		dc.l Obj01				; Sonic
		dc.l Obj02				; Tails
		dc.l Obj03				; Collision plane/layer switcher
		dc.l Obj04				; Surface of the water
		dc.l Obj05				; Tails' tails
		dc.l Obj06				; Twisting spiral pathway in EHZ
		dc.l ObjNull
		dc.l Obj08				; Water splash in HPZ
		dc.l Obj09				; (S1) Sonic in the Speical Stage
		dc.l Obj0A				; Small bubbles from Sonic's face while underwater
		dc.l Obj0B				; (S1) Pole that breaks in LZ
		dc.l Obj0C				; Strange floating/falling platform object from CPZ
		dc.l Obj0D				; End of level signpost
		dc.l Obj0E				; Sonic and Tails from the title screen
		dc.l Obj0F				; Mappings test?
		dc.l Obj10				; (S1) Blank, animation test in prototype
		dc.l Obj11				; Bridges in GHZ, EHZ and HPZ
		dc.l Obj12				; Emerald from Hidden Palace Zone
		dc.l Obj13				; Waterfall from Hidden Palace Zone
		dc.l Obj14				; Seesaw from Hill Top Zone
		dc.l Obj15				; Swinging platforms in GHZ, CPZ and EHZ
		dc.l Obj16				; Diagonally moving lift from HTZ
		dc.l Obj17				; (S1) GHZ rotating log helix spikes
		dc.l Obj18				; Stationary/moving platforms from GHZ and EHZ
		dc.l Obj19				; Platform from CPZ
		dc.l Obj1A				; Collapsing platform from GHZ and HPZ
		dc.l ObjNull
		dc.l Obj1C				; Stage decorations in GHZ, EHZ, HTZ and HPZ
		dc.l ObjNull
		dc.l ObjNull
		dc.l Obj1F				; (S1) Crabmeat from GHZ
		dc.l ObjNull
		dc.l Obj21				; Score/Rings/Time display (HUD)
		dc.l Obj22				; (S1) Buzz Bomber from GHZ
		dc.l Obj23				; (S1) Buzz Bomber/Newtron missile
		dc.l Obj24				; (S1) Unused Buzz Bomber missile explosion
		dc.l Obj25				; A ring
		dc.l Obj26				; Monitor
		dc.l Obj27				; An explosion, giving off an animal and 100 points
		dc.l Obj28				; Animal and the 100 points from a badnik
		dc.l Obj29				; "100 points" text
		dc.l Obj2A				; (S1) Small door from SBZ
		dc.l Obj2B				; (S1) Chopper from GHZ
		dc.l Obj2C				; (S1) Jaws from LZ
		dc.l ObjNull
		dc.l Obj2E				; Monitor contents (code for power-up behavior and rising image)
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l Obj34				; (S1) Level title card
		dc.l ObjNull
		dc.l Obj36				; Vertical spikes
		dc.l Obj37				; Scattering rings (generated when Sonic or Tails are hurt and has rings)
		dc.l Obj38				; Shield
		dc.l Obj39				; Game Over/Time Over text
		dc.l Obj3A				; (S1) End of level results screen
		dc.l Obj3B				; (S1) Purple rock from GHZ
		dc.l Obj3C				; (S1) Breakable wall
		dc.l Obj3D				; (S1) GHZ boss
		dc.l Obj3E				; Egg prison
		dc.l Obj3F				; Boss explosion
		dc.l Obj40				; (S1) Motobug from GHZ
		dc.l Obj41				; Spring
		dc.l Obj42				; (S1) Newtron from GHZ
		dc.l ObjNull
		dc.l Obj44				; (S1) Unbreakable wall
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l Obj48				; (S1) Eggman's wrecking ball
		dc.l Obj49				; Waterfall sound effect
		dc.l Obj4A				; Octus from HPZ
		dc.l Obj4B				; Buzzer from EHZ
		dc.l Obj4C				; BBat from HPZ
		dc.l Obj4D				; Stego/Stegway from HPZ
		dc.l Obj4E				; Gator from HPZ
		dc.l Obj4F				; Redz (dinosaur badnik) from HPZ
		dc.l Obj50				; Seahorse/Aquis from HPZ
		dc.l Obj51				; Skyhorse from HPZ
		dc.l Obj52				; BFish from HPZ
		dc.l Obj53				; Masher from EHZ
		dc.l Obj54				; Snail badnik from EHZ
		dc.l Obj55				; EHZ boss
		dc.l Obj56				; EHZ boss part 2
		dc.l Obj57				; EHZ boss part 3
		dc.l Obj58				; EHZ boss part 4
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l Obj79				; Checkpoint
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l Obj7D				; (S1) Hidden points at end of stage
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l ObjNull
		dc.l Obj8A				; (S1) "SONIC TEAM PRESENTS" screen and credits
		dc.l ObjNull
		dc.l ObjNull
; ===========================================================================
; blank object, allocates its array
; jmp_DeleteObject:
ObjNull:
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Subroutine to make an object move and fall downward increasingly fast
; This moves the object horizontally and vertically
; and also applies gravity to its speed
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ObjectFall:
ObjectMoveAndFall:
		move.l	obX(a0),d2			; load x position
		move.l	obY(a0),d3			; load y position
		move.w	obVelX(a0),d0			; load x speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d2				; add x speed to x position
		move.w	obVelY(a0),d0			; load y speed
		addi.w	#$38,obVelY(a0)			; increase vertical speed (apply gravity)
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d3				; add old y speed to y position
		move.l	d2,obX(a0)			; store new x position
		move.l	d3,obY(a0)			; store new y position
		rts
; End of function ObjectMoveAndFall

; ---------------------------------------------------------------------------
; Subroutine translating object speed to update object position
; This moves the object horizontally and vertically
; but does not apply gravity to it
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; SpeedToPos:
ObjectMove:
		move.l	obX(a0),d2			; load x position
		move.l	obY(a0),d3			; load y position
		move.w	obVelX(a0),d0			; load x speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d2				; add x speed to x position
		move.w	obVelY(a0),d0			; load y speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d3				; add old y speed to y position
		move.l	d2,obX(a0)			; store new x position
		move.l	d3,obY(a0)			; store new y position
		rts
; End of function ObjectMove

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite:
		lea	(v_spritequeue).w,a1
		move.w	obPriority(a0),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a1
		cmpi.w	#$7E,(a1)
		bcc.s	locret_CE20
		addq.w	#2,(a1)
		adda.w	(a1),a1
		move.w	a0,(a1)

locret_CE20:
		rts
; End of function DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DisplayA1Sprite:
DisplaySprite2:
		lea	(v_spritequeue).w,a2
		move.w	obPriority(a1),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a2
		cmpi.w	#$7E,(a2)
		bcc.s	locret_CE3E
		addq.w	#2,(a2)
		adda.w	(a2),a2
		move.w	a1,(a2)

locret_CE3E:
		rts
; End of function DisplaySprite2

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; and d0 is already (priority/2)&$380
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DisplaySprite_Param:
DisplaySprite3:
		lea	(v_spritequeue).w,a1
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a1
		cmpi.w	#$7E,(a1)
		bcc.s	locret_CE58
		addq.w	#2,(a1)
		adda.w	(a1),a1
		move.w	a0,(a1)

locret_CE58:
		rts
; End of function DisplaySprite3

; ===========================================================================
; ---------------------------------------------------------------------------
; Routines to mark an enemy/monitor/ring/platform as destroyed
; a0 = the object
; ---------------------------------------------------------------------------

MarkObjGone:
		tst.w	(Two_player_mode).w
		beq.s	loc_CE64
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_CE64:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_CE7C
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_CE7C:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_CE8E
		bclr	#7,2(a2,d0.w)

loc_CE8E:
		bra.w	DeleteObject
; ===========================================================================
; does nothing instead of calling DisplaySprite in the case of no deletion
; loc_CE92:
MarkObjGone2:
		tst.w	(Two_player_mode).w
		beq.s	loc_CE9A
		rts
; ---------------------------------------------------------------------------

loc_CE9A:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_CEB0
		rts
; ---------------------------------------------------------------------------

loc_CEB0:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_CEC2
		bclr	#7,2(a2,d0.w)

loc_CEC2:
		bra.w	DeleteObject
; ===========================================================================
; first player in two player mode
; loc_CEC6:
MarkObjGone_P1:
		tst.w	(Two_player_mode).w
		bne.s	MarkObjGone_P2
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_CEE4
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_CEE4:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_CEF6
		bclr	#7,2(a2,d0.w)

loc_CEF6:
		bra.w	DeleteObject
; ===========================================================================
; second player in two player mode
; loc_CEFA:
MarkObjGone_P2:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		move.w	d0,d1
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_CF14
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_CF14:
		sub.w	(Camera_X_pos_coarse_P2).w,d1
		cmpi.w	#$280,d1
		bhi.w	loc_CF24
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_CF24:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_CF36
		bclr	#7,2(a2,d0.w)

loc_CF36:
		bra.w	DeleteObject			; useless branch...

; ---------------------------------------------------------------------------
; Subroutine to delete an object
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


DeleteObject:
		movea.l	a0,a1
; sub_CF3C:
DeleteObject2:
		moveq	#0,d1
		moveq	#$F,d0				; we want to clear up to the next object
		; delete the object by setting all of its bytes to 0
loc_CF40:
		move.l	d1,(a1)+
		dbf	d0,loc_CF40
		rts
; End of function DeleteObject

; ---------------------------------------------------------------------------
; Subroutine to animate a sprite using an animation script
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


AnimateSprite:
		moveq	#0,d0
		move.b	obAnim(a0),d0			; move animation number to d0
		cmp.b	obPrevAni(a0),d0		; is animation set to change?
		beq.s	Anim_Run			; if not, branch
		move.b	d0,obPrevAni(a0)		; set previous animation to current one
		move.b	#0,obAniFrame(a0)		; reset animation
		move.b	#0,obTimeFrame(a0)		; reset frame duration
; loc_CF64:
Anim_Run:
		subq.b	#1,obTimeFrame(a0)		; subtract 1 from frame duration
		bpl.s	Anim_Wait			; if time remains, branch
		add.w	d0,d0
		adda.w	(a1,d0.w),a1			; calculate address of appropriate animation script
		move.b	(a1),obTimeFrame(a0)		; load frame duration
		moveq	#0,d1
		move.b	obAniFrame(a0),d1		; load current frame number
		move.b	1(a1,d1.w),d0			; read sprite number from script
		bmi.s	Anim_End_FF			; if animation is complete, branch
; loc_CF80:
Anim_Next:
		move.b	d0,d1				; move animation number to current frame number
		andi.b	#$1F,d0
		move.b	d0,obFrame(a0)			; load sprite number
		move.b	obStatus(a0),d0			; match the orientation dictated by the object
		rol.b	#3,d1				; with the orientation used by the object engine
		eor.b	d0,d1
		andi.b	#3,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		addq.b	#1,obAniFrame(a0)		; next frame number
; locret_CFA4:
Anim_Wait:
		rts
; ===========================================================================
; loc_CFA6:
Anim_End_FF:
		addq.b	#1,d0				; is the end flag = $FF ?
		bne.s	Anim_End_FE			; if not, branch
		move.b	#0,obAniFrame(a0)		; restart the animation
		move.b	1(a1),d0			; read sprite number
		bra.s	Anim_Next
; ===========================================================================
; loc_CFB6:
Anim_End_FE:
		addq.b	#1,d0				; is the end flag = $FE ?
		bne.s	Anim_End_FD			; if not, branch
		move.b	2(a1,d1.w),d0			; read the next byte in the script
		sub.b	d0,obAniFrame(a0)		; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0			; read sprite number
		bra.s	Anim_Next
; ===========================================================================
; loc_CFCA:
Anim_End_FD:
		addq.b	#1,d0				; is the end flag = $FD ?
		bne.s	Anim_End_FC			; if not, branch
		move.b	2(a1,d1.w),obAnim(a0)		; read next byte, run that animation
		rts
; ===========================================================================
; loc_CFD6:
Anim_End_FC:
		addq.b	#1,d0				; is the end flag = $FC ?
		bne.s	Anim_End_FB			; if not, branch
		addq.b	#2,obRoutine(a0)		; jump to next routine
		rts
; ===========================================================================
; loc_CFE0:
Anim_End_FB:
		addq.b	#1,d0				; is the end flag = $FB ?
		bne.s	Anim_End_FA			; if not, branch
		move.b	#0,obAniFrame(a0)		; reset animation
		clr.b	ob2ndRout(a0)			; reset 2nd routine counter
		rts
; ===========================================================================
; loc_CFF0:
Anim_End_FA:
		addq.b	#1,d0				; is the end flag = $FA ?
		bne.s	Anim_End			; if not, branch
		addq.b	#2,ob2ndRout(a0)		; jump to next routine
		rts
; ===========================================================================
; locret_CFFA:
Anim_End:
		rts
; End of function AnimateSprite

; ---------------------------------------------------------------------------
BldSpr_ScrPos:	dc.l 0
		dc.l Camera_RAM
		dc.l Camera_BG_X_pos
		dc.l Camera_BG3_X_pos

; =============== S U B	R O U T	I N E =======================================


BuildSprites:
		tst.w	(Two_player_mode).w
		bne.w	BuildSprites_2p
		lea	(Sprite_Table).w,a2
		moveq	#0,d5
		moveq	#0,d4
		tst.b	(Level_started_flag).w
		beq.s	loc_D026
		bsr.w	BuildSprites2

loc_D026:
		lea	(v_spritequeue).w,a4
		moveq	#7,d7

loc_D02C:
		tst.w	(a4)
		beq.w	loc_D102
		moveq	#2,d6

loc_D034:
		movea.w	(a4,d6.w),a0
		tst.b	(a0)
		beq.w	loc_D124
		tst.l	4(a0)
		beq.w	loc_D124
		andi.b	#$7F,obRender(a0)
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_D126
		andi.w	#$C,d0
		beq.s	loc_D0B2
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D0FA
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.w	loc_D0FA
		addi.w	#$80,d3
		btst	#4,d4
		beq.s	loc_D0BC
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D0FA
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#$E0,d1
		bge.s	loc_D0FA
		addi.w	#$80,d2
		bra.s	loc_D0D4
; ---------------------------------------------------------------------------

loc_D0B2:
		move.w	$A(a0),d2
		move.w	obX(a0),d3
		bra.s	loc_D0D4
; ---------------------------------------------------------------------------

loc_D0BC:
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D0FA
		cmpi.w	#$180,d2
		bcc.s	loc_D0FA

loc_D0D4:
		movea.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D0F0
		move.b	obFrame(a0),d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D0F4

loc_D0F0:
		bsr.w	sub_D1B6

loc_D0F4:
		ori.b	#$80,obRender(a0)

loc_D0FA:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D034

loc_D102:
		lea	$80(a4),a4
		dbf	d7,loc_D02C
		move.b	d5,($FFFFF62C).w
		cmpi.b	#$50,d5
		beq.s	loc_D11C
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

loc_D11C:
		move.b	#0,-5(a2)
		rts
; ---------------------------------------------------------------------------

loc_D124:
		bra.s	loc_D0FA
; ---------------------------------------------------------------------------

loc_D126:
		move.l	a4,-(sp)
		lea	(Camera_RAM).w,a4
		movea.w	2(a0),a3
		movea.l	4(a0),a5
		moveq	#0,d0
		move.b	$E(a0),d0
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D1B0
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.s	loc_D1B0
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D1B0
		cmpi.w	#$180,d2
		bcc.s	loc_D1B0
		ori.b	#$80,obRender(a0)
		lea	obVelX(a0),a6
		moveq	#0,d0
		move.b	$F(a0),d0
		subq.w	#1,d0
		bcs.s	loc_D1B0

loc_D17E:
		swap	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		addi.w	#$80,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		addi.w	#$80,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D1AA
		bsr.w	sub_D1BA

loc_D1AA:
		swap	d0
		dbf	d0,loc_D17E

loc_D1B0:
		movea.l	(sp)+,a4
		bra.w	loc_D0FA
; End of function BuildSprites


; =============== S U B	R O U T	I N E =======================================


sub_D1B6:
		movea.w	2(a0),a3
; End of function sub_D1B6


; =============== S U B	R O U T	I N E =======================================


sub_D1BA:
		cmpi.b	#$50,d5
		bcc.s	locret_D1F6
		btst	#0,d4
		bne.s	loc_D1F8
		btst	#1,d4
		bne.w	loc_D258

loc_D1CE:
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D1F0
		addq.w	#1,d0

loc_D1F0:
		move.w	d0,(a2)+
		dbf	d1,loc_D1CE

locret_D1F6:
		rts
; ---------------------------------------------------------------------------

loc_D1F8:
		btst	#1,d4
		bne.w	loc_D2A0

loc_D200:
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D238(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D230
		addq.w	#1,d0

loc_D230:
		move.w	d0,(a2)+
		dbf	d1,loc_D200
		rts
; ---------------------------------------------------------------------------
byte_D238:	dc.b   8,  8,  8,  8			; 0
		dc.b $10,$10,$10,$10			; 4
		dc.b $18,$18,$18,$18			; 8
		dc.b $20,$20,$20,$20			; 12
byte_D248:	dc.b   8,$10,$18,$20			; 0
		dc.b   8,$10,$18,$20			; 4
		dc.b   8,$10,$18,$20			; 8
		dc.b   8,$10,$18,$20			; 12
; ---------------------------------------------------------------------------

loc_D258:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D248(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D288
		addq.w	#1,d0

loc_D288:
		move.w	d0,(a2)+
		dbf	d1,loc_D258
		rts
; ---------------------------------------------------------------------------
byte_D290:	dc.b   8,$10,$18,$20			; 0
		dc.b   8,$10,$18,$20			; 4
		dc.b   8,$10,$18,$20			; 8
		dc.b   8,$10,$18,$20			; 12
; ---------------------------------------------------------------------------

loc_D2A0:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D290(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D2E2(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D2DA
		addq.w	#1,d0

loc_D2DA:
		move.w	d0,(a2)+
		dbf	d1,loc_D2A0
		rts
; End of function sub_D1BA

; ---------------------------------------------------------------------------
byte_D2E2:	dc.b   8,  8,  8,  8			; 0
		dc.b $10,$10,$10,$10			; 4
		dc.b $18,$18,$18,$18			; 8
		dc.b $20,$20,$20,$20			; 12
BldSpr_ScrPos_2p:dc.l 0
		dc.l Camera_RAM
		dc.l Camera_BG_X_pos
		dc.l Camera_BG3_X_pos
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR BuildSprites

BuildSprites_2p:
		tst.w	(f_hbla_pal).w
		bne.s	BuildSprites_2p
		lea	(Sprite_Table).w,a2
		moveq	#2,d5
		moveq	#0,d4
		move.l	#$1D80F01,(a2)+
		move.l	#1,(a2)+
		move.l	#$1D80F02,(a2)+
		move.l	#0,(a2)+
		tst.b	(Level_started_flag).w
		beq.s	loc_D332
		bsr.w	BuildSprites2_2p

loc_D332:
		lea	(v_spritequeue).w,a4
		moveq	#7,d7

loc_D338:
		move.w	(a4),d0
		beq.w	loc_D410
		move.w	d0,-(sp)
		moveq	#2,d6

loc_D342:
		movea.w	(a4,d6.w),a0
		tst.b	(a0)
		beq.w	loc_D406
		andi.b	#$7F,obRender(a0)
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_D54A
		andi.w	#$C,d0
		beq.s	loc_D3B6
		movea.l	BldSpr_ScrPos_2p(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D406
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.s	loc_D406
		addi.w	#$80,d3
		btst	#4,d4
		beq.s	loc_D3C4
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D406
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#$E0,d1
		bge.s	loc_D406
		addi.w	#$100,d2
		bra.s	loc_D3E0
; ---------------------------------------------------------------------------

loc_D3B6:
		move.w	$A(a0),d2
		move.w	obX(a0),d3
		addi.w	#$80,d2
		bra.s	loc_D3E0
; ---------------------------------------------------------------------------

loc_D3C4:
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D406
		cmpi.w	#$180,d2
		bcc.s	loc_D406
		addi.w	#$80,d2

loc_D3E0:
		movea.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D3FC
		move.b	obFrame(a0),d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D400

loc_D3FC:
		bsr.w	sub_D6A2

loc_D400:
		ori.b	#$80,obRender(a0)

loc_D406:
		addq.w	#2,d6
		subq.w	#2,(sp)
		bne.w	loc_D342
		addq.w	#2,sp

loc_D410:
		lea	$80(a4),a4
		dbf	d7,loc_D338
		move.b	d5,($FFFFF62C).w
		cmpi.b	#$50,d5
		bcc.s	loc_D42A
		move.l	#0,(a2)
		bra.s	loc_D442
; ---------------------------------------------------------------------------

loc_D42A:
		move.b	#0,-5(a2)
		bra.s	loc_D442
; END OF FUNCTION CHUNK	FOR BuildSprites
; ---------------------------------------------------------------------------
dword_D432:	dc.l 0
		dc.l Camera_X_pos_P2
		dc.l Camera_BG_X_pos_P2
		dc.l Camera_BG3_X_pos_P2
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR BuildSprites

loc_D442:
		lea	(v_spritetablebuffer).w,a2
		moveq	#0,d5
		moveq	#0,d4
		tst.b	(Level_started_flag).w
		beq.s	loc_D454
		bsr.w	sub_DACA

loc_D454:
		lea	(v_spritequeue).w,a4
		moveq	#7,d7

loc_D45A:
		tst.w	(a4)
		beq.w	loc_D528
		moveq	#2,d6

loc_D462:
		movea.w	(a4,d6.w),a0
		tst.b	(a0)
		beq.w	loc_D520
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_D5DA
		andi.w	#$C,d0
		beq.s	loc_D4D0
		movea.l	dword_D432(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D520
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.s	loc_D520
		addi.w	#$80,d3
		btst	#4,d4
		beq.s	loc_D4DE
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D520
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#$E0,d1
		bge.s	loc_D520
		addi.w	#$1E0,d2
		bra.s	loc_D4FA
; ---------------------------------------------------------------------------

loc_D4D0:
		move.w	$A(a0),d2
		move.w	obX(a0),d3
		addi.w	#$160,d2
		bra.s	loc_D4FA
; ---------------------------------------------------------------------------

loc_D4DE:
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D520
		cmpi.w	#$180,d2
		bcc.s	loc_D520
		addi.w	#$160,d2

loc_D4FA:
		movea.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D516
		move.b	obFrame(a0),d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D51A

loc_D516:
		bsr.w	sub_D6A2

loc_D51A:
		ori.b	#$80,obRender(a0)

loc_D520:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D462

loc_D528:
		lea	$80(a4),a4
		dbf	d7,loc_D45A
		move.b	d5,($FFFFF62C).w
		cmpi.b	#$50,d5
		beq.s	loc_D542
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

loc_D542:
		move.b	#0,-5(a2)
		rts
; ---------------------------------------------------------------------------

loc_D54A:
		move.l	a4,-(sp)
		lea	(Camera_RAM).w,a4
		movea.w	2(a0),a3
		movea.l	4(a0),a5
		moveq	#0,d0
		move.b	$E(a0),d0
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D5D4
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.s	loc_D5D4
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D5D4
		cmpi.w	#$180,d2
		bcc.s	loc_D5D4
		ori.b	#$80,obRender(a0)
		lea	obVelX(a0),a6
		moveq	#0,d0
		move.b	$F(a0),d0
		subq.w	#1,d0
		bcs.s	loc_D5D4

loc_D5A2:
		swap	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		addi.w	#$80,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		addi.w	#$100,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D5CE
		bsr.w	sub_D6A6

loc_D5CE:
		swap	d0
		dbf	d0,loc_D5A2

loc_D5D4:
		movea.l	(sp)+,a4
		bra.w	loc_D406
; ---------------------------------------------------------------------------

loc_D5DA:
		move.l	a4,-(sp)
		lea	(Camera_X_pos_P2).w,a4
		movea.w	2(a0),a3
		movea.l	4(a0),a5
		moveq	#0,d0
		move.b	$E(a0),d0
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D664
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.s	loc_D664
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D664
		cmpi.w	#$180,d2
		bcc.s	loc_D664
		ori.b	#$80,obRender(a0)
		lea	obVelX(a0),a6
		moveq	#0,d0
		move.b	$F(a0),d0
		subq.w	#1,d0
		bcs.s	loc_D664

loc_D632:
		swap	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		addi.w	#$80,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		addi.w	#$1E0,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D65E
		bsr.w	sub_D6A6

loc_D65E:
		swap	d0
		dbf	d0,loc_D632

loc_D664:
		movea.l	(sp)+,a4
		bra.w	loc_D520
; END OF FUNCTION CHUNK	FOR BuildSprites


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; adjust art pointer of object at a0 for 2-player mode
; ModifySpriteAttr_2P:
Adjust2PArtPointer:
		tst.w	(Two_player_mode).w
		beq.s	locret_D684
		move.w	2(a0),d0
		andi.w	#$7FF,d0
		lsr.w	#1,d0
		andi.w	#$F800,obGfx(a0)
		add.w	d0,obGfx(a0)

locret_D684:
		rts
; End of function Adjust2PArtPointer


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; adjust art pointer of object at a1 for 2-player mode
; ModifyA1SpriteAttr_2P:
Adjust2PArtPointer2:
		tst.w	(Two_player_mode).w
		beq.s	locret_D6BE
		move.w	2(a1),d0
		andi.w	#$7FF,d0
		lsr.w	#1,d0
		andi.w	#$F800,obGfx(a1)
		add.w	d0,obGfx(a1)

locret_D6BE
		rts
; End of function Adjust2PArtPointer2


; =============== S U B	R O U T	I N E =======================================


sub_D6A2:
		movea.w	2(a0),a3
; End of function sub_D6A2


; =============== S U B	R O U T	I N E =======================================


sub_D6A6:
		cmpi.b	#$50,d5
		bcc.s	locret_D6E6
		btst	#0,d4
		bne.s	loc_D6F8
		btst	#1,d4
		bne.w	loc_D75A

loc_D6BA:
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D6E8(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D6E0
		addq.w	#1,d0

loc_D6E0:
		move.w	d0,(a2)+
		dbf	d1,loc_D6BA

locret_D6E6:
		rts
; ---------------------------------------------------------------------------
byte_D6E8:	dc.b   0,  0				; 0
		dc.b   1,  1				; 2
		dc.b   4,  4				; 4
		dc.b   5,  5				; 6
		dc.b   8,  8				; 8
		dc.b   9,  9				; 10
		dc.b  $C, $C				; 12
		dc.b  $D, $D				; 14
; ---------------------------------------------------------------------------

loc_D6F8:
		btst	#1,d4
		bne.w	loc_D7B6

loc_D700:
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D6E8(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D73A(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D732
		addq.w	#1,d0

loc_D732:
		move.w	d0,(a2)+
		dbf	d1,loc_D700
		rts
; ---------------------------------------------------------------------------
byte_D73A:	dc.b   8,  8				; 0
		dc.b   8,  8				; 2
		dc.b $10,$10				; 4
		dc.b $10,$10				; 6
		dc.b $18,$18				; 8
		dc.b $18,$18				; 10
		dc.b $20,$20				; 12
		dc.b $20,$20				; 14
byte_D74A:	dc.b   8,$10,$18,$20			; 0
		dc.b   8,$10,$18,$20			; 4
		dc.b   8,$10,$18,$20			; 8
		dc.b   8,$10,$18,$20			; 12
; ---------------------------------------------------------------------------

loc_D75A:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D74A(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D796(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D78E
		addq.w	#1,d0

loc_D78E:
		move.w	d0,(a2)+
		dbf	d1,loc_D75A
		rts
; ---------------------------------------------------------------------------
byte_D796:	dc.b   0,  0,  1,  1			; 0
		dc.b   4,  4,  5,  5			; 4
		dc.b   8,  8,  9,  9			; 8
		dc.b  $C, $C, $D, $D			; 12
byte_D7A6:	dc.b   8,$10,$18,$20			; 0
		dc.b   8,$10,$18,$20			; 4
		dc.b   8,$10,$18,$20			; 8
		dc.b   8,$10,$18,$20			; 12
; ---------------------------------------------------------------------------

loc_D7B6:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D7A6(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D796(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D7FA(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D7F2
		addq.w	#1,d0

loc_D7F2:
		move.w	d0,(a2)+
		dbf	d1,loc_D7B6
		rts
; End of function sub_D6A6

; ---------------------------------------------------------------------------
byte_D7FA:	dc.b   8,  8,  8,  8			; 0
		dc.b $10,$10,$10,$10			; 4
		dc.b $18,$18,$18,$18			; 8
		dc.b $20,$20,$20,$20			; 12
		dc.b $30,$28,  0,  8			; 16
; ---------------------------------------------------------------------------
		sub.w	(Camera_RAM).w,d0
		bmi.s	loc_D82E
		cmpi.w	#$140,d0
		bge.s	loc_D82E
		move.w	obY(a0),d1
		sub.w	(Camera_Y_pos).w,d1
		bmi.s	loc_D82E
		cmpi.w	#$E0,d1
		bge.s	loc_D82E
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_D82E:
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	obX(a0),d0
		sub.w	(Camera_RAM).w,d0
		add.w	d1,d0
		bmi.s	loc_D862
		add.w	d1,d1
		sub.w	d1,d0
		cmpi.w	#$140,d0
		bge.s	loc_D862
		move.w	obY(a0),d1
		sub.w	(Camera_Y_pos).w,d1
		bmi.s	loc_D862
		cmpi.w	#$E0,d1
		bge.s	loc_D862
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_D862:
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------
		nop

; ============================================================================
; ----------------------------------------------------------------------------
; Pseudo-object that manages where rings are placed onscreen
; as you move through the level, and otherwise updates them.
; ----------------------------------------------------------------------------

; RingPosLoad:
RingsManager:
		moveq	#0,d0
		move.b	(Rings_manager_routine).w,d0
		move.w	RingsManager_States(pc,d0.w),d0
		jmp	RingsManager_States(pc,d0.w)
; End of function RingsManager

; ===========================================================================
; RPL_Index:
RingsManager_States:
		dc.w RingsManager_Init-RingsManager_States
		dc.w RingsManager_Main-RingsManager_States
; ===========================================================================
; RPL_Main:
RingsManager_Init:
		addq.b	#2,(Rings_manager_routine).w	; => RingsManager_Main
		bsr.w	RingsManager_Setup		; perform initial setup
		lea	(Ring_Positions).w,a1
		move.w	(Camera_RAM).w,d4
		subq.w	#8,d4
		bhi.s	loc_D896
		moveq	#1,d4				; no negative values allowed
		bra.s	loc_D896
; ---------------------------------------------------------------------------

loc_D892:
		lea	6(a1),a1			; load next ring

loc_D896:
		cmp.w	2(a1),d4			; is the X pos of the ring < camera X pos?
		bhi.s	loc_D892			; if it is, check next ring
		move.w	a1,(Ring_start_addr).w		; set start addresses
		move.w	a1,(Ring_start_addr_P2).w
		addi.w	#$150,d4			; advance by a screen
		bra.s	loc_D8AE
; ---------------------------------------------------------------------------

loc_D8AA:
		lea	6(a1),a1			; load next ring

loc_D8AE:
		cmp.w	2(a1),d4			; is the X pos of the ring < camera X + 336?
		bhi.s	loc_D8AA			; if it is, check next ring
		move.w	a1,(Ring_end_addr).w		; set end addresses
		move.w	a1,(Ring_end_addr_P2).w
		move.b	#1,(Level_started_flag).w
		rts
; ===========================================================================
; RPL_Next:
RingsManager_Main:
		lea	(Ring_Positions).w,a1
		move.w	#$FF,d1

loc_D8CC:
		move.b	(a1),d0				; is there a ring in this slot?
		beq.s	loc_D8EA			; if not, branch
		bmi.s	loc_D8EA
		subq.b	#1,(a1)				; decrement timer
		bne.s	loc_D8EA			; if it's not 0 yet, branch
		move.b	#6,(a1)				; reset timer
		addq.b	#1,1(a1)			; increment frame
		cmpi.b	#8,1(a1)			; is it destruction time yet?
		bne.s	loc_D8EA			; if not, branch
		move.w	#-1,(a1)			; destroy ring

loc_D8EA:
		lea	6(a1),a1
		dbf	d1,loc_D8CC

		; update ring start and end addresses
		movea.w	(Ring_start_addr).w,a1
		move.w	(Camera_RAM).w,d4
		subq.w	#8,d4
		bhi.s	loc_D906
		moveq	#1,d4
		bra.s	loc_D906
; ---------------------------------------------------------------------------

loc_D902:
		lea	6(a1),a1

loc_D906:
		cmp.w	2(a1),d4
		bhi.s	loc_D902
		bra.s	loc_D910
; ---------------------------------------------------------------------------

loc_D90E:
		subq.w	#6,a1

loc_D910:
		cmp.w	-4(a1),d4
		bls.s	loc_D90E
		move.w	a1,(Ring_start_addr).w		; update start address

		movea.w	(Ring_end_addr).w,a2
		addi.w	#$150,d4
		bra.s	loc_D928
; ---------------------------------------------------------------------------

loc_D924:
		lea	6(a2),a2

loc_D928:
		cmp.w	2(a2),d4
		bhi.s	loc_D924
		bra.s	loc_D932
; ---------------------------------------------------------------------------

loc_D930:
		subq.w	#6,a2

loc_D932:
		cmp.w	-4(a2),d4
		bls.s	loc_D930
		move.w	a2,(Ring_end_addr).w		; update end address
		tst.w	(Two_player_mode).w		; are we in 2P mode?
		bne.s	loc_D94C			; if we are, update P2 addresses
		move.w	a1,(Ring_start_addr_P2).w	; otherwise, copy over P1 addresses
		move.w	a2,(Ring_end_addr_P2).w
		rts
; ---------------------------------------------------------------------------

loc_D94C:
		; update ring start and end addresses for P2
		movea.w	(Ring_start_addr_P2).w,a1
		move.w	(Camera_X_pos_P2).w,d4
		subq.w	#8,d4
		bhi.s	loc_D960
		moveq	#1,d4
		bra.s	loc_D960
; ---------------------------------------------------------------------------

loc_D95C:
		lea	6(a1),a1

loc_D960:
		cmp.w	2(a1),d4
		bhi.s	loc_D95C
		bra.s	loc_D96A
; ---------------------------------------------------------------------------

loc_D968:
		subq.w	#6,a1

loc_D96A:
		cmp.w	-4(a1),d4
		bls.s	loc_D968
		move.w	a1,(Ring_start_addr_P2).w	; update start address

		movea.w	(Ring_end_addr_P2).w,a2
		addi.w	#$150,d4
		bra.s	loc_D982
; ---------------------------------------------------------------------------

loc_D97E:
		lea	6(a2),a2

loc_D982:
		cmp.w	2(a2),d4
		bhi.s	loc_D97E
		bra.s	loc_D98C
; ---------------------------------------------------------------------------

loc_D98A:
		subq.w	#6,a2

loc_D98C:
		cmp.w	-4(a2),d4
		bls.s	loc_D98A
		move.w	a2,(Ring_end_addr_P2).w		; update end address
		rts

; ---------------------------------------------------------------------------
; Subroutine to handle ring collision
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_D998:
Touch_Rings:
		movea.w	(Ring_start_addr).w,a1
		movea.w	(Ring_end_addr).w,a2
		cmpa.w	#v_objspace,a0
		beq.s	loc_D9AE
		movea.w	(Ring_start_addr_P2).w,a1
		movea.w	(Ring_end_addr_P2).w,a2

loc_D9AE:
		cmpa.l	a1,a2
		beq.w	locret_DA36
		cmpi.w	#$5A,$30(a0)
		bcc.s	locret_DA36
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
		cmpi.b	#$39,obFrame(a0)
		bne.s	loc_D9E0
		addi.w	#$C,d3
		moveq	#$A,d5

loc_D9E0:
		move.w	#6,d1
		move.w	#$C,d6
		move.w	#$10,d4
		add.w	d5,d5

loc_D9EE:
		tst.w	(a1)
		bne.w	loc_DA2C
		move.w	2(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_DA06
		add.w	d6,d0
		bcs.s	loc_DA0C
		bra.w	loc_DA2C
; ---------------------------------------------------------------------------

loc_DA06:
		cmp.w	d4,d0
		bhi.w	loc_DA2C

loc_DA0C:
		move.w	4(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_DA1E
		add.w	d6,d0
		bcs.s	loc_DA24
		bra.w	loc_DA2C
; ---------------------------------------------------------------------------

loc_DA1E:
		cmp.w	d5,d0
		bhi.w	loc_DA2C

loc_DA24:
		move.w	#$604,(a1)
		bsr.w	sub_A8DE

loc_DA2C:
		lea	6(a1),a1
		cmpa.l	a1,a2
		bne.w	loc_D9EE

locret_DA36:
		rts
; End of function Touch_Rings


; =============== S U B	R O U T	I N E =======================================


BuildSprites2:
		movea.w	(Ring_start_addr).w,a0
		movea.w	(Ring_end_addr).w,a4
		cmpa.l	a0,a4
		bne.s	loc_DA46
		rts
; ---------------------------------------------------------------------------

loc_DA46:
		lea	(Camera_RAM).w,a3

loc_DA4A:
		tst.w	(a0)
		bmi.w	loc_DAA8
		move.w	2(a0),d3
		sub.w	(a3),d3
		addi.w	#$80,d3
		move.w	4(a0),d2
		sub.w	4(a3),d2
		addi.w	#8,d2
		bmi.s	loc_DAA8
		cmpi.w	#$F0,d2
		bge.s	loc_DAA8
		addi.w	#$78,d2
		lea	(off_DC04).l,a1
		moveq	#0,d1
		move.b	1(a0),d1
		bne.s	loc_DA84
		move.b	(v_ani1_frame).w,d1

loc_DA84:
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		addi.w	#$26BC,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a2)+

loc_DAA8:
		lea	6(a0),a0
		cmpa.l	a0,a4
		bne.w	loc_DA4A
		rts
; End of function BuildSprites2


; =============== S U B	R O U T	I N E =======================================


BuildSprites2_2p:
		lea	(Camera_RAM).w,a3
		move.w	#$78,d6
		movea.w	(Ring_start_addr).w,a0
		movea.w	(Ring_end_addr).w,a4
		cmpa.l	a0,a4
		bne.s	loc_DAE0
		rts
; End of function BuildSprites2_2p


; =============== S U B	R O U T	I N E =======================================


sub_DACA:
		lea	(Camera_X_pos_P2).w,a3
		move.w	#$158,d6
		movea.w	(Ring_start_addr_P2).w,a0
		movea.w	(Ring_end_addr_P2).w,a4
		cmpa.l	a0,a4
		bne.s	loc_DAE0
		rts
; ---------------------------------------------------------------------------

loc_DAE0:
		tst.w	(a0)
		bmi.w	loc_DB40
		move.w	2(a0),d3
		sub.w	(a3),d3
		addi.w	#$80,d3
		move.w	4(a0),d2
		sub.w	4(a3),d2
		addi.w	#$88,d2
		bmi.s	loc_DB40
		cmpi.w	#$170,d2
		bge.s	loc_DB40
		add.w	d6,d2
		lea	(off_DC04).l,a1
		moveq	#0,d1
		move.b	1(a0),d1
		bne.s	loc_DB18
		move.b	(v_ani1_frame).w,d1

loc_DB18:
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_DB4C(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		addi.w	#$235E,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a2)+

loc_DB40:
		lea	6(a0),a0
		cmpa.l	a0,a4
		bne.w	loc_DAE0
		rts
; End of function sub_DACA

; ---------------------------------------------------------------------------
byte_DB4C:	dc.b   0,  0,  1,  1			; 0
		dc.b   4,  4,  5,  5			; 4
		dc.b   8,  8,  9,  9			; 8
		dc.b  $C, $C, $D, $D			; 12

; ---------------------------------------------------------------------------
; Subroutine to perform initial rings manager setup
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; RingsManager2:
RingsManager_Setup:
		lea	(Ring_Positions).w,a1
		moveq	#0,d0
		move.w	#$17F,d1

loc_DB66:
		move.l	d0,(a1)+
		dbf	d1,loc_DB66
		moveq	#0,d0
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		lea	(RingPos_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		lea	(Ring_Positions+6).w,a2
; loc_DB88:
RingsMgr_NextRowOrCol:
		move.w	(a1)+,d2
		bmi.s	RingsMgr_SortRings
		move.w	(a1)+,d3
		bmi.s	RingsMgr_RingCol
		move.w	d3,d0
		rol.w	#4,d0
		andi.w	#7,d0
		andi.w	#$FFF,d3
; loc_DB9C:
RingsMgr_NextRingInRow:
		move.w	#0,(a2)+
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		addi.w	#$18,d2
		dbf	d0,RingsMgr_NextRingInRow
		bra.s	RingsMgr_NextRowOrCol
; ===========================================================================
; loc_DBAE:
RingsMgr_RingCol:
		move.w	d3,d0
		rol.w	#4,d0
		andi.w	#7,d0
		andi.w	#$FFF,d3
; loc_DBBA:
RingsMgr_NextRingInCol:
		move.w	#0,(a2)+
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		addi.w	#$18,d3
		dbf	d0,RingsMgr_NextRingInCol
		bra.s	RingsMgr_NextRowOrCol
; ===========================================================================
; loc_DBCC:
RingsMgr_SortRings:
		moveq	#-1,d0
		move.l	d0,(a2)+
		lea	(Ring_Positions+2).w,a1
		move.w	#$FE,d3

loc_DBD8:
		move.w	d3,d4
		lea	6(a1),a2
		move.w	(a1),d0

loc_DBE0:
		tst.w	(a2)
		beq.s	loc_DBF2
		cmp.w	(a2),d0
		bls.s	loc_DBF2
		move.l	(a1),d1
		move.l	(a2),d0
		move.l	d0,(a1)
		move.l	d1,(a2)
		swap	d0

loc_DBF2:
		lea	6(a2),a2
		dbf	d4,loc_DBE0
		lea	6(a1),a1
		dbf	d3,loc_DBD8
		rts
; End of function RingsManager_Setup

; ---------------------------------------------------------------------------
off_DC04:	binclude	"mappings/sprite/Rings.bin"

; ===========================================================================
; ---------------------------------------------------------------------------
; Objects Manager
; Subroutine that keeps track of any objects that need to remember
; their state, such as monitors or enemies.
;
; input variables:
;  -none-
;
; writes:
;  d0, d1
;  d2 = respawn index of object to load
;  d6 = camera position
;
;  a0 = address in object placement list
;  a2 = respawn table
; ---------------------------------------------------------------------------

; ObjPosLoad:
ObjectsManager:
		moveq	#0,d0
		move.b	(Obj_placement_routine).w,d0
		move.w	ObjectsManager_States(pc,d0.w),d0
		jmp	ObjectsManager_States(pc,d0.w)
; End of function ObjectsManager

; ===========================================================================
; OPL_Index:
ObjectsManager_States:
		dc.w ObjectsManager_Init-ObjectsManager_States
		dc.w ObjectsManager_Main-ObjectsManager_States
		dc.w loc_DE5C-ObjectsManager_States
; ===========================================================================
; loc_DC68:
ObjectsManager_Init:
		addq.b	#2,(Obj_placement_routine).w
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	(ObjPos_Index).l,a0
		movea.l	a0,a1
		adda.w	(a0,d0.w),a0
		move.l	a0,(Obj_load_addr_right).w
		move.l	a0,(Obj_load_addr_left).w
		move.l	a0,(Obj_load_addr_right_P2).w
		move.l	a0,(Obj_load_addr_left_P2).w
		lea	(v_objstate).w,a2
		move.w	#$101,(a2)+
		move.w	#$5E,d0

loc_DC9C:
		clr.l	(a2)+
		dbf	d0,loc_DC9C
		lea	(v_objstate).w,a2
		moveq	#0,d2
		move.w	(Camera_RAM).w,d6
		subi.w	#$80,d6
		bcc.s	loc_DCB4
		moveq	#0,d6

loc_DCB4:
		andi.w	#$FF80,d6
		movea.l	(Obj_load_addr_right).w,a0

loc_DCBC:
		cmp.w	(a0),d6
		bls.s	loc_DCCE
		tst.b	4(a0)
		bpl.s	loc_DCCA
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_DCCA:
		addq.w	#6,a0
		bra.s	loc_DCBC
; ===========================================================================

loc_DCCE:
		move.l	a0,(Obj_load_addr_right).w
		move.l	a0,(Obj_load_addr_right_P2).w
		movea.l	(Obj_load_addr_left).w,a0
		subi.w	#$80,d6
		bcs.s	loc_DCF2

loc_DCE0:
		cmp.w	(a0),d6
		bls.s	loc_DCF2
		tst.b	4(a0)
		bpl.s	loc_DCEE
		addq.b	#1,1(a2)

loc_DCEE:
		addq.w	#6,a0
		bra.s	loc_DCE0
; ===========================================================================

loc_DCF2:
		move.l	a0,(Obj_load_addr_left).w
		move.l	a0,(Obj_load_addr_left_P2).w
		move.w	#-1,(Camera_X_pos_last).w
		move.w	#-1,(Camera_X_pos_last_P2).w
		tst.w	(Two_player_mode).w
		beq.s	ObjectsManager_Main
		addq.b	#2,(Obj_placement_routine).w
		bra.w	loc_DDE0
; ===========================================================================
; loc_DD14:
ObjectsManager_Main:
		move.w	(Camera_RAM).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		move.w	d1,(Camera_X_pos_coarse).w
		lea	(v_objstate).w,a2
		moveq	#0,d2
		move.w	(Camera_RAM).w,d6
		andi.w	#$FF80,d6
		cmp.w	(Camera_X_pos_last).w,d6
		beq.w	locret_DDDE
		bge.s	loc_DD9A
		move.w	d6,(Camera_X_pos_last).w
		movea.l	(Obj_load_addr_left).w,a0
		subi.w	#$80,d6
		bcs.s	loc_DD76

loc_DD4A:
		cmp.w	-6(a0),d6
		bge.s	loc_DD76
		subq.w	#6,a0
		tst.b	4(a0)
		bpl.s	loc_DD60
		subq.b	#1,1(a2)
		move.b	1(a2),d2

loc_DD60:
		bsr.w	sub_E0D2
		bne.s	loc_DD6A
		subq.w	#6,a0
		bra.s	loc_DD4A
; ===========================================================================

loc_DD6A:
		tst.b	4(a0)
		bpl.s	loc_DD74
		addq.b	#1,1(a2)

loc_DD74:
		addq.w	#6,a0

loc_DD76:
		move.l	a0,(Obj_load_addr_left).w
		movea.l	(Obj_load_addr_right).w,a0
		addi.w	#$300,d6

loc_DD82:
		cmp.w	-6(a0),d6
		bgt.s	loc_DD94
		tst.b	-2(a0)
		bpl.s	loc_DD90
		subq.b	#1,(a2)

loc_DD90:
		subq.w	#6,a0
		bra.s	loc_DD82
; ===========================================================================

loc_DD94:
		move.l	a0,(Obj_load_addr_right).w
		rts
; ===========================================================================

loc_DD9A:
		move.w	d6,(Camera_X_pos_last).w
		movea.l	(Obj_load_addr_right).w,a0
		addi.w	#$280,d6

loc_DDA6:
		cmp.w	(a0),d6
		bls.s	loc_DDBA
		tst.b	4(a0)
		bpl.s	loc_DDB4
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_DDB4:
		bsr.w	sub_E0D2
		beq.s	loc_DDA6

loc_DDBA:
		move.l	a0,(Obj_load_addr_right).w
		movea.l	(Obj_load_addr_left).w,a0
		subi.w	#$300,d6
		bcs.s	loc_DDDA

loc_DDC8:
		cmp.w	(a0),d6
		bls.s	loc_DDDA
		tst.b	4(a0)
		bpl.s	loc_DDD6
		addq.b	#1,1(a2)

loc_DDD6:
		addq.w	#6,a0
		bra.s	loc_DDC8
; ===========================================================================

loc_DDDA:
		move.l	a0,(Obj_load_addr_left).w

locret_DDDE:
		rts
; ===========================================================================

loc_DDE0:
		moveq	#-1,d0
		move.l	d0,(Object_RAM_block_indices).w
		move.l	d0,($FFFFF784).w
		move.l	d0,($FFFFF788).w
		move.l	d0,(Camera_X_pos_last_P2).w
		move.w	#0,(Camera_X_pos_last).w
		move.w	#0,(Camera_X_pos_last_P2).w
		lea	(v_objstate).w,a2
		move.w	(a2),(Obj_respawn_index_P2).w
		moveq	#0,d2
		lea	(v_objstate).w,a5
		lea	(Obj_load_addr_right).w,a4
		lea	(Player_1_loaded_object_blocks).w,a1
		lea	(Player_2_loaded_object_blocks).w,a6
		moveq	#-2,d6
		bsr.w	sub_DF80
		lea	(Player_1_loaded_object_blocks).w,a1
		moveq	#-1,d6
		bsr.w	sub_DF80
		lea	(Player_1_loaded_object_blocks).w,a1
		moveq	#0,d6
		bsr.w	sub_DF80
		lea	(Obj_respawn_index_P2).w,a5
		lea	(Obj_load_addr_right_P2).w,a4
		lea	(Player_2_loaded_object_blocks).w,a1
		lea	(Player_1_loaded_object_blocks).w,a6
		moveq	#-2,d6
		bsr.w	sub_DF80
		lea	(Player_2_loaded_object_blocks).w,a1
		moveq	#-1,d6
		bsr.w	sub_DF80
		lea	(Player_2_loaded_object_blocks).w,a1
		moveq	#0,d6
		bsr.w	sub_DF80

loc_DE5C:
		move.w	(Camera_RAM).w,d1
		andi.w	#$FF00,d1
		move.w	d1,(Camera_X_pos_coarse).w
		move.w	(Camera_X_pos_P2).w,d1
		andi.w	#$FF00,d1
		move.w	d1,(Camera_X_pos_coarse_P2).w
		move.b	(Camera_RAM).w,d6
		andi.w	#$FF,d6
		move.w	(Camera_X_pos_last).w,d0
		cmp.w	(Camera_X_pos_last).w,d6
		beq.s	loc_DE9C
		move.w	d6,(Camera_X_pos_last).w
		lea	(v_objstate).w,a5
		lea	(Obj_load_addr_right).w,a4
		lea	(Player_1_loaded_object_blocks).w,a1
		lea	(Player_2_loaded_object_blocks).w,a6
		bsr.s	sub_DED2

loc_DE9C:
		move.b	(Camera_X_pos_P2).w,d6
		andi.w	#$FF,d6
		move.w	(Camera_X_pos_last_P2).w,d0
		cmp.w	(Camera_X_pos_last_P2).w,d6
		beq.s	loc_DEC4
		move.w	d6,(Camera_X_pos_last_P2).w
		lea	(Obj_respawn_index_P2).w,a5
		lea	(Obj_load_addr_right_P2).w,a4
		lea	(Player_2_loaded_object_blocks).w,a1
		lea	(Player_1_loaded_object_blocks).w,a6
		bsr.s	sub_DED2

loc_DEC4:
		move.w	(v_objstate).w,(word_FFFFFFEC).w
		move.w	(Obj_respawn_index_P2).w,(word_FFFFFFEE).w
		rts
; ===========================================================================

sub_DED2:
		lea	(v_objstate).w,a2
		moveq	#0,d2
		cmp.w	d0,d6
		beq.w	locret_DDDE
		bge.w	sub_DF80
		move.b	2(a1),d2
		move.b	1(a1),2(a1)
		move.b	(a1),1(a1)
		move.b	d6,(a1)
		cmp.b	(a6),d2
		beq.s	loc_DF08
		cmp.b	1(a6),d2
		beq.s	loc_DF08
		cmp.b	2(a6),d2
		beq.s	loc_DF08
		bsr.w	sub_E062
		bra.s	loc_DF0C
; ===========================================================================

loc_DF08:
		bsr.w	sub_E026

loc_DF0C:
		bsr.w	sub_E002
		bne.s	loc_DF30
		movea.l	4(a4),a0

loc_DF16:
		cmp.b	-6(a0),d6
		bne.s	loc_DF2A
		tst.b	-2(a0)
		bpl.s	loc_DF26
		subq.b	#1,1(a5)

loc_DF26:
		subq.w	#6,a0
		bra.s	loc_DF16
; ===========================================================================

loc_DF2A:
		move.l	a0,4(a4)
		bra.s	loc_DF66
; ===========================================================================

loc_DF30:
		movea.l	4(a4),a0
		move.b	d6,(a1)

loc_DF36:
		cmp.b	-6(a0),d6
		bne.s	loc_DF62
		subq.w	#6,a0
		tst.b	4(a0)
		bpl.s	loc_DF4C
		subq.b	#1,1(a5)
		move.b	1(a5),d2

loc_DF4C:
		bsr.w	sub_E122
		bne.s	loc_DF56
		subq.w	#6,a0
		bra.s	loc_DF36
; ===========================================================================

loc_DF56:
		tst.b	4(a0)
		bpl.s	loc_DF60
		addq.b	#1,1(a5)

loc_DF60:
		addq.w	#6,a0

loc_DF62:
		move.l	a0,4(a4)

loc_DF66:
		movea.l	(a4),a0
		addq.w	#3,d6

loc_DF6A:
		cmp.b	-6(a0),d6
		bne.s	loc_DF7C
		tst.b	-2(a0)
		bpl.s	loc_DF78
		subq.b	#1,(a5)

loc_DF78:
		subq.w	#6,a0
		bra.s	loc_DF6A
; ===========================================================================

loc_DF7C:
		move.l	a0,(a4)
		rts
; ===========================================================================

sub_DF80:
		addq.w	#2,d6
		move.b	(a1),d2
		move.b	1(a1),(a1)
		move.b	2(a1),1(a1)
		move.b	d6,2(a1)
		cmp.b	(a6),d2
		beq.s	loc_DFA8
		cmp.b	1(a6),d2
		beq.s	loc_DFA8
		cmp.b	2(a6),d2
		beq.s	loc_DFA8
		bsr.w	sub_E062
		bra.s	loc_DFAC
; ===========================================================================

loc_DFA8:
		bsr.w	sub_E026

loc_DFAC:
		bsr.w	sub_E002
		bne.s	loc_DFC8
		movea.l	(a4),a0

loc_DFB4:
		cmp.b	(a0),d6
		bne.s	loc_DFC4
		tst.b	4(a0)
		bpl.s	loc_DFC0
		addq.b	#1,(a5)

loc_DFC0:
		addq.w	#6,a0
		bra.s	loc_DFB4
; ===========================================================================

loc_DFC4:
		move.l	a0,(a4)
		bra.s	loc_DFE2
; ===========================================================================

loc_DFC8:
		movea.l	(a4),a0
		move.b	d6,(a1)

loc_DFCC:
		cmp.b	(a0),d6
		bne.s	loc_DFE0
		tst.b	4(a0)
		bpl.s	loc_DFDA
		move.b	(a5),d2
		addq.b	#1,(a5)

loc_DFDA:
		bsr.w	sub_E122
		beq.s	loc_DFCC

loc_DFE0:
		move.l	a0,(a4)

loc_DFE2:
		movea.l	4(a4),a0
		subq.w	#3,d6
		bcs.s	loc_DFFC

loc_DFEA:
		cmp.b	(a0),d6
		bne.s	loc_DFFC
		tst.b	4(a0)
		bpl.s	loc_DFF8
		addq.b	#1,1(a5)

loc_DFF8:
		addq.w	#6,a0
		bra.s	loc_DFEA
; ===========================================================================

loc_DFFC:
		move.l	a0,4(a4)
		rts
; End of function sub_DF80


; =============== S U B	R O U T	I N E =======================================


sub_E002:
		move.l	a1,-(sp)
		lea	(Object_RAM_block_indices).w,a1
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		moveq	#1,d0

loc_E022:
		movea.l	(sp)+,a1
		rts
; End of function sub_E002


; =============== S U B	R O U T	I N E =======================================


sub_E026:
		lea	(Object_RAM_block_indices).w,a1
		lea	(v_objspace+$E00).w,a3
		tst.b	(a1)+
		bmi.s	loc_E05E
		lea	($FFFFC100).w,a3
		tst.b	(a1)+
		bmi.s	loc_E05E
		lea	($FFFFC400).w,a3
		tst.b	(a1)+
		bmi.s	loc_E05E
		lea	($FFFFC700).w,a3
		tst.b	(a1)+
		bmi.s	loc_E05E
		lea	($FFFFCA00).w,a3
		tst.b	(a1)+
		bmi.s	loc_E05E
		lea	($FFFFCD00).w,a3
		tst.b	(a1)+
		bmi.s	loc_E05E
		nop
		nop

loc_E05E:
		subq.w	#1,a1
		rts
; End of function sub_E026


; =============== S U B	R O U T	I N E =======================================


sub_E062:
		lea	(Object_RAM_block_indices).w,a1
		lea	(v_objspace+$E00).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_E09A
		lea	($FFFFC100).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_E09A
		lea	($FFFFC400).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_E09A
		lea	($FFFFC700).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_E09A
		lea	($FFFFCA00).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_E09A
		lea	($FFFFCD00).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_E09A
		nop
		nop

loc_E09A:
		move.b	#$FF,-(a1)
		movem.l	a1/a3,-(sp)
		moveq	#0,d1
		moveq	#$B,d2

loc_E0A6:
		tst.b	(a3)
		beq.s	loc_E0C2
		movea.l	a3,a1
		moveq	#0,d0
		move.b	obRespawnNo(a1),d0
		beq.s	loc_E0BA
		bclr	#7,2(a2,d0.w)

loc_E0BA:
		moveq	#$F,d0

loc_E0BC:
		move.l	d1,(a1)+
		dbf	d0,loc_E0BC

loc_E0C2:
		lea	$40(a3),a3
		dbf	d2,loc_E0A6
		moveq	#0,d2
		movem.l	(sp)+,a1/a3
		rts
; End of function sub_E062


; =============== S U B	R O U T	I N E =======================================


sub_E0D2:
		tst.b	4(a0)
		bpl.s	loc_E0E6
		bset	#7,2(a2,d2.w)
		beq.s	loc_E0E6
		addq.w	#6,a0
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_E0E6:
		bsr.w	FindFreeObj
		bne.s	locret_E120
		move.w	(a0)+,obX(a1)
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#$FFF,d0
		move.w	d0,obY(a1)
		rol.w	#2,d1
		andi.b	#3,d1
		move.b	d1,obRender(a1)
		move.b	d1,obStatus(a1)
		move.b	(a0)+,d0
		bpl.s	loc_E116
		andi.b	#$7F,d0
		move.b	d2,obRespawnNo(a1)

loc_E116:
		_move.b	d0,obID(a1)
		move.b	(a0)+,obSubtype(a1)
		moveq	#0,d0

locret_E120:
		rts
; End of function sub_E0D2


; =============== S U B	R O U T	I N E =======================================


sub_E122:
		tst.b	4(a0)
		bpl.s	loc_E136
		bset	#7,2(a2,d2.w)
		beq.s	loc_E136
		addq.w	#6,a0
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_E136:
		btst	#5,2(a0)
		beq.s	loc_E146
		bsr.w	FindFreeObj
		bne.s	locret_E180
		bra.s	loc_E14C
; ---------------------------------------------------------------------------

loc_E146:
		bsr.w	FindFreeObj3
		bne.s	locret_E180

loc_E14C:
		move.w	(a0)+,obX(a1)
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#$FFF,d0
		move.w	d0,obY(a1)
		rol.w	#2,d1
		andi.b	#3,d1
		move.b	d1,obRender(a1)
		move.b	d1,obStatus(a1)
		move.b	(a0)+,d0
		bpl.s	loc_E176
		andi.b	#$7F,d0
		move.b	d2,obRespawnNo(a1)

loc_E176:
		_move.b	d0,obID(a1)
		move.b	(a0)+,obSubtype(a1)
		moveq	#0,d0

locret_E180:
		rts
; End of function sub_E122

; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object array
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_E182: SingleObjectLoad:
FindFreeObj:
		lea	(v_objspace+$800).w,a1		; a1=object
		move.w	#$5F,d0				; search to end of table

loc_E18A:
		tst.b	(a1)				; is object RAM slot empty?
		beq.s	locret_E196			; if yes, branch
		lea	$40(a1),a1			; load obj address ; goto next object RAM slot
		dbf	d0,loc_E18A			; repeat until end

locret_E196:
		rts
; End of function FindFreeObj

; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object array AFTER the current one in the table
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_E198: S1SingleObjectLoad2:
FindNextFreeObj:
		movea.l	a0,a1
		move.w	#$D000,d0
		sub.w	a0,d0				; subtract current object location
		lsr.w	#6,d0				; divide by $40
		subq.w	#1,d0				; keep from going over the object zone
		bcs.s	locret_E1B2

loc_E1A6:
		tst.b	(a1)				; is object RAM slot empty?
		beq.s	locret_E1B2			; if yes, branch
		lea	$40(a1),a1			; load obj address ; goto next object RAM slot
		dbf	d0,loc_E1A6			; repeat until end

locret_E1B2:
		rts
; End of function FindNextFreeObj

; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object at or within < 12 slots after a3
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E1B4:
FindFreeObj3:
		movea.l	a3,a1
		move.w	#$B,d0

loc_E1BA:
		tst.b	(a1)				; is object RAM slot empty?
		beq.s	locret_E1C6			; if yes, branch
		lea	$40(a1),a1			; load obj address ; goto next object RAM slot
		dbf	d0,loc_E1BA			; repeat until end

locret_E1C6:
		rts
; End of function FindFreeObj3


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 41 - springs
; ---------------------------------------------------------------------------

Obj41:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj41_Index(pc,d0.w),d1
		jsr	Obj41_Index(pc,d1.w)
		tst.w	(Two_player_mode).w
		beq.s	loc_E1E0
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_E1E0:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj41_Index:	dc.w Obj41_Init-Obj41_Index		; 0
		dc.w Obj41_Up-Obj41_Index		; 2
		dc.w Obj41_Horizontal-Obj41_Index	; 4
		dc.w Obj41_Down-Obj41_Index		; 6
		dc.w Obj41_DiagonallyUp-Obj41_Index	; 8
		dc.w Obj41_DiagonallyDown-Obj41_Index	; $A
; ============================================================================
; loc_E204:
Obj41_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj41_GHZ,obMap(a0)
		move.w	#$4A8,obGfx(a0)
		tst.b	(Current_Zone).w
		beq.s	loc_E22A
		move.l	#Map_obj41,obMap(a0)
		move.w	#$45C,obGfx(a0)

loc_E22A:
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#4,obPriority(a0)
		move.b	obSubtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		move.w	Obj41_Init_Subtypes(pc,d0.w),d0
		jmp	Obj41_Init_Subtypes(pc,d0.w)
; ===========================================================================
Obj41_Init_Subtypes:
		dc.w Obj41_Init_Common-Obj41_Init_Subtypes
		dc.w Obj41_Init_Horizontal-Obj41_Init_Subtypes
		dc.w Obj41_Init_Down-Obj41_Init_Subtypes
		dc.w Obj41_Init_DiagonallyUp-Obj41_Init_Subtypes
		dc.w Obj41_Init_DiagonallyDown-Obj41_Init_Subtypes
; ===========================================================================
; loc_E258:
Obj41_Init_Horizontal:
		move.b	#4,obRoutine(a0)
		move.b	#2,obAnim(a0)
		move.b	#3,obFrame(a0)
		move.w	#$4B8,obGfx(a0)
		tst.b	(Current_Zone).w
		beq.s	loc_E27C
		move.w	#$470,obGfx(a0)

loc_E27C:
		move.b	#8,obActWid(a0)
		bra.s	Obj41_Init_Common
; ===========================================================================
; loc_E284:
Obj41_Init_Down:
		move.b	#6,obRoutine(a0)
		move.b	#6,obFrame(a0)
		bset	#1,obStatus(a0)
		bra.s	Obj41_Init_Common
; ===========================================================================
; loc_E298:
Obj41_Init_DiagonallyUp:
		move.b	#8,obRoutine(a0)
		move.b	#4,obAnim(a0)
		move.b	#7,obFrame(a0)
		move.w	#$43C,obGfx(a0)
		bra.s	Obj41_Init_Common
; ===========================================================================
; loc_E2B2:
Obj41_Init_DiagonallyDown:
		move.b	#$A,obRoutine(a0)
		move.b	#4,obAnim(a0)
		move.b	#$A,obFrame(a0)
		move.w	#$43C,obGfx(a0)
		bset	#1,obStatus(a0)
; loc_E2D0:
Obj41_Init_Common:
		move.b	obSubtype(a0),d0
		andi.w	#2,d0
		move.w	Obj41_Strengths(pc,d0.w),$30(a0)
		btst	#1,d0
		beq.s	loc_E2F8
		bset	#5,2(a0)
		tst.b	(Current_Zone).w
		beq.s	loc_E2F8
		move.l	#Map_obj41a,obMap(a0)

loc_E2F8:
		bsr.w	Adjust2PArtPointer
		rts
; ===========================================================================
; word_E2FE:
Obj41_Strengths:	dc.w -$1000
			dc.w -$A00
; ===========================================================================
; loc_E302:
Obj41_Up:
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SolidObject_Always_SingleCharacter
		btst	#3,obStatus(a0)
		beq.s	loc_E32A
		bsr.s	sub_E34E

loc_E32A:
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		moveq	#4,d6
		bsr.w	SolidObject_Always_SingleCharacter
		btst	#4,obStatus(a0)
		beq.s	loc_E342
		bsr.s	sub_E34E

loc_E342:
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E34E:
		move.w	#$100,obAnim(a0)
		addq.w	#8,obY(a1)
		move.w	$30(a0),obVelY(a1)
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#$10,obAnim(a1)
		move.b	#2,obRoutine(a1)
		move.b	obSubtype(a0),d0
		bpl.s	loc_E382
		move.w	#0,obVelX(a1)

loc_E382:
		btst	#0,d0
		beq.s	loc_E3C2
		move.w	#1,obInertia(a1)
		move.b	#1,$27(a1)
		move.b	#0,obAnim(a1)
		move.b	#0,$2C(a1)
		move.b	#4,$2D(a1)
		btst	#1,d0
		bne.s	loc_E3B2
		move.b	#1,$2C(a1)

loc_E3B2:
		btst	#0,obStatus(a1)
		beq.s	loc_E3C2
		neg.b	$27(a1)
		neg.w	obInertia(a1)

loc_E3C2:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E3D8
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)

loc_E3D8:
		cmpi.b	#8,d0
		bne.s	loc_E3EA
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_E3EA:
		move.w	#sfx_Spring,d0
		jmp	(PlaySound_Special).l
; End of function sub_E34E

; ===========================================================================
; loc_E3F4:
Obj41_Horizontal:
		move.w	#$13,d1
		move.w	#$E,d2
		move.w	#$F,d3
		move.w	obX(a0),d4
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SolidObject_Always_SingleCharacter
		btst	#5,obStatus(a0)
		beq.s	loc_E434
		move.b	obStatus(a0),d1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcs.s	loc_E42C
		eori.b	#1,d1

loc_E42C:
		andi.b	#1,d1
		bne.s	loc_E434
		bsr.s	sub_E474

loc_E434:
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		moveq	#4,d6
		bsr.w	SolidObject_Always_SingleCharacter
		btst	#6,obStatus(a0)
		beq.s	loc_E464
		move.b	obStatus(a0),d1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcs.s	loc_E45C
		eori.b	#1,d1

loc_E45C:
		andi.b	#1,d1
		bne.s	loc_E464
		bsr.s	sub_E474

loc_E464:
		bsr.w	sub_E54C
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E474:
		move.w	#$300,obAnim(a0)
		move.w	$30(a0),obVelX(a1)
		addq.w	#8,obX(a1)
		bset	#0,obStatus(a1)
		btst	#0,obStatus(a0)
		bne.s	loc_E4A2
		bclr	#0,obStatus(a1)
		subi.w	#$10,obX(a1)
		neg.w	obVelX(a1)

loc_E4A2:
		move.w	#$F,$2E(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#2,obStatus(a1)
		bne.s	loc_E4BC
		move.b	#0,obAnim(a1)

loc_E4BC:
		move.b	obSubtype(a0),d0
		bpl.s	loc_E4C8
		move.w	#0,obVelY(a1)

loc_E4C8:
		btst	#0,d0
		beq.s	loc_E508
		move.w	#1,obInertia(a1)
		move.b	#1,$27(a1)
		move.b	#0,obAnim(a1)
		move.b	#1,$2C(a1)
		move.b	#8,$2D(a1)
		btst	#1,d0
		bne.s	loc_E4F8
		move.b	#3,$2C(a1)

loc_E4F8:
		btst	#0,obStatus(a1)
		beq.s	loc_E508
		neg.b	$27(a1)
		neg.w	obInertia(a1)

loc_E508:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E51E
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)

loc_E51E:
		cmpi.b	#8,d0
		bne.s	loc_E530
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_E530:
		bclr	#5,obStatus(a0)
		bclr	#6,obStatus(a0)
		bclr	#5,obStatus(a1)
		move.w	#sfx_Spring,d0
		jmp	(PlaySound_Special).l
; End of function sub_E474


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E54C:
		cmpi.b	#3,obAnim(a0)
		beq.w	locret_E604
		move.w	obX(a0),d0
		move.w	d0,d1
		addi.w	#$28,d1
		btst	#0,obStatus(a0)
		beq.s	loc_E56E
		move.w	d0,d1
		subi.w	#$28,d0

loc_E56E:
		move.w	obY(a0),d2
		move.w	d2,d3
		subi.w	#$18,d2
		addi.w	#$18,d3
		lea	(v_objspace).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_E5C2
		move.w	obInertia(a1),d4
		btst	#0,obStatus(a0)
		beq.s	loc_E596
		neg.w	d4

loc_E596:
		tst.w	d4
		bmi.s	loc_E5C2
		move.w	obX(a1),d4
		cmp.w	d0,d4
		bcs.w	loc_E5C2
		cmp.w	d1,d4
		bcc.w	loc_E5C2
		move.w	obY(a1),d4
		cmp.w	d2,d4
		bcs.w	loc_E5C2
		cmp.w	d3,d4
		bcc.w	loc_E5C2
		move.w	d0,-(sp)
		bsr.w	sub_E474
		move.w	(sp)+,d0

loc_E5C2:
		lea	(v_objspace+$40).w,a1
		btst	#1,obStatus(a1)
		bne.s	locret_E604
		move.w	obInertia(a1),d4
		btst	#0,obStatus(a0)
		beq.s	loc_E5DC
		neg.w	d4

loc_E5DC:
		tst.w	d4
		bmi.s	locret_E604
		move.w	obX(a1),d4
		cmp.w	d0,d4
		bcs.w	locret_E604
		cmp.w	d1,d4
		bcc.w	locret_E604
		move.w	obY(a1),d4
		cmp.w	d2,d4
		bcs.w	locret_E604
		cmp.w	d3,d4
		bcc.w	locret_E604
		bsr.w	sub_E474

locret_E604:
		rts
; End of function sub_E54C

; ===========================================================================
; loc_E606:
Obj41_Down:
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SolidObject_Always_SingleCharacter
		cmpi.w	#-2,d4
		bne.s	loc_E62C
		bsr.s	sub_E64E

loc_E62C:
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		moveq	#4,d6
		bsr.w	SolidObject_Always_SingleCharacter
		cmpi.w	#-2,d4
		bne.s	loc_E642
		bsr.s	sub_E64E

loc_E642:
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E64E:
		move.w	#$100,obAnim(a0)
		subq.w	#8,obY(a1)
		move.w	$30(a0),obVelY(a1)
		neg.w	obVelY(a1)
		move.b	obSubtype(a0),d0
		bpl.s	loc_E66E
		move.w	#0,obVelX(a1)

loc_E66E:
		btst	#0,d0
		beq.s	loc_E6AE
		move.w	#1,obInertia(a1)
		move.b	#1,$27(a1)
		move.b	#0,obAnim(a1)
		move.b	#0,$2C(a1)
		move.b	#4,$2D(a1)
		btst	#1,d0
		bne.s	loc_E69E
		move.b	#1,$2C(a1)

loc_E69E:
		btst	#0,obStatus(a1)
		beq.s	loc_E6AE
		neg.b	$27(a1)
		neg.w	obInertia(a1)

loc_E6AE:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E6C4
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)

loc_E6C4:
		cmpi.b	#8,d0
		bne.s	loc_E6D6
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_E6D6:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		move.w	#sfx_Spring,d0
		jmp	(PlaySound_Special).l
; End of function sub_E64E

; ===========================================================================
; loc_E6F2:
Obj41_DiagonallyUp:
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	obX(a0),d4
		lea	Obj41_SlopeData_DiagUp(pc),a2
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SlopedSolid_SingleCharacter
		btst	#3,obStatus(a0)
		beq.s	loc_E71A
		bsr.s	sub_E73E

loc_E71A:
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		moveq	#4,d6
		bsr.w	SlopedSolid_SingleCharacter
		btst	#4,obStatus(a0)
		beq.s	loc_E732
		bsr.s	sub_E73E

loc_E732:
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E73E:
		btst	#0,obStatus(a0)
		bne.s	loc_E754
		move.w	obX(a0),d0
		subq.w	#4,d0
		cmp.w	obX(a1),d0
		bcs.s	loc_E762
		rts
; ===========================================================================

loc_E754:
		move.w	obX(a0),d0
		addq.w	#4,d0
		cmp.w	obX(a1),d0
		bcc.s	loc_E762
		rts
; ===========================================================================

loc_E762:
		move.w	#$500,obAnim(a0)
		move.w	$30(a0),obVelY(a1)
		move.w	$30(a0),obVelX(a1)
		addq.w	#6,obY(a1)
		addq.w	#6,obX(a1)
		bset	#0,obStatus(a1)
		btst	#0,obStatus(a0)
		bne.s	loc_E79A
		bclr	#0,obStatus(a1)
		subi.w	#$C,obX(a1)
		neg.w	obVelX(a1)

loc_E79A:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#$10,obAnim(a1)
		move.b	#2,obRoutine(a1)
		move.b	obSubtype(a0),d0
		btst	#0,d0
		beq.s	loc_E7F6
		move.w	#1,obInertia(a1)
		move.b	#1,$27(a1)
		move.b	#0,obAnim(a1)
		move.b	#1,$2C(a1)
		move.b	#8,$2D(a1)
		btst	#1,d0
		bne.s	loc_E7E6
		move.b	#3,$2C(a1)

loc_E7E6:
		btst	#0,obStatus(a1)
		beq.s	loc_E7F6
		neg.b	$27(a1)
		neg.w	obInertia(a1)

loc_E7F6:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E80C
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)

loc_E80C:
		cmpi.b	#8,d0
		bne.s	loc_E81E
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_E81E:
		move.w	#sfx_Spring,d0
		jmp	(PlaySound_Special).l
; End of function sub_E73E

; ===========================================================================
; loc_E828:
Obj41_DiagonallyDown:
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	obX(a0),d4
		lea	Obj41_SlopeData_DiagDown(pc),a2
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SlopedSolid_SingleCharacter
		cmpi.w	#-2,d4
		bne.s	loc_E84E
		bsr.s	sub_E870

loc_E84E:
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		moveq	#4,d6
		bsr.w	SlopedSolid_SingleCharacter
		cmpi.w	#-2,d4
		bne.s	loc_E864
		bsr.s	sub_E870

loc_E864:
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E870:
		move.w	#$500,obAnim(a0)
		move.w	$30(a0),obVelY(a1)
		neg.w	obVelY(a1)
		move.w	$30(a0),obVelX(a1)
		subq.w	#6,obY(a1)
		addq.w	#6,obX(a1)
		bset	#0,obStatus(a1)
		btst	#0,obStatus(a0)
		bne.s	loc_E8AC
		bclr	#0,obStatus(a1)
		subi.w	#$C,obX(a1)
		neg.w	obVelX(a1)

loc_E8AC:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		move.b	obSubtype(a0),d0
		btst	#0,d0
		beq.s	loc_E902
		move.w	#1,obInertia(a1)
		move.b	#1,$27(a1)
		move.b	#0,obAnim(a1)
		move.b	#1,$2C(a1)
		move.b	#8,$2D(a1)
		btst	#1,d0
		bne.s	loc_E8F2
		move.b	#3,$2C(a1)

loc_E8F2:
		btst	#0,obStatus(a1)
		beq.s	loc_E902
		neg.b	$27(a1)
		neg.w	obInertia(a1)

loc_E902:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E918
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)

loc_E918:
		cmpi.b	#8,d0
		bne.s	loc_E92A
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_E92A:
		move.w	#sfx_Spring,d0
		jmp	(PlaySound_Special).l
; End of function sub_E870

; ===========================================================================
; byte_E934:
Obj41_SlopeData_DiagUp:
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b  $E, $C, $A,  8
		dc.b   6,  4,  2,  0
		dc.b $FE,$FC,$FC,$FC
		dc.b $FC,$FC,$FC,$FC
; byte_E950:
Obj41_SlopeData_DiagDown:
		dc.b $F4,$F0,$F0,$F0
		dc.b $F0,$F0,$F0,$F0
		dc.b $F0,$F0,$F0,$F0
		dc.b $F2,$F4,$F6,$F8
		dc.b $FA,$FC,$FE,  0
		dc.b   2,  4,  4,  4
		dc.b   4,  4,  4,  4

; animation script
Ani_obj41:	dc.w byte_E978-Ani_obj41
		dc.w byte_E97B-Ani_obj41
		dc.w byte_E987-Ani_obj41
		dc.w byte_E98A-Ani_obj41
		dc.w byte_E996-Ani_obj41
		dc.w byte_E999-Ani_obj41
byte_E978:	dc.b  $F,  0,$FF
byte_E97B:	dc.b   0,  1,  0,  0,  2,  2,  2,  2
		dc.b   2,  2,$FD,  0
byte_E987:	dc.b  $F,  3,$FF
byte_E98A:	dc.b   0,  4,  3,  3,  5,  5,  5,  5
		dc.b   5,  5,$FD,  2
byte_E996:	dc.b  $F,  7,$FF
byte_E999:	dc.b   0,  8,  7,  7,  9,  9,  9,  9
		dc.b   9,  9,$FD,  4,  0

; ----------------------------------------------------------------------------
; Sprite mappings - GHZ springs
; ----------------------------------------------------------------------------
Map_obj41_GHZ:	binclude	"mappings/sprite/obj41_GHZ.bin"
; ----------------------------------------------------------------------------
; Primary sprite mappings for springs
; ----------------------------------------------------------------------------
Map_obj41:	dc.w word_EA4A-Map_obj41
		dc.w word_EA5C-Map_obj41
		dc.w word_EA66-Map_obj41
		dc.w word_EA78-Map_obj41
		dc.w word_EA8A-Map_obj41
		dc.w word_EA94-Map_obj41
		dc.w word_EAA6-Map_obj41
		dc.w word_EAB8-Map_obj41
		dc.w word_EADA-Map_obj41
		dc.w word_EAF4-Map_obj41
		dc.w word_EB16-Map_obj41
; -------------------------------------------------------------------------------
; Secondary sprite mappings for springs
; merged with the above mappings; can't split to file in a useful way...
; -------------------------------------------------------------------------------
Map_obj41a:	dc.w word_EA4A-Map_obj41a
		dc.w word_EA5C-Map_obj41a
		dc.w word_EA66-Map_obj41a
		dc.w word_EA78-Map_obj41a
		dc.w word_EA8A-Map_obj41a
		dc.w word_EA94-Map_obj41a
		dc.w word_EAA6-Map_obj41a
		dc.w word_EB38-Map_obj41a
		dc.w word_EB5A-Map_obj41a
		dc.w word_EB74-Map_obj41a
		dc.w word_EB96-Map_obj41a
word_EA4A:	dc.w 2
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 5,    8,    4,$FFF8
word_EA5C:	dc.w 1
		dc.w $F80D,    0,    0,$FFF0
word_EA66:	dc.w 2
		dc.w $E00D,    0,    0,$FFF0
		dc.w $F007,   $C,    6,$FFF8
word_EA78:	dc.w 2
		dc.w $F003,    0,    0,	   0
		dc.w $F801,    4,    2,$FFF8
word_EA8A:	dc.w 1
		dc.w $F003,    0,    0,$FFF8
word_EA94:	dc.w 2
		dc.w $F003,    0,    0,	 $10
		dc.w $F809,    6,    3,$FFF8
word_EAA6:	dc.w 2
		dc.w	$D,$1000,$1000,$FFF0
		dc.w $F005,$1008,$1004,$FFF8
word_EAB8:	dc.w 4
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 5,    8,    4,	   0
		dc.w $FB05,   $C,    6,$FFF6
		dc.w	 5,$201C,$200E,$FFF0
word_EADA:	dc.w 3
		dc.w $F60D,    0,    0,$FFEA
		dc.w  $605,    8,    4,$FFFA
		dc.w	 5,$201C,$200E,$FFF0
word_EAF4:	dc.w 4
		dc.w $E60D,    0,    0,$FFFB
		dc.w $F605,    8,    4,	  $B
		dc.w $F30B,  $10,    8,$FFF6
		dc.w	 5,$201C,$200E,$FFF0
word_EB16:	dc.w 4
		dc.w	$D,$1000,$1000,$FFF0
		dc.w $F005,$1008,$1004,	   0
		dc.w $F505,$100C,$1006,$FFF6
		dc.w $F005,$301C,$300E,$FFF0
word_EB38:	dc.w 4
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 5,    8,    4,	   0
		dc.w $FB05,   $C,    6,$FFF6
		dc.w	 5,  $1C,   $E,$FFF0
word_EB5A:	dc.w 3
		dc.w $F60D,    0,    0,$FFEA
		dc.w  $605,    8,    4,$FFFA
		dc.w	 5,  $1C,   $E,$FFF0
word_EB74:	dc.w 4
		dc.w $E60D,    0,    0,$FFFB
		dc.w $F605,    8,    4,	  $B
		dc.w $F30B,  $10,    8,$FFF6
		dc.w	 5,  $1C,   $E,$FFF0
word_EB96:	dc.w 4
		dc.w	$D,$1000,$1000,$FFF0
		dc.w $F005,$1008,$1004,	   0
		dc.w $F505,$100C,$1006,$FFF6
		dc.w $F005,$101C,$100E,$FFF0

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 42 - GHZ Newtron badnik
; ---------------------------------------------------------------------------

Obj42:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj42_Index(pc,d0.w),d1
		jmp	Obj42_Index(pc,d1.w)
; ===========================================================================
Obj42_Index:	dc.w Obj42_Init-Obj42_Index
		dc.w Obj42_Main-Obj42_Index
		dc.w Obj42_Delete-Obj42_Index
; ===========================================================================
; loc_EBCC:
Obj42_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj42,obMap(a0)
		move.w	#$49B,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#$14,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
; loc_EC00:
Obj42_Main
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj42_Main_Index(pc,d0.w),d1
		jsr	Obj42_Main_Index(pc,d1.w)
		lea	(Ani_obj42).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj42_Main_Index:	dc.w Obj42_ChkDistance-Obj42_Main_Index
			dc.w Obj42_Type00-Obj42_Main_Index
			dc.w Obj42_ChkFloor-Obj42_Main_Index
			dc.w Obj42_Move-Obj42_Main_Index
			dc.w Obj42_Type02-Obj42_Main_Index
; ===========================================================================
; loc_EC26:
Obj42_ChkDistance:
		bset	#0,obStatus(a0)
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	loc_EC3E
		neg.w	d0
		bclr	#0,obStatus(a0)

loc_EC3E:
		cmpi.w	#$80,d0
		bcc.s	locret_EC6A
		addq.b	#2,ob2ndRout(a0)
		move.b	#1,obAnim(a0)
		tst.b	obSubtype(a0)
		beq.s	locret_EC6A
		move.w	#$249B,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#8,ob2ndRout(a0)
		move.b	#4,obAnim(a0)

locret_EC6A:
		rts
; ===========================================================================
; Blue Newtron that appears before chasing Sonic/Tails
; loc_EC6C:
Obj42_Type00:
		cmpi.b	#4,obFrame(a0)
		bcc.s	Obj42_Fall
		bset	#0,obStatus(a0)
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	locret_EC8A
		bclr	#0,obStatus(a0)

locret_EC8A:
		rts
; ---------------------------------------------------------------------------
; loc_EC8C:
Obj42_Fall:
		cmpi.b	#1,obFrame(a0)
		bne.s	loc_EC9A
		move.b	#$C,obColType(a0)

loc_EC9A:
		bsr.w	ObjectMoveAndFall
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_ECDE
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,ob2ndRout(a0)
		move.b	#2,obAnim(a0)
		btst	#5,2(a0)
		beq.s	loc_ECC6
		addq.b	#1,obAnim(a0)

loc_ECC6:
		move.b	#$D,obColType(a0)
		move.w	#$200,obVelX(a0)
		btst	#0,obStatus(a0)
		bne.s	locret_ECDE
		neg.w	obVelX(a0)

locret_ECDE:
		rts
; ===========================================================================
; loc_ECE0:
Obj42_ChkFloor:
		bsr.w	ObjectMove
		bsr.w	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	loc_ECFA
		cmpi.w	#$C,d1
		bge.s	loc_ECFA
		add.w	d1,obY(a0)
		rts
; ---------------------------------------------------------------------------

loc_ECFA:
		addq.b	#2,ob2ndRout(a0)
		rts
; ===========================================================================
; loc_ED00:
Obj42_Move:
		bsr.w	ObjectMove
		rts
; ===========================================================================
; Green Newtron that fires a missile
; loc_ED06:
Obj42_Type02:
		cmpi.b	#1,obFrame(a0)
		bne.s	Obj42_FireMissile
		move.b	#$C,obColType(a0)
; loc_ED14:
Obj42_FireMissile:
		cmpi.b	#2,obFrame(a0)
		bne.s	locret_ED6C
		tst.b	$32(a0)
		bne.s	locret_ED6C
		move.b	#1,$32(a0)
		bsr.w	FindFreeObj
		bne.s	locret_ED6C
		_move.b	#$23,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		subq.w	#8,obY(a1)
		move.w	#$200,obVelX(a1)
		move.w	#$14,d0
		btst	#0,obStatus(a0)
		bne.s	loc_ED5C
		neg.w	d0
		neg.w	obVelX(a1)

loc_ED5C:
		add.w	d0,obX(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#1,obSubtype(a1)

locret_ED6C:
		rts
; ===========================================================================
; loc_ED6E:
Obj42_Delete:
		bra.w	DeleteObject
; ===========================================================================
; animation script
Ani_obj42:	dc.w byte_ED7C-Ani_obj42
		dc.w byte_ED7F-Ani_obj42
		dc.w byte_ED87-Ani_obj42
		dc.w byte_ED8B-Ani_obj42
		dc.w byte_ED8F-Ani_obj42
byte_ED7C:	dc.b  $F, $A,$FF
byte_ED7F:	dc.b $13,  0,  1,  3,  4,  5,$FE,  1
byte_ED87:	dc.b   2,  6,  7,$FF
byte_ED8B:	dc.b   2,  8,  9,$FF
byte_ED8F:	dc.b $13,  0,  1,  1,  2,  1,  1,  0
		dc.b $FC
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj42:	binclude	"mappings/sprite/obj42.bin"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 44 - GHZ wall
; ---------------------------------------------------------------------------

Obj44:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj44_Index(pc,d0.w),d1
		jmp	Obj44_Index(pc,d1.w)
; ===========================================================================
Obj44_Index:	dc.w Obj44_Init-Obj44_Index
		dc.w Obj44_Main-Obj44_Index
		dc.w Obj44_Display-Obj44_Index
; ===========================================================================
; loc_EEC8:
Obj44_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj44,obMap(a0)
		move.w	#$434C,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#8,obActWid(a0)
		move.b	#6,obPriority(a0)
		move.b	obSubtype(a0),obFrame(a0)
		bclr	#4,obFrame(a0)
		beq.s	Obj44_Main
		addq.b	#2,obRoutine(a0)
		bra.s	Obj44_Display
; ===========================================================================
; loc_EF04:
Obj44_Main:
		move.w	#$13,d1
		move.w	#$28,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
; loc_EF18:
Obj44_Display:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj44:	binclude	"mappings/sprite/obj44.bin"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0D - End of level signpost
; ---------------------------------------------------------------------------

Obj0D:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj0D_Index(pc,d0.w),d1
		jsr	Obj0D_Index(pc,d1.w)
		lea	(Ani_obj0D).l,a1
		bsr.w	AnimateSprite
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj0D_Index:	dc.w Obj0D_Init-Obj0D_Index
		dc.w Obj0D_Main-Obj0D_Index
		dc.w Obj0D_Spin-Obj0D_Index
		dc.w Obj0D_EndLevel-Obj0D_Index
		dc.w locret_F18A-Obj0D_Index
; ===========================================================================
; loc_EFD6:
Obj0D_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj0D,obMap(a0)
		move.w	#$680,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obPriority(a0)
; loc_EFFE:
Obj0D_Main:
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bcs.s	locret_F026
		cmpi.w	#$20,d0
		bcc.s	locret_F026
		move.w	#sfx_Signpost,d0
		jsr	(PlaySound).l
		clr.b	(f_timecount).w
		move.w	(Camera_Max_X_pos).w,(Camera_Min_X_pos).w
		addq.b	#2,obRoutine(a0)

locret_F026:
		rts
; ===========================================================================
; loc_F028:
Obj0D_Spin:
		subq.w	#1,$30(a0)
		bpl.s	Obj0D_Sparkle
		move.w	#$3C,$30(a0)
		addq.b	#1,obAnim(a0)
		cmpi.b	#3,obAnim(a0)
		bne.s	Obj0D_Sparkle
		addq.b	#2,obRoutine(a0)
; loc_F044:
Obj0D_Sparkle:
		subq.w	#1,$32(a0)
		bpl.s	locret_F0B2
		move.w	#$B,$32(a0)
		moveq	#0,d0
		move.b	$34(a0),d0
		addq.b	#2,$34(a0)
		andi.b	#$E,$34(a0)
		lea	Obj0D_RingSparklePositions(pc,d0.w),a2
		bsr.w	FindFreeObj
		bne.s	locret_F0B2
		_move.b	#$25,obID(a1)
		move.b	#6,obRoutine(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obX(a0),d0
		move.w	d0,obX(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obY(a0),d0
		move.w	d0,obY(a1)
		move.l	#Map_Obj25,obMap(a1)
		move.w	#$27B2,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#4,obRender(a1)
		move.b	#2,obPriority(a1)
		move.b	#8,obActWid(a1)

locret_F0B2:
		rts
; ===========================================================================
; dword_F0B4:
Obj0D_RingSparklePositions:
		dc.l $E8F00808
		dc.l $F00018F8
		dc.l $F81000
		dc.l $E8081810
; ===========================================================================
; loc_F0C4:
Obj0D_EndLevel:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_F15E
		btst	#1,(v_objspace+obStatus).w
		bne.s	loc_F0E0
		move.b	#1,(f_lockctrl).w
		move.w	#$800,(v_jpadhold2).w

loc_F0E0:
		; This check here is for S1's Big Ring, which would set Sonic's Object ID to 0
		tst.b	(v_objspace).w
		beq.s	loc_F0F6
		move.w	(v_objspace+obX).w,d0
		move.w	(Camera_Max_X_pos).w,d1
		addi.w	#$128,d1
		cmp.w	d1,d0
		bcs.s	locret_F15E

loc_F0F6:
		addq.b	#2,obRoutine(a0)

; ---------------------------------------------------------------------------
; Subroutine to load the end of act results screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; GotThroughAct:
Load_EndOfAct:
		tst.b	(v_objspace+$5C0).w
		bne.s	locret_F15E
		move.w	(Camera_Max_X_pos).w,(Camera_Min_X_pos).w
		clr.b	(v_invinc).w
		clr.b	(f_timecount).w
		move.b	#$3A,(v_objspace+$5C0).w
		moveq	#$10,d0
		jsr	(LoadPLC2).l
		move.b	#1,(f_endactbonus).w
		moveq	#0,d0
		move.b	(v_timemin).w,d0
		mulu.w	#$3C,d0
		moveq	#0,d1
		move.b	(v_timesec).w,d1
		add.w	d1,d0
		divu.w	#$F,d0
		moveq	#$14,d1
		cmp.w	d1,d0
		bcs.s	loc_F140
		move.w	d1,d0

loc_F140:
		add.w	d0,d0
		move.w	TimeBonuses(pc,d0.w),(v_timebonus).w
		move.w	(v_rings).w,d0
		mulu.w	#10,d0
		move.w	d0,(v_ringbonus).w
		move.w	#bgm_GotThrough,d0
		jsr	(PlaySound_Special).l

locret_F15E:
		rts
; End of function Load_EndOfAct

; ===========================================================================
; word_F160:
TimeBonuses:	dc.w  5000, 5000, 1000,	 500
		dc.w   400,  400,  300,	 300
		dc.w   200,  200,  200,	 200
		dc.w   100,  100,  100,	 100
		dc.w	50,   50,   50,	  50
		dc.w	 0
; ===========================================================================

locret_F18A:
		rts
; ===========================================================================
; animation script
; off_F18C:
Ani_obj0D:	dc.w byte_F194-Ani_obj0D
		dc.w byte_F197-Ani_obj0D
		dc.w byte_F1A5-Ani_obj0D
		dc.w byte_F1B3-Ani_obj0D
byte_F194:	dc.b  $F,  2,$FF
byte_F197:	dc.b   1,  2,  3,  4,  5,  1,  3,  4
		dc.b   5,  0,  3,  4,  5,$FF
byte_F1A5:	dc.b   1,  2,  3,  4,  5,  1,  3,  4
		dc.b   5,  0,  3,  4,  5,$FF
byte_F1B3:	dc.b  $F,  0,$FF
		even

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj0D:	binclude	"mappings/sprite/obj0D.bin"
; ===========================================================================
		nop
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 40 - GHZ Motobug
; ---------------------------------------------------------------------------

Obj40:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj40_Index(pc,d0.w),d1
		jmp	Obj40_Index(pc,d1.w)
; ===========================================================================
; off_F256:
Obj40_Index:	dc.w Obj40_Init-Obj40_Index
		dc.w Obj40_Main-Obj40_Index
		dc.w Obj40_Animate-Obj40_Index
		dc.w Obj40_Delete-Obj40_Index
; ===========================================================================
; loc_F25E:
Obj40_Init:
		move.l	#Map_obj40,obMap(a0)
		move.w	#$4E0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#$14,obActWid(a0)
		tst.b	obAnim(a0)
		bne.s	Obj40_Smoke
		move.b	#$E,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.b	#$C,obColType(a0)
		bsr.w	ObjectMoveAndFall
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_F2BC
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		bchg	#0,obStatus(a0)

locret_F2BC:
		rts
; ===========================================================================
; loc_F2BE:
Obj40_Smoke:
		addq.b	#4,obRoutine(a0)
		bra.w	Obj40_Animate
; ===========================================================================
; loc_F2C6:
Obj40_Main:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj40_Main_Index(pc,d0.w),d1
		jsr	Obj40_Main_Index(pc,d1.w)
		lea	(Ani_obj40).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
; off_F2E2
Obj40_Main_Index:	dc.w Obj40_Move-Obj40_Main_Index
			dc.w Obj40_Floor-Obj40_Main_Index
; ===========================================================================
; loc_F2E6:
Obj40_Move:
		subq.w	#1,$30(a0)
		bpl.s	locret_F308
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$100,obVelX(a0)
		move.b	#1,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	locret_F308
		neg.w	obVelX(a0)

locret_F308:
		rts
; ===========================================================================
; loc_F30A:
Obj40_Floor:
		bsr.w	ObjectMove
		jsr	(ObjHitFloor).l
		cmpi.w	#-8,d1
		blt.s	Obj40_StopMoving
		cmpi.w	#$C,d1
		bge.s	Obj40_StopMoving
		add.w	d1,obY(a0)
		subq.b	#1,$33(a0)
		bpl.s	locret_F354
		move.b	#$F,$33(a0)
		bsr.w	FindFreeObj
		bne.s	locret_F354
		_move.b	#$40,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)

locret_F354:
		rts
; ---------------------------------------------------------------------------
; loc_F356:
Obj40_StopMoving:
		subq.b	#2,ob2ndRout(a0)
		move.w	#$3B,$30(a0)
		move.w	#0,obVelX(a0)
		move.b	#0,obAnim(a0)
		rts
; ===========================================================================
; loc_F36E:
Obj40_Animate:
		lea	(Ani_obj40).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
; loc_F37C:
Obj40_Delete:
		bra.w	DeleteObject
; ===========================================================================
; animation script
Ani_obj40:	dc.w byte_F386-Ani_obj40
		dc.w byte_F389-Ani_obj40
		dc.w byte_F38F-Ani_obj40
byte_F386:	dc.b  $F,  2,$FF
byte_F389:	dc.b   7,  0,  1,  0,  2,$FF
byte_F38F:	dc.b   1,  3,  6,  3,  6,  4,  6,  4
		dc.b   6,  4,  6,  5,$FC
		even

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj40:	binclude	"mappings/sprite/obj40.bin"




; ===========================================================================
; ---------------------------------------------------------------------------
; Solid object subroutines (includes spikes, blocks, rocks etc)
; These check collision of Sonic/Tails with objects on the screen
;
; input variables:
; d1 = object width
; d2 = object height / 2 (when jumping)
; d3 = object height / 2 (when walking)
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = sonic or tails (set inside these subroutines)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


SolidObject:
		lea	(v_objspace).w,a1		; a1=character
		moveq	#3,d6
		movem.l	d1-d4,-(sp)			; store input registers
		bsr.s	sub_F456			; first collision check with Sonic
		movem.l	(sp)+,d1-d4			; restore input registers
		lea	(v_objspace+$40).w,a1		; a1=character ; now check collision with Tails
		tst.b	1(a1)
		bpl.w	locret_F490			; return if not Tails
		addq.b	#1,d6

sub_F456:
		btst	d6,obStatus(a0)
		beq.w	SolidObject_OnScreenTest
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F47A
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F47A
		cmp.w	d2,d0
		bcs.s	loc_F488

loc_F47A:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------
loc_F488:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4

locret_F490:
		rts
; End of function SolidObject

; ===========================================================================
; alternate function to check for collision even if off-screen, unused
; in this build...
; SolidObject_Always:
		lea	(v_objspace).w,a1		; a1=character
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	SolidObject_Always_SingleCharacter
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1		; a1=character
		addq.b	#1,d6
; loc_F4A8:
SolidObject_Always_SingleCharacter:
		btst	d6,obStatus(a0)
		beq.w	SolidObject_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F4CC
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F4CC
		cmp.w	d2,d0
		bcs.s	loc_F4DA

loc_F4CC:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F4DA:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; End of function SolidObject_Always

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to collide Sonic/Tails with the top of a sloped
; solid like diagonal springs; unused in this build...
;
; input variables:
; d1 = object width
; d2 = object height / 2 (when jumping)
; d3 = object height / 2 (when walking)
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = sonic or tails (set inside these subroutines)
; a2 = height data for slope
; ---------------------------------------------------------------------------
		lea	(v_objspace).w,a1		; a1=character
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	SlopedSolid_SingleCharacter
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1		; a1=character
		addq.b	#1,d6
; loc_F4FA:
SlopedSolid_SingleCharacter:
		btst	d6,obStatus(a0)
		beq.w	SlopedSolid_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F51E
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F51E
		cmp.w	d2,d0
		bcs.s	loc_F52C

loc_F51E:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F52C:
		move.w	d4,d2
		bsr.w	sub_F748
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------
; loc_F536:
SlopedSolid_cont:
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	SolidObject_TestClearPush
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	SolidObject_TestClearPush
		move.w	d0,d5
		btst	#0,1(a0)
		beq.s	loc_F55C
		not.w	d5
		add.w	d3,d5

loc_F55C:
		lsr.w	#1,d5
		move.b	(a2,d5.w),d3
		sub.b	(a2),d3
		ext.w	d3
		move.w	obY(a0),d5
		sub.w	d3,d5
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	SolidObject_TestClearPush
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.w	SolidObject_TestClearPush
		bra.w	SolidObject_ChkBounds
; ===========================================================================
; loc_F590:
SolidObject_OnScreenTest:
		tst.b	1(a0)
		bpl.w	SolidObject_TestClearPush
; loc_F598:
SolidObject_cont:
		; We now perform the x portion of a bounding box check.  To do this, we assume a
		; coordinate system where the x origin is at the object's left edge.
		move.w	obX(a1),d0			; load Sonic's x position...
		sub.w	obX(a0),d0			; ... and calculate his x position relative to the object
		add.w	d1,d0				; assume object's left edge is at (0,0).  This is also Sonic's distance to the object's left edge.
		bmi.w	SolidObject_TestClearPush	; branch, if Sonic is outside the object's left edge
		move.w	d1,d3
		add.w	d3,d3				; calculate object's width
		cmp.w	d3,d0
		bhi.w	SolidObject_TestClearPush	; branch, if Sonic is outside the object's right edge
		; We now perform the y portion of a bounding box check.  To do this, we assume a
		; coordinate system where the y origin is at the highest y position relative to the object
		; at which Sonic would still collide with it.  This point is
		;   y_pos(object) - width(object)/2 - y_radius(Sonic) - 4,
		; where object is stored in (a0), Sonic in (a1), and height(object)/2 in d2.  This way
		; of doing it causes the object's hitbox to be vertically off-center by -4 pixels.
		move.b	obHeight(a1),d3			; load Sonic's y radius
		ext.w	d3
		add.w	d3,d2				; calculate maximum distance for a top collision
		move.w	obY(a1),d3			; load Sonic's y position
		sub.w	obY(a0),d3			; ... and calculate his y position relative to the object
		addq.w	#4,d3				; assume a slightly lower position for Sonic
		add.w	d2,d3				; assume the highest position where Sonic would still be colliding with the object to be (0,0)
		bmi.w	SolidObject_TestClearPush	; branch, if Sonic is above this point
		move.w	d2,d4
		add.w	d4,d4				; calculate minimum distance for a bottom collision
		cmp.w	d4,d3
		bcc.w	SolidObject_TestClearPush	; branch, if Sonic is below this point
; loc_F5D2:
SolidObject_ChkBounds:
		tst.b	(f_playerctrl).w
		bmi.w	SolidObject_TestClearPush	; branch, if object collisions are disabled for Sonic
		cmpi.b	#6,obRoutine(a1)		; is Sonic dead?
		bcc.w	loc_F680			; if yes, branch
		tst.w	(Debug_placement_mode).w
		bne.w	loc_F680			; branch, if in Debug Mode

		move.w	d0,d5
		cmp.w	d0,d1
		bcc.s	loc_F5FA			; branch, if Sonic is to the object's left
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5				; calculate Sonic's distance to the object's right edge...
		neg.w	d5				; ... and calculate the absolute value

loc_F5FA:
		move.w	d3,d1
		cmp.w	d3,d2
		bcc.s	loc_F608
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_F608:
		cmp.w	d1,d5
		bhi.w	loc_F684			; branch, if horizontal distance is greater than vertical distance

		cmpi.w	#4,d1
		bls.s	loc_F65A
		tst.w	d0
		beq.s	loc_F634
		bmi.s	loc_F622
		tst.w	obVelX(a1)
		bmi.s	loc_F634
		bra.s	loc_F628
; ===========================================================================

loc_F622:
		tst.w	obVelX(a1)
		bpl.s	loc_F634

loc_F628:
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_F634:
		sub.w	d0,obX(a1)
		btst	#1,obStatus(a1)
		bne.s	loc_F65A
		move.l	d6,d4
		addq.b	#2,d4				; Character is pushing, not standing
		bset	d4,obStatus(a0)
		bset	#5,obStatus(a1)
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6				; This sets bits 0 (Sonic) or 1 (Tails) of high word of d6
		moveq	#1,d4
		rts
; ===========================================================================

loc_F65A:
		bsr.s	sub_F678
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6				; This sets bits 0 (Sonic) or 1 (Tails) of high word of d6
		moveq	#1,d4
		rts
; ===========================================================================
; loc_F668:
SolidObject_TestClearPush:
		move.l	d6,d4
		addq.b	#2,d4
		btst	d4,obStatus(a0)
		beq.s	loc_F680
		move.w	#1,obAnim(a1)

sub_F678:
		move.l	d6,d4
		addq.b	#2,d4
		bclr	d4,obStatus(a0)

loc_F680:
		moveq	#0,d4
		rts
; ===========================================================================

loc_F684:
		tst.w	d3
		bmi.s	loc_F690
		cmpi.w	#$10,d3
		bcs.s	loc_F6D2
		bra.s	SolidObject_TestClearPush
; ===========================================================================

loc_F690:
		tst.w	obVelY(a1)
		beq.s	loc_F6B2
		bpl.s	loc_F6A6
		tst.w	d3
		bpl.s	loc_F6A6
		sub.w	d3,obY(a1)
		move.w	#0,obVelY(a1)

loc_F6A6:
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6				; This sets bits 2 (Sonic) or 3 (Tails) of high word of d6
		moveq	#-2,d4
		rts
; ===========================================================================

loc_F6B2:
		btst	#1,obStatus(a1)
		bne.s	loc_F6A6
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	(KillSonic).l
		movea.l	(sp)+,a0			; load obj address
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6				; This sets bits 2 (Sonic) or 3 (Tails) of high word of d6
		moveq	#-2,d4
		rts
; ===========================================================================

loc_F6D2:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	loc_F70A
		cmp.w	d2,d1
		bcc.s	loc_F70A
		tst.w	obVelY(a1)
		bmi.s	loc_F70A
		sub.w	d3,obY(a1)
		subq.w	#1,obY(a1)
		bsr.w	RideObject_SetRide
		move.w	d6,d4
		addi.b	#$11,d4
		bset	d4,d6				; This sets bits 4 (Sonic) or 5 (Tails) of high word of d6
		moveq	#-1,d4
		rts
; ===========================================================================

loc_F70A:
		moveq	#0,d4
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_F70E:
MvSonicOnPtfm:
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.s	loc_F71E
; ===========================================================================
		; a couple lines of unused/leftover/dead code from Sonic 1 ; a0=object
		move.w	obY(a0),d0
		subi.w	#9,d0

loc_F71E:
		tst.b	(f_playerctrl).w
		bmi.s	locret_F746
		cmpi.b	#6,obRoutine(a1)
		bcc.s	locret_F746
		tst.w	(Debug_placement_mode).w
		bne.s	locret_F746
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_F746:
		rts
; End of function MvSonicOnPtfm


; =============== S U B	R O U T	I N E =======================================


sub_F748:
		btst	#3,obStatus(a1)
		beq.s	locret_F788
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,1(a0)
		beq.s	loc_F768
		not.w	d0
		add.w	d1,d0

loc_F768:
		move.b	(a2,d0.w),d1
		ext.w	d1
		move.w	obY(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_F788:
		rts
; End of function sub_F748


; =============== S U B	R O U T	I N E =======================================


sub_F78A:
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_F7A0
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		addq.b	#1,d6
; End of function sub_F78A


; =============== S U B	R O U T	I N E =======================================


sub_F7A0:
		btst	d6,obStatus(a0)
		beq.w	loc_F89E
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F7C4
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F7C4
		cmp.w	d2,d0
		bcs.s	loc_F7D2

loc_F7C4:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F7D2:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; End of function sub_F7A0


; =============== S U B	R O U T	I N E =======================================


sub_F7DC:
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_F7F2
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		addq.b	#1,d6
; End of function sub_F7DC


; =============== S U B	R O U T	I N E =======================================


sub_F7F2:

; FUNCTION CHUNK AT 0000F968 SIZE 00000038 BYTES

		btst	d6,obStatus(a0)
		beq.w	SlopedPlatform_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F816
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F816
		cmp.w	d2,d0
		bcs.s	loc_F824

loc_F816:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F824:
		move.w	d4,d2
		bsr.w	sub_F748
		moveq	#0,d4
		rts
; End of function sub_F7F2


; =============== S U B	R O U T	I N E =======================================


sub_F82E:
		lea	(v_objspace).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_F844
		movem.l	(sp)+,d1-d4
		lea	(v_objspace+$40).w,a1
		addq.b	#1,d6
; End of function sub_F82E


; =============== S U B	R O U T	I N E =======================================


sub_F844:

; FUNCTION CHUNK AT 0000F9A0 SIZE 00000028 BYTES

		btst	d6,obStatus(a0)
		beq.w	loc_F9A0
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F868
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F868
		cmp.w	d2,d0
		bcs.s	loc_F876

loc_F868:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F876:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; End of function sub_F844


; =============== S U B	R O U T	I N E =======================================


sub_F880:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	locret_F966
		cmp.w	d2,d0
		bcc.w	locret_F966
		bra.s	loc_F8BC
; ---------------------------------------------------------------------------

loc_F89E:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	locret_F966
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	locret_F966

loc_F8BC:
		move.w	obY(a0),d0
		sub.w	d3,d0

loc_F8C2:
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	locret_F966
		cmpi.w	#$FFF0,d0
		bcs.w	locret_F966
		tst.b	(f_playerctrl).w
		bmi.w	locret_F966
		cmpi.b	#6,obRoutine(a1)
		bcc.w	locret_F966
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
; sub_F8F8:
RideObject_SetRide:
		btst	#3,obStatus(a1)
		beq.s	loc_F916
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		addi.l	#v_objspace,d0
		movea.l	d0,a3
		bclr	#3,obStatus(a3)

loc_F916:
		move.w	a0,d0
		subi.w	#v_objspace,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)
		beq.s	loc_F95C
		move.l	a0,-(sp)
		movea.l	a1,a0
		move.w	a0,d1
		subi.w	#v_objspace,d1
		bne.s	loc_F954
		jsr	(Sonic_ResetOnFloor).l
		bra.s	loc_F95A
; ===========================================================================

loc_F954:
		jsr	(Tails_ResetTailsOnFloor).l

loc_F95A:
		movea.l	(sp)+,a0

loc_F95C:
		bset	#3,obStatus(a1)
		bset	d6,obStatus(a0)

locret_F966:
		rts
; ===========================================================================
; loc_F968:
SlopedPlatform_cont:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	locret_F966
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	locret_F966
		btst	#0,1(a0)
		beq.s	loc_F98E
		not.w	d0
		add.w	d1,d0

loc_F98E:
		lsr.w	#1,d0
		move.b	(a2,d0.w),d3
		ext.w	d3
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	loc_F8C2
; END OF FUNCTION CHUNK	FOR sub_F7F2
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_F844

loc_F9A0:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	locret_F966
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	locret_F966
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	loc_F8C2
; END OF FUNCTION CHUNK	FOR sub_F844

; =============== S U B	R O U T	I N E =======================================


sub_F9C8:
		move.w	d1,d2
		add.w	d2,d2
		lea	(v_objspace).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_F9E8
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F9E8
		cmp.w	d2,d0
		bcs.s	locret_F9FA

loc_F9E8:
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a0)
		bclr	#3,obStatus(a0)

locret_F9FA:
		rts
; End of function sub_F9C8

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

Obj01:
		tst.w	(Debug_placement_mode).w	; is debug mode being used?
		beq.s	Obj01_Normal			; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

Obj01_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj01_Index(pc,d0.w),d1
		jmp	Obj01_Index(pc,d1.w)
; ===========================================================================
Obj01_Index:	dc.w Obj01_Init-Obj01_Index		; 0
		dc.w Obj01_Control-Obj01_Index		; 2
		dc.w Obj01_Hurt-Obj01_Index		; 4
		dc.w Obj01_Dead-Obj01_Index		; 6
		dc.w Obj01_ResetLevel-Obj01_Index	; 8
; ===========================================================================
; Obj01_Main:
Obj01_Init:
		addq.b	#2,obRoutine(a0)		; => Obj01_Control
		move.b	#$13,obHeight(a0)		; this sets Sonic's collision height (2*pixels)
		move.b	#9,obWidth(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#$780,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#2,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(Sonic_top_speed).w	; set Sonic's top speed
		move.w	#$C,(Sonic_acceleration).w	; set Sonic's acceleration
		move.w	#$80,(Sonic_deceleration).w	; set Sonic's deceleration
		move.b	#$C,$3E(a0)
		move.b	#$D,$3F(a0)
		move.b	#0,$2C(a0)
		move.b	#4,$2D(a0)
		move.w	#0,(Sonic_Pos_Record_Index).w
		move.w	#$3F,d2

loc_FA88:
		bsr.w	Sonic_RecordPos
		move.w	#0,(a1,d0.w)
		dbf	d2,loc_FA88

; ---------------------------------------------------------------------------
; Normal state for Sonic
; ---------------------------------------------------------------------------

Obj01_Control:
		tst.w	(Debug_mode_flag).w		; is debug cheat enabled?
		beq.s	loc_FAB0			; if not, branch
		btst	#4,(v_jpadpress1).w		; is button B pressed?
		beq.s	loc_FAB0			; if not, branch
		move.w	#1,(Debug_placement_mode).w	; change Sonic into ring/item
		clr.b	(f_lockctrl).w			; unlock control
		rts
; -----------------------------------------------------------------------
loc_FAB0:
		tst.b	(f_lockctrl).w			; are controls locked?
		bne.s	loc_FABC			; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w	; copy new held buttons, to enable joypad

loc_FABC:
		btst	#0,(f_playerctrl).w		; is Sonic interacting with another object that holds him in place or controls his movement somehow?
		bne.s	Obj01_ControlsLock		; if yes, branch to skip Sonic's control
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Obj01_Modes(pc,d0.w),d1
		jsr	Obj01_Modes(pc,d1.w)		; run Sonic's movement control code

Obj01_ControlsLock:
		bsr.s	Sonic_Display
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Water
		move.b	(Primary_Angle).w,$36(a0)
		move.b	(Secondary_Angle).w,$37(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	loc_FAFE
		tst.b	obAnim(a0)
		bne.s	loc_FAFE
		move.b	obPrevAni(a0),obAnim(a0)

loc_FAFE:
		bsr.w	Sonic_Animate
		tst.b	(f_playerctrl).w
		bmi.s	loc_FB0E
		jsr	(TouchResponse).l

loc_FB0E:
		bra.w	LoadSonicDynPLC

; ===========================================================================
; secondary states under state Obj01_Control
Obj01_Modes:	dc.w Obj01_MdNormal-Obj01_Modes
		dc.w Obj01_MdAir-Obj01_Modes
		dc.w Obj01_MdRoll-Obj01_Modes
		dc.w Obj01_MdJump-Obj01_Modes

MusicList_Sonic:dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ

; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Display:
		move.w	$30(a0),d0
		beq.s	Obj01_Display
		subq.w	#1,$30(a0)
		lsr.w	#3,d0
		bcc.s	Obj01_ChkInvin
; loc_FB2E:
Obj01_Display:
		jsr	(DisplaySprite).l
; loc_FB34:
Obj01_ChkInvin:						; Checks if invincibility has expired and (should) disables it if it has
		tst.b	(v_invinc).w
		beq.s	Obj01_ChkShoes
		tst.w	$32(a0)
		beq.s	Obj01_ChkShoes
		bra.s	Obj01_ChkShoes
; ===========================================================================
; Strange that they disabled the invincibility timer for this build,
; a leftover debugging feature?
		subq.w	#1,$32(a0)
		bne.s	Obj01_ChkShoes
		tst.b	(f_lockscreen).w
		bne.s	Obj01_RmvInvin
		cmpi.w	#$C,(v_air).w
		bcs.s	Obj01_RmvInvin
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		cmpi.w	#$103,(Current_ZoneAndAct).w
		bne.s	loc_FB66
		moveq	#5,d0

loc_FB66:
		lea	MusicList_Sonic(pc),a1
		move.b	(a1,d0.w),d0
		jsr	(PlaySound).l
; loc_FB74:
Obj01_RmvInvin:
		move.b	#0,(v_invinc).w
; loc_FB7A:
Obj01_ChkShoes:	; Checks if Speed Shoes have expired and disables them if they have.
		tst.b	(v_shoes).w
		beq.s	Obj01_ExitChk
		tst.w	$34(a0)
		beq.s	Obj01_ExitChk
		subq.w	#1,$34(a0)
		bne.s	Obj01_ExitChk
		move.w	#$600,(Sonic_top_speed).w
		move.w	#$C,(Sonic_acceleration).w
		move.w	#$80,(Sonic_deceleration).w
		move.b	#0,(v_shoes).w
		move.w	#bgm_Slowdown,d0
		jmp	(PlaySound).l
; ---------------------------------------------------------------------------
; locret_FBAE:
Obj01_ExitChk:
		rts
; End of function Sonic_Display


; ---------------------------------------------------------------------------
; Subroutine to record Sonic's previous positions for invincibility stars
; and input/status flags for Tails' AI to follow
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_FBB2: CopySonicMovesForTails:
Sonic_RecordPos:
		move.w	(Sonic_Pos_Record_Index).w,d0
		lea	(Sonic_Pos_Record_Buf).w,a1
		lea	(a1,d0.w),a1
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		addq.b	#4,(Sonic_Pos_Record_Index+1).w

		lea	(Sonic_Stat_Record_Buf).w,a1
		move.w	(v_jpadhold1).w,(a1,d0.w)
		rts
; End of function Sonic_RecordPos

; ===========================================================================
; ---------------------------------------------------------------------------
; Seemingly an earlier subroutine to copy Sonic's status flags for Tails' AI
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Unused_RecordPos:
		move.w	($FFFFEEE0).w,d0
		subq.b	#4,d0
		lea	(Tails_Pos_Record_Buf).w,a1
		lea	(a1,d0.w),a2
		move.w	obX(a0),d1
		swap	d1
		move.w	obY(a0),d1
		cmp.l	(a2),d1
		beq.s	locret_FC02
		addq.b	#4,d0
		lea	(a1,d0.w),a2
		move.w	obX(a0),(a2)+
		move.w	obY(a0),(a2)
		addq.b	#4,($FFFFEEE1).w

locret_FC02:
		rts
; End of subroutine Unused_RecordPos


; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_FC06:
Sonic_Water:
		tst.b	(Water_flag).w
		bne.s	Obj01_InWater

locret_FC0A:
		rts
; ---------------------------------------------------------------------------
; loc_FC0E: Obj01_InLevelWithWater:
Obj01_InWater:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0			; is Sonic above water?
		bge.s	Obj01_OutWater			; if yes, branch

		bset	#6,obStatus(a0)			; set underwater flag
		bne.s	locret_FC0A			; if already underwater, branch

		bsr.w	ResumeMusic
		move.b	#$A,(v_objspace+$340).w		; load Obj0A (sonic's breathing bubbles) at $FFFFB340
		move.b	#$81,(v_objspace+$368).w
		move.w	#$300,(Sonic_top_speed).w
		move.w	#6,(Sonic_acceleration).w
		move.w	#$40,(Sonic_deceleration).w
		asr	obVelX(a0)
		asr	obVelY(a0)			; memory oprands can only be shifted one at a time
		asr	obVelY(a0)
		beq.s	locret_FC0A
		move.b	#8,(v_objspace+$300).w		; splash animation
		move.w	#sfx_Splash,d0			; splash sound
		jmp	(PlaySound_Special).l

; ---------------------------------------------------------------------------
; Obj01_NotInWater:
Obj01_OutWater:
		bclr	#6,obStatus(a0)			; unset underwater flag
		beq.s	locret_FC0A			; if already unset, branch

		bsr.w	ResumeMusic
		move.w	#$600,(Sonic_top_speed).w
		move.w	#$C,(Sonic_acceleration).w
		move.w	#$80,(Sonic_deceleration).w
		asl	obVelY(a0)
		beq.w	locret_FC0A
		move.b	#8,(v_objspace+$300).w		; splash animation
		cmpi.w	#$F000,obVelY(a0)
		bgt.s	loc_FC98
		move.w	#$F000,obVelY(a0)		; limit upward y velocity exiting the water

loc_FC98:
		move.w	#sfx_Splash,d0			; splash sound
		jmp	(PlaySound_Special).l
; End of function Sonic_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of subroutine Obj01_MdNormal
; Called if Sonic is neither airborne nor rolling this frame
; ---------------------------------------------------------------------------

Obj01_MdNormal:
		bsr.w	Sonic_CheckSpindash
		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMove).l
		bsr.w	AnglePos
		bsr.w	Sonic_SlopeRepel
		rts
; End of subroutine Obj01_MdNormal

; ===========================================================================
; Start of subroutine Obj01_MdAir
; Called if Sonic is airborne, but not in a ball (thus, probably not jumping)
; Obj01_MdJump:
Obj01_MdAir:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMoveAndFall).l
		btst	#6,obStatus(a0)			; is Sonic underwater?
		beq.s	loc_FCEA			; if not, branch
		subi.w	#$28,obVelY(a0)			; reduce gravity by $28 ($38-$28=$10)

loc_FCEA:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_DoLevelCollision
		rts
; End of subroutine Obj01_MdAir

; ===========================================================================
; Start of subroutine Obj01_MdRoll
; Called if Sonic is in a ball, but not airborne (thus, probably rolling)

Obj01_MdRoll:
		bsr.w	Sonic_Jump
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMove).l
		bsr.w	AnglePos
		bsr.w	Sonic_SlopeRepel
		rts
; End of subroutine Obj01_MdRoll

; ===========================================================================
; Start of subroutine Obj01_MdJump
; Called if Sonic is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Obj01_MdAir, at least at this outer level.
;        Why they gave it a separate copy of the code, I don't know.
; Obj01_MdJump2:
Obj01_MdJump:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMoveAndFall).l
		btst	#6,obStatus(a0)			; is Sonic underwater?
		beq.s	loc_FD34			; if not, branch
		subi.w	#$28,obVelY(a0)			; reduce gravity by $28 ($38-$28=$10)

loc_FD34:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_DoLevelCollision
		rts
; End of subroutine Obj01_MdJump


; ---------------------------------------------------------------------------
; Subroutine to make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:
		move.w	(Sonic_top_speed).w,d6
		move.w	(Sonic_acceleration).w,d5
		move.w	(Sonic_deceleration).w,d4
		tst.b	(f_slidemode).w
		bne.w	Obj01_Traction
		tst.w	$2E(a0)
		bne.w	Obj01_UpdateSpeedOnGround
		btst	#2,(v_jpadhold2).w		; is left being pressed?
		beq.s	loc_FD66			; if not, branch
		bsr.w	Sonic_MoveLeft

loc_FD66:
		btst	#3,(v_jpadhold2).w		; is right being pressed?
		beq.s	loc_FD72			; if not, branch
		bsr.w	Sonic_MoveRight

loc_FD72:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0				; is Sonic on a slope?
		bne.w	Obj01_UpdateSpeedOnGround	; if yes, branch
		tst.w	obInertia(a0)			; is Sonic moving?
		bne.w	Obj01_UpdateSpeedOnGround	; if yes, branch
		bclr	#5,obStatus(a0)
		cmpi.b	#$B,obAnim(a0)			; use "standing" animation
		beq.s	loc_FD9E
		move.b	#5,obAnim(a0)

loc_FD9E:
		btst	#3,obStatus(a0)
		beq.s	Sonic_Balance
		moveq	#0,d0
		move.b	$3D(a0),d0
		lsl.w	#6,d0
		lea	(v_objspace).w,a1		; a1=character
		lea	(a1,d0.w),a1			; a1=object
		tst.b	obStatus(a1)
		bmi.s	Sonic_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_FE00
		cmp.w	d2,d1
		bge.s	loc_FDF0
		bra.s	Sonic_LookUp
; ---------------------------------------------------------------------------

Sonic_Balance:
		jsr	(ChkFloorEdge).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,$36(a0)
		bne.s	loc_FDF8

loc_FDF0:
		bclr	#0,obStatus(a0)
		bra.s	loc_FE06
; ---------------------------------------------------------------------------

loc_FDF8:
		cmpi.b	#3,$37(a0)
		bne.s	Sonic_LookUp

loc_FE00:
		bset	#0,obStatus(a0)

loc_FE06:
		move.b	#6,obAnim(a0)
		bra.s	Obj01_UpdateSpeedOnGround
; ---------------------------------------------------------------------------

Sonic_LookUp:
		btst	#0,(v_jpadhold2).w		; is up being pressed?
		beq.s	Sonic_Duck			; if not, branch
		move.b	#7,obAnim(a0)			; use "looking up" animation
		bra.s	Obj01_UpdateSpeedOnGround
; ---------------------------------------------------------------------------

Sonic_Duck:
		btst	#1,(v_jpadhold2).w		; is down being pressed?
		beq.s	Obj01_UpdateSpeedOnGround	; if not, branch
		move.b	#8,obAnim(a0)			; use "ducking" animation

; ---------------------------------------------------------------------------
; updates Sonic's speed on the ground
; ---------------------------------------------------------------------------
; loc_FE2C:
Obj01_UpdateSpeedOnGround:
		move.b	(v_jpadhold2).w,d0
		andi.b	#$C,d0				; is left/right being pressed?
		bne.s	Obj01_Traction			; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	Obj01_Traction
		bmi.s	Obj01_SettleLeft

; slow down when facing right and not pressing a direction
; Obj01_SettleRight:
		sub.w	d5,d0
		bcc.s	loc_FE46
		move.w	#0,d0

loc_FE46:
		move.w	d0,obInertia(a0)
		bra.s	Obj01_Traction
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
; loc_FE4C:
Obj01_SettleLeft:
		add.w	d5,d0
		bcc.s	loc_FE54
		move.w	#0,d0

loc_FE54:
		move.w	d0,obInertia(a0)

; increase or decrease speed on the ground
; loc_FE58:
Obj01_Traction:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

; stops Sonic from running through walls that meet the ground
; loc_FE76:
Obj01_CheckWallsOnGround:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_FEF6
		move.b	#$40,d1				; rotate 90 degress clockwise
		tst.w	obInertia(a0)			; check if Sonic's moving
		beq.s	locret_FEF6			; if not, branch
		bmi.s	loc_FE8E			; if negative, branch
		neg.w	d1				; rotate counterclockwise

loc_FE8E:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	CalcRoomInFront
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_FEF6
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_FEF2
		cmpi.b	#$40,d0
		beq.s	loc_FED8
		cmpi.b	#$80,d0
		beq.s	loc_FED2
		cmpi.w	#$600,obVelX(a0)		; is Sonic at max speed?
		bge.s	Sonic_WallRecoil		; if yes, branch
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_FED2:
		sub.w	d1,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_FED8:
		cmpi.w	#$FA00,obVelX(a0)		; is Sonic at max speed?
		ble.s	Sonic_WallRecoil		; if yes, branch
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_FEF2:
		add.w	d1,obVelY(a0)

locret_FEF6:
		rts

; ---------------------------------------------------------------------------
; Subroutine to recoil Sonic off a wall if moving a top speed
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WallRecoil:
		move.b	#4,obRoutine(a0)
		bsr.w	Sonic_ResetOnFloor
		bset	#1,obStatus(a0)
		move.w	#-$200,d0
		tst.w	obVelX(a0)
		bpl.s	Sonic_WallRecoil_Right
		neg.w	d0

Sonic_WallRecoil_Right:
		move.w	d0,obVelX(a0)
		move.w	#-$400,obVelY(a0)
		move.w	#0,obInertia(a0)
		move.b	#$A,obAnim(a0)
		move.b	#1,ob2ndRout(a0)
		move.w	#sfx_Death,d0
		jsr	(PlaySound_Special).l
		rts
; End of function Sonic_Move


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_FF44
		bpl.s	Sonic_TurnLeft

loc_FF44:
		bset	#0,obStatus(a0)
		bne.s	loc_FF58
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)

loc_FF58:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_FF64
		move.w	d1,d0

loc_FF64:
		move.w	d0,obInertia(a0)
		move.b	#0,obAnim(a0)
		rts
; ---------------------------------------------------------------------------
; loc_FF70:
Sonic_TurnLeft:
		sub.w	d4,d0
		bcc.s	loc_FF78
		move.w	#$FF80,d0

loc_FF78:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_FFA6
		cmpi.w	#$400,d0
		blt.s	locret_FFA6
		move.b	#$D,obAnim(a0)
		bclr	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(PlaySound_Special).l

locret_FFA6:
		rts
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	Sonic_TurnRight
		bclr	#0,obStatus(a0)
		beq.s	loc_FFC2
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)

loc_FFC2:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_FFCA
		move.w	d6,d0

loc_FFCA:
		move.w	d0,obInertia(a0)
		move.b	#0,obAnim(a0)
		rts
; ---------------------------------------------------------------------------
; loc_FFD6:
Sonic_TurnRight:
		add.w	d4,d0
		bcc.s	loc_FFDE
		move.w	#$80,d0

loc_FFDE:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1000C
		cmpi.w	#$FC00,d0
		bgt.s	locret_1000C
		move.b	#$D,obAnim(a0)

loc_FFFC:
		bset	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(PlaySound_Special).l

locret_1000C:
		rts
; End of function Sonic_MoveRight


; =============== S U B	R O U T	I N E =======================================


Sonic_RollSpeed:
		move.w	(Sonic_top_speed).w,d6
		asl.w	#1,d6
		move.w	(Sonic_acceleration).w,d5
		asr.w	#1,d5
		move.w	(Sonic_deceleration).w,d4
		asr.w	#2,d4
		tst.b	(f_slidemode).w
		bne.w	loc_1008A
		tst.w	$2E(a0)
		bne.s	loc_10046
		btst	#2,(v_jpadhold2).w
		beq.s	loc_1003A
		bsr.w	Sonic_RollLeft

loc_1003A:
		btst	#3,(v_jpadhold2).w
		beq.s	loc_10046
		bsr.w	Sonic_RollRight

loc_10046:
		move.w	obInertia(a0),d0
		beq.s	loc_10068
		bmi.s	loc_1005C
		sub.w	d5,d0
		bcc.s	loc_10056
		move.w	#0,d0

loc_10056:
		move.w	d0,obInertia(a0)
		bra.s	loc_10068
; ---------------------------------------------------------------------------

loc_1005C:
		add.w	d5,d0
		bcc.s	loc_10064
		move.w	#0,d0

loc_10064:
		move.w	d0,obInertia(a0)

loc_10068:
		tst.w	obInertia(a0)
		bne.s	loc_1008A
		bclr	#2,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#5,obAnim(a0)
		subq.w	#5,obY(a0)

loc_1008A:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_100AE
		move.w	#$1000,d1

loc_100AE:
		cmpi.w	#$F000,d1
		bge.s	loc_100B8
		move.w	#$F000,d1

loc_100B8:
		move.w	d1,obVelX(a0)
		bra.w	Obj01_CheckWallsOnGround
; End of function Sonic_RollSpeed


; =============== S U B	R O U T	I N E =======================================


Sonic_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_100C8
		bpl.s	loc_100D6

loc_100C8:
		bset	#0,obStatus(a0)
		move.b	#2,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_100D6:
		sub.w	d4,d0
		bcc.s	loc_100DE
		move.w	#$FF80,d0

loc_100DE:
		move.w	d0,obInertia(a0)
		rts
; End of function Sonic_RollLeft


; =============== S U B	R O U T	I N E =======================================


Sonic_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_100F8
		bclr	#0,obStatus(a0)
		move.b	#2,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_100F8:
		add.w	d4,d0
		bcc.s	loc_10100
		move.w	#$80,d0

loc_10100:
		move.w	d0,obInertia(a0)
		rts
; End of function Sonic_RollRight


; =============== S U B	R O U T	I N E =======================================


Sonic_ChgJumpDir:
		move.w	(Sonic_top_speed).w,d6
		move.w	(Sonic_acceleration).w,d5
		asl.w	#1,d5
		btst	#4,obStatus(a0)
		bne.s	loc_10150
		move.w	obVelX(a0),d0
		btst	#2,(v_jpadhold2).w
		beq.s	loc_10136
		bset	#0,obStatus(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_10136
		move.w	d1,d0

loc_10136:
		btst	#3,(v_jpadhold2).w
		beq.s	loc_1014C
		bclr	#0,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1014C
		move.w	d6,d0

loc_1014C:
		move.w	d0,obVelX(a0)

loc_10150:
		cmpi.w	#$60,(Camera_Y_pos_bias).w
		beq.s	loc_10162
		bcc.s	loc_1015E
		addq.w	#4,(Camera_Y_pos_bias).w

loc_1015E:
		subq.w	#2,(Camera_Y_pos_bias).w

loc_10162:
		cmpi.w	#$FC00,obVelY(a0)
		bcs.s	locret_10190
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_10190
		bmi.s	loc_10184
		sub.w	d1,d0
		bcc.s	loc_1017E
		move.w	#0,d0

loc_1017E:
		move.w	d0,obVelX(a0)
		rts
; ---------------------------------------------------------------------------

loc_10184:
		sub.w	d1,d0
		bcs.s	loc_1018C
		move.w	#0,d0

loc_1018C:
		move.w	d0,obVelX(a0)

locret_10190:
		rts
; End of function Sonic_ChgJumpDir


; =============== S U B	R O U T	I N E =======================================

; Sonic_LevelBoundaries:
Sonic_LevelBound:
		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(Camera_Min_X_pos).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0
		bhi.s	loc_101FA
		move.w	(Camera_Max_X_pos).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	loc_101C0
		addi.w	#$40,d0

loc_101C0:
		cmp.w	d1,d0
		bls.s	loc_101FA

loc_101C4:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		blt.s	loc_101D4
		rts
; ---------------------------------------------------------------------------

loc_101D4:
		cmpi.w	#$501,(Current_ZoneAndAct).w
		bne.w	JmpTo_KillSonic
		cmpi.w	#$2000,(v_objspace+obX).w
		bcs.w	JmpTo_KillSonic
		clr.b	(v_lastlamp).w
		move.w	#1,(Level_Inactive_flag).w
		move.w	#$103,(Current_ZoneAndAct).w
		rts
; ---------------------------------------------------------------------------

loc_101FA:
		move.w	d0,obX(a0)
		move.w	#0,$A(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obInertia(a0)
		bra.s	loc_101C4
; End of function Sonic_LevelBound


; =============== S U B	R O U T	I N E =======================================


Sonic_Roll:
		tst.b	(f_slidemode).w
		bne.s	Obj01_NoRoll
		move.w	obInertia(a0),d0
		bpl.s	loc_10220
		neg.w	d0

loc_10220:
		cmpi.w	#$80,d0
		bcs.s	Obj01_NoRoll
		move.b	(v_jpadhold2).w,d0
		andi.b	#$C,d0
		bne.s	Obj01_NoRoll
		btst	#1,(v_jpadhold2).w
		bne.s	loc_1023A

Obj01_NoRoll:
		rts
; ---------------------------------------------------------------------------

loc_1023A:
		btst	#2,obStatus(a0)
		beq.s	Obj01_DoRoll
		rts
; ---------------------------------------------------------------------------

Obj01_DoRoll:
		bset	#2,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#2,obAnim(a0)
		addq.w	#5,obY(a0)
		move.w	#sfx_Roll,d0
		jsr	(PlaySound_Special).l
		tst.w	obInertia(a0)
		bne.s	locret_10276
		move.w	#$200,obInertia(a0)

locret_10276:
		rts
; End of function Sonic_Roll


; =============== S U B	R O U T	I N E =======================================


Sonic_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#$70,d0
		beq.w	locret_1031C
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_13102
		cmpi.w	#6,d1
		blt.w	locret_1031C
		move.w	#$680,d2
		btst	#6,obStatus(a0)
		beq.s	loc_102AA
		move.w	#$380,d2

loc_102AA:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		move.w	#sfx_Jump,d0
		jsr	(PlaySound_Special).l
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		btst	#2,obStatus(a0)
		bne.s	loc_1031E
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#2,obAnim(a0)
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)

locret_1031C:
		rts
; ---------------------------------------------------------------------------

loc_1031E:
		bset	#4,obStatus(a0)
		rts
; End of function Sonic_Jump


; =============== S U B	R O U T	I N E =======================================


Sonic_JumpHeight:
		tst.b	$3C(a0)
		beq.s	loc_10352
		move.w	#$FC00,d1
		btst	#6,obStatus(a0)
		beq.s	loc_1033C
		move.w	#$FE00,d1

loc_1033C:
		cmp.w	obVelY(a0),d1
		ble.s	locret_10350
		move.b	(v_jpadhold2).w,d0
		andi.b	#$70,d0
		bne.s	locret_10350
		move.w	d1,obVelY(a0)

locret_10350:
		rts
; ---------------------------------------------------------------------------

loc_10352:
		cmpi.w	#$F040,obVelY(a0)
		bge.s	locret_10360
		move.w	#$F040,obVelY(a0)

locret_10360:
		rts
; End of function Sonic_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Sonic_Spindash:
Sonic_CheckSpindash:
		tst.b	$39(a0)
		bne.s	Sonic_UpdateSpindash
		cmpi.b	#8,obAnim(a0)
		bne.s	locret_10394
		move.b	(v_jpadpress2).w,d0
		andi.b	#$70,d0
		beq.w	locret_10394
		move.b	#9,obAnim(a0)
		move.w	#sfx_Roll,d0
		jsr	(PlaySound_Special).l
		addq.l	#4,sp
		move.b	#1,$39(a0)

locret_10394:
		rts
; ===========================================================================
; loc_10396:
Sonic_UpdateSpindash:
		move.b	(v_jpadhold2).w,d0
		btst	#1,d0
		bne.s	Sonic_ChargingSpindash

		; unleash the charged spindash and start rolling quickly:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#2,obAnim(a0)
		addq.w	#5,obY(a0)			; add the difference between Sonic's rolling and standing heights
		move.b	#0,$39(a0)
		move.w	#$2000,(Horiz_scroll_delay_val).w
		move.w	#$800,obInertia(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_103D4
		neg.w	obInertia(a0)

loc_103D4:
		bset	#2,obStatus(a0)
		rts
; ===========================================================================
; loc_103DC:
Sonic_ChargingSpindash:
		move.b	(v_jpadpress2).w,d0
		andi.b	#$70,d0
		beq.w	loc_103EA
		nop

loc_103EA:
		addq.l	#4,sp
		rts
; End of function Sonic_CheckSpindash


; =============== S U B	R O U T	I N E =======================================


Sonic_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_10422
		move.b	obAngle(a0),d0

loc_10400:
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	locret_10422
		bmi.s	loc_1041E
		tst.w	d0
		beq.s	locret_1041C
		add.w	d0,obInertia(a0)

locret_1041C:
		rts
; ---------------------------------------------------------------------------

loc_1041E:
		add.w	d0,obInertia(a0)

locret_10422:
		rts
; End of function Sonic_SlopeResist


; =============== S U B	R O U T	I N E =======================================


Sonic_RollRepel:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_1045E
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	loc_10454
		tst.w	d0
		bpl.s	loc_1044E
		asr.l	#2,d0

loc_1044E:
		add.w	d0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_10454:
		tst.w	d0
		bmi.s	loc_1045A
		asr.l	#2,d0

loc_1045A:
		add.w	d0,obInertia(a0)

locret_1045E:
		rts
; End of function Sonic_RollRepel


; =============== S U B	R O U T	I N E =======================================


Sonic_SlopeRepel:
		nop
		tst.b	$38(a0)
		bne.s	locret_1049A
		tst.w	$2E(a0)
		bne.s	loc_1049C
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	locret_1049A
		move.w	obInertia(a0),d0
		bpl.s	loc_10484
		neg.w	d0

loc_10484:
		cmpi.w	#$280,d0
		bcc.s	locret_1049A
		clr.w	obInertia(a0)
		bset	#1,obStatus(a0)
		move.w	#$1E,$2E(a0)

locret_1049A:
		rts
; ---------------------------------------------------------------------------

loc_1049C:
		subq.w	#1,$2E(a0)
		rts
; End of function Sonic_SlopeRepel


; =============== S U B	R O U T	I N E =======================================


Sonic_JumpAngle:
		move.b	obAngle(a0),d0
		beq.s	loc_104BC
		bpl.s	loc_104B2
		addq.b	#2,d0
		bcc.s	loc_104B0
		moveq	#0,d0

loc_104B0:
		bra.s	loc_104B8
; ---------------------------------------------------------------------------

loc_104B2:
		subq.b	#2,d0
		bcc.s	loc_104B8
		moveq	#0,d0

loc_104B8:
		move.b	d0,obAngle(a0)

loc_104BC:
		move.b	$27(a0),d0
		beq.s	locret_104FA
		tst.w	obInertia(a0)
		bmi.s	loc_104E0
		move.b	$2D(a0),d1
		add.b	d1,d0
		bcc.s	loc_104DE
		subq.b	#1,$2C(a0)
		bcc.s	loc_104DE
		move.b	#0,$2C(a0)
		moveq	#0,d0

loc_104DE:
		bra.s	loc_104F6
; ---------------------------------------------------------------------------

loc_104E0:
		move.b	$2D(a0),d1
		sub.b	d1,d0
		bcc.s	loc_104F6
		subq.b	#1,$2C(a0)
		bcc.s	loc_104F6
		move.b	#0,$2C(a0)
		moveq	#0,d0

loc_104F6:
		move.b	d0,$27(a0)

locret_104FA:
		rts
; End of function Sonic_JumpAngle


; =============== S U B	R O U T	I N E =======================================

; Sonic_Floor:
Sonic_DoLevelCollision:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,$3E(a0)
		beq.s	loc_10514
		move.l	#v_colladdr2,(Collision_addr).w

loc_10514:
		move.b	$3F(a0),d5
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_105E4
		cmpi.b	#$80,d0
		beq.w	loc_10646
		cmpi.b	#$C0,d0
		beq.w	loc_106A2
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_10558
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_10558:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_1056A
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_1056A:
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_105E2
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_10582
		cmp.b	d2,d0
		blt.s	locret_105E2

loc_10582:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_105C0
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_105B2
		asr	obVelY(a0)
		bra.s	loc_105D4
; ---------------------------------------------------------------------------

loc_105B2:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_105C0:
		move.w	#0,obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_105D4
		move.w	#$FC0,obVelY(a0)

loc_105D4:
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_105E2
		neg.w	obInertia(a0)

locret_105E2:
		rts
; ---------------------------------------------------------------------------

loc_105E4:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_105FE
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_105FE:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_10618
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_10616
		move.w	#0,obVelY(a0)

locret_10616:
		rts
; ---------------------------------------------------------------------------

loc_10618:
		tst.w	obVelY(a0)
		bmi.s	locret_10644
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_10644
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_10644:
		rts
; ---------------------------------------------------------------------------

loc_10646:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_10658
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_10658:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_1066A
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_1066A:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_106A0
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1068A
		move.w	#0,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_1068A:
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_106A0
		neg.w	obInertia(a0)

locret_106A0:
		rts
; ---------------------------------------------------------------------------

loc_106A2:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_106BC
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_106BC:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_106D6
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_106D4
		move.w	#0,obVelY(a0)

locret_106D4:
		rts
; ---------------------------------------------------------------------------

loc_106D6:
		tst.w	obVelY(a0)
		bmi.s	locret_10702
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_10702
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_10702:
		rts
; End of function Sonic_DoLevelCollision


; =============== S U B	R O U T	I N E =======================================


Sonic_ResetOnFloor:
		btst	#4,obStatus(a0)
		beq.s	loc_10712
		nop
		nop
		nop

loc_10712:
		bclr	#5,obStatus(a0)
		bclr	#1,obStatus(a0)
		bclr	#4,obStatus(a0)
		btst	#2,obStatus(a0)
		beq.s	loc_10748
		bclr	#2,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#0,obAnim(a0)
		subq.w	#5,obY(a0)

loc_10748:
		move.b	#0,$3C(a0)
		move.w	#0,(v_itembonus).w
		move.b	#0,$27(a0)
		rts
; End of function Sonic_ResetOnFloor

; ---------------------------------------------------------------------------

Obj01_Hurt:
		tst.b	ob2ndRout(a0)
		bmi.w	loc_107E8
		jsr	(ObjectMove).l
		addi.w	#$30,obVelY(a0)
		btst	#6,obStatus(a0)
		beq.s	loc_1077E
		subi.w	#$20,obVelY(a0)

loc_1077E:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


Sonic_HurtStop:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		bcs.w	JmpTo_KillSonic
		bsr.w	Sonic_DoLevelCollision
		btst	#1,obStatus(a0)
		bne.s	locret_107E6
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obVelX(a0)
		move.w	d0,obInertia(a0)
		tst.b	ob2ndRout(a0)
		beq.s	loc_107D6
		move.b	#$FF,ob2ndRout(a0)
		move.b	#$B,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_107D6:
		move.b	#0,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.w	#$78,$30(a0)

locret_107E6:
		rts
; End of function Sonic_HurtStop

; ---------------------------------------------------------------------------

loc_107E8:
		cmpi.b	#$B,obAnim(a0)
		bne.s	loc_107FA
		move.b	(v_jpadpress1).w,d0
		andi.b	#$7F,d0
		beq.s	loc_10804

loc_107FA:
		subq.b	#2,obRoutine(a0)
		move.b	#0,ob2ndRout(a0)

loc_10804:
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------
; Obj01_Death:
Obj01_Dead:
		bsr.w	Sonic_GameOver
		jsr	(ObjectMoveAndFall).l
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


Sonic_GameOver:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bcc.w	locret_108B4
		move.w	#$FFC8,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w
		addq.b	#1,(f_lifecount).w
		subq.b	#1,(v_lives).w
		bne.s	loc_10888
		move.w	#0,$3A(a0)
		move.b	#$39,(v_objspace+$80).w
		move.b	#$39,(v_objspace+$C0).w
		move.b	#1,(v_objspace+$DA).w
		clr.b	(f_timeover).w

loc_10876:
		move.w	#bgm_GameOver,d0
		jsr	(PlaySound).l
		moveq	#3,d0
		jmp	(LoadPLC).l
; ---------------------------------------------------------------------------

loc_10888:
		move.w	#$3C,$3A(a0)
		tst.b	(f_timeover).w
		beq.s	locret_108B4
		move.w	#0,$3A(a0)
		move.b	#$39,(v_objspace+$80).w
		move.b	#$39,(v_objspace+$C0).w
		move.b	#2,(v_objspace+$9A).w
		move.b	#3,(v_objspace+$DA).w
		bra.s	loc_10876
; ---------------------------------------------------------------------------

locret_108B4:
		rts
; End of function Sonic_GameOver

; ---------------------------------------------------------------------------

Obj01_ResetLevel:
		tst.w	$3A(a0)
		beq.s	locret_108C8
		subq.w	#1,$3A(a0)
		bne.s	locret_108C8
		move.w	#1,(Level_Inactive_flag).w

locret_108C8:
		rts

; =============== S U B	R O U T	I N E =======================================


Sonic_Animate:

; FUNCTION CHUNK AT 0001095C SIZE 0000015E BYTES

		lea	(SonicAniData).l,a1
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obPrevAni(a0),d0
		beq.s	loc_108EC
		move.b	d0,obPrevAni(a0)
		move.b	#0,obAniFrame(a0)
		move.b	#0,obTimeFrame(a0)

loc_108EC:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	loc_1095C
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_1092A
		move.b	d0,obTimeFrame(a0)
; End of function Sonic_Animate


; =============== S U B	R O U T	I N E =======================================


sub_10912:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#$F0,d0
		bcc.s	loc_1092C

loc_10922:
		move.b	d0,obFrame(a0)
		addq.b	#1,obAniFrame(a0)

locret_1092A:
		rts
; ---------------------------------------------------------------------------

loc_1092C:
		addq.b	#1,d0
		bne.s	loc_1093C
		move.b	#0,obAniFrame(a0)
		move.b	1(a1),d0
		bra.s	loc_10922
; ---------------------------------------------------------------------------

loc_1093C:
		addq.b	#1,d0
		bne.s	loc_10950
		move.b	2(a1,d1.w),d0
		sub.b	d0,obAniFrame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	loc_10922
; ---------------------------------------------------------------------------

loc_10950:
		addq.b	#1,d0
		bne.s	locret_1095A
		move.b	2(a1,d1.w),obAnim(a0)

locret_1095A:
		rts
; End of function sub_10912

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Sonic_Animate

loc_1095C:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_1092A
		addq.b	#1,d0
		bne.w	loc_10A44
		moveq	#0,d0
		move.b	$27(a0),d0
		bne.w	loc_109EA
		moveq	#0,d1
		move.b	obAngle(a0),d0
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_10984
		not.b	d0

loc_10984:
		addi.b	#$10,d0
		bpl.s	loc_1098C
		moveq	#3,d1

loc_1098C:
		andi.b	#$FC,1(a0)
		eor.b	d1,d2
		or.b	d2,1(a0)
		btst	#5,obStatus(a0)
		bne.w	loc_10A88
		lsr.b	#4,d0
		andi.b	#6,d0
		move.w	obInertia(a0),d2
		bpl.s	loc_109B0
		neg.w	d2

loc_109B0:
		lea	(SonicAni_Run).l,a1
		cmpi.w	#$600,d2
		bcc.s	loc_109C2
		lea	(SonicAni_Walk).l,a1

loc_109C2:
		move.b	d0,d1
		lsr.b	#1,d1
		add.b	d1,d0
		add.b	d0,d0
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_109D8
		moveq	#0,d2

loc_109D8:
		lsr.w	#8,d2
		lsr.w	#1,d2
		move.b	d2,obTimeFrame(a0)
		bsr.w	sub_10912
		add.b	d3,obFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_109EA:
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_10A1E
		andi.b	#$FC,1(a0)
		moveq	#0,d2
		or.b	d2,1(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#$9B,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_10A1E:
		moveq	#3,d2
		andi.b	#$FC,1(a0)
		or.b	d2,1(a0)
		neg.b	d0
		addi.b	#$8F,d0
		divu.w	#$16,d0
		addi.b	#$9B,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_10A44:
		addq.b	#1,d0
		bne.s	loc_10A88
		move.w	obInertia(a0),d2
		bpl.s	loc_10A50
		neg.w	d2

loc_10A50:
		lea	(SonicAni_Roll2).l,a1
		cmpi.w	#$600,d2
		bcc.s	loc_10A62
		lea	(SonicAni_Roll).l,a1

loc_10A62:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_10A6C
		moveq	#0,d2

loc_10A6C:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	sub_10912
; ---------------------------------------------------------------------------

loc_10A88:
		move.w	obInertia(a0),d2
		bmi.s	loc_10A90
		neg.w	d2

loc_10A90:
		addi.w	#$800,d2
		bpl.s	loc_10A98
		moveq	#0,d2

loc_10A98:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0)
		lea	(SonicAni_Push).l,a1
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	sub_10912
; End of function Sonic_Animate
; ===========================================================================
; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
SonicAniData:	dc.w SonicAni_Walk-SonicAniData
		dc.w SonicAni_Run-SonicAniData
		dc.w SonicAni_Roll-SonicAniData
		dc.w SonicAni_Roll2-SonicAniData
		dc.w SonicAni_Push-SonicAniData
		dc.w SonicAni_Wait-SonicAniData
		dc.w SonicAni_Balance-SonicAniData
		dc.w SonicAni_LookUp-SonicAniData
		dc.w SonicAni_Duck-SonicAniData
		dc.w SonicAni_Spindash-SonicAniData
		dc.w SonicAni_WallRecoil1-SonicAniData
		dc.w SonicAni_WallRecoil2-SonicAniData
		dc.w SonicAni_0C-SonicAniData
		dc.w SonicAni_Stop-SonicAniData
		dc.w SonicAni_Float1-SonicAniData
		dc.w SonicAni_Float2-SonicAniData
		dc.w SonicAni_10-SonicAniData
		dc.w SonicAni_S1LZHang-SonicAniData
		dc.w SonicAni_Unused12-SonicAniData
		dc.w SonicAni_Unused13-SonicAniData
		dc.w SonicAni_Unused14-SonicAniData
		dc.w SonicAni_Bubble-SonicAniData
		dc.w SonicAni_Death1-SonicAniData
		dc.w SonicAni_Drown-SonicAniData
		dc.w SonicAni_Death2-SonicAniData
		dc.w SonicAni_Unused19-SonicAniData
		dc.w SonicAni_Hurt-SonicAniData
		dc.w SonicAni_S1LZSlide-SonicAniData
		dc.w SonicAni_1C-SonicAniData
		dc.w SonicAni_Float3-SonicAniData
		dc.w SonicAni_1E-SonicAniData
SonicAni_Walk:		dc.b $FF,$10,$11,$12,$13,$14,$15,$16,$17, $C, $D, $E, $F,$FF
SonicAni_Run:		dc.b $FF,$3C,$3D,$3E,$3F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
SonicAni_Roll:		dc.b $FE,$6C,$70,$6D,$70,$6E,$70,$6F,$70,$FF
SonicAni_Roll2:		dc.b $FE,$6C,$70,$6D,$70,$6E,$70,$6F,$70,$FF
SonicAni_Push:		dc.b $FD,$77,$78,$79,$7A,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
SonicAni_Wait:		dc.b   7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
			dc.b   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2
			dc.b   3,  3,  3,  4,  4,  5,  5,$FE,  4
SonicAni_Balance:	dc.b	7,$89,$8A,$FF
SonicAni_LookUp:	dc.b   5,  6,  7,$FE,  1
SonicAni_Duck:		dc.b   5,$7F,$80,$FE,  1
SonicAni_Spindash:	dc.b	 0,$71,$72,$71,$73,$71,$74,$71,$75,$71,$76,$71,$FF
SonicAni_WallRecoil1:	dc.b $3F,$82,$FF
SonicAni_WallRecoil2:	dc.b   7, 8, 8, 9,$FD,	5
SonicAni_0C:		dc.b   7,  9,$FD,  5
SonicAni_Stop:		dc.b   3,$81,$82,$83,$84,$85,$86,$87,$88,$FE,  2
SonicAni_Float1:	dc.b   7,$94,$96,$FF
SonicAni_Float2:	dc.b   7,$91,$92,$93,$94,$95,$FF
SonicAni_10:		dc.b $2F,$7E,$FD,  0
SonicAni_S1LZHang:	dc.b	 5,$8F,$90,$FF
SonicAni_Unused12:	dc.b	$F,$43,$43,$43,$FE,  1
SonicAni_Unused13:	dc.b	$F,$43,$44,$FE,	 1
SonicAni_Unused14:	dc.b $3F,$49,$FF
SonicAni_Bubble:	dc.b  $B,$97,$97,$12,$13,$FD,  0
SonicAni_Death1:	dc.b $20,$9A,$FF
SonicAni_Drown:		dc.b $20,$99,$FF
SonicAni_Death2:	dc.b $20,$98,$FF
SonicAni_Unused19:	dc.b	 3,$4E,$4F,$50,$51,$52,	 0,$FE,	 1
SonicAni_Hurt:		dc.b $40,$8D,$FF
SonicAni_S1LZSlide:	dc.b	  9,$8D,$8E,$FF
SonicAni_1C:		dc.b $77,  0,$FD,  0
SonicAni_Float3:	dc.b   3,$91,$92,$93,$94,$95,$FF
SonicAni_1E:		dc.b   3,$3C,$FD,  0
	even

; ---------------------------------------------------------------------------
; Sonic pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LoadSonicDynPLC:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	(Sonic_LastLoadedDPLC).w,d0
		beq.s	locret_10C34
		move.b	d0,(Sonic_LastLoadedDPLC).w
		lea	(SonicDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_10C34
		move.w	#$F000,d4
; loc_10C08:
SPLC_ReadEntry:
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		addi.l	#Art_Sonic,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,SPLC_ReadEntry

locret_10C34:
		rts
; End of function LoadSonicDynPLC

; ===========================================================================
		nop

JmpTo_KillSonic:					; JmpTo
		jmp	(KillSonic).l

		align 4

; ===========================================================================
;----------------------------------------------------------------------------
; Object 02 - Tails
;----------------------------------------------------------------------------

Obj02:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj02_Index(pc,d0.w),d1
		jmp	Obj02_Index(pc,d1.w)
; ===========================================================================
Obj02_Index:	dc.w Obj02_Init-Obj02_Index		; 0
		dc.w Obj02_Control-Obj02_Index		; 2
		dc.w Obj02_Hurt-Obj02_Index		; 4
		dc.w Obj02_Dead-Obj02_Index		; 6
		dc.w Obj02_ResetLevel-Obj02_Index	; 8
; ===========================================================================
; Obj02_Main:
Obj02_Init:
		addq.b	#2,obRoutine(a0)
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.l	#Map_Tails,obMap(a0)
		move.w	#$7A0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#2,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#$84,obRender(a0)
		move.w	#$600,(Sonic_top_speed).w
		move.w	#$C,(Sonic_acceleration).w
		move.w	#$80,(Sonic_deceleration).w
		move.b	#$C,$3E(a0)
		move.b	#$D,$3F(a0)
		move.b	#0,$2C(a0)
		move.b	#4,$2D(a0)
		move.b	#5,(v_objspace+$1C0).w		; load Tails' tails at $B1C0

; ---------------------------------------------------------------------------
; Normal state for Tails
; ---------------------------------------------------------------------------
Obj02_Control:
		bsr.w	Tails_Control
		btst	#0,(f_playerctrl).w		; is Tails interacting with another object that holds him in place or controls his movement somehow?
		bne.s	Obj02_ControlsLock		; if yes, branch to skip Tails' control
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Obj02_Modes(pc,d0.w),d1
		jsr	Obj02_Modes(pc,d1.w)		; run Tails' movement code

Obj02_ControlsLock:
		bsr.s	Tails_Display
		bsr.w	RecordTailsMoves
		move.b	(Primary_Angle).w,$36(a0)
		move.b	(Secondary_Angle).w,$37(a0)
		bsr.w	Tails_Animate
		tst.b	(f_playerctrl).w
		bmi.s	loc_10CFC
		jsr	(TouchResponse).l

loc_10CFC:
		bsr.w	LoadTailsDynPLC
		rts
; ===========================================================================
Obj02_Modes:	dc.w Obj02_MdNormal-Obj02_Modes
		dc.w Obj02_MdJump-Obj02_Modes
		dc.w Obj02_MdRoll-Obj02_Modes
		dc.w Obj02_MdJump2-Obj02_Modes
; ===========================================================================
; same as Sonic's...
MusicList_Tails:dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		even

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Display:
		move.w	$30(a0),d0
		beq.s	Obj02_Display
		subq.w	#1,$30(a0)
		lsr.w	#3,d0
		bcc.s	Obj02_ChkInvinc
; loc_10D1E:
Obj02_Display:
		jsr	(DisplaySprite).l
; loc_10D24:
Obj02_ChkInvinc:
		; checks if invincibility has expired and disables it if it has,
		; and unlike Sonic's version, functions normally...
		tst.b	(v_invinc).w
		beq.s	Obj02_ChkShoes
		tst.w	$32(a0)
		beq.s	Obj02_ChkShoes
		subq.w	#1,$32(a0)
		bne.s	Obj02_ChkShoes
		tst.b	(f_lockscreen).w
		bne.s	Obj02_RmvInvin
		cmpi.w	#$C,(v_air).w
		bcs.s	Obj02_RmvInvin
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		cmpi.w	#$103,(Current_ZoneAndAct).w
		bne.s	loc_10D54
		moveq	#5,d0

loc_10D54:
		lea	MusicList_Tails(pc),a1
		move.b	(a1,d0.w),d0
		jsr	(PlaySound).l
; loc_10D62:
Obj02_RmvInvin:
		move.b	#0,(v_invinc).w
; loc_10D68:
Obj02_ChkShoes:
		; checks if Speed Shoes have expired and disables them if they have
		tst.b	(v_shoes).w
		beq.s	Obj02_ExitChk
		tst.w	$34(a0)
		beq.s	Obj02_ExitChk
		subq.w	#1,$34(a0)
		bne.s	Obj02_ExitChk
		move.w	#$600,(Sonic_top_speed).w
		move.w	#$C,(Sonic_acceleration).w
		move.w	#$80,(Sonic_deceleration).w
; Obj02_RmvSpeed:
		move.b	#0,(v_shoes).w
		move.w	#bgm_Slowdown,d0		; slow down tempo
		jmp	(PlaySound).l
; ===========================================================================
; locret_10D9C:
Obj02_ExitChk:
		rts
; End of function Tails_Display


; =============== S U B	R O U T	I N E =======================================


Tails_Control:
		move.b	(v_2Pjpadhold1).w,d0
		andi.b	#$7F,d0
		beq.s	TailsC_NoKeysPressed
		move.w	#0,(word_FFFFF700).w
		move.w	#$12C,(Tails_control_counter).w
		rts
; ---------------------------------------------------------------------------

TailsC_NoKeysPressed:
		tst.w	(Tails_control_counter).w
		beq.s	TailsC_DoControl
		subq.w	#1,(Tails_control_counter).w
		rts
; ---------------------------------------------------------------------------

TailsC_DoControl:
		move.w	(Tails_CPU_routine).w,d0
		move.w	TailsC_Index(pc,d0.w),d0
		jmp	TailsC_Index(pc,d0.w)
; End of function Tails_Control

; ---------------------------------------------------------------------------
TailsC_Index:	dc.w TailsC_00-TailsC_Index
		dc.w TailsC_02-TailsC_Index
		dc.w TailsC_04-TailsC_Index
		dc.w TailsC_CopySonicMoves-TailsC_Index
; ---------------------------------------------------------------------------

TailsC_00:
		move.w	#6,(Tails_CPU_routine).w
		rts
; ---------------------------------------------------------------------------

TailsC_02:
		move.w	#6,(Tails_CPU_routine).w
		rts
; ---------------------------------------------------------------------------
		move.w	#$40,(word_FFFFF706).w
		move.w	#4,(Tails_CPU_routine).w

TailsC_04:
		move.w	#6,(Tails_CPU_routine).w
		rts
; ---------------------------------------------------------------------------
		move.w	(word_FFFFF706).w,d1
		subq.w	#1,d1
		cmpi.w	#$10,d1
		bne.s	loc_10E0C
		move.w	#6,(Tails_CPU_routine).w

loc_10E0C:
		move.w	d1,(word_FFFFF706).w
		lea	(Tails_Pos_Record_Buf).w,a1
		lsl.b	#2,d1
		addq.b	#4,d1
		move.w	($FFFFEEE0).w,d0
		sub.b	d1,d0
		move.w	(a1,d0.w),obX(a0)
		move.w	2(a1,d0.w),obY(a0)
		rts
; ---------------------------------------------------------------------------

TailsC_CopySonicMoves:
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	loc_10E38
		neg.w	d0

loc_10E38:
		cmpi.w	#$C0,d0
		bcs.s	loc_10E40
		nop

loc_10E40:
		lea	(Sonic_Pos_Record_Buf).w,a1
		move.w	#$10,d1
		lsl.b	#2,d1
		addq.b	#4,d1
		move.w	(Sonic_Pos_Record_Index).w,d0
		sub.b	d1,d0
		lea	(Sonic_Stat_Record_Buf).w,a1
		move.w	(a1,d0.w),(v_2Pjpadhold1).w
		rts

; =============== S U B	R O U T	I N E =======================================


RecordTailsMoves:
		move.w	(Tails_Pos_Record_Index).w,d0
		lea	(Tails_Pos_Record_Buf_Dup).w,a1
		lea	(a1,d0.w),a1
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		addq.b	#4,($FFFFEED7).w
		rts
; End of function RecordTailsMoves

; ---------------------------------------------------------------------------

Obj02_MdNormal:
		bsr.w	Tails_Spindash
		bsr.w	Tails_Jump
		bsr.w	Tails_SlopeResist
		bsr.w	Tails_Move
		bsr.w	Tails_Roll
		bsr.w	Tails_LevelBoundaries
		jsr	(ObjectMove).l
		bsr.w	AnglePos
		bsr.w	Tails_SlopeRepel
		rts
; ---------------------------------------------------------------------------

Obj02_MdJump:
		bsr.w	Tails_JumpHeight
		bsr.w	Tails_ChgJumpDir
		bsr.w	Tails_LevelBoundaries
		jsr	(ObjectMoveAndFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_10EC0
		subi.w	#$28,obVelY(a0)

loc_10EC0:
		bsr.w	Tails_JumpAngle
		bsr.w	Tails_Floor
		rts
; ---------------------------------------------------------------------------

Obj02_MdRoll:
		bsr.w	Tails_Jump
		bsr.w	Tails_RollRepel
		bsr.w	Tails_RollSpeed
		bsr.w	Tails_LevelBoundaries
		jsr	(ObjectMove).l
		bsr.w	AnglePos
		bsr.w	Tails_SlopeRepel
		rts
; ---------------------------------------------------------------------------

Obj02_MdJump2:
		bsr.w	Tails_JumpHeight
		bsr.w	Tails_ChgJumpDir
		bsr.w	Tails_LevelBoundaries
		jsr	(ObjectMoveAndFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_10F0A
		subi.w	#$28,obVelY(a0)

loc_10F0A:
		bsr.w	Tails_JumpAngle
		bsr.w	Tails_Floor
		rts

; =============== S U B	R O U T	I N E =======================================


Tails_Move:
		move.w	(Sonic_top_speed).w,d6
		move.w	(Sonic_acceleration).w,d5
		move.w	(Sonic_deceleration).w,d4
		tst.b	(f_slidemode).w
		bne.w	loc_11026
		tst.w	$2E(a0)
		bne.w	loc_10FFA
		btst	#2,(v_2Pjpadhold1).w
		beq.s	loc_10F3C
		bsr.w	Tails_MoveLeft

loc_10F3C:
		btst	#3,(v_2Pjpadhold1).w
		beq.s	loc_10F48
		bsr.w	Tails_MoveRight

loc_10F48:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.w	loc_10FFA
		tst.w	obInertia(a0)
		bne.w	loc_10FFA
		bclr	#5,obStatus(a0)
		move.b	#5,obAnim(a0)
		btst	#3,obStatus(a0)
		beq.s	Tails_Balance
		moveq	#0,d0
		move.b	$3D(a0),d0
		lsl.w	#6,d0
		lea	(v_objspace).w,a1
		lea	(a1,d0.w),a1
		tst.b	obStatus(a1)
		bmi.s	Tails_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_10FCE
		cmp.w	d2,d1
		bge.s	loc_10FBE
		bra.s	Tails_LookUp
; ---------------------------------------------------------------------------

Tails_Balance:
		jsr	(ObjHitFloor).l
		cmpi.w	#$C,d1
		blt.s	Tails_LookUp
		cmpi.b	#3,$36(a0)
		bne.s	loc_10FC6

loc_10FBE:
		bclr	#0,obStatus(a0)
		bra.s	loc_10FD4
; ---------------------------------------------------------------------------

loc_10FC6:
		cmpi.b	#3,$37(a0)
		bne.s	Tails_LookUp

loc_10FCE:
		bset	#0,obStatus(a0)

loc_10FD4:
		move.b	#6,obAnim(a0)
		bra.s	loc_10FFA
; ---------------------------------------------------------------------------

Tails_LookUp:
		btst	#0,(v_2Pjpadhold1).w
		beq.s	Tails_Duck
		move.b	#7,obAnim(a0)
		bra.s	loc_10FFA
; ---------------------------------------------------------------------------

Tails_Duck:
		btst	#1,(v_2Pjpadhold1).w
		beq.s	loc_10FFA
		move.b	#8,obAnim(a0)

loc_10FFA:
		move.b	(v_2Pjpadhold1).w,d0

loc_10FFE:
		andi.b	#$C,d0
		bne.s	loc_11026
		move.w	obInertia(a0),d0
		beq.s	loc_11026
		bmi.s	loc_1101A
		sub.w	d5,d0
		bcc.s	loc_11014
		move.w	#0,d0

loc_11014:
		move.w	d0,obInertia(a0)
		bra.s	loc_11026
; ---------------------------------------------------------------------------

loc_1101A:
		add.w	d5,d0
		bcc.s	loc_11022
		move.w	#0,d0

loc_11022:
		move.w	d0,obInertia(a0)

loc_11026:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

loc_11044:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_110B4
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	locret_110B4
		bmi.s	loc_1105C
		neg.w	d1

loc_1105C:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	CalcRoomInFront
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_110B4
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_110B0
		cmpi.b	#$40,d0
		beq.s	loc_1109E
		cmpi.b	#$80,d0
		beq.s	loc_11098
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_11098:
		sub.w	d1,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_1109E:
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_110B0:
		add.w	d1,obVelY(a0)

locret_110B4:
		rts
; End of function Tails_Move


; =============== S U B	R O U T	I N E =======================================


Tails_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_110BE
		bpl.s	loc_110EA

loc_110BE:
		bset	#0,obStatus(a0)
		bne.s	loc_110D2
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)

loc_110D2:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_110DE
		move.w	d1,d0

loc_110DE:
		move.w	d0,obInertia(a0)
		move.b	#0,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_110EA:
		sub.w	d4,d0
		bcc.s	loc_110F2
		move.w	#$FF80,d0

loc_110F2:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_11120
		cmpi.w	#$400,d0
		blt.s	locret_11120
		move.b	#$D,obAnim(a0)
		bclr	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(PlaySound_Special).l

locret_11120:
		rts
; End of function Tails_MoveLeft


; =============== S U B	R O U T	I N E =======================================


Tails_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_11150
		bclr	#0,obStatus(a0)
		beq.s	loc_1113C
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)

loc_1113C:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_11144
		move.w	d6,d0

loc_11144:
		move.w	d0,obInertia(a0)
		move.b	#0,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_11150:
		add.w	d4,d0
		bcc.s	loc_11158
		move.w	#$80,d0

loc_11158:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_11186
		cmpi.w	#$FC00,d0
		bgt.s	locret_11186
		move.b	#$D,obAnim(a0)
		bset	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(PlaySound_Special).l

locret_11186:
		rts
; End of function Tails_MoveRight


; =============== S U B	R O U T	I N E =======================================


Tails_RollSpeed:
		move.w	(Sonic_top_speed).w,d6
		asl.w	#1,d6
		move.w	(Sonic_acceleration).w,d5
		asr.w	#1,d5
		move.w	(Sonic_deceleration).w,d4
		asr.w	#2,d4
		tst.b	(f_slidemode).w
		bne.w	loc_11204
		tst.w	$2E(a0)
		bne.s	loc_111C0
		btst	#2,(v_2Pjpadhold1).w
		beq.s	loc_111B4
		bsr.w	Tails_RollLeft

loc_111B4:
		btst	#3,(v_2Pjpadhold1).w
		beq.s	loc_111C0
		bsr.w	Tails_RollRight

loc_111C0:
		move.w	obInertia(a0),d0
		beq.s	loc_111E2
		bmi.s	loc_111D6
		sub.w	d5,d0
		bcc.s	loc_111D0
		move.w	#0,d0

loc_111D0:
		move.w	d0,obInertia(a0)
		bra.s	loc_111E2
; ---------------------------------------------------------------------------

loc_111D6:
		add.w	d5,d0
		bcc.s	loc_111DE
		move.w	#0,d0

loc_111DE:
		move.w	d0,obInertia(a0)

loc_111E2:
		tst.w	obInertia(a0)
		bne.s	loc_11204
		bclr	#2,obStatus(a0)
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#5,obAnim(a0)
		subq.w	#5,obY(a0)

loc_11204:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_11228
		move.w	#$1000,d1

loc_11228:
		cmpi.w	#$F000,d1
		bge.s	loc_11232
		move.w	#$F000,d1

loc_11232:
		move.w	d1,obVelX(a0)
		bra.w	loc_11044
; End of function Tails_RollSpeed


; =============== S U B	R O U T	I N E =======================================


Tails_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_11242
		bpl.s	loc_11250

loc_11242:
		bset	#0,obStatus(a0)
		move.b	#2,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_11250:
		sub.w	d4,d0
		bcc.s	loc_11258
		move.w	#$FF80,d0

loc_11258:
		move.w	d0,obInertia(a0)
		rts
; End of function Tails_RollLeft


; =============== S U B	R O U T	I N E =======================================


Tails_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_11272
		bclr	#0,obStatus(a0)
		move.b	#2,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_11272:
		add.w	d4,d0
		bcc.s	loc_1127A
		move.w	#$80,d0

loc_1127A:
		move.w	d0,obInertia(a0)
		rts
; End of function Tails_RollRight


; =============== S U B	R O U T	I N E =======================================


Tails_ChgJumpDir:
		move.w	(Sonic_top_speed).w,d6
		move.w	(Sonic_acceleration).w,d5
		asl.w	#1,d5
		btst	#4,obStatus(a0)
		bne.s	loc_112CA
		move.w	obVelX(a0),d0
		btst	#2,(v_2Pjpadhold1).w
		beq.s	loc_112B0
		bset	#0,obStatus(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_112B0
		move.w	d1,d0

loc_112B0:
		btst	#3,(v_2Pjpadhold1).w
		beq.s	loc_112C6
		bclr	#0,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_112C6
		move.w	d6,d0

loc_112C6:
		move.w	d0,obVelX(a0)

loc_112CA:
		cmpi.w	#$60,(Camera_Y_pos_bias).w
		beq.s	loc_112DC
		bcc.s	loc_112D8
		addq.w	#4,(Camera_Y_pos_bias).w

loc_112D8:
		subq.w	#2,(Camera_Y_pos_bias).w

loc_112DC:
		cmpi.w	#$FC00,obVelY(a0)
		bcs.s	locret_1130A
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_1130A
		bmi.s	loc_112FE
		sub.w	d1,d0
		bcc.s	loc_112F8
		move.w	#0,d0

loc_112F8:
		move.w	d0,obVelX(a0)
		rts
; ---------------------------------------------------------------------------

loc_112FE:
		sub.w	d1,d0
		bcs.s	loc_11306
		move.w	#0,d0

loc_11306:
		move.w	d0,obVelX(a0)

locret_1130A:
		rts
; End of function Tails_ChgJumpDir


; =============== S U B	R O U T	I N E =======================================


Tails_LevelBoundaries:

; FUNCTION CHUNK AT 00011E5C SIZE 00000006 BYTES

		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(Camera_Min_X_pos).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0
		bhi.s	loc_11374
		move.w	(Camera_Max_X_pos).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	loc_1133A
		addi.w	#$40,d0

loc_1133A:
		cmp.w	d1,d0
		bls.s	loc_11374

loc_1133E:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		blt.s	loc_1134E
		rts
; ---------------------------------------------------------------------------

loc_1134E:
		cmpi.w	#$501,(Current_ZoneAndAct).w
		bne.w	KillTails
		cmpi.w	#$2000,obX(a0)
		bcs.w	KillTails
		clr.b	(v_lastlamp).w
		move.w	#1,(Level_Inactive_flag).w
		move.w	#$103,(Current_ZoneAndAct).w
		rts
; ---------------------------------------------------------------------------

loc_11374:
		move.w	d0,obX(a0)
		move.w	#0,$A(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obInertia(a0)
		bra.s	loc_1133E
; End of function Tails_LevelBoundaries


; =============== S U B	R O U T	I N E =======================================


Tails_Roll:
		tst.b	(f_slidemode).w
		bne.s	locret_113B2
		move.w	obInertia(a0),d0
		bpl.s	loc_1139A
		neg.w	d0

loc_1139A:
		cmpi.w	#$80,d0
		bcs.s	locret_113B2
		move.b	(v_2Pjpadhold1).w,d0
		andi.b	#$C,d0
		bne.s	locret_113B2
		btst	#1,(v_2Pjpadhold1).w
		bne.s	loc_113B4

locret_113B2:
		rts
; ---------------------------------------------------------------------------

loc_113B4:
		btst	#2,obStatus(a0)
		beq.s	loc_113BE
		rts
; ---------------------------------------------------------------------------

loc_113BE:
		bset	#2,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#2,obAnim(a0)
		addq.w	#5,obY(a0)
		move.w	#sfx_Roll,d0
		jsr	(PlaySound_Special).l
		tst.w	obInertia(a0)
		bne.s	locret_113F0
		move.w	#$200,obInertia(a0)

locret_113F0:
		rts
; End of function Tails_Roll


; =============== S U B	R O U T	I N E =======================================


Tails_Jump:
		move.b	(v_2Pjpadpress1).w,d0
		andi.b	#$70,d0
		beq.w	locret_11496
		moveq	#0,d0
		move.b	obAngle(a0),d0

loc_11404:
		addi.b	#$80,d0

loc_11408:
		bsr.w	sub_13102
		cmpi.w	#6,d1
		blt.w	locret_11496
		move.w	#$680,d2
		btst	#6,obStatus(a0)
		beq.s	loc_11424
		move.w	#$380,d2

loc_11424:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		move.w	#sfx_Jump,d0
		jsr	(PlaySound_Special).l
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		btst	#2,obStatus(a0)
		bne.s	loc_11498
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#2,obAnim(a0)
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)

locret_11496:
		rts
; ---------------------------------------------------------------------------

loc_11498:
		bset	#4,obStatus(a0)
		rts
; End of function Tails_Jump


; =============== S U B	R O U T	I N E =======================================


Tails_JumpHeight:
		tst.b	$3C(a0)
		beq.s	loc_114CC
		move.w	#$FC00,d1
		btst	#6,obStatus(a0)
		beq.s	loc_114B6
		move.w	#$FE00,d1

loc_114B6:
		cmp.w	obVelY(a0),d1
		ble.s	locret_114CA
		move.b	(v_2Pjpadhold1).w,d0
		andi.b	#$70,d0
		bne.s	locret_114CA
		move.w	d1,obVelY(a0)

locret_114CA:
		rts
; ---------------------------------------------------------------------------

loc_114CC:
		cmpi.w	#$F040,obVelY(a0)
		bge.s	locret_114DA
		move.w	#$F040,obVelY(a0)

locret_114DA:
		rts
; End of function Tails_JumpHeight


; =============== S U B	R O U T	I N E =======================================


Tails_Spindash:
		tst.b	$39(a0)
		bne.s	loc_11510
		cmpi.b	#8,obAnim(a0)
		bne.s	locret_1150E
		move.b	(v_2Pjpadpress1).w,d0
		andi.b	#$70,d0
		beq.w	locret_1150E
		move.b	#9,obAnim(a0)
		move.w	#sfx_Roll,d0
		jsr	(PlaySound_Special).l
		addq.l	#4,sp
		move.b	#1,$39(a0)

locret_1150E:
		rts
; ---------------------------------------------------------------------------

loc_11510:
		move.b	(v_2Pjpadhold1).w,d0
		btst	#1,d0
		bne.s	loc_11556
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#2,obAnim(a0)
		addq.w	#5,obY(a0)
		move.b	#0,$39(a0)
		move.w	#$2000,(Horiz_scroll_delay_val).w
		move.w	#$800,obInertia(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_1154E
		neg.w	obInertia(a0)

loc_1154E:
		bset	#2,obStatus(a0)
		rts
; ---------------------------------------------------------------------------

loc_11556:
		move.b	(v_2Pjpadpress1).w,d0
		andi.b	#$70,d0
		beq.w	loc_11564
		nop

loc_11564:
		addq.l	#4,sp
		rts
; End of function Tails_Spindash


; =============== S U B	R O U T	I N E =======================================


Tails_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_1159C
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	locret_1159C
		bmi.s	loc_11598
		tst.w	d0
		beq.s	locret_11596
		add.w	d0,obInertia(a0)

locret_11596:
		rts
; ---------------------------------------------------------------------------

loc_11598:
		add.w	d0,obInertia(a0)

locret_1159C:
		rts
; End of function Tails_SlopeResist


; =============== S U B	R O U T	I N E =======================================


Tails_RollRepel:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_115D8
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	loc_115CE
		tst.w	d0
		bpl.s	loc_115C8
		asr.l	#2,d0

loc_115C8:
		add.w	d0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_115CE:
		tst.w	d0
		bmi.s	loc_115D4
		asr.l	#2,d0

loc_115D4:
		add.w	d0,obInertia(a0)

locret_115D8:
		rts
; End of function Tails_RollRepel


; =============== S U B	R O U T	I N E =======================================


Tails_SlopeRepel:
		nop
		tst.b	$38(a0)
		bne.s	locret_11614
		tst.w	$2E(a0)
		bne.s	loc_11616
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	locret_11614
		move.w	obInertia(a0),d0
		bpl.s	loc_115FE
		neg.w	d0

loc_115FE:
		cmpi.w	#$280,d0
		bcc.s	locret_11614
		clr.w	obInertia(a0)
		bset	#1,obStatus(a0)
		move.w	#$1E,$2E(a0)

locret_11614:
		rts
; ---------------------------------------------------------------------------

loc_11616:
		subq.w	#1,$2E(a0)
		rts
; End of function Tails_SlopeRepel


; =============== S U B	R O U T	I N E =======================================


Tails_JumpAngle:
		move.b	obAngle(a0),d0
		beq.s	loc_11636
		bpl.s	loc_1162C
		addq.b	#2,d0
		bcc.s	loc_1162A
		moveq	#0,d0

loc_1162A:
		bra.s	loc_11632
; ---------------------------------------------------------------------------

loc_1162C:
		subq.b	#2,d0
		bcc.s	loc_11632
		moveq	#0,d0

loc_11632:
		move.b	d0,obAngle(a0)

loc_11636:
		move.b	$27(a0),d0
		beq.s	locret_11674
		tst.w	obInertia(a0)
		bmi.s	loc_1165A
		move.b	$2D(a0),d1
		add.b	d1,d0
		bcc.s	loc_11658
		subq.b	#1,$2C(a0)
		bcc.s	loc_11658
		move.b	#0,$2C(a0)
		moveq	#0,d0

loc_11658:
		bra.s	loc_11670
; ---------------------------------------------------------------------------

loc_1165A:
		move.b	$2D(a0),d1
		sub.b	d1,d0
		bcc.s	loc_11670
		subq.b	#1,$2C(a0)
		bcc.s	loc_11670
		move.b	#0,$2C(a0)
		moveq	#0,d0

loc_11670:
		move.b	d0,$27(a0)

locret_11674:
		rts
; End of function Tails_JumpAngle


; =============== S U B	R O U T	I N E =======================================


Tails_Floor:
		move.b	$3F(a0),d5
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_11746
		cmpi.b	#$80,d0
		beq.w	loc_117A8
		cmpi.b	#$C0,d0
		beq.w	loc_11804
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_116BA
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_116BA:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_116CC
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_116CC:
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_11744
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_116E4
		cmp.b	d2,d0
		blt.s	locret_11744

loc_116E4:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetTailsOnFloor
		move.b	#0,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_11722
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_11714
		asr	obVelY(a0)
		bra.s	loc_11736
; ---------------------------------------------------------------------------

loc_11714:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_11722:
		move.w	#0,obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_11736
		move.w	#$FC0,obVelY(a0)

loc_11736:
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_11744
		neg.w	obInertia(a0)

locret_11744:
		rts
; ---------------------------------------------------------------------------

loc_11746:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_11760
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_11760:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_1177A
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_11778
		move.w	#0,obVelY(a0)

locret_11778:
		rts
; ---------------------------------------------------------------------------

loc_1177A:
		tst.w	obVelY(a0)
		bmi.s	locret_117A6
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_117A6
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetTailsOnFloor
		move.b	#0,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_117A6:
		rts
; ---------------------------------------------------------------------------

loc_117A8:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_117BA
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_117BA:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_117CC
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_117CC:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_11802
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_117EC
		move.w	#0,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_117EC:
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetTailsOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_11802
		neg.w	obInertia(a0)

locret_11802:
		rts
; ---------------------------------------------------------------------------

loc_11804:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_1181E
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_1181E:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_11838
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_11836
		move.w	#0,obVelY(a0)

locret_11836:
		rts
; ---------------------------------------------------------------------------

loc_11838:
		tst.w	obVelY(a0)
		bmi.s	locret_11864
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_11864
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetTailsOnFloor
		move.b	#0,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_11864:
		rts
; End of function Tails_Floor


; =============== S U B	R O U T	I N E =======================================


Tails_ResetTailsOnFloor:
		btst	#4,obStatus(a0)
		beq.s	loc_11874
		nop
		nop
		nop

loc_11874:
		bclr	#5,obStatus(a0)
		bclr	#1,obStatus(a0)
		bclr	#4,obStatus(a0)
		btst	#2,obStatus(a0)
		beq.s	loc_118AA
		bclr	#2,obStatus(a0)
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#0,obAnim(a0)
		subq.w	#1,obY(a0)

loc_118AA:
		move.b	#0,$3C(a0)
		move.w	#0,(v_itembonus).w
		move.b	#0,$27(a0)
		rts
; End of function Tails_ResetTailsOnFloor

; ---------------------------------------------------------------------------

Obj02_Hurt:
		jsr	(ObjectMove).l
		addi.w	#$30,obVelY(a0)
		btst	#6,obStatus(a0)
		beq.s	loc_118D8
		subi.w	#$20,obVelY(a0)

loc_118D8:
		bsr.w	Tails_HurtStop
		bsr.w	Tails_LevelBoundaries
		bsr.w	Tails_Animate
		bsr.w	LoadTailsDynPLC
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


Tails_HurtStop:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		bcs.w	KillTails
		bsr.w	Tails_Floor
		btst	#1,obStatus(a0)
		bne.s	locret_1192A
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obVelX(a0)
		move.w	d0,obInertia(a0)
		move.b	#0,obAnim(a0)
		move.b	#2,obRoutine(a0)
		move.w	#$78,$30(a0)

locret_1192A:
		rts
; End of function Tails_HurtStop

; ---------------------------------------------------------------------------

Obj02_Dead:
		bsr.w	Tails_GameOver
		jsr	(ObjectMoveAndFall).l
		bsr.w	Tails_Animate
		bsr.w	LoadTailsDynPLC
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


Tails_GameOver:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bcc.w	locret_11986
		move.w	(v_objspace+obX).w,d0
		subi.w	#$40,d0
		move.w	d0,obX(a0)
		move.w	(v_objspace+obY).w,d0
		subi.w	#$80,d0
		move.w	d0,obY(a0)
		move.b	#2,obRoutine(a0)
		andi.w	#$7FFF,2(a0)
		move.b	#$C,$3E(a0)
		move.b	#$D,$3F(a0)
		nop

locret_11986:
		rts
; End of function Tails_GameOver

; ---------------------------------------------------------------------------

Obj02_ResetLevel:
		tst.w	$3A(a0)
		beq.s	locret_1199A
		subq.w	#1,$3A(a0)
		bne.s	locret_1199A
		move.w	#1,(Level_Inactive_flag).w

locret_1199A:
		rts

; =============== S U B	R O U T	I N E =======================================


Tails_Animate:

; FUNCTION CHUNK AT 00011A2E SIZE 000001AE BYTES

		lea	(TailsAniData).l,a1

Tails_Animate2:
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obPrevAni(a0),d0
		beq.s	loc_119BE
		move.b	d0,obPrevAni(a0)
		move.b	#0,obAniFrame(a0)
		move.b	#0,obTimeFrame(a0)

loc_119BE:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	loc_11A2E
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_119FC
		move.b	d0,obTimeFrame(a0)
; End of function Tails_Animate


; =============== S U B	R O U T	I N E =======================================


sub_119E4:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#$F0,d0
		bcc.s	loc_119FE

loc_119F4:
		move.b	d0,obFrame(a0)
		addq.b	#1,obAniFrame(a0)

locret_119FC:
		rts
; ---------------------------------------------------------------------------

loc_119FE:
		addq.b	#1,d0
		bne.s	loc_11A0E
		move.b	#0,obAniFrame(a0)
		move.b	1(a1),d0
		bra.s	loc_119F4
; ---------------------------------------------------------------------------

loc_11A0E:
		addq.b	#1,d0
		bne.s	loc_11A22
		move.b	2(a1,d1.w),d0
		sub.b	d0,obAniFrame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	loc_119F4
; ---------------------------------------------------------------------------

loc_11A22:
		addq.b	#1,d0
		bne.s	locret_11A2C
		move.b	2(a1,d1.w),obAnim(a0)

locret_11A2C:
		rts
; End of function sub_119E4

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Tails_Animate

loc_11A2E:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_119FC
		addq.b	#1,d0
		bne.w	loc_11B0E
		moveq	#0,d0
		move.b	$27(a0),d0
		bne.w	loc_11AB4
		moveq	#0,d1
		move.b	obAngle(a0),d0
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_11A56
		not.b	d0

loc_11A56:
		addi.b	#$10,d0
		bpl.s	loc_11A5E
		moveq	#3,d1

loc_11A5E:
		andi.b	#$FC,1(a0)
		eor.b	d1,d2
		or.b	d2,1(a0)
		lsr.b	#4,d0
		andi.b	#6,d0
		move.w	obInertia(a0),d2
		bpl.s	loc_11A78
		neg.w	d2

loc_11A78:
		move.b	d0,d3
		add.b	d3,d3
		add.b	d3,d3
		lea	(TailsAni_Walk).l,a1
		cmpi.w	#$600,d2
		bcs.s	loc_11A9A
		lea	(TailsAni_Run).l,a1
		move.b	d0,d1
		lsr.b	#1,d1
		add.b	d1,d0
		add.b	d0,d0
		move.b	d0,d3

loc_11A9A:
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_11AA4
		moveq	#0,d2

loc_11AA4:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)
		bsr.w	sub_119E4
		add.b	d3,obFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_11AB4:
		move.b	$27(a0),d0
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_11AE8
		andi.b	#$FC,1(a0)
		moveq	#0,d2
		or.b	d2,1(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#$75,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_11AE8:
		moveq	#3,d2
		andi.b	#$FC,1(a0)
		or.b	d2,1(a0)
		neg.b	d0
		addi.b	#$8F,d0
		divu.w	#$16,d0
		addi.b	#$75,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_11B0E:
		addq.b	#1,d0
		bne.s	loc_11B52
		move.w	obInertia(a0),d2
		bpl.s	loc_11B1A
		neg.w	d2

loc_11B1A:
		lea	(TailsAni_Roll2).l,a1
		cmpi.w	#$600,d2
		bcc.s	loc_11B2C
		lea	(TailsAni_Roll).l,a1

loc_11B2C:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_11B36
		moveq	#0,d2

loc_11B36:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	sub_119E4
; ---------------------------------------------------------------------------

loc_11B52:
		addq.b	#1,d0
		bne.s	loc_11B88
		move.w	obInertia(a0),d2
		bmi.s	loc_11B5E
		neg.w	d2

loc_11B5E:
		addi.w	#$800,d2
		bpl.s	loc_11B66
		moveq	#0,d2

loc_11B66:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0)
		lea	(TailsAni_Push_NoArt).l,a1
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	sub_119E4
; ---------------------------------------------------------------------------

loc_11B88:
		move.w	(v_objspace+$50).w,d1
		move.w	(v_objspace+$52).w,d2
		jsr	(CalcAngle).l
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_11BA6
		not.b	d0
		bra.s	loc_11BAA
; ---------------------------------------------------------------------------

loc_11BA6:
		addi.b	#$80,d0

loc_11BAA:
		addi.b	#$10,d0
		bpl.s	loc_11BB2
		moveq	#3,d1

loc_11BB2:
		andi.b	#$FC,1(a0)
		eor.b	d1,d2
		or.b	d2,1(a0)
		lsr.b	#3,d0
		andi.b	#$C,d0
		move.b	d0,d3
		lea	(byte_11E3C).l,a1
		move.b	#3,obTimeFrame(a0)
		bsr.w	sub_119E4
		add.b	d3,obFrame(a0)
		rts
; END OF FUNCTION CHUNK	FOR Tails_Animate
; ---------------------------------------------------------------------------
TailsAniData:	dc.w TailsAni_Walk-TailsAniData,TailsAni_Run-TailsAniData ; 0
		dc.w TailsAni_Roll-TailsAniData,TailsAni_Roll2-TailsAniData ; 2
		dc.w TailsAni_Push_NoArt-TailsAniData,TailsAni_Wait-TailsAniData ; 4
		dc.w TailsAni_Balance_NoArt-TailsAniData,TailsAni_LookUp-TailsAniData ; 6
		dc.w TailsAni_Duck-TailsAniData,TailsAni_Spindash-TailsAniData ;	8
		dc.w TailsAni_0A-TailsAniData,TailsAni_0B-TailsAniData ;	10
		dc.w TailsAni_0C-TailsAniData,TailsAni_Stop-TailsAniData ; 12
		dc.w TailsAni_Fly-TailsAniData,TailsAni_0F-TailsAniData ; 14
		dc.w TailsAni_Jump-TailsAniData,TailsAni_11-TailsAniData ; 16
		dc.w TailsAni_12-TailsAniData,TailsAni_13-TailsAniData ;	18
		dc.w TailsAni_14-TailsAniData,TailsAni_15-TailsAniData ;	20
		dc.w TailsAni_Death1-TailsAniData,TailsAni_UnusedDrown-TailsAniData ; 22
		dc.w TailsAni_Death2-TailsAniData,TailsAni_19-TailsAniData ; 24
		dc.w TailsAni_1A-TailsAniData,TailsAni_1B-TailsAniData ;	26
		dc.w TailsAni_1C-TailsAniData,TailsAni_1D-TailsAniData ;	28
		dc.w TailsAni_1E-TailsAniData		; 30
TailsAni_Walk:	dc.b $FF,$10,$11,$12,$13,$14,$15, $E, $F,$FF ; 0
TailsAni_Run:	dc.b $FF,$2E,$2F,$30,$31,$FF,$FF,$FF,$FF,$FF ; 0
TailsAni_Roll:	dc.b   1,$48,$47,$46,$FF		; 0
TailsAni_Roll2:	dc.b   1,$48,$47,$46,$FF		; 0
TailsAni_Push_NoArt:dc.b $FD,  9, $A, $B, $C, $D, $E,$FF ; 0
TailsAni_Wait:	dc.b   7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  3,  2,  1,  1,  1 ; 0
		dc.b   1,  1,  1,  1,  1,  3,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1 ; 16
		dc.b   5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5 ; 32
		dc.b   6,  7,  8,  7,  8,  7,  8,  7,  8,  7,  8,  6,$FE,$1C ; 48
TailsAni_Balance_NoArt:dc.b $1F,  1,  2,  3,  4,  5,  6,  7,  8,$FF ; 0
TailsAni_LookUp:dc.b $3F,  4,$FF			; 0
TailsAni_Duck:	dc.b $3F,$5B,$FF			; 0
TailsAni_Spindash:dc.b	 0,$60,$61,$62,$FF		; 0
TailsAni_0A:	dc.b $3F,$82,$FF			; 0
TailsAni_0B:	dc.b   7,  8,  8,  9,$FD,  5		; 0
TailsAni_0C:	dc.b   7,  9,$FD,  5			; 0
TailsAni_Stop:	dc.b   7,  1,  2,$FF			; 0
TailsAni_Fly:	dc.b   7,$5E,$5F,$FF			; 0
TailsAni_0F:	dc.b   7,  1,  2,  3,  4,  5,$FF	; 0
TailsAni_Jump:	dc.b   3,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$FD,  0 ; 0
TailsAni_11:	dc.b   4,  1,  2,$FF			; 0
TailsAni_12:	dc.b  $F,  1,  2,  3,$FE,  1		; 0
TailsAni_13:	dc.b  $F,  1,  2,$FE,  1		; 0
TailsAni_14:	dc.b $3F,  1,$FF			; 0
TailsAni_15:	dc.b  $B,  1,  2,  3,  4,$FD,  0	; 0
TailsAni_Death1:dc.b $20,$5D,$FF			; 0
TailsAni_UnusedDrown:dc.b $2F,$5D,$FF			; 0
TailsAni_Death2:dc.b   3,$5D,$FF			; 0
TailsAni_19:	dc.b   3,$5D,$FF			; 0
TailsAni_1A:	dc.b   3,$5C,$FF			; 0
TailsAni_1B:	dc.b   7,  1,  1,$FF			; 0
TailsAni_1C:	dc.b $77,  0,$FD,  0			; 0
TailsAni_1D:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF ; 0
TailsAni_1E:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF

; ===========================================================================
; ---------------------------------------------------------------------------
; Tails' Tails pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; LoadTailsDynPLC_F600:
LoadTailsTailsDynPLC:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	(TailsTails_LastLoadedDPLC).w,d0
		beq.s	locret_11D7C
		move.b	d0,(TailsTails_LastLoadedDPLC).w
		lea	(TailsDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_11D7C
		move.w	#$F600,d4
		bra.s	TPLC_ReadEntry
; End of function LoadTailsTailsDynPLC

; ---------------------------------------------------------------------------
; Tails pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LoadTailsDynPLC:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	(Tails_LastLoadedDPLC).w,d0
		beq.s	locret_11D7C
		move.b	d0,(Tails_LastLoadedDPLC).w
		lea	(TailsDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_11D7C
		move.w	#$F400,d4
; loc_11D50:
TPLC_ReadEntry:
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		addi.l	#Art_Tails,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,TPLC_ReadEntry

locret_11D7C:
		rts
; End of function LoadTailsDynPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 05 - Tails' tails
; ---------------------------------------------------------------------------

Obj05:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj05_Index(pc,d0.w),d1
		jmp	Obj05_Index(pc,d1.w)
; ===========================================================================
Obj05_Index:	dc.w Obj05_Init-Obj05_Index
		dc.w Obj05_Main-Obj05_Index
; ===========================================================================

Obj05_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Tails,obMap(a0)
		move.w	#$7B0,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#2,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)

Obj05_Main:
		move.b	(v_objspace+$66).w,obAngle(a0)
		move.b	(v_objspace+$62).w,obStatus(a0)
		move.w	(v_objspace+$48).w,obX(a0)
		move.w	(v_objspace+$4C).w,obY(a0)
		moveq	#0,d0
		move.b	(v_objspace+$5C).w,d0
		cmp.b	$30(a0),d0
		beq.s	loc_11DE6
		move.b	d0,$30(a0)
		move.b	Obj05_Animations(pc,d0.w),obAnim(a0)

loc_11DE6:
		lea	(Obj05_AniData).l,a1
		bsr.w	Tails_Animate2
		bsr.w	LoadTailsTailsDynPLC
		jsr	(DisplaySprite).l
		rts
; ---------------------------------------------------------------------------
Obj05_Animations:dc.b	0,  0				; 0
		dc.b   3,  3				; 2
		dc.b   0,  1				; 4
		dc.b   0,  2				; 6
		dc.b   1,  7				; 8
		dc.b   0,  0				; 10
		dc.b   0,  0				; 12
		dc.b   0,  0				; 14
		dc.b   0,  0				; 16
		dc.b   0,  0				; 18
		dc.b   0,  0				; 20
		dc.b   0,  0				; 22
		dc.b   0,  0				; 24
		dc.b   0,  0				; 26
		dc.b   0,  0				; 28
Obj05_AniData:	dc.w byte_11E2A-Obj05_AniData
		dc.w byte_11E2D-Obj05_AniData
		dc.w byte_11E34-Obj05_AniData
		dc.w byte_11E3C-Obj05_AniData
		dc.w byte_11E42-Obj05_AniData
		dc.w byte_11E48-Obj05_AniData
		dc.w byte_11E4E-Obj05_AniData
		dc.w byte_11E54-Obj05_AniData
byte_11E2A:	dc.b $20,  0,$FF			; 0
byte_11E2D:	dc.b   7,  9, $A, $B, $C, $D,$FF	; 0
byte_11E34:	dc.b   3,  9, $A, $B, $C, $D,$FD,  1	; 0
byte_11E3C:	dc.b $FC,$49,$4A,$4B,$4C,$FF		; 0
byte_11E42:	dc.b   3,$4D,$4E,$4F,$50,$FF		; 0
byte_11E48:	dc.b   3,$51,$52,$53,$54,$FF		; 0
byte_11E4E:	dc.b   3,$55,$56,$57,$58,$FF		; 0
byte_11E54:	dc.b   2,$81,$82,$83,$84,$FF		; 0
; ---------------------------------------------------------------------------
		nop
; START	OF FUNCTION CHUNK FOR Tails_LevelBoundaries

KillTails:
		jmp	(KillSonic).l
; END OF FUNCTION CHUNK	FOR Tails_LevelBoundaries
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 0A - drowning bubbles and countdown numbers
;----------------------------------------------------

Obj0A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj0A_Index(pc,d0.w),d1
		jmp	Obj0A_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj0A_Index:	dc.w Obj0A_Init-Obj0A_Index
		dc.w Obj0A_Animate-Obj0A_Index
		dc.w Obj0A_ChkWater-Obj0A_Index
		dc.w Obj0A_Display-Obj0A_Index
		dc.w Obj0A_Delete-Obj0A_Index
		dc.w Obj0A_Countdown-Obj0A_Index
		dc.w Obj0A_AirLeft-Obj0A_Index
		dc.w Obj0A_Display-Obj0A_Index
		dc.w Obj0A_Delete-Obj0A_Index
; ---------------------------------------------------------------------------

Obj0A_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj0A_Bubbles,obMap(a0)
		move.w	#$8348,obGfx(a0)
		move.b	#$84,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#1,obPriority(a0)
		move.b	obSubtype(a0),d0
		bpl.s	loc_11ECC
		addq.b	#8,obRoutine(a0)
		move.l	#Map_Obj0A_Countdown,obMap(a0)
		move.w	#$440,obGfx(a0)
		andi.w	#$7F,d0
		move.b	d0,$33(a0)
		bra.w	Obj0A_Countdown
; ---------------------------------------------------------------------------

loc_11ECC:
		move.b	d0,obAnim(a0)
		bsr.w	Adjust2PArtPointer
		move.w	obX(a0),$30(a0)
		move.w	#$FF78,obVelY(a0)

Obj0A_Animate:
		lea	(Ani_Obj0A).l,a1
		jsr	(AnimateSprite).l

Obj0A_ChkWater:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bcs.s	loc_11F0A
		move.b	#6,obRoutine(a0)
		addq.b	#7,obAnim(a0)
		cmpi.b	#$D,obAnim(a0)
		beq.s	Obj0A_Display
		bra.s	Obj0A_Display
; ---------------------------------------------------------------------------

loc_11F0A:
		tst.b	(f_wtunnelmode).w
		beq.s	loc_11F14
		addq.w	#4,$30(a0)

loc_11F14:
		move.b	obAngle(a0),d0
		addq.b	#1,obAngle(a0)
		andi.w	#$7F,d0
		lea	(Obj0A_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$30(a0),d0
		move.w	d0,obX(a0)
		bsr.s	Obj0A_ShowNumber
		jsr	(ObjectMove).l
		tst.b	obRender(a0)
		bpl.s	loc_11F48
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_11F48:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

Obj0A_Display:
		bsr.s	Obj0A_ShowNumber
		lea	(Ani_Obj0A).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

Obj0A_Delete:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

Obj0A_AirLeft:
		cmpi.w	#$C,(v_air).w
		bhi.s	loc_11F9A
		subq.w	#1,$38(a0)
		bne.s	loc_11F82
		move.b	#$E,obRoutine(a0)
		addq.b	#7,obAnim(a0)
		bra.s	Obj0A_Display
; ---------------------------------------------------------------------------

loc_11F82:
		lea	(Ani_Obj0A).l,a1
		jsr	(AnimateSprite).l
		tst.b	obRender(a0)
		bpl.s	loc_11F9A
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_11F9A:
		jmp	(DeleteObject).l

; =============== S U B	R O U T	I N E =======================================


Obj0A_ShowNumber:
		tst.w	$38(a0)
		beq.s	locret_11FEA
		subq.w	#1,$38(a0)
		bne.s	locret_11FEA
		cmpi.b	#7,obAnim(a0)
		bcc.s	locret_11FEA
		move.w	#$F,$38(a0)
		clr.w	obVelY(a0)
		move.b	#$80,obRender(a0)
		move.w	obX(a0),d0
		sub.w	(Camera_RAM).w,d0
		addi.w	#$80,d0
		move.w	d0,obX(a0)
		move.w	obY(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		move.w	d0,$A(a0)
		move.b	#$C,obRoutine(a0)

locret_11FEA:
		rts
; End of function Obj0A_ShowNumber

; ---------------------------------------------------------------------------
Obj0A_WobbleData:dc.b	 0,   0,   0,	0,   0,	  0,   1,   1,	 1,   1,   1,	2,   2,	  2,   2,   2 ; 0
		dc.b	2,   2,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   3 ; 16
		dc.b	3,   3,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   2 ; 32
		dc.b	2,   2,	  2,   2,   2,	 2,   1,   1,	1,   1,	  1,   0,   0,	 0,   0,   0 ; 48
		dc.b	0,  -1,	 -1,  -1,  -1,	-1,  -2,  -2,  -2,  -2,	 -2,  -3,  -3,	-3,  -3,  -3 ; 64
		dc.b   -3,  -3,	 -4,  -4,  -4,	-4,  -4,  -4,  -4,  -4,	 -4,  -4,  -4,	-4,  -4,  -4 ; 80
		dc.b   -4,  -4,	 -4,  -4,  -4,	-4,  -4,  -4,  -4,  -4,	 -4,  -4,  -4,	-4,  -4,  -3 ; 96
		dc.b   -3,  -3,	 -3,  -3,  -3,	-3,  -2,  -2,  -2,  -2,	 -2,  -1,  -1,	-1,  -1,  -1 ; 112
		dc.b	0,   0,	  0,   0,   0,	 0,   1,   1,	1,   1,	  1,   2,   2,	 2,   2,   2 ; 128
		dc.b	2,   2,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   3 ; 144
		dc.b	3,   3,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   2 ; 160
		dc.b	2,   2,	  2,   2,   2,	 2,   1,   1,	1,   1,	  1,   0,   0,	 0,   0,   0 ; 176
		dc.b	0,  -1,	 -1,  -1,  -1,	-1,  -2,  -2,  -2,  -2,	 -2,  -3,  -3,	-3,  -3,  -3 ; 192
		dc.b   -3,  -3,	 -4,  -4,  -4,	-4,  -4,  -4,  -4,  -4,	 -4,  -4,  -4,	-4,  -4,  -4 ; 208
		dc.b   -4,  -4,	 -4,  -4,  -4,	-4,  -4,  -4,  -4,  -4,	 -4,  -4,  -4,	-4,  -4,  -3 ; 224
		dc.b   -3,  -3,	 -3,  -3,  -3,	-3,  -2,  -2,  -2,  -2,	 -2,  -1,  -1,	-1,  -1,  -1 ; 240
; ---------------------------------------------------------------------------

Obj0A_Countdown:
		tst.w	$2C(a0)
		bne.w	loc_121D6
		cmpi.b	#6,(v_objspace+obRoutine).w
		bcc.w	locret_122DC
		btst	#6,(v_objspace+obStatus).w
		beq.w	locret_122DC
		subq.w	#1,$38(a0)
		bpl.w	loc_121FC
		move.w	#$3B,$38(a0)
		move.w	#1,$36(a0)
		jsr	(RandomNumber).l
		andi.w	#1,d0
		move.b	d0,$34(a0)
		move.w	(v_air).w,d0
		cmpi.w	#$19,d0
		beq.s	loc_12166
		cmpi.w	#$14,d0
		beq.s	loc_12166
		cmpi.w	#$F,d0
		beq.s	loc_12166
		cmpi.w	#$C,d0
		bhi.s	loc_12170
		bne.s	loc_12152
		move.w	#bgm_Drowning,d0
		jsr	(PlaySound).l

loc_12152:
		subq.b	#1,$32(a0)
		bpl.s	loc_12170
		move.b	$33(a0),$32(a0)
		bset	#7,$36(a0)
		bra.s	loc_12170
; ---------------------------------------------------------------------------

loc_12166:
		move.w	#sfx_Warning,d0
		jsr	(PlaySound_Special).l

loc_12170:
		subq.w	#1,(v_air).w
		bcc.w	loc_121FA
		bsr.w	ResumeMusic
		move.b	#$81,(f_playerctrl).w
		move.w	#sfx_Drown,d0
		jsr	(PlaySound_Special).l
		move.b	#$A,$34(a0)
		move.w	#1,$36(a0)
		move.w	#$78,$2C(a0)
		move.l	a0,-(sp)
		lea	(v_objspace).w,a0
		bsr.w	Sonic_ResetOnFloor
		move.b	#$17,obAnim(a0)
		bset	#1,obStatus(a0)
		bset	#7,2(a0)
		move.w	#0,obVelY(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obInertia(a0)
		move.b	#1,(Deform_lock).w
		movea.l	(sp)+,a0
		rts
; ---------------------------------------------------------------------------

loc_121D6:
		subq.w	#1,$2C(a0)
		bne.s	loc_121E4
		move.b	#6,(v_objspace+obRoutine).w
		rts
; ---------------------------------------------------------------------------

loc_121E4:
		move.l	a0,-(sp)
		lea	(v_objspace).w,a0
		jsr	(ObjectMove).l
		addi.w	#$10,obVelY(a0)
		movea.l	(sp)+,a0
		bra.s	loc_121FC
; ---------------------------------------------------------------------------

loc_121FA:
		bra.s	loc_1220C
; ---------------------------------------------------------------------------

loc_121FC:
		tst.w	$36(a0)
		beq.w	locret_122DC
		subq.w	#1,$3A(a0)
		bpl.w	locret_122DC

loc_1220C:
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		move.w	d0,$3A(a0)
		jsr	(FindFreeObj).l
		bne.w	locret_122DC
		_move.b	#$A,obID(a1)
		move.w	(v_objspace+obX).w,obX(a1)
		moveq	#6,d0
		btst	#0,(v_objspace+obStatus).w
		beq.s	loc_12242
		neg.w	d0
		move.b	#$40,obAngle(a1)

loc_12242:
		add.w	d0,obX(a1)
		move.w	(v_objspace+obY).w,obY(a1)
		move.b	#6,obSubtype(a1)
		tst.w	$2C(a0)
		beq.w	loc_1228E
		andi.w	#7,$3A(a0)
		addi.w	#0,$3A(a0)
		move.w	(v_objspace+obY).w,d0
		subi.w	#$C,d0
		move.w	d0,obY(a1)
		jsr	(RandomNumber).l
		move.b	d0,obAngle(a1)
		move.w	(Timer_frames).w,d0
		andi.b	#3,d0
		bne.s	loc_122D2
		move.b	#$E,obSubtype(a1)
		bra.s	loc_122D2
; ---------------------------------------------------------------------------

loc_1228E:
		btst	#7,$36(a0)
		beq.s	loc_122D2
		move.w	(v_air).w,d2
		lsr.w	#1,d2
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	loc_122BA
		bset	#6,$36(a0)
		bne.s	loc_122D2
		move.b	d2,obSubtype(a1)
		move.w	#$1C,$38(a1)

loc_122BA:
		tst.b	$34(a0)
		bne.s	loc_122D2
		bset	#6,$36(a0)
		bne.s	loc_122D2
		move.b	d2,obSubtype(a1)
		move.w	#$1C,$38(a1)

loc_122D2:
		subq.b	#1,$34(a0)
		bpl.s	locret_122DC
		clr.w	$36(a0)

locret_122DC:
		rts

; =============== S U B	R O U T	I N E =======================================


ResumeMusic:
		cmpi.w	#$C,(v_air).w
		bhi.s	loc_12310
		move.w	#bgm_LZ,d0
		cmpi.w	#$103,(Current_ZoneAndAct).w
		bne.s	loc_122F6
		move.w	#bgm_SBZ,d0

loc_122F6:
		tst.b	(v_invinc).w
		beq.s	loc_12300
		move.w	#bgm_Invincible,d0

loc_12300:
		tst.b	(f_lockscreen).w
		beq.s	loc_1230A
		move.w	#bgm_Boss,d0

loc_1230A:
		jsr	(PlaySound).l

loc_12310:
		move.w	#$1E,(v_air).w
		clr.b	(v_objspace+$372).w
		rts
; End of function ResumeMusic

; ---------------------------------------------------------------------------
Ani_Obj0A:	dc.w byte_1233A-Ani_Obj0A,byte_12343-Ani_Obj0A ;	0
		dc.w byte_1234C-Ani_Obj0A,byte_12355-Ani_Obj0A ;	2
		dc.w byte_1235E-Ani_Obj0A,byte_12367-Ani_Obj0A ;	4
		dc.w byte_12370-Ani_Obj0A,byte_12375-Ani_Obj0A ;	6
		dc.w byte_1237D-Ani_Obj0A,byte_12385-Ani_Obj0A ;	8
		dc.w byte_1238D-Ani_Obj0A,byte_12395-Ani_Obj0A ;	10
		dc.w byte_1239D-Ani_Obj0A,byte_123A5-Ani_Obj0A ;	12
		dc.w byte_123A7-Ani_Obj0A		; 14
byte_1233A:	dc.b   5,  0,  1,  2,  3,  4,  9, $D,$FC ; 0
byte_12343:	dc.b   5,  0,  1,  2,  3,  4, $C,$12,$FC ; 0
byte_1234C:	dc.b   5,  0,  1,  2,  3,  4, $C,$11,$FC ; 0
byte_12355:	dc.b   5,  0,  1,  2,  3,  4, $B,$10,$FC ; 0
byte_1235E:	dc.b   5,  0,  1,  2,  3,  4,  9, $F,$FC ; 0
byte_12367:	dc.b   5,  0,  1,  2,  3,  4, $A, $E,$FC ; 0
byte_12370:	dc.b  $E,  0,  1,  2,$FC		; 0
byte_12375:	dc.b   7,$16, $D,$16, $D,$16, $D,$FC	; 0
byte_1237D:	dc.b   7,$16,$12,$16,$12,$16,$12,$FC	; 0
byte_12385:	dc.b   7,$16,$11,$16,$11,$16,$11,$FC	; 0
byte_1238D:	dc.b   7,$16,$10,$16,$10,$16,$10,$FC	; 0
byte_12395:	dc.b   7,$16, $F,$16, $F,$16, $F,$FC	; 0
byte_1239D:	dc.b   7,$16, $E,$16, $E,$16, $E,$FC	; 0
byte_123A5:	dc.b  $E,$FC				; 0
byte_123A7:	dc.b  $E,  1,  2,  3,  4,$FC,  0	; 0
Map_Obj0A_Countdown:dc.w word_123B0-Map_Obj0A_Countdown
word_123B0:	dc.w 1
		dc.w $E80E,    0,    0,$FFF2		; 0

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

Obj38:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj38_Index(pc,d0.w),d1
		jmp	Obj38_Index(pc,d1.w)
; ===========================================================================
Obj38_Index:	dc.w Obj38_Init-Obj38_Index
		dc.w Obj38_Shield-Obj38_Index
		dc.w Obj38_Stars-Obj38_Index
; ===========================================================================

Obj38_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj38,obMap(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$18,obActWid(a0)
		tst.b	obAnim(a0)			; is this the shield?
		bne.s	loc_1240C			; if not, branch
		move.w	#$4BE,obGfx(a0)
		cmpi.b	#3,(Current_Zone).w		; is this Emerald Hill Zone?
		bne.s	loc_12406			; if not, branch
		move.w	#$560,obGfx(a0)

loc_12406:
		bsr.w	Adjust2PArtPointer
		rts
; ===========================================================================

loc_1240C:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#$4DE,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#2,obPriority(a0)
		rts
; ===========================================================================

Obj38_Shield:
		tst.b	(v_invinc).w			; is Sonic invincible?
		bne.s	locret_1245A			; if yes, branch
		tst.b	(v_shield).w			; does Sonic have a shield?
		beq.s	Obj38_Delete			; if not, branch
		move.w	(v_objspace+obX).w,obX(a0)
		move.w	(v_objspace+obY).w,obY(a0)
		move.b	(v_objspace+obStatus).w,obStatus(a0)
		lea	(Ani_obj38).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

locret_1245A:
		rts
; ===========================================================================
; loc_1245C:
Obj38_Delete:
		jmp	(DeleteObject).l
; ===========================================================================

Obj38_Stars:
		tst.b	(v_invinc).w			; is Sonic invincible?
		beq.s	Obj38_Delete2			; if not, branch
		move.w	($FFFFEEE0).w,d0
		move.b	obAnim(a0),d1
		subq.b	#1,d1
		move.b	#$3F,d1
		lsl.b	#2,d1
		addi.b	#4,d1
		sub.b	d1,d0
		lea	(Tails_Pos_Record_Buf).w,a1	; should actually be using Sonic's...
		lea	(a1,d0.w),a1
		move.w	(a1)+,d0
		andi.w	#$3FFF,d0
		move.w	d0,obX(a0)
		move.w	(a1)+,d0
		andi.w	#$7FF,d0
		move.w	d0,obY(a0)
		move.b	(v_objspace+obStatus).w,obStatus(a0)
		move.b	(v_objspace+$1A).w,obFrame(a0)
		move.b	(v_objspace+1).w,obRender(a0)
		jmp	(DisplaySprite).l
; ===========================================================================
; loc_124B2:
Obj38_Delete2:
		jmp	(DeleteObject).l
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	1 Object 4A - giant ring entry effect from prototype
; ---------------------------------------------------------------------------
; OST:
obj4A_vanishtime:	equ $30				; time for Sonic to vanish for
; ---------------------------------------------------------------------------

S1Obj4A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj4A_Index(pc,d0.w),d1
		jmp	S1Obj4A_Index(pc,d1.w)
; ===========================================================================
S1Obj4A_Index:	dc.w S1Obj4A_Init-S1Obj4A_Index
		dc.w S1Obj4A_RmvSonic-S1Obj4A_Index
		dc.w S1Obj4A_LoadSonic-S1Obj4A_Index
; ===========================================================================

S1Obj4A_Init:
		tst.l	(v_plc_buffer).w		; are the pattern load cues empty?
		beq.s	loc_124D4			; if yes, branch
		rts
; ---------------------------------------------------------------------------

loc_124D4:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_S1obj4A,obMap(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$38,obActWid(a0)
		move.w	#$541,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.w	#60*2,obj4A_vanishtime(a0)	; set vanishing time to 2 seconds

S1Obj4A_RmvSonic:
		move.w	(v_objspace+obX).w,obX(a0)
		move.w	(v_objspace+obY).w,obY(a0)
		move.b	(v_objspace+obStatus).w,obStatus(a0)
		lea	(Ani_S1obj4A).l,a1
		jsr	(AnimateSprite).l
		cmpi.b	#2,obFrame(a0)
		bne.s	loc_1253E
		tst.b	(v_objspace).w			; is this Sonic?
		beq.s	loc_1253E			; if not, branch
		move.b	#0,(v_objspace).w		; set Sonic's object ID to 0
		move.w	#sfx_SSGoal,d0
		jsr	(PlaySound_Special).l		; play Special Stage entry sound effect

loc_1253E:
		jmp	(DisplaySprite).l
; ===========================================================================

S1Obj4A_LoadSonic:
		subq.w	#1,obj4A_vanishtime(a0)		; subtract 1 from vanishing time
		bne.s	locret_12556			; if there's any time left, branch
		move.b	#1,(v_objspace).w		; set Sonic's object ID to 1
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

locret_12556:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 08 - water splash
; ---------------------------------------------------------------------------

Obj08:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj08_Index(pc,d0.w),d1
		jmp	Obj08_Index(pc,d1.w)
; ===========================================================================
Obj08_Index:	dc.w Obj08_Init-Obj08_Index
		dc.w Obj08_Display-Obj08_Index
		dc.w Obj08_Delete-Obj08_Index
; ===========================================================================

Obj08_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj08,obMap(a0)
		ori.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$4259,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.w	(v_objspace+obX).w,obX(a0)

Obj08_Display:
		move.w	(v_waterpos1).w,obY(a0)
		lea	(Ani_obj08).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ===========================================================================

Obj08_Delete:
		jmp	(DeleteObject).l
; ===========================================================================
; animation script
Ani_obj38:	dc.w byte_125C2-Ani_obj38
		dc.w byte_125CE-Ani_obj38
		dc.w byte_125D4-Ani_obj38
		dc.w byte_125EE-Ani_obj38
		dc.w byte_12608-Ani_obj38
byte_125C2:	dc.b   0,  5,  0,  5,  1,  5,  2,  5,  3,  5,  4,$FF
byte_125CE:	dc.b   5,  4,  5,  6,  7,$FF
byte_125D4:	dc.b   0,  4,  4,  0,  4,  4,  0,  5,  5,  0,  5,  5,  0,  6,  6,  0
		dc.b   6,  6,  0,  7,  7,  0,  7,  7,  0,$FF
byte_125EE:	dc.b   0,  4,  4,  0,  4,  0,  0,  5,  5,  0,  5,  0,  0,  6,  6,  0
		dc.b   6,  0,  0,  7,  7,  0,  7,  0,  0,$FF
byte_12608:	dc.b   0,  4,  0,  0,  4,  0,  0,  5,  0,  0,  5,  0,  0,  6,  0,  0
		dc.b   6,  0,  0,  7,  0,  0,  7,  0,  0,$FF

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj38:	binclude	"mappings/sprite/obj38.bin"

; animation script
Ani_S1obj4A:	dc.w byte_1278C-Ani_S1obj4A
byte_1278C:	dc.b   5,  0,  1,  0,  1,  0,  7,  1,  7,  2,  7,  3,  7,  4,  7,  5
		dc.b   7,  6,  7,$FC

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_S1obj4A:	binclude	"mappings/sprite/obj4A_S1.bin"

; animation script
Ani_obj08:	dc.w byte_129C2-Ani_obj08
byte_129C2:	dc.b   4,  0,  1,  2,$FC,  0

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj08:	binclude	"mappings/sprite/obj08.bin"

; =============== S U B	R O U T	I N E =======================================

; Sonic_AnglePos:
AnglePos:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,$3E(a0)
		beq.s	loc_12A14
		move.l	#v_colladdr2,(Collision_addr).w

loc_12A14:
		move.b	$3E(a0),d5
		btst	#3,obStatus(a0)
		beq.s	loc_12A2C
		moveq	#0,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		rts
; ---------------------------------------------------------------------------

loc_12A2C:
		moveq	#3,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		bpl.s	loc_12A4E
		move.b	obAngle(a0),d0
		bpl.s	loc_12A48
		subq.b	#1,d0

loc_12A48:
		addi.b	#$20,d0
		bra.s	loc_12A5A
; ---------------------------------------------------------------------------

loc_12A4E:
		move.b	obAngle(a0),d0
		bpl.s	loc_12A56
		addq.b	#1,d0

loc_12A56:
		addi.b	#$1F,d0

loc_12A5A:
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Sonic_WalkVertL
		cmpi.b	#$80,d0
		beq.w	Sonic_WalkCeiling
		cmpi.b	#$C0,d0
		beq.w	Sonic_WalkVertR
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_12AE4
		bpl.s	loc_12AE6
		cmpi.w	#$FFF2,d1
		blt.s	locret_12B0C
		add.w	d1,obY(a0)

locret_12AE4:
		rts
; ---------------------------------------------------------------------------

loc_12AE6:
		cmpi.w	#$E,d1
		bgt.s	loc_12AF2

loc_12AEC:
		add.w	d1,obY(a0)
		rts
; ---------------------------------------------------------------------------

loc_12AF2:
		tst.b	$38(a0)
		bne.s	loc_12AEC
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)
		rts
; ---------------------------------------------------------------------------

locret_12B0C:
		rts
; End of function AnglePos

; ---------------------------------------------------------------------------
		move.l	obX(a0),d2
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.l	d2,obX(a0)
		move.w	#$38,d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		rts
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR AnglePos

locret_12B30:
		rts
; END OF FUNCTION CHUNK	FOR AnglePos
; ---------------------------------------------------------------------------
		move.l	obY(a0),d3
		move.w	obVelY(a0),d0
		subi.w	#$38,d0
		move.w	d0,obVelY(a0)
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		rts
; ---------------------------------------------------------------------------
		rts
; ---------------------------------------------------------------------------
		move.l	obX(a0),d2
		move.l	obY(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d2,obX(a0)
		move.l	d3,obY(a0)
		rts

; =============== S U B	R O U T	I N E =======================================


Sonic_Angle:
		move.b	(Secondary_Angle).w,d2
		cmp.w	d0,d1
		ble.s	loc_12B84
		move.b	(Primary_Angle).w,d2
		move.w	d0,d1

loc_12B84:
		btst	#0,d2
		bne.s	loc_12B90
		move.b	d2,obAngle(a0)
		rts
; ---------------------------------------------------------------------------

loc_12B90:
		move.b	obAngle(a0),d2
		addi.b	#$20,d2
		andi.b	#$C0,d2
		move.b	d2,obAngle(a0)
		rts
; End of function Sonic_Angle

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR AnglePos

Sonic_WalkVertR:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_12C12
		bpl.s	loc_12C14
		cmpi.w	#$FFF2,d1
		blt.w	locret_12B30
		add.w	d1,obX(a0)

locret_12C12:
		rts
; ---------------------------------------------------------------------------

loc_12C14:
		cmpi.w	#$E,d1
		bgt.s	loc_12C20

loc_12C1A:
		add.w	d1,obX(a0)
		rts
; ---------------------------------------------------------------------------

loc_12C20:
		tst.b	$38(a0)
		bne.s	loc_12C1A
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)
		rts
; ---------------------------------------------------------------------------

Sonic_WalkCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_12CB0
		bpl.s	loc_12CB2
		cmpi.w	#$FFF2,d1
		blt.w	locret_12B0C
		sub.w	d1,obY(a0)

locret_12CB0:
		rts
; ---------------------------------------------------------------------------

loc_12CB2:
		cmpi.w	#$E,d1
		bgt.s	loc_12CBE

loc_12CB8:
		sub.w	d1,obY(a0)
		rts
; ---------------------------------------------------------------------------

loc_12CBE:
		tst.b	$38(a0)
		bne.s	loc_12CB8
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)
		rts
; ---------------------------------------------------------------------------

Sonic_WalkVertL:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_12D4E
		bpl.s	loc_12D50
		cmpi.w	#$FFF2,d1
		blt.w	locret_12B30
		sub.w	d1,obX(a0)

locret_12D4E:
		rts
; ---------------------------------------------------------------------------

loc_12D50:
		cmpi.w	#$E,d1
		bgt.s	loc_12D5C

loc_12D56:
		sub.w	d1,obX(a0)
		rts
; ---------------------------------------------------------------------------

loc_12D5C:
		tst.b	$38(a0)
		bne.s	loc_12D56
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)
		rts
; END OF FUNCTION CHUNK	FOR AnglePos

; =============== S U B	R O U T	I N E =======================================


Floor_ChkTile:
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$F00,d0
		move.w	d3,d1
		lsr.w	#7,d1
		andi.w	#$7F,d1
		add.w	d1,d0
		moveq	#$FFFFFFFF,d1
		lea	(v_lvllayout).w,a1
		move.b	(a1,d0.w),d1
		andi.w	#$FF,d1
		lsl.w	#7,d1
		move.w	d2,d0
		andi.w	#$70,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		add.w	d0,d1
		movea.l	d1,a1
		rts
; End of function Floor_ChkTile


; =============== S U B	R O U T	I N E =======================================


FindFloor:
		bsr.s	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_12DBE
		btst	d5,d4
		bne.s	loc_12DCC

loc_12DBE:
		add.w	a3,d2
		bsr.w	FindFloor2
		sub.w	a3,d2
		addi.w	#$10,d1
		rts
; ---------------------------------------------------------------------------

loc_12DCC:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.w	(a2,d0.w),d0
		beq.s	loc_12DBE
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_12DF0
		not.w	d1
		neg.b	(a4)

loc_12DF0:
		btst	#$B,d4
		beq.s	loc_12E00
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_12E00:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(ColArray1).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_12E1C
		neg.w	d0

loc_12E1C:
		tst.w	d0
		beq.s	loc_12DBE
		bmi.s	loc_12E38
		cmpi.b	#$10,d0
		beq.s	loc_12E44
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_12E38:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_12DBE

loc_12E44:
		sub.w	a3,d2
		bsr.w	FindFloor2
		add.w	a3,d2
		subi.w	#$10,d1
		rts
; End of function FindFloor


; =============== S U B	R O U T	I N E =======================================


FindFloor2:
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_12E64
		btst	d5,d4
		bne.s	loc_12E72

loc_12E64:
		move.w	#$F,d1
		move.w	d2,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_12E72:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.w	(a2,d0.w),d0
		beq.s	loc_12E64
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_12E96
		not.w	d1
		neg.b	(a4)

loc_12E96:
		btst	#$B,d4
		beq.s	loc_12EA6
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_12EA6:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(ColArray1).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_12EC2
		neg.w	d0

loc_12EC2:
		tst.w	d0
		beq.s	loc_12E64
		bmi.s	loc_12ED8
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_12ED8:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_12E64
		not.w	d1
		rts
; End of function FindFloor2


; =============== S U B	R O U T	I N E =======================================


FindWall:
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_12EFA
		btst	d5,d4
		bne.s	loc_12F08

loc_12EFA:
		add.w	a3,d3
		bsr.w	FindWall2
		sub.w	a3,d3
		addi.w	#$10,d1
		rts
; ---------------------------------------------------------------------------

loc_12F08:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.w	(a2,d0.w),d0
		beq.s	loc_12EFA
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4
		beq.s	loc_12F34
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_12F34:
		btst	#$A,d4
		beq.s	loc_12F3C
		neg.b	(a4)

loc_12F3C:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(ColArray2).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4
		beq.s	loc_12F58
		neg.w	d0

loc_12F58:
		tst.w	d0
		beq.s	loc_12EFA
		bmi.s	loc_12F74
		cmpi.b	#$10,d0
		beq.s	loc_12F80
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_12F74:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_12EFA

loc_12F80:
		sub.w	a3,d3
		bsr.w	FindWall2
		add.w	a3,d3
		subi.w	#$10,d1
		rts
; End of function FindWall


; =============== S U B	R O U T	I N E =======================================


FindWall2:
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_12FA0
		btst	d5,d4
		bne.s	loc_12FAE

loc_12FA0:
		move.w	#$F,d1
		move.w	d3,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_12FAE:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.w	(a2,d0.w),d0
		beq.s	loc_12FA0
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4
		beq.s	loc_12FDA
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_12FDA:
		btst	#$A,d4
		beq.s	loc_12FE2
		neg.b	(a4)

loc_12FE2:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(ColArray2).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4
		beq.s	loc_12FFE
		neg.w	d0

loc_12FFE:
		tst.w	d0
		beq.s	loc_12FA0
		bmi.s	loc_13014
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_13014:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_12FA0
		not.w	d1
		rts
; End of function FindWall2

; ---------------------------------------------------------------------------
; This dummied out subroutine takes Green Hill Zone/the Sonic 1 collision
; format and converts it to the format used in-game - UNLIKE Sonic 1/2 Final,
; where this instead converts the collision from a bitmap-like format to the
; one used in game (though both of these would require a cartridge that could
; write data to itself, not standard carts).
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; FloorLog_Unk: ConvertCollisionArray:
ApplySonic1Collision:
		rts
; ---------------------------------------------------------------------------
		lea	(ColArray1_GHZ).l,a1
		tst.b	(Current_Zone).w
		beq.s	loc_13038
		lea	(ColArray1).l,a1

loc_13038:
		lea	(ColArray1).l,a2
		move.w	#$7FF,d1

loc_13042:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_13042
		lea	(ColArray2).l,a2
		move.w	#$7FF,d1

loc_13052:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_13052
		lea	(AngleMap_GHZ).l,a1
		tst.b	(Current_Zone).w
		beq.s	loc_1306A
		lea	(AngleMap).l,a1

loc_1306A:
		lea	(AngleMap).l,a2
		move.w	#$7F,d1

loc_13074:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_13074
		rts
; End of function ApplySonic1Collision


; =============== S U B	R O U T	I N E =======================================

; Sonic_WalkSpeed:
CalcRoomInFront:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,$3E(a0)
		beq.s	loc_13094
		move.l	#v_colladdr2,(Collision_addr).w

loc_13094:
		move.b	$3F(a0),d5
		move.l	obX(a0),d3
		move.l	obY(a0),d2
		move.w	obVelX(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	obVelY(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_130D4
		move.b	d1,d0
		bpl.s	loc_130CE
		subq.b	#1,d0

loc_130CE:
		addi.b	#$20,d0
		bra.s	loc_130DE
; ---------------------------------------------------------------------------

loc_130D4:
		move.b	d1,d0
		bpl.s	loc_130DA
		addq.b	#1,d0

loc_130DA:
		addi.b	#$1F,d0

loc_130DE:
		andi.b	#$C0,d0
		beq.w	loc_131DE
		cmpi.b	#$80,d0
		beq.w	loc_133B0
		andi.b	#$38,d1
		bne.s	loc_130F6
		addq.w	#8,d2

loc_130F6:
		cmpi.b	#$40,d0
		beq.w	loc_13478
		bra.w	loc_132F6
; End of function CalcRoomInFront


; =============== S U B	R O U T	I N E =======================================


sub_13102:

; FUNCTION CHUNK AT 0001328E SIZE 00000060 BYTES
; FUNCTION CHUNK AT 00013408 SIZE 00000068 BYTES

		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,$3E(a0)
		beq.s	loc_1311A
		move.l	#v_colladdr2,(Collision_addr).w

loc_1311A:
		move.b	$3F(a0),d5
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_13408
		cmpi.b	#$80,d0
		beq.w	Sonic_DontRunOnWalls
		cmpi.b	#$C0,d0
		beq.w	loc_1328E

loc_13146:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,$3E(a0)
		beq.s	loc_1315E
		move.l	#v_colladdr2,(Collision_addr).w

loc_1315E:
		move.b	$3E(a0),d5
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#0,d2

loc_131BE:
		move.b	(Secondary_Angle).w,d3
		cmp.w	d0,d1
		ble.s	loc_131CC
		move.b	(Primary_Angle).w,d3
		exg	d0,d1

loc_131CC:
		btst	#0,d3
		beq.s	locret_131D4
		move.b	d2,d3

locret_131D4:
		rts
; End of function sub_13102

; ---------------------------------------------------------------------------
		move.w	obY(a0),d2
		move.w	obX(a0),d3
; START	OF FUNCTION CHUNK FOR CalcRoomInFront

loc_131DE:
		addi.w	#$A,d2
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.b	#0,d2

loc_131F6:
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_13202
		move.b	d2,d3

locret_13202:
		rts
; END OF FUNCTION CHUNK	FOR CalcRoomInFront

; =============== S U B	R O U T	I N E =======================================

; Sonic_HitFloor:
ChkFloorEdge:
		move.w	obX(a0),d3
		move.w	obY(a0),d2
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,$3E(a0)
		beq.s	loc_1322E
		move.l	#v_colladdr2,(Collision_addr).w

loc_1322E:
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		move.b	$3E(a0),d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_13254
		move.b	#0,d3

locret_13254:
		rts
; End of function ChkFloorEdge


; =============== S U B	R O U T	I N E =======================================


ObjHitFloor:
		move.w	obX(a0),d3

ObjHitFloor2:
		move.w	obY(a0),d2
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_1328C
		move.b	#0,d3

locret_1328C:
		rts
; End of function ObjHitFloor

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_13102

loc_1328E:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$C0,d2
		bra.w	loc_131BE
; END OF FUNCTION CHUNK	FOR sub_13102

; =============== S U B	R O U T	I N E =======================================


sub_132EE:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
; End of function sub_132EE

; START	OF FUNCTION CHUNK FOR CalcRoomInFront

loc_132F6:
		addi.w	#$A,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.b	#$C0,d2
		bra.w	loc_131F6
; END OF FUNCTION CHUNK	FOR CalcRoomInFront

; =============== S U B	R O U T	I N E =======================================


ObjHitWallRight:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_1333E
		move.b	#$C0,d3

locret_1333E:
		rts
; End of function ObjHitWallRight


; =============== S U B	R O U T	I N E =======================================


Sonic_DontRunOnWalls:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#$80,d2
		bra.w	loc_131BE
; End of function Sonic_DontRunOnWalls

; ---------------------------------------------------------------------------
		move.w	obY(a0),d2
		move.w	obX(a0),d3
; START	OF FUNCTION CHUNK FOR CalcRoomInFront

loc_133B0:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	#$80,d2
		bra.w	loc_131F6
; END OF FUNCTION CHUNK	FOR CalcRoomInFront
; ---------------------------------------------------------------------------

ObjHitCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_13406
		move.b	#$80,d3

locret_13406:
		rts
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_13102

loc_13408:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_131BE
; END OF FUNCTION CHUNK	FOR sub_13102

; =============== S U B	R O U T	I N E =======================================


Sonic_HitWall:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
; End of function Sonic_HitWall

; START	OF FUNCTION CHUNK FOR CalcRoomInFront

loc_13478:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	loc_131F6
; END OF FUNCTION CHUNK	FOR CalcRoomInFront
; ---------------------------------------------------------------------------

ObjHitWallLeft:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$FFF0,a3
		move.w	#$400,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_134C4
		move.b	#$40,d3

locret_134C4:
		rts
; ---------------------------------------------------------------------------
		nop
;----------------------------------------------------
; Object 79 - lamppost
;----------------------------------------------------

Obj79:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj79_Index(pc,d0.w),d1
		jsr	Obj79_Index(pc,d1.w)
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------
Obj79_Index:	dc.w Obj79_Init-Obj79_Index
		dc.w Obj79_Main-Obj79_Index
		dc.w Obj79_AfterHit-Obj79_Index
; ---------------------------------------------------------------------------

Obj79_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj79,obMap(a0)
		move.w	#$47C,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#8,obActWid(a0)
		move.b	#5,obPriority(a0)
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
		bne.s	loc_13536
		move.b	(v_lastlamp).w,d1
		andi.b	#$7F,d1
		move.b	obSubtype(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1
		bcs.s	Obj79_Main

loc_13536:
		bset	#0,2(a2,d0.w)
		move.b	#4,obRoutine(a0)
		rts
; ---------------------------------------------------------------------------

Obj79_Main:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_135CA
		tst.b	(f_playerctrl).w
		bmi.w	locret_135CA
		move.b	(v_lastlamp).w,d1
		andi.b	#$7F,d1
		move.b	obSubtype(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1
		bcs.s	Obj79_HitLamp
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	#0,2(a2,d0.w)
		move.b	#4,obRoutine(a0)
		bra.w	locret_135CA
; ---------------------------------------------------------------------------

Obj79_HitLamp:
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		addi.w	#8,d0
		cmpi.w	#$10,d0
		bcc.w	locret_135CA
		move.w	(v_objspace+obY).w,d0
		sub.w	obY(a0),d0
		addi.w	#$40,d0
		cmpi.w	#$68,d0
		bcc.s	locret_135CA
		move.w	#sfx_Lamppost,d0
		jsr	(PlaySound_Special).l
		addq.b	#2,obRoutine(a0)
		bsr.w	Lamppost_StoreInfo
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	#0,2(a2,d0.w)

locret_135CA:
		rts
; ---------------------------------------------------------------------------

Obj79_AfterHit:
		move.b	($FFFFFE0F).w,d0
		andi.b	#2,d0
		lsr.b	#1,d0
		addq.b	#1,d0
		move.b	d0,obFrame(a0)
		rts

; =============== S U B	R O U T	I N E =======================================


Lamppost_StoreInfo:
		move.b	obSubtype(a0),(v_lastlamp).w
		move.b	(v_lastlamp).w,(v_lastlamp+1).w
		move.w	obX(a0),(v_lamp_xpos).w
		move.w	obY(a0),(v_lamp_ypos).w
		move.w	(v_rings).w,(v_lamp_rings).w
		move.b	(v_lifecount).w,(v_lamp_lives).w
		move.l	(v_time).w,(v_lamp_time).w
		move.b	(Dynamic_Resize_Routine).w,(v_lamp_dle).w
		move.w	(Camera_Max_Y_pos).w,(v_lamp_limitbtm).w
		move.w	(Camera_RAM).w,(v_lamp_scrx).w
		move.w	(Camera_Y_pos).w,(v_lamp_scry).w
		move.w	(Camera_BG_X_pos).w,(v_lamp_bgscrx).w
		move.w	(Camera_BG_Y_pos).w,(v_lamp_bgscry).w
		move.w	(Camera_BG2_X_pos).w,(v_lamp_bg2scrx).w
		move.w	(Camera_BG2_Y_pos).w,(v_lamp_bg2scry).w
		move.w	(Camera_BG3_X_pos).w,(v_lamp_bg3scrx).w
		move.w	(Camera_BG3_Y_pos).w,(v_lamp_bg3scry).w
		move.w	(v_waterpos2).w,(v_lamp_wtrpos).w
		move.b	(v_wtr_routine).w,(v_lamp_wtrrout).w
		move.b	(f_wtr_state).w,(v_lamp_wtrstat).w
		rts
; End of function Lamppost_StoreInfo


; =============== S U B	R O U T	I N E =======================================


Lamppost_LoadInfo:
		move.b	(v_lastlamp+1).w,(v_lastlamp).w
		move.w	(v_lamp_xpos).w,(v_objspace+obX).w
		move.w	(v_lamp_ypos).w,(v_objspace+obY).w
		move.w	(v_lamp_rings).w,(v_rings).w
		move.b	(v_lamp_lives).w,(v_lifecount).w
		clr.w	(v_rings).w
		clr.b	(v_lifecount).w
		move.l	(v_lamp_time).w,(v_time).w
		move.b	#$3B,(v_timecent).w
		subq.b	#1,(v_timesec).w
		move.b	(v_lamp_dle).w,(Dynamic_Resize_Routine).w
		move.b	(v_lamp_wtrrout).w,(v_wtr_routine).w
		move.w	(v_lamp_limitbtm).w,(Camera_Max_Y_pos).w
		move.w	(v_lamp_limitbtm).w,(Camera_Max_Y_pos_target).w
		move.w	(v_lamp_scrx).w,(Camera_RAM).w
		move.w	(v_lamp_scry).w,(Camera_Y_pos).w
		move.w	(v_lamp_bgscrx).w,(Camera_BG_X_pos).w
		move.w	(v_lamp_bgscry).w,(Camera_BG_Y_pos).w
		move.w	(v_lamp_bg2scrx).w,(Camera_BG2_X_pos).w
		move.w	(v_lamp_bg2scry).w,(Camera_BG2_Y_pos).w
		move.w	(v_lamp_bg3scrx).w,(Camera_BG3_X_pos).w
		move.w	(v_lamp_bg3scry).w,(Camera_BG3_Y_pos).w
		cmpi.b	#1,(Current_Zone).w
		bne.s	loc_136F0
		move.w	(v_lamp_wtrpos).w,(v_waterpos2).w
		move.b	(v_lamp_wtrrout).w,(v_wtr_routine).w
		move.b	(v_lamp_wtrstat).w,(f_wtr_state).w

loc_136F0:
		tst.b	(v_lastlamp).w
		bpl.s	locret_13702
		move.w	(v_lamp_xpos).w,d0
		subi.w	#$A0,d0
		move.w	d0,(Camera_Min_X_pos).w

locret_13702:
		rts
; End of function Lamppost_LoadInfo

; ---------------------------------------------------------------------------
Map_Obj79:	dc.w word_1370A-Map_Obj79
		dc.w word_1372C-Map_Obj79
		dc.w word_1374E-Map_Obj79
word_1370A:	dc.w 4
		dc.w $E801,$2000,$2000,$FFF8		; 0
		dc.w $E801,$2800,$2800,	   0		; 4
		dc.w $F803,    6,    3,$FFF8		; 8
		dc.w $F803, $806, $803,	   0		; 12
word_1372C:	dc.w 4
		dc.w $E801,    2,    1,$FFF8		; 0
		dc.w $E801, $802, $801,	   0		; 4
		dc.w $F803,    6,    3,$FFF8		; 8
		dc.w $F803, $806, $803,	   0		; 12
word_1374E:	dc.w 4
		dc.w $E801,$2004,$2002,$FFF8		; 0
		dc.w $E801,$2804,$2802,	   0		; 4
		dc.w $F803,    6,    3,$FFF8		; 8
		dc.w $F803, $806, $803,	   0		; 12
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 7D - hidden points at the end of a level
;----------------------------------------------------

Obj7D:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj7D_Index(pc,d0.w),d1
		jmp	Obj7D_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj7D_Index:	dc.w Obj7D_Main-Obj7D_Index
		dc.w Obj7D_DelayDelete-Obj7D_Index
; ---------------------------------------------------------------------------

Obj7D_Main:
		moveq	#$10,d2
		move.w	d2,d3
		add.w	d3,d3
		lea	(v_objspace).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	loc_13804
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bcc.s	loc_13804
		tst.w	(Debug_placement_mode).w
		bne.s	loc_13804
		tst.b	(f_bigring).w
		bne.s	loc_13804
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj7D,obMap(a0)
		move.w	#$84B6,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#0,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	obSubtype(a0),obFrame(a0)
		move.w	#$77,$30(a0)
		move.w	#sfx_Bonus,d0
		jsr	(PlaySound_Special).l
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	Obj7D_Points(pc,d0.w),d0
		jsr	(AddPoints).l

loc_13804:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_13818
		rts
; ---------------------------------------------------------------------------

loc_13818:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------
Obj7D_Points:	dc.w	 0, 1000,  100,	   1		; 0
; ---------------------------------------------------------------------------

Obj7D_DelayDelete:
		subq.w	#1,$30(a0)
		bmi.s	loc_13844
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_13844
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_13844:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------
Map_Obj7D:	dc.w word_13852-Map_Obj7D
		dc.w word_13854-Map_Obj7D
		dc.w word_1385E-Map_Obj7D
		dc.w word_13868-Map_Obj7D
word_13852:	dc.w 0
word_13854:	dc.w 1
		dc.w $F40E,    0,    0,$FFF0		; 0
word_1385E:	dc.w 1
		dc.w $F40E,   $C,    6,$FFF0		; 0
word_13868:	dc.w 1
		dc.w $F40E,  $18,   $C,$FFF0		; 0
; ---------------------------------------------------------------------------
		nop

S1Obj47:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj47_Index(pc,d0.w),d1
		jmp	S1Obj47_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj47_Index:	dc.w S1Obj47_Init-S1Obj47_Index
		dc.w S1Obj47_Main-S1Obj47_Index
; ---------------------------------------------------------------------------

S1Obj47_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_S1Obj47,obMap(a0)
		move.w	#$380,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#1,obPriority(a0)
		move.b	#$D7,obColType(a0)

S1Obj47_Main:
		move.b	obColProp(a0),d0
		beq.w	loc_13976
		lea	(v_objspace).w,a1
		bclr	#0,obColProp(a0)
		beq.s	loc_138CA
		bsr.s	S1Obj47_Bump

loc_138CA:
		lea	(v_objspace+$40).w,a1
		bclr	#1,obColProp(a0)
		beq.s	loc_138D8
		bsr.s	S1Obj47_Bump

loc_138D8:
		clr.b	obColProp(a0)
		bra.w	loc_13976

; =============== S U B	R O U T	I N E =======================================


S1Obj47_Bump:
		move.w	obX(a0),d1
		move.w	obY(a0),d2
		sub.w	obX(a1),d1
		sub.w	obY(a1),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#$F900,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a1)
		muls.w	#$F900,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a1)
		bset	#1,obStatus(a1)
		bclr	#4,obStatus(a1)
		bclr	#5,obStatus(a1)
		clr.b	$3C(a1)
		move.b	#1,obAnim(a0)
		move.w	#sfx_Bumper,d0
		jsr	(PlaySound_Special).l
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_1394E
		cmpi.b	#$8A,2(a2,d0.w)
		bcc.s	locret_13974
		addq.b	#1,2(a2,d0.w)

loc_1394E:
		moveq	#1,d0
		jsr	(AddPoints).l
		bsr.w	FindFreeObj
		bne.s	locret_13974
		_move.b	#$29,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#4,obFrame(a1)

locret_13974:
		rts
; End of function S1Obj47_Bump

; ---------------------------------------------------------------------------

loc_13976:
		lea	(Ani_S1Obj47).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------
Ani_S1Obj47:	dc.w byte_13988-Ani_S1Obj47
		dc.w byte_1398B-Ani_S1Obj47
byte_13988:	dc.b  $F,  0,$FF			; 0
byte_1398B:	dc.b   3,  1,  2,  1,  2,$FD,  0	; 0
Map_S1Obj47:	dc.w word_13998-Map_S1Obj47
		dc.w word_139AA-Map_S1Obj47
		dc.w word_139BC-Map_S1Obj47
word_13998:	dc.w 2
		dc.w $F007,    0,    0,$FFF0		; 0
		dc.w $F007, $800, $800,	   0		; 4
word_139AA:	dc.w 2
		dc.w $F406,    8,    4,$FFF4		; 0
		dc.w $F402, $808, $804,	   4		; 4
word_139BC:	dc.w 2
		dc.w $F007,   $E,    7,$FFF0		; 0
		dc.w $F007, $80E, $807,	   0		; 4
; ---------------------------------------------------------------------------
		nop

S1Obj64:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	S1Obj64_Index(pc,d0.w),d1
		jmp	S1Obj64_Index(pc,d1.w)
; ---------------------------------------------------------------------------
S1Obj64_Index:	dc.w S1Obj64_Init-S1Obj64_Index
		dc.w S1Obj64_Animate-S1Obj64_Index
		dc.w S1Obj64_ChkWater-S1Obj64_Index
		dc.w S1Obj64_Display-S1Obj64_Index
		dc.w S1Obj64_Delete-S1Obj64_Index
		dc.w S1Obj64_BblMaker-S1Obj64_Index
; ---------------------------------------------------------------------------

S1Obj64_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj0A_Bubbles,obMap(a0)
		move.w	#$8348,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#$84,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#1,obPriority(a0)
		move.b	obSubtype(a0),d0
		bpl.s	loc_13A32
		addq.b	#8,obRoutine(a0)
		andi.w	#$7F,d0
		move.b	d0,$32(a0)
		move.b	d0,$33(a0)
		move.b	#6,obAnim(a0)
		bra.w	S1Obj64_BblMaker
; ---------------------------------------------------------------------------

loc_13A32:
		move.b	d0,obAnim(a0)
		move.w	obX(a0),$30(a0)
		move.w	#$FF78,obVelY(a0)
		jsr	(RandomNumber).l
		move.b	d0,obAngle(a0)

S1Obj64_Animate:
		lea	(Ani_S1Obj64).l,a1
		jsr	(AnimateSprite).l
		cmpi.b	#6,obFrame(a0)
		bne.s	S1Obj64_ChkWater
		move.b	#1,$2E(a0)

S1Obj64_ChkWater:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bcs.s	loc_13A7E

loc_13A70:
		move.b	#6,obRoutine(a0)
		addq.b	#3,obAnim(a0)
		bra.w	S1Obj64_Display
; ---------------------------------------------------------------------------

loc_13A7E:
		move.b	obAngle(a0),d0
		addq.b	#1,obAngle(a0)
		andi.w	#$7F,d0
		lea	(Obj0A_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$30(a0),d0
		move.w	d0,obX(a0)
		tst.b	$2E(a0)
		beq.s	loc_13B0A
		bsr.w	S1Obj64_ChkSonic
		beq.s	loc_13B0A
		bsr.w	ResumeMusic
		move.w	#sfx_Bubble,d0
		jsr	(PlaySound_Special).l
		lea	(v_objspace).w,a1
		clr.w	obVelX(a1)
		clr.w	obVelY(a1)
		clr.w	obInertia(a1)
		move.b	#$15,obAnim(a1)
		move.w	#$23,$2E(a1)
		move.b	#0,$3C(a1)
		bclr	#5,obStatus(a1)
		bclr	#4,obStatus(a1)
		btst	#2,obStatus(a1)
		beq.w	loc_13A70
		bclr	#2,obStatus(a1)
		move.b	#$13,obHeight(a1)
		move.b	#9,obWidth(a1)
		subq.w	#5,obY(a1)
		bra.w	loc_13A70
; ---------------------------------------------------------------------------

loc_13B0A:
		bsr.w	ObjectMove
		tst.b	obRender(a0)
		bpl.s	loc_13B1A
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_13B1A:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

S1Obj64_Display:
		lea	(Ani_S1Obj64).l,a1
		jsr	(AnimateSprite).l
		tst.b	obRender(a0)
		bpl.s	loc_13B38
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_13B38:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

S1Obj64_Delete:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------

S1Obj64_BblMaker:
		tst.w	$36(a0)
		bne.s	loc_13BA4
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bcc.w	loc_13C50
		tst.b	obRender(a0)
		bpl.w	loc_13C50
		subq.w	#1,$38(a0)
		bpl.w	loc_13C44
		move.w	#1,$36(a0)

loc_13B6A:
		jsr	(RandomNumber).l
		move.w	d0,d1
		andi.w	#7,d0
		cmpi.w	#6,d0
		bcc.s	loc_13B6A
		move.b	d0,$34(a0)
		andi.w	#$C,d1
		lea	(S1Obj64_BblTypes).l,a1
		adda.w	d1,a1
		move.l	a1,$3C(a0)
		subq.b	#1,$32(a0)
		bpl.s	loc_13BA2
		move.b	$33(a0),$32(a0)
		bset	#7,$36(a0)

loc_13BA2:
		bra.s	loc_13BAC
; ---------------------------------------------------------------------------

loc_13BA4:
		subq.w	#1,$38(a0)
		bpl.w	loc_13C44

loc_13BAC:
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		move.w	d0,$38(a0)
		bsr.w	FindFreeObj
		bne.s	loc_13C28
		_move.b	#$64,obID(a1)
		move.w	obX(a0),obX(a1)
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	d0,obX(a1)
		move.w	obY(a0),obY(a1)
		moveq	#0,d0
		move.b	$34(a0),d0
		movea.l	$3C(a0),a2
		move.b	(a2,d0.w),obSubtype(a1)
		btst	#7,$36(a0)
		beq.s	loc_13C28
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	loc_13C14
		bset	#6,$36(a0)
		bne.s	loc_13C28
		move.b	#2,obSubtype(a1)

loc_13C14:
		tst.b	$34(a0)
		bne.s	loc_13C28
		bset	#6,$36(a0)
		bne.s	loc_13C28
		move.b	#2,obSubtype(a1)

loc_13C28:
		subq.b	#1,$34(a0)
		bpl.s	loc_13C44
		jsr	(RandomNumber).l
		andi.w	#$7F,d0
		addi.w	#$80,d0
		add.w	d0,$38(a0)
		clr.w	$36(a0)

loc_13C44:
		lea	(Ani_S1Obj64).l,a1
		jsr	(AnimateSprite).l

loc_13C50:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bcs.w	DisplaySprite
		rts
; ---------------------------------------------------------------------------
S1Obj64_BblTypes:dc.b	0,  1,	0,  0,	0,  0,	1,  0,	0 ; 0
		dc.b   0,  0,  1,  0,  1,  0,  0,  1,  0 ; 9

; =============== S U B	R O U T	I N E =======================================


S1Obj64_ChkSonic:
		tst.b	(f_playerctrl).w
		bmi.s	loc_13CBE
		lea	(v_objspace).w,a1
		move.w	obX(a1),d0
		move.w	obX(a0),d1
		subi.w	#$10,d1
		cmp.w	d0,d1
		bcc.s	loc_13CBE
		addi.w	#$20,d1
		cmp.w	d0,d1
		bcs.s	loc_13CBE
		move.w	obY(a1),d0
		move.w	obY(a0),d1
		cmp.w	d0,d1
		bcc.s	loc_13CBE
		addi.w	#$10,d1
		cmp.w	d0,d1
		bcs.s	loc_13CBE
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

loc_13CBE:
		moveq	#0,d0
		rts
; End of function S1Obj64_ChkSonic

; ---------------------------------------------------------------------------
Ani_S1Obj64:	dc.w byte_13CD0-Ani_S1Obj64
		dc.w byte_13CD5-Ani_S1Obj64
		dc.w byte_13CDB-Ani_S1Obj64
		dc.w byte_13CE2-Ani_S1Obj64
		dc.w byte_13CE2-Ani_S1Obj64
		dc.w byte_13CE4-Ani_S1Obj64
		dc.w byte_13CE9-Ani_S1Obj64
byte_13CD0:	dc.b  $E,  0,  1,  2,$FC		; 0
byte_13CD5:	dc.b  $E,  1,  2,  3,  4,$FC		; 0
byte_13CDB:	dc.b  $E,  2,  3,  4,  5,  6,$FC	; 0
byte_13CE2:	dc.b   4,$FC				; 0
byte_13CE4:	dc.b   4,  6,  7,  8,$FC		; 0
byte_13CE9:	dc.b  $F,$13,$14,$15,$FF		; 0
Map_Obj0A_Bubbles:dc.w word_13D1C-Map_Obj0A_Bubbles
		dc.w word_13D26-Map_Obj0A_Bubbles
		dc.w word_13D30-Map_Obj0A_Bubbles
		dc.w word_13D3A-Map_Obj0A_Bubbles
		dc.w word_13D44-Map_Obj0A_Bubbles
		dc.w word_13D4E-Map_Obj0A_Bubbles
		dc.w word_13D58-Map_Obj0A_Bubbles
		dc.w word_13D62-Map_Obj0A_Bubbles
		dc.w word_13D84-Map_Obj0A_Bubbles
		dc.w word_13DA6-Map_Obj0A_Bubbles
		dc.w word_13DB0-Map_Obj0A_Bubbles
		dc.w word_13DBA-Map_Obj0A_Bubbles
		dc.w word_13DC4-Map_Obj0A_Bubbles
		dc.w word_13DCE-Map_Obj0A_Bubbles
		dc.w word_13DD8-Map_Obj0A_Bubbles
		dc.w word_13DE2-Map_Obj0A_Bubbles
		dc.w word_13DEC-Map_Obj0A_Bubbles
		dc.w word_13DF6-Map_Obj0A_Bubbles
		dc.w word_13E00-Map_Obj0A_Bubbles
		dc.w word_13E0A-Map_Obj0A_Bubbles
		dc.w word_13E14-Map_Obj0A_Bubbles
		dc.w word_13E1E-Map_Obj0A_Bubbles
		dc.w word_13E28-Map_Obj0A_Bubbles
word_13D1C:	dc.w 1
		dc.w $FC00,    0,    0,$FFFC		; 0
word_13D26:	dc.w 1
		dc.w $FC00,    1,    0,$FFFC		; 0
word_13D30:	dc.w 1
		dc.w $FC00,    2,    1,$FFFC		; 0
word_13D3A:	dc.w 1
		dc.w $F805,    3,    1,$FFF8		; 0
word_13D44:	dc.w 1
		dc.w $F805,    7,    3,$FFF8		; 0
word_13D4E:	dc.w 1
		dc.w $F40A,   $B,    5,$FFF4		; 0
word_13D58:	dc.w 1
		dc.w $F00F,  $14,   $A,$FFF0		; 0
word_13D62:	dc.w 4
		dc.w $F005,  $24,  $12,$FFF0		; 0
		dc.w $F005, $824, $812,	   0		; 4
		dc.w	 5,$1024,$1012,$FFF0		; 8
		dc.w	 5,$1824,$1812,	   0		; 12
word_13D84:	dc.w 4
		dc.w $F005,  $28,  $14,$FFF0		; 0
		dc.w $F005, $828, $814,	   0		; 4
		dc.w	 5,$1028,$1014,$FFF0		; 8
		dc.w	 5,$1828,$1814,	   0		; 12
word_13DA6:	dc.w 1
		dc.w $F406,  $2C,  $16,$FFF8		; 0
word_13DB0:	dc.w 1
		dc.w $F406,  $32,  $19,$FFF8		; 0
word_13DBA:	dc.w 1
		dc.w $F406,  $38,  $1C,$FFF8		; 0
word_13DC4:	dc.w 1
		dc.w $F406,  $3E,  $1F,$FFF8		; 0
word_13DCE:	dc.w 1
		dc.w $F406,$2044,$2022,$FFF8		; 0
word_13DD8:	dc.w 1
		dc.w $F406,$204A,$2025,$FFF8		; 0
word_13DE2:	dc.w 1
		dc.w $F406,$2050,$2028,$FFF8		; 0
word_13DEC:	dc.w 1
		dc.w $F406,$2056,$202B,$FFF8		; 0
word_13DF6:	dc.w 1
		dc.w $F406,$205C,$202E,$FFF8		; 0
word_13E00:	dc.w 1
		dc.w $F406,$2062,$2031,$FFF8		; 0
word_13E0A:	dc.w 1
		dc.w $F805,  $68,  $34,$FFF8		; 0
word_13E14:	dc.w 1
		dc.w $F805,  $6C,  $36,$FFF8		; 0
word_13E1E:	dc.w 1
		dc.w $F805,  $70,  $38,$FFF8		; 0
word_13E28:	dc.w 0
; ---------------------------------------------------------------------------
		nop
;----------------------------------------------------
; Object 03 - collision	index switcher (in loops)
;----------------------------------------------------

Obj03:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj03_Index(pc,d0.w),d1
		jsr	Obj03_Index(pc,d1.w)
		tst.w	(Debug_mode_flag).w
		beq.w	MarkObjGone2
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------
Obj03_Index:	dc.w Obj03_Init-Obj03_Index
		dc.w loc_13EB4-Obj03_Index
		dc.w loc_13FB6-Obj03_Index
; ---------------------------------------------------------------------------

Obj03_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj03,obMap(a0)
		move.w	#$26BC,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#5,obPriority(a0)
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	loc_13EA4
		addq.b	#2,obRoutine(a0)
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	Obj03_Data(pc,d0.w),$32(a0)
		bra.w	loc_13FB6
; ---------------------------------------------------------------------------
Obj03_Data:	dc.w   $20,  $40,  $80,	$100		; 0
; ---------------------------------------------------------------------------

loc_13EA4:
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	Obj03_Data(pc,d0.w),$32(a0)

loc_13EB4:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_13FB4
		move.w	$30(a0),d5
		move.w	obX(a0),d0
		move.w	d0,d1
		subq.w	#8,d0
		addq.w	#8,d1
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		lea	(dword_140B8).l,a2
		moveq	#7,d6

loc_13EE0:
		move.l	(a2)+,d4
		beq.w	loc_13FA8
		movea.l	d4,a1
		move.w	obX(a1),d4
		cmp.w	d0,d4
		bcs.w	loc_13F10
		cmp.w	d1,d4
		bcc.w	loc_13F10
		move.w	obY(a1),d4
		cmp.w	d2,d4
		bcs.w	loc_13F10
		cmp.w	d3,d4
		bcc.w	loc_13F10
		ori.w	#$8000,d5
		bra.w	loc_13FA8
; ---------------------------------------------------------------------------

loc_13F10:
		tst.w	d5
		bpl.w	loc_13FA8
		swap	d0
		move.b	obSubtype(a0),d0
		bpl.s	loc_13F26
		btst	#1,obStatus(a1)
		bne.s	loc_13FA2

loc_13F26:
		move.w	obX(a1),d4
		cmp.w	obX(a0),d4
		bcs.s	loc_13F62
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)
		btst	#3,d0
		beq.s	loc_13F4E
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_13F4E:
		bclr	#7,2(a1)
		btst	#5,d0
		beq.s	loc_13F92
		bset	#7,2(a1)
		bra.s	loc_13F92
; ---------------------------------------------------------------------------

loc_13F62:
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)
		btst	#4,d0
		beq.s	loc_13F80
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_13F80:
		bclr	#7,2(a1)
		btst	#6,d0
		beq.s	loc_13F92
		bset	#7,2(a1)

loc_13F92:
		tst.w	(Debug_mode_flag).w
		beq.s	loc_13FA2
		move.w	#sfx_Lamppost,d0
		jsr	(PlaySound_Special).l

loc_13FA2:
		swap	d0
		andi.w	#$7FFF,d5

loc_13FA8:
		add.l	d5,d5
		dbf	d6,loc_13EE0
		swap	d5
		move.b	d5,$30(a0)

locret_13FB4:
		rts
; ---------------------------------------------------------------------------

loc_13FB6:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_140B6
		move.w	$30(a0),d5
		move.w	obX(a0),d0
		move.w	d0,d1
		move.w	$32(a0),d4
		sub.w	d4,d0
		add.w	d4,d1
		move.w	obY(a0),d2
		move.w	d2,d3
		subq.w	#8,d2
		addq.w	#8,d3
		lea	(dword_140B8).l,a2
		moveq	#7,d6

loc_13FE2:
		move.l	(a2)+,d4
		beq.w	loc_140AA
		movea.l	d4,a1
		move.w	obX(a1),d4
		cmp.w	d0,d4
		bcs.w	loc_14012
		cmp.w	d1,d4
		bcc.w	loc_14012
		move.w	obY(a1),d4
		cmp.w	d2,d4
		bcs.w	loc_14012
		cmp.w	d3,d4
		bcc.w	loc_14012
		ori.w	#$8000,d5
		bra.w	loc_140AA
; ---------------------------------------------------------------------------

loc_14012:
		tst.w	d5
		bpl.w	loc_140AA
		swap	d0
		move.b	obSubtype(a0),d0
		bpl.s	loc_14028
		btst	#1,obStatus(a1)
		bne.s	loc_140A4

loc_14028:
		move.w	obY(a1),d4
		cmp.w	obY(a0),d4
		bcs.s	loc_14064
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)
		btst	#3,d0
		beq.s	loc_14050
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_14050:
		bclr	#7,2(a1)
		btst	#5,d0
		beq.s	loc_14094
		bset	#7,2(a1)
		bra.s	loc_14094
; ---------------------------------------------------------------------------

loc_14064:
		move.b	#$C,$3E(a1)
		move.b	#$D,$3F(a1)
		btst	#4,d0
		beq.s	loc_14082
		move.b	#$E,$3E(a1)
		move.b	#$F,$3F(a1)

loc_14082:
		bclr	#7,2(a1)
		btst	#6,d0
		beq.s	loc_14094
		bset	#7,2(a1)

loc_14094:
		tst.w	(Debug_mode_flag).w
		beq.s	loc_140A4
		move.w	#sfx_Lamppost,d0
		jsr	(PlaySound_Special).l

loc_140A4:
		swap	d0
		andi.w	#$7FFF,d5

loc_140AA:
		add.l	d5,d5
		dbf	d6,loc_13FE2
		swap	d5
		move.b	d5,$30(a0)

locret_140B6:
		rts
; ---------------------------------------------------------------------------
dword_140B8:	dc.l v_objspace
		dc.l v_objspace+$40
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_Obj03:	binclude	"mappings/sprite/obj03.bin"

; ===========================================================================

Obj0B:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj0B_Index(pc,d0.w),d1
		jmp	Obj0B_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj0B_Index:	dc.w loc_141C8-Obj0B_Index
		dc.w loc_1421C-Obj0B_Index
		dc.w loc_1422A-Obj0B_Index
; ---------------------------------------------------------------------------

loc_141C8:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj0B,obMap(a0)
		move.w	#$E000,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#4,obPriority(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F0,d0
		addi.w	#$10,d0
		move.w	d0,d1
		subq.w	#1,d0
		move.w	d0,$30(a0)
		move.w	d0,$32(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		addq.w	#1,d0
		lsl.w	#4,d0
		move.b	d0,$36(a0)

loc_1421C:
		move.b	($FFFFFE0F).w,d0
		add.b	$36(a0),d0
		bne.s	loc_14254
		addq.b	#2,obRoutine(a0)

loc_1422A:
		subq.w	#1,$30(a0)
		bpl.s	loc_14248
		move.w	#$7F,$30(a0)
		tst.b	obAnim(a0)
		beq.s	loc_14242
		move.w	$32(a0),$30(a0)

loc_14242:
		bchg	#0,obAnim(a0)

loc_14248:
		lea	(off_1428A).l,a1
		jsr	(AnimateSprite).l

loc_14254:
		tst.b	obFrame(a0)
		bne.s	loc_1426E
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#$11,d3
		move.w	obX(a0),d4
		bsr.w	sub_F78A
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------

loc_1426E:
		btst	#3,obStatus(a0)
		beq.s	loc_14286
		lea	(v_objspace).w,a1
		bclr	#3,obStatus(a1)
		bclr	#3,obStatus(a0)

loc_14286:
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------
off_1428A:	dc.w byte_1428E-off_1428A
		dc.w byte_14296-off_1428A
byte_1428E:	dc.b   7,  0,  1,  2,  3,  4,$FE,  1	; 0
byte_14296:	dc.b   7,  4,  3,  2,  1,  0,$FE,  1	; 0
Map_Obj0B:	dc.w word_142A8-Map_Obj0B
		dc.w word_142B2-Map_Obj0B
		dc.w word_142BC-Map_Obj0B
		dc.w word_142C6-Map_Obj0B
		dc.w word_142D0-Map_Obj0B
word_142A8:	dc.w 1
		dc.w $F00C,  $11,    8,$FFF0		; 0
word_142B2:	dc.w 1
		dc.w $E80F,  $15,   $A,$FFF0		; 0
word_142BC:	dc.w 1
		dc.w $F40F,  $25,  $12,$FFF0		; 0
word_142C6:	dc.w 1
		dc.w	$F,$1015,$100A,$FFF0		; 0
word_142D0:	dc.w 1
		dc.w $100C,$1011,$1008,$FFF0		; 0
; ---------------------------------------------------------------------------
		nop

Obj0C:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj0C_Index(pc,d0.w),d1
		jmp	Obj0C_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj0C_Index:	dc.w Obj0C_Init-Obj0C_Index
		dc.w Obj0C_Main-Obj0C_Index
; ---------------------------------------------------------------------------

Obj0C_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj0C,obMap(a0)
		move.w	#$E418,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#4,obPriority(a0)
		move.w	obY(a0),d0
		subi.w	#$10,d0
		move.w	d0,$3A(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F0,d0
		addi.w	#$10,d0
		move.w	d0,d1
		subq.w	#1,d0
		move.w	d0,$30(a0)
		move.w	d0,$32(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		move.b	d0,$3E(a0)
		move.b	d0,$3F(a0)

Obj0C_Main:
		move.b	$3C(a0),d0
		beq.s	loc_1438C
		cmpi.b	#$80,d0
		bne.s	loc_1439C
		move.b	$3D(a0),d1
		bne.s	loc_1436E
		subq.b	#1,$3E(a0)
		bpl.s	loc_1436E
		move.b	$3F(a0),$3E(a0)
		bra.s	loc_1439C
; ---------------------------------------------------------------------------

loc_1436E:
		addq.b	#1,$3D(a0)
		move.b	d1,d0
		bsr.w	j_CalcSine
		addi.w	#8,d0
		asr.w	#6,d0
		subi.w	#$10,d0
		add.w	$3A(a0),d0
		move.w	d0,obY(a0)
		bra.s	loc_143B2
; ---------------------------------------------------------------------------

loc_1438C:
		move.w	($FFFFFE0E).w,d1
		andi.w	#$3FF,d1
		bne.s	loc_143A0
		move.b	#1,$3D(a0)

loc_1439C:
		addq.b	#1,$3C(a0)

loc_143A0:
		bsr.w	j_CalcSine
		addi.w	#8,d1
		asr.w	#4,d1
		add.w	$3A(a0),d1
		move.w	d1,obY(a0)

loc_143B2:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#9,d3
		move.w	obX(a0),d4
		bsr.w	sub_F78A
		bra.w	MarkObjGone
; ---------------------------------------------------------------------------
Map_Obj0C:	dc.w word_143C8-Map_Obj0C
word_143C8:	dc.w 1
		dc.w $F80D,    0,    0,$FFF0		; 0
; ---------------------------------------------------------------------------
		nop

j_CalcSine:
		jmp	(CalcSine).l
; ---------------------------------------------------------------------------
		align 4
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
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Map_Obj12:	dc.w word_14444-Map_Obj12
word_14444:	dc.w 2
		dc.w $F00F,    0,    0,$FFE0		; 0
		dc.w $F00F,  $10,    8,	   0		; 4
; ---------------------------------------------------------------------------
		nop
;----------------------------------------------------
; Object 13 - HPZ waterfall
;----------------------------------------------------

Obj13:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj13_Index(pc,d0.w),d1
		jmp	Obj13_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj13_Index:	dc.w loc_1446C-Obj13_Index
		dc.w loc_14532-Obj13_Index
		dc.w loc_145BC-Obj13_Index
; ---------------------------------------------------------------------------

loc_1446C:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj13,obMap(a0)
		move.w	#$E315,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.b	#1,obPriority(a0)
		move.b	#$12,obFrame(a0)
		bsr.s	sub_144D4
		move.b	#$A0,obHeight(a1)
		bset	#4,obRender(a1)
		move.l	a1,$38(a0)
		move.w	obY(a0),$34(a0)
		move.w	obY(a0),$36(a0)
		cmpi.b	#$10,obSubtype(a0)
		bcs.s	loc_14518
		bsr.s	sub_144D4
		move.l	a1,$3C(a0)
		move.w	obY(a0),obY(a1)
		addi.w	#$98,obY(a1)
		bra.s	loc_14518

; =============== S U B	R O U T	I N E =======================================


sub_144D4:
		jsr	(FindNextFreeObj).l
		bne.s	locret_14516
		_move.b	#$13,obID(a1)
		addq.b	#4,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Obj13,obMap(a1)
		move.w	#$E315,obGfx(a1)
		bsr.w	Adjust2PArtPointer2
		move.b	#4,obRender(a1)
		move.b	#$10,obActWid(a1)
		move.b	#1,obPriority(a1)

locret_14516:
		rts
; End of function sub_144D4

; ---------------------------------------------------------------------------

loc_14518:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		move.w	$34(a0),d0
		subi.w	#$78,d0
		lsl.w	#4,d1
		add.w	d1,d0
		move.w	d0,obY(a0)
		move.w	d0,$34(a0)

loc_14532:
		movea.l	$38(a0),a1
		move.b	#$12,obFrame(a0)
		move.w	$34(a0),d0
		move.w	(v_waterpos1).w,d1
		cmp.w	d0,d1
		bcc.s	loc_1454A
		move.w	d1,d0

loc_1454A:
		move.w	d0,obY(a0)
		sub.w	$36(a0),d0
		addi.w	#$80,d0
		bmi.s	loc_1459C
		lsr.w	#4,d0
		move.w	d0,d1
		cmpi.w	#$F,d0
		bcs.s	loc_14564
		moveq	#$F,d0

loc_14564:
		move.b	d0,obFrame(a1)
		cmpi.b	#$10,obSubtype(a0)
		bcs.s	loc_14584
		movea.l	$3C(a0),a1
		subi.w	#$F,d1
		bcc.s	loc_1457C
		moveq	#0,d1

loc_1457C:
		addi.w	#$13,d1
		move.b	d1,obFrame(a1)

loc_14584:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_1459C:
		moveq	#$13,d0
		move.b	d0,obFrame(a0)
		move.b	d0,obFrame(a1)
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ---------------------------------------------------------------------------

loc_145BC:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Map_Obj13:	dc.w word_1460E-Map_Obj13
		dc.w word_14618-Map_Obj13
		dc.w word_1462A-Map_Obj13
		dc.w word_1463C-Map_Obj13
		dc.w word_14656-Map_Obj13
		dc.w word_14670-Map_Obj13
		dc.w word_14692-Map_Obj13
		dc.w word_146B4-Map_Obj13
		dc.w word_146DE-Map_Obj13
		dc.w word_14708-Map_Obj13
		dc.w word_1473A-Map_Obj13
		dc.w word_1476C-Map_Obj13
		dc.w word_147A6-Map_Obj13
		dc.w word_147E0-Map_Obj13
		dc.w word_14822-Map_Obj13
		dc.w word_14864-Map_Obj13
		dc.w word_148AE-Map_Obj13
		dc.w word_148AE-Map_Obj13
		dc.w word_148AE-Map_Obj13
		dc.w word_1460C-Map_Obj13
		dc.w word_148C0-Map_Obj13
		dc.w word_148CA-Map_Obj13
		dc.w word_148D4-Map_Obj13
		dc.w word_148E6-Map_Obj13
		dc.w word_148F8-Map_Obj13
		dc.w word_14912-Map_Obj13
		dc.w word_1492C-Map_Obj13
		dc.w word_1494E-Map_Obj13
word_1460C:	dc.w 0
word_1460E:	dc.w 1
		dc.w $800C,  $10,    8,$FFF0		; 0
word_14618:	dc.w 2
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880D,  $2D,  $16,$FFF0		; 4
word_1462A:	dc.w 2
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
word_1463C:	dc.w 3
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80D,  $2D,  $16,$FFF0		; 8
word_14656:	dc.w 3
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
word_14670:	dc.w 4
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80D,  $2D,  $16,$FFF0		; 12
word_14692:	dc.w 4
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
word_146B4:	dc.w 5
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80D,  $2D,  $16,$FFF0		; 16
word_146DE:	dc.w 5
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
word_14708:	dc.w 6
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
		dc.w  $80D,  $2D,  $16,$FFF0		; 20
word_1473A:	dc.w 6
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
		dc.w  $80F,    0,    0,$FFF0		; 20
word_1476C:	dc.w 7
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
		dc.w  $80F,    0,    0,$FFF0		; 20
		dc.w $280D,  $2D,  $16,$FFF0		; 24
word_147A6:	dc.w 7
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
		dc.w  $80F,    0,    0,$FFF0		; 20
		dc.w $280F,    0,    0,$FFF0		; 24
word_147E0:	dc.w 8
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
		dc.w  $80F,    0,    0,$FFF0		; 20
		dc.w $280F,    0,    0,$FFF0		; 24
		dc.w $480D,  $2D,  $16,$FFF0		; 28
word_14822:	dc.w 8
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
		dc.w  $80F,    0,    0,$FFF0		; 20
		dc.w $280F,    0,    0,$FFF0		; 24
		dc.w $480F,    0,    0,$FFF0		; 28
word_14864:	dc.w 9
		dc.w $800C,  $10,    8,$FFF0		; 0
		dc.w $880F,    0,    0,$FFF0		; 4
		dc.w $A80F,    0,    0,$FFF0		; 8
		dc.w $C80F,    0,    0,$FFF0		; 12
		dc.w $E80F,    0,    0,$FFF0		; 16
		dc.w  $80F,    0,    0,$FFF0		; 20
		dc.w $280F,    0,    0,$FFF0		; 24
		dc.w $480F,    0,    0,$FFF0		; 28
		dc.w $680D,  $2D,  $16,$FFF0		; 32
word_148AE:	dc.w 2
		dc.w $F00A,  $18,   $C,$FFE8		; 0
		dc.w $F00A, $818, $80C,	   0		; 4
word_148C0:	dc.w 1
		dc.w $E00D,  $2D,  $16,$FFF0		; 0
word_148CA:	dc.w 1
		dc.w $E00F,    0,    0,$FFF0		; 0
word_148D4:	dc.w 2
		dc.w $E00F,    0,    0,$FFF0		; 0
		dc.w	$D,  $2D,  $16,$FFF0		; 4
word_148E6:	dc.w 2
		dc.w $E00F,    0,    0,$FFF0		; 0
		dc.w	$F,    0,    0,$FFF0		; 4
word_148F8:	dc.w 3
		dc.w $E00F,    0,    0,$FFF0		; 0
		dc.w	$F,    0,    0,$FFF0		; 4
		dc.w $200D,  $2D,  $16,$FFF0		; 8
word_14912:	dc.w 3
		dc.w $E00F,    0,    0,$FFF0		; 0
		dc.w	$F,    0,    0,$FFF0		; 4
		dc.w $200F,    0,    0,$FFF0		; 8
word_1492C:	dc.w 4
		dc.w $E00F,    0,    0,$FFF0		; 0
		dc.w	$F,    0,    0,$FFF0		; 4
		dc.w $200F,    0,    0,$FFF0		; 8
		dc.w $400D,  $2D,  $16,$FFF0		; 12
word_1494E:	dc.w 4
		dc.w $E00F,    0,    0,$FFF0		; 0
		dc.w	$F,    0,    0,$FFF0		; 4
		dc.w $200F,    0,    0,$FFF0		; 8
		dc.w $400F,    0,    0,$FFF0		; 12
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 06 - spiral loop in EHZ
;----------------------------------------------------

Obj06:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj06_Index(pc,d0.w),d1
		jsr	Obj06_Index(pc,d1.w)
		tst.w	(Two_player_mode).w
		beq.s	loc_14986
		rts
; ---------------------------------------------------------------------------

loc_14986:
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_1499A
		rts
; ---------------------------------------------------------------------------

loc_1499A:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------
Obj06_Index:	dc.w Obj06_Init-Obj06_Index
		dc.w Obj06_Main-Obj06_Index
; ---------------------------------------------------------------------------

Obj06_Init:
		addq.b	#2,obRoutine(a0)
		move.b	#$D0,obActWid(a0)

Obj06_Main:
		lea	(v_objspace).w,a1
		moveq	#3,d6
		bsr.s	sub_149BC
		lea	(v_objspace+$40).w,a1
		addq.b	#1,d6

; =============== S U B	R O U T	I N E =======================================


sub_149BC:
		btst	d6,obStatus(a0)
		bne.w	loc_14A56
		btst	#1,obStatus(a1)
		bne.w	locret_14A54
		btst	#3,obStatus(a1)
		bne.s	loc_14A16
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		tst.w	obVelX(a1)
		bmi.s	loc_149F2
		cmpi.w	#$FF40,d0
		bgt.s	locret_14A54
		cmpi.w	#$FF30,d0
		blt.s	locret_14A54
		bra.s	loc_149FE
; ---------------------------------------------------------------------------

loc_149F2:
		cmpi.w	#$C0,d0
		blt.s	locret_14A54
		cmpi.w	#$D0,d0
		bgt.s	locret_14A54

loc_149FE:
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		subi.w	#$10,d1
		cmpi.w	#$30,d1
		bcc.s	locret_14A54
		bsr.w	RideObject_SetRide
		rts
; ---------------------------------------------------------------------------

loc_14A16:
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		tst.w	obVelX(a1)
		bmi.s	loc_14A32
		cmpi.w	#$FF50,d0
		bgt.s	locret_14A54
		cmpi.w	#$FF40,d0
		blt.s	locret_14A54
		bra.s	loc_14A3E
; ---------------------------------------------------------------------------

loc_14A32:
		cmpi.w	#$B0,d0
		blt.s	locret_14A54
		cmpi.w	#$C0,d0
		bgt.s	locret_14A54

loc_14A3E:
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		subi.w	#$10,d1
		cmpi.w	#$30,d1
		bcc.s	locret_14A54
		bsr.w	RideObject_SetRide

locret_14A54:
		rts
; ---------------------------------------------------------------------------

loc_14A56:
		move.w	obInertia(a1),d0
		bpl.s	loc_14A5E
		neg.w	d0

loc_14A5E:
		cmpi.w	#$600,d0
		bcs.s	loc_14A80
		btst	#1,obStatus(a1)
		bne.s	loc_14A80
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		addi.w	#$D0,d0
		bmi.s	loc_14A80
		cmpi.w	#$1A0,d0
		bcs.s	loc_14A98

loc_14A80:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		move.b	#0,$2C(a1)
		move.b	#4,$2D(a1)
		rts
; ---------------------------------------------------------------------------

loc_14A98:
		btst	#3,obStatus(a1)
		beq.s	locret_14A54
		move.b	Obj06_PlayerDeltaYArray(pc,d0.w),d1
		ext.w	d1
		move.w	obY(a0),d2
		add.w	d1,d2
		moveq	#0,d1
		move.b	obHeight(a1),d1
		subi.w	#$13,d1
		sub.w	d1,d2
		move.w	d2,obY(a1)
		lsr.w	#3,d0
		andi.w	#$3F,d0
		move.b	Obj06_PlayerAngleArray(pc,d0.w),$27(a1)
		rts
; End of function sub_149BC

; ---------------------------------------------------------------------------
Obj06_PlayerAngleArray:dc.b   0,  0,  1,  1		; 0
		dc.b $16,$16,$16,$16			; 4
		dc.b $2C,$2C,$2C,$2C			; 8
		dc.b $42,$42,$42,$42			; 12
		dc.b $58,$58,$58,$58			; 16
		dc.b $6E,$6E,$6E,$6E			; 20
		dc.b $84,$84,$84,$84			; 24
		dc.b $9A,$9A,$9A,$9A			; 28
		dc.b $B0,$B0,$B0,$B0			; 32
		dc.b $C6,$C6,$C6,$C6			; 36
		dc.b $DC,$DC,$DC,$DC			; 40
		dc.b $F2,$F2,$F2,$F2			; 44
		dc.b   1,  1,  0,  0			; 48
Obj06_PlayerDeltaYArray:dc.b  $20, $20,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $20, $20 ; 0
		dc.b  $20, $20,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $1F, $1F ; 16
		dc.b  $1F, $1F,	$1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F,	$1F, $1F, $1F, $1E, $1E, $1E ; 32
		dc.b  $1E, $1E,	$1E, $1E, $1E, $1E, $1D, $1D, $1D, $1D,	$1D, $1C, $1C, $1C, $1C, $1B ; 48
		dc.b  $1B, $1B,	$1B, $1A, $1A, $1A, $19, $19, $19, $18,	$18, $18, $17, $17, $16, $16 ; 64
		dc.b  $15, $15,	$14, $14, $13, $12, $12, $11, $10, $10,	 $F,  $E,  $E,	$D,  $C,  $C ; 80
		dc.b   $B,  $A,	 $A,   9,   8,	 8,   7,   6,	6,   5,	  4,   4,   3,	 2,   2,   1 ; 96
		dc.b	0,  -1,	 -2,  -2,  -3,	-4,  -4,  -5,  -6,  -7,	 -7,  -8,  -9,	-9, -$A, -$A ; 112
		dc.b  -$B, -$B,	-$C, -$C, -$D, -$E, -$E, -$F, -$F,-$10,-$10,-$11,-$11,-$12,-$12,-$13 ; 128
		dc.b -$13,-$13,-$14,-$15,-$15,-$16,-$16,-$17,-$17,-$18,-$18,-$19,-$19,-$1A,-$1A,-$1B ; 144
		dc.b -$1B,-$1C,-$1C,-$1C,-$1D,-$1D,-$1E,-$1E,-$1E,-$1F,-$1F,-$1F,-$20,-$20,-$20,-$21 ; 160
		dc.b -$21,-$21,-$21,-$22,-$22,-$22,-$23,-$23,-$23,-$23,-$23,-$23,-$23,-$23,-$24,-$24 ; 176
		dc.b -$24,-$24,-$24,-$24,-$24,-$24,-$24,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25 ; 192
		dc.b -$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25 ; 208
		dc.b -$25,-$25,-$25,-$25,-$24,-$24,-$24,-$24,-$24,-$24,-$24,-$23,-$23,-$23,-$23,-$23 ; 224
		dc.b -$23,-$23,-$23,-$22,-$22,-$22,-$21,-$21,-$21,-$21,-$20,-$20,-$20,-$1F,-$1F,-$1F ; 240
		dc.b -$1E,-$1E,-$1E,-$1D,-$1D,-$1C,-$1C,-$1C,-$1B,-$1B,-$1A,-$1A,-$19,-$19,-$18,-$18 ; 256
		dc.b -$17,-$17,-$16,-$16,-$15,-$15,-$14,-$13,-$13,-$12,-$12,-$11,-$10,-$10, -$F, -$E ; 272
		dc.b  -$E, -$D,	-$C, -$B, -$B, -$A,  -9,  -8,  -7,  -7,	 -6,  -5,  -4,	-3,  -2,  -1 ; 288
		dc.b	0,   1,	  2,   3,   4,	 5,   6,   7,	8,   8,	  9,  $A,  $A,	$B,  $C,  $D ; 304
		dc.b   $D,  $E,	 $E,  $F,  $F, $10, $10, $11, $11, $12,	$12, $13, $13, $14, $14, $15 ; 320
		dc.b  $15, $16,	$16, $17, $17, $18, $18, $18, $19, $19,	$19, $19, $1A, $1A, $1A, $1A ; 336
		dc.b  $1B, $1B,	$1B, $1B, $1C, $1C, $1C, $1C, $1C, $1C,	$1D, $1D, $1D, $1D, $1D, $1D ; 352
		dc.b  $1D, $1E,	$1E, $1E, $1E, $1E, $1E, $1E, $1F, $1F,	$1F, $1F, $1F, $1F, $1F, $1F ; 368
		dc.b  $1F, $1F,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $20, $20 ; 384
		dc.b  $20, $20,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $20, $20 ; 400
; ---------------------------------------------------------------------------
		nop
;----------------------------------------------------
; Object 14 - HTZ see-saw
;----------------------------------------------------

Obj14:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj14_Index(pc,d0.w),d1
		jsr	Obj14_Index(pc,d1.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
Obj14_Index:	dc.w loc_14CD2-Obj14_Index
		dc.w loc_14D40-Obj14_Index
		dc.w locret_14DF2-Obj14_Index
		dc.w loc_14E3C-Obj14_Index
		dc.w loc_14E9C-Obj14_Index
		dc.w loc_14F30-Obj14_Index
; ---------------------------------------------------------------------------

loc_14CD2:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj14,obMap(a0)
		move.w	#$3CE,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#$30,obActWid(a0)
		move.w	obX(a0),$30(a0)
		tst.b	obSubtype(a0)
		bne.s	loc_14D2C
		bsr.w	FindNextFreeObj
		bne.s	loc_14D2C
		_move.b	#$14,obID(a1)
		addq.b	#6,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.l	a0,$3C(a1)

loc_14D2C:
		btst	#0,obStatus(a0)
		beq.s	loc_14D3A
		move.b	#2,obFrame(a0)

loc_14D3A:
		move.b	obFrame(a0),$3A(a0)

loc_14D40:
		move.b	$3A(a0),d1
		btst	#3,obStatus(a0)
		beq.s	loc_14D9A
		moveq	#2,d1
		lea	(v_objspace).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcc.s	loc_14D60
		neg.w	d0
		moveq	#0,d1

loc_14D60:
		cmpi.w	#8,d0
		bcc.s	loc_14D68
		moveq	#1,d1

loc_14D68:
		btst	#4,obStatus(a0)
		beq.s	loc_14DBE
		moveq	#2,d2
		lea	(v_objspace+$40).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcc.s	loc_14D84
		neg.w	d0
		moveq	#0,d2

loc_14D84:
		cmpi.w	#8,d0
		bcc.s	loc_14D8C
		moveq	#1,d2

loc_14D8C:
		add.w	d2,d1
		cmpi.w	#3,d1
		bne.s	loc_14D96
		addq.w	#1,d1

loc_14D96:
		lsr.w	#1,d1
		bra.s	loc_14DBE
; ---------------------------------------------------------------------------

loc_14D9A:
		btst	#4,obStatus(a0)
		beq.s	loc_14DBE
		moveq	#2,d1
		lea	(v_objspace+$40).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcc.s	loc_14DB6
		neg.w	d0
		moveq	#0,d1

loc_14DB6:
		cmpi.w	#8,d0
		bcc.s	loc_14DBE
		moveq	#1,d1

loc_14DBE:
		bsr.w	sub_14E10
		lea	(byte_14FFE).l,a2
		btst	#0,obFrame(a0)
		beq.s	loc_14DD6
		lea	(byte_1502F).l,a2

loc_14DD6:
		lea	(v_objspace).w,a1
		move.w	obVelY(a1),$38(a0)
		move.w	obX(a0),-(sp)
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#8,d3
		move.w	(sp)+,d4
		bra.w	sub_F7DC
; ---------------------------------------------------------------------------

locret_14DF2:
		rts
; ---------------------------------------------------------------------------
		moveq	#2,d1
		lea	(v_objspace).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcc.s	loc_14E08
		neg.w	d0
		moveq	#0,d1

loc_14E08:
		cmpi.w	#8,d0
		bcc.s	sub_14E10
		moveq	#1,d1

; =============== S U B	R O U T	I N E =======================================


sub_14E10:
		move.b	obFrame(a0),d0
		cmp.b	d1,d0
		beq.s	locret_14E3A
		bcc.s	loc_14E1C
		addq.b	#2,d0

loc_14E1C:
		subq.b	#1,d0
		move.b	d0,obFrame(a0)
		move.b	d1,$3A(a0)
		bclr	#0,obRender(a0)
		btst	#1,obFrame(a0)
		beq.s	locret_14E3A
		bset	#0,obRender(a0)

locret_14E3A:
		rts
; End of function sub_14E10

; ---------------------------------------------------------------------------

loc_14E3C:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj14b,obMap(a0)
		move.w	#$3CE,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#$8B,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.w	obX(a0),$30(a0)
		addi.w	#$28,obX(a0)
		addi.w	#$10,obY(a0)
		move.w	obY(a0),$34(a0)
		move.b	#1,obFrame(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_14E9C
		subi.w	#$50,obX(a0)
		move.b	#2,$3A(a0)

loc_14E9C:
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$3A(a0),d0
		sub.b	$3A(a1),d0
		beq.s	loc_14EF2
		bcc.s	loc_14EB0
		neg.b	d0

loc_14EB0:
		move.w	#$F7E8,d1
		move.w	#$FEEC,d2
		cmpi.b	#1,d0
		beq.s	loc_14ED6
		move.w	#$F510,d1
		move.w	#$FF34,d2
		cmpi.w	#$A00,$38(a1)
		blt.s	loc_14ED6
		move.w	#$F200,d1
		move.w	#$FF60,d2

loc_14ED6:
		move.w	d1,obVelY(a0)
		move.w	d2,obVelX(a0)
		move.w	obX(a0),d0
		sub.w	$30(a0),d0
		bcc.s	loc_14EEC
		neg.w	obVelX(a0)

loc_14EEC:
		addq.b	#2,obRoutine(a0)
		bra.s	loc_14F30
; ---------------------------------------------------------------------------

loc_14EF2:
		lea	(word_14FF4).l,a2
		moveq	#0,d0
		move.b	obFrame(a1),d0
		move.w	#$28,d2
		move.w	obX(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_14F10
		neg.w	d2
		addq.w	#2,d0

loc_14F10:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		move.w	d1,obY(a0)
		add.w	$30(a0),d2
		move.w	d2,obX(a0)
		clr.w	$E(a0)
		clr.w	$A(a0)
		rts
; ---------------------------------------------------------------------------

loc_14F30:
		tst.w	obVelY(a0)
		bpl.s	loc_14F4E
		bsr.w	j_ObjectMoveAndFall
		move.w	$34(a0),d0
		subi.w	#$2F,d0
		cmp.w	obY(a0),d0
		bgt.s	locret_14F4C
		bsr.w	j_ObjectMoveAndFall

locret_14F4C:
		rts
; ---------------------------------------------------------------------------

loc_14F4E:
		bsr.w	j_ObjectMoveAndFall
		movea.l	$3C(a0),a1
		lea	(word_14FF4).l,a2
		moveq	#0,d0
		move.b	obFrame(a1),d0
		move.w	obX(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_14F6E
		addq.w	#2,d0

loc_14F6E:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	obY(a0),d1
		bgt.s	locret_14FC2
		movea.l	$3C(a0),a1
		moveq	#2,d1
		tst.w	obVelX(a0)
		bmi.s	loc_14F8C
		moveq	#0,d1

loc_14F8C:
		move.b	d1,$3A(a1)
		move.b	d1,$3A(a0)
		cmp.b	obFrame(a1),d1
		beq.s	loc_14FB6
		lea	(v_objspace).w,a2
		bclr	#3,obStatus(a1)
		beq.s	loc_14FA8
		bsr.s	sub_14FC4

loc_14FA8:
		lea	(v_objspace+$40).w,a2
		bclr	#4,obStatus(a1)
		beq.s	loc_14FB6
		bsr.s	sub_14FC4

loc_14FB6:
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)
		subq.b	#2,obRoutine(a0)

locret_14FC2:
		rts

; =============== S U B	R O U T	I N E =======================================


sub_14FC4:
		move.w	obVelY(a0),obVelY(a2)
		neg.w	obVelY(a2)
		bset	#1,obStatus(a2)
		bclr	#3,obStatus(a2)
		clr.b	$3C(a2)
		move.b	#$10,obAnim(a2)
		move.b	#2,obRoutine(a2)
		move.w	#sfx_Spring,d0
		jmp	(PlaySound_Special).l
; End of function sub_14FC4

; ---------------------------------------------------------------------------
word_14FF4:	dc.w	 -8,  -$1C,  -$2F,  -$1C,    -8	; 0
byte_14FFE:	dc.b  $14, $14,	$16, $18, $1A, $1C, $1A	; 0
		dc.b  $18, $16,	$14, $13, $12, $11, $10	; 7
		dc.b   $F,  $E,	 $D,  $C,  $B,	$A,   9	; 14
		dc.b	8,   7,	  6,   5,   4,	 3,   2	; 21
		dc.b	1,   0,	 -1,  -2,  -3,	-4,  -5	; 28
		dc.b   -6,  -7,	 -8,  -9, -$A, -$B, -$C	; 35
		dc.b  -$D, -$E,	-$E, -$E, -$E, -$E, -$E	; 42
byte_1502F:	dc.b	5,   5,	  5,   5,   5,	 5,   5	; 0
		dc.b	5,   5,	  5,   5,   5,	 5,   5	; 7
		dc.b	5,   5,	  5,   5,   5,	 5,   5	; 14
		dc.b	5,   5,	  5,   5,   5,	 5,   5	; 21
		dc.b	5,   5,	  5,   5,   5,	 5,   5	; 28
		dc.b	5,   5,	  5,   5,   5,	 5,   5	; 35
		dc.b	5,   5,	  5,   5,   5,	 5,   0	; 42
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Map_obj14:	binclude	"mappings/sprite/obj14_a.bin"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Map_obj14b:	binclude	"mappings/sprite/obj14_b.bin"

; ---------------------------------------------------------------------------
		nop

j_ObjectMoveAndFall:
		jmp	(ObjectMoveAndFall).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 16 - the HTZ platform that goes down diagonally
;	      and stops	after a	while (in final, it falls)
;----------------------------------------------------

Obj16:
		moveq	#0,d0

loc_15106:
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
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_152AA
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
; ---------------------------------------------------------------------------
Map_Obj16:	dc.w word_151DA-Map_Obj16
		dc.w word_1522C-Map_Obj16
		dc.w word_15246-Map_Obj16
		dc.w word_15260-Map_Obj16
word_151DA:	dc.w $A
		dc.w $C105,    0,    0,$FFE4		; 0
		dc.w $D003,    4,    2,$FFE6		; 4
		dc.w $F003,    4,    2,$FFE6		; 8
		dc.w $1001,    8,    4,$FFE7		; 12
		dc.w $D505,   $A,    5,	  $C		; 16
		dc.w $E003,   $E,    7,	 $11		; 20
		dc.w $1001,  $12,    9,	 $11		; 24
		dc.w	 3,   $E,    7,	 $11		; 28
		dc.w $200D,  $14,   $A,$FFE0		; 32
		dc.w $200D, $814, $80A,	   0		; 36
word_1522C:	dc.w 3
		dc.w $D805,  $1C,   $E,$FFF8		; 0
		dc.w $E807,  $20,  $10,$FFF8		; 4
		dc.w  $807,  $20,  $10,$FFF8		; 8
word_15246:	dc.w 3
		dc.w $D805,  $28,  $14,$FFF8		; 0
		dc.w $E807, $820, $810,$FFF8		; 4
		dc.w  $807, $820, $810,$FFF8		; 8
word_15260:	dc.w 8
		dc.w $C905,    0,    0,$FFE4		; 0
		dc.w $D803,    4,    2,$FFE6		; 4
		dc.w $F803,    4,    2,$FFE6		; 8
		dc.w $1801,  $2C,  $16,$FFE6		; 12
		dc.w $DD05,   $A,    5,	  $C		; 16
		dc.w $E803,   $E,    7,	 $11		; 20
		dc.w $2001,  $2E,  $17,	 $11		; 24
		dc.w  $803,   $E,    7,	 $11		; 28
; ---------------------------------------------------------------------------
		nop

loc_152A4:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_152AA:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

j_ObjectMove_0:
		jmp	(ObjectMove).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 19 - CPZ platforms moving side	to side
;----------------------------------------------------

Obj19:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj19_Index(pc,d0.w),d1
		jmp	Obj19_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj19_Index:	dc.w Obj19_Init-Obj19_Index
		dc.w Obj19_Main-Obj19_Index
Obj19_WidthArray:dc.w $2000				; 0
		dc.w $2001				; 1
		dc.w $2002				; 2
		dc.w $4003				; 3
		dc.w $3004				; 4
; ---------------------------------------------------------------------------

Obj19_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj19,obMap(a0)
		move.w	#$6400,obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj19_WidthArray(pc,d0.w),a2
		move.b	(a2)+,obActWid(a0)
		move.b	(a2)+,obFrame(a0)
		move.b	#4,obPriority(a0)
		move.w	obX(a0),$30(a0)
		move.w	obY(a0),$32(a0)
		andi.b	#$F,obSubtype(a0)

Obj19_Main:
		move.w	obX(a0),-(sp)
		bsr.w	Obj19_Modes
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	#$10,d3
		move.w	(sp)+,d4
		bsr.w	sub_F78A
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_154C6
		bra.w	loc_154C0

; =============== S U B	R O U T	I N E =======================================


Obj19_Modes:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj19_SubIndex(pc,d0.w),d1
		jmp	Obj19_SubIndex(pc,d1.w)
; End of function Obj19_Modes

; ---------------------------------------------------------------------------
Obj19_SubIndex:	dc.w locret_1537A-Obj19_SubIndex
		dc.w loc_1537C-Obj19_SubIndex
		dc.w loc_1539C-Obj19_SubIndex
		dc.w loc_153AC-Obj19_SubIndex
		dc.w loc_1539C-Obj19_SubIndex
		dc.w loc_153CC-Obj19_SubIndex
		dc.w loc_153EC-Obj19_SubIndex
		dc.w loc_1540E-Obj19_SubIndex
		dc.w loc_15430-Obj19_SubIndex
		dc.w loc_1539C-Obj19_SubIndex
		dc.w loc_15450-Obj19_SubIndex
; ---------------------------------------------------------------------------

locret_1537A:
		rts
; ---------------------------------------------------------------------------

loc_1537C:
		move.b	($FFFFFE6C).w,d0
		move.w	#$60,d1
		btst	#0,obStatus(a0)
		beq.s	loc_15390
		neg.w	d0
		add.w	d1,d0

loc_15390:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,obX(a0)
		rts
; ---------------------------------------------------------------------------

loc_1539C:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		beq.s	locret_153AA
		addq.b	#1,obSubtype(a0)

locret_153AA:
		rts
; ---------------------------------------------------------------------------

loc_153AC:
		moveq	#0,d3
		move.b	obActWid(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1
		bmi.s	loc_153C6
		addq.w	#1,obX(a0)
		move.w	obX(a0),$30(a0)
		rts
; ---------------------------------------------------------------------------

loc_153C6:
		clr.b	obSubtype(a0)
		rts
; ---------------------------------------------------------------------------

loc_153CC:
		moveq	#0,d3
		move.b	obActWid(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1
		bmi.s	loc_153E6
		addq.w	#1,obX(a0)
		move.w	obX(a0),$30(a0)
		rts
; ---------------------------------------------------------------------------

loc_153E6:
		addq.b	#1,obSubtype(a0)
		rts
; ---------------------------------------------------------------------------

loc_153EC:
		bsr.w	j_ObjectMove_1
		addi.w	#$18,obVelY(a0)
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.w	locret_1540C
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	obSubtype(a0)

locret_1540C:
		rts
; ---------------------------------------------------------------------------

loc_1540E:
		tst.b	(f_switch+2).w
		beq.s	loc_15418
		subq.b	#3,obSubtype(a0)

loc_15418:
		addq.l	#6,sp
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_154C6
		rts
; ---------------------------------------------------------------------------

loc_15430:
		move.b	($FFFFFE7C).w,d0
		move.w	#$80,d1
		btst	#0,obStatus(a0)
		beq.s	loc_15444
		neg.w	d0
		add.w	d1,d0

loc_15444:
		move.w	$32(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)
		rts
; ---------------------------------------------------------------------------

loc_15450:
		moveq	#0,d3
		move.b	obActWid(a0),d3
		add.w	d3,d3
		moveq	#8,d1
		btst	#0,obStatus(a0)
		beq.s	loc_15466
		neg.w	d1
		neg.w	d3

loc_15466:
		tst.w	$36(a0)
		bne.s	loc_15492
		move.w	obX(a0),d0
		sub.w	$30(a0),d0
		cmp.w	d3,d0
		beq.s	loc_15484
		add.w	d1,obX(a0)
		move.w	#$12C,$34(a0)
		rts
; ---------------------------------------------------------------------------

loc_15484:
		subq.w	#1,$34(a0)
		bne.s	locret_15490
		move.w	#1,$36(a0)

locret_15490:
		rts
; ---------------------------------------------------------------------------

loc_15492:
		move.w	obX(a0),d0
		sub.w	$30(a0),d0
		beq.s	loc_154A2
		sub.w	d1,obX(a0)
		rts
; ---------------------------------------------------------------------------

loc_154A2:
		clr.w	$36(a0)
		subq.b	#1,obSubtype(a0)
		rts
; ---------------------------------------------------------------------------
Map_Obj19:	dc.w word_154AE-Map_Obj19
word_154AE:	dc.w 2
		dc.w $F00F,    0,    0,$FFE0		; 0
		dc.w $F00F, $800, $800,	   0		; 4
; ---------------------------------------------------------------------------

loc_154C0:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_154C6:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

j_ObjectMove_1:
		jmp	(ObjectMove).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 04 - water surface
;----------------------------------------------------

Obj04:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj04_Index(pc,d0.w),d1
		jmp	Obj04_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj04_Index:	dc.w Obj04_Init-Obj04_Index
		dc.w Obj04_Main-Obj04_Index
; ---------------------------------------------------------------------------

Obj04_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj04,obMap(a0)
		move.w	#$8400,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_0
		move.b	#4,obRender(a0)
		move.b	#$80,obActWid(a0)
		move.w	obX(a0),$30(a0)

Obj04_Main:
		move.w	(v_waterpos1).w,d1
		move.w	d1,obY(a0)
		tst.b	$32(a0)
		bne.s	loc_15530
		btst	#7,(v_jpadpress1).w
		beq.s	loc_15540
		addq.b	#3,obFrame(a0)
		move.b	#1,$32(a0)
		bra.s	loc_15540
; ---------------------------------------------------------------------------

loc_15530:
		tst.w	($FFFFF63A).w
		bne.s	loc_15540
		move.b	#0,$32(a0)
		subq.b	#3,obFrame(a0)

loc_15540:
		lea	(Obj04_FrameData).l,a1
		moveq	#0,d1
		move.b	obAniFrame(a0),d1
		move.b	(a1,d1.w),obFrame(a0)
		addq.b	#1,obAniFrame(a0)
		andi.b	#$3F,obAniFrame(a0)
		bra.w	loc_15868
; ---------------------------------------------------------------------------
Obj04_FrameData:dc.b   0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1 ; 0
		dc.b   1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2 ; 16
		dc.b   2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1 ; 32
		dc.b   1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0 ; 48
Map_Obj04:	dc.w word_155AC-Map_Obj04
		dc.w word_155C6-Map_Obj04
		dc.w word_155E0-Map_Obj04
		dc.w word_155FA-Map_Obj04
		dc.w word_1562C-Map_Obj04
		dc.w word_1565E-Map_Obj04
word_155AC:	dc.w 3
		dc.w $F80D,    0,    0,$FFA0		; 0
		dc.w $F80D,    0,    0,$FFE0		; 4
		dc.w $F80D,    0,    0,	 $20		; 8
word_155C6:	dc.w 3
		dc.w $F80D,    8,    4,$FFA0		; 0
		dc.w $F80D,    8,    4,$FFE0		; 4
		dc.w $F80D,    8,    4,	 $20		; 8
word_155E0:	dc.w 3
		dc.w $F80D,  $10,    8,$FFA0		; 0
		dc.w $F80D,  $10,    8,$FFE0		; 4
		dc.w $F80D,  $10,    8,	 $20		; 8
word_155FA:	dc.w 6
		dc.w $F80D,    0,    0,$FFA0		; 0
		dc.w $F80D,    8,    4,$FFC0		; 4
		dc.w $F80D,    0,    0,$FFE0		; 8
		dc.w $F80D,    8,    4,	   0		; 12
		dc.w $F80D,    0,    0,	 $20		; 16
		dc.w $F80D,    8,    4,	 $40		; 20
word_1562C:	dc.w 6
		dc.w $F80D,    8,    4,$FFA0		; 0
		dc.w $F80D,  $10,    8,$FFC0		; 4
		dc.w $F80D,    8,    4,$FFE0		; 8
		dc.w $F80D,  $10,    8,	   0		; 12
		dc.w $F80D,    8,    4,	 $20		; 16
		dc.w $F80D,  $10,    8,	 $40		; 20
word_1565E:	dc.w 6
		dc.w $F80D,  $10,    8,$FFA0		; 0
		dc.w $F80D,    8,    4,$FFC0		; 4
		dc.w $F80D,  $10,    8,$FFE0		; 8
		dc.w $F80D,    8,    4,	   0		; 12
		dc.w $F80D,  $10,    8,	 $20		; 16
		dc.w $F80D,    8,    4,	 $40		; 20
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 49 - EHZ waterfalls
;----------------------------------------------------

Obj49:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj49_Index(pc,d0.w),d1
		jmp	Obj49_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj49_Index:	dc.w Obj49_Init-Obj49_Index
		dc.w Obj49_Main-Obj49_Index
; ---------------------------------------------------------------------------

Obj49_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj49,obMap(a0)
		move.w	#$23AE,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_0
		move.b	#4,obRender(a0)
		move.b	#$20,obActWid(a0)
		move.w	obX(a0),$30(a0)
		move.b	#0,obPriority(a0)
		move.b	#$80,obHeight(a0)
		bset	#4,obRender(a0)

Obj49_Main:
		tst.w	(Two_player_mode).w
		bne.s	loc_156F6
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_1586E

loc_156F6:
		move.w	obX(a0),d1
		move.w	d1,d2
		subi.w	#$40,d1
		addi.w	#$40,d2
		move.b	obSubtype(a0),d3
		move.b	#0,obFrame(a0)
		move.w	(v_objspace+obX).w,d0
		cmp.w	d1,d0
		bcs.s	loc_15728
		cmp.w	d2,d0
		bcc.s	loc_15728
		move.b	#1,obFrame(a0)
		add.b	d3,obFrame(a0)
		bra.w	loc_15868
; ---------------------------------------------------------------------------

loc_15728:
		move.w	(v_objspace+$40+obX).w,d0
		cmp.w	d1,d0
		bcs.s	loc_1573A
		cmp.w	d2,d0
		bcc.s	loc_1573A
		move.b	#1,obFrame(a0)

loc_1573A:
		add.b	d3,obFrame(a0)
		bra.w	loc_15868
; ---------------------------------------------------------------------------
Map_Obj49:	dc.w word_1574E-Map_Obj49
		dc.w word_15760-Map_Obj49
		dc.w word_157F2-Map_Obj49
		dc.w word_157F4-Map_Obj49
		dc.w word_157F2-Map_Obj49
		dc.w word_15816-Map_Obj49
word_1574E:	dc.w 2
		dc.w $800D,    0,    0,$FFE0		; 0
		dc.w $800D,    0,    0,	   0		; 4
word_15760:	dc.w $12
		dc.w $800D,    0,    0,$FFE0		; 0
		dc.w $800D,    0,    0,	   0		; 4
		dc.w $800F,    8,    4,$FFE0		; 8
		dc.w $800F,    8,    4,	   0		; 12
		dc.w $A00F,    8,    4,$FFE0		; 16
		dc.w $A00F,    8,    4,	   0		; 20
		dc.w $C00F,    8,    4,$FFE0		; 24
		dc.w $C00F,    8,    4,	   0		; 28
		dc.w $E00F,    8,    4,$FFE0		; 32
		dc.w $E00F,    8,    4,	   0		; 36
		dc.w	$F,    8,    4,$FFE0		; 40
		dc.w	$F,    8,    4,	   0		; 44
		dc.w $200F,    8,    4,$FFE0		; 48
		dc.w $200F,    8,    4,	   0		; 52
		dc.w $400F,    8,    4,$FFE0		; 56
		dc.w $400F,    8,    4,	   0		; 60
		dc.w $600F,    8,    4,$FFE0		; 64
		dc.w $600F,    8,    4,	   0		; 68
word_157F2:	dc.w 0
word_157F4:	dc.w 4
		dc.w $E00F,    8,    4,$FFE0		; 0
		dc.w $E00F,    8,    4,	   0		; 4
		dc.w	$F,    8,    4,$FFE0		; 8
		dc.w	$F,    8,    4,	   0		; 12
word_15816:	dc.w $A
		dc.w $C00F,    8,    4,$FFE0		; 0
		dc.w $C00F,    8,    4,	   0		; 4
		dc.w $E00F,    8,    4,$FFE0		; 8
		dc.w $E00F,    8,    4,	   0		; 12
		dc.w	$F,    8,    4,$FFE0		; 16
		dc.w	$F,    8,    4,	   0		; 20
		dc.w $200F,    8,    4,$FFE0		; 24
		dc.w $200F,    8,    4,	   0		; 28
		dc.w $400F,    8,    4,$FFE0		; 32
		dc.w $400F,    8,    4,	   0		; 36
; ---------------------------------------------------------------------------

loc_15868:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_1586E:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

j_Adjust2PArtPointer_0:
		jmp	(Adjust2PArtPointer).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 4D - Rhinobot badnik
;----------------------------------------------------

Obj4D:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj4D_Index(pc,d0.w),d1
		jmp	Obj4D_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj4D_Index:	dc.w Obj4D_Init-Obj4D_Index
		dc.w Obj4D_Main-Obj4D_Index
; ---------------------------------------------------------------------------

Obj4D_Init:
		move.l	#Map_Obj4D,obMap(a0)
		move.w	#$23C4,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#$18,obWidth(a0)
		bsr.w	j_ObjectMoveAndFall_0
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_158DC
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)

locret_158DC:
		rts
; ---------------------------------------------------------------------------

Obj4D_Main:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj4D_SubIndex(pc,d0.w),d1
		jsr	Obj4D_SubIndex(pc,d1.w)
		lea	(Ani_Obj4D).l,a1
		bsr.w	j_AnimateSprite_0
		bra.w	loc_15B38
; ---------------------------------------------------------------------------
Obj4D_SubIndex:	dc.w loc_158FE-Obj4D_SubIndex
		dc.w loc_15922-Obj4D_SubIndex
; ---------------------------------------------------------------------------

loc_158FE:
		subq.w	#1,$30(a0)
		bpl.s	locret_15920
		addq.b	#2,ob2ndRout(a0)
		move.w	#$FF80,obVelX(a0)
		move.b	#0,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	locret_15920
		neg.w	obVelX(a0)

locret_15920:
		rts
; ---------------------------------------------------------------------------

loc_15922:
		bsr.w	sub_1596C
		bsr.w	j_ObjectMoveAndFall_0
		jsr	(ObjHitFloor).l
		cmpi.w	#$FFF8,d1
		blt.s	loc_15948
		cmpi.w	#$C,d1
		bge.s	locret_15946
		move.w	#0,obVelY(a0)
		add.w	d1,obY(a0)

locret_15946:
		rts
; ---------------------------------------------------------------------------

loc_15948:
		subq.b	#2,ob2ndRout(a0)
		move.w	#$3B,$30(a0)
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,obX(a0)
		move.w	#0,obVelX(a0)
		move.b	#1,obAnim(a0)
		rts

; =============== S U B	R O U T	I N E =======================================


sub_1596C:
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		bmi.s	loc_159A0
		cmpi.w	#$60,d0
		bgt.s	locret_15990
		btst	#0,obStatus(a0)
		bne.s	loc_15992
		move.b	#2,obAnim(a0)
		move.w	#$FE00,obVelX(a0)

locret_15990:
		rts
; ---------------------------------------------------------------------------

loc_15992:
		move.b	#0,obAnim(a0)
		move.w	#$80,obVelX(a0)
		rts
; ---------------------------------------------------------------------------

loc_159A0:
		cmpi.w	#$FFA0,d0
		blt.s	locret_15990
		btst	#0,obStatus(a0)
		beq.s	loc_159BC
		move.b	#2,obAnim(a0)
		move.w	#$200,obVelX(a0)
		rts
; ---------------------------------------------------------------------------

loc_159BC:
		move.b	#0,obAnim(a0)
		move.w	#$FF80,obVelX(a0)
		rts
; End of function sub_1596C

; ---------------------------------------------------------------------------
Ani_Obj4D:	dc.w byte_159D0-Ani_Obj4D
		dc.w byte_159DE-Ani_Obj4D
		dc.w byte_159E1-Ani_Obj4D
byte_159D0:	dc.b   2,  0,  0,  0,  3,  3,  4,  1,  1,  2,  5,  5,  5,$FF ; 0
byte_159DE:	dc.b  $F,  0,$FF			; 0
byte_159E1:	dc.b   2,  6,  7,$FF,  0		; 0
Map_Obj4D:	dc.w word_159F6-Map_Obj4D
		dc.w word_15A20-Map_Obj4D
		dc.w word_15A4A-Map_Obj4D
		dc.w word_15A74-Map_Obj4D
		dc.w word_15A9E-Map_Obj4D
		dc.w word_15AC8-Map_Obj4D
		dc.w word_15AF2-Map_Obj4D
		dc.w word_15B14-Map_Obj4D
word_159F6:	dc.w 5
		dc.w $F005,    0,    0,$FFF0		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w $F801,    8,    4,$FFE8		; 8
		dc.w	 5,   $A,    5,$FFF0		; 12
		dc.w	 9,  $22,  $11,	   0		; 16
word_15A20:	dc.w 5
		dc.w $F005,    0,    0,$FFF0		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w $F801,    8,    4,$FFE8		; 8
		dc.w	 5,   $E,    7,$FFF0		; 12
		dc.w	 9,  $22,  $11,	   0		; 16
word_15A4A:	dc.w 5
		dc.w $F005,    0,    0,$FFF0		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w $F801,    8,    4,$FFE8		; 8
		dc.w	 5,  $12,    9,$FFF0		; 12
		dc.w	 9,  $22,  $11,	   0		; 16
word_15A74:	dc.w 5
		dc.w $F005,    0,    0,$FFF0		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w $F801,    8,    4,$FFE8		; 8
		dc.w	 5,   $A,    5,$FFF0		; 12
		dc.w	 9,  $28,  $14,	   0		; 16
word_15A9E:	dc.w 5
		dc.w $F005,    0,    0,$FFF0		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w $F801,    8,    4,$FFE8		; 8
		dc.w	 5,   $E,    7,$FFF0		; 12
		dc.w	 9,  $28,  $14,	   0		; 16
word_15AC8:	dc.w 5
		dc.w $F005,    0,    0,$FFF0		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w $F801,    8,    4,$FFE8		; 8
		dc.w	 5,  $12,    9,$FFF0		; 12
		dc.w	 9,  $28,  $14,	   0		; 16
word_15AF2:	dc.w 4
		dc.w $F00B,  $16,   $B,$FFE8		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w	 9,  $22,  $11,	   0		; 8
		dc.w $FB01,  $2E,  $17,	 $1A		; 12
word_15B14:	dc.w 4
		dc.w $F00B,  $16,   $B,$FFE8		; 0
		dc.w $F005,    4,    2,	   0		; 4
		dc.w	 9,  $28,  $14,	   0		; 8
		dc.w $FB01,  $30,  $18,	 $1A		; 12
		align 4

loc_15B38:
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

j_AnimateSprite_0:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMoveAndFall_0:
		jmp	(ObjectMoveAndFall).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 52 - Piranha badnik
;----------------------------------------------------

Obj52:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj52_Index(pc,d0.w),d1
		jmp	Obj52_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj52_Index:	dc.w Obj52_Init-Obj52_Index
		dc.w Obj52_Main-Obj52_Index
		dc.w loc_15C48-Obj52_Index
; ---------------------------------------------------------------------------

Obj52_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj52,obMap(a0)
		move.w	#$2530,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.b	d0,d1
		andi.w	#$F0,d1
		add.w	d1,d1
		add.w	d1,d1
		move.w	d1,$3A(a0)
		move.w	d1,$3C(a0)
		andi.w	#$F,d0
		lsl.w	#6,d0
		subq.w	#1,d0
		move.w	d0,$30(a0)
		move.w	d0,$32(a0)
		move.w	#$FF80,obVelX(a0)
		move.l	#$FFFB8000,$36(a0)
		move.w	obY(a0),$34(a0)
		bset	#6,obStatus(a0)
		btst	#0,obStatus(a0)
		beq.s	Obj52_Main
		neg.w	obVelX(a0)

Obj52_Main:
		cmpi.w	#$FFFF,$3A(a0)
		beq.s	loc_15BE4
		subq.w	#1,$3A(a0)

loc_15BE4:
		subq.w	#1,$30(a0)
		bpl.s	NemDec_WriteIter_Part26
		move.w	$32(a0),$30(a0)
		neg.w	obVelX(a0)
		bchg	#0,obStatus(a0)
		move.b	#1,obPrevAni(a0)
		move.w	$3C(a0),$3A(a0)

NemDec_WriteIter_Part26:
		lea	(Ani_Obj52).l,a1
		bsr.w	j_AnimateSprite_1
		bsr.w	j_ObjectMove_2
		tst.w	$3A(a0)
		bgt.w	loc_15D90
		cmpi.w	#$FFFF,$3A(a0)
		beq.w	loc_15D90
		move.l	#$FFFB8000,$36(a0)
		addq.b	#2,obRoutine(a0)
		move.w	#$FFFF,$3A(a0)
		move.b	#2,obAnim(a0)
		move.w	#1,$3E(a0)
		bra.w	loc_15D90
; ---------------------------------------------------------------------------

loc_15C48:
		move.w	#$390,(v_waterpos1).w
		lea	(Ani_Obj52).l,a1
		bsr.w	j_AnimateSprite_1
		move.w	$3E(a0),d0
		sub.w	d0,$30(a0)
		bsr.w	sub_15CF8
		tst.l	$36(a0)
		bpl.s	loc_15CA0
		move.w	obY(a0),d0
		cmp.w	(v_waterpos1).w,d0
		bgt.w	loc_15D90
		move.b	#3,obAnim(a0)
		bclr	#6,obStatus(a0)
		tst.b	$2A(a0)
		bne.w	loc_15D90
		move.w	obVelX(a0),d0
		asl.w	#1,d0
		move.w	d0,obVelX(a0)
		addq.w	#1,$3E(a0)
		st	$2A(a0)
		bra.w	loc_15D90
; ---------------------------------------------------------------------------

loc_15CA0:
		move.w	obY(a0),d0
		cmp.w	(v_waterpos1).w,d0
		bgt.s	loc_15CB4
		move.b	#1,obAnim(a0)
		bra.w	loc_15D90
; ---------------------------------------------------------------------------

loc_15CB4:
		move.b	#0,obAnim(a0)
		bset	#6,obStatus(a0)
		bne.s	loc_15CCE
		move.l	$36(a0),d0
		asr.l	#1,d0
		move.l	d0,$36(a0)
		nop

loc_15CCE:
		move.w	$34(a0),d0
		cmp.w	obY(a0),d0
		bgt.w	loc_15D90
		subq.b	#2,obRoutine(a0)
		tst.b	$2A(a0)
		beq.w	loc_15D90
		move.w	obVelX(a0),d0
		asr.w	#1,d0
		move.w	d0,obVelX(a0)
		sf	$2A(a0)
		bra.w	loc_15D90

; =============== S U B	R O U T	I N E =======================================


sub_15CF8:
		move.l	obX(a0),d2
		move.l	obY(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		add.l	$36(a0),d3
		btst	#6,obStatus(a0)
		beq.s	loc_15D34
		tst.l	$36(a0)
		bpl.s	loc_15D2C
		addi.l	#$1000,$36(a0)
		addi.l	#$1000,$36(a0)

loc_15D2C:
		subi.l	#$1000,$36(a0)

loc_15D34:
		addi.l	#$1800,$36(a0)
		move.l	d2,obX(a0)
		move.l	d3,obY(a0)
		rts
; End of function sub_15CF8

; ---------------------------------------------------------------------------
Ani_Obj52:	dc.w byte_15D4E-Ani_Obj52
		dc.w byte_15D52-Ani_Obj52
		dc.w byte_15D56-Ani_Obj52
		dc.w byte_15D5A-Ani_Obj52
byte_15D4E:	dc.b  $E,  0,  1,$FF			; 0
byte_15D52:	dc.b   3,  0,  1,$FF			; 0
byte_15D56:	dc.b  $E,  2,  3,$FF			; 0
byte_15D5A:	dc.b   3,  2,  3,$FF			; 0
Map_Obj52:	dc.w word_15D66-Map_Obj52
		dc.w word_15D70-Map_Obj52
		dc.w word_15D7A-Map_Obj52
		dc.w word_15D84-Map_Obj52
word_15D66:	dc.w 1
		dc.w $F00F,    0,    0,$FFF0		; 0
word_15D70:	dc.w 1
		dc.w $F00F,  $10,    8,$FFF0		; 0
word_15D7A:	dc.w 1
		dc.w $F00F,  $20,  $10,$FFF0		; 0
word_15D84:	dc.w 1
		dc.w $F00F,  $30,  $18,$FFF0		; 0
		align 4

loc_15D90:
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

j_AnimateSprite_1:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMove_2:
		jmp	(ObjectMove).l
		align 4

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4F - Redz (dinosaur badnik) from HPZ
; ---------------------------------------------------------------------------

Obj4F:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj4F_Index(pc,d0.w),d1
		jmp	Obj4F_Index(pc,d1.w)
; ===========================================================================
Obj4F_Index:	dc.w Obj4F_Init-Obj4F_Index
		dc.w Obj4F_Main-Obj4F_Index
		dc.w Obj4F_Delete-Obj4F_Index
; ===========================================================================

Obj4F_Init:
		move.l	#Map_obj4F,obMap(a0)
		move.w	#$500,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#6,obWidth(a0)
		move.b	#$C,obColType(a0)
		bsr.w	j_ObjectMoveAndFall_1
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_15E0C
		add.w	d1,obY(a0)

loc_15DFC:
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		bchg	#0,obStatus(a0)

locret_15E0C:
		rts
; ===========================================================================

Obj4F_Main:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj4F_SubIndex(pc,d0.w),d1
		jsr	Obj4F_SubIndex(pc,d1.w)
		lea	(Ani_obj4F).l,a1
		bsr.w	j_AnimateSprite_2
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_15E3E
		bra.w	loc_15EE8
; ---------------------------------------------------------------------------

loc_15E3E:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	loc_15E50
		bclr	#7,2(a2,d0.w)

loc_15E50:
		bra.w	JmpTo_DeleteObject
; ===========================================================================
Obj4F_SubIndex:	dc.w Obj4F_MoveLeft-Obj4F_SubIndex
		dc.w Obj4F_ChkFloor-Obj4F_SubIndex
; ===========================================================================
; loc_15E58:
Obj4F_MoveLeft:
		subq.w	#1,$30(a0)			; is Redz not moving?
		bpl.s	locret_15E7A			; if not, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#$FF80,obVelX(a0)
		move.b	#1,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	locret_15E7A
		neg.w	obVelX(a0)

locret_15E7A:
		rts
; ===========================================================================
; loc_15E7C:
Obj4F_ChkFloor:
		bsr.w	j_ObjectMove_3
		jsr	(ObjHitFloor).l
		cmpi.w	#$FFF8,d1
		blt.s	Obj4F_StopMoving
		cmpi.w	#$C,d1
		bge.s	Obj4F_StopMoving
		add.w	d1,obY(a0)
		rts
; ---------------------------------------------------------------------------
; loc_15E98:
Obj4F_StopMoving:
		subq.b	#2,ob2ndRout(a0)
		move.w	#1*59,$30(a0)			; pause for 1 second
		move.w	#0,obVelX(a0)
		move.b	#0,obAnim(a0)
		rts
; ===========================================================================

Obj4F_Delete:
		bra.w	JmpTo_DeleteObject
; ===========================================================================
; animation script
Ani_obj4F:	dc.w byte_15EB8-Ani_obj4F
		dc.w byte_15EBB-Ani_obj4F
byte_15EB8:	dc.b   9,  1,$FF
byte_15EBB:	dc.b   9,  0,  1,  2,  1,$FF,  0
; ---------------------------------------------------------------------------
; Sprite mappings - Redz (dinosaur badnik) from HPZ
; ---------------------------------------------------------------------------
Map_obj4F:	binclude	"mappings/sprite/obj4F.bin"
		align 4

loc_15EE8:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

JmpTo_DeleteObject:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

j_AnimateSprite_2:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMoveAndFall_1:
		jmp	(ObjectMoveAndFall).l
; ---------------------------------------------------------------------------

j_ObjectMove_3:
		jmp	(ObjectMove).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 50 - unused Seahorse badnik from HPZ
;----------------------------------------------------

Obj50:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj50_Index(pc,d0.w),d1
		jmp	Obj50_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj50_Index:	dc.w Obj50_Init-Obj50_Index
		dc.w loc_15FDA-Obj50_Index
		dc.w loc_16006-Obj50_Index
		dc.w loc_16030-Obj50_Index
		dc.w Obj50_Routine08-Obj50_Index
		dc.w Obj50_Routine0A-Obj50_Index
; ---------------------------------------------------------------------------

Obj50_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj50,obMap(a0)
		move.w	#$2570,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$FF00,obVelX(a0)
		move.b	obSubtype(a0),d0
		move.b	d0,d1
		andi.w	#$F0,d1
		lsl.w	#4,d1
		move.w	d1,$2E(a0)
		move.w	d1,$30(a0)
		andi.w	#$F,d0
		lsl.w	#4,d0
		subq.w	#1,d0
		move.w	d0,$32(a0)
		move.w	d0,$34(a0)
		move.w	obY(a0),$2A(a0)
		bsr.w	j_FindFreeObj
		bne.s	loc_15FDA
		_move.b	#$50,obID(a1)
		move.b	#4,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$A,obX(a1)
		addi.w	#$FFFA,obY(a1)
		move.l	#Map_Obj50,obMap(a1)
		move.w	#$24E0,obGfx(a1)
		ori.b	#4,obRender(a1)
		move.b	#3,obPriority(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#3,obAnim(a1)
		move.l	a1,$36(a0)
		move.l	a0,$36(a1)
		bset	#6,obStatus(a0)

loc_15FDA:
		lea	(Ani_Obj50).l,a1
		bsr.w	j_AnimateSprite_3
		move.w	#$39C,(v_waterpos1).w
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj50_SubIndex(pc,d0.w),d1
		jsr	Obj50_SubIndex(pc,d1.w)
		bsr.w	sub_161D8
		bra.w	loc_1677A
; ---------------------------------------------------------------------------
Obj50_SubIndex:	dc.w loc_16046-Obj50_SubIndex
		dc.w loc_16058-Obj50_SubIndex
		dc.w loc_16066-Obj50_SubIndex
; ---------------------------------------------------------------------------

loc_16006:
		movea.l	$36(a0),a1
		tst.b	(a1)
		beq.w	loc_1676E
		cmpi.b	#$50,(a1)
		bne.w	loc_1676E
		btst	#7,obStatus(a1)
		bne.w	loc_1676E
		lea	(Ani_Obj50).l,a1
		bsr.w	j_AnimateSprite_3
		bra.w	loc_16768
; ---------------------------------------------------------------------------

loc_16030:
		bsr.w	loc_162FC
		bsr.w	j_ObjectMove_4
		lea	(Ani_Obj50).l,a1
		bsr.w	j_AnimateSprite_3
		bra.w	loc_1677A
; ---------------------------------------------------------------------------

loc_16046:
		bsr.w	j_ObjectMove_4
		bsr.w	sub_162DE
		bsr.w	sub_16184
		bsr.w	sub_1611C
		rts
; ---------------------------------------------------------------------------

loc_16058:
		bsr.w	j_ObjectMove_4
		bsr.w	sub_162DE
		bsr.w	sub_161A6
		rts
; ---------------------------------------------------------------------------

loc_16066:
		bsr.w	j_ObjectMoveAndFall_2
		bsr.w	sub_162DE
		bsr.w	sub_16078
		bsr.w	sub_160F4
		rts

; =============== S U B	R O U T	I N E =======================================


sub_16078:
		tst.b	$2D(a0)
		bne.s	locret_16084
		tst.w	obVelY(a0)
		bpl.s	loc_16086

locret_16084:
		rts
; ---------------------------------------------------------------------------

loc_16086:
		st	$2D(a0)
		bsr.w	j_FindFreeObj
		bne.s	locret_160F2
		_move.b	#$50,obID(a1)
		move.b	#6,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Obj50,obMap(a1)
		move.w	#$24E0,obGfx(a1)
		ori.b	#4,obRender(a1)
		move.b	#3,obPriority(a1)
		move.b	#$E5,obColType(a1)
		move.b	#2,obAnim(a1)
		move.w	#$C,d0
		move.w	#$10,d1
		move.w	#$FD00,d2
		btst	#0,obStatus(a0)
		beq.s	loc_160E6
		neg.w	d1
		neg.w	d2

loc_160E6:
		sub.w	d0,obY(a1)
		sub.w	d1,obX(a1)
		move.w	d2,obVelX(a1)

locret_160F2:
		rts
; End of function sub_16078


; =============== S U B	R O U T	I N E =======================================


sub_160F4:
		move.w	obY(a0),d0
		cmp.w	(v_waterpos1).w,d0
		blt.s	locret_1611A
		move.b	#2,ob2ndRout(a0)
		move.b	#0,obAnim(a0)
		move.w	$30(a0),$2E(a0)
		move.w	#$40,obVelY(a0)
		sf	$2D(a0)

locret_1611A:
		rts
; End of function sub_160F4


; =============== S U B	R O U T	I N E =======================================


sub_1611C:
		tst.b	$2C(a0)
		beq.s	locret_16182
		move.w	(v_objspace+obX).w,d0
		move.w	(v_objspace+obY).w,d1
		sub.w	obY(a0),d1
		bpl.s	locret_16182
		cmpi.w	#$FFD0,d1
		blt.s	locret_16182
		sub.w	obX(a0),d0
		cmpi.w	#$48,d0
		bgt.s	locret_16182
		cmpi.w	#$FFB8,d0
		blt.s	locret_16182
		tst.w	d0
		bpl.s	loc_1615A
		cmpi.w	#$FFD8,d0
		bgt.s	locret_16182
		btst	#0,obStatus(a0)
		bne.s	locret_16182
		bra.s	loc_16168
; ---------------------------------------------------------------------------

loc_1615A:
		cmpi.w	#$28,d0
		blt.s	locret_16182
		btst	#0,obStatus(a0)
		beq.s	locret_16182

loc_16168:
		moveq	#$20,d0
		cmp.w	$32(a0),d0
		bgt.s	locret_16182
		move.b	#4,ob2ndRout(a0)
		move.b	#1,obAnim(a0)
		move.w	#$FC00,obVelY(a0)

locret_16182:
		rts
; End of function sub_1611C


; =============== S U B	R O U T	I N E =======================================


sub_16184:
		subq.w	#1,$2E(a0)
		bne.s	locret_161A4
		move.w	$30(a0),$2E(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#$FFC0,d0
		tst.b	$2C(a0)
		beq.s	loc_161A0
		neg.w	d0

loc_161A0:
		move.w	d0,obVelY(a0)

locret_161A4:
		rts
; End of function sub_16184


; =============== S U B	R O U T	I N E =======================================


sub_161A6:
		move.w	obY(a0),d0
		tst.b	$2C(a0)
		bne.s	loc_161C4
		cmp.w	(v_waterpos1).w,d0
		bgt.s	locret_161C2
		subq.b	#2,ob2ndRout(a0)
		st	$2C(a0)
		clr.w	obVelY(a0)

locret_161C2:
		rts
; ---------------------------------------------------------------------------

loc_161C4:
		cmp.w	$2A(a0),d0
		blt.s	locret_161C2
		subq.b	#2,ob2ndRout(a0)
		sf	$2C(a0)
		clr.w	obVelY(a0)
		rts
; End of function sub_161A6


; =============== S U B	R O U T	I N E =======================================


sub_161D8:
		moveq	#$A,d0
		moveq	#$FFFFFFFA,d1
		movea.l	$36(a0),a1
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obRespawnNo(a0),obRespawnNo(a1)
		move.b	obRender(a0),obRender(a1)
		btst	#0,obStatus(a1)
		beq.s	loc_16208
		neg.w	d0

loc_16208:
		add.w	d0,obX(a1)
		add.w	d1,obY(a1)
		rts
; End of function sub_161D8

; ---------------------------------------------------------------------------

Obj50_Routine08:
		bsr.w	j_ObjectMoveAndFall_2
		bsr.w	sub_16228
		lea	(Ani_Obj50).l,a1
		bsr.w	j_AnimateSprite_3
		bra.w	loc_1677A

; =============== S U B	R O U T	I N E =======================================


sub_16228:
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_16242
		add.w	d1,obY(a0)
		move.w	obVelY(a0),d0
		asr.w	#1,d0
		neg.w	d0
		move.w	d0,obVelY(a0)

loc_16242:
		subi.b	#1,obColProp(a0)
		beq.w	loc_1676E
		rts
; End of function sub_16228

; ---------------------------------------------------------------------------

Obj50_Routine0A:
		bsr.w	sub_1629E
		tst.b	ob2ndRout(a0)
		beq.s	locret_1628E
		subi.w	#1,$2C(a0)
		beq.w	loc_1676E
		move.w	(v_objspace+obX).w,obX(a0)
		move.w	(v_objspace+obY).w,obY(a0)
		addi.w	#$C,obY(a0)
		subi.b	#1,$2A(a0)
		bne.s	loc_16290
		move.b	#3,$2A(a0)
		bchg	#0,obStatus(a0)
		bchg	#0,obRender(a0)

locret_1628E:
		rts
; ---------------------------------------------------------------------------

loc_16290:
		lea	(Ani_Obj50).l,a1
		bsr.w	j_AnimateSprite_3
		bra.w	loc_16768

; =============== S U B	R O U T	I N E =======================================


sub_1629E:
		tst.b	ob2ndRout(a0)
		bne.s	locret_162DC
		move.b	(v_objspace+obRoutine).w,d0
		cmpi.b	#2,d0
		bne.s	locret_162DC
		move.w	(v_objspace+obX).w,obX(a0)
		move.w	(v_objspace+obY).w,obY(a0)
		ori.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#5,obAnim(a0)
		st	ob2ndRout(a0)
		move.w	#$12C,$2C(a0)
		move.b	#3,$2A(a0)

locret_162DC:
		rts
; End of function sub_1629E


; =============== S U B	R O U T	I N E =======================================


sub_162DE:
		subq.w	#1,$32(a0)
		bpl.s	locret_162FA
		move.w	$34(a0),$32(a0)
		neg.w	obVelX(a0)
		bchg	#0,obStatus(a0)
		move.b	#1,obPrevAni(a0)

locret_162FA:
		rts
; End of function sub_162DE

; ---------------------------------------------------------------------------

loc_162FC:
		tst.b	obColProp(a0)
		beq.w	locret_1639E
		moveq	#2,d3

loc_16306:
		bsr.w	j_FindFreeObj
		bne.s	loc_16378
		_move.b	obID(a0),obID(a1)
		move.b	#8,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	#$24E0,obGfx(a1)
		ori.b	#4,obRender(a1)
		move.b	#3,obPriority(a1)
		move.w	#$FF00,obVelY(a1)
		move.b	#4,obAnim(a1)
		move.b	#$78,obColProp(a1)
		cmpi.w	#1,d3
		beq.s	loc_16372
		blt.s	loc_16364
		move.w	#$C0,obVelX(a1)
		addi.w	#$FF40,obVelY(a1)
		bra.s	loc_16378
; ---------------------------------------------------------------------------

loc_16364:
		move.w	#$FF00,obVelX(a1)
		addi.w	#$FFC0,obVelY(a1)
		bra.s	loc_16378
; ---------------------------------------------------------------------------

loc_16372:
		move.w	#$40,obVelX(a1)

loc_16378:
		dbf	d3,loc_16306
		bsr.w	j_FindFreeObj
		bne.s	loc_1639A
		_move.b	obID(a0),obID(a1)
		move.b	#$A,obRoutine(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	#$24E0,obGfx(a1)

loc_1639A:
		bra.w	loc_1676E
; ---------------------------------------------------------------------------

locret_1639E:
		rts
; ---------------------------------------------------------------------------
Ani_Obj50:	dc.w byte_163B0-Ani_Obj50
		dc.w byte_163B3-Ani_Obj50
		dc.w byte_163BB-Ani_Obj50
		dc.w byte_163C1-Ani_Obj50
		dc.w byte_163C5-Ani_Obj50
		dc.w byte_163C8-Ani_Obj50
		dc.w byte_163CB-Ani_Obj50
		dc.w byte_163CF-Ani_Obj50
byte_163B0:	dc.b  $E,  0,$FF			; 0
byte_163B3:	dc.b   5,  3,  4,  3,  4,  3,  4,$FF	; 0
byte_163BB:	dc.b   3,  5,  6,  7,  6,$FF		; 0
byte_163C1:	dc.b   3,  1,  2,$FF			; 0
byte_163C5:	dc.b   1,  5,$FF			; 0
byte_163C8:	dc.b  $E,  8,$FF			; 0
byte_163CB:	dc.b   1,  9, $A,$FF			; 0
byte_163CF:	dc.b   5, $B, $C, $B, $C, $B, $C,$FF,  0 ; 0
Map_Obj50:	dc.w word_163F2-Map_Obj50
		dc.w word_1640C-Map_Obj50
		dc.w word_16416-Map_Obj50
		dc.w word_16420-Map_Obj50
		dc.w word_16442-Map_Obj50
		dc.w word_16464-Map_Obj50
		dc.w word_1646E-Map_Obj50
		dc.w word_16478-Map_Obj50
		dc.w word_16482-Map_Obj50
		dc.w word_1648C-Map_Obj50
		dc.w word_164AE-Map_Obj50
		dc.w word_164D0-Map_Obj50
		dc.w word_164FA-Map_Obj50
word_163F2:	dc.w 3
		dc.w $E80D,    0,    0,$FFF0		; 0
		dc.w $F809,  $16,   $B,$FFF8		; 4
		dc.w  $805,  $24,  $12,$FFF8		; 8
word_1640C:	dc.w 1
		dc.w $F805,  $28,  $14,$FFF8		; 0
word_16416:	dc.w 1
		dc.w $F805,  $2C,  $16,$FFF8		; 0
word_16420:	dc.w 4
		dc.w $E809,    8,    4,$FFF0		; 0
		dc.w $E801,   $E,    7,	   8		; 4
		dc.w $F809,  $16,   $B,$FFF8		; 8
		dc.w  $805,  $24,  $12,$FFF8		; 12
word_16442:	dc.w 4
		dc.w $E809,  $10,    8,$FFF0		; 0
		dc.w $E801,   $E,    7,	   8		; 4
		dc.w $F809,  $16,   $B,$FFF8		; 8
		dc.w  $805,  $24,  $12,$FFF8		; 12
word_16464:	dc.w 1
		dc.w $F801,  $30,  $18,$FFFC		; 0
word_1646E:	dc.w 1
		dc.w $F801,  $32,  $19,$FFFC		; 0
word_16478:	dc.w 1
		dc.w $F801,  $34,  $1A,$FFFC		; 0
word_16482:	dc.w 1
		dc.w $F80D,  $36,  $1B,$FFF0		; 0
word_1648C:	dc.w 4
		dc.w $E80D,    0,    0,$FFF0		; 0
		dc.w $F805,  $1C,   $E,$FFF8		; 4
		dc.w $F801,  $20,  $10,	   8		; 8
		dc.w  $805,  $24,  $12,$FFF8		; 12
word_164AE:	dc.w 4
		dc.w $E80D,    0,    0,$FFF0		; 0
		dc.w $F805,  $1C,   $E,$FFF8		; 4
		dc.w $F801,  $22,  $11,	   8		; 8
		dc.w  $805,  $24,  $12,$FFF8		; 12
word_164D0:	dc.w 5
		dc.w $E809,    8,    4,$FFF0		; 0
		dc.w $E801,   $E,    7,	   8		; 4
		dc.w $F805,  $1C,   $E,$FFF8		; 8
		dc.w $F801,  $20,  $10,	   8		; 12
		dc.w  $805,  $24,  $12,$FFF8		; 16
word_164FA:	dc.w 5
		dc.w $E809,  $10,    8,$FFF0		; 0
		dc.w $E801,   $E,    7,	   8		; 4
		dc.w $F805,  $1C,   $E,$FFF8		; 8
		dc.w $F801,  $22,  $11,	   8		; 12
		dc.w  $805,  $24,  $12,$FFF8		; 16
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 51 - unused Skyhorse badnik from HPZ
;----------------------------------------------------

Obj51:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	off_16532(pc,d0.w),d1
		jmp	off_16532(pc,d1.w)
; ---------------------------------------------------------------------------
off_16532:	dc.w loc_1653E-off_16532
		dc.w loc_1659C-off_16532
		dc.w loc_165C0-off_16532
		dc.w 0
		dc.w Obj50_Routine08-off_16532
		dc.w Obj50_Routine0A-off_16532
; ---------------------------------------------------------------------------

loc_1653E:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj50,obMap(a0)
		move.w	#$2570,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#6,obAnim(a0)
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0
		move.w	d0,d1
		lsl.w	#5,d1
		subq.w	#1,d1
		move.w	d1,$32(a0)
		move.w	d1,$34(a0)
		move.w	obY(a0),$2A(a0)
		move.w	obY(a0),$2E(a0)
		addi.w	#$60,$2E(a0)
		move.w	#$FF00,obVelX(a0)

loc_1659C:
		lea	Ani_Obj50(pc),a1
		bsr.w	j_AnimateSprite_3
		move.w	#$39C,(v_waterpos1).w
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	off_165BC(pc,d0.w),d1
		jsr	off_165BC(pc,d1.w)
		bra.w	loc_1677A
; ---------------------------------------------------------------------------
off_165BC:	dc.w loc_165D4-off_165BC
		dc.w loc_165EA-off_165BC
; ---------------------------------------------------------------------------

loc_165C0:
		bsr.w	loc_162FC
		bsr.w	j_ObjectMove_4
		lea	Ani_Obj50(pc),a1
		bsr.w	j_AnimateSprite_3
		bra.w	loc_1677A
; ---------------------------------------------------------------------------

loc_165D4:
		bsr.w	j_ObjectMove_4
		bsr.w	sub_162DE
		bsr.w	loc_16626
		bsr.w	loc_16708
		bsr.w	loc_16678
		rts
; ---------------------------------------------------------------------------

loc_165EA:
		bsr.w	j_ObjectMove_4
		bsr.w	sub_162DE
		bsr.w	loc_16626
		bsr.w	loc_16708
		bsr.w	loc_16600
		rts
; ---------------------------------------------------------------------------

loc_16600:
		subq.w	#1,$30(a0)
		beq.s	loc_16614
		move.w	$30(a0),d0
		cmpi.w	#$12,d0
		beq.w	loc_1669E
		rts
; ---------------------------------------------------------------------------

loc_16614:
		subq.b	#2,ob2ndRout(a0)
		move.b	#6,obAnim(a0)
		move.w	#$B4,$30(a0)
		rts
; ---------------------------------------------------------------------------

loc_16626:
		sf	$2D(a0)
		sf	$2C(a0)
		sf	$36(a0)
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	loc_16646
		btst	#0,obStatus(a0)
		bne.s	loc_1664E
		bra.s	loc_16652
; ---------------------------------------------------------------------------

loc_16646:
		btst	#0,obStatus(a0)
		bne.s	loc_16652

loc_1664E:
		st	$2C(a0)

loc_16652:
		move.w	(v_objspace+obY).w,d0
		sub.w	obY(a0),d0
		cmpi.w	#$FFFC,d0
		blt.s	locret_16676
		cmpi.w	#4,d0
		bgt.s	loc_16672
		st	$2D(a0)
		move.w	#0,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_16672:
		st	$36(a0)

locret_16676:
		rts
; ---------------------------------------------------------------------------

loc_16678:
		tst.b	$2C(a0)
		bne.s	locret_1669C
		subq.w	#1,$30(a0)
		bgt.s	locret_1669C
		tst.b	$2D(a0)
		beq.s	locret_1669C
		move.b	#7,obAnim(a0)
		move.w	#$24,$30(a0)
		addi.b	#2,ob2ndRout(a0)

locret_1669C:
		rts
; ---------------------------------------------------------------------------

loc_1669E:
		bsr.w	j_FindFreeObj
		bne.s	locret_16706
		_move.b	#$51,obID(a1)
		move.b	#4,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Obj50,obMap(a1)
		move.w	#$24E0,obGfx(a1)
		ori.b	#4,obRender(a1)
		move.b	#3,obPriority(a1)
		move.b	#2,obAnim(a1)
		move.b	#$E5,obColType(a1)
		move.w	#$C,d0
		move.w	#$10,d1
		move.w	#$FD00,d2
		btst	#0,obStatus(a0)
		beq.s	loc_166FA
		neg.w	d1
		neg.w	d2

loc_166FA:
		sub.w	d0,obY(a1)
		sub.w	d1,obX(a1)
		move.w	d2,obVelX(a1)

locret_16706:
		rts
; ---------------------------------------------------------------------------

loc_16708:
		tst.b	$2D(a0)
		bne.s	locret_16766
		tst.b	$36(a0)
		beq.s	loc_16738
		move.w	$2E(a0),d0
		cmp.w	obY(a0),d0
		ble.s	loc_1675C
		tst.b	$2C(a0)
		beq.s	loc_16730
		move.w	$2A(a0),d0
		cmp.w	obY(a0),d0
		bge.s	loc_1675C
		rts
; ---------------------------------------------------------------------------

loc_16730:
		move.w	#$180,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_16738:
		move.w	$2A(a0),d0
		cmp.w	obY(a0),d0
		bge.s	loc_1675C
		tst.b	$2C(a0)
		beq.s	loc_16754
		move.w	$2E(a0),d0
		cmp.w	obY(a0),d0
		ble.s	loc_1675C
		rts
; ---------------------------------------------------------------------------

loc_16754:
		move.w	#$FE80,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_1675C:
		move.w	d0,obY(a0)
		move.w	#0,obVelY(a0)

locret_16766:
		rts
; ---------------------------------------------------------------------------

loc_16768:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_1676E:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

j_FindFreeObj:
		jmp	(FindFreeObj).l
; ---------------------------------------------------------------------------

loc_1677A:
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

j_AnimateSprite_3:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMoveAndFall_2:
		jmp	(ObjectMoveAndFall).l
; ---------------------------------------------------------------------------

j_ObjectMove_4:
		jmp	(ObjectMove).l

		align 4

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4B - Buzzer from EHZ
; ---------------------------------------------------------------------------

Obj4B:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj4B_Index(pc,d0.w),d1
		jmp	Obj4B_Index(pc,d1.w)
; ===========================================================================
Obj4B_Index:	dc.w Obj4B_Init-Obj4B_Index
		dc.w Obj4B_Main-Obj4B_Index
		dc.w Obj4B_Flame-Obj4B_Index
		dc.w Obj4B_Projectile-Obj4B_Index
; ===========================================================================
; loc_167AA:
Obj4B_Projectile:
		bsr.w	j_ObjectMove_5
		lea	(Ani_obj4B).l,a1
		bsr.w	j_AnimateSprite_4
		bra.w	loc_16A8C
; ===========================================================================
; loc_167BC:
Obj4B_Flame:
		movea.l	$2A(a0),a1
		tst.b	(a1)
		beq.w	loc_16A74
		tst.w	$30(a1)
		bmi.s	loc_167CE
		rts
; ---------------------------------------------------------------------------

loc_167CE:
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		lea	(Ani_obj4B).l,a1
		bsr.w	j_AnimateSprite_4
		bra.w	loc_16A8C
; ===========================================================================

Obj4B_Init:
		move.l	#Map_obj4B,obMap(a0)
		move.w	#$3E6,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_2
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#$18,obWidth(a0)
		move.b	#3,obPriority(a0)
		addq.b	#2,obRoutine(a0)		; => Obj4B_Main

		; load exhaust flame object
		bsr.w	j_FindNextFreeObj_0
		bne.s	locret_1689E

		_move.b	#$4B,obID(a1)			; load obj4B
		move.b	#4,obRoutine(a1)		; => Obj4B_Flame
		move.l	#Map_obj4B,obMap(a1)
		move.w	#$3E6,obGfx(a1)
		bsr.w	j_Adjust2PArtPointer2
		move.b	#4,obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	#1,obAnim(a1)
		move.l	a0,$2A(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$100,$2E(a0)
		move.w	#-$100,obVelX(a0)
		btst	#0,obRender(a0)
		beq.s	locret_1689E
		neg.w	obVelX(a0)

locret_1689E:
		rts
; ===========================================================================

Obj4B_Main:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj4B_Main_Index(pc,d0.w),d1
		jsr	Obj4B_Main_Index(pc,d1.w)
		lea	(Ani_obj4B).l,a1
		bsr.w	j_AnimateSprite_4
		bra.w	loc_16A8C
; ===========================================================================
Obj4B_Main_Index:	dc.w Obj4B_Roaming-Obj4B_Main_Index
			dc.w Obj4B_Shooting-Obj4B_Main_Index
; ===========================================================================
; loc_168C0:
Obj4B_Roaming:
		bsr.w	Obj4B_ChkPlayers
		subq.w	#1,$30(a0)
		move.w	$30(a0),d0
		cmpi.w	#$F,d0
		beq.s	Obj4B_TurnAround
		tst.w	d0
		bpl.s	locret_168E4
		subq.w	#1,$2E(a0)
		bgt.w	j_ObjectMove_5
		move.w	#$1E,$30(a0)

locret_168E4:
		rts
; ---------------------------------------------------------------------------
; loc_168E6:
Obj4B_TurnAround:
		sf	$32(a0)				; reenable shooting
		neg.w	obVelX(a0)			; reverse movement direction
		bchg	#0,obRender(a0)
		bchg	#0,obStatus(a0)
		move.w	#$100,$2E(a0)
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_16902:
Obj4B_ChkPlayers:
		tst.b	$32(a0)
		bne.w	locret_1694E			; branch, if shooting is disabled
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0		; a1=character
		move.w	d0,d1
		bpl.s	loc_16918
		neg.w	d0

loc_16918:
		; test if player is inside an 8 pixel wide strip
		cmpi.w	#$28,d0
		blt.s	locret_1694E
		cmpi.w	#$30,d0
		bgt.s	locret_1694E

		tst.w	d1				; test sign of distance
		bpl.s	Obj4B_PlayerIsLeft		; branch, if player is left from object
		btst	#0,obRender(a0)
		beq.s	locret_1694E			; branch, if object is facing right
		bra.s	Obj4B_ReadyToShoot
; ---------------------------------------------------------------------------
; loc_16932:
Obj4B_PlayerIsLeft:
		btst	#0,obRender(a0)
		bne.s	locret_1694E			; branch, if object is facing left
; loc_1693A:
Obj4B_ReadyToShoot:
		st	$32(a0)				; disable shooting
		addq.b	#2,ob2ndRout(a0)		; => Obj4B_Shooting
		move.b	#3,obAnim(a0)			; play shooting animation
		move.w	#$32,$34(a0)

locret_1694E:
		rts
; End of function Obj4B_ChkPlayers

; ===========================================================================
; loc_16950:
Obj4B_Shooting:
		move.w	$34(a0),d0			; get timer value
		subq.w	#1,d0				; decrement
		blt.s	Obj4B_DoneShooting		; branch, if timer has expired
		move.w	d0,$34(a0)			; update timer value
		cmpi.w	#$14,d0				; has timer reached a certain value?
		beq.s	Obj4B_ShootProjectile		; if yes, branch
		rts
; ===========================================================================
; loc_16964:
Obj4B_DoneShooting:
		subq.b	#2,ob2ndRout(a0)		; => Obj4B_Roaming
		rts
; ===========================================================================
; loc_1696A:
Obj4B_ShootProjectile:
		jsr	(FindNextFreeObj).l
		bne.s	locret_169D8

		_move.b	#$4B,obID(a1)			; load obj4B
		move.b	#6,obRoutine(a1)		; => Obj4B_Projectile
		move.l	#Map_obj4B,obMap(a1)
		move.w	#$3E6,obGfx(a1)
		bsr.w	j_Adjust2PArtPointer2
		move.b	#4,obPriority(a1)
		move.b	#$98,obColType(a1)
		move.b	#$10,obActWid(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	#2,obAnim(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$180,obVelY(a1)
		move.w	#-$180,obVelX(a1)
		btst	#0,obRender(a1)			; is object facing left?
		beq.s	locret_169D8			; if not, branch
		neg.w	obVelX(a1)			; move in other direction

locret_169D8:
		rts
; ===========================================================================
; animation script
; off_169DA:
Ani_obj4B:	dc.w byte_169E2-Ani_obj4B
		dc.w byte_169E5-Ani_obj4B
		dc.w byte_169E9-Ani_obj4B
		dc.w byte_169ED-Ani_obj4B
byte_169E2:	dc.b  $F,  0,$FF
byte_169E5:	dc.b   2,  3,  4,$FF
byte_169E9:	dc.b   3,  5,  6,$FF
byte_169ED:	dc.b   9,  1,  1,  1,  1,  1,$FD,  0,  0
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj4B:	binclude	"mappings/sprite/obj4B.bin"
		align 4
loc_16A74:
		jmp	(DeleteObject).l

j_FindNextFreeObj_0:
		jmp	(FindNextFreeObj).l

j_AnimateSprite_4:
		jmp	(AnimateSprite).l

j_Adjust2PArtPointer2:
		jmp	(Adjust2PArtPointer2).l

loc_16A8C:
		jmp	(MarkObjGone_P1).l

j_Adjust2PArtPointer_2:
		jmp	(Adjust2PArtPointer).l

j_ObjectMove_5:
		jmp	(ObjectMove).l
		align 4

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4A - Octopus badnik
; ---------------------------------------------------------------------------

Obj4A:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj4A_Index(pc,d0.w),d1
		jmp	Obj4A_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj4A_Index:	dc.w loc_16ADE-Obj4A_Index
		dc.w loc_16B44-Obj4A_Index
		dc.w loc_16AD2-Obj4A_Index
		dc.w loc_16AB6-Obj4A_Index
; ---------------------------------------------------------------------------

loc_16AB6:
		subi.w	#1,$2C(a0)
		bmi.s	loc_16AC0
		rts
; ---------------------------------------------------------------------------

loc_16AC0:
		bsr.w	j_ObjectMoveAndFall_3
		lea	(Ani_Obj4A).l,a1
		bsr.w	j_AnimateSprite_5
		bra.w	loc_16D3C
; ---------------------------------------------------------------------------

loc_16AD2:
		subq.w	#1,$2C(a0)
		beq.w	loc_16D36
		bra.w	loc_16D30
; ---------------------------------------------------------------------------

loc_16ADE:
		move.l	#Map_Obj4A,obMap(a0)
		move.w	#$238A,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
		bsr.w	j_ObjectMoveAndFall_3
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_16B3C
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		bpl.s	loc_16B3C
		bchg	#0,obStatus(a0)

loc_16B3C:
		move.w	obY(a0),$2A(a0)
		rts
; ---------------------------------------------------------------------------

loc_16B44:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj4A_SubIndex(pc,d0.w),d1
		jsr	Obj4A_SubIndex(pc,d1.w)
		lea	(Ani_Obj4A).l,a1
		bsr.w	j_AnimateSprite_5
		bra.w	loc_16D3C
; ---------------------------------------------------------------------------
Obj4A_SubIndex:	dc.w Obj4A_Init-Obj4A_SubIndex
		dc.w Obj4A_Main-Obj4A_SubIndex
		dc.w loc_16BAA-Obj4A_SubIndex
		dc.w loc_16C7C-Obj4A_SubIndex
; ---------------------------------------------------------------------------

Obj4A_Init:
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		cmpi.w	#$80,d0
		bgt.s	locret_16B86
		cmpi.w	#$FF80,d0
		blt.s	locret_16B86
		addq.b	#2,ob2ndRout(a0)
		move.b	#1,obAnim(a0)

locret_16B86:
		rts
; ---------------------------------------------------------------------------

Obj4A_Main:
		subi.l	#$18000,obY(a0)
		move.w	$2A(a0),d0
		sub.w	obY(a0),d0
		cmpi.w	#$20,d0
		ble.s	locret_16BA8
		addq.b	#2,ob2ndRout(a0)
		move.w	#0,$2C(a0)

locret_16BA8:
		rts
; ---------------------------------------------------------------------------

loc_16BAA:
		subi.w	#1,$2C(a0)
		beq.w	loc_16C76
		bpl.w	locret_16C74
		move.w	#$1E,$2C(a0)
		jsr	(FindFreeObj).l
		bne.s	loc_16C10
		_move.b	#$4A,obID(a1)
		move.b	#4,obRoutine(a1)
		move.l	#Map_Obj4A,obMap(a1)
		move.b	#4,obFrame(a1)
		move.w	#$24C6,obGfx(a1)
		move.b	#3,obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$1E,$2C(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	obStatus(a0),obStatus(a1)

loc_16C10:
		jsr	(FindFreeObj).l
		bne.s	locret_16C74
		_move.b	#$4A,obID(a1)
		move.b	#6,obRoutine(a1)
		move.l	#Map_Obj4A,obMap(a1)
		move.w	#$24C6,obGfx(a1)
		move.b	#4,obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$F,$2C(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)
		move.w	#$FA80,obVelX(a1)
		btst	#0,obRender(a1)
		beq.s	locret_16C74
		neg.w	obVelX(a1)

locret_16C74:
		rts
; ---------------------------------------------------------------------------

loc_16C76:
		addq.b	#2,ob2ndRout(a0)
		rts
; ---------------------------------------------------------------------------

loc_16C7C:
		move.w	#$FFFA,d0
		btst	#0,obRender(a0)
		beq.s	loc_16C8A
		neg.w	d0

loc_16C8A:
		add.w	d0,obX(a0)
		bra.w	loc_16D3C
; ---------------------------------------------------------------------------
Ani_Obj4A:	dc.w byte_16C98-Ani_Obj4A
		dc.w byte_16C9B-Ani_Obj4A
		dc.w byte_16CA0-Ani_Obj4A
byte_16C98:	dc.b  $F,  0,$FF			; 0
byte_16C9B:	dc.b   3,  1,  2,  3,$FF		; 0
byte_16CA0:	dc.b   2,  5,  6,$FF			; 0
Map_Obj4A:	dc.w word_16CB2-Map_Obj4A
		dc.w word_16CC4-Map_Obj4A
		dc.w word_16CDE-Map_Obj4A
		dc.w word_16CF8-Map_Obj4A
		dc.w word_16D12-Map_Obj4A
		dc.w word_16D1C-Map_Obj4A
		dc.w word_16D26-Map_Obj4A
word_16CB2:	dc.w 2
		dc.w $F00D,    0,    0,$FFF0		; 0
		dc.w	$D,    8,    4,$FFF0		; 4
word_16CC4:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0		; 0
		dc.w	 9,  $10,    8,$FFE8		; 4
		dc.w	 9,  $16,   $B,	   0		; 8
word_16CDE:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0		; 0
		dc.w	 9,  $1C,   $E,$FFE8		; 4
		dc.w	 9,  $22,  $11,	   0		; 8
word_16CF8:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0		; 0
		dc.w	 9,  $28,  $14,$FFE8		; 4
		dc.w	 9,  $2E,  $17,	   0		; 8
word_16D12:	dc.w 1
		dc.w $F001,  $34,  $1A,$FFF7		; 0
word_16D1C:	dc.w 1
		dc.w $F201,  $36,  $1B,$FFF0		; 0
word_16D26:	dc.w 1
		dc.w $F201,  $38,  $1C,$FFF0		; 0
; ---------------------------------------------------------------------------

loc_16D30:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_16D36:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

loc_16D3C:
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

j_AnimateSprite_5:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMoveAndFall_3:
		jmp	(ObjectMoveAndFall).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 4C - Bat badnik from HPZ
;----------------------------------------------------

Obj4C:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj4C_Index(pc,d0.w),d1
		jmp	Obj4C_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj4C_Index:	dc.w Obj4C_Init-Obj4C_Index
		dc.w loc_16DA2-Obj4C_Index
		dc.w loc_16E10-Obj4C_Index
; ---------------------------------------------------------------------------

Obj4C_Init:
		move.l	#Map_Obj4C,obMap(a0)
		move.w	#$2530,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
		addq.b	#2,obRoutine(a0)
		move.w	obY(a0),$2E(a0)
		rts
; ---------------------------------------------------------------------------

loc_16DA2:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj4C_SubIndex(pc,d0.w),d1
		jsr	Obj4C_SubIndex(pc,d1.w)
		bsr.w	sub_16DC8
		lea	(Ani_Obj4C).l,a1
		bsr.w	j_AnimateSprite_6
		bra.w	loc_171C4
; ---------------------------------------------------------------------------
Obj4C_SubIndex:	dc.w loc_16F2E-Obj4C_SubIndex
		dc.w loc_16F66-Obj4C_SubIndex
		dc.w loc_16F72-Obj4C_SubIndex

; =============== S U B	R O U T	I N E =======================================


sub_16DC8:
		move.b	$3F(a0),d0
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	$2E(a0),d0
		move.w	d0,obY(a0)
		addq.b	#4,$3F(a0)
		rts
; End of function sub_16DC8


; =============== S U B	R O U T	I N E =======================================


sub_16DE2:
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		cmpi.w	#$80,d0
		bgt.s	locret_16E0E
		cmpi.w	#$FF80,d0
		blt.s	locret_16E0E
		move.b	#4,ob2ndRout(a0)
		move.b	#2,obAnim(a0)
		move.w	#8,$2A(a0)
		move.b	#0,$3E(a0)

locret_16E0E:
		rts
; End of function sub_16DE2

; ---------------------------------------------------------------------------

loc_16E10:
		bsr.w	sub_16F0E
		bsr.w	sub_16EB0
		bsr.w	sub_16E30
		bsr.w	j_ObjectMove_8
		lea	(Ani_Obj4C).l,a1
		bsr.w	j_AnimateSprite_6
		bra.w	loc_171C4
; ---------------------------------------------------------------------------
		rts

; =============== S U B	R O U T	I N E =======================================


sub_16E30:
		tst.b	$3D(a0)
		beq.s	locret_16E42
		bset	#0,obRender(a0)
		bset	#0,obStatus(a0)

locret_16E42:
		rts
; End of function sub_16E30


; =============== S U B	R O U T	I N E =======================================


sub_16E44:
		subi.w	#1,$2C(a0)
		bpl.s	locret_16E8E
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		cmpi.w	#$60,d0
		bgt.s	loc_16E90
		cmpi.w	#$FFA0,d0
		blt.s	loc_16E90
		tst.w	d0
		bpl.s	loc_16E68
		st	$3D(a0)

loc_16E68:
		move.b	#$40,$3F(a0)
		move.w	#$400,obInertia(a0)
		move.b	#4,obRoutine(a0)
		move.b	#3,obAnim(a0)
		move.w	#$C,$2A(a0)
		move.b	#1,$3E(a0)
		moveq	#0,d0

locret_16E8E:
		rts
; ---------------------------------------------------------------------------

loc_16E90:
		cmpi.w	#$80,d0
		bgt.s	loc_16E9C
		cmpi.w	#$FF80,d0
		bgt.s	locret_16E8E

loc_16E9C:
		move.b	#1,obAnim(a0)
		move.b	#0,ob2ndRout(a0)
		move.w	#$18,$2A(a0)
		rts
; End of function sub_16E44


; =============== S U B	R O U T	I N E =======================================


sub_16EB0:
		tst.b	$3D(a0)
		bne.s	loc_16ECA
		moveq	#0,d0
		move.b	$3F(a0),d0
		cmpi.w	#$C0,d0
		bge.s	loc_16EDE
		addq.b	#2,d0
		move.b	d0,$3F(a0)
		rts
; ---------------------------------------------------------------------------

loc_16ECA:
		moveq	#0,d0
		move.b	$3F(a0),d0
		cmpi.w	#$C0,d0
		beq.s	loc_16EDE
		subq.b	#2,d0
		move.b	d0,$3F(a0)
		rts
; ---------------------------------------------------------------------------

loc_16EDE:
		sf	$3D(a0)
		move.b	#0,obAnim(a0)
		move.b	#2,obRoutine(a0)
		move.b	#0,ob2ndRout(a0)
		move.w	#$18,$2A(a0)
		move.b	#1,obAnim(a0)
		bclr	#0,obRender(a0)
		bclr	#0,obStatus(a0)
		rts
; End of function sub_16EB0


; =============== S U B	R O U T	I N E =======================================


sub_16F0E:
		move.b	$3F(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		rts
; End of function sub_16F0E

; ---------------------------------------------------------------------------

loc_16F2E:
		subi.w	#1,$2A(a0)
		bpl.s	locret_16F64
		bsr.w	sub_16DE2
		beq.s	locret_16F64
		jsr	(RandomNumber).l
		andi.b	#$FF,d0
		bne.s	locret_16F64
		move.w	#$18,$2A(a0)
		move.w	#$1E,$2C(a0)
		addq.b	#2,ob2ndRout(a0)
		move.b	#1,obAnim(a0)
		move.b	#0,$3E(a0)

locret_16F64:
		rts
; ---------------------------------------------------------------------------

loc_16F66:
		subq.b	#1,$2A(a0)
		bpl.s	locret_16F70
		subq.b	#2,ob2ndRout(a0)

locret_16F70:
		rts
; ---------------------------------------------------------------------------

loc_16F72:
		bsr.w	sub_16E44
		beq.s	locret_16FB8
		subi.w	#1,$2A(a0)
		bne.s	locret_16FB8
		move.b	$3E(a0),d0
		beq.s	loc_16FA0
		move.b	#0,$3E(a0)
		move.w	#8,$2A(a0)
		bset	#0,obRender(a0)
		bset	#0,obStatus(a0)
		rts
; ---------------------------------------------------------------------------

loc_16FA0:
		move.b	#1,$3E(a0)
		move.w	#$C,$2A(a0)
		bclr	#0,obRender(a0)
		bclr	#0,obStatus(a0)

locret_16FB8:
		rts
; ---------------------------------------------------------------------------
Ani_Obj4C:	dc.w byte_16FC2-Ani_Obj4C
		dc.w byte_16FC6-Ani_Obj4C
		dc.w byte_16FD5-Ani_Obj4C
		dc.w byte_16FE6-Ani_Obj4C
byte_16FC2:	dc.b   1,  0,  5,$FF			; 0
byte_16FC6:	dc.b   1,  1,  6,  1,  6,  2,  7,  2,  7,  1,  6,  1,  6,$FD,  0 ; 0
byte_16FD5:	dc.b   1,  1,  6,  1,  6,  2,  7,  3,  8,  4,  9,  4,  9,  3,  8,$FE ; 0
		dc.b  $A				; 16
byte_16FE6:	dc.b   3, $A, $B, $C, $D, $E,$FF,  0	; 0
Map_Obj4C:	dc.w word_1700C-Map_Obj4C
		dc.w word_1702E-Map_Obj4C
		dc.w word_17050-Map_Obj4C
		dc.w word_17072-Map_Obj4C
		dc.w word_17094-Map_Obj4C
		dc.w word_170AE-Map_Obj4C
		dc.w word_170D0-Map_Obj4C
		dc.w word_170F2-Map_Obj4C
		dc.w word_17114-Map_Obj4C
		dc.w word_17136-Map_Obj4C
		dc.w word_17150-Map_Obj4C
		dc.w word_1716A-Map_Obj4C
		dc.w word_17184-Map_Obj4C
		dc.w word_17196-Map_Obj4C
		dc.w word_171A8-Map_Obj4C
word_1700C:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,    4,    2,$FFF8		; 4
		dc.w $F00B,    8,    4,	   5		; 8
		dc.w $F00B, $808, $804,$FFE3		; 12
word_1702E:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,    4,    2,$FFF8		; 4
		dc.w $F60D,  $14,   $A,	   5		; 8
		dc.w $F60D, $814, $80A,$FFDB		; 12
word_17050:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,    4,    2,$FFF8		; 4
		dc.w $F80D,  $1C,   $E,	   4		; 8
		dc.w $F80D, $81C, $80E,$FFDC		; 12
word_17072:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,    4,    2,$FFF8		; 4
		dc.w $F805,  $24,  $12,$FFEC		; 8
		dc.w $F805,  $28,  $14,	   4		; 12
word_17094:	dc.w 3
		dc.w $F801,  $2C,  $16,	   0		; 0
		dc.w $F005,    0,    0,$FFF8		; 4
		dc.w	 5,    4,    2,$FFF8		; 8
word_170AE:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,  $2E,  $17,$FFF8		; 4
		dc.w $F00B,    8,    4,	   5		; 8
		dc.w $F00B, $808, $804,$FFE3		; 12
word_170D0:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,  $2E,  $17,$FFF8		; 4
		dc.w $F60D,  $14,   $A,	   5		; 8
		dc.w $F60D, $814, $80A,$FFDB		; 12
word_170F2:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,  $2E,  $17,$FFF8		; 4
		dc.w $F80D,  $1C,   $E,	   4		; 8
		dc.w $F80D, $81C, $80E,$FFDC		; 12
word_17114:	dc.w 4
		dc.w $F005,    0,    0,$FFF8		; 0
		dc.w	 5,  $2E,  $17,$FFF8		; 4
		dc.w $F805,  $28,  $14,	   4		; 8
		dc.w $F805,  $24,  $12,$FFEC		; 12
word_17136:	dc.w 3
		dc.w $F801,  $2C,  $16,	   0		; 0
		dc.w $F005,    0,    0,$FFF8		; 4
		dc.w	 5,  $2E,  $17,$FFF8		; 8
word_17150:	dc.w 3
		dc.w $F007,  $32,  $19,$FFF8		; 0
		dc.w $F80D,  $1C,   $E,	   4		; 4
		dc.w $F80D, $81C, $80E,$FFDC		; 8
word_1716A:	dc.w 3
		dc.w $F007,  $32,  $19,$FFF8		; 0
		dc.w $F805,  $28,  $14,	   4		; 4
		dc.w $F805,  $24,  $12,$FFEC		; 8
word_17184:	dc.w 2
		dc.w $F801,  $2C,  $16,	   0		; 0
		dc.w $F007,  $32,  $19,$FFF8		; 4
word_17196:	dc.w 2
		dc.w $F801, $82C, $816,$FFF8		; 0
		dc.w $F007,  $32,  $19,$FFF8		; 4
word_171A8:	dc.w 3
		dc.w $F007,  $32,  $19,$FFF8		; 0
		dc.w $F805, $828, $814,$FFEC		; 4
		dc.w $F805, $824, $812,	   4		; 8
		align 4

loc_171C4:
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

j_AnimateSprite_6:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMove_8:
		jmp	(ObjectMove).l
; ---------------------------------------------------------------------------
		align 4
;----------------------------------------------------
; Object 4E - Aligator badnik from HPZ
;----------------------------------------------------

Obj4E:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj4E_Index(pc,d0.w),d1
		jmp	Obj4E_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj4E_Index:	dc.w Obj4E_Init-Obj4E_Index
		dc.w Obj4E_Main-Obj4E_Index
; ---------------------------------------------------------------------------

Obj4E_Init:
		move.l	#Map_Obj4E,obMap(a0)
		move.w	#$2300,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
		bsr.w	j_ObjectMoveAndFall_4
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	locret_17238
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)

locret_17238:
		rts
; ---------------------------------------------------------------------------

Obj4E_Main:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj4E_SubIndex(pc,d0.w),d1
		jsr	Obj4E_SubIndex(pc,d1.w)
		lea	(Ani_Obj4E).l,a1
		bsr.w	j_AnimateSprite_7
		bra.w	loc_174B8
; ---------------------------------------------------------------------------
Obj4E_SubIndex:	dc.w loc_1725A-Obj4E_SubIndex
		dc.w loc_1727E-Obj4E_SubIndex
; ---------------------------------------------------------------------------

loc_1725A:
		subq.w	#1,$30(a0)
		bpl.s	locret_1727C
		addq.b	#2,ob2ndRout(a0)
		move.w	#$FF40,obVelX(a0)
		move.b	#0,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	locret_1727C
		neg.w	obVelX(a0)

locret_1727C:
		rts
; ---------------------------------------------------------------------------

loc_1727E:
		bsr.w	sub_172B6
		bsr.w	j_ObjectMove_6
		jsr	(ObjHitFloor).l
		cmpi.w	#$FFF8,d1
		blt.s	loc_1729E
		cmpi.w	#$C,d1
		bge.s	loc_1729E
		add.w	d1,obY(a0)
		rts
; ---------------------------------------------------------------------------

loc_1729E:
		subq.b	#2,ob2ndRout(a0)
		move.w	#$3B,$30(a0)
		move.w	#0,obVelX(a0)
		move.b	#1,obAnim(a0)
		rts

; =============== S U B	R O U T	I N E =======================================


sub_172B6:
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		bmi.s	loc_172D0
		cmpi.w	#$40,d0
		bgt.s	loc_172E6
		btst	#0,obStatus(a0)
		beq.s	loc_172DE
		rts
; ---------------------------------------------------------------------------

loc_172D0:
		cmpi.w	#$FFC0,d0
		blt.s	loc_172E6
		btst	#0,obStatus(a0)
		beq.s	loc_172E6

loc_172DE:
		move.b	#2,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_172E6:
		move.b	#0,obAnim(a0)
		rts
; End of function sub_172B6

; ---------------------------------------------------------------------------
Ani_Obj4E:	dc.w byte_172F4-Ani_Obj4E
		dc.w byte_172FC-Ani_Obj4E
		dc.w byte_172FF-Ani_Obj4E
byte_172F4:	dc.b   3,  0,  4,  2,  3,  1,  5,$FF	; 0
byte_172FC:	dc.b  $F,  0,$FF			; 0
byte_172FF:	dc.b   3,  6, $A,  8,  9,  7, $B,$FF,  0 ; 0
Map_Obj4E:	dc.w word_17320-Map_Obj4E
		dc.w word_17342-Map_Obj4E
		dc.w word_17364-Map_Obj4E
		dc.w word_17386-Map_Obj4E
		dc.w word_173A8-Map_Obj4E
		dc.w word_173CA-Map_Obj4E
		dc.w word_173EC-Map_Obj4E
		dc.w word_1740E-Map_Obj4E
		dc.w word_17430-Map_Obj4E
		dc.w word_17452-Map_Obj4E
		dc.w word_17474-Map_Obj4E
		dc.w word_17496-Map_Obj4E
word_17320:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1C,   $E,	   4		; 8
		dc.w	 5,  $20,  $10,	  $C		; 12
word_17342:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1C,   $E,	   4		; 8
		dc.w	 5,  $24,  $12,	  $C		; 12
word_17364:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1C,   $E,	   4		; 8
		dc.w	 5,  $28,  $14,	  $C		; 12
word_17386:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1E,   $F,	   4		; 8
		dc.w	 5,  $20,  $10,	  $C		; 12
word_173A8:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1E,   $F,	   4		; 8
		dc.w	 5,  $24,  $12,	  $C		; 12
word_173CA:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1E,   $F,	   4		; 8
		dc.w	 5,  $28,  $14,	  $C		; 12
word_173EC:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1C,   $E,	   4		; 8
		dc.w	 5,  $20,  $10,	  $C		; 12
word_1740E:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1C,   $E,	   4		; 8
		dc.w	 5,  $24,  $12,	  $C		; 12
word_17430:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1C,   $E,	   4		; 8
		dc.w	 5,  $28,  $14,	  $C		; 12
word_17452:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1E,   $F,	   4		; 8
		dc.w	 5,  $20,  $10,	  $C		; 12
word_17474:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1E,   $F,	   4		; 8
		dc.w	 5,  $24,  $12,	  $C		; 12
word_17496:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC		; 0
		dc.w $F805,  $18,   $C,	   4		; 4
		dc.w	 1,  $1E,   $F,	   4		; 8
		dc.w	 5,  $28,  $14,	  $C		; 12
; ---------------------------------------------------------------------------

loc_174B8:
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

j_AnimateSprite_7:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMoveAndFall_4:
		jmp	(ObjectMoveAndFall).l
; ---------------------------------------------------------------------------

j_ObjectMove_6:
		jmp	(ObjectMove).l

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 53 - Masher from EHZ
; ---------------------------------------------------------------------------

Obj53:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj53_Index(pc,d0.w),d1
		jsr	Obj53_Index(pc,d1.w)
		bra.w	loc_175B8
; ===========================================================================
Obj53_Index:	dc.w Obj53_Init-Obj53_Index
		dc.w Obj53_Main-Obj53_Index
; ===========================================================================

Obj53_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj53,obMap(a0)
		move.w	#$41C,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#9,obColType(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$FC00,obVelY(a0)
		move.w	obY(a0),$30(a0)

Obj53_Main:
		lea	(Ani_obj53).l,a1
		bsr.w	j_AnimateSprite
		bsr.w	j_ObjectMove
		addi.w	#$18,obVelY(a0)
		move.w	$30(a0),d0
		cmp.w	obY(a0),d0
		bcc.s	loc_17548
		move.w	d0,obY(a0)
		move.w	#$FB00,obVelY(a0)

loc_17548:
		move.b	#1,obAnim(a0)
		subi.w	#$C0,d0
		cmp.w	obY(a0),d0
		bcc.s	locret_1756A
		move.b	#0,obAnim(a0)
		tst.w	obVelY(a0)
		bmi.s	locret_1756A
		move.b	#2,obAnim(a0)

locret_1756A:
		rts
; ===========================================================================
; animation script
Ani_obj53:	dc.w byte_17572-Ani_obj53
		dc.w byte_17576-Ani_obj53
		dc.w byte_1757A-Ani_obj53
byte_17572:	dc.b   7,  0,  1,$FF
byte_17576:	dc.b   3,  0,  1,$FF
byte_1757A:	dc.b   7,  0,$FF,  0
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj53:	binclude	"mappings/sprite/obj53.bin"

; ===========================================================================

loc_175B8:
		jmp	(MarkObjGone).l

j_AnimateSprite:
		jmp	(AnimateSprite).l

j_Adjust2PArtPointer:
		jmp	(Adjust2PArtPointer).l

j_ObjectMove:
		jmp	(ObjectMove).l

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 54 - Snail badnik from	EHZ
; ---------------------------------------------------------------------------

Obj54:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj54_Index(pc,d0.w),d1
		jmp	Obj54_Index(pc,d1.w)
; ===========================================================================
Obj54_Index:	dc.w Obj54_Init-Obj54_Index
		dc.w Obj54_Move-Obj54_Index
		dc.w loc_177B4-Obj54_Index
		dc.w loc_177EC-Obj54_Index
		dc.w loc_17772-Obj54_Index
; ===========================================================================

Obj54_Init:
		move.l	#Map_obj54,obMap(a0)
		move.w	#$402,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_3
		ori.b	#4,obRender(a0)
		move.b	#$A,obColType(a0)
		move.b	#4,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#$E,obWidth(a0)
		bsr.w	j_FindNextFreeObj_1
		bne.s	loc_17670
		_move.b	#$54,obID(a1)
		move.b	#6,obRoutine(a1)
		move.l	#Map_obj54,obMap(a1)
		move.w	#$2402,obGfx(a1)
		bsr.w	j_Adjust2PArtPointer2_0
		move.b	#3,obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obRender(a0),obRender(a1)
		move.l	a0,$2A(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#2,obFrame(a1)

loc_17670:
		addq.b	#2,obRoutine(a0)
		move.w	#$FF80,d0
		btst	#0,obStatus(a0)
		beq.s	loc_17682
		neg.w	d0

loc_17682:
		move.w	d0,obVelX(a0)
		rts
; ===========================================================================
; loc_17688:
Obj54_Move:
		bsr.w	sub_176D0
		bsr.w	j_ObjectMove_7
		jsr	(ObjHitFloor).l
		cmpi.w	#-8,d1
		blt.s	Obj54_Display
		cmpi.w	#$C,d1
		bge.s	Obj54_Display
		add.w	d1,obY(a0)
		lea	(Ani_Obj54).l,a1
		bsr.w	j_AnimateSprite_8
		bra.w	loc_1786C
; ===========================================================================
; loc_176B4:
Obj54_Display:
		addq.b	#2,obRoutine(a0)
		move.w	#$14,$30(a0)
		st	$34(a0)
		lea	(Ani_Obj54).l,a1
		bsr.w	j_AnimateSprite_8
		bra.w	loc_1786C

; =============== S U B	R O U T	I N E =======================================


sub_176D0:
		tst.b	$35(a0)
		bne.s	locret_17712
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		cmpi.w	#$64,d0
		bgt.s	locret_17712
		cmpi.w	#$FF9C,d0
		blt.s	locret_17712
		tst.w	d0
		bmi.s	loc_176F8
		btst	#0,obStatus(a0)
		beq.s	locret_17712
		bra.s	loc_17700
; ---------------------------------------------------------------------------

loc_176F8:
		btst	#0,obStatus(a0)
		bne.s	locret_17712

loc_17700:
		move.w	obVelX(a0),d0
		asl.w	#2,d0
		move.w	d0,obVelX(a0)
		st	$35(a0)
		bsr.w	sub_17714

locret_17712:
		rts
; End of function sub_176D0


; =============== S U B	R O U T	I N E =======================================


sub_17714:
		bsr.w	j_FindNextFreeObj_1
		bne.s	locret_17770
		_move.b	#$54,obID(a1)
		move.b	#8,obRoutine(a1)
		move.l	#Map_obj4B,obMap(a1)
		move.w	#$3E6,obGfx(a1)
		bsr.w	j_Adjust2PArtPointer2_0
		move.b	#4,obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obRender(a0),obRender(a1)
		move.l	a0,$2A(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addq.w	#7,obY(a1)
		addi.w	#$D,obX(a1)
		move.b	#1,obAnim(a1)

locret_17770:
		rts
; End of function sub_17714

; ---------------------------------------------------------------------------

loc_17772:
		movea.l	$2A(a0),a1
		cmpi.b	#$54,(a1)
		bne.w	loc_17854
		tst.b	$34(a1)
		bne.w	loc_17854
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		addq.w	#7,obY(a0)
		moveq	#$D,d0
		btst	#0,obStatus(a0)
		beq.s	loc_177A2
		neg.w	d0

loc_177A2:
		add.w	d0,obX(a0)
		lea	(Ani_obj4B).l,a1
		bsr.w	j_AnimateSprite_8
		bra.w	loc_1786C
; ---------------------------------------------------------------------------

loc_177B4:
		subi.w	#1,$30(a0)
		bpl.w	loc_1786C
		neg.w	obVelX(a0)
		bsr.w	j_ObjectMoveAndFall_5
		move.w	obVelX(a0),d0
		asr.w	#2,d0
		move.w	d0,obVelX(a0)
		bchg	#0,obStatus(a0)
		bchg	#0,obRender(a0)
		subq.b	#2,obRoutine(a0)
		sf	$34(a0)
		sf	$35(a0)
		bra.w	loc_1786C
; ---------------------------------------------------------------------------

loc_177EC:
		movea.l	$2A(a0),a1
		cmpi.b	#$54,(a1)
		bne.w	loc_17854
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		bra.w	loc_1786C
; ---------------------------------------------------------------------------
Ani_Obj54:	dc.w byte_17818-Ani_Obj54
		dc.w byte_1781C-Ani_Obj54
byte_17818:	dc.b   5,  0,  1,$FF			; 0
byte_1781C:	dc.b   1,  0,  1,$FF			; 0
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj54:	binclude	"mappings/sprite/obj54.bin"




; ---------------------------------------------------------------------------

loc_17854:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

j_FindNextFreeObj_1:
		jmp	(FindNextFreeObj).l
; ---------------------------------------------------------------------------

j_AnimateSprite_8:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_Adjust2PArtPointer2_0:
		jmp	(Adjust2PArtPointer2).l
; ---------------------------------------------------------------------------

loc_1786C:
		jmp	(MarkObjGone_P1).l
; ---------------------------------------------------------------------------

j_Adjust2PArtPointer_3:
		jmp	(Adjust2PArtPointer).l
; ---------------------------------------------------------------------------

j_ObjectMoveAndFall_5:
		jmp	(ObjectMoveAndFall).l
; ---------------------------------------------------------------------------

j_ObjectMove_7:
		jmp	(ObjectMove).l
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 57 - sub object of the	EHZ boss
;----------------------------------------------------

Obj57:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	off_17892(pc,d0.w),d1
		jmp	off_17892(pc,d1.w)
; ---------------------------------------------------------------------------
off_17892:	dc.w loc_1789E-off_17892		; 0
		dc.w loc_178C4-off_17892		; 1
		dc.w loc_17920-off_17892		; 2
		dc.w loc_17952-off_17892		; 3
		dc.w loc_1797C-off_17892		; 4
		dc.w loc_17996-off_17892		; 5
; ---------------------------------------------------------------------------

loc_1789E:
		move.b	#0,obColType(a0)
		cmpi.w	#$29D0,obX(a0)
		ble.s	loc_178B6
		subi.w	#1,obX(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_178B6:
		move.w	#$29D0,obX(a0)
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_178C4:
		moveq	#0,d0
		move.b	$2C(a0),d0
		move.w	off_178D2(pc,d0.w),d1
		jmp	off_178D2(pc,d1.w)
; ---------------------------------------------------------------------------
off_178D2:	dc.w loc_178D6-off_178D2
		dc.w loc_178FC-off_178D2
; ---------------------------------------------------------------------------

loc_178D6:
		cmpi.w	#$41E,obY(a0)
		bge.s	loc_178E8
		addi.w	#1,obY(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_178E8:
		addq.b	#2,$2C(a0)
		bset	#0,$2D(a0)
		move.w	#$3C,$2A(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_178FC:
		subi.w	#1,$2A(a0)
		bpl.w	loc_181A8
		move.w	#$FE00,obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.b	#$F,obColType(a0)
		bset	#1,$2D(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17920:
		bsr.w	sub_17A8C
		bsr.w	sub_17A6A
		move.w	$2E(a0),d0
		lsr.w	#1,d0
		subi.w	#$14,d0
		move.w	d0,obY(a0)
		move.w	#0,$2E(a0)
		move.l	obX(a0),d2
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,obX(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17952:
		subq.w	#1,$3C(a0)
		bpl.w	BossDefeated
		bset	#0,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#$FFDA,$3C(a0)
		move.w	#$C,$2A(a0)
		rts
; ---------------------------------------------------------------------------

loc_1797C:
		addq.w	#1,obY(a0)
		subq.w	#1,$2A(a0)
		bpl.w	loc_181A8
		addq.b	#2,ob2ndRout(a0)
		move.b	#0,$2C(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17996:
		moveq	#0,d0
		move.b	$2C(a0),d0
		move.w	off_179A8(pc,d0.w),d1
		jsr	off_179A8(pc,d1.w)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------
off_179A8:	dc.w loc_179AE-off_179A8
		dc.w loc_17A22-off_179A8
		dc.w loc_17A3C-off_179A8
; ---------------------------------------------------------------------------

loc_179AE:
		bclr	#0,$2D(a0)
		bsr.w	j_FindNextFreeObj
		bne.w	loc_181A8
		_move.b	#$58,obID(a1)
		move.l	a0,$34(a1)
		move.l	#Map_Obj58,obMap(a1)
		move.w	#$2540,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.b	#4,obPriority(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		addi.w	#$C,obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	#8,obRoutine(a1)
		move.b	#2,obAnim(a1)
		move.w	#$10,$2A(a1)
		move.w	#$32,$2A(a0)
		addq.b	#2,$2C(a0)
		rts
; ---------------------------------------------------------------------------

loc_17A22:
		subi.w	#1,$2A(a0)
		bpl.s	locret_17A3A
		bset	#2,$2D(a0)
		move.w	#$60,$2A(a0)
		addq.b	#2,$2C(a0)

locret_17A3A:
		rts
; ---------------------------------------------------------------------------

loc_17A3C:
		subq.w	#1,obY(a0)
		subi.w	#1,$2A(a0)
		bpl.s	locret_17A68
		addq.w	#1,obY(a0)
		addq.w	#2,obX(a0)
		cmpi.w	#$2B08,obX(a0)
		bcs.s	locret_17A68
		tst.b	(Boss_defeated_flag).w
		bne.s	locret_17A68
		move.b	#1,(Boss_defeated_flag).w
		bra.w	loc_181AE
; ---------------------------------------------------------------------------

locret_17A68:
		rts

; =============== S U B	R O U T	I N E =======================================


sub_17A6A:
		move.w	obX(a0),d0
		cmpi.w	#$2720,d0
		ble.s	loc_17A7A
		cmpi.w	#$2B08,d0
		blt.s	locret_17A8A

loc_17A7A:
		bchg	#0,obStatus(a0)
		bchg	#0,obRender(a0)
		neg.w	obVelX(a0)

locret_17A8A:
		rts
; End of function sub_17A6A


; =============== S U B	R O U T	I N E =======================================


sub_17A8C:
		cmpi.b	#6,ob2ndRout(a0)
		bcc.s	locret_17AD2
		tst.b	obStatus(a0)
		bmi.s	loc_17AD4
		tst.b	obColType(a0)
		bne.s	locret_17AD2
		tst.b	$3E(a0)
		bne.s	loc_17AB6
		move.b	#$20,$3E(a0)
		move.w	#sfx_HitBoss,d0
		jsr	(PlaySound_Special).l

loc_17AB6:
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_17AC4
		move.w	#$EEE,d0

loc_17AC4:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_17AD2
		move.b	#$F,obColType(a0)

locret_17AD2:
		rts
; ---------------------------------------------------------------------------

loc_17AD4:
		moveq	#$64,d0
		bsr.w	AddPoints
		move.b	#6,ob2ndRout(a0)
		move.w	#$B3,$3C(a0)
		bset	#3,$2D(a0)
		rts
; End of function sub_17A8C

; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 58 - sub object of the	EHZ boss
;----------------------------------------------------

Obj58:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	off_17AFC(pc,d0.w),d1
		jmp	off_17AFC(pc,d1.w)
; ---------------------------------------------------------------------------
off_17AFC:	dc.w loc_17B2A-off_17AFC
		dc.w loc_17BB0-off_17AFC
		dc.w loc_17C02-off_17AFC
		dc.w loc_17CE4-off_17AFC
		dc.w loc_17B06-off_17AFC
; ---------------------------------------------------------------------------

loc_17B06:
		subi.w	#1,obY(a0)
		subi.w	#1,$2A(a0)
		bpl.w	loc_181A8
		move.b	#0,obRoutine(a0)
		lea	(Ani_Obj58).l,a1
		bsr.w	j_AnimateSprite_9
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17B2A:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	off_17B38(pc,d0.w),d1
		jmp	off_17B38(pc,d1.w)
; ---------------------------------------------------------------------------
off_17B38:	dc.w loc_17B3C-off_17B38
		dc.w loc_17B86-off_17B38
; ---------------------------------------------------------------------------

loc_17B3C:
		movea.l	$34(a0),a1
		cmpi.b	#$55,(a1)
		bne.w	loc_181AE
		btst	#0,$2D(a1)
		beq.s	loc_17B60
		move.b	#1,obAnim(a0)
		move.w	#$18,$2A(a0)
		addq.b	#2,ob2ndRout(a0)

loc_17B60:
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		lea	(Ani_Obj58).l,a1
		bsr.w	j_AnimateSprite_9
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17B86:
		subi.w	#1,$2A(a0)
		bpl.s	loc_17BA2
		cmpi.w	#$FFF0,$2A(a0)
		ble.w	loc_181AE
		addi.w	#1,obY(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17BA2:
		lea	(Ani_Obj58).l,a1
		bsr.w	j_AnimateSprite_9
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17BB0:
		movea.l	$34(a0),a1
		cmpi.b	#$55,(a1)
		bne.w	loc_181AE
		btst	#1,$2D(a1)
		beq.w	loc_181A8
		btst	#2,$2D(a1)
		bne.w	loc_17BF2
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		addi.w	#8,obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17BF2:
		move.b	#8,obFrame(a0)
		move.b	#0,obPriority(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17C02:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	off_17C10(pc,d0.w),d1
		jmp	off_17C10(pc,d1.w)
; ---------------------------------------------------------------------------
off_17C10:	dc.w loc_17C18-off_17C10
		dc.w loc_17C36-off_17C10
		dc.w loc_17C96-off_17C10
		dc.w loc_17CC2-off_17C10
; ---------------------------------------------------------------------------

loc_17C18:
		movea.l	$34(a0),a1
		cmpi.b	#$55,(a1)
		bne.w	loc_181AE
		btst	#1,$2D(a1)
		beq.w	loc_181A8
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17C36:
		movea.l	$34(a0),a1
		cmpi.b	#$55,(a1)
		bne.w	loc_181AE
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		tst.b	obStatus(a0)
		bpl.s	loc_17C58
		addq.b	#2,ob2ndRout(a0)

loc_17C58:
		bsr.w	sub_17A6A
		bsr.w	j_ObjectMoveAndFall_6
		jsr	(ObjHitFloor).l
		tst.w	d1
		bpl.s	loc_17C6E
		add.w	d1,obY(a0)

loc_17C6E:
		move.w	#$100,obVelY(a0)
		cmpi.b	#1,obPriority(a0)
		bne.s	loc_17C88
		move.w	obY(a0),d0
		movea.l	$34(a0),a1
		add.w	d0,$2E(a1)

loc_17C88:
		lea	(Ani_Obj58a).l,a1
		bsr.w	j_AnimateSprite_9
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17C96:
		subi.w	#1,$2A(a0)
		bpl.w	loc_181A8
		addq.b	#2,ob2ndRout(a0)
		move.w	#$A,$2A(a0)
		move.w	#$FD00,obVelY(a0)
		cmpi.b	#1,obPriority(a0)
		beq.w	loc_181A8
		neg.w	obVelX(a0)
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17CC2:
		subq.w	#1,$2A(a0)
		bpl.w	loc_181A8
		bsr.w	j_ObjectMoveAndFall_6
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	loc_17CE0
		move.w	#$FE00,obVelY(a0)
		add.w	d1,obY(a0)

loc_17CE0:
		bra.w	loc_181B4
; ---------------------------------------------------------------------------

loc_17CE4:
		movea.l	$34(a0),a1
		cmpi.b	#$55,(a1)
		bne.w	loc_181AE
		btst	#3,$2D(a1)
		bne.s	loc_17D4A
		bsr.w	sub_17D6A
		btst	#1,$2D(a1)
		beq.w	loc_181A8
		move.b	#$8B,obColType(a0)
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		addi.w	#$10,obY(a0)
		move.w	#$FFCA,d0
		btst	#0,obStatus(a0)
		beq.s	loc_17D38
		neg.w	d0

loc_17D38:
		add.w	d0,obX(a0)
		lea	(Ani_Obj58a).l,a1
		bsr.w	j_AnimateSprite_9
		bra.w	loc_181A8
; ---------------------------------------------------------------------------

loc_17D4A:
		move.w	#$FFFD,d0
		btst	#0,obStatus(a0)
		beq.s	loc_17D58
		neg.w	d0

loc_17D58:
		add.w	d0,obX(a0)
		lea	(Ani_Obj58a).l,a1
		bsr.w	j_AnimateSprite_9
		bra.w	loc_181A8

; =============== S U B	R O U T	I N E =======================================


sub_17D6A:
		cmpi.b	#1,obColProp(a1)
		beq.s	loc_17D74
		rts
; ---------------------------------------------------------------------------

loc_17D74:
		move.w	obX(a0),d0
		sub.w	(v_objspace+obX).w,d0
		bpl.s	loc_17D88
		btst	#0,obStatus(a1)
		bne.s	loc_17D92
		rts
; ---------------------------------------------------------------------------

loc_17D88:
		btst	#0,obStatus(a1)
		beq.s	loc_17D92
		rts
; ---------------------------------------------------------------------------

loc_17D92:
		bset	#3,$2D(a1)
		rts
; End of function sub_17D6A


; =============== S U B	R O U T	I N E =======================================


sub_17D9A:
		jsr	(FindNextFreeObj).l
		bne.s	loc_17E0E
		_move.b	#$58,obID(a1)
		move.l	a0,$34(a1)
		move.l	#Map_Obj58a,obMap(a1)
		move.w	#$24C0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$10,obActWid(a1)
		move.b	#1,obPriority(a1)
		move.b	#$10,obHeight(a1)
		move.b	#$10,obWidth(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		addi.w	#$1C,obX(a1)
		addi.w	#$C,obY(a1)
		move.w	#$FE00,obVelX(a1)
		move.b	#4,obRoutine(a1)
		move.b	#4,obFrame(a1)
		move.b	#1,obAnim(a1)
		move.w	#$16,$2A(a1)

loc_17E0E:
		jsr	(FindNextFreeObj).l
		bne.s	loc_17E82
		_move.b	#$58,obID(a1)
		move.l	a0,$34(a1)
		move.l	#Map_Obj58a,obMap(a1)
		move.w	#$24C0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$10,obActWid(a1)
		move.b	#1,obPriority(a1)
		move.b	#$10,obHeight(a1)
		move.b	#$10,obWidth(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		addi.w	#$FFF4,obX(a1)
		addi.w	#$C,obY(a1)
		move.w	#$FE00,obVelX(a1)
		move.b	#4,obRoutine(a1)
		move.b	#4,obFrame(a1)
		move.b	#1,obAnim(a1)
		move.w	#$4B,$2A(a1)

loc_17E82:
		jsr	(FindNextFreeObj).l
		bne.s	loc_17EF6
		_move.b	#$58,obID(a1)
		move.l	a0,$34(a1)
		move.l	#Map_Obj58a,obMap(a1)
		move.w	#$24C0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$10,obActWid(a1)
		move.b	#2,obPriority(a1)
		move.b	#$10,obHeight(a1)
		move.b	#$10,obWidth(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		addi.w	#$FFD4,obX(a1)
		addi.w	#$C,obY(a1)
		move.w	#$FE00,obVelX(a1)
		move.b	#4,obRoutine(a1)
		move.b	#6,obFrame(a1)
		move.b	#2,obAnim(a1)
		move.w	#$30,$2A(a1)

loc_17EF6:
		jsr	(FindNextFreeObj).l
		bne.s	locret_17F52
		_move.b	#$58,obID(a1)
		move.l	a0,$34(a1)
		move.l	#Map_Obj58a,obMap(a1)
		move.w	#$24C0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$10,obActWid(a1)
		move.b	#1,obPriority(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		addi.w	#$FFCA,obX(a1)
		addi.w	#8,obY(a1)
		move.b	#6,obRoutine(a1)
		move.b	#1,obFrame(a1)
		move.b	#0,obAnim(a1)

locret_17F52:
		rts
; End of function sub_17D9A

; ---------------------------------------------------------------------------

loc_17F54:
		jsr	(FindNextFreeObj).l
		bne.s	loc_17F98
		_move.b	#$58,obID(a1)
		move.l	a0,$34(a1)
		move.l	#Map_Obj58a,obMap(a1)
		move.w	#$4C0,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.b	#2,obPriority(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		move.b	#2,obRoutine(a1)

loc_17F98:
		bsr.w	sub_17D9A
		subi.w	#8,$38(a0)
		move.w	#$2A00,obX(a0)
		move.w	#$2C0,obY(a0)
		jsr	(FindNextFreeObj).l
		bne.s	locret_17FF8
		_move.b	#$58,obID(a1)
		move.l	a0,$34(a1)
		move.l	#Map_Obj58,obMap(a1)
		move.w	#$2540,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.b	#4,obPriority(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		move.w	#$1E,$2A(a1)
		move.b	#0,obRoutine(a1)

locret_17FF8:
		rts
; ---------------------------------------------------------------------------
Ani_Obj58:	dc.w byte_18000-Ani_Obj58
		dc.w byte_18004-Ani_Obj58
		dc.w byte_1801A-Ani_Obj58
byte_18000:	dc.b   1,  5,  6,$FF			; 0
byte_18004:	dc.b   1,  1,  1,  1,  2,  2,  2,  3,  3,  3,  4,  4,  4,  0,  0,  0 ; 0
		dc.b   0,  0,  0,  0,  0,$FF		; 16
byte_1801A:	dc.b   1,  0,  0,  0,  0,  0,  0,  0,  0,  4,  4,  4,  3,  3,  3,  2 ; 0
		dc.b   2,  2,  1,  1,  1,  5,  6,$FE,  2,  0 ; 16
Map_Obj58:	dc.w word_18042-Map_Obj58
		dc.w word_1804C-Map_Obj58
		dc.w word_18076-Map_Obj58
		dc.w word_180A0-Map_Obj58
		dc.w word_180BA-Map_Obj58
		dc.w word_180D4-Map_Obj58
		dc.w word_180EE-Map_Obj58
word_18042:	dc.w 1
		dc.w $D805,    0,    0,	   2		; 0
word_1804C:	dc.w 5
		dc.w $D805,    4,    2,	   2		; 0
		dc.w $D80D,   $C,    6,	 $12		; 4
		dc.w $D80D,   $C,    6,	 $32		; 8
		dc.w $D80D,   $C,    6,$FFE2		; 12
		dc.w $D80D,   $C,    6,$FFC2		; 16
word_18076:	dc.w 5
		dc.w $D805,    4,    2,	   2		; 0
		dc.w $D80D,   $C,    6,	 $12		; 4
		dc.w $D805,    8,    4,	 $32		; 8
		dc.w $D80D,   $C,    6,$FFE2		; 12
		dc.w $D805,    8,    4,$FFD2		; 16
word_180A0:	dc.w 3
		dc.w $D805,    4,    2,	   2		; 0
		dc.w $D80D,   $C,    6,	 $12		; 4
		dc.w $D80D,   $C,    6,$FFE2		; 8
word_180BA:	dc.w 3
		dc.w $D805,    4,    2,	   2		; 0
		dc.w $D805,    8,    4,	 $12		; 4
		dc.w $D805,    8,    4,$FFF2		; 8
word_180D4:	dc.w 3
		dc.w $D805,    0,    0,	   2		; 0
		dc.w $D80D,   $C,    6,	 $12		; 4
		dc.w $D80D,   $C,    6,	 $32		; 8
word_180EE:	dc.w 3
		dc.w $D805,    4,    2,	   2		; 0
		dc.w $D80D,   $C,    6,$FFE2		; 4
		dc.w $D80D,   $C,    6,$FFC2		; 8
Ani_Obj58a:	dc.w byte_1810E-Ani_Obj58a
		dc.w byte_18113-Ani_Obj58a
		dc.w byte_18117-Ani_Obj58a
byte_1810E:	dc.b   5,  1,  2,  3,$FF		; 0
byte_18113:	dc.b   1,  4,  5,$FF			; 0
byte_18117:	dc.b   1,  6,  7,$FF,  0		; 0
Map_Obj58a:	dc.w word_1812E-Map_Obj58a
		dc.w word_18148-Map_Obj58a
		dc.w word_18152-Map_Obj58a
		dc.w word_1815C-Map_Obj58a
		dc.w word_18166-Map_Obj58a
		dc.w word_18170-Map_Obj58a
		dc.w word_1817A-Map_Obj58a
		dc.w word_18184-Map_Obj58a
		dc.w word_1818E-Map_Obj58a
word_1812E:	dc.w 3
		dc.w $F00F,    0,    0,$FFD0		; 0
		dc.w $F00F,  $10,    8,$FFF0		; 4
		dc.w $F00F,  $20,  $10,	 $10		; 8
word_18148:	dc.w 1
		dc.w $F00F,  $30,  $18,$FFF0		; 0
word_18152:	dc.w 1
		dc.w $F00F,  $40,  $20,$FFF0		; 0
word_1815C:	dc.w 1
		dc.w $F00F,  $50,  $28,$FFF0		; 0
word_18166:	dc.w 1
		dc.w $F00F,  $60,  $30,$FFF0		; 0
word_18170:	dc.w 1
		dc.w $F00F,$1060,$1030,$FFF0		; 0
word_1817A:	dc.w 1
		dc.w $F00F,  $70,  $38,$FFF0		; 0
word_18184:	dc.w 1
		dc.w $F00F,$1070,$1038,$FFF0		; 0
word_1818E:	dc.w 3
		dc.w $F00F,$8000,$8000,$FFD0		; 0
		dc.w $F00F,$8010,$8008,$FFF0		; 4
		dc.w $F00F,$8020,$8010,	 $10		; 8
; ---------------------------------------------------------------------------

loc_181A8:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_181AE:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

loc_181B4:
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

j_FindNextFreeObj:
		jmp	(FindNextFreeObj).l
; ---------------------------------------------------------------------------

j_AnimateSprite_9:
		jmp	(AnimateSprite).l
; ---------------------------------------------------------------------------

j_ObjectMoveAndFall_6:
		jmp	(ObjectMoveAndFall).l
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 55 - EHZ boss
; ---------------------------------------------------------------------------

Obj55:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj55_Index(pc,d0.w),d1
		jmp	Obj55_Index(pc,d1.w)
; ===========================================================================
Obj55_Index:	dc.w Obj55_Init-Obj55_Index
		dc.w loc_18302-Obj55_Index
		dc.w loc_18340-Obj55_Index
		dc.w loc_18372-Obj55_Index
		dc.w loc_18410-Obj55_Index
; ===========================================================================
; loc_181E4:
Obj55_Init:
		move.l	#Map_Obj55,obMap(a0)
		move.w	#$2400,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$20,obActWid(a0)
		move.b	#3,obPriority(a0)
		move.b	#$F,obColType(a0)
		move.b	#8,obColProp(a0)
		addq.b	#2,obRoutine(a0)
		move.w	obX(a0),$30(a0)
		move.w	obY(a0),$38(a0)
		move.b	obSubtype(a0),d0
		cmpi.b	#$81,d0
		bne.s	loc_18230
		addi.w	#$60,obGfx(a0)

loc_18230:
		jsr	(FindNextFreeObj).l
		bne.w	loc_182E8
		_move.b	#$55,obID(a1)
		move.l	a0,$34(a1)
		move.l	a1,$34(a0)
		move.l	#Map_Obj55,obMap(a1)
		move.w	#$400,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.b	#3,obPriority(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		addq.b	#4,obRoutine(a1)
		move.b	#1,obAnim(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	obSubtype(a0),d0
		cmpi.b	#$81,d0
		bne.s	loc_18294
		addi.w	#$60,obGfx(a1)

loc_18294:
		tst.b	obSubtype(a0)
		bmi.s	loc_182E8
		jsr	(FindNextFreeObj).l
		bne.s	loc_182E8
		_move.b	#$55,obID(a1)
		move.l	a0,$34(a1)

loc_182AC:
		move.l	#Map_Obj55a,obMap(a1)
		move.w	#$4D0,obGfx(a1)
		move.b	#1,obTimeFrame(a0)

loc_182C0:
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.b	#3,obPriority(a1)
		move.l	obX(a0),obX(a1)
		move.l	obY(a0),obY(a1)
		addq.b	#6,obRoutine(a1)
		move.b	obRender(a0),obRender(a1)

loc_182E8:
		move.b	obSubtype(a0),d0
		andi.w	#$7F,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	dword_182FA(pc,d0.w),a1
		jmp	(a1)
; ===========================================================================
dword_182FA:	dc.l 0
		dc.l loc_17F54
; ===========================================================================

loc_18302:
		move.b	obSubtype(a0),d0
		andi.w	#$7F,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	dword_18338(pc,d0.w),a1
		jsr	(a1)
		lea	(Ani_Obj55a).l,a1
		jsr	(AnimateSprite).l
		move.b	obStatus(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp	(DisplaySprite).l
; ===========================================================================
dword_18338:	dc.l 0
		dc.l Obj57
; ===========================================================================

loc_18340:
		movea.l	$34(a0),a1
		move.l	obX(a1),obX(a0)
		move.l	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		movea.l	#Ani_Obj55a,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ===========================================================================
byte_1836E:	dc.b   0,$FF,  1,  0			; 0
; ===========================================================================

loc_18372:
		btst	#7,obStatus(a0)
		bne.s	loc_183C6
		movea.l	$34(a0),a1
		move.l	obX(a1),obX(a0)
		move.l	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		move.b	obRender(a1),obRender(a0)
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_183BA
		move.b	#1,obTimeFrame(a0)
		move.b	$2A(a0),d0
		addq.b	#1,d0
		cmpi.b	#2,d0
		ble.s	loc_183B0
		moveq	#0,d0

loc_183B0:
		move.b	byte_1836E(pc,d0.w),obFrame(a0)
		move.b	d0,$2A(a0)

loc_183BA:
		cmpi.b	#$FF,obFrame(a0)
		bne.w	loc_185D4
		rts
; ===========================================================================

loc_183C6:
		movea.l	$34(a0),a1
		btst	#6,$2E(a1)
		bne.s	loc_183D4
		rts
; ===========================================================================

loc_183D4:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj55b,obMap(a0)
		move.w	#$4D8,obGfx(a0)
		move.b	#0,obFrame(a0)
		move.b	#5,obTimeFrame(a0)
		movea.l	$34(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		addi.w	#4,obY(a0)
		subi.w	#$28,obX(a0)
		rts
; ===========================================================================

loc_18410:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_18452
		move.b	#5,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#4,obFrame(a0)
		bne.w	loc_18452
		move.b	#0,obFrame(a0)
		movea.l	$34(a0),a1
		move.b	(a1),d0
		beq.w	loc_185DA
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		addi.w	#4,obY(a0)
		subi.w	#$28,obX(a0)

loc_18452:
		bra.w	loc_185D4
; ===========================================================================

Obj56:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj56_Index(pc,d0.w),d1
		jmp	Obj56_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj56_Index:	dc.w Obj56_Init-Obj56_Index
		dc.w Obj56_Animate-Obj56_Index
; ---------------------------------------------------------------------------

Obj56_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj56,obMap(a0)
		move.w	#$5A0,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		rts
; ---------------------------------------------------------------------------

Obj56_Animate:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_184BA
		move.b	#7,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#7,obFrame(a0)
		beq.w	loc_185DA

loc_184BA:
		bra.w	loc_185D4
; ---------------------------------------------------------------------------
Map_Obj55a:	dc.w word_184C2-Map_Obj55a
		dc.w word_184CC-Map_Obj55a
word_184C2:	dc.w 1
		dc.w	 5,    0,    0,	 $1C		; 0
word_184CC:	dc.w 1
		dc.w	 5,    4,    2,	 $1C		; 0
Map_Obj55b:	dc.w word_184DE-Map_Obj55b
		dc.w word_184E8-Map_Obj55b
		dc.w word_184F2-Map_Obj55b
		dc.w word_184FC-Map_Obj55b
word_184DE:	dc.w 1
		dc.w $F805,    0,    0,$FFF8		; 0
word_184E8:	dc.w 1
		dc.w $F805,    4,    2,$FFF8		; 0
word_184F2:	dc.w 1
		dc.w $F805,    8,    4,$FFF8		; 0
word_184FC:	dc.w 1
		dc.w $F805,   $C,    6,$FFF8		; 0
Map_Obj56:	dc.w word_18514-Map_Obj56
		dc.w word_1851E-Map_Obj56
		dc.w word_18528-Map_Obj56
		dc.w word_18532-Map_Obj56
		dc.w word_1853C-Map_Obj56
		dc.w word_18546-Map_Obj56
		dc.w word_18550-Map_Obj56
word_18514:	dc.w 1
		dc.w $F805,    0,    0,$FFF8		; 0
word_1851E:	dc.w 1
		dc.w $F00F,    4,    2,$FFF0		; 0
word_18528:	dc.w 1
		dc.w $F00F,  $14,   $A,$FFF0		; 0
word_18532:	dc.w 1
		dc.w $F00F,  $24,  $12,$FFF0		; 0
word_1853C:	dc.w 1
		dc.w $F00F,  $34,  $1A,$FFF0		; 0
word_18546:	dc.w 1
		dc.w $F00F,  $44,  $22,$FFF0		; 0
word_18550:	dc.w 1
		dc.w $F00F,  $54,  $2A,$FFF0		; 0
Ani_Obj55a:	dc.w byte_1855E-Ani_Obj55a
		dc.w byte_18561-Ani_Obj55a
byte_1855E:	dc.b  $F,  0,$FF			; 0
byte_18561:	dc.b   7,  1,  2,$FF,  0		; 0
Map_Obj55:	dc.w word_1856C-Map_Obj55
		dc.w word_1858E-Map_Obj55
		dc.w word_185B0-Map_Obj55
word_1856C:	dc.w 4
		dc.w $F805,    0,    0,$FFE0		; 0
		dc.w  $805,    4,    2,$FFE0		; 4
		dc.w $F80F,    8,    4,$FFF0		; 8
		dc.w $F807,  $18,   $C,	 $10		; 12
word_1858E:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0		; 0
		dc.w $E80D,  $30,  $18,$FFF0		; 4
		dc.w $E805,  $24,  $12,	 $10		; 8
		dc.w $D805,  $20,  $10,	   2		; 12
word_185B0:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0		; 0
		dc.w $E80D,  $38,  $1C,$FFF0		; 4
		dc.w $E805,  $24,  $12,	 $10		; 8
		dc.w $D805,  $20,  $10,	   2		; 12
; ---------------------------------------------------------------------------
		nop

loc_185D4:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_185DA:
		jmp	(DeleteObject).l
; ===========================================================================
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
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj8A:	binclude	"mappings/sprite/obj8A.bin"

; ===========================================================================
		nop

j_Adjust2PArtPointer_4:					; JmpTo
		jmp	(Adjust2PArtPointer).l

		align 4

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3D - GHZ Boss
; ---------------------------------------------------------------------------

Obj3D:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj3D_Index(pc,d0.w),d1
		jmp	Obj3D_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj3D_Index:	dc.w Obj3D_Main-Obj3D_Index
		dc.w Obj3D_ShipMain-Obj3D_Index
		dc.w Obj3D_FaceMain-Obj3D_Index
		dc.w Obj3D_FlameMain-Obj3D_Index
Obj3D_ObjData:	dc.b   2,  0				; 0
		dc.b   4,  1				; 2
		dc.b   6,  7				; 4
; ---------------------------------------------------------------------------

Obj3D_Main:
		lea	Obj3D_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#2,d1
		bra.s	loc_18D2A
; ---------------------------------------------------------------------------

loc_18D22:
		jsr	(FindNextFreeObj).l
		bne.s	loc_18D70

loc_18D2A:
		move.b	(a2)+,obRoutine(a1)
		_move.b	#$3D,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Eggman,obMap(a1)
		move.w	#$400,obGfx(a1)
		bsr.w	j_Adjust2PArtPointer2_1
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.b	#3,obPriority(a1)
		move.b	(a2)+,obAnim(a1)
		move.l	a0,$34(a1)
		dbf	d1,loc_18D22

loc_18D70:
		move.w	obX(a0),$30(a0)
		move.w	obY(a0),$38(a0)
		move.b	#$F,obColType(a0)
		move.b	#8,obColProp(a0)

Obj3D_ShipMain:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj3D_ShipIndex(pc,d0.w),d1
		jsr	Obj3D_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l
		move.b	obStatus(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------
Obj3D_ShipIndex:dc.w loc_18DC8-Obj3D_ShipIndex
		dc.w loc_18EC8-Obj3D_ShipIndex
		dc.w loc_18F18-Obj3D_ShipIndex
		dc.w loc_18F52-Obj3D_ShipIndex
		dc.w loc_18F78-Obj3D_ShipIndex
		dc.w loc_18FAA-Obj3D_ShipIndex
		dc.w loc_18FF6-Obj3D_ShipIndex
; ---------------------------------------------------------------------------

loc_18DC8:
		move.w	#$100,obVelY(a0)
		bsr.w	BossMove
		cmpi.w	#$338,$38(a0)
		bne.s	loc_18DE4
		move.w	#0,obVelY(a0)
		addq.b	#2,ob2ndRout(a0)

loc_18DE4:
		move.b	$3F(a0),d0
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	$38(a0),d0
		move.w	d0,obY(a0)
		move.w	$30(a0),obX(a0)
		addq.b	#2,$3F(a0)
		cmpi.b	#8,ob2ndRout(a0)
		bcc.s	locret_18E48
		tst.b	obStatus(a0)
		bmi.s	loc_18E4A
		tst.b	obColType(a0)
		bne.s	locret_18E48
		tst.b	$3E(a0)
		bne.s	loc_18E2C
		move.b	#$20,$3E(a0)
		move.w	#sfx_HitBoss,d0
		jsr	(PlaySound_Special).l

loc_18E2C:
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_18E3A
		move.w	#$EEE,d0

loc_18E3A:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_18E48
		move.b	#$F,obColType(a0)

locret_18E48:
		rts
; ---------------------------------------------------------------------------

loc_18E4A:
		moveq	#$64,d0
		bsr.w	AddPoints
		move.b	#8,ob2ndRout(a0)
		move.w	#$B3,$3C(a0)
		rts

; =============== S U B	R O U T	I N E =======================================


BossDefeated:
		move.b	($FFFFFE0F).w,d0
		andi.b	#7,d0
		bne.s	locret_18EA0
		jsr	(FindFreeObj).l
		bne.s	locret_18EA0
		_move.b	#$3F,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr	(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

locret_18EA0:
		rts
; End of function BossDefeated


; =============== S U B	R O U T	I N E =======================================


BossMove:
		move.l	$30(a0),d2
		move.l	$38(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,$30(a0)
		move.l	d3,$38(a0)
		rts
; End of function BossMove

; ---------------------------------------------------------------------------

loc_18EC8:
		move.w	#$FF00,obVelX(a0)
		move.w	#$FFC0,obVelY(a0)
		bsr.w	BossMove
		cmpi.w	#$2A00,$30(a0)
		bne.s	loc_18F14
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,ob2ndRout(a0)
		jsr	(FindNextFreeObj).l
		bne.s	loc_18F0E
		_move.b	#$48,obID(a1)
		move.w	$30(a0),obX(a1)
		move.w	$38(a0),obY(a1)
		move.l	a0,$34(a1)

loc_18F0E:
		move.w	#$77,$3C(a0)

loc_18F14:
		bra.w	loc_18DE4
; ---------------------------------------------------------------------------

loc_18F18:
		subq.w	#1,$3C(a0)
		bpl.s	loc_18F42
		addq.b	#2,ob2ndRout(a0)
		move.w	#$3F,$3C(a0)
		move.w	#$100,obVelX(a0)
		cmpi.w	#$2A00,$30(a0)
		bne.s	loc_18F42
		move.w	#$7F,$3C(a0)
		move.w	#$40,obVelX(a0)

loc_18F42:
		btst	#0,obStatus(a0)
		bne.s	loc_18F4E
		neg.w	obVelX(a0)

loc_18F4E:
		bra.w	loc_18DE4
; ---------------------------------------------------------------------------

loc_18F52:
		subq.w	#1,$3C(a0)
		bmi.s	loc_18F5E
		bsr.w	BossMove
		bra.s	loc_18F74
; ---------------------------------------------------------------------------

loc_18F5E:
		bchg	#0,obStatus(a0)
		move.w	#$3F,$3C(a0)
		subq.b	#2,ob2ndRout(a0)
		move.w	#0,obVelX(a0)

loc_18F74:
		bra.w	loc_18DE4
; ---------------------------------------------------------------------------

loc_18F78:
		subq.w	#1,$3C(a0)
		bmi.s	loc_18F82
		bra.w	BossDefeated
; ---------------------------------------------------------------------------

loc_18F82:
		bset	#0,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#$FFDA,$3C(a0)
		tst.b	(Boss_defeated_flag).w
		bne.s	locret_18FA8
		move.b	#1,(Boss_defeated_flag).w

locret_18FA8:
		rts
; ---------------------------------------------------------------------------

loc_18FAA:
		addq.w	#1,$3C(a0)
		beq.s	loc_18FBA
		bpl.s	loc_18FC0
		addi.w	#$18,obVelY(a0)
		bra.s	loc_18FEE
; ---------------------------------------------------------------------------

loc_18FBA:
		clr.w	obVelY(a0)
		bra.s	loc_18FEE
; ---------------------------------------------------------------------------

loc_18FC0:
		cmpi.w	#$30,$3C(a0)
		bcs.s	loc_18FD8
		beq.s	loc_18FE0
		cmpi.w	#$38,$3C(a0)
		bcs.s	loc_18FEE
		addq.b	#2,ob2ndRout(a0)
		bra.s	loc_18FEE
; ---------------------------------------------------------------------------

loc_18FD8:
		subi.w	#8,obVelY(a0)
		bra.s	loc_18FEE
; ---------------------------------------------------------------------------

loc_18FE0:
		clr.w	obVelY(a0)
		move.w	#bgm_GHZ,d0
		jsr	(PlaySound).l

loc_18FEE:
		bsr.w	BossMove
		bra.w	loc_18DE4
; ---------------------------------------------------------------------------

loc_18FF6:
		move.w	#$400,obVelX(a0)
		move.w	#$FFC0,obVelY(a0)
		cmpi.w	#$2AC0,(Camera_Max_X_pos).w
		beq.s	loc_19010
		addq.w	#2,(Camera_Max_X_pos).w
		bra.s	loc_19016
; ---------------------------------------------------------------------------

loc_19010:
		tst.b	obRender(a0)
		bpl.s	loc_1901E

loc_19016:
		bsr.w	BossMove
		bra.w	loc_18DE4
; ---------------------------------------------------------------------------

loc_1901E:
		addq.l	#4,sp
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

Obj3D_FaceMain:
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	ob2ndRout(a1),d0
		subq.b	#4,d0
		bne.s	loc_19040
		cmpi.w	#$2A00,$30(a1)
		bne.s	loc_19048
		moveq	#4,d1

loc_19040:
		subq.b	#6,d0
		bmi.s	loc_19048
		moveq	#$A,d1
		bra.s	loc_1905C
; ---------------------------------------------------------------------------

loc_19048:
		tst.b	obColType(a1)
		bne.s	loc_19052
		moveq	#5,d1
		bra.s	loc_1905C
; ---------------------------------------------------------------------------

loc_19052:
		cmpi.b	#4,(v_objspace+obRoutine).w
		bcs.s	loc_1905C
		moveq	#4,d1

loc_1905C:
		move.b	d1,obAnim(a0)
		subq.b	#2,d0
		bne.s	loc_19070
		move.b	#6,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	loc_19072

loc_19070:
		bra.s	Obj3D_Display
; ---------------------------------------------------------------------------

loc_19072:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

Obj3D_FlameMain:
		move.b	#7,obAnim(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$C,ob2ndRout(a1)
		bne.s	loc_19098
		move.b	#$B,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	loc_190A6
		bra.s	loc_190A4
; ---------------------------------------------------------------------------

loc_19098:
		move.w	obVelX(a1),d0
		beq.s	loc_190A4
		move.b	#8,obAnim(a0)

loc_190A4:
		bra.s	Obj3D_Display
; ---------------------------------------------------------------------------

loc_190A6:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

Obj3D_Display:
		movea.l	$34(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l
		move.b	obStatus(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 48 - the ball that swings on the GHZ boss
;----------------------------------------------------

Obj48:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj48_Index(pc,d0.w),d1
		jmp	Obj48_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj48_Index:	dc.w Obj48_Init-Obj48_Index
		dc.w Obj48_Main-Obj48_Index
		dc.w loc_19226-Obj48_Index
		dc.w loc_19274-Obj48_Index
		dc.w loc_19290-Obj48_Index
; ---------------------------------------------------------------------------

Obj48_Init:
		addq.b	#2,obRoutine(a0)
		move.w	#$4080,obAngle(a0)
		move.w	#$FE00,$3E(a0)
		move.l	#Map_BossItems,obMap(a0)
		move.w	#$46C,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_5
		lea	obSubtype(a0),a2
		move.b	#0,(a2)+
		moveq	#5,d1
		movea.l	a0,a1
		bra.s	loc_1916A
; ---------------------------------------------------------------------------

loc_1912E:
		jsr	(FindNextFreeObj).l
		bne.s	loc_19194
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		_move.b	#$48,obID(a1)
		move.b	#6,obRoutine(a1)
		move.l	#Map_Obj15,obMap(a1)
		move.w	#$380,obGfx(a1)
		bsr.w	j_Adjust2PArtPointer2_1
		move.b	#1,obFrame(a1)
		addq.b	#1,obSubtype(a0)

loc_1916A:
		move.w	a1,d5
		subi.w	#v_objspace,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#4,obRender(a1)
		move.b	#8,obActWid(a1)
		move.b	#6,obPriority(a1)
		move.l	$34(a0),$34(a1)
		dbf	d1,loc_1912E

loc_19194:
		move.b	#8,obRoutine(a1)
		move.l	#Map_Obj48,obMap(a1)
		move.w	#$43AA,obGfx(a1)
		bsr.w	j_Adjust2PArtPointer2_1
		move.b	#1,obFrame(a1)
		move.b	#5,obPriority(a1)
		move.b	#$81,obColType(a1)
		rts
; ---------------------------------------------------------------------------
Obj48_PosData:	dc.b   0,$10,$20,$30,$40,$60		; 0
; ---------------------------------------------------------------------------

Obj48_Main:
		lea	Obj48_PosData(pc),a3
		lea	obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_191D2:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#v_objspace,d4
		movea.l	d4,a1
		move.b	(a3)+,d0
		cmp.b	$3C(a1),d0
		beq.s	loc_191EC
		addq.b	#1,$3C(a1)

loc_191EC:
		dbf	d6,loc_191D2
		cmp.b	$3C(a1),d0
		bne.s	loc_19206
		movea.l	$34(a0),a1
		cmpi.b	#6,ob2ndRout(a1)
		bne.s	loc_19206
		addq.b	#2,obRoutine(a0)

loc_19206:
		cmpi.w	#$20,$32(a0)
		beq.s	loc_19212
		addq.w	#1,$32(a0)

loc_19212:
		bsr.w	sub_19236
		move.b	obAngle(a0),d0
		jsr	(loc_842E).l
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_19226:
		bsr.w	sub_19236
		jsr	(loc_83EA).l
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


sub_19236:
		movea.l	$34(a0),a1
		addi.b	#$20,obAniFrame(a0)
		bcc.s	loc_19248
		bchg	#0,obFrame(a0)

loc_19248:
		move.w	obX(a1),$3A(a0)
		move.w	obY(a1),d0
		add.w	$32(a0),d0
		move.w	d0,$38(a0)
		move.b	obStatus(a1),obStatus(a0)
		tst.b	obStatus(a1)
		bpl.s	locret_19272
		_move.b	#$3F,obID(a0)
		move.b	#0,obRoutine(a0)

locret_19272:
		rts
; End of function sub_19236

; ---------------------------------------------------------------------------

loc_19274:
		movea.l	$34(a0),a1
		tst.b	obStatus(a1)
		bpl.s	loc_1928A
		_move.b	#$3F,obID(a0)
		move.b	#0,obRoutine(a0)

loc_1928A:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_19290:
		moveq	#0,d0
		tst.b	obFrame(a0)
		bne.s	loc_1929A
		addq.b	#1,d0

loc_1929A:
		move.b	d0,obFrame(a0)
		movea.l	$34(a0),a1
		tst.b	obStatus(a1)
		bpl.s	loc_192C2
		move.b	#0,obColType(a0)
		bsr.w	BossDefeated
		subq.b	#1,$3C(a0)
		bpl.s	loc_192C2
		move.b	#$3F,obID(a0)
		move.b	#0,obRoutine(a0)

loc_192C2:
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------
Ani_Eggman:	dc.w byte_192E0-Ani_Eggman
		dc.w byte_192E3-Ani_Eggman
		dc.w byte_192E7-Ani_Eggman
		dc.w byte_192EB-Ani_Eggman
		dc.w byte_192EF-Ani_Eggman
		dc.w byte_192F3-Ani_Eggman
		dc.w byte_192F7-Ani_Eggman
		dc.w byte_192FB-Ani_Eggman
		dc.w byte_192FE-Ani_Eggman
		dc.w byte_19302-Ani_Eggman
		dc.w byte_19306-Ani_Eggman
		dc.w byte_19309-Ani_Eggman
byte_192E0:	dc.b  $F,  0,$FF			; 0
byte_192E3:	dc.b   5,  1,  2,$FF			; 0
byte_192E7:	dc.b   3,  1,  2,$FF			; 0
byte_192EB:	dc.b   1,  1,  2,$FF			; 0
byte_192EF:	dc.b   4,  3,  4,$FF			; 0
byte_192F3:	dc.b $1F,  5,  1,$FF			; 0
byte_192F7:	dc.b   3,  6,  1,$FF			; 0
byte_192FB:	dc.b  $F, $A,$FF			; 0
byte_192FE:	dc.b   3,  8,  9,$FF			; 0
byte_19302:	dc.b   1,  8,  9,$FF			; 0
byte_19306:	dc.b  $F,  7,$FF			; 0
byte_19309:	dc.b   2,  9,  8, $B, $C, $B, $C,  9,  8,$FE,  2 ; 0
Map_Eggman:	dc.w word_1932E-Map_Eggman
		dc.w word_19360-Map_Eggman
		dc.w word_19372-Map_Eggman
		dc.w word_19384-Map_Eggman
		dc.w word_1939E-Map_Eggman
		dc.w word_193B8-Map_Eggman
		dc.w word_193D2-Map_Eggman
		dc.w word_193EC-Map_Eggman
		dc.w word_1940E-Map_Eggman
		dc.w word_19418-Map_Eggman
		dc.w word_19422-Map_Eggman
		dc.w word_19424-Map_Eggman
		dc.w word_19436-Map_Eggman
word_1932E:	dc.w 6
		dc.w $EC01,   $A,    5,$FFE4		; 0
		dc.w $EC05,   $C,    6,	  $C		; 4
		dc.w $FC0E,$2010,$2008,$FFE4		; 8
		dc.w $FC0E,$201C,$200E,	   4		; 12
		dc.w $140C,$2028,$2014,$FFEC		; 16
		dc.w $1400,$202C,$2016,	  $C		; 20
word_19360:	dc.w 2
		dc.w $E404,    0,    0,$FFF4		; 0
		dc.w $EC0D,    2,    1,$FFEC		; 4
word_19372:	dc.w 2
		dc.w $E404,    0,    0,$FFF4		; 0
		dc.w $EC0D,  $35,  $1A,$FFEC		; 4
word_19384:	dc.w 3
		dc.w $E408,  $3D,  $1E,$FFF4		; 0
		dc.w $EC09,  $40,  $20,$FFEC		; 4
		dc.w $EC05,  $46,  $23,	   4		; 8
word_1939E:	dc.w 3
		dc.w $E408,  $4A,  $25,$FFF4		; 0
		dc.w $EC09,  $4D,  $26,$FFEC		; 4
		dc.w $EC05,  $53,  $29,	   4		; 8
word_193B8:	dc.w 3
		dc.w $E408,  $57,  $2B,$FFF4		; 0
		dc.w $EC09,  $5A,  $2D,$FFEC		; 4
		dc.w $EC05,  $60,  $30,	   4		; 8
word_193D2:	dc.w 3
		dc.w $E404,  $64,  $32,	   4		; 0
		dc.w $E404,    0,    0,$FFF4		; 4
		dc.w $EC0D,  $35,  $1A,$FFEC		; 8
word_193EC:	dc.w 4
		dc.w $E409,  $66,  $33,$FFF4		; 0
		dc.w $E408,  $57,  $2B,$FFF4		; 4
		dc.w $EC09,  $5A,  $2D,$FFEC		; 8
		dc.w $EC05,  $60,  $30,	   4		; 12
word_1940E:	dc.w 1
		dc.w  $405,  $2D,  $16,	 $22		; 0
word_19418:	dc.w 1
		dc.w  $405,  $31,  $18,	 $22		; 0
word_19422:	dc.w 0
word_19424:	dc.w 2
		dc.w	 8, $12A, $195,	 $22		; 0
		dc.w  $808,$112A,$1995,	 $22		; 4
word_19436:	dc.w 2
		dc.w $F80B, $12D, $199,	 $22		; 0
		dc.w	 1, $139, $1AB,	 $3A		; 4
Map_BossItems:	dc.w word_19458-Map_BossItems
		dc.w word_19462-Map_BossItems
		dc.w word_19474-Map_BossItems
		dc.w word_1947E-Map_BossItems
		dc.w word_19488-Map_BossItems
		dc.w word_19492-Map_BossItems
		dc.w word_194B4-Map_BossItems
		dc.w word_194C6-Map_BossItems
word_19458:	dc.w 1
		dc.w $F805,    0,    0,$FFF8		; 0
word_19462:	dc.w 2
		dc.w $FC04,    4,    2,$FFF8		; 0
		dc.w $F805,    0,    0,$FFF8		; 4
word_19474:	dc.w 1
		dc.w $FC00,    6,    3,$FFFC		; 0
word_1947E:	dc.w 1
		dc.w $1409,    7,    3,$FFF4		; 0
word_19488:	dc.w 1
		dc.w $1405,   $D,    6,$FFF8		; 0
word_19492:	dc.w 4
		dc.w $F004,  $11,    8,$FFF8		; 0
		dc.w $F801,  $13,    9,$FFF8		; 4
		dc.w $F801, $813, $809,	   0		; 8
		dc.w  $804,  $15,   $A,$FFF8		; 12
word_194B4:	dc.w 2
		dc.w	 5,  $17,   $B,	   0		; 0
		dc.w	 0,  $1B,   $D,	 $10		; 4
word_194C6:	dc.w 2
		dc.w $1804,  $1C,   $E,	   0		; 0
		dc.w	$B,  $1E,   $F,	 $10		; 4
; ---------------------------------------------------------------------------

j_Adjust2PArtPointer2_1:
		jmp	(Adjust2PArtPointer2).l
; ---------------------------------------------------------------------------

j_Adjust2PArtPointer_5:
		jmp	(Adjust2PArtPointer).l
; ---------------------------------------------------------------------------
;----------------------------------------------------
; Object 3E - prison capsule
;----------------------------------------------------

Obj3E:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj3E_Index(pc,d0.w),d1
		jsr	Obj3E_Index(pc,d1.w)
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_1950A
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_1950A:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------
Obj3E_Index:	dc.w Obj3E_Init-Obj3E_Index
		dc.w Obj3E_BodyMain-Obj3E_Index
		dc.w Obj3E_Switched-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Animals-Obj3E_Index
		dc.w Obj3E_EndAct-Obj3E_Index
Obj3E_Var:	dc.b   2,$20,  4,  0			; 0
		dc.b   4, $C,  5,  1			; 4
		dc.b   6,$10,  4,  3			; 8
		dc.b   8,$10,  3,  5			; 12
; ---------------------------------------------------------------------------

Obj3E_Init:
		move.l	#Map_Obj3E,obMap(a0)
		move.w	#$49D,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_6
		move.b	#4,obRender(a0)
		move.w	obY(a0),$30(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsl.w	#2,d0
		lea	Obj3E_Var(pc,d0.w),a1
		move.b	(a1)+,obRoutine(a0)
		move.b	(a1)+,obActWid(a0)
		move.b	(a1)+,obPriority(a0)
		move.b	(a1)+,obFrame(a0)
		cmpi.w	#8,d0
		bne.s	locret_1957C
		move.b	#6,obColType(a0)
		move.b	#8,obColProp(a0)

locret_1957C:
		rts
; ---------------------------------------------------------------------------

Obj3E_BodyMain:
		cmpi.b	#2,($FFFFF7A7).w
		beq.s	loc_1959C
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	#$18,d3
		move.w	obX(a0),d4
		jmp	(SolidObject).l
; ---------------------------------------------------------------------------

loc_1959C:
		tst.b	ob2ndRout(a0)
		beq.s	loc_195B2
		clr.b	ob2ndRout(a0)
		bclr	#3,(v_objspace+obStatus).w
		bset	#1,(v_objspace+obStatus).w

loc_195B2:
		move.b	#2,obFrame(a0)
		rts
; ---------------------------------------------------------------------------

Obj3E_Switched:
		move.w	#$17,d1
		move.w	#8,d2
		move.w	#8,d3
		move.w	obX(a0),d4
		jsr	(SolidObject).l
		lea	(Ani_Obj3E).l,a1
		jsr	(AnimateSprite).l
		move.w	$30(a0),obY(a0)
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		beq.s	locret_19620
		addq.w	#8,obY(a0)
		move.b	#$A,obRoutine(a0)
		move.w	#$3C,obTimeFrame(a0)
		clr.b	(f_timecount).w
		clr.b	(f_lockscreen).w
		move.b	#1,(f_lockctrl).w
		move.w	#$800,(v_jpadhold2).w
		clr.b	ob2ndRout(a0)
		bclr	#3,(v_objspace+obStatus).w
		bset	#1,(v_objspace+obStatus).w

locret_19620:
		rts
; ---------------------------------------------------------------------------

Obj3E_Explosion:
		moveq	#7,d0
		and.b	($FFFFFE0F).w,d0
		bne.s	loc_19660
		jsr	(FindFreeObj).l
		bne.s	loc_19660
		_move.b	#$3F,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr	(RandomNumber).l
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

loc_19660:
		subq.w	#1,obTimeFrame(a0)
		beq.s	loc_19668
		rts
; ---------------------------------------------------------------------------

loc_19668:
		move.b	#2,($FFFFF7A7).w
		move.b	#$C,obRoutine(a0)
		move.b	#6,obFrame(a0)
		move.w	#$96,obTimeFrame(a0)
		addi.w	#$20,obY(a0)
		moveq	#7,d6
		move.w	#$9A,d5
		moveq	#$FFFFFFE4,d4

loc_1968E:
		jsr	(FindFreeObj).l
		bne.s	locret_196B8
		_move.b	#$28,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		add.w	d4,obX(a1)
		addq.w	#7,d4
		move.w	d5,$36(a1)
		subq.w	#8,d5
		dbf	d6,loc_1968E

locret_196B8:
		rts
; ---------------------------------------------------------------------------

Obj3E_Animals:
		moveq	#7,d0
		and.b	($FFFFFE0F).w,d0
		bne.s	loc_196F8
		jsr	(FindFreeObj).l
		bne.s	loc_196F8
		_move.b	#$28,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	loc_196EE
		neg.w	d0

loc_196EE:
		add.w	d0,obX(a1)
		move.w	#$C,$36(a1)

loc_196F8:
		subq.w	#1,obTimeFrame(a0)
		bne.s	locret_19708
		addq.b	#2,obRoutine(a0)
		move.w	#$B4,obTimeFrame(a0)

locret_19708:
		rts
; ---------------------------------------------------------------------------

Obj3E_EndAct:
		moveq	#$3E,d0
		moveq	#$28,d1
		moveq	#$40,d2
		lea	(v_objspace+$40).w,a1

loc_19714:
		cmp.b	(a1),d1
		beq.s	locret_1972A
		adda.w	d2,a1
		dbf	d0,loc_19714
		jsr	(Load_EndOfAct).l
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

locret_1972A:
		rts
; ---------------------------------------------------------------------------
Ani_Obj3E:	dc.w byte_19730-Ani_Obj3E
		dc.w byte_19730-Ani_Obj3E
byte_19730:	dc.b   2,  1,  3,$FF			; 0
Map_Obj3E:	dc.w word_19742-Map_Obj3E
		dc.w word_1977C-Map_Obj3E
		dc.w word_19786-Map_Obj3E
		dc.w word_197B8-Map_Obj3E
		dc.w word_197C2-Map_Obj3E
		dc.w word_197D4-Map_Obj3E
		dc.w word_197DE-Map_Obj3E
word_19742:	dc.w 7
		dc.w $E00C,$2000,$2000,$FFF0		; 0
		dc.w $E80D,$2004,$2002,$FFE0		; 4
		dc.w $E80D,$200C,$2006,	   0		; 8
		dc.w $F80E,$2014,$200A,$FFE0		; 12
		dc.w $F80E,$2020,$2010,	   0		; 16
		dc.w $100D,$202C,$2016,$FFE0		; 20
		dc.w $100D,$2034,$201A,	   0		; 24
word_1977C:	dc.w 1
		dc.w $F809,  $3C,  $1E,$FFF4		; 0
word_19786:	dc.w 6
		dc.w	 8,$2042,$2021,$FFE0		; 0
		dc.w  $80C,$2045,$2022,$FFE0		; 4
		dc.w	 4,$2049,$2024,	 $10		; 8
		dc.w  $80C,$204B,$2025,	   0		; 12
		dc.w $100D,$202C,$2016,$FFE0		; 16
		dc.w $100D,$2034,$201A,	   0		; 20
word_197B8:	dc.w 1
		dc.w $F809,  $4F,  $27,$FFF4		; 0
word_197C2:	dc.w 2
		dc.w $E80E,$2055,$202A,$FFF0		; 0
		dc.w	$E,$2061,$2030,$FFF0		; 4
word_197D4:	dc.w 1
		dc.w $F007,$206D,$2036,$FFF8		; 0
word_197DE:	dc.w 0
; ---------------------------------------------------------------------------

j_Adjust2PArtPointer_6:
		jmp	(Adjust2PArtPointer).l
; ---------------------------------------------------------------------------
		align 4

; =============== S U B	R O U T	I N E =======================================


TouchResponse:

; FUNCTION CHUNK AT 00019B02 SIZE 00000070 BYTES

		nop
		bsr.w	loc_19B7A
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
		cmpi.b	#$39,obFrame(a0)
		bne.s	loc_19812
		addi.w	#$C,d3
		moveq	#$A,d5

loc_19812:
		move.w	#$10,d4
		add.w	d5,d5
		lea	(v_objspace+$800).w,a1
		move.w	#$5F,d6

loc_19820:
		move.b	obColType(a1),d0
		bne.s	Touch_Height

loc_19826:
		lea	$40(a1),a1
		dbf	d6,loc_19820
		moveq	#0,d0

locret_19830:
		rts
; ---------------------------------------------------------------------------
Touch_Sizes:	dc.b $14,$14				; 0
		dc.b  $C,$14				; 2
		dc.b $14, $C				; 4
		dc.b   4,$10				; 6
		dc.b  $C,$12				; 8
		dc.b $10,$10				; 10
		dc.b   6,  6				; 12
		dc.b $18, $C				; 14
		dc.b  $C,$10				; 16
		dc.b $10, $C				; 18
		dc.b   8,  8				; 20
		dc.b $14,$10				; 22
		dc.b $14,  8				; 24
		dc.b  $E, $E				; 26
		dc.b $18,$18				; 28
		dc.b $28,$10				; 30
		dc.b $10,$18				; 32
		dc.b   8,$10				; 34
		dc.b $20,$70				; 36
		dc.b $40,$20				; 38
		dc.b $80,$20				; 40
		dc.b $20,$20				; 42
		dc.b   8,  8				; 44
		dc.b   4,  4				; 46
		dc.b $20,  8				; 48
		dc.b  $C, $C				; 50
		dc.b   8,  4				; 52
		dc.b $18,  4				; 54
		dc.b $28,  4				; 56
		dc.b   4,  8				; 58
		dc.b   4,$18				; 60
		dc.b   4,$28				; 62
		dc.b   4,$20				; 64
		dc.b $18,$18				; 66
		dc.b  $C,$18				; 68
		dc.b $48,  8				; 70
; ---------------------------------------------------------------------------

Touch_Height:
		andi.w	#$3F,d0
		add.w	d0,d0
		lea	Touch_Sizes-2(pc,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obX(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_1989C
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_198A2
		bra.w	loc_19826
; ---------------------------------------------------------------------------

loc_1989C:
		cmp.w	d4,d0
		bhi.w	loc_19826

loc_198A2:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obY(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_198BA
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_198C0
		bra.w	loc_19826
; ---------------------------------------------------------------------------

loc_198BA:
		cmp.w	d5,d0
		bhi.w	loc_19826

loc_198C0:
		move.b	obColType(a1),d1
		andi.b	#$C0,d1
		beq.w	loc_1993A
		cmpi.b	#$C0,d1
		beq.w	Touch_Special
		tst.b	d1
		bmi.w	loc_199F2
		move.b	obColType(a1),d0
		andi.b	#$3F,d0
		cmpi.b	#6,d0
		beq.s	loc_198FA
		cmpi.w	#$5A,$30(a0)
		bcc.w	locret_198F8
		move.b	#4,obRoutine(a1)

locret_198F8:
		rts
; ---------------------------------------------------------------------------

loc_198FA:
		tst.w	obVelY(a0)
		bpl.s	loc_19926
		move.w	obY(a0),d0
		subi.w	#$10,d0
		cmp.w	obY(a1),d0
		bcs.s	locret_19938

loc_1990E:
		neg.w	obVelY(a0)

loc_19912:
		move.w	#$FE80,obVelY(a1)
		tst.b	ob2ndRout(a1)
		bne.s	locret_19938
		move.b	#4,ob2ndRout(a1)
		rts
; ---------------------------------------------------------------------------

loc_19926:
		cmpi.b	#2,obAnim(a0)
		bne.s	locret_19938
		neg.w	obVelY(a0)
		move.b	#4,obRoutine(a1)

locret_19938:
		rts
; ---------------------------------------------------------------------------

loc_1993A:
		tst.b	(v_invinc).w
		bne.s	loc_19952
		cmpi.b	#9,obAnim(a0)
		beq.s	loc_19952
		cmpi.b	#2,obAnim(a0)
		bne.w	loc_199F2

loc_19952:
		tst.b	obColProp(a1)
		beq.s	Touch_KillEnemy
		neg.w	obVelX(a0)
		neg.w	obVelY(a0)
		asr	obVelX(a0)
		asr	obVelY(a0)
		move.b	#0,obColType(a1)
		subq.b	#1,obColProp(a1)
		bne.s	locret_1997A
		bset	#7,obStatus(a1)

locret_1997A:
		rts
; ---------------------------------------------------------------------------

Touch_KillEnemy:
		bset	#7,obStatus(a1)
		moveq	#0,d0
		move.w	(v_itembonus).w,d0
		addq.w	#2,(v_itembonus).w
		cmpi.w	#6,d0
		bcs.s	loc_19994
		moveq	#6,d0

loc_19994:
		move.w	d0,$3E(a1)
		move.w	Enemy_Points(pc,d0.w),d0
		cmpi.w	#$20,(v_itembonus).w
		bcs.s	loc_199AE
		move.w	#$3E8,d0
		move.w	#$A,$3E(a1)

loc_199AE:
		bsr.w	AddPoints
		_move.b	#$27,obID(a1)
		move.b	#0,obRoutine(a1)
		tst.w	obVelY(a0)
		bmi.s	loc_199D4
		move.w	obY(a0),d0
		cmp.w	obY(a1),d0
		bcc.s	loc_199DC
		neg.w	obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_199D4:
		addi.w	#$100,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_199DC:
		subi.w	#$100,obVelY(a0)
		rts
; ---------------------------------------------------------------------------
Enemy_Points:
		dc.w	10,   20,   50,	 100		; 0
; ---------------------------------------------------------------------------

loc_199EC:
		bset	#7,obStatus(a1)

loc_199F2:
		tst.b	(v_invinc).w
		beq.s	Touch_Hurt

loc_199F8:
		moveq	#-1,d0
		rts
; ---------------------------------------------------------------------------

Touch_Hurt:
		nop
		tst.w	$30(a0)
		bne.s	loc_199F8
		movea.l	a1,a2
; End of function TouchResponse


; =============== S U B	R O U T	I N E =======================================


HurtSonic:
		tst.b	(v_shield).w
		bne.s	HurtShield
		tst.w	(v_rings).w
		beq.w	Hurt_NoRings
		jsr	(FindFreeObj).l
		bne.s	HurtShield
		_move.b	#$37,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

HurtShield:
		move.b	#0,(v_shield).w
		move.b	#4,obRoutine(a0)
		bsr.w	j_Sonic_ResetOnFloor
		bset	#1,obStatus(a0)
		move.w	#$FC00,obVelY(a0)
		move.w	#$FE00,obVelX(a0)
		btst	#6,obStatus(a0)
		beq.s	Hurt_Reverse
		move.w	#$FE00,obVelY(a0)
		move.w	#$FF00,obVelX(a0)

Hurt_Reverse:
		move.w	obX(a0),d0
		cmp.w	obX(a2),d0
		bcs.s	Hurt_ChkSpikes
		neg.w	obVelX(a0)

Hurt_ChkSpikes:
		move.w	#0,obInertia(a0)
		move.b	#$1A,obAnim(a0)
		move.w	#$78,$30(a0)
		move.w	#sfx_Death,d0
		cmpi.b	#$36,(a2)
		bne.s	loc_19A98
		cmpi.b	#$16,(a2)
		bne.s	loc_19A98
		move.w	#sfx_HitSpikes,d0

loc_19A98:
		jsr	(PlaySound_Special).l
		moveq	#-1,d0
		rts
; ---------------------------------------------------------------------------

Hurt_NoRings:
		tst.w	(Debug_mode_flag).w
		bne.w	HurtShield
; End of function HurtSonic


; =============== S U B	R O U T	I N E =======================================


KillSonic:
		tst.w	(Debug_placement_mode).w
		bne.s	Kill_NoDeath
		move.b	#0,(v_invinc).w
		move.b	#6,obRoutine(a0)
		bsr.w	j_Sonic_ResetOnFloor
		bset	#1,obStatus(a0)
		move.w	#$F900,obVelY(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obInertia(a0)
		move.w	obY(a0),$38(a0)
		move.b	#$18,obAnim(a0)
		bset	#7,2(a0)
		move.w	#sfx_Death,d0
		cmpi.b	#$36,(a2)
		bne.s	loc_19AF8
		move.w	#sfx_HitSpikes,d0

loc_19AF8:
		jsr	(PlaySound_Special).l

Kill_NoDeath:
		moveq	#-1,d0
		rts
; End of function KillSonic

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR TouchResponse

Touch_Special:
		move.b	obColType(a1),d1
		andi.b	#$3F,d1
		cmpi.b	#$B,d1
		beq.s	Touch_Caterkiller
		cmpi.b	#$C,d1
		beq.s	Touch_Yadrin
		cmpi.b	#$17,d1
		beq.s	Touch_D7
		cmpi.b	#$21,d1
		beq.s	Touch_E1
		rts
; ---------------------------------------------------------------------------

Touch_Caterkiller:
		bra.w	loc_199EC
; ---------------------------------------------------------------------------

Touch_Yadrin:
		sub.w	d0,d5
		cmpi.w	#8,d5
		bcc.s	loc_19B56
		move.w	obX(a1),d0
		subq.w	#4,d0
		btst	#0,obStatus(a1)
		beq.s	loc_19B42
		subi.w	#$10,d0

loc_19B42:
		sub.w	d2,d0
		bcc.s	loc_19B4E
		addi.w	#$18,d0
		bcs.s	loc_19B52
		bra.s	loc_19B56
; ---------------------------------------------------------------------------

loc_19B4E:
		cmp.w	d4,d0
		bhi.s	loc_19B56

loc_19B52:
		bra.w	loc_199F2
; ---------------------------------------------------------------------------

loc_19B56:
		bra.w	loc_1993A
; ---------------------------------------------------------------------------

Touch_D7:
		move.w	a0,d1
		subi.w	#v_objspace,d1
		beq.s	loc_19B66
		addq.b	#1,obColProp(a1)

loc_19B66:
		addq.b	#1,obColProp(a1)
		rts
; ---------------------------------------------------------------------------

Touch_E1:
		addq.b	#1,obColProp(a1)
		rts
; END OF FUNCTION CHUNK	FOR TouchResponse
; ---------------------------------------------------------------------------
		nop

j_Sonic_ResetOnFloor:
		jmp	(Sonic_ResetOnFloor).l

; ---------------------------------------------------------------------------

loc_19B7A:
		jmp	(Touch_Rings).l

; =============== S U B	R O U T	I N E =======================================

; leftover from Sonic 1

S1SS_ShowLayout:
		bsr.w	sub_19CC2
		bsr.w	sub_19F02
		move.w	d5,-(sp)
		lea	(v_ssbuffer3).w,a1
		move.b	($FFFFF780).w,d0
		andi.b	#$FC,d0
		jsr	(CalcSine).l
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	(Camera_RAM).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#$FF4C,d2
		moveq	#0,d3
		move.w	(Camera_Y_pos).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#$FF4C,d3
		move.w	#$F,d7

loc_19BD0:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$F,d6

loc_19BF2:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,loc_19BF2
		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf	d7,loc_19BD0
		move.w	(sp)+,d5
		lea	(v_ssbuffer1).l,a0
		moveq	#0,d0
		move.w	(Camera_Y_pos).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	(Camera_RAM).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea	(v_ssbuffer3).w,a4
		move.w	#$F,d7

loc_19C3E:
		move.w	#$F,d6

loc_19C42:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	loc_19C9A
		cmpi.b	#$4E,d0
		bhi.s	loc_19C9A
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		bcs.s	loc_19C9A
		cmpi.w	#$1D0,d3
		bcc.s	loc_19C9A
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		bcs.s	loc_19C9A
		cmpi.w	#$170,d2
		bcc.s	loc_19C9A
		lea	(v_ssbuffer2).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_19C9A
		jsr	(loc_D1CE).l

loc_19C9A:
		addq.w	#4,a4
		dbf	d6,loc_19C42
		lea	$70(a0),a0
		dbf	d7,loc_19C3E
		move.b	d5,($FFFFF62C).w
		cmpi.b	#$50,d5
		beq.s	loc_19CBA
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

loc_19CBA:
		move.b	#0,-5(a2)
		rts
; End of function S1SS_ShowLayout


; =============== S U B	R O U T	I N E =======================================


sub_19CC2:
		lea	($FFFF400C).l,a1
		moveq	#0,d0
		move.b	($FFFFF780).w,d0
		lsr.b	#2,d0
		andi.w	#$F,d0
		moveq	#$23,d1

loc_19CD6:
		move.w	d0,(a1)
		addq.w	#8,a1
		dbf	d1,loc_19CD6
		lea	($FFFF4005).l,a1
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_19CFA
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

loc_19CFA:
		move.b	(v_ani1_frame).w,$1D0(a1)
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_19D16
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#1,(v_ani2_frame).w

loc_19D16:
		move.b	(v_ani2_frame).w,d0
		move.b	d0,$138(a1)

loc_19D1E:
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,(v_ani3_time).w
		bpl.s	loc_19D58
		move.b	#4,(v_ani3_time).w
		addq.b	#1,(v_ani3_frame).w
		andi.b	#3,(v_ani3_frame).w

loc_19D58:
		move.b	(v_ani3_frame).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_19D82
		move.b	#7,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_19D82:
		lea	($FFFF4016).l,a1
		lea	(S1SS_WaRiVramSet).l,a0
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		rts
; End of function sub_19CC2

; ---------------------------------------------------------------------------
S1SS_WaRiVramSet:dc.w $142,$6142,$142,$142,$142,$142,$142,$6142
		dc.w $142,$6142,$142,$142,$142,$142,$142,$6142
		dc.w $2142,$142,$2142,$2142,$2142,$2142,$2142,$142
		dc.w $2142,$142,$2142,$2142,$2142,$2142,$2142,$142
		dc.w $4142,$2142,$4142,$4142,$4142,$4142,$4142,$2142
		dc.w $4142,$2142,$4142,$4142,$4142,$4142,$4142,$2142
		dc.w $6142,$4142,$6142,$6142,$6142,$6142,$6142,$4142
		dc.w $6142,$4142,$6142,$6142,$6142,$6142,$6142,$4142

; =============== S U B	R O U T	I N E =======================================


sub_19EEC:
		lea	($FFFF4400).l,a2
		move.w	#$1F,d0

loc_19EF6:
		tst.b	(a2)
		beq.s	locret_19F00
		addq.w	#8,a2
		dbf	d0,loc_19EF6

locret_19F00:
		rts
; End of function sub_19EEC


; =============== S U B	R O U T	I N E =======================================


sub_19F02:
		lea	($FFFF4400).l,a0
		move.w	#$1F,d7

loc_19F0C:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_19F1A
		lsl.w	#2,d0
		movea.l	S1SS_AniIndex-4(pc,d0.w),a1
		jsr	(a1)

loc_19F1A:
		addq.w	#8,a0

loc_19F1C:
		dbf	d7,loc_19F0C
		rts
; End of function sub_19F02

; ---------------------------------------------------------------------------
S1SS_AniIndex:	dc.l loc_19F3A
		dc.l loc_19F6A
		dc.l loc_19FA0
		dc.l loc_19FD0
		dc.l loc_1A006
		dc.l loc_1A046
; ---------------------------------------------------------------------------

loc_19F3A:
		subq.b	#1,2(a0)
		bpl.s	locret_19F62
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_19F64(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_19F62
		clr.l	(a0)
		clr.l	4(a0)

locret_19F62:
		rts
; ---------------------------------------------------------------------------
byte_19F64:	dc.b $42,$43,$44,$45,  0,  0		; 0
; ---------------------------------------------------------------------------

loc_19F6A:
		subq.b	#1,2(a0)
		bpl.s	locret_19F98
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_19F9A(pc,d0.w),d0
		bne.s	loc_19F96
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1)
		rts
; ---------------------------------------------------------------------------

loc_19F96:
		move.b	d0,(a1)

locret_19F98:
		rts
; ---------------------------------------------------------------------------
byte_19F9A:	dc.b $32,$33,$32,$33,  0,  0		; 0
; ---------------------------------------------------------------------------

loc_19FA0:
		subq.b	#1,2(a0)
		bpl.s	locret_19FC8
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_19FCA(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_19FC8
		clr.l	(a0)
		clr.l	4(a0)

locret_19FC8:
		rts
; ---------------------------------------------------------------------------
byte_19FCA:	dc.b $46,$47,$48,$49,  0,  0		; 0
; ---------------------------------------------------------------------------

loc_19FD0:
		subq.b	#1,2(a0)
		bpl.s	locret_19FFE
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_1A000(pc,d0.w),d0
		bne.s	loc_19FFC
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1)
		rts
; ---------------------------------------------------------------------------

loc_19FFC:
		move.b	d0,(a1)

locret_19FFE:
		rts
; ---------------------------------------------------------------------------
byte_1A000:	dc.b $2B,$31,$2B,$31,  0,  0		; 0
; ---------------------------------------------------------------------------

loc_1A006:
		subq.b	#1,2(a0)
		bpl.s	locret_1A03E
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_1A040(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1A03E
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,(v_objspace+obRoutine).w
		move.w	#sfx_SSGoal,d0
		jsr	(PlaySound_Special).l

locret_1A03E:
		rts
; ---------------------------------------------------------------------------
byte_1A040:	dc.b $46,$47,$48,$49,  0,  0		; 0
; ---------------------------------------------------------------------------

loc_1A046:
		subq.b	#1,2(a0)
		bpl.s	locret_1A072
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_1A074(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1A072
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

locret_1A072:
		rts
; ---------------------------------------------------------------------------
byte_1A074:	dc.b $4B,$4C,$4D,$4E,$4B,$4C,$4D,$4E	; 0
		dc.b   0,  0				; 8
S1SS_LayoutIndex:dc.l S1SS_1,S1SS_2			; 0
		dc.l S1SS_3,S1SS_4			; 2
		dc.l S1SS_5,S1SS_6			; 4
S1SS_StartLoc:	dc.w  $3D0, $2E0			; 0
		dc.w  $328, $574			; 2
		dc.w  $4E4, $2E0			; 4
		dc.w  $3AD, $2E0			; 6
		dc.w  $340, $6B8			; 8
		dc.w  $49B, $358			; 10

; =============== S U B	R O U T	I N E =======================================


S1SS_Load:
		moveq	#0,d0
		move.b	(v_lastspecial).w,d0
		addq.b	#1,(v_lastspecial).w
		cmpi.b	#6,(v_lastspecial).w
		bcs.s	loc_1A0C6
		move.b	#0,(v_lastspecial).w

loc_1A0C6:
		cmpi.b	#6,(v_emeralds).w
		beq.s	loc_1A0E8
		moveq	#0,d1
		move.b	(v_emeralds).w,d1
		subq.b	#1,d1
		bcs.s	loc_1A0E8
		lea	(v_emldlist).w,a3

loc_1A0DC:
		cmp.b	(a3,d1.w),d0
		bne.s	loc_1A0E4
		bra.s	S1SS_Load
; ---------------------------------------------------------------------------

loc_1A0E4:
		dbf	d1,loc_1A0DC

loc_1A0E8:
		lsl.w	#2,d0
		lea	S1SS_StartLoc(pc,d0.w),a1
		move.w	(a1)+,(v_objspace+obX).w
		move.w	(a1)+,(v_objspace+obY).w
		movea.l	S1SS_LayoutIndex(pc,d0.w),a0
		lea	(v_ssbuffer2).l,a1
		move.w	#0,d0
		jsr	(EniDec).l
		lea	(v_ssbuffer1).l,a1
		move.w	#(v_ssbuffer2-v_ssbuffer1)/4-1,d0

loc_1A114:
		clr.l	(a1)+
		dbf	d0,loc_1A114
		lea	(v_ssblockbuffer).l,a1
		lea	(v_ssbuffer2).l,a0
		moveq	#(v_ssblockbuffer_end-v_ssblockbuffer)/$80-1,d1

loc_1A128:
		moveq	#$40-1,d2

loc_1A12A:
		move.b	(a0)+,(a1)+
		dbf	d2,loc_1A12A
		lea	$40(a1),a1
		dbf	d1,loc_1A128
		lea	(v_ssblocktypes+8).l,a1
		lea	(S1SS_MapIndex).l,a0
		moveq	#(S1SS_MapIndex_End-S1SS_MapIndex)/6-1,d1

loc_1A146:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,loc_1A146
		lea	(v_ssitembuffer).l,a1
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/4-1,d1

loc_1A162:
		clr.l	(a1)+
		dbf	d1,loc_1A162
		rts
; End of function S1SS_Load

; ---------------------------------------------------------------------------
S1SS_MapIndex:	dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $2142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $4142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l S1Map_SS_R
		dc.w $6142
		dc.l Map_S1Obj47
		dc.w $23B
		dc.l S1Map_SS_R
		dc.w $570
		dc.l S1Map_SS_R
		dc.w $251
		dc.l S1Map_SS_R
		dc.w $370
		dc.l S1Map_SS_Up
		dc.w $263
		dc.l S1Map_SS_Down
		dc.w $263
		dc.l S1Map_SS_R
		dc.w $22F0
		dc.l S1Map_SS_Glass
		dc.w $470
		dc.l S1Map_SS_Glass
		dc.w $5F0
		dc.l S1Map_SS_Glass
		dc.w $65F0
		dc.l S1Map_SS_Glass
		dc.w $25F0
		dc.l S1Map_SS_Glass
		dc.w $45F0
		dc.l S1Map_SS_R
		dc.w $2F0
		dc.l Map_S1Obj47+$1000000
		dc.w $23B
		dc.l Map_S1Obj47+$2000000
		dc.w $23B
		dc.l S1Map_SS_R
		dc.w $797
		dc.l S1Map_SS_R
		dc.w $7A0
		dc.l S1Map_SS_R
		dc.w $7A9
		dc.l S1Map_SS_R
		dc.w $797
		dc.l S1Map_SS_R
		dc.w $7A0
		dc.l S1Map_SS_R
		dc.w $7A9
		dc.l Map_Obj25
		dc.w $27B2
		dc.l S1Map_SS_Chaos3
		dc.w $770
		dc.l S1Map_SS_Chaos3
		dc.w $2770
		dc.l S1Map_SS_Chaos3
		dc.w $4770
		dc.l S1Map_SS_Chaos3
		dc.w $6770
		dc.l S1Map_SS_Chaos1
		dc.w $770
		dc.l S1Map_SS_Chaos2
		dc.w $770
		dc.l S1Map_SS_R
		dc.w $4F0
		dc.l Map_Obj25+$4000000
		dc.w $27B2
		dc.l Map_Obj25+$5000000
		dc.w $27B2
		dc.l Map_Obj25+$6000000
		dc.w $27B2
		dc.l Map_Obj25+$7000000
		dc.w $27B2
		dc.l S1Map_SS_Glass
		dc.w $23F0
		dc.l S1Map_SS_Glass+$1000000
		dc.w $23F0
		dc.l S1Map_SS_Glass+$2000000
		dc.w $23F0
		dc.l S1Map_SS_Glass+$3000000
		dc.w $23F0
		dc.l S1Map_SS_R+$2000000
		dc.w $4F0
		dc.l S1Map_SS_Glass
		dc.w $5F0
		dc.l S1Map_SS_Glass
		dc.w $65F0
		dc.l S1Map_SS_Glass
		dc.w $25F0
		dc.l S1Map_SS_Glass
		dc.w $45F0
S1SS_MapIndex_End:
; ===========================================================================
; Rather humourously, these sprite mappings are stored in the Sonic 1 format
; ---------------------------------------------------------------------------
; Sprite mappings - 'R'
; ---------------------------------------------------------------------------
S1Map_SS_R:	dc.w byte_1A344-S1Map_SS_R
		dc.w byte_1A34A-S1Map_SS_R
		dc.w word_1A350-S1Map_SS_R
byte_1A344:	dc.b 1
		dc.b $F4, $A,  0,  0,$F4
byte_1A34A:	dc.b 1
		dc.b $F4, $A,  0,  9,$F4
word_1A350:	dc.w 0
; ---------------------------------------------------------------------------
; Sprite mappings - Glass
; ---------------------------------------------------------------------------
S1Map_SS_Glass:	dc.w byte_1A35A-S1Map_SS_Glass
		dc.w byte_1A360-S1Map_SS_Glass
		dc.w byte_1A366-S1Map_SS_Glass
		dc.w byte_1A36C-S1Map_SS_Glass
byte_1A35A:	dc.b 1
		dc.b $F4, $A,  0,  0,$F4
byte_1A360:	dc.b 1
		dc.b $F4, $A,  8,  0,$F4
byte_1A366:	dc.b 1
		dc.b $F4, $A,$18,  0,$F4
byte_1A36C:	dc.b 1
		dc.b $F4, $A,$10,  0,$F4
; ---------------------------------------------------------------------------
; Sprite mappings - 'Up'
; ---------------------------------------------------------------------------
S1Map_SS_Up:	dc.w byte_1A376-S1Map_SS_Up
		dc.w byte_1A37C-S1Map_SS_Up
byte_1A376:	dc.b 1
		dc.b $F4, $A,  0,  0,$F4
byte_1A37C:	dc.b 1
		dc.b $F4, $A,  0,$12,$F4
; ---------------------------------------------------------------------------
; Sprite mappings - 'Down'
; ---------------------------------------------------------------------------
S1Map_SS_Down:	dc.w byte_1A386-S1Map_SS_Down
		dc.w byte_1A38C-S1Map_SS_Down
byte_1A386:	dc.b 1
		dc.b $F4, $A,  0,  9,$F4
byte_1A38C:	dc.b 1
		dc.b $F4, $A,  0,$12,$F4
; ---------------------------------------------------------------------------
; Sprite mappings - Chaos Emeralds
; Merged together; can't split to file in a useful way...
; ---------------------------------------------------------------------------
S1Map_SS_Chaos1:dc.w byte_1A39E-S1Map_SS_Chaos1
		dc.w byte_1A3B0-S1Map_SS_Chaos1
S1Map_SS_Chaos2:dc.w byte_1A3A4-S1Map_SS_Chaos2
		dc.w byte_1A3B0-S1Map_SS_Chaos2
S1Map_SS_Chaos3:dc.w byte_1A3AA-S1Map_SS_Chaos3
		dc.w byte_1A3B0-S1Map_SS_Chaos3
byte_1A39E:	dc.b 1
		dc.b $F8,  5,  0,  0,$F8
byte_1A3A4:	dc.b 1
		dc.b $F8,  5,  0,  4,$F8
byte_1A3AA:	dc.b 1
		dc.b $F8,  5,  0,  8,$F8
byte_1A3B0:	dc.b 1
		dc.b $F8,  5,  0, $C,$F8
; ===========================================================================
		nop
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 09 - Sonic in Special Stage
; ---------------------------------------------------------------------------

Obj09:
		tst.w	(Debug_placement_mode).w
		beq.s	Obj09_Normal
		bsr.w	S1SS_FixCamera
		bra.w	DebugMode
; ---------------------------------------------------------------------------

Obj09_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj09_Index(pc,d0.w),d1
		jmp	Obj09_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Obj09_Index:	dc.w loc_1A3DC-Obj09_Index
		dc.w loc_1A41C-Obj09_Index
		dc.w loc_1A618-Obj09_Index
		dc.w loc_1A66C-Obj09_Index
; ---------------------------------------------------------------------------

loc_1A3DC:
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#$780,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_7
		move.b	#4,obRender(a0)
		move.b	#0,obPriority(a0)
		move.b	#2,obAnim(a0)
		bset	#2,obStatus(a0)
		bset	#1,obStatus(a0)

loc_1A41C:
		tst.w	(Debug_mode_flag).w
		beq.s	loc_1A430
		btst	#4,(v_jpadpress1).w
		beq.s	loc_1A430
		move.w	#1,(Debug_placement_mode).w

loc_1A430:
		move.b	#0,$30(a0)
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#2,d0
		move.w	Obj09_Modes(pc,d0.w),d1
		jsr	Obj09_Modes(pc,d1.w)
		jsr	(LoadSonicDynPLC).l
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------
Obj09_Modes:	dc.w Obj09_OnWall-Obj09_Modes
		dc.w Obj09_InAir-Obj09_Modes
; ---------------------------------------------------------------------------

Obj09_OnWall:
		bsr.w	Obj09_Jump
		bsr.w	Obj09_Move
		bsr.w	Obj09_Fall
		bra.s	Obj09_Display
; ---------------------------------------------------------------------------

Obj09_InAir:
		bsr.w	nullsub_2
		bsr.w	Obj09_Move
		bsr.w	Obj09_Fall

Obj09_Display:
		bsr.w	Obj09_ChkItems
		bsr.w	Obj09_ChkItems2
		jsr	(ObjectMove).l
		bsr.w	S1SS_FixCamera
		move.w	($FFFFF780).w,d0
		add.w	($FFFFF782).w,d0
		move.w	d0,($FFFFF780).w
		jsr	(Sonic_Animate).l
		rts

; =============== S U B	R O U T	I N E =======================================


Obj09_Move:
		btst	#2,(v_jpadhold2).w
		beq.s	loc_1A4A4
		bsr.w	Obj09_MoveLeft

loc_1A4A4:
		btst	#3,(v_jpadhold2).w
		beq.s	loc_1A4B0
		bsr.w	Obj09_MoveRight

loc_1A4B0:
		move.b	(v_jpadhold2).w,d0
		andi.b	#$C,d0
		bne.s	loc_1A4E0
		move.w	obInertia(a0),d0
		beq.s	loc_1A4E0
		bmi.s	loc_1A4D2
		subi.w	#$C,d0
		bcc.s	loc_1A4CC
		move.w	#0,d0

loc_1A4CC:
		move.w	d0,obInertia(a0)
		bra.s	loc_1A4E0
; ---------------------------------------------------------------------------

loc_1A4D2:
		addi.w	#$C,d0
		bcc.s	loc_1A4DC
		move.w	#0,d0

loc_1A4DC:
		move.w	d0,obInertia(a0)

loc_1A4E0:
		move.b	($FFFFF780).w,d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		neg.b	d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		add.l	d1,obX(a0)
		muls.w	obInertia(a0),d0
		add.l	d0,obY(a0)
		movem.l	d0-d1,-(sp)
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		bsr.w	sub_1A720
		beq.s	loc_1A52A
		movem.l	(sp)+,d0-d1
		sub.l	d1,obX(a0)
		sub.l	d0,obY(a0)
		move.w	#0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_1A52A:
		movem.l	(sp)+,d0-d1
		rts
; End of function Obj09_Move


; =============== S U B	R O U T	I N E =======================================


Obj09_MoveLeft:
		bset	#0,obStatus(a0)
		move.w	obInertia(a0),d0
		beq.s	loc_1A53E
		bpl.s	loc_1A552

loc_1A53E:
		subi.w	#$C,d0
		cmpi.w	#$F800,d0
		bgt.s	loc_1A54C
		move.w	#$F800,d0

loc_1A54C:
		move.w	d0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_1A552:
		subi.w	#$40,d0
		bcc.s	loc_1A55A
		nop

loc_1A55A:
		move.w	d0,obInertia(a0)
		rts
; End of function Obj09_MoveLeft


; =============== S U B	R O U T	I N E =======================================


Obj09_MoveRight:
		bclr	#0,obStatus(a0)
		move.w	obInertia(a0),d0
		bmi.s	loc_1A580
		addi.w	#$C,d0
		cmpi.w	#$800,d0
		blt.s	loc_1A57A
		move.w	#$800,d0

loc_1A57A:
		move.w	d0,obInertia(a0)
		bra.s	locret_1A58C
; ---------------------------------------------------------------------------

loc_1A580:
		addi.w	#$40,d0
		bcc.s	loc_1A588
		nop

loc_1A588:
		move.w	d0,obInertia(a0)

locret_1A58C:
		rts
; End of function Obj09_MoveRight


; =============== S U B	R O U T	I N E =======================================


Obj09_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#$70,d0
		beq.s	locret_1A5D0
		move.b	($FFFFF780).w,d0
		andi.b	#$FC,d0
		neg.b	d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	#$680,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#$680,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bset	#1,obStatus(a0)
		move.w	#sfx_Jump,d0
		jsr	(PlaySound_Special).l

locret_1A5D0:
		rts
; End of function Obj09_Jump


; =============== S U B	R O U T	I N E =======================================


nullsub_2:
		rts
; End of function nullsub_2

; ---------------------------------------------------------------------------
		move.w	#$FC00,d1
		cmp.w	obVelY(a0),d1
		ble.s	locret_1A5EC
		move.b	(v_jpadhold2).w,d0
		andi.b	#$70,d0
		bne.s	locret_1A5EC
		move.w	d1,obVelY(a0)

locret_1A5EC:
		rts

; =============== S U B	R O U T	I N E =======================================


S1SS_FixCamera:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		move.w	(Camera_RAM).w,d0
		subi.w	#$A0,d3
		bcs.s	loc_1A606
		sub.w	d3,d0
		sub.w	d0,(Camera_RAM).w

loc_1A606:
		move.w	(Camera_Y_pos).w,d0
		subi.w	#$70,d2
		bcs.s	locret_1A616
		sub.w	d2,d0
		sub.w	d0,(Camera_Y_pos).w

locret_1A616:
		rts
; End of function S1SS_FixCamera

; ---------------------------------------------------------------------------

loc_1A618:
		addi.w	#$40,($FFFFF782).w
		cmpi.w	#$1800,($FFFFF782).w
		bne.s	loc_1A62C
		move.b	#GameModeID_Level,(v_gamemode).w

loc_1A62C:
		cmpi.w	#$3000,($FFFFF782).w
		blt.s	loc_1A64A
		move.w	#0,($FFFFF782).w
		move.w	#$4000,($FFFFF780).w
		addq.b	#2,obRoutine(a0)
		move.w	#$3C,$38(a0)

loc_1A64A:
		move.w	($FFFFF780).w,d0
		add.w	($FFFFF782).w,d0
		move.w	d0,($FFFFF780).w
		jsr	(Sonic_Animate).l
		jsr	(LoadSonicDynPLC).l
		bsr.w	S1SS_FixCamera
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

loc_1A66C:
		subq.w	#1,$38(a0)
		bne.s	loc_1A678
		move.b	#GameModeID_Level,(v_gamemode).w

loc_1A678:
		jsr	(Sonic_Animate).l
		jsr	(LoadSonicDynPLC).l
		bsr.w	S1SS_FixCamera
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


Obj09_Fall:
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		move.b	($FFFFF780).w,d0
		andi.b	#$FC,d0
		jsr	(CalcSine).l
		move.w	obVelX(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d0
		add.l	d4,d0
		move.w	obVelY(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d1
		add.l	d4,d1
		add.l	d0,d3
		bsr.w	sub_1A720
		beq.s	loc_1A6E8
		sub.l	d0,d3
		moveq	#0,d0
		move.w	d0,obVelX(a0)
		bclr	#1,obStatus(a0)
		add.l	d1,d2
		bsr.w	sub_1A720
		beq.s	loc_1A6FE
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_1A6E8:
		add.l	d1,d2
		bsr.w	sub_1A720
		beq.s	loc_1A70C
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)
		bclr	#1,obStatus(a0)

loc_1A6FE:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_1A70C:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		bset	#1,obStatus(a0)
		rts
; End of function Obj09_Fall


; =============== S U B	R O U T	I N E =======================================


sub_1A720:
		lea	(v_startofram).l,a1
		moveq	#0,d4
		swap	d2
		move.w	d2,d4
		swap	d2
		addi.w	#$44,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		swap	d3
		move.w	d3,d4
		swap	d3
		addi.w	#$14,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		moveq	#0,d5
		move.b	(a1)+,d4
		bsr.s	sub_1A768
		move.b	(a1)+,d4
		bsr.s	sub_1A768
		adda.w	#$7E,a1
		move.b	(a1)+,d4
		bsr.s	sub_1A768
		move.b	(a1)+,d4
		bsr.s	sub_1A768
		tst.b	d5
		rts
; End of function sub_1A720


; =============== S U B	R O U T	I N E =======================================


sub_1A768:
		beq.s	locret_1A77C
		cmpi.b	#$28,d4
		beq.s	locret_1A77C
		cmpi.b	#$3A,d4
		bcs.s	loc_1A77E
		cmpi.b	#$4B,d4
		bcc.s	loc_1A77E

locret_1A77C:
		rts
; ---------------------------------------------------------------------------

loc_1A77E:
		move.b	d4,$30(a0)
		move.l	a1,$32(a0)
		moveq	#-1,d5
		rts
; End of function sub_1A768


; =============== S U B	R O U T	I N E =======================================


Obj09_ChkItems:
		lea	(v_startofram).l,a1
		moveq	#0,d4
		move.w	obY(a0),d4
		addi.w	#$50,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		move.w	obX(a0),d4
		addi.w	#$20,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		move.b	(a1),d4
		bne.s	loc_1A7C4
		tst.b	$3A(a0)
		bne.w	loc_1A894
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1A7C4:
		cmpi.b	#$3A,d4
		bne.s	loc_1A800
		bsr.w	sub_19EEC
		bne.s	loc_1A7D8
		move.b	#1,(a2)
		move.l	a1,4(a2)

loc_1A7D8:
		jsr	(sub_A8DE).l
		cmpi.w	#$32,(v_rings).w
		bcs.s	loc_1A7FC
		bset	#0,(v_lifecount).w
		bne.s	loc_1A7FC
		addq.b	#1,(v_continues).w
		move.w	#sfx_Continue,d0
		jsr	(PlaySound).l

loc_1A7FC:
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1A800:
		cmpi.b	#$28,d4
		bne.s	loc_1A82A
		bsr.w	sub_19EEC
		bne.s	loc_1A814
		move.b	#3,(a2)
		move.l	a1,4(a2)

loc_1A814:
		addq.b	#1,(v_lives).w
		addq.b	#1,(f_lifecount).w
		move.w	#bgm_ExtraLife,d0
		jsr	(PlaySound).l
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1A82A:
		cmpi.b	#$3B,d4
		bcs.s	loc_1A870
		cmpi.b	#$40,d4
		bhi.s	loc_1A870
		bsr.w	sub_19EEC
		bne.s	loc_1A844
		move.b	#5,(a2)
		move.l	a1,4(a2)

loc_1A844:
		cmpi.b	#6,(v_emeralds).w
		beq.s	loc_1A862
		subi.b	#$3B,d4
		moveq	#0,d0
		move.b	(v_emeralds).w,d0
		lea	(v_emldlist).w,a2
		move.b	d4,(a2,d0.w)
		addq.b	#1,(v_emeralds).w

loc_1A862:
		move.w	#bgm_Emerald,d0
		jsr	(PlaySound_Special).l
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1A870:
		cmpi.b	#$41,d4
		bne.s	loc_1A87C
		move.b	#1,$3A(a0)

loc_1A87C:
		cmpi.b	#$4A,d4
		bne.s	loc_1A890
		cmpi.b	#1,$3A(a0)
		bne.s	loc_1A890
		move.b	#2,$3A(a0)

loc_1A890:
		moveq	#-1,d4
		rts
; ---------------------------------------------------------------------------

loc_1A894:
		cmpi.b	#2,$3A(a0)
		bne.s	loc_1A8BE
		lea	($FFFF1020).l,a1
		moveq	#$3F,d1

loc_1A8A4:
		moveq	#$3F,d2

loc_1A8A6:
		cmpi.b	#$41,(a1)
		bne.s	loc_1A8B0
		move.b	#$2C,(a1)

loc_1A8B0:
		addq.w	#1,a1
		dbf	d2,loc_1A8A6
		lea	$40(a1),a1
		dbf	d1,loc_1A8A4

loc_1A8BE:
		clr.b	$3A(a0)
		moveq	#0,d4
		rts
; End of function Obj09_ChkItems


; =============== S U B	R O U T	I N E =======================================


Obj09_ChkItems2:
		move.b	$30(a0),d0
		bne.s	loc_1A8E6
		subq.b	#1,$36(a0)
		bpl.s	loc_1A8D8
		move.b	#0,$36(a0)

loc_1A8D8:
		subq.b	#1,$37(a0)
		bpl.s	locret_1A8E4
		move.b	#0,$37(a0)

locret_1A8E4:
		rts
; ---------------------------------------------------------------------------

loc_1A8E6:
		cmpi.b	#$25,d0
		bne.s	loc_1A95E
		move.l	$32(a0),d1
		subi.l	#$FFFF0001,d1
		move.w	d1,d2
		andi.w	#$7F,d1
		mulu.w	#$18,d1
		subi.w	#$14,d1
		lsr.w	#7,d2
		andi.w	#$7F,d2
		mulu.w	#$18,d2
		subi.w	#$44,d2
		sub.w	obX(a0),d1
		sub.w	obY(a0),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#$F900,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#$F900,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bset	#1,obStatus(a0)
		bsr.w	sub_19EEC
		bne.s	loc_1A954
		move.b	#2,(a2)
		move.l	$32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

loc_1A954:
		move.w	#sfx_Bumper,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------

loc_1A95E:
		cmpi.b	#$27,d0
		bne.s	loc_1A974
		addq.b	#2,obRoutine(a0)
		move.w	#sfx_SSGoal,d0
		jsr	(PlaySound_Special).l
		rts
; ---------------------------------------------------------------------------

loc_1A974:
		cmpi.b	#$29,d0
		bne.s	loc_1A9A8
		tst.b	$36(a0)
		bne.w	locret_1AA58
		move.b	#$1E,$36(a0)
		btst	#6,($FFFFF783).w
		beq.s	loc_1A99E
		asl	($FFFFF782).w
		movea.l	$32(a0),a1
		subq.l	#1,a1
		move.b	#$2A,(a1)

loc_1A99E:
		move.w	#sfx_SSItem,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------

loc_1A9A8:
		cmpi.b	#$2A,d0
		bne.s	loc_1A9DC
		tst.b	$36(a0)
		bne.w	locret_1AA58
		move.b	#$1E,$36(a0)
		btst	#6,($FFFFF783).w
		bne.s	loc_1A9D2
		asr	($FFFFF782).w
		movea.l	$32(a0),a1
		subq.l	#1,a1
		move.b	#$29,(a1)

loc_1A9D2:
		move.w	#sfx_SSItem,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------

loc_1A9DC:
		cmpi.b	#$2B,d0
		bne.s	loc_1AA12
		tst.b	$37(a0)
		bne.w	locret_1AA58
		move.b	#$1E,$37(a0)
		bsr.w	sub_19EEC
		bne.s	loc_1AA04
		move.b	#4,(a2)
		move.l	$32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

loc_1AA04:
		neg.w	($FFFFF782).w
		move.w	#sfx_SSItem,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------

loc_1AA12:
		cmpi.b	#$2D,d0
		beq.s	loc_1AA2A
		cmpi.b	#$2E,d0
		beq.s	loc_1AA2A
		cmpi.b	#$2F,d0
		beq.s	loc_1AA2A
		cmpi.b	#$30,d0
		bne.s	locret_1AA58

loc_1AA2A:
		bsr.w	sub_19EEC
		bne.s	loc_1AA4E
		move.b	#6,(a2)
		movea.l	$32(a0),a1
		subq.l	#1,a1
		move.l	a1,4(a2)
		move.b	(a1),d0
		addq.b	#1,d0
		cmpi.b	#$30,d0
		bls.s	loc_1AA4A
		clr.b	d0

loc_1AA4A:
		move.b	d0,4(a2)

loc_1AA4E:
		move.w	#sfx_SSGlass,d0
		jmp	(PlaySound_Special).l
; ---------------------------------------------------------------------------

locret_1AA58:
		rts
; End of function Obj09_ChkItems2

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 10 - Blank, animation test in Sonic 1 prototype
; ---------------------------------------------------------------------------

Obj10:
		rts
; ===========================================================================

j_Adjust2PArtPointer_7:					; JmpTo
		jmp	(Adjust2PArtPointer).l

		align 4

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to animate stage art
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DynamicArtCues:
AniArt_Load:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	DynArtCue_Index+2(pc,d0.w),d1
		lea	DynArtCue_Index(pc,d1.w),a2
		move.w	DynArtCue_Index(pc,d0.w),d0
		jmp	DynArtCue_Index(pc,d0.w)
; ---------------------------------------------------------------------------
		rts
; End of function AniArt_Load

; ---------------------------------------------------------------------------
; ZONE ANIMATION PROCEDURES AND SCRIPTS
;
; Each zone gets two entries in this jump table. The first entry points to the
; zone's animation procedure (usually Dynamic_Null, AKA none). The second points
; to the zone's animation script.
;
; Seems like stage IDs were already being shifted, since listings for $07-$0F
; can be found, alongside HPZ's art listed from $08 (its ID in the final).
; ---------------------------------------------------------------------------
DynArtCue_Index:
		dc.w Dynamic_NullGHZ-DynArtCue_Index
                dc.w AnimCue_EHZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Normal-DynArtCue_Index
                dc.w AnimCue_EHZ-DynArtCue_Index
		dc.w Dynamic_Normal-DynArtCue_Index
                dc.w AnimCue_HPZ-DynArtCue_Index
		dc.w Dynamic_Normal-DynArtCue_Index
                dc.w AnimCue_EHZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Normal-DynArtCue_Index
                dc.w AnimCue_HPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
		dc.w Dynamic_Null-DynArtCue_Index
                dc.w AnimCue_CPZ-DynArtCue_Index
; ===========================================================================

Dynamic_Null:
		rts
; ===========================================================================

Dynamic_NullGHZ:
		rts
; ===========================================================================

Dynamic_Normal:
		lea	(Anim_Counters).w,a3
		move.w	(a2)+,d6			; Get number of scripts in list

loc_1AACA:
		subq.b	#1,(a3)				; Tick down frame duration
		bpl.s	loc_1AB10			; If frame isn't over, move on to next script

		moveq	#0,d0
		move.b	obRender(a3),d0			; Get current frame
		cmp.b	6(a2),d0			; Have we processed the last frame in the script?
		bcs.s	loc_1AAE0
		moveq	#0,d0				; If so, reset to first frame
		move.b	d0,1(a3)

loc_1AAE0:
		addq.b	#1,1(a3)			; Consider this frame processed; set counter to next frame
		move.b	(a2),(a3)			; Set frame duration to global duration value
		bpl.s	loc_1AAEE
		; If script uses per-frame durations, use those instead
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)			; Set frame duration to current frame's duration value

loc_1AAEE:
		; Prepare for DMA transfer
		; Get relative address of frame's art
		move.b	8(a2,d0.w),d0			; Get tile ID
		lsl.w	#5,d0				; Turn it into an offset
		; Get VRAM destination address
		move.w	4(a2),d2
		; Get ROM source address
		move.l	(a2),d1				; Get start address of animated tile art
		andi.l	#$FFFFFF,d1
		add.l	d0,d1				; Offset into art, to get the address of new frame
		; Get size of art to be transferred
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3				; Turn it into actual size (in words)
		; Use d1, d2 and d3 to queue art for transfer
		jsr	(QueueDMATransfer).l

loc_1AB10:
		move.b	6(a2),d0			; Get total size of frame data
		tst.b	(a2)				; Is per-frame duration data present?
		bpl.s	loc_1AB1A			; If not, keep the current size; it's correct
		add.b	d0,d0				; Double size to account for the additional frame duration data

loc_1AB1A:
		addq.b	#1,d0
		andi.w	#$FE,d0				; Round to next even address, if it isn't already
		lea	8(a2,d0.w),a2			; Advance to next script in list
		addq.w	#2,a3				; Advance to next script's slot in a3 (usually Anim_Counters)
		dbf	d6,loc_1AACA
		rts
; ===========================================================================
AnimCue_EHZ:	dc.w 4
		dc.l Art_EHZFlower1+$FF000000
		dc.w $7280
		dc.b 6
		dc.b 2
		dc.b   0,$7F				; 0
		dc.b   2,$13				; 2
		dc.b   0,  7				; 4
		dc.b   2,  7				; 6
		dc.b   0,  7				; 8
		dc.b   2,  7				; 10
		dc.l Art_EHZFlower2+$FF000000
		dc.w $72C0
		dc.b 8
		dc.b 2
		dc.b   2,$7F				; 0
		dc.b   0, $B				; 2
		dc.b   2, $B				; 4
		dc.b   0, $B				; 6
		dc.b   2,  5				; 8
		dc.b   0,  5				; 10
		dc.b   2,  5				; 12
		dc.b   0,  5				; 14
		dc.l Art_EHZFlower3+$7000000
		dc.w $7300
		dc.b 2
		dc.b 2
		dc.b   0,  2				; 0
		dc.l Art_EHZFlower4+$FF000000
		dc.w $7340
		dc.b 8
		dc.b 2
		dc.b   0,$7F				; 0
		dc.b   2,  7				; 2
		dc.b   0,  7				; 4
		dc.b   2,  7				; 6
		dc.b   0,  7				; 8
		dc.b   2, $B				; 10
		dc.b   0, $B				; 12
		dc.b   2, $B				; 14
		dc.l Art_EHZFlower5+$1000000
		dc.w $7380
		dc.b 6
		dc.b 2
		dc.b   0,  2				; 0
		dc.b   4,  6				; 2
		dc.b   4,  2				; 4

AnimCue_HPZ:	dc.w 2
		dc.l Art_HPZGlowingBall+$8000000
		dc.w $5D00
		dc.b 6
		dc.b 8
		dc.b   0,  0				; 0
		dc.b   8,$10				; 2
		dc.b $10,  8				; 4
		dc.l Art_HPZGlowingBall+$8000000
		dc.w $5E00
		dc.b 6
		dc.b 8
		dc.b   8,$10				; 0
		dc.b $10,  8				; 2
		dc.b   0,  0				; 4
		dc.l Art_HPZGlowingBall+$8000000
		dc.w $5F00
		dc.b 6
		dc.b 8
		dc.b $10,  8				; 0
		dc.b   0,  0				; 2
		dc.b   8,$10				; 4

; According to leftover resizing code, this was meant for the
; Chemical Plant Zone boss, which symbol tables refer to as "vaccume".
AnimCue_CPZ:	dc.w 7
		dc.l Art_UnkZone_1+$7000000
		dc.w $9000
		dc.b 2
		dc.b 4
		dc.b   0,  4				; 0
		dc.l Art_UnkZone_2+$7000000
		dc.w $9080
		dc.b 3
		dc.b 8
		dc.b   0,  8				; 0
		dc.b $10,  0				; 2
		dc.l Art_UnkZone_3+$7000000
		dc.w $9180
		dc.b 4
		dc.b 2
		dc.b   0,  2				; 0
		dc.b   0,  4				; 2
		dc.l Art_UnkZone_4+$B000000
		dc.w $91C0
		dc.b 4
		dc.b 2
		dc.b   0,  2				; 0
		dc.b   4,  2				; 2
		dc.l Art_UnkZone_5+$F000000
		dc.w $9200
		dc.b $A
		dc.b 1
		dc.b   0				; 0
		dc.b   0				; 1
		dc.b   1				; 2
		dc.b   2				; 3
		dc.b   3				; 4
		dc.b   4				; 5
		dc.b   5				; 6
		dc.b   4				; 7
		dc.b   5				; 8
		dc.b   4				; 9
		dc.l Art_UnkZone_6+$3000000
		dc.w $9220
		dc.b 4
		dc.b 4
		dc.b   0,  4				; 0
		dc.b   8,  4				; 2
		dc.l Art_UnkZone_7+$7000000
		dc.w $92A0
		dc.b 6
		dc.b 3
		dc.b   0,  3				; 0
		dc.b   6,  9				; 2
		dc.b  $C, $F				; 4
		dc.l Art_UnkZone_8+$7000000
		dc.w $9300
		dc.b 4
		dc.b 1
		dc.b   0				; 0
		dc.b   1				; 1
		dc.b   2				; 2
		dc.b   3				; 3

; ===========================================================================
; ---------------------------------------------------------------------------
; This seems to be a subroutine that would've shifted the background blocks
; of Chemical Plant Zone once the player reached a certain X position,
; lasting exactly two screens. This can also be found in the final at
; $40200 in the ROM, with the only difference being its level ID, which
; was updated to match Chemical Plant's final ID ($0D instead of 02)
;
; To see the effect for yourself, add a branch to it at the
; start of LoadTilesAsYouMove and change $FFFF7500/$FFFF7D00 to
; $FFFF0000/$FFFF0800 (to make it more visible)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; sub_1AC1E: ShiftCPZBackground:
		cmpi.b	#2,(Current_Zone).w		; is this Chemical Plant Zone?
		beq.s	loc_1AC28			; if yes, branch

locret_1AC26:
		rts
; ===========================================================================
; this shifts all blocks of the chunks $EA-$ED and $FA-$FD one block to the
; left and the last block in each row (chunk $ED/$FD) to the beginning
; i.e. rotates the blocks to the left by one

loc_1AC28:
		move.w	(Camera_RAM).w,d0
		cmpi.w	#$1940,d0
		bcs.s	locret_1AC26
		cmpi.w	#$1F80,d0
		bcc.s	locret_1AC26
		subq.b	#1,(byte_FFFFF721).w
		bpl.s	locret_1AC26
		move.b	#7,(byte_FFFFF721).w
		move.b	#1,(byte_FFFFF720).w
		lea	($FFFF7500).l,a1
		bsr.s	sub_1AC58
		lea	($FFFF7D00).l,a1

sub_1AC58:
		move.w	#7,d1

loc_1AC5C:
		move.w	(a1),d0
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	d0,(a1)+
		suba.w	#$180,a1
		dbf	d1,loc_1AC5C
		rts
; End of function ShiftCPZBackground

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load animated blocks
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; LoadMap16Delta:
LoadAnimatedBlocks:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	AnimPatMaps(pc,d0.w),d0
		lea	AnimPatMaps(pc,d0.w),a0
		tst.w	(a0)
		beq.s	locret_1AD1A
		lea	(v_16x16).w,a1
		adda.w	(a0)+,a1
		move.w	(a0)+,d1
		tst.w	(Two_player_mode).w
		bne.s	LoadLevelBlocks_2P
; loc_1AD14:
LoadLevelBlocks:
		move.w	(a0)+,(a1)+
		dbf	d1,LoadLevelBlocks

locret_1AD1A:
		rts
; ---------------------------------------------------------------------------
; loc_1AD1C:
LoadLevelBlocks_2P:
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#$F800,d0
		andi.w	#$7FF,d1
		lsr.w	#1,d1
		or.w	d1,d0
		move.w	d0,(a1)+
		dbf	d1,LoadLevelBlocks_2P
		rts
; End of function LoadAnimatedBlocks

; ===========================================================================
; like with the animated stage art, this already lists stages up to $0F and
; includes an entry for the final HPZ level slot, and this time even lists
; CPZ's final level slot
; Map16Delta_Index:
AnimPatMaps:
		dc.w APM_GHZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_CPZ-AnimPatMaps
		dc.w APM_GHZ-AnimPatMaps
		dc.w APM_HPZ-AnimPatMaps
		dc.w APM_GHZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_HPZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_CPZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps
		dc.w APM_LZ-AnimPatMaps

APM_GHZ:	dc.w $1788,  $3B,$4502,$4504,$4503,$4505,$4506,$4508,$4507,$4509,$450A,$450C,$450B,$450D,$450E,$4510
		dc.w $450F,$4511,$4512,$4514,$4513,$4515,$4516,$4518,$4517,$4519,$651A,$651C,$651B,$651D,$651E,$6520
		dc.w $651F,$6521,$439C,$4B9C,$439D,$4B9D,$4158,$439C,$4159,$439D,$4B9C,$4958,$4B9D,$4959,$6394,$6B94
		dc.w $6395,$6B95,$E396,$EB96,$E397,$EB97,$6398,$6B98,$6399,$6B99,$E39A,$EB9A,$E39B,$EB9B

APM_LZ:		dc.w	 0, $C80,  $9B,$43A1,$43A2,$43A3,$43A4,$43A5,$43A6,$43A7,$43A8,$43A9,$43AA,$43AB,$43AC,$43AD
		dc.w $43AE,$43AF,$43B0,$43B1,$43B2,$43B3,$43B4,$43B5,$43B6,$43B7,$43B8,$43B9,$43BA,$43BB,$43BC,$43BD
		dc.w $43BE,$43BF,$43C0,$43C1,$43C2,$43C3,$43C4,$63A0,$63A0,$63A0,$63A0,$63A0,$63A0,$63A0,$63A0,	   0
		dc.w	 0,$6340,$6344,	   0,	 0,$6348,$634C,$6341,$6345,$6342,$6346,$6349,$634D,$634A,$634E,$6343
		dc.w $6347,$4358,$4359,$634B,$634F,$435A,$435B,$6380,$6384,$6381,$6385,$6388,$638C,$6389,$638D,$6382
		dc.w $6386,$6383,$6387,$638A,$638E,$638B,$638F,$6390,$6394,$6391,$6395,$6398,$639C,$6399,$639D,$6392
		dc.w $6396,$6393,$6397,$639A,$639E,$639B,$639F,$4378,$4379,$437A,$437B,$437C,$437D,$437E,$437F,$235C
		dc.w $235D,$235E,$235F,$2360,$2361,$2362,$2363,$2364,$2365,$2366,$2367,$2368,$2369,$236A,$236B,	   0
		dc.w	 0,$636C,$636D,	   0,	 0,$636E,    0,$636F,$6370,$6371,$6372,$6373,	 0,$6374,    0,$6375
		dc.w $6376,$4358,$4359,$6377,	 0,$435A,$435B,$C378,$C379,$C37A,$C37B,$C37C,$C37D,$C37E,$C37F

APM_CPZ:	dc.w $17E0,   $F,$43D1,$43D1,$43D1,$43D1,$43D2,$43D2,$43D3,$43D3,$43D4,$43D4,$43D5,$43D5,$43D6,$43D6
		dc.w $43D7,$43D7

APM_HPZ:	dc.w $1710,  $77,$62E8,$62E9,$62EA,$62EB,$62EC,$62ED,$62EE,$62EF,$62F0,$62F1,$62F2,$62F3,$62F4,$62F5
		dc.w $62F6,$62F7,$62F8,$62F9,$62FA,$62FB,$62FC,$62FD,$62FE,$62FF,$42E8,$42E9,$42EA,$42EB,$42EC,$42ED
		dc.w $42EE,$42EF,$42F0,$42F1,$42F2,$42F3,$42F4,$42F5,$42F6,$42F7,$42F8,$42F9,$42FA,$42FB,$42FC,$42FD
		dc.w $42FE,$42FF,    0,$62E8,	 0,$62EA,$62E9,$62EC,$62EB,$62EE,$62ED,	   0,$62EF,    0,    0,$62F0
		dc.w	 0,$62F2,$62F1,$62F4,$62F3,$62F6,$62F5,	   0,$62F7,    0,    0,$62F8,	 0,$62FA,$62F9,$62FC
		dc.w $62FB,$62FE,$62FD,	   0,$62FF,    0,    0,$42E8,	 0,$42EA,$42E9,$42EC,$42EB,$42EE,$42ED,	   0
		dc.w $42EF,    0,    0,$42F0,	 0,$42F2,$42F1,$42F4,$42F3,$42F6,$42F5,	   0,$42F7,    0,    0,$42F8
		dc.w	 0,$42FA,$42F9,$42FC,$42FB,$42FE,$42FD,	   0,$42FF,    0
		nop

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 21 - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------

Obj21:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj21_Index(pc,d0.w),d1
		jmp	Obj21_Index(pc,d1.w)
; ===========================================================================
Obj21_Index:	dc.w Obj21_Init-Obj21_Index
		dc.w Obj21_Main-Obj21_Index
; ===========================================================================

Obj21_Init:
		addq.b	#2,obRoutine(a0)
		move.w	#$90,obX(a0)
		move.w	#$108,obScreenY(a0)
		move.l	#Map_obj21,obMap(a0)
		move.w	#$6CA,obGfx(a0)
		bsr.w	j_Adjust2PArtPointer_8
		move.b	#0,obRender(a0)
		move.b	#0,obPriority(a0)

Obj21_Main:
		tst.w	(v_rings).w
		beq.s	Obj21_NoRings
		moveq	#0,d0
		btst	#3,(Timer_frames+1).w
		bne.s	Obj21_Display
		cmpi.b	#9,(v_timemin).w
		bne.s	Obj21_Display
		addq.w	#2,d0
; loc_1B082:
Obj21_Display:
		move.b	d0,obFrame(a0)
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------
; loc_1B08C:
Obj21_NoRings:
		moveq	#0,d0
		btst	#3,(Timer_frames+1).w
		bne.s	Obj21_Display2
		addq.w	#1,d0
		cmpi.b	#9,(v_timemin).w
		bne.s	Obj21_Display2
		addq.w	#2,d0
; loc_1B0A2:
Obj21_Display2:
		move.b	d0,obFrame(a0)
		jmp	(DisplaySprite).l
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_obj21:	binclude	"mappings/sprite/obj21.bin"

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add points to the score counter
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


AddPoints:
		move.b	#1,(f_scorecount).w
		lea	(v_score).w,a3
		add.l	d0,(a3)
		move.l	#999999,d1
		cmp.l	(a3),d1
		bhi.s	loc_1B214
		move.l	d1,(a3)

loc_1B214:
		move.l	(a3),d0
		cmp.l	(v_scorelife).w,d0
		bcs.s	locret_1B23C
		addi.l	#5000,(v_scorelife).w
		tst.b	(v_megadrive).w			; is this a Japanese console?
		bmi.s	locret_1B23C			; if not, branch
		addq.b	#1,(v_lives).w
		addq.b	#1,(f_lifecount).w
		move.w	#bgm_ExtraLife,d0
		jmp	(PlaySound).l

locret_1B23C:
		rts
; End of function AddPoints


; =============== S U B	R O U T	I N E =======================================


HudUpdate:
		nop
		lea	(vdp_data_port).l,a6
		tst.w	(Debug_mode_flag).w
		bne.w	loc_1B330
		tst.b	(f_scorecount).w
		beq.s	loc_1B266
		clr.b	(f_scorecount).w
		move.l	#$5C800003,d0
		move.l	(v_score).w,d1
		bsr.w	HUD_Score

loc_1B266:
		tst.b	(f_ringcount).w
		beq.s	loc_1B286
		bpl.s	loc_1B272
		bsr.w	HUD_LoadZero

loc_1B272:
		clr.b	(f_ringcount).w
		move.l	#$5F400003,d0
		moveq	#0,d1
		move.w	(v_rings).w,d1
		bsr.w	HUD_Rings

loc_1B286:
		tst.b	(f_timecount).w
		beq.s	loc_1B2E2
		tst.w	($FFFFF63A).w
		bne.s	loc_1B2E2
		lea	(v_time).w,a1
		cmpi.l	#$93B3B,(a1)+			; if the timer has passed 9:59...
		nop					; ...do nothing since this has been nopped out
		addq.b	#1,-(a1)
		cmpi.b	#$3C,(a1)
		bcs.s	loc_1B2E2
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmpi.b	#$3C,(a1)
		bcs.s	loc_1B2C2
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmpi.b	#9,(a1)
		bcs.s	loc_1B2C2
		move.b	#9,(a1)

loc_1B2C2:
		move.l	#$5E400003,d0
		moveq	#0,d1
		move.b	(v_timemin).w,d1
		bsr.w	HUD_Mins
		move.l	#$5EC00003,d0
		moveq	#0,d1
		move.b	(v_timesec).w,d1
		bsr.w	HUD_Secs

loc_1B2E2:
		tst.b	(f_lifecount).w
		beq.s	loc_1B2F0
		clr.b	(f_lifecount).w
		bsr.w	HUD_Lives

loc_1B2F0:
		tst.b	(f_endactbonus).w
		beq.s	locret_1B318
		clr.b	(f_endactbonus).w
		move.l	#$6E000002,(vdp_control_port).l
		moveq	#0,d1
		move.w	(v_timebonus).w,d1
		bsr.w	HUD_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1
		bsr.w	HUD_TimeRingBonus

locret_1B318:
		rts
; ===========================================================================
; kills the player if the time has reached 9:59, except now it's unused due
; to its "beq" command being noped out above
S1TimeOver:
		clr.b	(f_timecount).w
		lea	(v_objspace).w,a0
		movea.l	a0,a2
		bsr.w	KillSonic
		move.b	#1,(f_timeover).w
		rts
; ---------------------------------------------------------------------------

loc_1B330:
		bsr.w	HUDDebug_XY
		tst.b	(f_ringcount).w
		beq.s	loc_1B354
		bpl.s	loc_1B340
		bsr.w	HUD_LoadZero

loc_1B340:
		clr.b	(f_ringcount).w
		move.l	#$5F400003,d0
		moveq	#0,d1
		move.w	(v_rings).w,d1
		bsr.w	HUD_Rings

loc_1B354:
		move.l	#$5EC00003,d0
		moveq	#0,d1
		move.b	($FFFFF62C).w,d1
		bsr.w	HUD_Secs
		tst.b	(f_lifecount).w
		beq.s	loc_1B372
		clr.b	(f_lifecount).w
		bsr.w	HUD_Lives

loc_1B372:
		tst.b	(f_endactbonus).w
		beq.s	locret_1B39A
		clr.b	(f_endactbonus).w
		move.l	#$6E000002,(vdp_control_port).l
		moveq	#0,d1
		move.w	(v_timebonus).w,d1
		bsr.w	HUD_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1
		bsr.w	HUD_TimeRingBonus

locret_1B39A:
		rts
; End of function HudUpdate


; =============== S U B	R O U T	I N E =======================================


HUD_LoadZero:
		move.l	#$5F400003,(vdp_control_port).l
		lea	HUD_TilesZero(pc),a2
		move.w	#2,d2
		bra.s	loc_1B3CC
; End of function HUD_LoadZero


; =============== S U B	R O U T	I N E =======================================


HUD_Base:
		lea	(vdp_data_port).l,a6
		bsr.w	HUD_Lives
		move.l	#$5C400003,(vdp_control_port).l
		lea	HUD_TilesBase(pc),a2
		move.w	#$E,d2

loc_1B3CC:
		lea	Art_HUD(pc),a1

loc_1B3D0:
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	loc_1B3EC
		ext.w	d0
		lsl.w	#5,d0
		lea	(a1,d0.w),a3

loc_1B3E0:
		move.l	(a3)+,(a6)
		dbf	d1,loc_1B3E0

loc_1B3E6:
		dbf	d2,loc_1B3D0
		rts
; ---------------------------------------------------------------------------

loc_1B3EC:
		move.l	#0,(a6)
		dbf	d1,loc_1B3EC
		bra.s	loc_1B3E6
; End of function HUD_Base

; ---------------------------------------------------------------------------
HUD_TilesBase:	dc.b $16,$FF,$FF,$FF,$FF,$FF,$FF,  0,  0,$14,  0,  0 ; 0
HUD_TilesZero:	dc.b $FF,$FF,  0,  0			; 0

; =============== S U B	R O U T	I N E =======================================


HUDDebug_XY:
		move.l	#$5C400003,(vdp_control_port).l
		move.w	(Camera_RAM).w,d1
		swap	d1
		move.w	(v_objspace+obX).w,d1
		bsr.s	HUDDebug_XY2
		move.w	(Camera_Y_pos).w,d1
		swap	d1
		move.w	(v_objspace+obY).w,d1
; End of function HUDDebug_XY


; =============== S U B	R O U T	I N E =======================================


HUDDebug_XY2:
		moveq	#7,d6
		lea	(Art_Text).l,a1

loc_1B430:
		rol.w	#4,d1
		move.w	d1,d2
		andi.w	#$F,d2
		cmpi.w	#$A,d2
		bcs.s	loc_1B442
		addi.w	#7,d2

loc_1B442:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		swap	d1
		dbf	d6,loc_1B430
		rts
; End of function HUDDebug_XY2


; =============== S U B	R O U T	I N E =======================================


HUD_Rings:
		lea	(HUD_100).l,a2
		moveq	#2,d6
		bra.s	loc_1B472
; End of function HUD_Rings


; =============== S U B	R O U T	I N E =======================================


HUD_Score:
		lea	(HUD_100000).l,a2
		moveq	#5,d6

loc_1B472:
		moveq	#0,d4
		lea	Art_HUD(pc),a1

loc_1B478:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1B47C:
		sub.l	d3,d1
		bcs.s	loc_1B484
		addq.w	#1,d2
		bra.s	loc_1B47C
; ---------------------------------------------------------------------------

loc_1B484:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1B48E
		move.w	#1,d4

loc_1B48E:
		tst.w	d4
		beq.s	loc_1B4BC
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1B4BC:
		addi.l	#$400000,d0
		dbf	d6,loc_1B478
		rts
; End of function HUD_Score

; ---------------------------------------------------------------------------

HUD_Unk:
		move.l	#$5F800003,(vdp_control_port).l
		lea	(vdp_data_port).l,a6
		lea	(HUD_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_HUD(pc),a1

loc_1B4E6:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1B4EA:
		sub.l	d3,d1
		bcs.s	loc_1B4F2
		addq.w	#1,d2
		bra.s	loc_1B4EA
; ---------------------------------------------------------------------------

loc_1B4F2:
		add.l	d3,d1
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		dbf	d6,loc_1B4E6
		rts
; ---------------------------------------------------------------------------
HUD_100000:	dc.l 100000
HUD_10000:	dc.l 10000
HUD_1000:	dc.l 1000
HUD_100:	dc.l 100
HUD_10:		dc.l 10
HUD_1:		dc.l 1

; =============== S U B	R O U T	I N E =======================================


HUD_Mins:
		lea	HUD_1(pc),a2
		moveq	#0,d6
		bra.s	loc_1B546
; End of function HUD_Mins


; =============== S U B	R O U T	I N E =======================================


HUD_Secs:
		lea	HUD_10(pc),a2
		moveq	#1,d6

loc_1B546:
		moveq	#0,d4

loc_1B548:
		lea	Art_HUD(pc),a1

loc_1B54C:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1B550:
		sub.l	d3,d1
		bcs.s	loc_1B558
		addq.w	#1,d2
		bra.s	loc_1B550
; ---------------------------------------------------------------------------

loc_1B558:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1B562
		move.w	#1,d4

loc_1B562:
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$400000,d0
		dbf	d6,loc_1B54C
		rts
; End of function HUD_Secs


; =============== S U B	R O U T	I N E =======================================


HUD_TimeRingBonus:
		lea	HUD_1000(pc),a2
		moveq	#3,d6
		moveq	#0,d4
		lea	Art_HUD(pc),a1

loc_1B5A4:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1B5A8:
		sub.l	d3,d1
		bcs.s	loc_1B5B0
		addq.w	#1,d2
		bra.s	loc_1B5A8
; ---------------------------------------------------------------------------

loc_1B5B0:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1B5BA
		move.w	#1,d4

loc_1B5BA:
		tst.w	d4
		beq.s	loc_1B5EA
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1B5E4:
		dbf	d6,loc_1B5A4
		rts
; ---------------------------------------------------------------------------

loc_1B5EA:
		moveq	#$F,d5

loc_1B5EC:
		move.l	#0,(a6)
		dbf	d5,loc_1B5EC
		bra.s	loc_1B5E4
; End of function HUD_TimeRingBonus


; =============== S U B	R O U T	I N E =======================================


HUD_Lives:
		move.l	#$7BA00003,d0
		moveq	#0,d1
		move.b	(v_lives).w,d1
		lea	HUD_10(pc),a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_LivesNums(pc),a1

loc_1B610:
		move.l	d0,4(a6)
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1B618:
		sub.l	d3,d1
		bcs.s	loc_1B620
		addq.w	#1,d2
		bra.s	loc_1B618
; ---------------------------------------------------------------------------

loc_1B620:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1B62A
		move.w	#1,d4

loc_1B62A:
		tst.w	d4
		beq.s	loc_1B650

loc_1B62E:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1B644:
		addi.l	#$400000,d0
		dbf	d6,loc_1B610
		rts
; ---------------------------------------------------------------------------

loc_1B650:
		tst.w	d6
		beq.s	loc_1B62E
		moveq	#7,d5

loc_1B656:
		move.l	#0,(a6)
		dbf	d5,loc_1B656
		bra.s	loc_1B644
; End of function HUD_Lives

; ---------------------------------------------------------------------------
Art_HUD:	binclude	"art/uncompressed/HUD Numbers.bin"
		even
Art_LivesNums:	dc.b   0,  0,  0,  0,  0,$66,$66,$10,  6,$61,$16,$61,  6,$61,  6,$61,  6,$61,  6,$61,  6,$61,  6,$61,  0,$66,$66,$10,  0,$11,$11,  0 ; 0
		dc.b   0,  0,  0,  0,  0,  6,$61,  0,  0,$66,$61,  0,  0,$16,$61,  0,  0,  6,$61,  0,  0,  6,$61,  0,  0,  6,$61,  0,  0,  1,$11,  0 ; 32
		dc.b   0,  0,  0,  0,  0,$66,$66,$10,  0,$11,$16,$61,  0,  0,$66,$11,  0,  6,$61,$10,  0,$66,$11,$10,  6,$66,$66,$61,  1,$11,$11,$11 ; 64
		dc.b   0,  0,  0,  0,  0,$66,$66,$10,  0,$11,$16,$61,  0,  6,$66,$10,  0,  1,$16,$61,  6,$61,  6,$61,  0,$66,$66,$10,  0,$11,$11,  0 ; 96
		dc.b   0,  0,  0,  0,  0,  0,$66,$10,  0,  6,$66,$10,  0,$61,$66,$10,  6,$61,$66,$10,  6,$66,$66,$61,  1,$11,$66,$11,  0,  0,$11,$10 ; 128
		dc.b   0,  0,  0,  0,  6,$66,$66,$61,  6,$61,$11,$11,  6,$66,$66,$10,  1,$11,$16,$61,  6,$61,  6,$61,  0,$66,$66,$10,  0,$11,$11,  0 ; 160
		dc.b   0,  0,  0,  0,  0,$66,$66,$10,  6,$61,$11,$10,  6,$66,$66,$10,  6,$61,$16,$61,  6,$61,  6,$61,  0,$66,$66,$10,  0,$11,$11,  0 ; 192
		dc.b   0,  0,  0,  0,  6,$66,$66,$61,  1,$11,$16,$61,  0,  0,$66,$10,  0,  6,$61,  0,  0,$66,$10,  0,  0,$66,$10,  0,  0,$11,$10,  0 ; 224
		dc.b   0,  0,  0,  0,  0,$66,$66,$10,  6,$61,$16,$61,  0,$66,$66,$10,  6,$61,$16,$61,  6,$61,  6,$61,  0,$66,$66,$10,  0,$11,$11,  0 ; 256
		dc.b   0,  0,  0,  0,  0,$66,$66,$10,  6,$61,$16,$61,  6,$61,  6,$61,  0,$66,$66,$61,  0,$11,$16,$61,  0,$66,$66,$10,  0,$11,$11,  0 ; 288
; ---------------------------------------------------------------------------
		nop

j_Adjust2PArtPointer_8:
		jmp	(Adjust2PArtPointer).l

		align 4

; ===========================================================================
; ---------------------------------------------------------------------------
; When debug mode is currently in use, you can actually find the original
; source code for it within the leftovers at $50A9C, which includes the
; code that has been commented out below
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0
		move.b	(Debug_placement_mode).w,d0
		move.w	DebugIndex(pc,d0.w),d1
		jmp	DebugIndex(pc,d1.w)
; ===========================================================================
DebugIndex:	dc.w Debug_Init-DebugIndex
		dc.w Debug_Main-DebugIndex
; ===========================================================================
Debug_Init:
		addq.b	#2,(Debug_placement_mode).w
		move.w	(Camera_Min_Y_pos).w,(v_limittopdb).w
		move.w	(Camera_Max_Y_pos_target).w,(v_limitbtmdb).w
		move.w	#0,(Camera_Min_Y_pos).w
		move.w	#$720,(Camera_Max_Y_pos_target).w
		andi.w	#$7FF,(v_objspace+obY).w
		andi.w	#$7FF,(Camera_Y_pos).w
		andi.w	#$3FF,(Camera_BG_Y_pos).w
		move.b	#0,obFrame(a0)
		move.b	#0,obAnim(a0)

; Debug_CheckSS:
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w ; is this the Special Stage?
		bne.s	loc_1BB04			; if not, branch
		;move.b	#7-1,(Current_Zone).w		; sets the debug object list and resets Special Stage rotation
		;move.w	#0,($FFFFF782).w
		;move.w	#0,($FFFFF780).w
		moveq	#6,d0				; force zone 6's debug object list (was the ending in S1)
		bra.s	loc_1BB0A
; ===========================================================================

loc_1BB04:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0

loc_1BB0A:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		cmp.b	(Debug_object).w,d6
		bhi.s	loc_1BB24
		move.b	#0,(Debug_object).w

loc_1BB24:
		bsr.w	LoadDebugObjectSprite
		move.b	#$C,(Debug_Accel_Timer).w
		move.b	#1,(Debug_Speed).w

Debug_Main:
		moveq	#6,d0				; force zone 6's debug object list (was the ending in S1)
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w ; is this the Special Stage?
		beq.s	loc_1BB44			; if yes, branch

		moveq	#0,d0
		move.b	(Current_Zone).w,d0

loc_1BB44:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		bsr.w	Debug_Control
		;bsr.w	dirsprset			; I have no idea what this branches to, it can't be found within the symbol tables
		jmp	(DisplaySprite).l

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Debug_Control:
		moveq	#0,d4
		move.w	#1,d1
		move.b	(v_jpadpress1).w,d4
		andi.w	#$F,d4
		bne.s	Debug_Move
		move.b	(v_jpadhold1).w,d0
		andi.w	#$F,d0
		bne.s	Debug_ContinueMoving
		move.b	#$C,(Debug_Accel_Timer).w
		move.b	#$F,(Debug_Speed).w
		bra.w	Debug_ControlObjects
; ===========================================================================
; loc_1BB86:
Debug_ContinueMoving:
		subq.b	#1,(Debug_Accel_Timer).w
		bne.s	Debug_TimerNotOver
		move.b	#1,(Debug_Accel_Timer).w
		addq.b	#1,(Debug_Speed).w
		;cmpi.b	#-1,(Debug_Speed).w		; this effectively resets the Debug movement speed when it reaches 255
		bne.s	Debug_Move
		move.b	#-1,(Debug_Speed).w
; loc_1BB9E:
Debug_Move:
		move.b	(v_jpadhold1).w,d4
; loc_1BBA2:
Debug_TimerNotOver:
		moveq	#0,d1
		move.b	(Debug_Speed).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1
		move.l	obY(a0),d2
		move.l	obX(a0),d3

		; move up
		btst	#0,d4
		beq.s	loc_1BBC2
		sub.l	d1,d2
		bcc.s	loc_1BBC2
		moveq	#0,d2

loc_1BBC2:
		; move down
		btst	#1,d4
		beq.s	loc_1BBD8
		add.l	d1,d2
		cmpi.l	#$7FF0000,d2
		bcs.s	loc_1BBD8
		move.l	#$7FF0000,d2

loc_1BBD8:
		; move left
		btst	#2,d4
		beq.s	loc_1BBE4
		sub.l	d1,d3
		bcc.s	loc_1BBE4
		moveq	#0,d3

loc_1BBE4:
		; move right
		btst	#3,d4
		beq.s	loc_1BBEC
		add.l	d1,d3

loc_1BBEC:
		move.l	d2,obY(a0)
		move.l	d3,obX(a0)
; loc_1BBF4:
Debug_ControlObjects:
		btst	#6,(v_jpadhold1).w
		beq.s	Debug_SpawnObject
		btst	#5,(v_jpadpress1).w
		beq.s	Debug_CycleObjects
		; cycle backwards through the object list
		subq.b	#1,(Debug_object).w
		bcc.s	loc_1BC28
		add.b	d6,(Debug_object).w
		bra.s	loc_1BC28
; ===========================================================================
; loc_1BC10:
Debug_CycleObjects:
		btst	#6,(v_jpadpress1).w
		beq.s	Debug_SpawnObject
		addq.b	#1,(Debug_object).w
		cmp.b	(Debug_object).w,d6
		bhi.s	loc_1BC28
		move.b	#0,(Debug_object).w

loc_1BC28:
		bra.w	LoadDebugObjectSprite
; ===========================================================================
; loc_1BC2C:
Debug_SpawnObject:
		btst	#5,(v_jpadpress1).w
		beq.s	Debug_ExitDebugMode
		; spawn object
		jsr	(FindFreeObj).l
		bne.s	Debug_ExitDebugMode
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		_move.b	obMap(a0),obID(a1)		; load obj
		move.b	obRender(a0),obRender(a1)
		move.b	obRender(a0),obStatus(a1)
		andi.b	#$7F,obStatus(a1)
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0.w),obSubtype(a1)
		rts
; ===========================================================================
; loc_1BC70:
Debug_ExitDebugMode:
		btst	#4,(v_jpadpress1).w
		beq.s	locret_1BCCA
		; exit Debug Mode
		moveq	#0,d0
		move.w	d0,(Debug_placement_mode).w
		move.l	#Map_Sonic,(v_objspace+obMap).w
		move.w	#$780,(v_objspace+obGfx).w
		tst.w	(Two_player_mode).w
		beq.s	loc_1BC98
		move.w	#$3C0,(v_objspace+obGfx).w

loc_1BC98:
		move.b	d0,(v_objspace+obAnim).w
		move.w	d0,$A(a0)
		move.w	d0,$E(a0)
		move.w	(v_limittopdb).w,(Camera_Min_Y_pos).w
		move.w	(v_limitbtmdb).w,(Camera_Max_Y_pos_target).w
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w ; is this the Special Stage?
		bne.s	locret_1BCCA			; if not, branch

		;clr.w	($FFFFF780).w			; again, this resets the Special Stage rotation
		;move.w	#$40,($FFFFF782).w		; and Sonic's art for whatever reason
		;move.l	#Map_Sonic,($FFFFD004).w
		;move.w	#$780,($FFFFD002).w

		move.b	#2,(v_objspace+obAnim).w
		bset	#2,(v_objspace+obStatus).w
		bset	#1,(v_objspace+obStatus).w

locret_1BCCA:
		rts
; End of function Debug_Control


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1BCCC: Debug_ShowItem:
LoadDebugObjectSprite:
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		lsl.w	#3,d0
		move.l	(a2,d0.w),obMap(a0)
		move.w	6(a2,d0.w),obGfx(a0)
		move.b	5(a2,d0.w),obFrame(a0)
		;move.b	4(a2,d0.w),obSubtype(a0)	; this does... something with the object's subtype
		bsr.w	j_Adjust2PArtPointer_1
		rts
; End of function Debug_ShowItem

; ===========================================================================
DebugList:	dc.w Debug_GHZ-DebugList
		dc.w Debug_CPZ-DebugList
		dc.w Debug_CPZ-DebugList
		dc.w Debug_EHZ-DebugList
		dc.w Debug_HPZ-DebugList
		dc.w Debug_HTZ-DebugList
		dc.w Debug_HPZ-DebugList
Debug_GHZ:	dc.w $E
		dc.l Map_Obj25+$25000000
		dc.b   0,  0,$26,$BC			; subtype, frame, VRAM setting (2 bytes)
		dc.l Map_Obj26+$26000000
		dc.b   0,  0,  6,$80			; 0
		dc.l Map_obj1F+$1F000000
		dc.b   0,  0,  4,  0			; 0
		dc.l Map_obj22+$22000000
		dc.b   0,  0,  4,$44			; 0
		dc.l Map_Obj2B+$2B000000
		dc.b   0,  0,  4,$70			; 0
		dc.l Map_Obj36+$36000000
		dc.b   0,  0,  4,$A0			; 0
		dc.l Map_Obj18+$18000000
		dc.b   0,  0,$40,  0			; 0
		dc.l Map_Obj3B+$3B000000
		dc.b   0,  0,$66,$C0			; 0
		dc.l Map_obj40+$40000000
		dc.b   0,  0,  4,$E0			; 0
		dc.l Map_obj41_GHZ+$41000000
		dc.b   0,  0,  4,$A8			; 0
		dc.l Map_obj42+$42000000
		dc.b   0,  0,$24,$9B			; 0
		dc.l Map_obj44+$44000000
		dc.b   0,  0,$43,$4C			; 0
		dc.l Map_Obj79+$79000000
		dc.b   1,  0,$26,$BC			; 0
		dc.l Map_Obj03+$03000000
		dc.b   0,  0,$26,$BC			; 0
Debug_CPZ:	dc.w $10
		dc.l Map_Obj25+$25000000
		dc.b   0,  0,$26,$BC			; 0
		dc.l Map_Obj26+$26000000
		dc.b   0,  0,  6,$80			; 0
		dc.l Map_obj41_GHZ+$41000000
		dc.b   0,  0,  4,$A8			; 0
		dc.l Map_Obj03+$03000000
		dc.b   0,  0,  7,$BC			; 0
		dc.l Map_Obj0B+$0B000000
		dc.b   0,  0,$E0,  0			; 0
		dc.l Map_Obj0C+$0C000000
		dc.b   0,  0,$E4,$18			; 0
		dc.l Map_Obj15_CPZ+$15000000
		dc.b   8,  0,$24,$18			; 0
		dc.l Map_Obj03+$03000000
		dc.b   9,  1,$26,$BC			; 0
		dc.l Map_Obj03+$03000000
		dc.b  $D,  5,$26,$BC			; 0
		dc.l Map_Obj19+$19000000
		dc.b   1,  0,$64,  0			; 0
		dc.l Map_Obj36+$36000000
		dc.b   0,  0,$24,$34			; 0
		dc.l Map_obj41+$41000000
		dc.b $81,  0,  4,$5C			; 0
		dc.l Map_obj41+$41000000
		dc.b $90,  3,  4,$70			; 0
		dc.l Map_obj41+$41000000
		dc.b $A0,  6,  4,$5C			; 0
		dc.l Map_obj41+$41000000
		dc.b $30,  7,  4,$3C			; 0
		dc.l Map_obj41+$41000000
		dc.b $40, $A,  4,$3C			; 0
Debug_EHZ:	dc.w $13
		dc.l Map_Obj25+$25000000
		dc.b   0,  0,$26,$BC			; 0
		dc.l Map_Obj26+$26000000
		dc.b   0,  0,  6,$80			; 0
		dc.l Map_Obj79+$79000000
		dc.b   1,  0,  4,$7C			; 0
		dc.l Map_Obj03+$03000000
		dc.b   0,  0,$26,$BC			; 0
		dc.l Map_Obj49+$49000000
		dc.b   0,  0,$23,$AE			; 0
		dc.l Map_Obj49+$49000000
		dc.b   2,  3,$23,$AE			; 0
		dc.l Map_Obj49+$49000000
		dc.b   4,  5,$23,$AE			; 0
		dc.l Map_obj18_EHZ+$18000000
		dc.b   1,  0,$40,  0			; 0
		dc.l Map_obj18_EHZ+$18000000
		dc.b  $A,  1,$40,  0			; 0
		dc.l Map_Obj36+$36000000
		dc.b   0,  0,$24,$34			; 0
		dc.l Map_obj14+$14000000
		dc.b   0,  0,  3,$CE			; 0
		dc.l Map_obj41+$41000000
		dc.b $81,  0,  4,$5C			; 0
		dc.l Map_obj41+$41000000
		dc.b $90,  3,  4,$70			; 0
		dc.l Map_obj41+$41000000
		dc.b $A0,  6,  4,$5C			; 0
		dc.l Map_obj41+$41000000
		dc.b $30,  7,  4,$3C			; 0
		dc.l Map_obj41+$41000000
		dc.b $40, $A,  4,$3C			; 0
		dc.l Map_obj4B+$4B000000
		dc.b   0,  0,  3,$E6			; 0
		dc.l Map_obj54+$54000000
		dc.b   0,  0,  4,  2			; 0
		dc.l Map_obj53+$53000000
		dc.b   0,  0,  4,$1C			; 0
		dc.l Map_obj4F+$4F000000
		dc.b   0,  0,  5,  0			; 0
		dc.l Map_Obj52+$52000000
		dc.b   0,  0,$25,$30			; 0
		dc.l Map_Obj50+$50000000
		dc.b   0,  0,$25,$70			; 0
		dc.l Map_Obj50+$51000000
		dc.b   0,  0,$25,$70			; 0
		dc.l Map_Obj4D+$4D000000
		dc.b   0,  0,$23,$C4			; 0
		dc.l Map_obj4B+$4B000000
		dc.b   0,  0,  3,$2C			; 0
		dc.l Map_Obj4E+$4E000000
		dc.b   0,  0,$23,  0			; 0
		dc.l Map_Obj4C+$4C000000
		dc.b   0,  0,$23,$50			; 0
		dc.l Map_Obj4A+$4A000000
		dc.b   0,  0,$23,$8A			; 0
Debug_HTZ:	dc.w $13
		dc.l Map_Obj25+$25000000
		dc.b   0,  0,$26,$BC			; 0
		dc.l Map_Obj26+$26000000
		dc.b   0,  0,  6,$80			; 0
		dc.l Map_Obj79+$79000000
		dc.b   1,  0,  4,$7C			; 0
		dc.l Map_Obj03+$03000000
		dc.b   0,  0,$26,$BC			; 0
		dc.l Map_obj18_EHZ+$18000000
		dc.b   1,  0,$40,  0			; 0
		dc.l Map_obj18_EHZ+$18000000
		dc.b  $A,  1,$40,  0			; 0
		dc.l Map_Obj36+$36000000
		dc.b   0,  0,$24,$34			; 0
		dc.l Map_obj14+$14000000
		dc.b   0,  0,  3,$CE			; 0
		dc.l Map_obj41+$41000000
		dc.b $81,  0,  4,$5C			; 0
		dc.l Map_obj41+$41000000
		dc.b $90,  3,  4,$70			; 0
		dc.l Map_obj41+$41000000
		dc.b $A0,  6,  4,$5C			; 0
		dc.l Map_obj41+$41000000
		dc.b $30,  7,  4,$3C			; 0
		dc.l Map_obj41+$41000000
		dc.b $40, $A,  4,$3C			; 0
		dc.l Map_Obj16+$16000000
		dc.b   0,  0,$43,$E6			; 0
		dc.l Map_Obj16+$1C000000
		dc.b   4,  1,$43,$E6			; 0
		dc.l Map_Obj16+$1C000000
		dc.b   5,  2,$43,$E6			; 0
		dc.l Map_obj4B+$4B000000
		dc.b   0,  0,  3,$E6			; 0
		dc.l Map_obj54+$54000000
		dc.b   0,  0,  4,  2			; 0
		dc.l Map_obj53+$53000000
		dc.b   0,  0,  4,$1C			; 0
Debug_HPZ:	dc.w $F
		dc.l Map_Obj25+$25000000
		dc.b   0,  0,$26,$BC			; 0
		dc.l Map_Obj26+$26000000
		dc.b   0,  0,  6,$80			; 0
		dc.l Map_Obj1C_01+$1C000000
		dc.b $21,  3,$E4,$85			; 0
		dc.l Map_Obj13+$13000000
		dc.b   4,  4,$E4,$15			; 0
		dc.l Map_Obj1A_HPZ+$1A000000
		dc.b   0,  0,$44,$75			; 0
		dc.l Map_Obj03+$03000000
		dc.b   0,  0,$26,$BC			; 0
		dc.l Map_obj4F+$4F000000
		dc.b   0,  0,  5,  0			; 0
		dc.l Map_Obj52+$52000000
		dc.b   0,  0,$25,$30			; 0
		dc.l Map_Obj50+$50000000
		dc.b   0,  0,$25,$70			; 0
		dc.l Map_Obj50+$51000000
		dc.b   0,  0,$25,$70			; 0
		dc.l Map_Obj4D+$4D000000
		dc.b   0,  0,$23,$C4			; 0
		dc.l Map_obj4B+$4B000000
		dc.b   0,  0,  3,$2C			; 0
		dc.l Map_Obj4E+$4E000000
		dc.b   0,  0,$23,  0			; 0
		dc.l Map_Obj4C+$4C000000
		dc.b   0,  0,$23,$50			; 0
		dc.l Map_Obj4A+$4A000000
		dc.b   0,  0,$23,$8A			; 0
; ---------------------------------------------------------------------------

j_Adjust2PArtPointer_1:
		jmp	(Adjust2PArtPointer).l
; ---------------------------------------------------------------------------
		align 4



; ---------------------------------------------------------------------------
; "MAIN LEVEL LOAD BLOCK" (after Nemesis)
;
; This struct array tells the engine where to find all the art associated with
; a particular zone. Each zone gets four longwords, in which it stores four
; pointers (in the lower 24 bits) and three jump table indeces (in the upper eight
; bits). The assembled data looks something like this:
;
; aaBBBBBB
; ccDDDDDD
; EEEEEE
; ffgghhii
;
; aa = index for primary pattern load request list
; BBBBBB = unused, pointer to level art
; cc = index for secondary pattern load request list
; DDDDDD = pointer to 16x16 block mappings
; EEEEEE = pointer to 128x128 block mappings
; ff = unused, always 0
; gg = unused, music track
; hh = unused, palette
; ii = palette
;
; Nemesis refers to this as the "main level load block". However, that name implies
; that this is code (obviously, it isn't), or at least that it points to the level's
; collision, object and ring placement arrays (it only points to palettes and 16x16
; mappings although the 128x128 mappings do affect the actual level layout and collision)
; ---------------------------------------------------------------------------

; macro for declaring a "main level load block" (MLLB)
levartptrs macro plc1,plc2,palette,art,map16x16,map128x128,music
	dc.l art+(plc1<<24)
	dc.l map16x16+(plc2<<24)
	dc.l map128x128
	dc.b 0,music,palette,palette
	endm

; MainLoadBlocks:
LevelArtPointers:
		levartptrs  4,  5,  4, Nem_GHZ, Map16_GHZ, Map128_GHZ, bgm_GHZ ;   0 ; GHZ  ; GREEN HILL ZONE
		levartptrs  6,  7,  5, Nem_CPZ, Map16_CPZ, Map128_CPZ, bgm_LZ ;   1 ; LZ   ; LABYRINTH ZONE
		levartptrs  8,  9,  6, Nem_CPZ, Map16_CPZ, Map128_CPZ, bgm_MZ ;   2 ; CPZ  ; CHEMICAL PLANT ZONE
		levartptrs $A, $B,  7, Nem_EHZ, Map16_EHZ, Map128_EHZ, bgm_SLZ ;   3 ; EHZ  ; EMERALD HILL ZONE
		levartptrs $C, $D,  8, Nem_HPZ, Map16_HPZ, Map128_HPZ, bgm_SYZ ;   4 ; HPZ  ; HIDDEN PALACE ZONE
		levartptrs $E, $F,  9, Nem_EHZ, Map16_EHZ, Map128_EHZ, bgm_SBZ ;   5 ; HTZ  ; HILL TOP ZONE
		levartptrs  0,  0,$13, Nem_GHZ, Map16_GHZ, Map128_GHZ, bgm_SBZ ;   6 ; LEV6 ; LEVEL 6 (UNUSED, SONIC 1 ENDING)

; ---------------------------------------------------------------------------
; PATTERN LOAD REQUEST LISTS
;
; Pattern load request lists are simple structures used to load
; Nemesis-compressed art for sprites.
;
; The decompressor predictably moves down the list, so request 0 is processed first, etc.
; This only matters if your addresses are bad and you overwrite art loaded in a previous request.
;

; NOTICE: The load queue buffer can only hold $10 (16) load requests. None of the routines
; that load PLRs into the queue do any bounds checking, so it's possible to create a buffer
; overflow and completely screw up the variables stored directly after the queue buffer.
; (in my experience this is a guaranteed crash or hang)
;
; Many levels queue more than 16 items overall, but they don't exceed the limit because
; their PLRs are split into multiple parts (like PLC_GHZ and PLC_GHZ2) and they fully
; process the first part before requesting the rest.
; ---------------------------------------------------------------------------

;---------------------------------------------------------------------------------------
; Table of pattern load request lists. Remember to use word-length data when adding lists
; otherwise you'll break the array.
;---------------------------------------------------------------------------------------
ArtLoadCues:	dc.w PLC_Main-ArtLoadCues,PLC_Main2-ArtLoadCues
		dc.w PLC_Explode-ArtLoadCues,PLC_GameOver-ArtLoadCues
		dc.w PLC_GHZ-ArtLoadCues,PLC_GHZ2-ArtLoadCues
		dc.w PLC_CPZ-ArtLoadCues,PLC_CPZ2-ArtLoadCues
		dc.w PLC_CPZ-ArtLoadCues,PLC_CPZ2-ArtLoadCues
		dc.w PLC_EHZ-ArtLoadCues,PLC_EHZ2-ArtLoadCues
		dc.w PLC_HPZ-ArtLoadCues,PLC_HPZ2-ArtLoadCues
		dc.w PLC_HTZ-ArtLoadCues,PLC_HTZ2-ArtLoadCues
		dc.w PLC_S1TitleCard-ArtLoadCues,PLC_Boss-ArtLoadCues
		dc.w PLC_Signpost-ArtLoadCues,PLC_S1SpecialStage-ArtLoadCues
		dc.w PLC_S1SpecialStage-ArtLoadCues,PLC_GHZAnimals-ArtLoadCues
		dc.w PLC_LZAnimals-ArtLoadCues,PLC_CPZAnimals-ArtLoadCues
		dc.w PLC_EHZAnimals-ArtLoadCues,PLC_HPZAnimals-ArtLoadCues
		dc.w PLC_HTZAnimals-ArtLoadCues,$1C318-ArtLoadCues
		dc.w $1C31A-ArtLoadCues,$1C31C-ArtLoadCues
		dc.w $1C31E-ArtLoadCues,$1C320-ArtLoadCues

; macro for a pattern load request
plreq macro toVRAMaddr,fromROMaddr
	dc.l	fromROMaddr				; art to load
	dc.w	(toVRAMaddr<<5)				; VRAM address to load it at (multiplied by $20)
	endm

; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Standard 1 - loaded for every level
; --------------------------------------------------------------------------------------
PLC_Main:	dc.w ((PLC_Main_End-PLC_Main)/6)-1
		plreq $47C, Nem_Lamppost
		plreq $6CA, Nem_HUD
		plreq $7D4, Nem_Lives
		plreq $6BC, Nem_Ring
		plreq $4AC, Nem_Points
PLC_Main_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Standard 2 - loaded for every level
; --------------------------------------------------------------------------------------
PLC_Main2:	dc.w ((PLC_Main2_End-PLC_Main2)/6)-1
		plreq $680, Nem_Monitors
		plreq $4BE, Nem_Shield
		plreq $4DE, Nem_Stars
PLC_Main2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Explosion - loaded for every level AFTER the title card
; --------------------------------------------------------------------------------------
PLC_Explode:	dc.w ((PLC_Explode_End-PLC_Explode)/6)-1
		plreq $5A0, Nem_Explosion
PLC_Explode_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Game/Time over
; --------------------------------------------------------------------------------------
PLC_GameOver:	dc.w ((PLC_GameOver_End-PLC_GameOver)/6)-1
		plreq $55E, Nem_GameOver
PLC_GameOver_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Green Hill Zone primary
; --------------------------------------------------------------------------------------
PLC_GHZ:	dc.w ((PLC_GHZ_End-PLC_GHZ)/6)-1
		plreq 0, Nem_GHZ
		plreq $470, Nem_GHZ_Piranha
		plreq $4A0, Nem_VSpikes
		plreq $4A8, Nem_HSpring
		plreq $4B8, Nem_VSpring
		plreq $4C6, Nem_GHZ_Bridge
		plreq $4D0, Nem_SwingPlatform
		plreq $4E0, Nem_Motobug
		plreq $6C0, Nem_GHZ_Rock
PLC_GHZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Green Hill Zone secondary
; --------------------------------------------------------------------------------------
PLC_GHZ2:	dc.w ((PLC_GHZ2_End-PLC_GHZ2)/6)-1
		plreq $470, Nem_GHZ_Piranha
PLC_GHZ2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Chemical Plant Zone primary
; --------------------------------------------------------------------------------------
PLC_CPZ:	dc.w ((PLC_CPZ_End-PLC_CPZ)/6)-1
		plreq 0, Nem_CPZ
		plreq $3D0, Nem_CPZ_Buildings
		plreq $400, Nem_CPZ_FloatingPlatform
PLC_CPZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Chemical Plant Zone secondary
; --------------------------------------------------------------------------------------
PLC_CPZ2:	dc.w ((PLC_CPZ2_End-PLC_CPZ2)/6)-1
		plreq $434, Nem_VSpikes
		plreq $43C, Nem_DSpring
		plreq $45C, Nem_VSpring2
		plreq $470, Nem_HSpring2
PLC_CPZ2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Emerald Hill Zone primary
; --------------------------------------------------------------------------------------
PLC_EHZ:	dc.w ((PLC_EHZ_End-PLC_EHZ)/6)-1
		plreq 0, Nem_EHZ
		plreq $39E, Nem_EHZ_Fireball
		plreq $3AE, Nem_EHZ_Waterfall
		plreq $3C6, Nem_EHZ_Bridge
		plreq $3CE, Nem_HTZ_Seesaw
		plreq $434, Nem_VSpikes
		plreq $43C, Nem_DSpring
		plreq $45C, Nem_VSpring2
		plreq $470, Nem_HSpring2
PLC_EHZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Emerald Hill Zone secondary
; --------------------------------------------------------------------------------------
PLC_EHZ2:	dc.w ((PLC_EHZ2_End-PLC_EHZ2)/6)-1
		plreq $560, Nem_Shield
		plreq $4AC, Nem_Points
		plreq $3E6, Nem_Buzzer
		plreq $402, Nem_Snail
		plreq $41C, Nem_Masher
PLC_EHZ2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hidden Palace Zone primary
; --------------------------------------------------------------------------------------
PLC_HPZ:	dc.w ((PLC_HPZ_End-PLC_HPZ)/6)-1
		plreq 0, Nem_HPZ
		plreq $300, Nem_HPZ_Bridge
		plreq $315, Nem_HPZ_Waterfall
		plreq $34A, Nem_HPZ_Platform
		plreq $35A, Nem_HPZ_PulsingBall
		plreq $37C, Nem_HPZ_Various
		plreq $392, Nem_HPZ_Emerald
		plreq $400, Nem_WaterSurface
PLC_HPZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hidden Palace Zone secondary
; --------------------------------------------------------------------------------------
PLC_HPZ2:	dc.w ((PLC_HPZ2_End-PLC_HPZ2)/6)-1
		plreq $500, Nem_Redz
		plreq $530, Nem_Bat
PLC_HPZ2_End:
		; unused PLR entries
		plreq $300, Nem_Crocobot
		plreq $32C, Nem_Buzzer
		plreq $350, Nem_Bat
		plreq $3C4, Nem_Triceratops
		plreq $500, Nem_Redz
		plreq $530, Nem_HPZ_Piranha
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hill Top Zone primary
; --------------------------------------------------------------------------------------
PLC_HTZ:	dc.w ((PLC_HTZ_End-PLC_HTZ)/6)-1
		plreq 0, Nem_EHZ
		plreq $1FC, Nem_HTZ
		plreq $500, Nem_HTZ_AniPlaceholders
		plreq $39E, Nem_EHZ_Fireball
		plreq $3AE, Nem_HTZ_Fireball
		plreq $3BE, Nem_HTZ_AutomaticDoor
		plreq $3C6, Nem_EHZ_Bridge
		plreq $3CE, Nem_HTZ_Seesaw
		plreq $434, Nem_VSpikes
		plreq $43C, Nem_DSpring
PLC_HTZ_End:
		; unused PLR entries
		plreq $45C, Nem_VSpring2
		plreq $470, Nem_HSpring2
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hill Top Zone secondary
; --------------------------------------------------------------------------------------
PLC_HTZ2:	dc.w ((PLC_HTZ2_End-PLC_HTZ2)/6)-1
		plreq $3E6, Nem_HTZ_Lift
PLC_HTZ2_End:
		; unused PLR entries
		plreq $3E6, Nem_Buzzer
		plreq $402, Nem_Snail
		plreq $41C, Nem_Masher
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Sonic 1 title card
; --------------------------------------------------------------------------------------
PLC_S1TitleCard:dc.w ((PLC_S1TitleCard_End-PLC_S1TitleCard)/6)-1
		plreq $580, Nem_S1TitleCard
PLC_S1TitleCard_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; End of zone bosses
; --------------------------------------------------------------------------------------
PLC_Boss:	dc.w ((PLC_Boss_End-PLC_Boss)/6)-1
		plreq $460, Nem_BossShip
		plreq $4C0, Nem_EHZ_Boss
		plreq $540, Nem_EHZ_Boss_Blades
PLC_Boss_End:
		; unused PLR entries
		plreq $400, Nem_BossShip
		plreq $460, Nem_CPZ_ProtoBoss
		plreq $4D0, Nem_BossShipBoost
		plreq $4D8, Nem_Smoke
		plreq $4E8, Nem_EHZ_Boss
		plreq $568, Nem_EHZ_Boss_Blades
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; End of level signpost
; --------------------------------------------------------------------------------------
PLC_Signpost:	dc.w ((PLC_Signpost_End-PLC_Signpost)/6)-1
		plreq $680, Nem_Signpost
		plreq $4B6, Nem_S1BonusPoints
		plreq $462, Nem_BigFlash
PLC_Signpost_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Sonic 1 Special Stage, although since it's blank, using it will crash the game
; unless you remove the +$10
; --------------------------------------------------------------------------------------
; PLC_Invalid:
PLC_S1SpecialStage:	dc.w ((PLC_S1SpecialStage_End-PLC_S1SpecialStage)/6)+$10
PLC_S1SpecialStage_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Green Hill Zone animals
; --------------------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w ((PLC_GHZAnimals_End-PLC_GHZAnimals)/6)-1
		plreq $580, Nem_Bunny
		plreq $592, Nem_Flicky
PLC_GHZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Labyrinth Zone animals
; --------------------------------------------------------------------------------------
PLC_LZAnimals:	dc.w ((PLC_LZAnimals_End-PLC_LZAnimals)/6)-1
		plreq $580, Nem_Penguin
		plreq $592, Nem_Seal
PLC_LZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Chemical Plant Zone animals
; --------------------------------------------------------------------------------------
PLC_CPZAnimals:	dc.w ((PLC_CPZAnimals_End-PLC_CPZAnimals)/6)-1
		plreq $580, Nem_Squirrel
		plreq $592, Nem_Seal
PLC_CPZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Emerald Hill Zone animals
; --------------------------------------------------------------------------------------
PLC_EHZAnimals:	dc.w ((PLC_EHZAnimals_End-PLC_EHZAnimals)/6)-1
		plreq $580, Nem_Pig
		plreq $592, Nem_Flicky
PLC_EHZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hidden Palace Zone animals
; --------------------------------------------------------------------------------------
PLC_HPZAnimals:	dc.w ((PLC_HPZAnimals_End-PLC_HPZAnimals)/6)-1
		plreq $580, Nem_Pig
		plreq $592, Nem_Chicken
PLC_HPZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hill Top Zone animals
; --------------------------------------------------------------------------------------
PLC_HTZAnimals:	dc.w ((PLC_HTZAnimals_End-PLC_HTZAnimals)/6)-1
		plreq $580, Nem_Bunny
		plreq $592, Nem_Chicken
PLC_HTZAnimals_End:

; --------------------------------------------------------------------------------------
; Leftover art from an unknown game, overwrites the other Sonic 1 PLC entries
; --------------------------------------------------------------------------------------
LeftoverArt_Unknown:
		binclude	"art/uncompressed/leftovers/1C318.bin"
		even
AngleMap_GHZ:	binclude	"collision/S1/Angle Map.bin"
		even
AngleMap:	binclude	"collision/Curve and resistance mapping.bin"
		even
ColArray1_GHZ:	binclude	"collision/S1/Collision Array (Normal).bin"
		even
		binclude	"collision/S1/Collision Array (Rotated).bin"
		even
ColArray1:	binclude	"collision/Collision array 1.bin"
		even
ColArray2:	binclude	"collision/Collision array 2.bin"
		even
ColP_GHZ:	binclude	"collision/S1/GHZ1.bin"
		even
ColS_GHZ:	binclude	"collision/S1/GHZ2.bin"
		even
ColP_EHZ:	binclude	"collision/EHZ primary 16x16 collision index.bin"
		even
ColS_EHZ:	binclude	"collision/EHZ secondary 16x16 collision index.bin"
		even
ColP_CPZ:	binclude	"collision/CPZ primary 16x16 collision index.bin"
		even
ColS_CPZ:	binclude	"collision/CPZ secondary 16x16 collision index.bin"
		even
ColP_HPZ:	binclude	"collision/HPZ primary 16x16 collision index.bin"
		even
ColS_HPZ:	binclude	"collision/HPZ secondary 16x16 collision index.bin"
		even
S1SS_1:		binclude	"sslayout/1.eni"
		even
S1SS_2:		binclude	"sslayout/2.eni"
		even
S1SS_3:		binclude	"sslayout/3.eni"
		even
S1SS_4:		binclude	"sslayout/4.eni"
		even
S1SS_5:		binclude	"sslayout/5 (JP1).eni"
		even
S1SS_6:		binclude	"sslayout/6 (JP1).eni"
		even
Art_EHZFlower1:	binclude	"art/uncompressed/EHZ and HTZ flowers - 1.bin"
		even
Art_EHZFlower2:	binclude	"art/uncompressed/EHZ and HTZ flowers - 2.bin"
		even
Art_EHZFlower3:	binclude	"art/uncompressed/EHZ and HTZ flowers - 3.bin"
		even
Art_EHZFlower4:	binclude	"art/uncompressed/EHZ and HTZ flowers - 4.bin"
		even
Art_EHZFlower5:	binclude	"art/uncompressed/Pulsing ball against checkered background (EHZ).bin"
		even
Art_HPZUnusedBg:binclude	"art/uncompressed/HPZ unused background.bin"
		even
Art_HPZGlowingBall:
		binclude	"art/uncompressed/Pulsing orb (HPZ).bin"
		even
Art_UnkZone_1:	binclude	"art/uncompressed/Unknown Zone - 1.bin"
		even
Art_UnkZone_2:	binclude	"art/uncompressed/Unknown Zone - 2.bin"
		even
Art_UnkZone_3:	binclude	"art/uncompressed/Unknown Zone - 3.bin"
		even
Art_UnkZone_4:	binclude	"art/uncompressed/Unknown Zone - 4.bin"
		even
Art_UnkZone_5:	binclude	"art/uncompressed/Unknown Zone - 5.bin"
		even
Art_UnkZone_6:	binclude	"art/uncompressed/Unknown Zone - 6.bin"
		even
Art_UnkZone_7:	binclude	"art/uncompressed/Unknown Zone - 7.bin"
		even
Art_UnkZone_8:	binclude	"art/uncompressed/Unknown Zone - 8.bin"
		even

; ---------------------------------------------------------------------------
; Level layouts, three entries per act (although the third one is unused)
; ---------------------------------------------------------------------------
Level_Index:	dc.w Level_GHZ1-Level_Index,Level_GHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_GHZ2-Level_Index,Level_GHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_GHZ3-Level_Index,Level_GHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_EHZ1-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_EHZ2-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_EHZ1-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_EHZ2-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_HTZ1-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HTZ2-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HTZ1-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HTZ2-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

Level_GHZ1:	binclude	"level/layout/S1/ghz1.bin"
		even
Level_GHZ2:	binclude	"level/layout/S1/ghz2.bin"
		even
Level_GHZ3:	binclude	"level/layout/S1/ghz3.bin"
		even
Level_GHZBg:	binclude	"level/layout/S1/ghzbg.bin"
		even
Level_EHZ1:	binclude	"level/layout/EHZ_1.bin"
		even
Level_EHZ2:	binclude	"level/layout/EHZ_2.bin"
		even
Level_EHZBg:	binclude	"level/layout/EHZ_BG.bin"
		even
Level_HTZ1:	binclude	"level/layout/HTZ_1.bin"
		even
Level_HTZ2:	binclude	"level/layout/HTZ_2.bin"
		even
Level_HTZBg:	binclude	"level/layout/HTZ_BG.bin"
		even
Level_CPZ1:	binclude	"level/layout/CPZ_1.bin"
		even
Level_HPZ1:	binclude	"level/layout/HPZ_1.bin"
		even
Level_CPZBg:	binclude	"level/layout/CPZ_BG.bin"
		even
Level_HPZBg:	binclude	"level/layout/HPZ_BG.bin"
		even
Level_Null:	dc.l	0

Art_BigRing:	binclude	"art/uncompressed/Giant Ring.bin"
		even
;
; leftover level layouts from a	previous build
;
Leftover_LevelLayouts:
		binclude	"misc/leftovers/2C292.bin"
		even
;----------------------------------------------------
; A duplicate copy of the big ring art
;----------------------------------------------------
Leftover_Art_BigRing:
		binclude	"art/uncompressed/Giant Ring.bin"
		even
;----------------------------------------------------
; some level mappings	(16x16 or 256x256?)
;----------------------------------------------------
Leftover_LevelMappings:
		binclude	"misc/leftovers/2E292.bin"
		even
;----------------------------------------------------
; leftover art - full 128 character ASCII table
;----------------------------------------------------
Leftover_Art_Alphabet:
		binclude	"art/uncompressed/leftovers/128 char ASCII.bin"
		even
; --------------------------------------------------------------------------------------
; Leftover level mappings and palettes from a previous build
; --------------------------------------------------------------------------------------
Leftover_31000:
		binclude	"misc/leftovers/31000.bin"
		even
; --------------------------------------------------------------------------------------
; Object layouts
; --------------------------------------------------------------------------------------
ObjPos_Index:	dc.w ObjPos_GHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_LZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_CPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CPZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CPZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_EHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_EHZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_EHZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_EHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_HPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HPZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HPZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_HTZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HTZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HTZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HTZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index

		; platform objects in LZ/SBZ (unused)
		dc.w ObjPos_S1LZ1pf1-ObjPos_Index,ObjPos_S1LZ1pf2-ObjPos_Index
		dc.w ObjPos_S1LZ2pf1-ObjPos_Index,ObjPos_S1LZ2pf2-ObjPos_Index
		dc.w ObjPos_S1LZ3pf1-ObjPos_Index,ObjPos_S1LZ3pf2-ObjPos_Index
		dc.w ObjPos_S1LZ1pf1-ObjPos_Index,ObjPos_S1LZ1pf2-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf1-ObjPos_Index,ObjPos_S1SBZ1pf2-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf3-ObjPos_Index,ObjPos_S1SBZ1pf4-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf5-ObjPos_Index,ObjPos_S1SBZ1pf6-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf1-ObjPos_Index,ObjPos_S1SBZ1pf2-ObjPos_Index

		dc.w $FFFF,    0,    0
ObjPos_GHZ1:	binclude	"level/objects/GHZ_1.bin"
		dc.w $FFFF,    0,    0
ObjPos_GHZ2:	binclude	"level/objects/GHZ_2.bin"
		dc.w $FFFF,    0,    0
ObjPos_GHZ3:	binclude	"level/objects/GHZ_3.bin"
		dc.w $FFFF,    0,    0
ObjPos_LZ1:	dc.w $FFFF,    0,    0
ObjPos_LZ2:	dc.w $FFFF,    0,    0
ObjPos_LZ3:	dc.w $FFFF,    0,    0
ObjPos_S1LZ1pf1:dc.w	 7,$1078, $21A			; 0
		dc.w	 0,$10BE, $291			; 3
		dc.w	 2,$10BE, $307			; 6
		dc.w	 2,$10BE, $37E			; 9
		dc.w	 2,$105C, $390			; 12
		dc.w	 4,$1022, $352			; 15
		dc.w	 5,$1022, $2DB			; 18
		dc.w	 5,$1022, $265			; 21
		dc.w	 5				; 24
ObjPos_S1LZ1pf2:dc.w	 7,$127E, $280			; 0
		dc.w   $10,$12CE, $305			; 3
		dc.w   $12,$12CE, $38A			; 6
		dc.w   $12,$12CE, $40F			; 9
		dc.w   $12,$12A7, $46E			; 12
		dc.w   $13,$1232, $40F			; 15
		dc.w   $14,$1232, $38A			; 18
		dc.w   $14,$1232, $305			; 21
		dc.w   $14				; 24
ObjPos_S1LZ2pf1:dc.w	 7, $D22, $483			; 0
		dc.w   $21, $D9C, $482			; 3
		dc.w   $20, $DAE, $4EA			; 6
		dc.w   $23, $DAE, $564			; 9
		dc.w   $23, $DAE, $5DD			; 12
		dc.w   $23, $D34, $5DE			; 15
		dc.w   $22, $D22, $576			; 18
		dc.w   $21, $D22, $4FC			; 21
		dc.w   $21				; 24
ObjPos_S1LZ2pf2:dc.w	 7, $D62, $3A2			; 0
		dc.w   $30, $DD4, $3A2			; 3
		dc.w   $31, $DEE, $3FA			; 6
		dc.w   $32, $DEE, $46C			; 9
		dc.w   $32, $DEE, $4DD			; 12
		dc.w   $32, $D7C, $4DE			; 15
		dc.w   $33, $D62, $486			; 18
		dc.w   $30, $D62, $414			; 21
		dc.w   $30				; 24
ObjPos_S1LZ3pf1:dc.w	$B, $CAD, $242			; 0
		dc.w   $41, $D2D, $242			; 3
		dc.w   $41, $DAC, $242			; 6
		dc.w   $41, $DDE, $28F			; 9
		dc.w   $42, $DDE, $30E			; 12
		dc.w   $42, $DDE, $38D			; 15
		dc.w   $42, $DB0, $3DE			; 18
		dc.w   $43, $D31, $3DE			; 21
		dc.w   $43, $CB2, $3DE			; 24
		dc.w   $43, $C52, $3BF			; 27
		dc.w   $44, $C52, $340			; 30
		dc.w   $44, $C52, $2C1			; 33
		dc.w   $44				; 36
ObjPos_S1LZ3pf2:dc.w	 8,$1252, $20A			; 0
		dc.w   $50,$12D2, $20A			; 3
		dc.w   $51,$1352, $20A			; 6
		dc.w   $51,$13D2, $20A			; 9
		dc.w   $51,$13DE, $27E			; 12
		dc.w   $52,$139E, $2BE			; 15
		dc.w   $53,$131E, $2BE			; 18
		dc.w   $53,$129E, $2BE			; 21
		dc.w   $53,$1252, $28A			; 24
		dc.w   $50,$FFFF,    0			; 27
		dc.w	 0				; 30
ObjPos_CPZ1:	binclude	"level/objects/CPZ_1.bin"
		dc.w $FFFF,    0,    0
ObjPos_CPZ2:	dc.w $FFFF,    0,    0
ObjPos_CPZ3:	dc.w $FFFF,    0,    0
ObjPos_EHZ1:	binclude	"level/objects/EHZ_1.bin"
		dc.w $FFFF,    0,    0
ObjPos_EHZ2:	binclude	"level/objects/EHZ_2.bin"
		dc.w $FFFF,    0,    0
ObjPos_EHZ3:	dc.w $FFFF,    0,    0
ObjPos_HPZ1:	binclude	"level/objects/HPZ_1.bin"
		dc.w $FFFF,    0,    0
ObjPos_HPZ2:	dc.w $FFFF,    0,    0
ObjPos_HPZ3:	dc.w $FFFF,    0,    0
ObjPos_HTZ1:	binclude	"level/objects/HTZ_1.bin"
		dc.w $FFFF,    0,    0
ObjPos_HTZ2:	dc.w $FFFF,    0,    0
ObjPos_HTZ3:	binclude	"level/objects/HTZ_3.bin"
		dc.w $FFFF,    0,    0
ObjPos_S1SBZ1pf1:dc.w 7
		dc.w  $E14, $370,    0			; 0
		dc.w  $E5A, $34D,    1			; 3
		dc.w  $EA0, $32A,    1			; 6
		dc.w  $EE7, $307,    1			; 9
		dc.w  $EEF, $340,    2			; 12
		dc.w  $EA9, $363,    3			; 15
		dc.w  $E63, $386,    3			; 18
		dc.w  $E1C, $3A9,    3			; 21
ObjPos_S1SBZ1pf2:dc.w 7
		dc.w  $F14, $2E0,  $10			; 0
		dc.w  $F5A, $2BD,  $11			; 3
		dc.w  $FA0, $29A,  $11			; 6
		dc.w  $FE7, $277,  $11			; 9
		dc.w  $FEF, $2B0,  $12			; 12
		dc.w  $FA9, $2D3,  $13			; 15
		dc.w  $F63, $2F6,  $13			; 18
		dc.w  $F1C, $319,  $13			; 21
ObjPos_S1SBZ1pf3:dc.w 7
		dc.w $1014, $270,  $20			; 0
		dc.w $105A, $24D,  $21			; 3
		dc.w $10A0, $22A,  $21			; 6
		dc.w $10E7, $207,  $21			; 9
		dc.w $10EF, $240,  $22			; 12
		dc.w $10A9, $263,  $23			; 15
		dc.w $1063, $286,  $23			; 18
		dc.w $101C, $2A9,  $23			; 21
ObjPos_S1SBZ1pf4:dc.w 7
		dc.w  $F14, $570,  $30			; 0
		dc.w  $F5A, $54D,  $31			; 3
		dc.w  $FA0, $52A,  $31			; 6
		dc.w  $FE7, $507,  $31			; 9
		dc.w  $FEF, $540,  $32			; 12
		dc.w  $FA9, $563,  $33			; 15
		dc.w  $F63, $586,  $33			; 18
		dc.w  $F1C, $5A9,  $33			; 21
ObjPos_S1SBZ1pf5:dc.w 7
		dc.w $1B14, $670,  $40			; 0
		dc.w $1B5A, $64D,  $41			; 3
		dc.w $1BA0, $62A,  $41			; 6
		dc.w $1BE7, $607,  $41			; 9
		dc.w $1BEF, $640,  $42			; 12
		dc.w $1BA9, $663,  $43			; 15
		dc.w $1B63, $686,  $43			; 18
		dc.w $1B1C, $6A9,  $43			; 21
ObjPos_S1SBZ1pf6:dc.w	  7,$1C14, $5E0			; 0
		dc.w   $50,$1C5A, $5BD			; 3
		dc.w   $51,$1CA0, $59A			; 6
		dc.w   $51,$1CE7, $577			; 9
		dc.w   $51,$1CEF, $5B0			; 12
		dc.w   $52,$1CA9, $5D3			; 15
		dc.w   $53,$1C63, $5F6			; 18
		dc.w   $53,$1C1C, $619			; 21
		dc.w   $53,$FFFF,    0			; 24
		dc.w	 0				; 27
ObjPos_S1Ending:dc.w   $10, $170,$280C			; 0
		dc.w   $14, $1B2,$2812			; 3
		dc.w   $28, $1B0,$280C			; 6
		dc.w   $30, $1B2,$2812			; 9
		dc.w   $40, $170,$280F			; 12
		dc.w   $5B, $1B1,$2811			; 15
		dc.w   $64, $1B1,$2811			; 18
		dc.w   $68, $1B1,$280C			; 21
		dc.w   $D8, $1B0,$2813			; 24
		dc.w   $E4, $1B1,$280C			; 27
		dc.w   $E8, $1B0,$280F			; 30
		dc.w   $F4, $1B0,$2810			; 33
		dc.w   $F8, $1AF,$2814			; 36
		dc.w  $108, $1B0,$280E			; 39
		dc.w  $108, $1B4,$2813			; 42
		dc.w  $110, $173,$280C			; 45
		dc.w  $114, $1B0,$2810			; 48
		dc.w  $128, $174,$280E			; 51
		dc.w  $128, $1B0,$2814			; 54
		dc.w  $128, $1B2,$2813			; 57
		dc.w  $130, $1B8,$280C			; 60
		dc.w  $210, $1B0,$280A			; 63
		dc.w  $230, $1B2,$2813			; 66
		dc.w  $260, $1B0,$280D			; 69
		dc.w  $290, $1B6,$2813			; 72
		dc.w  $2B0, $150,$280A			; 75
		dc.w  $2B0, $180,$280A			; 78
		dc.w  $2B0, $1B0,$280A			; 81
		dc.w  $2F0, $1B2,$2813			; 84
		dc.w  $300, $1B0,$280A			; 87
		dc.w  $384, $1B0,$280D			; 90
		dc.w  $434, $1B8,$280D			; 93
		dc.w  $478, $1A4,$2813			; 96
		dc.w  $4D8, $176,$2813			; 99
		dc.w  $4F8, $170,$280A			; 102
		dc.w  $530, $170,$2810			; 105
		dc.w  $560, $170,$2810			; 108
		dc.w  $590, $170,$2810			; 111
		dc.w  $5C0, $170,$2810			; 114
		dc.w  $5D8, $170,$2810			; 117
		dc.w  $624, $170,$280A			; 120
		dc.w  $6C4, $1A4,$280D			; 123
		dc.w  $734, $1B8,$280A			; 126
		dc.w  $7F8, $174,$280A			; 129
		dc.w  $878, $178,$280D			; 132
		dc.w  $9B8, $158,$280A			; 135
		dc.w  $A00, $1B4,$280D			; 138
		dc.w  $A48, $152,$2812			; 141
		dc.w  $A78, $152,$2812			; 144
		dc.w  $AA8, $152,$2812			; 147
		dc.w  $AD4, $154,$2814			; 150
		dc.w  $B34, $138,$280A			; 153
		dc.w  $BF8, $174,$280A			; 156
		dc.w  $CC4, $1AB,$280D			; 159
		dc.w  $CC8, $148,$280A			; 162
		dc.w  $D34, $1BA,$280D			; 165
		dc.w  $DF8, $174,$280A			; 168
		dc.w $FFFF,    0,    0
ObjPos_Null:	dc.w $FFFF,    0,    0
; ---------------------------------------------------------------------------
; Leftover symbol tables due to compiler weirdness; these are formatted
; with a Unix ($0A) line break instead of a DOS ($0D0A) line break and it's
; also using big-endian integers, which suggest Sonic 2 wasn't developed in
; at least a little-endian environment
; in addition, the locations that can be extracted don't even match up with
; the prototype.
;
; Read more about it here:
; https://clownacy.wordpress.com/2022/03/30/everything-that-i-know-about-sonic-the-hedgehogs-source-code/
; https://tcrf.net/Proto:Sonic_the_Hedgehog_2_(Genesis)/Nick_Arcade_Prototype/Symbol_Tables
; ---------------------------------------------------------------------------
Leftover_418A8:	binclude	"misc/leftovers/418A8.bin"
		even
; ---------------------------------------------------------------------------
; Ring layouts; one entry per act, four entries per zone
; ---------------------------------------------------------------------------
RingPos_Index:	dc.w RingPos_GHZ1-RingPos_Index
		dc.w RingPos_GHZ2-RingPos_Index
		dc.w RingPos_GHZ3-RingPos_Index
		dc.w RingPos_GHZ1-RingPos_Index

		dc.w RingPos_LZ1-RingPos_Index
		dc.w RingPos_LZ2-RingPos_Index
		dc.w RingPos_LZ3-RingPos_Index
		dc.w RingPos_LZ1-RingPos_Index

		dc.w RingPos_CPZ1-RingPos_Index
		dc.w RingPos_GHZ2-RingPos_Index
		dc.w RingPos_GHZ3-RingPos_Index
		dc.w RingPos_GHZ1-RingPos_Index

		dc.w RingPos_EHZ1-RingPos_Index
		dc.w RingPos_EHZ2-RingPos_Index
		dc.w RingPos_HTZ1-RingPos_Index
		dc.w RingPos_HTZ2-RingPos_Index

		dc.w RingPos_HPZ1-RingPos_Index
		dc.w RingPos_GHZ2-RingPos_Index
		dc.w RingPos_GHZ3-RingPos_Index
		dc.w RingPos_GHZ1-RingPos_Index

		dc.w RingPos_HTZ1-RingPos_Index
		dc.w RingPos_HTZ2-RingPos_Index
		dc.w RingPos_LZ3-RingPos_Index
		dc.w RingPos_LZ1-RingPos_Index

RingPos_GHZ1:	binclude	"level/rings/GHZ_1.bin"
		even
RingPos_GHZ2:	binclude	"level/rings/GHZ_2.bin"
		even
RingPos_GHZ3:	binclude	"level/rings/GHZ_3.bin"
		even
RingPos_LZ1:	binclude	"level/rings/LZ_1.bin"
		even
RingPos_LZ2:	binclude	"level/rings/LZ_2.bin"
		even
RingPos_LZ3:	binclude	"level/rings/LZ_3.bin"
		even
RingPos_HPZ1:	binclude	"level/rings/HPZ_1.bin"
		even
RingPos_EHZ1:	binclude	"level/rings/EHZ_1.bin"
		even
RingPos_EHZ2:	binclude	"level/rings/EHZ_2.bin"
		even
RingPos_HTZ1:	binclude	"level/rings/HTZ_1.bin"
		even
RingPos_HTZ2:	binclude	"level/rings/HTZ_2.bin"
		even
RingPos_CPZ1:	binclude	"level/rings/CPZ_1.bin"
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Yet another symbol table that doesn't match up with the prototype
; There's also code strewn in here which currently is in the process
; of being disassembled, check "misc/leftovers/50A9C.idb".
; It also contains the raw source code for debug mode.
; ---------------------------------------------------------------------------

Leftover_50A9C:	binclude	"misc/leftovers/50A9C.bin"
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Modified Type 1b 68000 Sound Driver
; Same as Sonic 1's, down to its location in the ROM
; ---------------------------------------------------------------------------
		include	"s1.sounddriver.asm"

; ---------------------------------------------------------------------------
; Primary object assets (players and common objects)
; ---------------------------------------------------------------------------
Art_Sonic:	binclude	"art/uncompressed/Sonic's art.bin"
		even
Map_Sonic:	binclude	"mappings/sprite/Sonic.bin"
		even
Art_Tails:	binclude	"art/uncompressed/Tails' art.bin"
		even
SonicDynPLC:	binclude	"mappings/spriteDPLC/Sonic.bin"
		even
Nem_Shield:	binclude	"art/nemesis/Shield.nem"
		even
Nem_Stars:	binclude	"art/nemesis/Stars.nem"
		even
Art_SplashDust:	binclude	"art/uncompressed/Dust and water splash.bin"
		even
Map_Tails:	binclude	"mappings/sprite/Tails.bin"
		even
TailsDynPLC:	binclude	"mappings/spriteDPLC/Tails.bin"
		even
; ---------------------------------------------------------------------------
; Sega and title screen assets
; ---------------------------------------------------------------------------
Nem_SegaLogo:	binclude	"art/nemesis/S1/Sega Logo (JP1).nem"
		even
Eni_SegaLogo:	binclude	"tilemaps/S1/Sega Logo (JP1).eni"
		even
Eni_TitleMap:	binclude	"tilemaps/Title Emblem.eni"
		even
Eni_TitleBg1:	binclude	"tilemaps/Title Background - 1.eni"
		even
Eni_TitleBg2:	binclude	"tilemaps/Title Background - 2.eni"
		even
Nem_Title:	binclude	"art/nemesis/8x8 - Title.bin"
		even
Nem_TitleSonicTails:
		binclude	"art/nemesis/Title Sonic and Tails.nem"
		even
; ---------------------------------------------------------------------------
; Green Hill Zone stage assets
; ---------------------------------------------------------------------------
S1Nem_GHZFlowerBits:
		binclude	"art/nemesis/S1/GHZ Flower Stalk.nem"
		even
Nem_SwingPlatform:
		binclude	"art/nemesis/S1/GHZ Swinging Platform.nem"
		even
Nem_GHZ_Bridge:	binclude	"art/nemesis/S1/GHZ Bridge.nem"
		even
		binclude	"art/nemesis/S1/Unused - GHZ Block.nem"
		even
S1Nem_GHZRollingBall:
		binclude	"art/nemesis/S1/GHZ Giant Ball.nem"
		even
S1Nem_GHZRollingSpikesLog:
		binclude	"art/nemesis/S1/Unused - GHZ Log.nem"
		even
S1Nem_GHZLogSpikes:
		binclude	"art/nemesis/S1/GHZ Spiked Log.nem"
		even
Nem_GHZ_Rock:	binclude	"art/nemesis/S1/GHZ Purple Rock.nem"
		even
S1Nem_GHZBreakableWall:
		binclude	"art/nemesis/S1/GHZ Breakable Wall.nem"
		even
S1Nem_GHZWall:	binclude	"art/nemesis/S1/GHZ Edge Wall.nem"
		even
; ---------------------------------------------------------------------------
; Emerald Hill Zone stage assets
; ---------------------------------------------------------------------------
Nem_EHZ_Fireball:
		binclude	"art/nemesis/Fireball 1.nem"
		even
Nem_BurningLog:	binclude	"art/nemesis/Burning Log.nem"
		even
Nem_EHZ_Waterfall:
		binclude	"art/nemesis/Waterfall tiles.nem"
		even
Nem_HTZ_Fireball:
		binclude	"art/nemesis/Fireball 2.nem"
		even
Nem_EHZ_Bridge:	binclude	"art/nemesis/EHZ bridge.nem"
		even
; ---------------------------------------------------------------------------
; Hill Top Zone stage assets
; ---------------------------------------------------------------------------
Nem_HTZ_Lift:	binclude	"art/nemesis/HTZ zip-line platform.nem"
		even
Nem_HTZ_AutomaticDoor:
		binclude	"art/nemesis/HTZ Autodoor.nem"
		even
Nem_HTZ_Seesaw:	binclude	"art/nemesis/See-saw in HTZ.bin"
		even
; ---------------------------------------------------------------------------
; Hidden Palace Zone stage assets
; ---------------------------------------------------------------------------
Nem_HPZ_Bridge:	binclude	"art/nemesis/HPZ bridge.nem"
		even
Nem_HPZ_Waterfall:
		binclude	"art/nemesis/HPZ waterfall.nem"
		even
Nem_HPZ_Emerald:
		binclude	"art/nemesis/HPZ Emerald.nem"
		even
Nem_HPZ_Platform:
		binclude	"art/nemesis/HPZ Platform.nem"
		even
Nem_HPZ_PulsingBall:
		binclude	"art/nemesis/HPZ Pulsing Ball.nem"
		even
Nem_HPZ_Various:
		binclude	"art/nemesis/HPZ Various.nem"
		even
Nem_UnusedDust:	binclude	"art/nemesis/Unused - Dust.nem"
		even
; ---------------------------------------------------------------------------
; Chemical Plant Zone stage assets
; ---------------------------------------------------------------------------
Nem_CPZ_FloatingPlatform:
		binclude	"art/nemesis/CPZ Floating Platform.nem"
		even
; ---------------------------------------------------------------------------
; Primary object assets (common objects)
; ---------------------------------------------------------------------------
Nem_WaterSurface:
		binclude	"art/nemesis/Water Surface.nem"
		even
Nem_Button:	binclude	"art/nemesis/Button.nem"
		even
Nem_VSpring2:	binclude	"art/nemesis/Vertical spring.bin"
		even
Nem_HSpring2:	binclude	"art/nemesis/Horizontal spring.bin"
		even
Nem_DSpring:	binclude	"art/nemesis/Diagonal spring.bin"
		even
Nem_HUD:	binclude	"art/nemesis/HUD.nem"
		even
Nem_Lives:	binclude	"art/nemesis/Sonic lives counter.bin"
		even
Nem_Ring:	binclude	"art/nemesis/Ring.bin"
		even
Nem_Monitors:	binclude	"art/nemesis/Monitor and contents.bin"
		even
Nem_VSpikes:	binclude	"art/nemesis/Spikes.nem"
		even
Nem_Points:	binclude	"art/nemesis/Numbers.nem"
		even
Nem_Lamppost:	binclude	"art/nemesis/Lamppost.nem"
		even
Nem_Signpost:	binclude	"art/nemesis/Signpost.bin"
		even
Nem_Crocobot:	binclude	"art/nemesis/Crocobot.nem"
		even
Nem_Buzzer:	binclude	"art/nemesis/Buzzer.bin"
		even
Nem_Bat:	binclude	"art/nemesis/Bat.nem"
		even
Nem_Octopus:	binclude	"art/nemesis/Octus.nem"
		even
Nem_Triceratops:
		binclude	"art/nemesis/Stegway.nem"
		even
Nem_Redz:	binclude	"art/nemesis/Redz.bin"
		even
Nem_HPZ_Piranha:
		binclude	"art/nemesis/BFish.nem"
		even
Nem_Seahorses:	binclude	"art/nemesis/Aquis.nem"
		even
Nem_UnusedRollingBall:
		binclude	"art/nemesis/Ball.nem"
		even
Nem_UnusedMotherBubbler:
		binclude	"art/nemesis/Unused - Bubbler's Mother.nem"
		even
Nem_UnusedBubbler:
		binclude	"art/nemesis/Unused - Bubbler.nem"
		even
Nem_Snail:	binclude	"art/nemesis/Snail badnik from EHZ.bin"
		even
Nem_Masher:	binclude	"art/nemesis/Masher.bin"
		even
Nem_BossShip:	binclude	"art/nemesis/Boss Ship.nem"
		even
Nem_CPZ_ProtoBoss:
		binclude	"art/nemesis/CPZ boss.nem"
		even
Nem_BigExplosion:
		binclude	"art/nemesis/Large explosion.nem"
		even
Nem_BossShipBoost:
		binclude	"art/nemesis/Boss Ship Boost.nem"
		even
Nem_Smoke:	binclude	"art/nemesis/Smoke trail from CPZ boss.nem"
		even
Nem_EHZ_Boss:	binclude	"art/nemesis/EHZ boss.nem"
		even
Nem_EHZ_Boss_Blades:
		binclude	"art/nemesis/Chopper blades for EHZ boss.nem"
		even
S1Nem_Ballhog:	binclude	"art/nemesis/S1/Enemy Ball Hog.nem"
		even
Nem_Crabmeat:	binclude	"art/nemesis/S1/Enemy Crabmeat.nem"
		even
Nem_GHZBuzzbomber:
		binclude	"art/nemesis/S1/Enemy Buzz Bomber.nem"
		even
Nem_UnknownGroundExplosion:
		binclude	"art/nemesis/S1/Unused - Explosion.nem"
		even
S1Nem_LZBurrobot:
		binclude	"art/nemesis/S1/Enemy Burrobot.nem"
		even
Nem_GHZ_Piranha:
		binclude	"art/nemesis/S1/Enemy Chopper.nem"
		even
Nem_S1LZJaws:	binclude	"art/nemesis/S1/Enemy Jaws.nem"
		even
Nem_S1SYZRoller:
		binclude	"art/nemesis/S1/Enemy Roller.nem"
		even
Nem_Motobug:	binclude	"art/nemesis/S1/Enemy Motobug.nem"
		even
Nem_S1Newtron:	binclude	"art/nemesis/S1/Enemy Newtron.nem"
		even
S1Nem_SYZSnail:	binclude	"art/nemesis/S1/Enemy Yadrin.nem"
		even
S1Nem_MZBat:	binclude	"art/nemesis/S1/Enemy Basaran.nem"
		even
S1Nem_Splats:	binclude	"art/nemesis/S1/Enemy Splats.nem"
		even
S1Nem_Bomb:	binclude	"art/nemesis/S1/Enemy Bomb.nem"
		even
S1Nem_Orbinaut:	binclude	"art/nemesis/S1/Enemy Orbinaut.nem"
		even
S1Nem_Caterkiller:
		binclude	"art/nemesis/S1/Enemy Caterkiller.nem"
		even
Nem_S1TitleCard:
		binclude	"art/nemesis/S1/Title Cards.nem"
		even
Nem_Explosion:	binclude	"art/nemesis/S1/Explosion.nem"
		even
Nem_GameOver:	binclude	"art/nemesis/S1/Game Over.nem"
		even
Nem_HSpring:	binclude	"art/nemesis/S1/Spring Horizontal.nem"
		even
Nem_VSpring:	binclude	"art/nemesis/S1/Spring Vertical.nem"
		even
Nem_BigFlash:	binclude	"art/nemesis/S1/Giant Ring Flash.nem"
		even
Nem_S1BonusPoints:
		binclude	"art/nemesis/S1/Hidden Bonuses.nem"
		even
S1Nem_SonicContinue:
		binclude	"art/nemesis/S1/Continue Screen Sonic.nem"
		even
S1Nem_MiniSonic:
		binclude	"art/nemesis/S1/Continue Screen Stuff.nem"
		even
Nem_Bunny:	binclude	"art/nemesis/S1/Animal Rabbit.nem"
		even
Nem_Chicken:	binclude	"art/nemesis/S1/Animal Chicken.nem"
		even
Nem_Penguin:	binclude	"art/nemesis/S1/Animal Penguin.nem"
		even
Nem_Seal:	binclude	"art/nemesis/S1/Animal Seal.nem"
		even
Nem_Pig:	binclude	"art/nemesis/S1/Animal Pig.nem"
		even
Nem_Flicky:	binclude	"art/nemesis/S1/Animal Flicky.nem"
		even
Nem_Squirrel:	binclude	"art/nemesis/S1/Animal Squirrel.nem"
		even
Map16_EHZ:	binclude	"mappings/16x16/EHZ.unc"
		even
Nem_EHZ:	binclude	"art/nemesis/8x8 - EHZ.bin"
		even
Map16_HTZ:	binclude	"mappings/16x16/HTZ.unc"
		even
Nem_HTZ:	binclude	"art/nemesis/8x8 - HTZ.bin"
		even
Nem_HTZ_AniPlaceholders:
		binclude	"art/nemesis/HTZ Ani Placeholders.nem"
		even
Map128_EHZ:	binclude	"mappings/128x128/EHZ_HTZ.unc"
		even
Map16_HPZ:	binclude	"mappings/16x16/HPZ.unc"
		even
Nem_HPZ:	binclude	"art/nemesis/8x8 - HPZ.bin"
		even
Map128_HPZ:	binclude	"mappings/128x128/HPZ.unc"
		even
Map16_CPZ:	binclude	"mappings/16x16/CPZ.unc"
		even
Nem_CPZ:	binclude	"art/nemesis/8x8 - CPZ.bin"
		even
Nem_CPZ_Buildings:
		binclude	"art/nemesis/CPZ Buildings.nem"
		even
Map128_CPZ:	binclude	"mappings/128x128/CPZ.unc"
		even
Map16_GHZ:	binclude	"mappings/16x16/GHZ.unc"
		even
Nem_GHZ:	binclude	"art/nemesis/8x8 - GHZ.bin"
		even
Nem_GHZ2:	binclude	"art/nemesis/8x8 - GHZ2.bin"
		even
Map128_GHZ:	binclude	"mappings/128x128/GHZ.kc"
		even
; --------------------------------------------------------------------------------------
; yet another leftover chunk
; --------------------------------------------------------------------------------------
Leftover_E0178:	binclude	"misc/leftovers/E0178.bin"
		even
S1Nem_EndingGraphics:
		binclude	"art/nemesis/S1/Ending - Flowers.nem"
		even
S1Nem_CreditsFont:
		binclude	"art/nemesis/S1/Ending - Credits.nem"
		even
S1Nem_EndingSONICText:
		binclude	"art/nemesis/S1/Ending - StH Logo.nem"
		even
; --------------------------------------------------------------------------------------
; ToeJam & Earl REV00 data, likely due to it once occupying the cartridge, best
; just to remove it given it takes up ONE TENTH of the cartridge space
; --------------------------------------------------------------------------------------

Leftover_E1670:
		binclude	"misc/leftovers/E1670.bin"
		even

		cnop	-1,2<<lastbit(*-1)
		dc.b	0

; end of 'ROM'
		END
