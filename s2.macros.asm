; ---------------------------------------------------------------------------
; I run the main 68k RAM addresses through this function
; to let them work in both 16-bit and 32-bit addressing modes.
ramaddr function x,-(-x)&$FFFFFFFF

; makes a VDP address difference
vdpCommDelta function addr,((addr&$3FFF)<<16)|((addr&$C000)>>14)

; makes a VDP command
vdpComm function addr,type,rwd,(((type&rwd)&3)<<30)|((addr&$3FFF)<<16)|(((type&rwd)&$FC)<<2)|((addr&$C000)>>14)

; values for the type argument
VRAM = %100001
CRAM = %101011
VSRAM = %100101

; values for the rwd argument
READ = %001100
WRITE = %000111
DMA = %100111

; tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM
dma68kToVDP macro source,dest,length,type
	lea	(vdp_control_port).l,a5
	move.l	#(($9400|((((length)>>1)&$FF00)>>8))<<16)|($9300|(((length)>>1)&$FF)),(a5)
	move.l	#(($9600|((((source)>>1)&$FF00)>>8))<<16)|($9500|(((source)>>1)&$FF)),(a5)
	move.w	#$9700|(((((source)>>1)&$FF0000)>>16)&$7F),(a5)
	move.w	#((vdpComm(dest,type,DMA)>>16)&$FFFF),(a5)
	move.w	#(vdpComm(dest,type,DMA)&$FFFF),(v_vdp_buffer2).w
	move.w	(v_vdp_buffer2).w,(a5)
    endm

; tells the VDP to fill a region of VRAM with a certain byte
dmaFillVRAM macro byte,addr,length
	lea	(vdp_control_port).l,a5
	move.w	#$8F01,(a5)				; VRAM pointer increment: $0001
	move.l	#(($9400|((((length)-1)&$FF00)>>8))<<16)|($9300|(((length)-1)&$FF)),(a5) ; DMA length ...
	move.w	#$9780,(a5)				; VRAM fill
	move.l	#$40000080|(((addr)&$3FFF)<<16)|(((addr)&$C000)>>14),(a5) ; Start at ...
	move.w	#(byte)<<8,(vdp_data_port).l		; Fill with byte
.loop:	move.w	(a5),d1
	btst	#1,d1
	bne.s	.loop ; busy loop until the VDP is finished filling...
	move.w	#$8F02,(a5)				; VRAM pointer increment: $0002
    endm

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 4 bytes per iteration
bytesToLcnt function n,n>>2-1

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 2 bytes per iteration
bytesToWcnt function n,n>>1-1

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at x bytes per iteration
bytesToXcnt function n,x,n/x-1

; fills a region of 68k RAM with 0
clearRAM macro startaddr,endaddr
	if startaddr>endaddr
		fatal "Starting address of clearRAM \{startaddr} is after ending address \{endaddr}."
	elseif startaddr==endaddr
		warning "clearRAM is clearing zero bytes. Turning this into a nop instead."
		exitm
	endif
	if ((startaddr)&$8000)==0
		lea	(startaddr).l,a1
	else
		lea	(startaddr).w,a1
	endif
		moveq	#0,d0
	if ((startaddr)&1)
		move.b	d0,(a1)+
	endif
		move.w	#bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)),d1
.loop:		move.l	d0,(a1)+
		dbf	d1,.loop
	if (((endaddr-startaddr) - ((startaddr)&1))&2)
		move.w	d0,(a1)+
	endif
	if (((endaddr-startaddr) - ((startaddr)&1))&1)
		move.b	d0,(a1)+
	endif
		endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

stopZ80:	macro
		move.w	#$100,(z80_bus_request).l
		endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------

waitZ80:	macro
.wait:		btst	#0,(z80_bus_request).l
		bne.s	.wait
		endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

resetZ80:	macro
		move.w	#$100,(z80_reset).l
		endm

resetZ80a:	macro
		move.w	#0,(z80_reset).l
		endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

startZ80:	macro
		move.w	#0,(z80_bus_request).l
		endm

; ---------------------------------------------------------------------------
; disable interrupts
; ---------------------------------------------------------------------------

disable_ints:	macro
		move	#$2700,sr
		endm

; ---------------------------------------------------------------------------
; enable interrupts
; ---------------------------------------------------------------------------

enable_ints:	macro
		move	#$2300,sr
		endm
		
; macros to convert from tile index to art tiles, block mapping or VRAM address.
make_art_tile function addr,pal,pri,((pri&1)<<15)|((pal&3)<<13)|(addr&tile_mask)
make_art_tile_2p function addr,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((addr&tile_mask)>>1)
make_block_tile function addr,flx,fly,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((fly&1)<<12)|((flx&1)<<11)|(addr&tile_mask)
make_block_tile_2p function addr,flx,fly,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((fly&1)<<12)|((flx&1)<<11)|((addr&tile_mask)>>1)
tiles_to_bytes function addr,((addr&$7FF)<<5)
make_block_tile_pair function addr,flx,fly,pal,pri,((make_block_tile(addr,flx,fly,pal,pri)<<16)|make_block_tile(addr,flx,fly,pal,pri))
make_block_tile_pair_2p function addr,flx,fly,pal,pri,((make_block_tile_2p(addr,flx,fly,pal,pri)<<16)|make_block_tile_2p(addr,flx,fly,pal,pri))

; function to calculate the location of a tile in plane mappings
planeLoc function width,col,line,(((width * line) + col) * 2)
		
; ---------------------------------------------------------------------------
; turn a sample rate into a djnz loop counter
; ---------------------------------------------------------------------------

pcmLoopCounter function sampleRate,baseCycles, 1+(53693175/15/(sampleRate)-(baseCycles)+(13/2))/13
dpcmLoopCounter function sampleRate, pcmLoopCounter(sampleRate,301/2) ; 301 is the number of cycles zPlayPCMLoop takes.

; some variables and functions to help define those constants (redefined before a new set of IDs)
offset :=	0					; this is the start of the pointer table
ptrsize :=	1					; this is the size of a pointer (should be 1 if the ID is a multiple of the actual size)
idstart :=	0					; value to add to all IDs

; function using these variables
id function ptr,((ptr-offset)/ptrsize+idstart)
