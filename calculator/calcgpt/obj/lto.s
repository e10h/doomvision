	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -52
	call	__frameset
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
	ld	hl, 3
	push	hl
	ld	hl, _.str
	push	hl
	call	_append_chat_line
	pop	hl
	pop	hl
	ld	hl, 4
	push	hl
	ld	hl, _.str.1
	push	hl
	call	_append_chat_line
	pop	hl
	pop	hl
	ld	hl, 4
	push	hl
	ld	hl, _.str.2
	push	hl
	call	_append_chat_line
	pop	hl
	pop	hl
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
	jp	nz, .LBB0_91
; %bb.1:
	lea	hl, ix - 40
	ld	(ix - 52), hl
	.local	.LBB0_2
.LBB0_2:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_35 Depth 2
	call	_usb_HandleEvents
	call	_os_GetCSC
	ld	c, a
	cp	a, 48
	call	pe, __setflag
	jp	p, .LBB0_15
; %bb.3:                                ;   in Loop: Header=BB0_2 Depth=1
	or	a, a
	jp	z, .LBB0_33
; %bb.4:                                ;   in Loop: Header=BB0_2 Depth=1
	ld	a, c
	cp	a, 9
	jp	nz, .LBB0_21
; %bb.5:                                ;   in Loop: Header=BB0_2 Depth=1
	ld	hl, (_input_len)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB0_33
; %bb.6:                                ;   in Loop: Header=BB0_2 Depth=1
	ld	hl, (_ep_in)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB0_33
; %bb.7:                                ;   in Loop: Header=BB0_2 Depth=1
	ld	a, (_tx_busy)
	bit	0, a
	jp	nz, .LBB0_33
; %bb.8:                                ;   in Loop: Header=BB0_2 Depth=1
	ld	(ix - 40), 62
	ld	(ix - 39), 32
	ld	hl, 37
	push	hl
	ld	hl, _input_buf
	push	hl
	ld	iy, (ix - 52)
	pea	iy + 2
	call	_strncpy
	pop	hl
	pop	hl
	pop	hl
	ld	(ix - 1), 0
	ld	hl, 1
	push	hl
	ld	hl, (ix - 52)
	push	hl
	call	_append_chat_line
	pop	hl
	pop	hl
	ld	hl, _.str.12
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
	jr	c, .LBB0_10
; %bb.9:                                ;   in Loop: Header=BB0_2 Depth=1
	ld.sis	hl, 56
	ex.sis	de, hl
	.local	.LBB0_10
.LBB0_10:                               ;   in Loop: Header=BB0_2 Depth=1
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
	jp	z, .LBB0_12
; %bb.11:                               ;   in Loop: Header=BB0_2 Depth=1
	push	de
	ld	hl, _input_buf
	push	hl
	ld	hl, _tx_pkt+8
	push	hl
	ld	(ix - 46), bc
	ld	(ix - 43), de
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 46)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 56
	or	a, a
	sbc.sis	hl, de
	ld	de, (ix - 43)
	jr	nc, .LBB0_13
	.local	.LBB0_12
.LBB0_12:                               ;   in Loop: Header=BB0_2 Depth=1
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
	.local	.LBB0_13
.LBB0_13:                               ;   in Loop: Header=BB0_2 Depth=1
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
	jr	z, .LBB0_22
; %bb.14:                               ;   in Loop: Header=BB0_2 Depth=1
	xor	a, a
	ld	(_tx_busy), a
	ld	hl, _.str.13
	ld	(_status_str), hl
	jr	.LBB0_22
	.local	.LBB0_15
.LBB0_15:                               ;   in Loop: Header=BB0_2 Depth=1
	cp	a, 48
	jr	nz, .LBB0_17
; %bb.16:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	hl, (_typing_mode)
	inc	hl
	ld	bc, 3
	call	__iremu
	ld	(_typing_mode), hl
	jp	.LBB0_33
	.local	.LBB0_17
.LBB0_17:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, c
	cp	a, 55
	jp	z, .LBB0_94
