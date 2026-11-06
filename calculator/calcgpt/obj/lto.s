	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	hl, _.str+1
	ld	(ix - 3), hl
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 256
	push	hl
	ld	hl, -1900032
	push	hl
	call	_gfx_SetPalette
	pop	hl
	pop	hl
	pop	hl
	ld	hl, -1900032
	ld.sis	de, 1058
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld.sis	hl, 2148
	ld	iy, -1900030
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 1009
	ex.sis	de, hl
	ld	hl, -1900028
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, -1900026
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld.sis	hl, 17042
	ld	iy, -1900024
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 895
	ld	iy, -1900022
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 32074
	ld	iy, -1900020
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 31711
	ld	iy, -1900018
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, 67
	push	hl
	pop	bc
	.local	.LBB0_1
.LBB0_1:                                ; =>This Inner Loop Header: Depth=1
	ld	de, 3
	push	de
	push	bc
	call	_append_chat_char
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 3), hl
	or	a, a
	jr	nz, .LBB0_1
; %bb.2:
	ld	bc, (_chat_count)
	ld	de, 23
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_4
; %bb.3:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	hl, _chat+902
	push	hl
	pop	de
	inc	de
	ld	bc, 40
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 22
	.local	.LBB0_4
.LBB0_4:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 39
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 40), 3
	ld	de, 67
	ld	hl, _.str.1+1
	.local	.LBB0_5
.LBB0_5:                                ; =>This Inner Loop Header: Depth=1
	ld	(ix - 3), hl
	ld	hl, 4
	push	hl
	push	de
	call	_append_chat_char
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	a, (hl)
	ld	e, a
	inc	hl
	or	a, a
	jr	nz, .LBB0_5
; %bb.6:
	ld	bc, (_chat_count)
	push	bc
	pop	hl
	ld	de, 23
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_8
; %bb.7:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	hl, _chat+902
	push	hl
	pop	de
	inc	de
	ld	bc, 40
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 22
	.local	.LBB0_8
.LBB0_8:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 39
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 40), 4
	ld	hl, _.str.2+1
	ld	de, 65
	.local	.LBB0_9
.LBB0_9:                                ; =>This Inner Loop Header: Depth=1
	ld	(ix - 3), hl
	ld	hl, 4
	push	hl
	push	de
	call	_append_chat_char
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	a, (hl)
	ld	e, a
	inc	hl
	or	a, a
	jr	nz, .LBB0_9
; %bb.10:
	ld	bc, (_chat_count)
	push	bc
	pop	hl
	ld	de, 23
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_12
; %bb.11:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	hl, _chat+902
	push	hl
	pop	de
	inc	de
	ld	bc, 40
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 22
	.local	.LBB0_12
.LBB0_12:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 39
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 40), 4
	ld	hl, 36106
	push	hl
	ld	hl, _descriptors
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, _usb_event
	push	hl
	call	_usb_Init
	pop	de
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB0_109
	.local	.LBB0_13
.LBB0_13:                               ; %.preheader13
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_20 Depth 2
                                        ;     Child Loop BB0_23 Depth 2
                                        ;     Child Loop BB0_53 Depth 2
	call	_usb_HandleEvents
	call	_os_GetCSC
	ld	c, a
	cp	a, 48
	call	pe, __setflag
	jp	p, .LBB0_33
; %bb.14:                               ; %.preheader13
                                        ;   in Loop: Header=BB0_13 Depth=1
	or	a, a
	jp	z, .LBB0_51
; %bb.15:                               ; %.preheader13
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	a, c
	cp	a, 9
	jp	nz, .LBB0_39
; %bb.16:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, (_input_len)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB0_51
; %bb.17:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, (_ep_in)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB0_51
; %bb.18:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, (_tx_busy)
	bit	0, a
	jp	nz, .LBB0_51
; %bb.19:                               ; %.preheader12.preheader
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, _.str.12+1
	push	hl
	pop	iy
	ld	hl, 62
	.local	.LBB0_20
.LBB0_20:                               ; %.preheader12
                                        ;   Parent Loop BB0_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 3), iy
	ld	de, 1
	push	de
	push	hl
	call	_append_chat_char
	ld	iy, (ix - 3)
	pop	hl
	pop	hl
	ld	a, (iy)
	ld	l, a
	inc	iy
	or	a, a
	jr	nz, .LBB0_20
; %bb.21:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, (_input_buf)
	ld	l, a
	or	a, a
	jr	z, .LBB0_24
; %bb.22:                               ; %.preheader10.preheader
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	de, _input_buf+1
	push	de
	pop	iy
	.local	.LBB0_23
.LBB0_23:                               ; %.preheader10
                                        ;   Parent Loop BB0_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 3), iy
	ld	de, 1
	push	de
	push	hl
	call	_append_chat_char
	ld	iy, (ix - 3)
	pop	hl
	pop	hl
	ld	a, (iy)
	ld	l, a
	inc	iy
	or	a, a
	jr	nz, .LBB0_23
	.local	.LBB0_24
.LBB0_24:                               ; %.loopexit11
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	bc, (_chat_count)
	push	bc
	pop	hl
	ld	de, 23
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_26
; %bb.25:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	hl, _chat+902
	push	hl
	pop	de
	inc	de
	ld	bc, 40
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 22
	.local	.LBB0_26
