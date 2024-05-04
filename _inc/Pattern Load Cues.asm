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
ArtLoadCues:

ptr_PLC_Main:		dc.w PLC_Main-ArtLoadCues
ptr_PLC_Main2:		dc.w PLC_Main2-ArtLoadCues
ptr_PLC_Explode:	dc.w PLC_Explode-ArtLoadCues
ptr_PLC_GameOver:	dc.w PLC_GameOver-ArtLoadCues
PLC_Levels:
ptr_PLC_GHZ:		dc.w PLC_GHZ-ArtLoadCues
ptr_PLC_GHZ2:		dc.w PLC_GHZ2-ArtLoadCues
ptr_PLC_LZ:		dc.w PLC_CPZ-ArtLoadCues
ptr_PLC_LZ2:		dc.w PLC_CPZ2-ArtLoadCues
ptr_PLC_CPZ:		dc.w PLC_CPZ-ArtLoadCues
ptr_PLC_CPZ2:		dc.w PLC_CPZ2-ArtLoadCues
ptr_PLC_EHZ:		dc.w PLC_EHZ-ArtLoadCues
ptr_PLC_EHZ2:		dc.w PLC_EHZ2-ArtLoadCues
ptr_PLC_HPZ:		dc.w PLC_HPZ-ArtLoadCues
ptr_PLC_HPZ2:		dc.w PLC_HPZ2-ArtLoadCues
ptr_PLC_HTZ:		dc.w PLC_HTZ-ArtLoadCues
ptr_PLC_HTZ2:		dc.w PLC_HTZ2-ArtLoadCues

ptr_PLC_TitleCard:	dc.w PLC_S1TitleCard-ArtLoadCues
ptr_PLC_Boss:		dc.w PLC_Boss-ArtLoadCues
ptr_PLC_Signpost:	dc.w PLC_Signpost-ArtLoadCues
ptr_PLC_Warp:		dc.w PLC_S1SpecialStage-ArtLoadCues
ptr_PLC_SpecialStage:	dc.w PLC_S1SpecialStage-ArtLoadCues
PLC_Animals:
ptr_PLC_GHZAnimals:	dc.w PLC_GHZAnimals-ArtLoadCues
ptr_PLC_LZAnimals:	dc.w PLC_LZAnimals-ArtLoadCues
ptr_PLC_CPZAnimals:	dc.w PLC_CPZAnimals-ArtLoadCues
ptr_PLC_EHZAnimals:	dc.w PLC_EHZAnimals-ArtLoadCues
ptr_PLC_HPZAnimals:	dc.w PLC_HPZAnimals-ArtLoadCues
ptr_PLC_HTZAnimals:	dc.w PLC_HTZAnimals-ArtLoadCues

ptr_PLC_SSResult:	dc.w $1C318-ArtLoadCues
ptr_PLC_Ending:		dc.w $1C31A-ArtLoadCues
ptr_PLC_TryAgain:	dc.w $1C31C-ArtLoadCues
ptr_PLC_EggmanSBZ2:	dc.w $1C31E-ArtLoadCues
ptr_PLC_FZBoss:		dc.w $1C320-ArtLoadCues

plcm:	macro gfx,vram
	dc.l gfx
	dc.w (vram<<5)
	endm
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Standard 1 - loaded for every level
; --------------------------------------------------------------------------------------
PLC_Main:	dc.w ((PLC_Main_End-PLC_Main)/6)-1
		plcm	Nem_Lamppost, $47C
		plcm	Nem_HUD, $6CA
		plcm	Nem_Lives, $7D4
		plcm	Nem_Ring, $6BC
		plcm	Nem_Points, $4AC
PLC_Main_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Standard 2 - loaded for every level
; --------------------------------------------------------------------------------------
PLC_Main2:	dc.w ((PLC_Main2_End-PLC_Main2)/6)-1
		plcm	Nem_Monitors, $680
		plcm	Nem_Shield, $4BE
		plcm	Nem_Stars, $4DE
PLC_Main2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Explosion - loaded for every level AFTER the title card
; --------------------------------------------------------------------------------------
PLC_Explode:	dc.w ((PLC_Explode_End-PLC_Explode)/6)-1
		plcm	Nem_Explosion, $5A0