; %bb.18:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, c
	cp	a, 56
	jr	nz, .LBB0_23
; %bb.19:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	de, (_input_len)
	push	de
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_33
; %bb.20:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	iy, _input_buf
	add	iy, de
	dec	de
	ld	(_input_len), de
	ld	(iy - 1), 0
	jp	.LBB0_33
	.local	.LBB0_21
.LBB0_21:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, c
	cp	a, 15
	jr	nz, .LBB0_23
	.local	.LBB0_22
.LBB0_22:                               ;   in Loop: Header=BB0_2 Depth=1
	or	a, a
	sbc	hl, hl
	ld	(_input_len), hl
	xor	a, a
	ld	(_input_buf), a
	jp	.LBB0_33
	.local	.LBB0_23
.LBB0_23:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	iy, (_typing_mode)
	lea	hl, iy + 0
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB0_32
; %bb.24:                               ;   in Loop: Header=BB0_2 Depth=1
	lea	de, iy + 0
	ld	l, -11
	ld	a, c
	add	a, l
	ld	l, a
	cp	a, 37
	ld	a, 0
	ld	b, a
	ld	c, a
	jp	c, .LBB0_43
	.local	.LBB0_25
.LBB0_25:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	iyl, b
	ld	b, a
	ex	de, hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	z, .LBB0_27
; %bb.26:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 0
	.local	.LBB0_27
.LBB0_27:                               ;   in Loop: Header=BB0_2 Depth=1
	and	a, b
	ld	l, a
	ld	e, iyl
	ld	a, l
	and	a, e
	ld	l, a
	bit	0, l
	jr	z, .LBB0_29
; %bb.28:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	l, 32
	ld	a, c
	add	a, l
	ld	c, a
	.local	.LBB0_29
.LBB0_29:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, c
	or	a, a
	jr	z, .LBB0_33
; %bb.30:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	de, (_input_len)
	push	de
	pop	hl
	ld	a, c
	ld	bc, 128
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB0_33
; %bb.31:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	iy, _input_buf
	add	iy, de
	inc	de
	ld	(_input_len), de
	ld	(iy), a
	ld	(iy + 1), 0
	jr	.LBB0_33
	.local	.LBB0_32
.LBB0_32:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	l, -10
	ld	a, c
	add	a, l
	ld	l, a
	cp	a, 28
	jp	c, .LBB0_45
	.local	.LBB0_33
.LBB0_33:                               ;   in Loop: Header=BB0_2 Depth=1
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
	ld	hl, _.str.14
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
	ld	hl, _.str.15
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
	jp	m, .LBB0_38
; %bb.34:                               ; %.preheader.preheader
                                        ;   in Loop: Header=BB0_2 Depth=1
	ld	hl, _chat
	ld	(ix - 43), hl
	ld	hl, 22
	ld	(ix - 46), hl
	ld	de, 0
	.local	.LBB0_35
.LBB0_35:                               ; %.preheader
                                        ;   Parent Loop BB0_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 49), de
	ld	hl, (ix - 46)
	ld	iy, (ix - 43)
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
	jr	c, .LBB0_37
; %bb.36:                               ; %.preheader
                                        ;   in Loop: Header=BB0_35 Depth=2
	ld	a, 7
	ld	l, a
	.local	.LBB0_37
.LBB0_37:                               ; %.preheader
                                        ;   in Loop: Header=BB0_35 Depth=2
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, (ix - 46)
	push	hl
	ld	hl, 6
	push	hl
	ld	hl, (ix - 43)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 49)
	inc	hl
	ld	bc, (_chat_count)
	ld	(ix - 49), bc
	ld	bc, 8
	ld	iy, (ix - 46)
	add	iy, bc
	ld	(ix - 46), iy
	ld	iy, (ix - 43)
	lea	iy, iy + 41
	ld	(ix - 43), iy
	push	hl
	pop	de
	ld	bc, (ix - 49)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_35
	.local	.LBB0_38
.LBB0_38:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_2 Depth=1
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
	ld	bc, _.str.17
	jr	z, .LBB0_40