.LBB0_26:                               ;   in Loop: Header=BB0_13 Depth=1
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	hl, _chat
	add	hl, de
	ld	(hl), b
	push	hl
	pop	iy
	inc	iy
	lea	de, iy + 0
	push	hl
	pop	iy
	ld	bc, 39
	ldir
	ld	(iy + 40), 2
	ld	hl, _.str.13
	ld	(_status_str), hl
	ld	hl, _input_len
	ld	bc, (hl)
	ld	a, 67
	ld	(_tx_pkt), a
	ld	a, 71
	ld	(_tx_pkt+1), a
	ld	a, 80
	ld	(_tx_pkt+2), a
	ld	a, 84
	ld	(_tx_pkt+3), a
	ld	a, 1
	ld	(_tx_pkt+4), a
	dec	a
	ld	(_tx_pkt+5), a
	ld	l, c
	ld	h, b
	ld.sis	de, 56
	or	a, a
	sbc.sis	hl, de
	ld	e, c
	ld	d, b
	jr	c, .LBB0_28
; %bb.27:                               ;   in Loop: Header=BB0_13 Depth=1
	ld.sis	hl, 56
	ex.sis	de, hl
	.local	.LBB0_28
.LBB0_28:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, _tx_pkt+6
	ld	(hl), e
	inc	hl
	ld	(hl), d
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ex	de, hl
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jp	z, .LBB0_30
; %bb.29:                               ;   in Loop: Header=BB0_13 Depth=1
	push	de
	ld	hl, _input_buf
	push	hl
	ld	hl, _tx_pkt+8
	push	hl
	ld	(ix - 6), bc
	ld	(ix - 3), de
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 6)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 56
	or	a, a
	sbc.sis	hl, de
	ld	de, (ix - 3)
	jr	nc, .LBB0_31
	.local	.LBB0_30
.LBB0_30:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	iy, _tx_pkt+8
	add	iy, de
	ld	hl, 56
	or	a, a
	sbc	hl, de
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	iy
	call	_memset
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB0_31
.LBB0_31:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	(_tx_busy), a
	ld	hl, (_ep_in)
	ld	de, 0
	push	de
	ld	de, _tx_complete
	push	de
	ld	de, 64
	push	de
	ld	de, _tx_pkt
	push	de
	push	hl
	call	_usb_ScheduleTransfer
	pop	de
	pop	de
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB0_40
; %bb.32:                               ;   in Loop: Header=BB0_13 Depth=1
	xor	a, a
	ld	(_tx_busy), a
	ld	hl, _.str.14
	ld	(_status_str), hl
	jr	.LBB0_40
	.local	.LBB0_33
.LBB0_33:                               ; %.preheader13
                                        ;   in Loop: Header=BB0_13 Depth=1
	cp	a, 48
	jr	nz, .LBB0_35
; %bb.34:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, (_typing_mode)
	inc	hl
	ld	bc, 3
	call	__iremu
	ld	(_typing_mode), hl
	jp	.LBB0_51
	.local	.LBB0_35
.LBB0_35:                               ; %.preheader13
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	a, c
	cp	a, 55
	jp	z, .LBB0_112
; %bb.36:                               ; %.preheader13
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	a, c
	cp	a, 56
	jr	nz, .LBB0_41
; %bb.37:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	de, (_input_len)
	push	de
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_51
; %bb.38:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	iy, _input_buf
	add	iy, de
	dec	de
	ld	(_input_len), de
	ld	(iy - 1), 0
	jp	.LBB0_51
	.local	.LBB0_39
.LBB0_39:                               ; %.preheader13
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	a, c
	cp	a, 15
	jr	nz, .LBB0_41
	.local	.LBB0_40
.LBB0_40:                               ;   in Loop: Header=BB0_13 Depth=1
	or	a, a
	sbc	hl, hl
	ld	(_input_len), hl
	xor	a, a
	ld	(_input_buf), a
	jp	.LBB0_51
	.local	.LBB0_41
.LBB0_41:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	iy, (_typing_mode)
	lea	hl, iy + 0
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB0_50
; %bb.42:                               ;   in Loop: Header=BB0_13 Depth=1
	lea	de, iy + 0
	ld	l, -11
	ld	a, c
	add	a, l
	ld	l, a
	cp	a, 37
	ld	a, 0
	ld	b, a
	ld	c, a
	jp	c, .LBB0_61
	.local	.LBB0_43
.LBB0_43:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	iyl, b
	ld	b, a
	ex	de, hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	z, .LBB0_45
; %bb.44:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 0
	.local	.LBB0_45
.LBB0_45:                               ;   in Loop: Header=BB0_13 Depth=1
	and	a, b
	ld	l, a
	ld	e, iyl
	ld	a, l
	and	a, e
	ld	l, a
	bit	0, l
	jr	z, .LBB0_47
; %bb.46:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	l, 32
	ld	a, c
	add	a, l
	ld	c, a
	.local	.LBB0_47
.LBB0_47:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, c
	or	a, a
	jr	z, .LBB0_51
