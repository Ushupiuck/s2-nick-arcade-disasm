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
	dc.l (plc1<<24)|art
	dc.l (plc2<<24)|map16x16
	dc.l map128x128
	dc.b 0,music,palette,palette
	endm

; MainLoadBlocks:
LevelArtPointers:
		levartptrs plcid_GHZ, plcid_GHZ2, palid_GHZ, Nem_GHZ, Map16_GHZ, Map128_GHZ, bgm_GHZ ; GHZ  ; GREEN HILL ZONE
		levartptrs plcid_LZ, plcid_LZ2, palid_LZ, Nem_CPZ, Map16_CPZ, Map128_CPZ, bgm_LZ ; LZ   ; LABYRINTH ZONE
		levartptrs plcid_CPZ, plcid_CPZ2, palid_CPZ, Nem_CPZ, Map16_CPZ, Map128_CPZ, bgm_MZ ; CPZ  ; CHEMICAL PLANT ZONE
		levartptrs plcid_EHZ, plcid_EHZ2, palid_EHZ, Nem_EHZ, Map16_EHZ, Map128_EHZ, bgm_SLZ ; EHZ  ; EMERALD HILL ZONE
		levartptrs plcid_HPZ, plcid_HPZ2, palid_HPZ, Nem_HPZ, Map16_HPZ, Map128_HPZ, bgm_SYZ ; HPZ  ; HIDDEN PALACE ZONE
		levartptrs plcid_HTZ, plcid_HTZ2, palid_HTZ1, Nem_EHZ, Map16_EHZ, Map128_EHZ, bgm_SBZ ; HTZ  ; HILL TOP ZONE
		levartptrs 0, 0, palid_Ending, Nem_GHZ, Map16_GHZ, Map128_GHZ, bgm_SBZ ; LEV6 ; LEVEL 6 (UNUSED, SONIC 1 ENDING)