; %bb.39:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_2 Depth=1
	ld	bc, _.str.18
	.local	.LBB0_40
.LBB0_40:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_2 Depth=1
	sbc	hl, hl
	adc	hl, de
	ld	hl, _.str.16
	ld	de, 6
	jr	z, .LBB0_42
; %bb.41:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_2 Depth=1
	push	bc
	pop	hl
	.local	.LBB0_42
.LBB0_42:                               ; %.loopexit
                                        ;   in Loop: Header=BB0_2 Depth=1
	ld	bc, 226
	push	bc
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
	jp	.LBB0_2
	.local	.LBB0_43
.LBB0_43:                               ;   in Loop: Header=BB0_2 Depth=1
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
	.local	.LBB0_44
.LBB0_44:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 87
	jp	.LBB0_25
	.local	.LBB0_45
.LBB0_45:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	de, 0
	ld	e, l
	ld	hl, JTI0_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	ld	c, 48
	jp	(hl)
	.local	.LBB0_46
.LBB0_46:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 43
	jp	.LBB0_29
	.local	.LBB0_47
.LBB0_47:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 52
	jp	.LBB0_29
	.local	.LBB0_48
.LBB0_48:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 40
	jp	.LBB0_29
	.local	.LBB0_49
.LBB0_49:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 50
	jp	.LBB0_29
	.local	.LBB0_50
.LBB0_50:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 42
	jp	.LBB0_29
	.local	.LBB0_51
.LBB0_51:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 53
	jp	.LBB0_29
	.local	.LBB0_52
.LBB0_52:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 41
	jp	.LBB0_29
	.local	.LBB0_53
.LBB0_53:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 49
	jp	.LBB0_29
	.local	.LBB0_54
.LBB0_54:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 45
	jp	.LBB0_29
	.local	.LBB0_55
.LBB0_55:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 54
	jp	.LBB0_29
	.local	.LBB0_56
.LBB0_56:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 55
	jp	.LBB0_29
	.local	.LBB0_57
.LBB0_57:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 47
	jp	.LBB0_29
	.local	.LBB0_58
.LBB0_58:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 56
	jp	.LBB0_29
	.local	.LBB0_59
.LBB0_59:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 51
	jp	.LBB0_29
	.local	.LBB0_60
.LBB0_60:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 44
	jp	.LBB0_29
	.local	.LBB0_61
.LBB0_61:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 46
	jp	.LBB0_29
	.local	.LBB0_62
.LBB0_62:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	c, 57
	jp	.LBB0_29
	.local	.LBB0_63
.LBB0_63:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 73
	jp	.LBB0_25
	.local	.LBB0_64
.LBB0_64:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 67
	jp	.LBB0_25
	.local	.LBB0_65
.LBB0_65:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 75
	jp	.LBB0_25
	.local	.LBB0_66
.LBB0_66:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 90
	jp	.LBB0_25
	.local	.LBB0_67
.LBB0_67:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 72
	jp	.LBB0_25
	.local	.LBB0_68
.LBB0_68:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 85
	jp	.LBB0_25
	.local	.LBB0_69
.LBB0_69:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 71
	jp	.LBB0_25
	.local	.LBB0_70
.LBB0_70:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 83
	jp	.LBB0_25
	.local	.LBB0_71
.LBB0_71:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 88
	jp	.LBB0_25
	.local	.LBB0_72
.LBB0_72:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 82
	jp	.LBB0_25
	.local	.LBB0_73
.LBB0_73:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 70
	jp	.LBB0_25
	.local	.LBB0_74
.LBB0_74:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 77
	jp	.LBB0_25
	.local	.LBB0_75
.LBB0_75:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 81
	jp	.LBB0_25
	.local	.LBB0_76
.LBB0_76:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, 0
	ld	c, 32
	jp	.LBB0_25
	.local	.LBB0_77
.LBB0_77:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 79
	jp	.LBB0_25
	.local	.LBB0_78
.LBB0_78:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, 0
	ld	c, 63
	jp	.LBB0_25
	.local	.LBB0_79