; %bb.48:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	de, (_input_len)
	push	de
	pop	hl
	ld	a, c
	ld	bc, 128
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB0_51
; %bb.49:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	iy, _input_buf
	add	iy, de
	inc	de
	ld	(_input_len), de
	ld	(iy), a
	ld	(iy + 1), 0
	jr	.LBB0_51
	.local	.LBB0_50
.LBB0_50:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	l, -10
	ld	a, c
	add	a, l
	ld	l, a
	cp	a, 28
	jp	c, .LBB0_63
	.local	.LBB0_51
.LBB0_51:                               ;   in Loop: Header=BB0_13 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 18
	push	hl
	ld	hl, 320
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_gfx_FillRectangle
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 2
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 320
	push	hl
	ld	hl, 18
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_HorizLine
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 3
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 4
	push	hl
	ld	hl, 6
	push	hl
	ld	hl, _.str.15
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 4
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 4
	push	hl
	ld	hl, 72
	push	hl
	ld	hl, _.str.16
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (_status_str)
	push	hl
	call	_gfx_PrintString
	pop	hl
	ld	hl, (_chat_count)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB0_56
; %bb.52:                               ; %.preheader.preheader
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, _chat
	ld	(ix - 3), hl
	ld	hl, 22
	ld	(ix - 6), hl
	ld	de, 0
	.local	.LBB0_53
.LBB0_53:                               ; %.preheader
                                        ;   Parent Loop BB0_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 9), de
	ld	hl, (ix - 6)
	ld	iy, (ix - 3)
	ld	a, (iy + 40)
	dec	a
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ld	hl, 393989
                                        ; kill: def $c killed $c killed $ubc
	call	__ishru
	cp	a, 3
	jr	c, .LBB0_55
; %bb.54:                               ; %.preheader
                                        ;   in Loop: Header=BB0_53 Depth=2
	ld	a, 7
	ld	l, a
	.local	.LBB0_55
.LBB0_55:                               ; %.preheader
                                        ;   in Loop: Header=BB0_53 Depth=2
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, (ix - 6)
	push	hl
	ld	hl, 6
	push	hl
	ld	hl, (ix - 3)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 9)
	inc	hl
	ld	bc, (_chat_count)
	ld	(ix - 9), bc
	ld	bc, 8
	ld	iy, (ix - 6)
	add	iy, bc
	ld	(ix - 6), iy
	ld	iy, (ix - 3)
	lea	iy, iy + 41
	ld	(ix - 3), iy
	push	hl
	pop	de
	ld	bc, (ix - 9)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_53
	.local	.LBB0_56
.LBB0_56:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	hl, 1
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 18
	push	hl
	ld	hl, 320
	push	hl
	ld	hl, 222
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillRectangle
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 2
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 320
	push	hl
	ld	hl, 221
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_HorizLine
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 3
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	de, (_typing_mode)
	push	de
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	ld	bc, _.str.18
	jr	z, .LBB0_58
; %bb.57:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	bc, _.str.19
	.local	.LBB0_58
.LBB0_58:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_13 Depth=1
	sbc	hl, hl
	adc	hl, de
	ld	hl, _.str.17
	jr	z, .LBB0_60
; %bb.59:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_13 Depth=1
	push	bc
	pop	hl
	.local	.LBB0_60
.LBB0_60:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_13 Depth=1
	ld	de, 226
	push	de
	ld	de, 6
	push	de
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 7
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, _input_buf
	push	hl
	call	_gfx_PrintString
	pop	hl
	ld	a, (-851968)
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	ld	hl, 95
	push	hl
	call	z, _gfx_PrintChar
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_Blit
	pop	hl
	jp	.LBB0_13
	.local	.LBB0_61
.LBB0_61:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	bc, 0
	ld	c, l
	ld	hl, JTI0_1
	add	hl, bc
	add	hl, bc
	add	hl, bc
	ld	hl, (hl)
	xor	a, a
	ld	b, a
	ld	c, a
	jp	(hl)
	.local	.LBB0_62
.LBB0_62:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 87
	jp	.LBB0_43
	.local	.LBB0_63
.LBB0_63:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	de, 0
	ld	e, l
	ld	hl, JTI0_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	ld	c, 48
	jp	(hl)
	.local	.LBB0_64
.LBB0_64:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 43
	jp	.LBB0_47
	.local	.LBB0_65
.LBB0_65:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 52
	jp	.LBB0_47
	.local	.LBB0_66
.LBB0_66:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 40
	jp	.LBB0_47
	.local	.LBB0_67
.LBB0_67:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 50
	jp	.LBB0_47
	.local	.LBB0_68
.LBB0_68:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 42
	jp	.LBB0_47
	.local	.LBB0_69
.LBB0_69:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 53
	jp	.LBB0_47
	.local	.LBB0_70
.LBB0_70:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 41
	jp	.LBB0_47
	.local	.LBB0_71
.LBB0_71:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 49
	jp	.LBB0_47
	.local	.LBB0_72
.LBB0_72:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 45
	jp	.LBB0_47
	.local	.LBB0_73
.LBB0_73:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 54
	jp	.LBB0_47
	.local	.LBB0_74
.LBB0_74:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 55
	jp	.LBB0_47
	.local	.LBB0_75
