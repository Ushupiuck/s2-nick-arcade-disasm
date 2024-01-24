; ===========================================================================
; ---------------------------------------------------------------------------
; Object Status Table offsets
; ---------------------------------------------------------------------------

; Object variables
obID:		equ 0					; object ID number
obRender:	equ 1					; bitfield for x/y flip, display mode
obGfx:		equ 2					; palette line & VRAM setting (2 bytes)
obMap:		equ 4					; mappings address (4 bytes)
obX:		equ 8					; x-axis position (2-4 bytes)
obScreenY:	equ $A					; y-axis position for screen-fixed items (2 bytes)
obY:		equ $C					; y-axis position (2-4 bytes)
obVelX:		equ $10					; x-axis velocity (2 bytes)
obVelY:		equ $12					; y-axis velocity (2 bytes)
obInertia:	equ $14					; potential speed (2 bytes)
obHeight:	equ $16					; height/2
obWidth:	equ $17					; width/2
obPriority:	equ $18					; sprite stack priority -- 0 is front
obActWid:	equ $19					; action width
obFrame:	equ $1A					; current frame displayed
obAniFrame:	equ $1B					; current frame in animation script
obAnim:		equ $1C					; current animation
obPrevAni:	equ $1D					; previous animation
obTimeFrame:	equ $1E					; time to next frame
obDelayAni:	equ $1F					; time to delay animation
obColType:	equ $20					; collision response type
obColProp:	equ $21					; collision extra property
obStatus:	equ $22					; orientation or mode
obRespawnNo:	equ $23					; respawn list index number
obRoutine:	equ $24					; routine number
ob2ndRout:	equ $25					; secondary routine number
obAngle:	equ $26					; angle
obSubtype:	equ $28					; object subtype
obSolid:	equ ob2ndRout				; solid status flag

; Object variables used by Sonic/Tails
flashtime:	equ $30					; time between flashes after getting hit
invtime:	equ $32					; time left for invincibility
shoetime:	equ $34					; time left for speed shoes
standonobject:	equ $3D					; object Sonic stands on

; Miscellaneous object scratch-RAM
objoff_25:	equ $25
objoff_26:	equ $26
objoff_29:	equ $29
objoff_2A:	equ $2A
objoff_2B:	equ $2B
objoff_2C:	equ $2C
objoff_2E:	equ $2E
objoff_2F:	equ $2F
objoff_30:	equ $30
objoff_32:	equ $32
objoff_33:	equ $33
objoff_34:	equ $34
objoff_35:	equ $35
objoff_36:	equ $36
objoff_37:	equ $37
objoff_38:	equ $38
objoff_39:	equ $39
objoff_3A:	equ $3A
objoff_3B:	equ $3B
objoff_3C:	equ $3C
objoff_3D:	equ $3D
objoff_3E:	equ $3E
objoff_3F:	equ $3F

object_size_bits:	equ 6
object_size:	equ 1<<object_size_bits

; ---------------------------------------------------------------------------
; Controller Buttons
;
; Buttons bit numbers
button_up:			EQU	0
button_down:			EQU	1
button_left:			EQU	2
button_right:			EQU	3
button_B:			EQU	4
button_C:			EQU	5
button_A:			EQU	6
button_start:			EQU	7
; Buttons masks (1 << x == pow(2, x))
button_up_mask:			EQU	1<<button_up	; $01
button_down_mask:		EQU	1<<button_down	; $02
button_left_mask:		EQU	1<<button_left	; $04
button_right_mask:		EQU	1<<button_right	; $08
button_B_mask:			EQU	1<<button_B	; $10
button_C_mask:			EQU	1<<button_C	; $20
button_A_mask:			EQU	1<<button_A	; $40
button_start_mask:		EQU	1<<button_start	; $80

Size_of_SegaPCM:	equ $6978
Size_of_DAC_driver_guess:	equ $1760

; VDP addressses
vdp_data_port:		equ $C00000
vdp_control_port:	equ $C00004
vdp_counter:		equ $C00008

psg_input:		equ $C00011

; Z80 addresses
z80_ram:		equ $A00000			; start of Z80 RAM
z80_dac_timpani_pitch:	equ $A000EA
z80_dac_status:		equ $A01FFD
z80_dac_sample:		equ $A01FFF
z80_ram_end:		equ $A02000			; end of non-reserved Z80 RAM
z80_version:		equ $A10001
z80_port_1_data:	equ $A10002
z80_port_1_control:	equ $A10008
z80_port_2_control:	equ $A1000A
z80_expansion_control:	equ $A1000C
z80_bus_request:	equ $A11100
z80_reset:		equ $A11200
ym2612_a0:		equ $A04000
ym2612_d0:		equ $A04001
ym2612_a1:		equ $A04002
ym2612_d1:		equ $A04003

security_addr:		equ $A14000