PLC_Explode_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Game/Time over
; --------------------------------------------------------------------------------------
PLC_GameOver:	dc.w ((PLC_GameOver_End-PLC_GameOver)/6)-1
		plcm	Nem_GameOver, $55E
PLC_GameOver_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Green Hill Zone primary
; --------------------------------------------------------------------------------------
PLC_GHZ:	dc.w ((PLC_GHZ_End-PLC_GHZ)/6)-1
		plcm	Nem_GHZ, 0
		plcm	Nem_GHZ_Piranha, $470
		plcm	Nem_VSpikes, $4A0
		plcm	Nem_HSpring, $4A8
		plcm	Nem_VSpring, $4B8
		plcm	Nem_GHZ_Bridge, $4C6
		plcm	Nem_SwingPlatform, $4D0
		plcm	Nem_Motobug, $4E0
		plcm	Nem_GHZ_Rock, $6C0
PLC_GHZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Green Hill Zone secondary
; --------------------------------------------------------------------------------------
PLC_GHZ2:	dc.w ((PLC_GHZ2_End-PLC_GHZ2)/6)-1
		plcm	Nem_GHZ_Piranha, $470
PLC_GHZ2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Chemical Plant Zone primary
; --------------------------------------------------------------------------------------
PLC_CPZ:	dc.w ((PLC_CPZ_End-PLC_CPZ)/6)-1
		plcm	Nem_CPZ, 0
		plcm	Nem_CPZ_Buildings, $3D0
		plcm	Nem_CPZ_FloatingPlatform, $400
PLC_CPZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Chemical Plant Zone secondary
; --------------------------------------------------------------------------------------
PLC_CPZ2:	dc.w ((PLC_CPZ2_End-PLC_CPZ2)/6)-1
		plcm	Nem_VSpikes, $434
		plcm	Nem_DSpring, $43C
		plcm	Nem_VSpring2, $45C
		plcm	Nem_HSpring2, $470
PLC_CPZ2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Emerald Hill Zone primary
; --------------------------------------------------------------------------------------
PLC_EHZ:	dc.w ((PLC_EHZ_End-PLC_EHZ)/6)-1
		plcm	Nem_EHZ, 0
		plcm	Nem_EHZ_Fireball, $39E
		plcm	Nem_EHZ_Waterfall, $3AE
		plcm	Nem_EHZ_Bridge, $3C6
		plcm	Nem_HTZ_Seesaw, $3CE
		plcm	Nem_VSpikes, $434
		plcm	Nem_DSpring, $43C
		plcm	Nem_VSpring2, $45C
		plcm	Nem_HSpring2, $470
PLC_EHZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Emerald Hill Zone secondary
; --------------------------------------------------------------------------------------
PLC_EHZ2:	dc.w ((PLC_EHZ2_End-PLC_EHZ2)/6)-1
		plcm	Nem_Shield, $560
		plcm	Nem_Points, $4AC
		plcm	Nem_Buzzer, $3E6
		plcm	Nem_Snail, $402
		plcm	Nem_Masher, $41C
PLC_EHZ2_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hidden Palace Zone primary
; --------------------------------------------------------------------------------------
PLC_HPZ:	dc.w ((PLC_HPZ_End-PLC_HPZ)/6)-1
		plcm	Nem_HPZ, 0
		plcm	Nem_HPZ_Bridge, $300
		plcm	Nem_HPZ_Waterfall, $315
		plcm	Nem_HPZ_Platform, $34A
		plcm	Nem_HPZ_PulsingBall, $35A
		plcm	Nem_HPZ_Various, $37C
		plcm	Nem_HPZ_Emerald, $392
		plcm	Nem_WaterSurface, $400
PLC_HPZ_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hidden Palace Zone secondary
; --------------------------------------------------------------------------------------
PLC_HPZ2:	dc.w ((PLC_HPZ2_End-PLC_HPZ2)/6)-1
		plcm	Nem_Redz, $500
		plcm	Nem_Bat, $530