.LBB0_75:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 47
	jp	.LBB0_47
	.local	.LBB0_76
.LBB0_76:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 56
	jp	.LBB0_47
	.local	.LBB0_77
.LBB0_77:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 51
	jp	.LBB0_47
	.local	.LBB0_78
.LBB0_78:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 44
	jp	.LBB0_47
	.local	.LBB0_79
.LBB0_79:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 46
	jp	.LBB0_47
	.local	.LBB0_80
.LBB0_80:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	c, 57
	jp	.LBB0_47
	.local	.LBB0_81
.LBB0_81:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 73
	jp	.LBB0_43
	.local	.LBB0_82
.LBB0_82:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 67
	jp	.LBB0_43
	.local	.LBB0_83
.LBB0_83:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 75
	jp	.LBB0_43
	.local	.LBB0_84
.LBB0_84:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 90
	jp	.LBB0_43
	.local	.LBB0_85
.LBB0_85:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 72
	jp	.LBB0_43
	.local	.LBB0_86
.LBB0_86:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 85
	jp	.LBB0_43
	.local	.LBB0_87
.LBB0_87:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 71
	jp	.LBB0_43
	.local	.LBB0_88
.LBB0_88:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 83
	jp	.LBB0_43
	.local	.LBB0_89
.LBB0_89:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 88
	jp	.LBB0_43
	.local	.LBB0_90
.LBB0_90:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 82
	jp	.LBB0_43
	.local	.LBB0_91
.LBB0_91:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 70
	jp	.LBB0_43
	.local	.LBB0_92
.LBB0_92:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 77
	jp	.LBB0_43
	.local	.LBB0_93
.LBB0_93:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 81
	jp	.LBB0_43
	.local	.LBB0_94
.LBB0_94:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, 0
	ld	c, 32
	jp	.LBB0_43
	.local	.LBB0_95
.LBB0_95:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 79
	jp	.LBB0_43
	.local	.LBB0_96
.LBB0_96:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, 0
	ld	c, 63
	jp	.LBB0_43
	.local	.LBB0_97
.LBB0_97:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 74
	jp	.LBB0_43
	.local	.LBB0_98
.LBB0_98:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 80
	jp	.LBB0_43
	.local	.LBB0_99
.LBB0_99:                               ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 86
	jp	.LBB0_43
	.local	.LBB0_100
.LBB0_100:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 89
	jp	.LBB0_43
	.local	.LBB0_101
.LBB0_101:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, 0
	ld	c, 46
	jp	.LBB0_43
	.local	.LBB0_102
.LBB0_102:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 76
	jp	.LBB0_43
	.local	.LBB0_103
.LBB0_103:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 69
	jp	.LBB0_43
	.local	.LBB0_104
.LBB0_104:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 84
	jp	.LBB0_43
	.local	.LBB0_105
.LBB0_105:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 66
	jp	.LBB0_43
	.local	.LBB0_106
.LBB0_106:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 68
	jp	.LBB0_43
	.local	.LBB0_107
.LBB0_107:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 65
	jp	.LBB0_43
	.local	.LBB0_108
.LBB0_108:                              ;   in Loop: Header=BB0_13 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 78
	jp	.LBB0_43
	.local	.LBB0_109
.LBB0_109:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, 6
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 12
	push	hl
	push	hl
	ld	hl, _.str.3
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_Blit
	pop	hl
	.local	.LBB0_110
.LBB0_110:                              ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB0_110
; %bb.111:
	ld	hl, 1
	jr	.LBB0_113
	.local	.LBB0_112
.LBB0_112:
	call	_usb_Cleanup
	or	a, a
	sbc	hl, hl
	.local	.LBB0_113
.LBB0_113:                              ; %.loopexit14
	ld	(ix - 3), hl
	call	_gfx_End
	ld	hl, (ix - 3)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_main, .Lfunc_end0-_main
	.section	.rodata._main,"a",@progbits
JTI0_0:
	d24	.LBB0_64
	d24	.LBB0_72
	d24	.LBB0_68
	d24	.LBB0_75
	d24	.LBB0_51
	d24	.LBB0_51
	d24	.LBB0_51
	d24	.LBB0_51
	d24	.LBB0_77
	d24	.LBB0_73
	d24	.LBB0_80
	d24	.LBB0_70
	d24	.LBB0_51
	d24	.LBB0_51
	d24	.LBB0_51
	d24	.LBB0_79
	d24	.LBB0_67
	d24	.LBB0_69
	d24	.LBB0_76
	d24	.LBB0_66
	d24	.LBB0_51
	d24	.LBB0_51
	d24	.LBB0_51
	d24	.LBB0_47
	d24	.LBB0_71
	d24	.LBB0_65
	d24	.LBB0_74
	d24	.LBB0_78