.LBB0_79:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 74
	jp	.LBB0_25
	.local	.LBB0_80
.LBB0_80:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 80
	jp	.LBB0_25
	.local	.LBB0_81
.LBB0_81:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 86
	jp	.LBB0_25
	.local	.LBB0_82
.LBB0_82:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 89
	jp	.LBB0_25
	.local	.LBB0_83
.LBB0_83:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, 0
	ld	c, 46
	jp	.LBB0_25
	.local	.LBB0_84
.LBB0_84:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 76
	jp	.LBB0_25
	.local	.LBB0_85
.LBB0_85:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 69
	jp	.LBB0_25
	.local	.LBB0_86
.LBB0_86:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 84
	jp	.LBB0_25
	.local	.LBB0_87
.LBB0_87:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 66
	jp	.LBB0_25
	.local	.LBB0_88
.LBB0_88:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 68
	jp	.LBB0_25
	.local	.LBB0_89
.LBB0_89:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 65
	jp	.LBB0_25
	.local	.LBB0_90
.LBB0_90:                               ;   in Loop: Header=BB0_2 Depth=1
	ld	a, 1
	ld	b, a
	ld	c, 78
	jp	.LBB0_25
	.local	.LBB0_91
.LBB0_91:
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
	.local	.LBB0_92
.LBB0_92:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB0_92
; %bb.93:
	call	_gfx_End
	ld	hl, 1
	jr	.LBB0_95
	.local	.LBB0_94
.LBB0_94:
	call	_usb_Cleanup
	call	_gfx_End
	or	a, a
	sbc	hl, hl
	.local	.LBB0_95
.LBB0_95:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_main, .Lfunc_end0-_main
	.section	.rodata._main,"a",@progbits
JTI0_0:
	d24	.LBB0_46
	d24	.LBB0_54
	d24	.LBB0_50
	d24	.LBB0_57
	d24	.LBB0_33
	d24	.LBB0_33
	d24	.LBB0_33
	d24	.LBB0_33
	d24	.LBB0_59
	d24	.LBB0_55
	d24	.LBB0_62
	d24	.LBB0_52
	d24	.LBB0_33
	d24	.LBB0_33
	d24	.LBB0_33
	d24	.LBB0_61
	d24	.LBB0_49
	d24	.LBB0_51
	d24	.LBB0_58
	d24	.LBB0_48
	d24	.LBB0_33
	d24	.LBB0_33
	d24	.LBB0_33
	d24	.LBB0_29
	d24	.LBB0_53
	d24	.LBB0_47
	d24	.LBB0_56
	d24	.LBB0_60
JTI0_1:
	d24	.LBB0_44
	d24	.LBB0_72
	d24	.LBB0_74
	d24	.LBB0_67
	d24	.LBB0_25
	d24	.LBB0_25
	d24	.LBB0_78
	d24	.LBB0_25
	d24	.LBB0_81
	d24	.LBB0_75
	d24	.LBB0_84
	d24	.LBB0_69
	d24	.LBB0_25
	d24	.LBB0_25
	d24	.LBB0_83
	d24	.LBB0_66
	d24	.LBB0_68
	d24	.LBB0_80
	d24	.LBB0_65
	d24	.LBB0_73
	d24	.LBB0_64
	d24	.LBB0_25
	d24	.LBB0_76
	d24	.LBB0_82
	d24	.LBB0_86
	d24	.LBB0_77
	d24	.LBB0_79
	d24	.LBB0_85
	d24	.LBB0_87
	d24	.LBB0_25
	d24	.LBB0_25
	d24	.LBB0_71
	d24	.LBB0_70
	d24	.LBB0_90
	d24	.LBB0_63
	d24	.LBB0_88
	d24	.LBB0_89
                                        ; -- End function
	.section	.text._append_chat_line,"ax",@progbits
	.type	_append_chat_line,@function     ; -- Begin function append_chat_line