PLC_HPZ2_End:
		; unused PLR entries
		plcm	Nem_Crocobot, $300
		plcm	Nem_Buzzer, $32C
		plcm	Nem_Bat, $350
		plcm	Nem_Triceratops, $3C4
		plcm	Nem_Redz, $500
		plcm	Nem_HPZ_Piranha, $530
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hill Top Zone primary
; --------------------------------------------------------------------------------------
PLC_HTZ:	dc.w ((PLC_HTZ_End-PLC_HTZ)/6)-1
		plcm	Nem_EHZ, 0
		plcm	Nem_HTZ, $1FC
		plcm	Nem_HTZ_AniPlaceholders, $500
		plcm	Nem_EHZ_Fireball, $39E
		plcm	Nem_HTZ_Fireball, $3AE
		plcm	Nem_HTZ_AutomaticDoor, $3BE
		plcm	Nem_EHZ_Bridge, $3C6
		plcm	Nem_HTZ_Seesaw, $3CE
		plcm	Nem_VSpikes, $434
		plcm	Nem_DSpring, $43C
PLC_HTZ_End:
		; unused PLR entries
		plcm	Nem_VSpring2, $45C
		plcm	Nem_HSpring2, $470
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hill Top Zone secondary
; --------------------------------------------------------------------------------------
PLC_HTZ2:	dc.w ((PLC_HTZ2_End-PLC_HTZ2)/6)-1
		plcm	Nem_HTZ_Lift, $3E6
PLC_HTZ2_End:
		; unused PLR entries
		plcm	Nem_Buzzer, $3E6
		plcm	Nem_Snail, $402
		plcm	Nem_Masher, $41C
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Sonic 1 title card
; --------------------------------------------------------------------------------------
PLC_S1TitleCard:dc.w ((PLC_S1TitleCard_End-PLC_S1TitleCard)/6)-1
		plcm	Nem_S1TitleCard, $580
PLC_S1TitleCard_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; End of zone bosses
; --------------------------------------------------------------------------------------
PLC_Boss:	dc.w ((PLC_Boss_End-PLC_Boss)/6)-1
		plcm	Nem_BossShip, $460
		plcm	Nem_EHZ_Boss, $4C0
		plcm	Nem_EHZ_Boss_Blades, $540
PLC_Boss_End:
		; unused PLR entries
		plcm	Nem_BossShip, $400
		plcm	Nem_CPZ_ProtoBoss, $460
		plcm	Nem_BossShipBoost, $4D0
		plcm	Nem_Smoke, $4D8
		plcm	Nem_EHZ_Boss, $4E8
		plcm	Nem_EHZ_Boss_Blades, $568
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; End of level signpost
; --------------------------------------------------------------------------------------
PLC_Signpost:	dc.w ((PLC_Signpost_End-PLC_Signpost)/6)-1
		plcm	Nem_Signpost, $680
		plcm	Nem_S1BonusPoints, $4B6
		plcm	Nem_BigFlash, $462
PLC_Signpost_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Sonic 1 Special Stage, although since it's blank, using it will crash the game
; unless you replace the +$10 with a -1
; --------------------------------------------------------------------------------------
; PLC_Invalid:
PLC_S1SpecialStage:
	if FixBugs
		dc.w ((PLC_S1SpecialStage_End-PLC_S1SpecialStage)/6)-1
	else
		dc.w ((PLC_S1SpecialStage_End-PLC_S1SpecialStage)/6)+$10
	endif
PLC_S1SpecialStage_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Green Hill Zone animals
; --------------------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w ((PLC_GHZAnimals_End-PLC_GHZAnimals)/6)-1
		plcm	Nem_Bunny, $580
		plcm	Nem_Flicky, $592
PLC_GHZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Labyrinth Zone animals
; --------------------------------------------------------------------------------------
PLC_LZAnimals:	dc.w ((PLC_LZAnimals_End-PLC_LZAnimals)/6)-1
		plcm	Nem_Penguin, $580
		plcm	Nem_Seal, $592
PLC_LZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Chemical Plant Zone animals
; --------------------------------------------------------------------------------------
PLC_CPZAnimals:	dc.w ((PLC_CPZAnimals_End-PLC_CPZAnimals)/6)-1
		plcm	Nem_Squirrel, $580
		plcm	Nem_Seal, $592
PLC_CPZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Emerald Hill Zone animals
; --------------------------------------------------------------------------------------
PLC_EHZAnimals:	dc.w ((PLC_EHZAnimals_End-PLC_EHZAnimals)/6)-1
		plcm	Nem_Pig, $580
		plcm	Nem_Flicky, $592