JTI0_1:
	d24	.LBB0_62
	d24	.LBB0_90
	d24	.LBB0_92
	d24	.LBB0_85
	d24	.LBB0_43
	d24	.LBB0_43
	d24	.LBB0_96
	d24	.LBB0_43
	d24	.LBB0_99
	d24	.LBB0_93
	d24	.LBB0_102
	d24	.LBB0_87
	d24	.LBB0_43
	d24	.LBB0_43
	d24	.LBB0_101
	d24	.LBB0_84
	d24	.LBB0_86
	d24	.LBB0_98
	d24	.LBB0_83
	d24	.LBB0_91
	d24	.LBB0_82
	d24	.LBB0_43
	d24	.LBB0_94
	d24	.LBB0_100
	d24	.LBB0_104
	d24	.LBB0_95
	d24	.LBB0_97
	d24	.LBB0_103
	d24	.LBB0_105
	d24	.LBB0_43
	d24	.LBB0_43
	d24	.LBB0_89
	d24	.LBB0_88
	d24	.LBB0_108
	d24	.LBB0_81
	d24	.LBB0_106
	d24	.LBB0_107
                                        ; -- End function
	.section	.text._append_chat_char,"ax",@progbits
	.type	_append_chat_char,@function     ; -- Begin function append_chat_char
_append_chat_char:                      ; @append_chat_char
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	e, (ix + 6)
	ld	iy, _chat
	xor	a, a
	ld	hl, (_chat_count)
	push	hl
	pop	bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB1_3
; %bb.1:
	ld	hl, 1
	ld	(_chat_count), hl
	ld	(_chat), a
	lea	hl, iy + 0
	inc	hl
	ld	bc, 39
	ld	a, e
	ex	de, hl
	lea	hl, iy + 0
	ldir
	ld	l, a
	ld	a, (ix + 9)
	ld	(_chat+40), a
	ld	a, l
	cp	a, 10
	ld	bc, 1
	jr	nz, .LBB1_6
; %bb.2:
	ld	hl, 1
	push	hl
	pop	bc
	push	bc
	pop	de
	ld	(ix - 3), bc
	ld	a, (ix + 9)
	jp	.LBB1_12
	.local	.LBB1_3
.LBB1_3:
	ld	a, e
	cp	a, 10
	jr	nz, .LBB1_6
; %bb.4:
	ld	de, 23
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB1_11
; %bb.5:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	push	iy
	ld	(ix - 9), bc
	call	_memmove
	ld	iy, _chat
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	hl, _chat+902
	push	hl
	pop	de
	inc	de
	ld	bc, 40
	ldir
	ld	hl, 22
	ld	(ix - 3), hl
	ld	a, (ix + 9)
	scf
	sbc	hl, hl
	ld	de, (ix - 9)
	jp	.LBB1_12
	.local	.LBB1_6
.LBB1_6:
	ld	(ix - 9), bc
	push	bc
	pop	hl
	dec	hl
	ld	bc, 41
	ld	(ix - 3), hl
	call	__imulu
	ex	de, hl
	add	iy, de
	push	iy
	call	_strlen
	pop	de
	ld	de, 39
	ld	(ix - 6), hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	a, (ix + 9)
	jp	m, .LBB1_10
; %bb.7:
	ld	de, 23
	ld	bc, (ix - 9)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	hl
	push	bc
	pop	de
	ld	iy, 1
	jp	m, .LBB1_9
; %bb.8:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	a, (ix + 9)
	ld	hl, _chat+902
	push	hl
	pop	de
	inc	de
	ld	bc, 40
	ldir
	ld	de, (ix - 9)
	scf
	sbc	hl, hl
	push	hl
	pop	iy
	ld	hl, 22
	.local	.LBB1_9
.LBB1_9:                                ; %._crit_edge
	ld	bc, 0
	ld	(ix - 6), bc
	add	iy, de
	ld	(ix - 9), iy
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	hl, _chat
	push	hl
	pop	iy
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 39
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 40), a
	ld	hl, (ix - 9)
	dec	hl
	ld	(ix - 3), hl
	.local	.LBB1_10
.LBB1_10:
	ld	bc, 41
	ld	hl, (ix - 3)
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	de, (ix - 6)
	add	iy, de
	ld	l, (ix + 6)
	ld	(iy), l
	ld	(iy + 1), b
	jr	.LBB1_13
	.local	.LBB1_11
.LBB1_11:
	ld	hl, 1
	ld	(ix - 3), bc
	ld	a, (ix + 9)
	push	bc
	pop	de
	.local	.LBB1_12
.LBB1_12:
	add	hl, de
	ld	(_chat_count), hl
	ld	bc, 41
	ld	hl, (ix - 3)
	call	__imulu
	ex	de, hl
	lea	hl, iy + 0
	add	hl, de
	ld	(hl), b
	push	hl
	pop	iy
	inc	iy
	ld	bc, 39
	lea	de, iy + 0
	ldir
	.local	.LBB1_13
.LBB1_13:
	ld	bc, 41
	ld	hl, (ix - 3)
	call	__imulu
	ex	de, hl
	ld	hl, _chat
	push	hl
	pop	iy
	add	iy, de
	ld	(iy + 40), a
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_append_chat_char, .Lfunc_end1-_append_chat_char
                                        ; -- End function
	.section	.text._usb_event,"ax",@progbits
	.type	_usb_event,@function            ; -- Begin function usb_event