_append_chat_line:                      ; @append_chat_line
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	iy, (_chat_count)
	ld	de, 23
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB1_2
; %bb.1:
	ld	hl, _chat+41
	ld	de, 902
	push	de
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), iy
	call	_memmove
	ld	iy, (ix - 3)
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
	dec	iy
	.local	.LBB1_2
.LBB1_2:
	ld	(ix - 3), iy
	ld	bc, 41
	lea	hl, iy + 0
	call	__imulu
	ex	de, hl
	ld	hl, _chat
	add	hl, de
	ex	de, hl
	ld	(ix - 6), de
	ld	hl, 39
	push	hl
	ld	hl, (ix + 6)
	push	hl
	push	de
	call	_strncpy
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix - 6)
	ld	(iy + 39), 0
	ld	a, (ix + 9)
	ld	(iy + 40), a
	ld	hl, (ix - 3)
	inc	hl
	ld	(_chat_count), hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_append_chat_line, .Lfunc_end1-_append_chat_line
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
	ld	b, 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB5_41
; %bb.1:
	ld	hl, (ix + 12)
	ld	de, 8
	or	a, a
	sbc	hl, de
	jp	c, .LBB5_41
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
	jp	nz, .LBB5_41
; %bb.3:
	ld	a, c
	cp	a, 71
	jp	nz, .LBB5_41
; %bb.4:
	ld	a, e
	cp	a, 80
	jp	nz, .LBB5_41
; %bb.5:
	ld	a, l
	cp	a, 84
	jp	nz, .LBB5_41
; %bb.6:
	ld	hl, _rx_pkt+6
	ld	a, (_rx_pkt+4)
	ld	iy, (hl)
	ld.sis	de, 56
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, de
	ld	(ix - 3), iy
	ld	e, iyl
	ld	d, iyh
	jr	c, .LBB5_8
; %bb.7:
	ld.sis	de, 56
	.local	.LBB5_8
.LBB5_8:
	ld	l, -16
	add	a, l
	ld	l, a
	cp	a, 5
	jp	nc, .LBB5_41
; %bb.9:
	ld	(ix - 6), e
	ld	(ix - 5), d
	ld	iy, 902
	ld	de, 0
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
	jr	.LBB5_12
	.local	.LBB5_11
.LBB5_11:
	ld	hl, _.str.8
	.local	.LBB5_12
.LBB5_12:                               ; %.loopexit
	ld	(_status_str), hl
	jp	.LBB5_41
	.local	.LBB5_13
.LBB5_13:
	ld	hl, _.str.8
	ld	(_status_str), hl
	ld	de, (_chat_count)
	sbc	hl, hl
	adc	hl, de
	jp	nz, .LBB5_20
; %bb.14:
	ld	a, b
	ld	(_chat), a
	ld	iy, _chat
	lea	hl, iy + 0
	inc	hl
	ld	bc, 39
	ex	de, hl
	lea	hl, iy + 0
	ldir
	ld	a, 2
	ld	(_chat+40), a
	ld	hl, 1
	push	hl
	pop	de
	jp	.LBB5_25
	.local	.LBB5_15
.LBB5_15:
	ld	hl, _.str.9
	ld	(_status_str), hl
	ld	de, (_chat_count)
	ld	(ix - 9), de
	sbc	hl, hl
	adc	hl, de
	ld	iy, _chat
	lea	de, iy + 0
	inc	de
	ld	(ix - 15), de
	jp	nz, .LBB5_22
; %bb.16:
	ld	a, b
	ld	(_chat), a
	ld	bc, 39
	lea	hl, iy + 0
	ldir
	ld	a, 3
	ld	(_chat+40), a
	ld	hl, 1
	push	hl
	pop	iy
	jp	.LBB5_28
	.local	.LBB5_17
.LBB5_17:
	ld	hl, _.str.7
	ld	(_status_str), hl
	ld	hl, (ix - 3)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	iy, _rx_pkt+8
	ld	l, (ix - 6)
	ld	h, (ix - 5)
	jp	z, .LBB5_41
; %bb.18:
	ld	de, 0
	ld	e, l
	ld	d, h
	.local	.LBB5_19