PLC_EHZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hidden Palace Zone animals
; --------------------------------------------------------------------------------------
PLC_HPZAnimals:	dc.w ((PLC_HPZAnimals_End-PLC_HPZAnimals)/6)-1
		plcm	Nem_Pig, $580
		plcm	Nem_Chicken, $592
PLC_HPZAnimals_End:
; --------------------------------------------------------------------------------------
; PATTERN LOAD REQUEST LIST
; Hill Top Zone animals
; --------------------------------------------------------------------------------------
PLC_HTZAnimals:	dc.w ((PLC_HTZAnimals_End-PLC_HTZAnimals)/6)-1
		plcm	Nem_Bunny, $580
		plcm	Nem_Chicken, $592
PLC_HTZAnimals_End:

; ---------------------------------------------------------------------------
; Pattern load cue IDs
; ---------------------------------------------------------------------------
plcid_Main:		equ (ptr_PLC_Main-ArtLoadCues)/2	; 0
plcid_Main2:		equ (ptr_PLC_Main2-ArtLoadCues)/2	; 1
plcid_Explode:		equ (ptr_PLC_Explode-ArtLoadCues)/2	; 2
plcid_GameOver:		equ (ptr_PLC_GameOver-ArtLoadCues)/2	; 3
plcid_GHZ:		equ (ptr_PLC_GHZ-ArtLoadCues)/2		; 4
plcid_GHZ2:		equ (ptr_PLC_GHZ2-ArtLoadCues)/2	; 5
plcid_LZ:		equ (ptr_PLC_LZ-ArtLoadCues)/2		; 6
plcid_LZ2:		equ (ptr_PLC_LZ2-ArtLoadCues)/2		; 7
plcid_CPZ:		equ (ptr_PLC_CPZ-ArtLoadCues)/2		; 8
plcid_CPZ2:		equ (ptr_PLC_CPZ2-ArtLoadCues)/2	; 9
plcid_EHZ:		equ (ptr_PLC_EHZ-ArtLoadCues)/2		; $A
plcid_EHZ2:		equ (ptr_PLC_EHZ2-ArtLoadCues)/2	; $B
plcid_HPZ:		equ (ptr_PLC_HPZ-ArtLoadCues)/2		; $C
plcid_HPZ2:		equ (ptr_PLC_HPZ2-ArtLoadCues)/2	; $D
plcid_HTZ:		equ (ptr_PLC_HTZ-ArtLoadCues)/2		; $E
plcid_HTZ2:		equ (ptr_PLC_HTZ2-ArtLoadCues)/2	; $F
plcid_TitleCard:	equ (ptr_PLC_TitleCard-ArtLoadCues)/2	; $10
plcid_Boss:		equ (ptr_PLC_Boss-ArtLoadCues)/2	; $11
plcid_Signpost:		equ (ptr_PLC_Signpost-ArtLoadCues)/2	; $12
plcid_Warp:		equ (ptr_PLC_Warp-ArtLoadCues)/2	; $13
plcid_SpecialStage:	equ (ptr_PLC_SpecialStage-ArtLoadCues)/2 ; $14
plcid_GHZAnimals:	equ (ptr_PLC_GHZAnimals-ArtLoadCues)/2	; $15
plcid_LZAnimals:	equ (ptr_PLC_LZAnimals-ArtLoadCues)/2	; $16
plcid_CPZAnimals:	equ (ptr_PLC_CPZAnimals-ArtLoadCues)/2	; $17
plcid_EHZAnimals:	equ (ptr_PLC_EHZAnimals-ArtLoadCues)/2	; $18
plcid_HPZAnimals:	equ (ptr_PLC_HPZAnimals-ArtLoadCues)/2	; $19
plcid_HTZAnimals:	equ (ptr_PLC_HTZAnimals-ArtLoadCues)/2	; $1A
plcid_SSResult:		equ (ptr_PLC_SSResult-ArtLoadCues)/2	; $1B
plcid_Ending:		equ (ptr_PLC_Ending-ArtLoadCues)/2	; $1C
plcid_TryAgain:		equ (ptr_PLC_TryAgain-ArtLoadCues)/2	; $1D
plcid_EggmanSBZ2:	equ (ptr_PLC_EggmanSBZ2-ArtLoadCues)/2	; $1E
plcid_FZBoss:		equ (ptr_PLC_FZBoss-ArtLoadCues)/2	; $1F