_usb_event:                             ; @usb_event
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	de, (ix + 6)
	ld	iy, 0
	ld	bc, 12
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB2_4
; %bb.1:
	ld	hl, 8
	push	hl
	push	iy
	push	iy
	call	_usb_FindDevice
	ld	(ix - 3), hl
	pop	de
	pop	de
	pop	de
	ld	de, 129
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	pop	de
	pop	de
	ld	(_ep_in), hl
	ld	hl, 2
	push	hl
	ld	hl, (ix - 3)
	push	hl
	call	_usb_GetDeviceEndpoint
	ex	de, hl
	pop	hl
	pop	hl
	ld	(_ep_out), de
	ld	bc, (_ep_in)
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB2_3
; %bb.2:
	ld	hl, 1
	push	hl
	push	bc
	call	_usb_SetEndpointFlags
	pop	hl
	pop	hl
	ld	de, (_ep_out)
	.local	.LBB2_3
.LBB2_3:
	sbc	hl, hl
	adc	hl, de
	ld	hl, 1
	push	hl
	push	de
	call	nz, _usb_SetEndpointFlags
	pop	hl
	pop	hl
	ld	hl, _.str.4
	ld	(_status_str), hl
	call	_queue_rx
	jr	.LBB2_6
	.local	.LBB2_4
.LBB2_4:
	ld	bc, -3
	ex	de, hl
	call	__iand
	ld	de, 1
	or	a, a
	sbc	hl, de
	jr	nz, .LBB2_6
; %bb.5:
	xor	a, a
	ld	hl, _.str.5
	ld	(_ep_in), iy
	ld	(_ep_out), iy
	ld	(_rx_pending), a
	ld	(_status_str), hl
	.local	.LBB2_6
.LBB2_6:
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_usb_event, .Lfunc_end2-_usb_event
                                        ; -- End function
	.section	.text._tx_complete,"ax",@progbits
	.type	_tx_complete,@function          ; -- Begin function tx_complete
_tx_complete:                           ; @tx_complete
; %bb.0:
	call	__frameset0
	xor	a, a
	sbc	hl, hl
	ld	(_tx_busy), a
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_tx_complete, .Lfunc_end3-_tx_complete
                                        ; -- End function
	.section	.text._queue_rx,"ax",@progbits
	.type	_queue_rx,@function             ; -- Begin function queue_rx
_queue_rx:                              ; @queue_rx
; %bb.0:
	call	__frameset0
	ld	bc, 0
	ld	de, (_ep_out)
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB4_4
; %bb.1:
	ld	a, (_rx_pending)
	bit	0, a
	jr	nz, .LBB4_4
; %bb.2:
	ld	a, 1
	ld	iy, 64
	ld	hl, _rx_complete
	ld	(_rx_pending), a
	push	bc
	push	hl
	push	iy
	ld	hl, _rx_pkt
	push	hl
	push	de
	call	_usb_ScheduleTransfer
	pop	de
	pop	de
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB4_4
; %bb.3:
	xor	a, a
	ld	(_rx_pending), a
	.local	.LBB4_4
.LBB4_4:
	pop	ix
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_queue_rx, .Lfunc_end4-_queue_rx
                                        ; -- End function
	.section	.text._rx_complete,"ax",@progbits
	.type	_rx_complete,@function          ; -- Begin function rx_complete
_rx_complete:                           ; @rx_complete
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	hl, (ix + 9)
	ld	iy, 0
	ld	b, iyh
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB5_28
; %bb.1:
	ld	hl, (ix + 12)
	ld	de, 8
	or	a, a
	sbc	hl, de
	jp	c, .LBB5_28
; %bb.2:
	ld	a, (_rx_pkt)
	ld	h, a
	ld	a, (_rx_pkt+1)
	ld	c, a
	ld	a, (_rx_pkt+2)
	ld	e, a
	ld	a, (_rx_pkt+3)
	ld	l, a
	ld	a, h
	cp	a, 67
	jp	nz, .LBB5_28
; %bb.3:
	ld	a, c
	cp	a, 71
	jp	nz, .LBB5_28
; %bb.4:
	ld	a, e
	cp	a, 80
	jp	nz, .LBB5_28
; %bb.5:
	ld	a, l
	cp	a, 84
	jp	nz, .LBB5_28
; %bb.6:
	ld	hl, _rx_pkt+6
	ld	a, (_rx_pkt+4)
	ld	hl, (hl)
	ld	(ix - 3), hl
	ld.sis	de, 56
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	ld	hl, (ix - 3)
                                        ; kill: def $hl killed $hl killed $uhl
	jr	c, .LBB5_8
; %bb.7:
	ld.sis	hl, 56
	.local	.LBB5_8
.LBB5_8:
	ld	(ix - 6), l
	ld	(ix - 5), h
	ld	l, -16
	add	a, l
	ld	l, a
	cp	a, 5
	jp	nc, .LBB5_28
; %bb.9:
	ld	bc, _chat+902
	lea	de, iy + 0
	ld	e, l
	ld	hl, JTI5_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB5_10
.LBB5_10:
	ld	hl, _.str.6
	jr	.LBB5_13
	.local	.LBB5_11
.LBB5_11:
	ld	hl, _.str.8
	ld	(_status_str), hl
	jp	.LBB5_27
	.local	.LBB5_12
.LBB5_12:
	ld	hl, _.str.8
	.local	.LBB5_13