.LBB5_19:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 6), de
	ld	(ix - 3), iy
	ld	a, (iy)
	ld	hl, 2
	push	hl
	ld	l, a
	push	hl
	call	_append_chat_char
	ld	de, (ix - 6)
	ld	iy, (ix - 3)
	ld	b, 0
	pop	hl
	pop	hl
	inc	iy
	dec	de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB5_19
	jp	.LBB5_41
	.local	.LBB5_20
.LBB5_20:
	ex	de, hl
	ld	de, 23
	ld	(ix - 3), hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB5_24
; %bb.21:
	push	iy
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
	ld	de, (ix - 3)
	dec	de
	ld	hl, 22
	jr	.LBB5_26
	.local	.LBB5_22
.LBB5_22:
	ld	iy, (ix - 9)
	lea	hl, iy + 0
	ld	de, 23
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB5_27
; %bb.23:
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
	ld	iy, (ix - 9)
	dec	iy
	ld	hl, 22
	jr	.LBB5_29
	.local	.LBB5_24
.LBB5_24:
	ld	de, (ix - 3)
	push	de
	pop	hl
	.local	.LBB5_25
.LBB5_25:
	inc	de
	.local	.LBB5_26
.LBB5_26:
	ld	(_chat_count), de
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
	jp	.LBB5_40
	.local	.LBB5_27
.LBB5_27:
	lea	hl, iy + 0
	.local	.LBB5_28
.LBB5_28:
	inc	iy
	.local	.LBB5_29
.LBB5_29:
	ld	(ix - 9), iy
	ld	(_chat_count), iy
	ld	bc, 41
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 12), iy
	ld	hl, (ix - 12)
	inc	hl
	ld	(ix - 12), hl
	ld	bc, 39
	ld	de, (ix - 12)
	lea	hl, iy + 0
	ldir
	ld	de, (ix - 9)
	ld	(iy + 40), 3
	ld	hl, (ix - 3)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB5_33
; %bb.30:
	ld	de, 0
	ld	l, (ix - 6)
	ld	h, (ix - 5)
	ld	e, l
	ld	d, h
	ld	iy, _rx_pkt+8
	.local	.LBB5_31
.LBB5_31:                               ; =>This Inner Loop Header: Depth=1
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
	jr	nz, .LBB5_31
; %bb.32:
	ld	de, (_chat_count)
	.local	.LBB5_33
.LBB5_33:
	sbc	hl, hl
	adc	hl, de
	ld	a, 0
	jr	nz, .LBB5_35
; %bb.34:
	ld	(_chat), a
	ld	bc, 39
	ld	de, (ix - 15)
	ld	iy, _chat
	lea	hl, iy + 0
	ldir
	ld	a, 3
	ld	(_chat+40), a
	ld	hl, 1
	push	hl
	pop	de
	jr	.LBB5_38
	.local	.LBB5_35
.LBB5_35:
	push	de
	pop	hl
	ld	bc, 23
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	iy, _chat
	jp	m, .LBB5_37
; %bb.36:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	push	iy
	ld	(ix - 9), de
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
	ld	de, (ix - 9)
	dec	de
	ld	hl, 22
	jr	.LBB5_39
	.local	.LBB5_37
.LBB5_37:
	push	de
	pop	hl
	.local	.LBB5_38
.LBB5_38:
	inc	de
	.local	.LBB5_39
.LBB5_39:
	ld	(_chat_count), de
	ld	bc, 41
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	(iy), b
	lea	hl, iy + 0
	inc	iy
	ld	bc, 39
	lea	de, iy + 0
	push	hl
	pop	iy
	ldir
	ld	(iy + 40), 3
	.local	.LBB5_40
.LBB5_40:                               ; %.loopexit
	ld	b, 0
	.local	.LBB5_41
.LBB5_41:                               ; %.loopexit
	ld	a, b
	ld	(_rx_pending), a
	call	_queue_rx
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_rx_complete, .Lfunc_end5-_rx_complete
	.section	.rodata._rx_complete,"a",@progbits
