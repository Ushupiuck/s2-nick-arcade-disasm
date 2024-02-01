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