.LBB5_13:
	ld	(_status_str), hl
	ld	hl, (_chat_count)
	ld	de, 1
	ld	(ix - 3), hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	b, d
	jp	m, .LBB5_28
; %bb.14:
	ld	de, (ix - 3)
	dec	de
	ld	bc, 41
	ex	de, hl
	call	__imulu
	ex	de, hl
	ld	hl, _chat
	add	hl, de
	ld	a, (hl)
	or	a, a
	jp	z, .LBB5_28
; %bb.15:
	ld	de, 23
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	push	bc
	pop	hl
	ld	iy, 1
	jr	c, .LBB5_17
; %bb.16:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	hl, _chat+902
	push	hl
	pop	de
	inc	de
	ld	bc, 40
	ldir
	ld	bc, (ix - 3)
	scf
	sbc	hl, hl
	push	hl
	pop	iy
	ld	hl, 22
	.local	.LBB5_17
.LBB5_17:                               ; %._crit_edge4
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 39
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 40), 2
	jp	.LBB5_27
	.local	.LBB5_18
.LBB5_18:
	ld	hl, _.str.9
	ld	(_status_str), hl
	ld	iy, (_chat_count)
	ld	de, 23
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	inc	bc
	ld	(ix - 12), bc
	ld	bc, 1
	ld	(ix - 9), iy
	lea	hl, iy + 0
	jp	m, .LBB5_20
; %bb.19:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	bc, 40
	ld	de, (ix - 12)
	ld	hl, _chat+902
	ldir
	scf
	sbc	hl, hl
	push	hl
	pop	bc
	ld	hl, 22
	.local	.LBB5_20
.LBB5_20:
	ld	de, (ix - 9)
	push	bc
	pop	iy
	add	iy, de
	ld	(ix - 15), iy
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 9), iy
	ld	hl, (ix - 9)
	inc	hl
	ld	(ix - 9), hl
	ld	bc, 39
	ld	de, (ix - 9)
	lea	hl, iy + 0
	ldir
	ld	(iy + 40), 3
	ld	hl, (ix - 3)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	bc, (ix - 15)
	jr	z, .LBB5_24
; %bb.21:
	ld	de, 0
	ld	l, (ix - 6)
	ld	h, (ix - 5)
	ld	e, l
	ld	d, h
	ld	iy, _rx_pkt+8
	.local	.LBB5_22
.LBB5_22:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 6), de
	ld	(ix - 3), iy
	ld	a, (iy)
	ld	hl, 3
	push	hl
	ld	l, a
	push	hl
	call	_append_chat_char
	ld	de, (ix - 6)
	ld	iy, (ix - 3)
	pop	hl
	pop	hl
	inc	iy
	dec	de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB5_22
; %bb.23:
	ld	bc, (_chat_count)
	.local	.LBB5_24
.LBB5_24:
	push	bc
	pop	hl
	ld	de, 23
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	hl
	ld	iy, 1
	jp	m, .LBB5_26
; %bb.25:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+902), a
	ld	bc, 40
	ld	de, (ix - 12)
	ld	hl, _chat+902
	ldir
	ld	bc, (ix - 3)
	scf
	sbc	hl, hl
	push	hl
	pop	iy
	ld	hl, 22
	.local	.LBB5_26
.LBB5_26:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 39
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 40), 3
	.local	.LBB5_27
.LBB5_27:                               ; %.loopexit
	ld	b, 0
	.local	.LBB5_28
.LBB5_28:                               ; %.loopexit
	ld	a, b
	ld	(_rx_pending), a
	call	_queue_rx
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB5_29
.LBB5_29:
	ld	de, _rx_pkt+8
	ld	hl, _.str.7
	ld	(_status_str), hl
	ld	hl, (ix - 3)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	b, 0
	jr	z, .LBB5_28
; %bb.30:
	ld	bc, 0
	ld	l, (ix - 6)
	ld	h, (ix - 5)
	ld	c, l
	ld	b, h
	ld	(ix - 6), bc
	.local	.LBB5_31
.LBB5_31:                               ; =>This Inner Loop Header: Depth=1
	ex	de, hl
	ld	(ix - 3), hl
	ld	a, (hl)
	ld	hl, 2
	push	hl
	ld	l, a
	push	hl
	call	_append_chat_char
	ld	b, 0
	pop	hl
	pop	hl
	ld	de, (ix - 3)
	inc	de
	ld	hl, (ix - 6)
	dec	hl
	ld	(ix - 6), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB5_31
	jr	.LBB5_28
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_rx_complete, .Lfunc_end5-_rx_complete
	.section	.rodata._rx_complete,"a",@progbits
JTI5_0:
	d24	.LBB5_10
	d24	.LBB5_29
	d24	.LBB5_12
	d24	.LBB5_18
	d24	.LBB5_11
                                        ; -- End function
	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"CalcGPT Gemini v1.0"

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"Connect USB cable to host."

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"ALPHA: toggle A/a/1 | ENTER: send"

	.section	.rodata._descriptors,"a",@progbits
	.balign	1
	.local	_descriptors
_descriptors:
	d24	_device
	d24	_configs
	d24	_lang
	db	1                               ; 0x1
	d24	_strings

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"USB Init Failed!"

	.section	.bss._typing_mode,"aw",@nobits
	.balign	1
	.local	_typing_mode