JTI5_0:
	d24	.LBB5_10
	d24	.LBB5_17
	d24	.LBB5_13
	d24	.LBB5_15
	d24	.LBB5_11
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
	jr	nz, .LBB6_2
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
	ld	e, a
	ld	hl, 1
	ld	a, (ix + 9)
	ld	(_chat+40), a
	ld	a, e
	cp	a, 10
	jr	nz, .LBB6_6
	jp	.LBB6_11
	.local	.LBB6_2
.LBB6_2:
	ld	a, e
	cp	a, 10
	jr	nz, .LBB6_5
; %bb.3:
	ld	de, 23
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB6_10
; %bb.4:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	push	iy
	ld	(ix - 3), bc
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
	ld	de, (ix - 3)
	dec	de
	ld	hl, 22
	jp	.LBB6_12
	.local	.LBB6_5
.LBB6_5:
	push	bc
	pop	hl
	.local	.LBB6_6
.LBB6_6:
	ld	(ix - 3), hl
	dec	hl
	ld	bc, 41
	ld	(ix - 6), hl
	call	__imulu
	ex	de, hl
	add	iy, de
	push	iy
	call	_strlen
	push	hl
	pop	bc
	pop	hl
	ld	de, 39
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB6_9
; %bb.7:
	ld	de, 23
	ld	hl, (ix - 3)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB6_13
; %bb.8:
	ld	hl, 902
	push	hl
	ld	hl, _chat+41
	push	hl
	ld	hl, _chat
	push	hl
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
	ld	a, (ix + 9)
	ld	de, (ix - 6)
	jr	.LBB6_14
	.local	.LBB6_9
.LBB6_9:
	ld	de, (ix - 6)
	ld	a, (ix + 9)
	ld	(ix - 6), bc
	jr	.LBB6_15
	.local	.LBB6_10
.LBB6_10:
	push	bc
	pop	hl
	.local	.LBB6_11
.LBB6_11:
	push	hl
	pop	de
	inc	de
	.local	.LBB6_12
.LBB6_12:
	ld	(_chat_count), de
	ld	bc, 41
	ld	(ix - 3), hl
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
	ld	a, (ix + 9)
	jr	.LBB6_16
	.local	.LBB6_13
.LBB6_13:
	ld	hl, (ix - 3)
	push	hl
	pop	de
	inc	de
	ld	a, (ix + 9)
	ld	iy, _chat
	.local	.LBB6_14
.LBB6_14:
	ld	(ix - 3), hl
	ld	bc, 0
	ld	(ix - 6), bc
	ld	(_chat_count), de
	ld	bc, 41
	call	__imulu
	ex	de, hl
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
	ld	de, (ix - 3)
	ld	(iy + 40), a
	.local	.LBB6_15
.LBB6_15:
	ld	bc, 41
	ld	(ix - 3), de
	ex	de, hl
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	de, (ix - 6)
	add	iy, de
	ld	l, (ix + 6)
	ld	(iy), l
	ld	(iy + 1), b
	.local	.LBB6_16
.LBB6_16:
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
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_append_chat_char, .Lfunc_end6-_append_chat_char
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
	.asciz	"Sending prompt\342\200\246"

	.section	.bss._tx_pkt,"aw",@nobits
	.balign	1
	.local	_tx_pkt
_tx_pkt:
	.zero	64

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"USB Tx error"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"CalcGPT"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"| "

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"[A] > "

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"[a] > "

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"[1] > "

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_usb_Cleanup
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_usb_HandleEvents
	.extern	_strncpy
	.extern	_gfx_PrintString
	.extern	_gfx_FillRectangle
	.extern	__iremu
	.extern	_llvm.lifetime.end.p0
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
	.extern	_llvm.lifetime.start.p0
	.extern	__frameset0
	.extern	_llvm.umin.i16
	.extern	_llvm.frameaddress.p0
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.stackrestore.p0
	.extern	_gfx_Blit
	.extern	_gfx_HorizLine
	.extern	_gfx_SetDraw
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_PrintChar
	.extern	_gfx_Begin
	.extern	_usb_SetEndpointFlags