; Sound driver constants
TrackPlaybackControl:	equ 0				; All tracks
TrackVoiceControl:	equ 1				; All tracks
TrackTempoDivider:	equ 2				; All tracks
TrackDataPointer:	equ 4				; All tracks (4 bytes)
TrackTranspose:		equ 8				; FM/PSG only (sometimes written to as a word, to include TrackVolume)
TrackVolume:		equ 9				; FM/PSG only
TrackAMSFMSPan:		equ $A				; FM/DAC only
TrackVoiceIndex:	equ $B				; FM/PSG only
TrackVolEnvIndex:	equ $C				; PSG only
TrackStackPointer:	equ $D				; All tracks
TrackDurationTimeout:	equ $E				; All tracks
TrackSavedDuration:	equ $F				; All tracks
TrackSavedDAC:		equ $10				; DAC only
TrackFreq:		equ $10				; FM/PSG only (2 bytes)
TrackNoteTimeout:	equ $12				; FM/PSG only
TrackNoteTimeoutMaster:equ $13				; FM/PSG only
TrackModulationPtr:	equ $14				; FM/PSG only (4 bytes)
TrackModulationWait:	equ $18				; FM/PSG only
TrackModulationSpeed:	equ $19				; FM/PSG only
TrackModulationDelta:	equ $1A				; FM/PSG only
TrackModulationSteps:	equ $1B				; FM/PSG only
TrackModulationVal:	equ $1C				; FM/PSG only (2 bytes)
TrackDetune:		equ $1E				; FM/PSG only
TrackPSGNoise:		equ $1F				; PSG only
TrackFeedbackAlgo:	equ $1F				; FM only
TrackVoicePtr:		equ $20				; FM SFX only (4 bytes)
TrackLoopCounters:	equ $24				; All tracks (multiple bytes)
TrackGoSubStack:	equ TrackSz			; All tracks (multiple bytes. This constant won't get to be used because of an optimisation that just uses TrackSz)

TrackSz:	equ $30

; ===========================================================================
; ---------------------------------------------------------------------------
; V-Int routines
offset :=	Vint_SwitchTbl
ptrsize :=	1
idstart :=	0

VintID_Lag =			id(Vint_Lag_ptr)	; 0
VintID_SEGA =			id(Vint_SEGA_ptr)	; 2
VintID_Title =			id(Vint_Title_ptr)	; 4
VintID_Unused6 =		id(Vint_Unused6_ptr)	; 6
VintID_Level =			id(Vint_Level_ptr)	; 8
VintID_S1SS =			id(Vint_S1SS_ptr)	; $A
VintID_TitleCard =		id(Vint_TitleCard_ptr)	; $C
VintID_UnusedE =		id(Vint_UnusedE_ptr)	; $E
VintID_Pause =			id(Vint_Pause_ptr)	; $10
VintID_Fade =			id(Vint_Fade_ptr)	; $12
VintID_PCM =			id(Vint_PCM_ptr)	; $14
VintID_SSResults =		id(Vint_SSResults_ptr)	; $16
VintID_TitleCard2 =		id(Vint_TitleCard2_ptr)	; $18

; Game modes
offset :=	GameModeArray
ptrsize :=	1
idstart :=	0
GameModeID_SegaScreen =		id(GameMode_SegaScreen)	; 0
GameModeID_TitleScreen =	id(GameMode_TitleScreen) ; 4
GameModeID_Demo =		id(GameMode_Demo)	; 8
GameModeID_Level =		id(GameMode_Level)	; $C
GameModeID_SpecialStage =	id(GameMode_SpecialStage) ; $10
GameModeID_ContinueScreen:	equ $14			; $14 ; referenced despite it not existing
GameModeID_S1Ending:		equ $18			; $18 ; referenced despite it not existing
GameModeID_S1Credits:		equ $1C			; $1C ; referenced despite it not existing
GameModeFlag_TitleCard:		equ 7			; flag bit
GameModeID_TitleCard:		equ 1<<GameModeFlag_TitleCard ; $80 ; flag mask

; ---------------------------------------------------------------------------
; Main RAM
	phase	ramaddr($FFFF0000)
v_startofram:
v_128x128:	ds.b	$8000				; 128x128 tile mappings ($8000 bytes)
v_128x128_end:

v_lvllayout:	ds.b	$1000				; level layout buffer ($1000 bytes)
v_lvllayoutbg:	= v_lvllayout+$80

v_16x16:	ds.b	$1800				; 16x16 tile mappings ($1800 bytes)

v_bgscroll_buffer:	ds.b	$200			; background scroll buffer
v_ngfx_buffer:		ds.b	$200			; Nemesis graphics decompression buffer
v_ngfx_buffer_end:

v_spritequeue:		ds.b	$400			; sprite display queue, in order of priority
v_spritequeue_end:

v_objspace:		ds.b	object_size*$80		; object variable space ($40 bytes per object)
v_objspace_end:

; Title screen objects
v_sonicteam	= v_objspace+object_size*2	; object variable space for the "SONIC TEAM PRESENTS" text ($40 bytes)
v_titlesonic	= v_objspace+object_size*1	; object variable space for Sonic in the title screen ($40 bytes)
v_pressstart	= v_objspace+object_size*2	; object variable space for the "PRESS START BUTTON" text ($40 bytes)
v_titletm	= v_objspace+object_size*3	; object variable space for the trademark symbol ($40 bytes)
v_ttlsonichide	= v_objspace+object_size*4	; object variable space for hiding part of Sonic ($40 bytes)

; Level objects
v_player	= v_objspace+object_size*0	; object variable space for Sonic ($40 bytes)
v_2ndplayer	= v_objspace+object_size*1	; object variable space for Tails ($40 bytes)
v_hud		= v_objspace+object_size*14	; object variable space for the HUD ($40 bytes)

v_titlecard	= v_objspace+object_size*2	; object variable space for the title card ($100 bytes)
v_ttlcardname	= v_titlecard+object_size*0		; object variable space for the title card zone name text ($40 bytes)
v_ttlcardzone	= v_titlecard+object_size*1	; object variable space for the title card "ZONE" text ($40 bytes)
v_ttlcardact	= v_titlecard+object_size*2	; object variable space for the title card act text ($40 bytes)
v_ttlcardoval	= v_titlecard+object_size*3	; object variable space for the title card oval ($40 bytes)

v_gameovertext1	= v_objspace+object_size*2	; object variable space for the "GAME"/"TIME" in "GAME OVER"/"TIME OVER" text ($40 bytes)
v_gameovertext2	= v_objspace+object_size*3	; object variable space for the "OVER" in "GAME OVER"/"TIME OVER" text ($40 bytes)

v_shieldobj	= v_objspace+object_size*6	; object variable space for the shield ($40 bytes)
v_starsobj1	= v_objspace+object_size*8	; object variable space for the invincibility stars #1 ($40 bytes)
v_starsobj2	= v_objspace+object_size*9	; object variable space for the invincibility stars #2 ($40 bytes)
v_starsobj3	= v_objspace+object_size*10	; object variable space for the invincibility stars #3 ($40 bytes)
v_starsobj4	= v_objspace+object_size*11	; object variable space for the invincibility stars #4 ($40 bytes)

v_splash	= v_objspace+object_size*12	; object variable space for the water splash ($40 bytes)
v_sonicbubbles	= v_objspace+object_size*13	; object variable space for the bubbles that come out of Sonic's mouth/drown countdown ($40 bytes)
v_watersurface1	= v_objspace+object_size*30	; object variable space for the water surface #1 ($40 bytes)
v_watersurface2	= v_objspace+object_size*31	; object variable space for the water surface #1 ($40 bytes)

v_endcard	= v_objspace+object_size*23	; object variable space for the level results card ($1C0 bytes)
v_endcardsonic	= v_endcard+object_size*0	; object variable space for the level results card "SONIC HAS" text ($40 bytes)
v_endcardpassed	= v_endcard+object_size*1	; object variable space for the level results card "PASSED" text ($40 bytes)
v_endcardact	= v_endcard+object_size*2	; object variable space for the level results card act text ($40 bytes)
v_endcardscore	= v_endcard+object_size*3	; object variable space for the level results card score tally ($40 bytes)
v_endcardtime	= v_endcard+object_size*4	; object variable space for the level results card time bonus tally ($40 bytes)
v_endcardring	= v_endcard+object_size*5	; object variable space for the level results card ring bonus tally ($40 bytes)
v_endcardoval	= v_endcard+object_size*6	; object variable space for the level results card oval ($40 bytes)

v_lvlobjspace	= v_objspace+object_size*32	; level object variable space ($1800 bytes)
v_lvlobjend	= v_lvlobjspace+object_size*96
v_objend	= v_lvlobjend

; Special Stage objects
v_ssrescard	= v_objspace+object_size*23	; object variable space for the Special Stage results card ($140 bytes)
v_ssrestext	= v_ssrescard+object_size*0	; object variable space for the Special Stage results card text ($40 bytes)
v_ssresscore	= v_ssrescard+object_size*1	; object variable space for the Special Stage results card score tally ($40 bytes)
v_ssresring	= v_ssrescard+object_size*2	; object variable space for the Special Stage results card ring bonus tally ($40 bytes)
v_ssresoval	= v_ssrescard+object_size*3	; object variable space for the Special Stage results card oval ($40 bytes)
v_ssrescontinue	= v_ssrescard+object_size*4	; object variable space for the Special Stage results card continue icon ($40 bytes)
v_ssresemeralds	= v_objspace+object_size*32	; object variable space for the emeralds in the Special Stage results ($180 bytes)

; Continue screen objects
v_continuetext	= v_objspace+object_size*1	; object variable space for the continue screen text ($40 bytes)
v_continuelight	= v_objspace+object_size*2	; object variable space for the continue screen light spot ($40 bytes)
v_continueicon	= v_objspace+object_size*3	; object variable space for the continue screen icon ($40 bytes)

; Ending objects
v_endemeralds	= v_objspace+object_size*16	; object variable space for the emeralds in the ending ($180 bytes)
v_endemeralds_end	= v_objspace+object_size*32
v_endlogo	= v_objspace+object_size*16	; object variable space for the logo in the ending ($40 bytes)

; Credits objects
v_credits	= v_objspace+object_size*2	; object variable space for the credits text ($40 bytes)
v_endeggman	= v_objspace+object_size*2	; object variable space for Eggman after the credits ($40 bytes)
v_tryagain	= v_objspace+object_size*3	; object variable space for the "TRY AGAIN" text ($40 bytes)
v_eggmanchaos	= v_objspace+object_size*32	; object variable space for the emeralds juggled by Eggman ($180 bytes)

v_colladdr1:	ds.b	$600
v_colladdr2:	ds.b	$600

VDP_Command_Buffer:		ds.w	7*$12
VDP_Command_Buffer_Slot:	ds.l	1

v_spritetablebuffer:	ds.b	$300			; sprite table (last $80 bytes are overwritten by v_pal_water_dup)
v_spritetablebuffer_end:

v_hscrolltablebuffer:	ds.b	$380			; scrolling table data
v_hscrolltablebuffer_end:
			ds.b	$80			; would be unused, but data from v_hscrolltablebuffer can spill into here
v_hscrolltablebuffer_end_padded:

Sonic_Stat_Record_Buf:	ds.b	$100
Sonic_Pos_Record_Buf:	ds.b	$100
Tails_Pos_Record_Buf:	ds.b	$100
Tails_Pos_Record_Buf_Dup:	ds.b	$100

Ring_Positions:		ds.b	$600
Ring_Positions_End:

Camera_RAM:

Camera_Positions:
Camera_X_pos:			ds.l	1
Camera_Y_pos:			ds.l	1
Camera_BG_X_pos:		ds.l	1		; only used sometimes as the layer deformation makes it sort of redundant
Camera_BG_Y_pos:		ds.l	1
Camera_BG2_X_pos:		ds.l	1		; used in CPZ
Camera_BG2_Y_pos:		ds.l	1		; used in CPZ
Camera_BG3_X_pos:		ds.l	1		; unused (only initialised at beginning of level)?
Camera_BG3_Y_pos:		ds.l	1		; unused (only initialised at beginning of level)?
Camera_Positions_End:

Camera_Positions_P2:
Camera_X_pos_P2:		ds.l	1
Camera_Y_pos_P2:		ds.l	1
Camera_BG_X_pos_P2:		ds.l	1		; only used sometimes as the layer deformation makes it sort of redundant
Camera_BG_Y_pos_P2:		ds.l	1
Camera_BG2_X_pos_P2:		ds.l	1		; unused (only initialised at beginning of level)?
Camera_BG2_Y_pos_P2:		ds.l	1
Camera_BG3_X_pos_P2:		ds.l	1		; unused (only initialised at beginning of level)?
Camera_BG3_Y_pos_P2:		ds.l	1
Camera_Positions_P2_End:

Block_Crossed_Flags:
Horiz_block_crossed_flag:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary horizontally
Verti_block_crossed_flag:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary vertically
Horiz_block_crossed_flag_BG:	ds.b	1		; toggles between 0 and $10 when background camera crosses a block boundary horizontally
Verti_block_crossed_flag_BG:	ds.b	1		; toggles between 0 and $10 when background camera crosses a block boundary vertically
Horiz_block_crossed_flag_BG2:	ds.b	1		; used in CPZ
				ds.b	1		; $FFFFEE45 ; seems unused
Horiz_block_crossed_flag_BG3:	ds.b	1
				ds.b	1		; $FFFFEE47 ; seems unused
Block_Crossed_Flags_End:

Block_Crossed_Flags_P2:
Horiz_block_crossed_flag_P2:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary horizontally
Verti_block_crossed_flag_P2:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary vertically
				ds.b	6		; $FFFFEE4A-$FFFFEE4F ; seems unused
Block_Crossed_Flags_P2_End:

Scroll_Flags_All:
Scroll_flags:			ds.w	1		; bitfield ; bit 0 = redraw top row, bit 1 = redraw bottom row, bit 2 = redraw left-most column, bit 3 = redraw right-most column
Scroll_flags_BG:		ds.w	1		; bitfield ; bits 0-3 as above, bit 4 = redraw top row (except leftmost block), bit 5 = redraw bottom row (except leftmost block), bits 6-7 = as bits 0-1
Scroll_flags_BG2:		ds.w	1		; bitfield ; essentially unused; bit 0 = redraw left-most column, bit 1 = redraw right-most column
Scroll_flags_BG3:		ds.w	1		; bitfield ; for CPZ; bits 0-3 as Scroll_flags_BG but using Y-dependent BG camera; bits 4-5 = bits 2-3; bits 6-7 = bits 2-3
Scroll_Flags_All_End:

Scroll_Flags_All_P2:
Scroll_flags_P2:		ds.w	1		; bitfield ; bit 0 = redraw top row, bit 1 = redraw bottom row, bit 2 = redraw left-most column, bit 3 = redraw right-most column
Scroll_flags_BG_P2:		ds.w	1		; bitfield ; bits 0-3 as above, bit 4 = redraw top row (except leftmost block), bit 5 = redraw bottom row (except leftmost block), bits 6-7 = as bits 0-1
Scroll_flags_BG2_P2:		ds.w	1		; bitfield ; essentially unused; bit 0 = redraw left-most column, bit 1 = redraw right-most column
Scroll_flags_BG3_P2:		ds.w	1		; bitfield ; for CPZ; bits 0-3 as Scroll_flags_BG but using Y-dependent BG camera; bits 4-5 = bits 2-3; bits 6-7 = bits 2-3
Scroll_Flags_All_P2_End:

Camera_Positions_Copy:
Camera_RAM_copy:		ds.l	2		; copied over every V-int
Camera_BG_copy:			ds.l	2		; copied over every V-int
Camera_BG2_copy:		ds.l	2		; copied over every V-int
Camera_BG3_copy:		ds.l	2		; copied over every V-int
Camera_Positions_Copy_End:

Camera_Positions_Copy_P2:
Camera_P2_copy:			ds.l	8		; copied over every V-int
Camera_Positions_Copy_P2_End:

Scroll_Flags_Copy_All:
Scroll_flags_copy:		ds.w	1		; copied over every V-int
Scroll_flags_BG_copy:		ds.w	1		; copied over every V-int
Scroll_flags_BG2_copy:		ds.w	1		; copied over every V-int
Scroll_flags_BG3_copy:		ds.w	1		; copied over every V-int
Scroll_Flags_Copy_All_End:

Scroll_Flags_Copy_All_P2:
Scroll_flags_copy_P2:		ds.w	1		; copied over every V-int
Scroll_flags_BG_copy_P2:	ds.w	1		; copied over every V-int
Scroll_flags_BG2_copy_P2:	ds.w	1		; copied over every V-int
Scroll_flags_BG3_copy_P2:	ds.w	1		; copied over every V-int
Scroll_Flags_Copy_All_P2_End:

Camera_Difference:
Camera_X_pos_diff:		ds.w	1		; (new X pos - old X pos) * 256
Camera_Y_pos_diff:		ds.w	1		; (new Y pos - old Y pos) * 256
Camera_Difference_End:

Camera_BG_X_pos_diff:		ds.w	1		; Effective camera change used in WFZ ending and HTZ screen shake
Camera_BG_Y_pos_diff:		ds.w	1		; Effective camera change used in WFZ ending and HTZ screen shake

Camera_Difference_P2:
Camera_X_pos_diff_P2:		ds.w	1		; (new X pos - old X pos) * 256
Camera_Y_pos_diff_P2:		ds.w	1		; (new Y pos - old Y pos) * 256
Camera_Difference_P2_End:
				ds.l	1		; $FFFFEEBC-$FFFFEEBF ; seems unused

Camera_Min_X_pos_target:	ds.w	1		; unused, except on write in LevelSizeLoad...
Camera_Max_X_pos_target:	ds.w	1		; unused
Camera_Min_Y_pos_target:	ds.w	1		; same as above. The write being a long also overwrites the address below
Camera_Max_Y_pos_target:	ds.w	1

Camera_Boundaries:
Camera_Min_X_pos:		ds.w	1
Camera_Max_X_pos:		ds.w	1
Camera_Min_Y_pos:		ds.w	1
Camera_Max_Y_pos:		ds.w	1
Camera_Boundaries_End:

Camera_Delay:
Horiz_scroll_delay_val:		ds.w	1		; if its value is a, where a != 0, X scrolling will be based on the player's X position a-1 frames ago
Sonic_Pos_Record_Index:		ds.w	1		; into Sonic_Pos_Record_Buf and Sonic_Stat_Record_Buf
Camera_Delay_End:

Camera_Delay_P2:
Horiz_scroll_delay_val_P2:	ds.w	1
Tails_Pos_Record_Index:		ds.w	1		; into Tails_Pos_Record_Buf
Camera_Delay_P2_End:

Camera_Y_pos_bias:		ds.w	1		; added to y position for lookup/lookdown, $60 is center
Camera_Y_pos_bias_End:

Camera_Y_pos_bias_P2:		ds.w	1		; for Tails
Camera_Y_pos_bias_P2_End:

Deform_lock:			ds.b	1		; set to 1 to stop all deformation
				ds.b	1		; $FFFFEEDD ; seems unused
Camera_Max_Y_Pos_Changing:	ds.b	1
Dynamic_Resize_Routine:		ds.b	1
				ds.b	2		; $FFFFEEE0-$FFFFEEE1
Camera_BG_X_offset:		ds.w	1		; Used to control background scrolling in X in WFZ ending and HTZ screen shake
Camera_BG_Y_offset:		ds.w	1		; Used to control background scrolling in Y in WFZ ending and HTZ screen shake
HTZ_Terrain_Delay:		ds.w	1		; During HTZ screen shake, this is a delay between rising and sinking terrain during which there is no shaking
HTZ_Terrain_Direction:		ds.b	1		; During HTZ screen shake, 0 if terrain/lava is rising, 1 if lowering
				ds.b	3		; $FFFFEEE9-$FFFFEEEB ; seems unused
Vscroll_Factor_P2_HInt:		ds.l	1
Camera_X_pos_copy:		ds.l	1
Camera_Y_pos_copy:		ds.l	1

Camera_Boundaries_P2:
Tails_Min_X_pos:		ds.w	1
Tails_Max_X_pos:		ds.w	1
Tails_Min_Y_pos:		ds.w	1		; seems not actually implemented (only written to)
Tails_Max_Y_pos:		ds.w	1
Camera_Boundaries_P2_End:

Camera_RAM_End:

Block_cache:			ds.w	512/16*2	; Width of plane in blocks, with each block getting two words.
Ring_consumption_table:		ds.b	$80		; contains RAM addresses of rings currently being consumed
Ring_consumption_table_End:

v_snddriver_ram:	ds.b	$5C0			; start of RAM for the sound driver data ($5C0 bytes)
			ds.b	$40
; =================================================================================
; From here on, until otherwise stated, all offsets are relative to v_snddriver_ram
; =================================================================================
v_startofvariables:	= $000
v_sndprio:		= $000				; sound priority (priority of new music/SFX must be higher or equal to this value or it won't play; bit 7 of priority being set prevents this value from changing)
v_main_tempo_timeout:	= $001				; Counts down to zero; when zero, resets to next value and delays song by 1 frame
v_main_tempo:		= $002				; Used for music only
f_pausemusic:		= $003				; flag set to stop music when paused
v_fadeout_counter:	= $004

v_fadeout_delay:	= $006
v_communication_byte:	= $007				; used in Ristar to sync with a boss' attacks; unused here
f_updating_dac:		= $008				; $80 if updating DAC, $00 otherwise
v_sound_id:		= $009				; sound or music copied from below
v_soundqueue_start:	= $00A
v_soundqueue0:		= v_soundqueue_start+0		; sound or music to play
v_soundqueue1:		= v_soundqueue_start+1		; special sound to play
v_soundqueue2:		= v_soundqueue_start+2		; unused sound to play
v_soundqueue_end:	= v_soundqueue_start+3

f_voice_selector:	= $00E				; $00 = use music voice pointer; $40 = use special voice pointer; $80 = use track voice pointer

v_voice_ptr:		= $018				; voice data pointer (4 bytes)

v_special_voice_ptr:	= $020				; voice data pointer for special SFX ($D0-$DF) (4 bytes)

f_fadein_flag:		= $024				; Flag for fade in
v_fadein_delay:		= $025
v_fadein_counter:	= $026				; Timer for fade in/out
f_1up_playing:		= $027				; flag indicating 1-up song is playing
v_tempo_mod:		= $028				; music - tempo modifier
v_speeduptempo:		= $029				; music - tempo modifier with speed shoes
f_speedup:		= $02A				; flag indicating whether speed shoes tempo is on ($80) or off ($00)
v_ring_speaker:		= $02B				; which speaker the "ring" sound is played in (00 = right; 01 = left)
f_push_playing:		= $02C				; if set, prevents further push sounds from playing

v_music_track_ram:	= $040				; Start of music RAM

v_music_fmdac_tracks:	= v_music_track_ram+TrackSz*0
v_music_dac_track:	= v_music_fmdac_tracks+TrackSz*0
v_music_fm_tracks:	= v_music_fmdac_tracks+TrackSz*1
v_music_fm1_track:	= v_music_fm_tracks+TrackSz*0
v_music_fm2_track:	= v_music_fm_tracks+TrackSz*1
v_music_fm3_track:	= v_music_fm_tracks+TrackSz*2
v_music_fm4_track:	= v_music_fm_tracks+TrackSz*3
v_music_fm5_track:	= v_music_fm_tracks+TrackSz*4
v_music_fm6_track:	= v_music_fm_tracks+TrackSz*5
v_music_fm_tracks_end:	= v_music_fm_tracks+TrackSz*6
v_music_fmdac_tracks_end:	= v_music_fm_tracks_end
v_music_psg_tracks:	= v_music_fmdac_tracks_end
v_music_psg1_track:	= v_music_psg_tracks+TrackSz*0
v_music_psg2_track:	= v_music_psg_tracks+TrackSz*1
v_music_psg3_track:	= v_music_psg_tracks+TrackSz*2
v_music_psg_tracks_end:	= v_music_psg_tracks+TrackSz*3
v_music_track_ram_end:	= v_music_psg_tracks_end

v_sfx_track_ram:	= v_music_track_ram_end		; Start of SFX RAM, straight after the end of music RAM

v_sfx_fm_tracks:	= v_sfx_track_ram+TrackSz*0
v_sfx_fm3_track:	= v_sfx_fm_tracks+TrackSz*0
v_sfx_fm4_track:	= v_sfx_fm_tracks+TrackSz*1
v_sfx_fm5_track:	= v_sfx_fm_tracks+TrackSz*2
v_sfx_fm_tracks_end:	= v_sfx_fm_tracks+TrackSz*3
v_sfx_psg_tracks:	= v_sfx_fm_tracks_end
v_sfx_psg1_track:	= v_sfx_psg_tracks+TrackSz*0
v_sfx_psg2_track:	= v_sfx_psg_tracks+TrackSz*1
v_sfx_psg3_track:	= v_sfx_psg_tracks+TrackSz*2
v_sfx_psg_tracks_end:	= v_sfx_psg_tracks+TrackSz*3
v_sfx_track_ram_end:	= v_sfx_psg_tracks_end

v_spcsfx_track_ram:	= v_sfx_track_ram_end		; Start of special SFX RAM, straight after the end of SFX RAM

v_spcsfx_fm4_track:	= v_spcsfx_track_ram+TrackSz*0
v_spcsfx_psg3_track:	= v_spcsfx_track_ram+TrackSz*1
v_spcsfx_track_ram_end:	= v_spcsfx_track_ram+TrackSz*2

v_1up_ram_copy:		= v_spcsfx_track_ram_end

; =================================================================================
; From here on, no longer relative to sound driver RAM
; =================================================================================

v_gamemode:		ds.b	1			; game mode (00=Sega; 04=Title; 08=Demo; 0C=Level; 10=SS; 14=Cont; 18=End; 1C=Credit; +8C=PreLevel)
			ds.b	1			; unused
v_jpadhold2:		ds.b	1			; joypad input - held, duplicate
v_jpadpress2:		ds.b	1			; joypad input - pressed, duplicate
v_jpadhold1:		ds.b	1			; joypad input - held
v_jpadpress1:		ds.b	1			; joypad input - pressed
v_2Pjpadhold1:		ds.b	1			; joypad input - held
v_2Pjpadpress1:		ds.b	1			; joypad input - pressed
			ds.b	4			; unused
v_vdp_buffer1:		ds.w	1			; VDP instruction buffer
			ds.b	6			; unused
v_demolength:		ds.w	1			; the length of a demo in frames
v_scrposy_vdp:		ds.w	1			; screen position y (VDP)
v_bgscrposy_vdp:	ds.w	1			; background screen position y (VDP)
v_scrposx_vdp:		ds.w	1			; screen position x (VDP)
v_bgscrposx_vdp:	ds.w	1			; background screen position x (VDP)
v_bg3scrposy_vdp:	ds.w	1
v_bg3scrposx_vdp:	ds.w	1
			ds.b	2			; unused
v_hbla_hreg:		ds.w	1			; VDP H.interrupt register buffer (8Axx)
v_hbla_line = v_hbla_hreg+1				; screen line where water starts and palette is changed by HBlank
v_pfade_start:		ds.b	1			; palette fading - start position in bytes
v_pfade_size:		ds.b	1			; palette fading - number of colours

v_misc_variables:
v_vbla_0e_counter:	ds.b	1			; tracks how many times vertical interrupts routine 0E occured (pretty much unused because routine 0E is unused)
			ds.b	1			; unused
v_vbla_routine:		ds.b	1			; VBlank - routine counter
			ds.b	1			; unused
v_spritecount:		ds.b	1			; number of sprites on-screen
			ds.b	5			; unused
v_pcyc_num:		ds.w	1			; palette cycling - current reference number
v_pcyc_time:		ds.w	1			; palette cycling - time until the next change
v_random:		ds.l	1			; pseudo random number buffer
f_pause:		ds.w	1			; flag set to pause the game
			ds.b	4			; unused
v_vdp_buffer2:		ds.w	1			; VDP instruction buffer
			ds.b	2			; unused
f_hbla_pal:		ds.w	1			; flag set to change palette during HBlank (0000 = no; 0001 = change)
v_waterpos1:		ds.w	1			; water height, actual
v_waterpos2:		ds.w	1			; water height, ignoring sway
v_waterpos3:		ds.w	1			; water height, next target
f_water:		ds.b	1			; flag set for water
v_wtr_routine:		ds.b	1			; water event - routine counter
f_wtr_state:		ds.b	1			; water palette state when water is above/below the screen (00 = partly/all dry; 01 = all underwater)
f_doupdatesinhblank:	ds.b	1			; defers performing various tasks to the Horizontal Interrupt (H-Blank)
v_pal_buffer:		ds.b	$30			; palette data buffer (used for palette cycling)
v_misc_variables_end:

v_plc_buffer:		ds.b	6*16			; pattern load cues buffer (maximum $10 PLCs)
v_plc_buffer_only_end:
v_plc_ptrnemcode:	ds.l	1			; pointer for nemesis decompression code ($1502 or $150C)
v_plc_repeatcount:	ds.l	1
v_plc_paletteindex:	ds.l	1
v_plc_previousrow:	ds.l	1
v_plc_dataword:		ds.l	1
v_plc_shiftvalue:	ds.l	1
v_plc_patternsleft:	ds.w	1
v_plc_framepatternsleft:ds.w	1
			ds.b	4			; unused
v_plc_buffer_end:

v_levelvariables:					; variables that are reset between levels
word_FFFFF700:		ds.w	1
Tails_control_counter:	ds.w	1
Tails_respawn_counter:	ds.w	1
word_FFFFF706:		ds.w	1
Tails_CPU_routine:	ds.w	1
	ds.b	6

Rings_manager_routine:	ds.b	1
Level_started_flag:	ds.b	1
Ring_start_addr:	ds.w	1
Ring_end_addr:		ds.w	1
Ring_start_addr_P2:	ds.w	1
Ring_end_addr_P2:	ds.w	1
	ds.b	6

byte_FFFFF720:		ds.b	1
byte_FFFFF721:		ds.b	1
	ds.b	$E

Water_flag:		ds.b	1
	ds.b	$F

Demo_button_index_2P:	ds.w	1			; index into button press demo data, for player 2
Demo_press_counter_2P:	ds.w	1			; frames remaining until next button press, for player 2
	ds.b	$1C

Sonic_top_speed:	ds.w	1
Sonic_acceleration:	ds.w	1
Sonic_deceleration:	ds.w	1
Sonic_LastLoadedDPLC:	ds.b	1
	ds.b	1					; $FFFFF767 ; seems unused
Primary_Angle:		ds.b	1
	ds.b	1					; $FFFFF769 ; seems unused
Secondary_Angle:	ds.b	1
	ds.b	1					; $FFFFF76B ; seems unused

Obj_placement_routine:	ds.b	1
	ds.b	1					; $FFFFF76D ; seems unused
Camera_X_pos_last:	ds.w	1			; Camera_X_pos_coarse from the previous frame
Camera_X_pos_last_End:

Object_Manager_Addresses:
Obj_load_addr_right:	ds.l	1			; contains the address of the next object to load when moving right
Obj_load_addr_left:	ds.l	1			; contains the address of the last object loaded when moving left
Object_Manager_Addresses_End:

Object_Manager_Addresses_P2:
Obj_load_addr_right_P2:		ds.l	1
Obj_load_addr_left_P2:		ds.l	1
Object_Manager_Addresses_P2_End:

Object_manager_2P_RAM:					; The next 16 bytes belong to this.
Object_RAM_block_indices:	ds.b	6		; seems to be an array of horizontal chunk positions, used for object position range checks
Player_1_loaded_object_blocks:	ds.b	3
Player_2_loaded_object_blocks:	ds.b	3

Camera_X_pos_last_P2:		ds.w	1
Camera_X_pos_last_P2_End:

Obj_respawn_index_P2:		ds.b	2		; respawn table indices of the next objects when moving left or right for the second player
Obj_respawn_index_P2_End:
Object_manager_2P_RAM_End:

Demo_button_index:		ds.w	1		; index into button press demo data, for player 1
Demo_press_counter:		ds.b	1		; frames remaining until next button press, for player 1
				ds.b	1		; $FFFFF793 ; seems unused
PalChangeSpeed:			ds.w	1
Collision_addr:			ds.l	1
v_palss_num:		ds.w	1			; palette cycling in Special Stage - reference number
v_palss_time:		ds.w	1			; palette cycling in Special Stage - time until next change
v_palss_index:		ds.w	1			; palette cycling in Special Stage - index into palette cycle 2 (unused?)
v_ssbganim:		ds.w	1			; Special Stage background animation
				ds.b	5		; seems unused
Boss_defeated_flag:		ds.b	1
				ds.b	2		; seems unused

f_lockscreen:		ds.b	1
			ds.b	$13			; unused

v_gfxbigring:		ds.w	1			; settings for giant ring graphics loading
			ds.b	7			; unused

f_wtunnelmode:		ds.b	1			; LZ water tunnel mode
f_playerctrl:		ds.b	1			; Player control override flags (object ineraction, control enable)
f_wtunnelallow:		ds.b	1			; LZ water tunnels (00 = enabled; 01 = disabled)
f_slidemode:		ds.b	1			; LZ water slide mode
			ds.b	1

f_lockctrl:		ds.b	1
f_bigring:		ds.b	1			; flag set when Sonic collects the giant ring
			ds.b	2

v_itembonus:		ds.w	1			; item bonus from broken enemies, blocks etc.
v_timebonus:		ds.w	1			; time bonus at the end of an act
v_ringbonus:		ds.w	1			; ring bonus at the end of an act
f_endactbonus:		ds.b	1			; time/ring bonus update flag at the end of an act
			ds.b	1
v_lz_deform:		ds.w	1			; LZ deformation offset, in units of $80

Camera_X_pos_coarse:	ds.w	1			; (Camera_X_pos - 128) / 256
Camera_X_pos_coarse_End:

Camera_X_pos_coarse_P2:	ds.w	1
Camera_X_pos_coarse_P2_End:

Tails_LastLoadedDPLC:	ds.b	1
TailsTails_LastLoadedDPLC:	ds.b	1

f_switch:		ds.b	$10			; flags set when Sonic stands on a switch

Anim_Counters:		ds.b	$10

v_levelvariables_end:

Sprite_Table:		ds.b	$280			; Sprite attribute table buffer
Sprite_Table_End:
v_pal_water_dup = Sprite_Table_End-$80			; duplicate underwater palette, used for transitions ($80 bytes)
v_pal_water:		ds.b	$80			; main underwater palette
v_pal_dry:		ds.b	$80			; main palette
v_pal_dry_dup:		ds.b	$80			; duplicate palette, used for transitions
v_objstate:		ds.b	$C0			; object state list
v_objstate_end:
			ds.b	$140			; stack
v_systemstack:

			ds.b	2
Level_Inactive_flag:	ds.w	1			; (2 bytes)
Timer_frames:		ds.w	1			; (2 bytes)
Debug_object:		ds.w	1			; (2 bytes)
Debug_placement_mode:	ds.w	1			; (2 bytes)
Debug_Accel_Timer:	ds.b	1			; (1 byte)
Debug_Speed:		ds.b	1			; (1 byte)

Vint_runcount:		ds.l	1			; (4 bytes)

Current_ZoneAndAct:	= Current_Zone
Current_Zone:		ds.b	1			; (1 byte)
Current_Act:		ds.b	1			; (1 byte)
v_lives:		ds.b	1			; (1 byte)
			ds.b	1			; unused
v_air:			ds.w	1			; air remaining while underwater
v_airbyte = v_air+1					; low byte for air
v_lastspecial:		ds.b	1			; last special stage number
			ds.b	1			; unused
v_continues:		ds.b	1			; number of continues
			ds.b	1			; unused
f_timeover:		ds.b	1			; time over flag
v_lifecount:		ds.b	1			; lives counter value (for actual number, see "v_lives")
f_lifecount:		ds.b	1			; lives counter update flag
f_ringcount:		ds.b	1			; ring counter update flag
f_timecount:		ds.b	1			; time counter update flag
f_scorecount:		ds.b	1			; score counter update flag
v_rings:		ds.w	1			; rings
v_ringbyte = v_rings+1					; low byte for rings
v_time:			ds.l	1			; time
v_timemin = v_time+1					; time - minutes
v_timesec = v_time+2					; time - seconds
v_timecent = v_time+3					; time - centiseconds
v_score:		ds.l	1			; score
			ds.b	2			; unused
v_shield:		ds.b	1			; shield status (00 = no; 01 = yes)
v_invinc:		ds.b	1			; invinciblity status (00 = no; 01 = yes)
v_shoes:		ds.b	1			; speed shoes status (00 = no; 01 = yes)
v_unused1:		ds.b	1			; an unused fourth player status (Goggles?)

v_lastlamp:		ds.b	2			; number of the last lamppost you hit
v_lamp_xpos:		ds.w	1			; x-axis for Sonic to respawn at lamppost
v_lamp_ypos:		ds.w	1			; y-axis for Sonic to respawn at lamppost
v_lamp_rings:		ds.w	1			; rings stored at lamppost
v_lamp_time:		ds.l	1			; time stored at lamppost
v_lamp_dle:		ds.b	1			; dynamic level event routine counter at lamppost
			ds.b	1			; unused
v_lamp_limitbtm:	ds.w	1			; level bottom boundary at lamppost
v_lamp_scrx:		ds.w	1			; x-axis screen at lamppost
v_lamp_scry:		ds.w	1			; y-axis screen at lamppost
v_lamp_bgscrx:		ds.w	1			; x-axis BG screen at lamppost
v_lamp_bgscry:		ds.w	1			; y-axis BG screen at lamppost
v_lamp_bg2scrx:		ds.w	1			; x-axis BG2 screen at lamppost
v_lamp_bg2scry:		ds.w	1			; y-axis BG2 screen at lamppost
v_lamp_bg3scrx:		ds.w	1			; x-axis BG3 screen at lamppost
v_lamp_bg3scry:		ds.w	1			; y-axis BG3 screen at lamppost
v_lamp_wtrpos:		ds.w	1			; water position at lamppost
v_lamp_wtrrout:		ds.b	1			; water routine at lamppost
v_lamp_wtrstat:		ds.b	1			; water state at lamppost
v_lamp_lives:		ds.b	1			; lives counter at lamppost
			ds.b	2			; unused
v_emeralds:		ds.b	1			; number of chaos emeralds
v_emldlist:		ds.b	6			; which individual emeralds you have (00 = no; 01 = yes)
v_oscillate:		ds.w	1			; oscillation bitfield
v_timingandscreenvariables:
v_timingvariables:
			ds.b	$40			; values which oscillate - for swinging platforms, et al
			ds.b	$20			; unused
v_ani0_time:		ds.b	1			; synchronised sprite animation 0 - time until next frame (used for synchronised animations)
v_ani0_frame:		ds.b	1			; synchronised sprite animation 0 - current frame
v_ani1_time:		ds.b	1			; synchronised sprite animation 1 - time until next frame
v_ani1_frame:		ds.b	1			; synchronised sprite animation 1 - current frame
v_ani2_time:		ds.b	1			; synchronised sprite animation 2 - time until next frame
v_ani2_frame:		ds.b	1			; synchronised sprite animation 2 - current frame
v_ani3_time:		ds.b	1			; synchronised sprite animation 3 - time until next frame
v_ani3_frame:		ds.b	1			; synchronised sprite animation 3 - current frame
v_ani3_buf:		ds.w	1			; synchronised sprite animation 3 - info buffer
			ds.b	$26			; unused
v_limittopdb:		ds.w	1			; level upper boundary, buffered for debug mode
v_limitbtmdb:		ds.w	1			; level bottom boundary, buffered for debug mode
			ds.b	$8C			; unused
v_timingvariables_end:

v_levseldelay:		ds.w	1			; level select - time until change when up/down is held
v_levselitem:		ds.w	1			; level select - item selected
v_levselsound:		ds.w	1			; level select - sound selected
			ds.b	$3A			; unused

v_scorelife:		ds.l	1			; points required for an extra life (JP1 only)
			ds.b	$1C			; unused

f_levselcheat:		ds.b	1			; level select cheat flag
f_slomocheat:		ds.b	1			; slow motion & frame advance cheat flag
f_debugcheat:		ds.b	1			; debug mode cheat flag
f_creditscheat:		ds.b	1			; hidden credits & press start cheat flag
v_title_dcount:		ds.w	1			; number of times the d-pad is pressed on title screen
v_title_ccount:		ds.w	1			; number of times C is pressed on title screen
Two_player_mode:	ds.w	1
unk_FFFFFFE9	= Two_player_mode+1
word_FFFFFFEA:		ds.w	1
word_FFFFFFEC:		ds.w	1
word_FFFFFFEE:		ds.w	1

f_demo:			ds.w	1			; demo mode flag (0 = no; 1 = yes; $8001 = ending)
v_demonum:		ds.w	1			; demo level number (not the same as the level number)
v_creditsnum:		ds.w	1			; credits index number
			ds.b	2			; unused
v_megadrive:		ds.b	1			; Megadrive machine type
			ds.b	1			; unused
Debug_mode_flag:	ds.w	1
v_init:			ds.l	1			; 'init' text string
v_endofram:
    if * > 0	; Don't declare more space than the RAM can contain!
	fatal "The RAM variable declarations are too large by $\{*} bytes."
    endif
	dephase

; Special stage
v_ssbuffer1		= v_128x128
v_ssblockbuffer		= v_ssbuffer1+$1020		; ($2000 bytes)
v_ssblockbuffer_end	= v_ssblockbuffer+$80*$40
v_ssbuffer2		= v_128x128+$4000
v_ssblocktypes		= v_ssbuffer2
v_ssitembuffer		= v_ssbuffer2+$400		; ($100 bytes)
v_ssitembuffer_end	= v_ssitembuffer+$100
v_ssbuffer3		= v_128x128+$8000
v_ssscroll_buffer	= v_ngfx_buffer+$100

; Error handler
	phase v_objstate
v_regbuffer:	ds.b	$40				; stores registers d0-a7 during an error event
v_spbuffer:	ds.l	1				; stores most recent sp address
v_errortype:	ds.b	1				; error type
	dephase
	!org 0
; ---------------------------------------------------------------------------
; I/O Area
HW_Version:			equ $A10001
HW_Port_1_Data:			equ $A10003
HW_Port_2_Data:			equ $A10005
HW_Expansion_Data:		equ $A10007
HW_Port_1_Control:		equ $A10009
HW_Port_2_Control:		equ $A1000B
HW_Expansion_Control:		equ $A1000D
HW_Port_1_TxData:		equ $A1000F
HW_Port_1_RxData:		equ $A10011
HW_Port_1_SCtrl:		equ $A10013
HW_Port_2_TxData:		equ $A10015
HW_Port_2_RxData:		equ $A10017
HW_Port_2_SCtrl:		equ $A10019
HW_Expansion_TxData:		equ $A1001B
HW_Expansion_RxData:		equ $A1001D
HW_Expansion_SCtrl:		equ $A1001F

; Background music
offset :=	MusicIndex
ptrsize :=	4
idstart :=	$81

bgm__First =	idstart
bgm_GHZ =	id(ptr_mus81)
bgm_LZ =	id(ptr_mus82)
bgm_MZ =	id(ptr_mus83)
bgm_SLZ =	id(ptr_mus84)
bgm_SYZ =	id(ptr_mus85)
bgm_SBZ =	id(ptr_mus86)
bgm_Invincible =	id(ptr_mus87)
bgm_ExtraLife =	id(ptr_mus88)
bgm_SS =	id(ptr_mus89)
bgm_Title =	id(ptr_mus8A)
bgm_Ending =	id(ptr_mus8B)
bgm_Boss =	id(ptr_mus8C)
bgm_FZ =	id(ptr_mus8D)
bgm_GotThrough =	id(ptr_mus8E)
bgm_GameOver =	id(ptr_mus8F)
bgm_Continue =	id(ptr_mus90)
bgm_Credits =	id(ptr_mus91)
bgm_Drowning =	id(ptr_mus92)
bgm_Emerald =	id(ptr_mus93)
bgm__Last =	id(ptr_musend)-1

; Sound effects
offset :=	SoundIndex
ptrsize :=	4
idstart :=	$A0

sfx__First =	idstart
sfx_Jump =	id(ptr_sndA0)
sfx_Lamppost =	id(ptr_sndA1)
sfx_A2 =	id(ptr_sndA2)
sfx_Death =	id(ptr_sndA3)
sfx_Skid =	id(ptr_sndA4)
sfx_A5 =	id(ptr_sndA5)
sfx_HitSpikes =	id(ptr_sndA6)
sfx_Push =	id(ptr_sndA7)
sfx_SSGoal =	id(ptr_sndA8)
sfx_SSItem =	id(ptr_sndA9)
sfx_Splash =	id(ptr_sndAA)
sfx_AB =	id(ptr_sndAB)
sfx_HitBoss =	id(ptr_sndAC)
sfx_Bubble =	id(ptr_sndAD)
sfx_Fireball =	id(ptr_sndAE)
sfx_Shield =	id(ptr_sndAF)
sfx_Saw =	id(ptr_sndB0)
sfx_Electric =	id(ptr_sndB1)
sfx_Drown =	id(ptr_sndB2)
sfx_Flamethrower =	id(ptr_sndB3)
sfx_Bumper =	id(ptr_sndB4)
sfx_Ring =	id(ptr_sndB5)
sfx_SpikesMove =	id(ptr_sndB6)
sfx_Rumbling =	id(ptr_sndB7)
sfx_B8 =	id(ptr_sndB8)
sfx_Collapse =	id(ptr_sndB9)
sfx_SSGlass =	id(ptr_sndBA)
sfx_Door =	id(ptr_sndBB)
sfx_Teleport =	id(ptr_sndBC)
sfx_ChainStomp =	id(ptr_sndBD)
sfx_Roll =	id(ptr_sndBE)
sfx_Continue =	id(ptr_sndBF)
sfx_Basaran =	id(ptr_sndC0)
sfx_BreakItem =	id(ptr_sndC1)
sfx_Warning =	id(ptr_sndC2)
sfx_GiantRing =	id(ptr_sndC3)
sfx_Bomb =	id(ptr_sndC4)
sfx_Cash =	id(ptr_sndC5)
sfx_RingLoss =	id(ptr_sndC6)
sfx_ChainRise =	id(ptr_sndC7)
sfx_Burning =	id(ptr_sndC8)
sfx_Bonus =	id(ptr_sndC9)
sfx_EnterSS =	id(ptr_sndCA)
sfx_WallSmash =	id(ptr_sndCB)
sfx_Spring =	id(ptr_sndCC)
sfx_Switch =	id(ptr_sndCD)
sfx_RingLeft =	id(ptr_sndCE)
sfx_Signpost =	id(ptr_sndCF)
sfx__Last =	id(ptr_sndend)-1

; Special sound effects
offset :=	SpecSoundIndex
ptrsize :=	4
idstart :=	$D0

spec__First =	idstart
sfx_Waterfall =	id(ptr_sndD0)
spec__Last =	id(ptr_specend)-1

offset :=	Sound_ExIndex
ptrsize :=	4
idstart :=	$E0

flg__First =	idstart
bgm_Fade =	id(ptr_flgE0)
sfx_Sega =	id(ptr_flgE1)
bgm_Speedup =	id(ptr_flgE2)
bgm_Slowdown =	id(ptr_flgE3)
bgm_Stop =	id(ptr_flgE4)
flg__Last =	id(ptr_flgend)-1


; Tile VRAM Locations

; Font
ArtTile_Credits_Font:		equ $5A0