_typing_mode:
	.zero	3

	.section	.bss._input_len,"aw",@nobits
	.balign	1
	.local	_input_len
_input_len:
	.zero	3

	.section	.bss._input_buf,"aw",@nobits
	.balign	1
	.local	_input_buf
_input_buf:
	.zero	129

	.section	.bss._chat_count,"aw",@nobits
	.balign	1
	.local	_chat_count
_chat_count:
	.zero	3

	.section	.bss._chat,"aw",@nobits
	.balign	1
	.local	_chat
_chat:
	.zero	943

	.section	.bss._ep_in,"aw",@nobits
	.balign	1
	.local	_ep_in
_ep_in:
	.zero	3

	.section	.bss._ep_out,"aw",@nobits
	.balign	1
	.local	_ep_out
_ep_out:
	.zero	3

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"Connected to host"

	.section	.data._status_str,"aw",@progbits
	.balign	1
	.local	_status_str
_status_str:
	d24	_.str.5

	.section	.bss._rx_pending,"aw",@nobits
	.balign	1
	.local	_rx_pending
_rx_pending:
	.zero	1

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"Waiting for USB link\342\200\246"

	.section	.bss._rx_pkt,"aw",@nobits
	.balign	1
	.local	_rx_pkt
_rx_pkt:
	.zero	64

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"Gemini typing\342\200\246"

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"Receiving stream\342\200\246"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"Online (Ready)"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"Gemini Error"

	.section	.data._device,"aw",@progbits
	.balign	2
	.local	_device
_device:
	db	18                              ; 0x12
	db	1                               ; 0x1
	dw	512                             ; 0x200
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	64                              ; 0x40
	dw	1105                            ; 0x451
	dw	57352                           ; 0xe008
	dw	256                             ; 0x100
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	1                               ; 0x1

	.section	.data._configs,"aw",@progbits
	.balign	1
	.local	_configs
_configs:
	d24	_configuration_bytes

	.section	.data._strings,"aw",@progbits
	.balign	1
	.local	_strings
_strings:
	d24	_product

	.section	.rodata._configuration_bytes,"a",@progbits
	.balign	1
	.local	_configuration_bytes
_configuration_bytes:
	.asciz	"\t\002 \000\001\001\000\2002\t\004\000\000\002\377D\002\000\007\005\201\002@\000\000\007\005\002\002@\000"

	.section	.rodata._lang,"a",@progbits
	.balign	2
	.local	_lang
_lang:
	db	4                               ; 0x4
	db	3                               ; 0x3
	dw	1033                            ; 0x409

	.section	.rodata._product,"a",@progbits
	.balign	2
	.local	_product
_product:
	db	30                              ; 0x1e
	db	3                               ; 0x3
	dw	67                              ; 0x43
	dw	97                              ; 0x61
	dw	108                             ; 0x6c
	dw	99                              ; 0x63
	dw	71                              ; 0x47
	dw	80                              ; 0x50
	dw	84                              ; 0x54
	dw	32                              ; 0x20
	dw	71                              ; 0x47
	dw	101                             ; 0x65
	dw	109                             ; 0x6d
	dw	105                             ; 0x69
	dw	110                             ; 0x6e
	dw	105                             ; 0x69
	dw	0                               ; 0x0

	.section	.bss._tx_busy,"aw",@nobits
	.balign	1
	.local	_tx_busy
_tx_busy:
	.zero	1

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"> "

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"Sending prompt\342\200\246"

	.section	.bss._tx_pkt,"aw",@nobits
	.balign	1
	.local	_tx_pkt
_tx_pkt:
	.zero	64

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"USB Tx error"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"CalcGPT"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"| "

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"[A] > "

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"[a] > "

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"[1] > "

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_usb_Cleanup
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_usb_HandleEvents
	.extern	_gfx_PrintString
	.extern	_gfx_FillRectangle
	.extern	__iremu
	.extern	_llvm.memmove.p0.p0.i24
	.extern	_memcpy
	.extern	_gfx_SetPalette
	.extern	__ishru
	.extern	_llvm.eh.sjlj.lsda
	.extern	_usb_GetDeviceEndpoint
	.extern	__Unwind_SjLj_Unregister
	.extern	_gfx_FillScreen
	.extern	_strlen
	.extern	_memmove
	.extern	__frameset
	.extern	_usb_FindDevice
	.extern	_memset
	.extern	__iand
	.extern	__imulu
	.extern	_usb_Init
	.extern	__setflag
	.extern	_usb_ScheduleTransfer
	.extern	_gfx_PrintStringXY
	.extern	_llvm.memset.p0.i64
	.extern	_llvm.memset.p0.i24
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_gfx_SetColor
	.extern	_os_GetCSC
	.extern	_llvm.eh.sjlj.callsite
	.extern	_gfx_End
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.stacksave.p0
	.extern	__frameset0
	.extern	_llvm.umin.i16
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.frameaddress.p0
	.extern	_llvm.stackrestore.p0
	.extern	_gfx_Blit
	.extern	_gfx_HorizLine
	.extern	_gfx_SetDraw
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_PrintChar
	.extern	_gfx_Begin
	.extern	_usb_SetEndpointFlags
