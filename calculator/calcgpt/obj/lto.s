	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -21
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
	ex	de, hl
	.local	.LBB0_1
.LBB0_1:                                ; =>This Inner Loop Header: Depth=1
	ld	hl, 3
	push	hl
	push	de
	call	_append_chat_char
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	a, (hl)
	ld	e, a
	inc	hl
	ld	(ix - 3), hl
	or	a, a
	jr	nz, .LBB0_1
; %bb.2:
	ld	bc, (_chat_count)
	ld	de, 35
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
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 34
	.local	.LBB0_4
.LBB0_4:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 3
	ld	hl, _.str.1+1
	push	hl
	pop	iy
	ld	hl, 83
	.local	.LBB0_5
.LBB0_5:                                ; =>This Inner Loop Header: Depth=1
	ld	(ix - 3), iy
	ld	de, 4
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
	jr	nz, .LBB0_5
; %bb.6:
	ld	bc, (_chat_count)
	push	bc
	pop	hl
	ld	de, 35
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_8
; %bb.7:
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 34
	.local	.LBB0_8
.LBB0_8:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 4
	ld	hl, _.str.2+1
	ld	de, 43
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
	ld	de, 35
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_12
; %bb.11:
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 34
	.local	.LBB0_12
.LBB0_12:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 4
	ld	hl, _.str.3+1
	ld	de, 69
	.local	.LBB0_13
.LBB0_13:                               ; =>This Inner Loop Header: Depth=1
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
	jr	nz, .LBB0_13
; %bb.14:
	ld	bc, (_chat_count)
	push	bc
	pop	hl
	ld	de, 35
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_16
; %bb.15:
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 34
	.local	.LBB0_16
.LBB0_16:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 4
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
	jp	z, .LBB0_111
; %bb.17:
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
	ld	hl, _.str.4
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_Blit
	pop	hl
	.local	.LBB0_18
.LBB0_18:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB0_18
; %bb.19:
	ld	hl, 1
	jp	.LBB0_114
	.local	.LBB0_20
.LBB0_20:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, (_input_len)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB0_79
; %bb.21:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, (_ep_in)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB0_79
; %bb.22:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	a, (_tx_busy)
	bit	0, a
	jp	nz, .LBB0_79
; %bb.23:                               ; %.preheader29.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, _.str.13+1
	push	hl
	pop	iy
	ld	hl, 62
	.local	.LBB0_24
.LBB0_24:                               ; %.preheader29
                                        ;   Parent Loop BB0_111 Depth=1
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
	jr	nz, .LBB0_24
; %bb.25:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	a, (_input_buf)
	ld	l, a
	or	a, a
	jr	z, .LBB0_28
; %bb.26:                               ; %.preheader27.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	de, _input_buf+1
	push	de
	pop	iy
	.local	.LBB0_27
.LBB0_27:                               ; %.preheader27
                                        ;   Parent Loop BB0_111 Depth=1
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
	jr	nz, .LBB0_27
	.local	.LBB0_28
.LBB0_28:                               ; %.loopexit28
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	bc, (_chat_count)
	push	bc
	pop	hl
	ld	de, 35
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, 1
	push	bc
	pop	hl
	jp	m, .LBB0_30
; %bb.29:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	bc, (ix - 3)
	ld	iy, -1
	ld	hl, 34
	.local	.LBB0_30
.LBB0_30:                               ;   in Loop: Header=BB0_111 Depth=1
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 2
	ld	hl, _.str.14
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
	ld.sis	de, 56
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	ld	e, c
	ld	d, b
	jr	c, .LBB0_32
; %bb.31:                               ;   in Loop: Header=BB0_111 Depth=1
	ld.sis	hl, 56
	ex.sis	de, hl
	.local	.LBB0_32
.LBB0_32:                               ;   in Loop: Header=BB0_111 Depth=1
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
	jp	z, .LBB0_34
; %bb.33:                               ;   in Loop: Header=BB0_111 Depth=1
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
	jr	nc, .LBB0_35
	.local	.LBB0_34
.LBB0_34:                               ;   in Loop: Header=BB0_111 Depth=1
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
	.local	.LBB0_35
.LBB0_35:                               ;   in Loop: Header=BB0_111 Depth=1
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
	jr	z, .LBB0_37
; %bb.36:                               ;   in Loop: Header=BB0_111 Depth=1
	xor	a, a
	ld	(_tx_busy), a
	ld	hl, _.str.15
	ld	(_status_str), hl
	.local	.LBB0_37
.LBB0_37:                               ;   in Loop: Header=BB0_111 Depth=1
	or	a, a
	sbc	hl, hl
	ld	(_input_len), hl
	xor	a, a
	ld	(_input_buf), a
	jp	.LBB0_79
	.local	.LBB0_38
.LBB0_38:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 76
	jp	.LBB0_73
	.local	.LBB0_39
.LBB0_39:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 79
	jp	.LBB0_73
	.local	.LBB0_40
.LBB0_40:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 84
	jp	.LBB0_73
	.local	.LBB0_41
.LBB0_41:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 80
	jp	.LBB0_73
	.local	.LBB0_42
.LBB0_42:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 65
	jp	.LBB0_73
	.local	.LBB0_43
.LBB0_43:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 78
	jp	.LBB0_73
	.local	.LBB0_44
.LBB0_44:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 1
	ld	iyl, c
	ld	b, 63
	jp	.LBB0_73
	.local	.LBB0_45
.LBB0_45:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 67
	jp	.LBB0_73
	.local	.LBB0_46
.LBB0_46:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	de, (_input_len)
	push	de
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_79
; %bb.47:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	iy, _input_buf
	add	iy, de
	dec	de
	ld	(_input_len), de
	ld	(iy - 1), 0
	jp	.LBB0_79
	.local	.LBB0_48
.LBB0_48:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 86
	jp	.LBB0_73
	.local	.LBB0_49
.LBB0_49:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 90
	jp	.LBB0_73
	.local	.LBB0_50
.LBB0_50:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 69
	jp	.LBB0_73
	.local	.LBB0_51
.LBB0_51:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 87
	jp	.LBB0_73
	.local	.LBB0_52
.LBB0_52:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 77
	jp	.LBB0_73
	.local	.LBB0_53
.LBB0_53:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	a, (_shift_mode)
	ld	l, 1
	xor	a, l
	ld	l, a
	ld	(_shift_mode), a
	jp	.LBB0_79
	.local	.LBB0_54
.LBB0_54:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 1
	ld	iyl, c
	ld	b, 47
	jp	.LBB0_73
	.local	.LBB0_55
.LBB0_55:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 1
	ld	iyl, c
	ld	b, 39
	jp	.LBB0_73
	.local	.LBB0_56
.LBB0_56:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 83
	jp	.LBB0_73
	.local	.LBB0_57
.LBB0_57:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 71
	jp	.LBB0_73
	.local	.LBB0_58
.LBB0_58:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 72
	jp	.LBB0_73
	.local	.LBB0_59
.LBB0_59:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 66
	jr	.LBB0_73
	.local	.LBB0_60
.LBB0_60:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 1
	ld	iyl, c
	ld	b, 42
	jr	.LBB0_73
	.local	.LBB0_61
.LBB0_61:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 68
	jr	.LBB0_73
	.local	.LBB0_62
.LBB0_62:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 88
	jr	.LBB0_73
	.local	.LBB0_63
.LBB0_63:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	de, (_input_len)
	ld	bc, 128
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB0_79
; %bb.64:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	iy, _input_buf
	add	iy, de
	inc	de
	ld	(_input_len), de
	ld	(iy), 32
	jr	.LBB0_78
	.local	.LBB0_65
.LBB0_65:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 73
	jr	.LBB0_73
	.local	.LBB0_66
.LBB0_66:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 1
	ld	iyl, c
	ld	a, d
	jr	.LBB0_74
	.local	.LBB0_67
.LBB0_67:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 74
	jr	.LBB0_73
	.local	.LBB0_68
.LBB0_68:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 70
	jr	.LBB0_73
	.local	.LBB0_69
.LBB0_69:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 75
	jr	.LBB0_73
	.local	.LBB0_70
.LBB0_70:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 89
	jr	.LBB0_73
	.local	.LBB0_71
.LBB0_71:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 85
	jr	.LBB0_73
	.local	.LBB0_72
.LBB0_72:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, 0
	ld	iyl, c
	ld	b, 82
	.local	.LBB0_73
.LBB0_73:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	a, b
	.local	.LBB0_74
.LBB0_74:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	de, (_input_len)
	ld	bc, 128
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB0_79
; %bb.75:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	c, a
	ld	a, (_shift_mode)
	ld	l, a
	ld	a, iyl
	or	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB0_77
; %bb.76:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	l, 32
	ld	a, c
	add	a, l
	ld	c, a
	.local	.LBB0_77
.LBB0_77:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	iy, _input_buf
	add	iy, de
	inc	de
	ld	(_input_len), de
	ld	(iy), c
	.local	.LBB0_78
.LBB0_78:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	(iy + 1), 0
	.local	.LBB0_79
.LBB0_79:                               ;   in Loop: Header=BB0_111 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 240
	push	hl
	ld	hl, 16
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
	ld	hl, 240
	push	hl
	ld	hl, 1
	push	hl
	dec	hl
	push	hl
	ld	hl, 16
	push	hl
	call	_gfx_FillRectangle
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _.str.16+1
	push	hl
	pop	iy
	ld	hl, 67
	ld	de, 4
	ld	(ix - 3), de
	.local	.LBB0_80
.LBB0_80:                               ;   Parent Loop BB0_111 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 6), iy
	ld	bc, 1
	push	bc
	ld	bc, 3
	push	bc
	push	hl
	push	de
	ld	hl, (ix - 3)
	push	hl
	ld	de, 8
	add	hl, de
	ld	(ix - 3), hl
	call	_draw_char_rot
	ld	iy, (ix - 6)
	ld	de, 4
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (iy)
	ld	l, a
	inc	iy
	or	a, a
	jr	nz, .LBB0_80
; %bb.81:                               ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, 1
	push	hl
	ld	hl, 4
	push	hl
	ld	hl, 124
	push	hl
	push	de
	ld	hl, 68
	push	hl
	call	_draw_char_rot
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (_status_str)
	ld	l, (iy)
	ld	a, l
	or	a, a
	jr	z, .LBB0_85
; %bb.82:                               ; %.preheader25.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	c, l
	inc	iy
	ld	de, 80
	ex	de, hl
	ld	(ix - 3), hl
	.local	.LBB0_83
.LBB0_83:                               ; %.preheader25
                                        ;   Parent Loop BB0_111 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 6), iy
	ld	de, 8
	push	bc
	pop	iy
	push	hl
	pop	bc
	ld	(ix - 9), bc
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	ld	de, 1
	push	de
	ld	de, 4
	push	de
	push	iy
	ld	hl, 4
	push	hl
	push	bc
	call	_draw_char_rot
	ld	iy, (ix - 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 9)
	ld	de, 225
	or	a, a
	sbc	hl, de
	jr	nc, .LBB0_85
; %bb.84:                               ; %.preheader25
                                        ;   in Loop: Header=BB0_83 Depth=2
	ld	a, (iy)
	ld	c, a
	inc	iy
	or	a, a
	ld	hl, (ix - 3)
	jr	nz, .LBB0_83
	.local	.LBB0_85
.LBB0_85:                               ; %.loopexit26
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	de, (_chat_count)
	push	de
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_95
; %bb.86:                               ; %.preheader23.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, _chat+1
	ld	(ix - 3), hl
	ld	bc, 0
	.local	.LBB0_87
.LBB0_87:                               ; %.preheader23
                                        ;   Parent Loop BB0_111 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB0_91 Depth 3
	ld	(ix - 6), bc
	push	bc
	pop	hl
	ld	bc, 31
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _chat
	add	iy, bc
	ld	a, (iy + 30)
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
	ld	(ix - 9), hl
	cp	a, 3
	jr	c, .LBB0_89
; %bb.88:                               ; %.preheader23
                                        ;   in Loop: Header=BB0_87 Depth=2
	ld	a, 7
	ld	l, a
	ld	(ix - 9), hl
	.local	.LBB0_89
.LBB0_89:                               ; %.preheader23
                                        ;   in Loop: Header=BB0_87 Depth=2
	ld	hl, (ix - 6)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	bc, 20
	add	hl, bc
	ld	(ix - 12), hl
	ld	l, (iy)
	ld	a, l
	or	a, a
	jr	z, .LBB0_94
; %bb.90:                               ; %.preheader.preheader
                                        ;   in Loop: Header=BB0_87 Depth=2
	ld	c, l
	ld	hl, (ix - 3)
	ld	(ix - 21), hl
	ld	de, 4
	ex	de, hl
	push	hl
	pop	iy
	.local	.LBB0_91
.LBB0_91:                               ; %.preheader
                                        ;   Parent Loop BB0_111 Depth=1
                                        ;     Parent Loop BB0_87 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	de, 8
	add	iy, de
	ld	(ix - 15), iy
	ld	de, 0
	push	de
	ld	de, (ix - 9)
	push	de
	push	bc
	ex	de, hl
	ld	(ix - 18), de
	ld	hl, (ix - 12)
	push	hl
	push	de
	call	_draw_char_rot
	ld	iy, (ix - 15)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 18)
	ld	de, 225
	or	a, a
	sbc	hl, de
	jr	nc, .LBB0_93
; %bb.92:                               ; %.preheader
                                        ;   in Loop: Header=BB0_91 Depth=3
	ld	hl, (ix - 21)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 21), hl
	or	a, a
	lea	hl, iy + 0
	jr	nz, .LBB0_91
	.local	.LBB0_93
.LBB0_93:                               ;   in Loop: Header=BB0_87 Depth=2
	ld	de, (_chat_count)
	.local	.LBB0_94
.LBB0_94:                               ;   in Loop: Header=BB0_87 Depth=2
	ld	bc, (ix - 6)
	inc	bc
	ld	iy, (ix - 3)
	lea	iy, iy + 31
	ld	(ix - 3), iy
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB0_87
	.local	.LBB0_95
.LBB0_95:                               ; %.loopexit24
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, 1
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 240
	push	hl
	ld	hl, 20
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 300
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
	ld	hl, 240
	push	hl
	ld	hl, 1
	push	hl
	dec	hl
	push	hl
	ld	hl, 299
	push	hl
	call	_gfx_FillRectangle
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_shift_mode)
	bit	0, a
	ld	hl, _.str.19+1
	push	hl
	pop	iy
	ld	hl, 91
	ld	de, 4
	ld	(ix - 3), de
	jr	z, .LBB0_98
; %bb.96:                               ; %.preheader19.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, _.str.18+1
	push	hl
	pop	iy
	ld	hl, 91
	ld	(ix - 3), de
	.local	.LBB0_97
.LBB0_97:                               ; %.preheader19
                                        ;   Parent Loop BB0_111 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 6), iy
	ld	de, 1
	push	de
	ld	de, 3
	push	de
	push	hl
	ld	hl, 306
	push	hl
	ld	hl, (ix - 3)
	push	hl
	ld	de, 8
	add	hl, de
	ld	(ix - 3), hl
	call	_draw_char_rot
	ld	iy, (ix - 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (iy)
	ld	l, a
	inc	iy
	or	a, a
	jr	nz, .LBB0_97
	jr	.LBB0_99
	.local	.LBB0_98
.LBB0_98:                               ; %.preheader21
                                        ;   Parent Loop BB0_111 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 6), iy
	ld	de, 1
	push	de
	ld	de, 3
	push	de
	push	hl
	ld	hl, 306
	push	hl
	ld	hl, (ix - 3)
	push	hl
	ld	de, 8
	add	hl, de
	ld	(ix - 3), hl
	call	_draw_char_rot
	ld	iy, (ix - 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (iy)
	ld	l, a
	inc	iy
	or	a, a
	jr	nz, .LBB0_98
	.local	.LBB0_99
.LBB0_99:                               ; %.loopexit20
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, (_input_len)
	push	hl
	pop	iy
	ld	de, -22
	add	iy, de
	push	hl
	pop	bc
	ld	de, 23
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	lea	de, iy + 0
	jp	p, .LBB0_101
; %bb.100:                              ; %.loopexit20
                                        ;   in Loop: Header=BB0_111 Depth=1
	or	a, a
	sbc	hl, hl
	ex	de, hl
	.local	.LBB0_101
.LBB0_101:                              ; %.loopexit20
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, _input_buf
	ld	(ix - 3), de
	add	hl, de
	ld	e, (hl)
	ld	a, e
	or	a, a
	jr	z, .LBB0_107
; %bb.102:                              ; %.preheader18.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	push	bc
	pop	iy
	lea	hl, iy + 0
	ld	bc, 23
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB0_104
; %bb.103:                              ; %.preheader18.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	iy, 22
	.local	.LBB0_104
.LBB0_104:                              ; %.preheader18.preheader
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	c, e
	ld	de, _input_buf-21
	ex	de, hl
	lea	de, iy + 0
	add	hl, de
	ld	(ix - 12), hl
	ld	de, 52
	ex	de, hl
	push	hl
	pop	iy
	.local	.LBB0_105
.LBB0_105:                              ; %.preheader18
                                        ;   Parent Loop BB0_111 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	de, 8
	add	iy, de
	ld	(ix - 6), iy
	ld	de, 1
	push	de
	ld	de, 7
	push	de
	push	bc
	ex	de, hl
	ld	(ix - 9), de
	ld	hl, 306
	push	hl
	push	de
	call	_draw_char_rot
	ld	iy, (ix - 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 9)
	ld	de, 225
	or	a, a
	sbc	hl, de
	jr	nc, .LBB0_107
; %bb.106:                              ; %.preheader18
                                        ;   in Loop: Header=BB0_105 Depth=2
	ld	hl, (ix - 12)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 12), hl
	or	a, a
	lea	hl, iy + 0
	jr	nz, .LBB0_105
	.local	.LBB0_107
.LBB0_107:                              ; %.loopexit
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	a, (-851968)
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	jr	nz, .LBB0_110
; %bb.108:                              ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, (_input_len)
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	ld	bc, 23
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB0_110
; %bb.109:                              ;   in Loop: Header=BB0_111 Depth=1
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, 52
	add	hl, de
	ld	de, 1
	push	de
	ld	de, 3
	push	de
	ld	de, 95
	push	de
	ld	de, 306
	push	de
	push	hl
	call	_draw_char_rot
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB0_110
.LBB0_110:                              ;   in Loop: Header=BB0_111 Depth=1
	ld	hl, 1
	push	hl
	call	_gfx_Blit
	pop	hl
	.local	.LBB0_111
.LBB0_111:                              ; %.preheader30
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_24 Depth 2
                                        ;     Child Loop BB0_27 Depth 2
                                        ;     Child Loop BB0_80 Depth 2
                                        ;     Child Loop BB0_83 Depth 2
                                        ;     Child Loop BB0_87 Depth 2
                                        ;       Child Loop BB0_91 Depth 3
                                        ;     Child Loop BB0_98 Depth 2
                                        ;     Child Loop BB0_97 Depth 2
                                        ;     Child Loop BB0_105 Depth 2
	call	_usb_HandleEvents
	call	_os_GetCSC
	ld	d, a
	ld	l, -9
	ld	a, d
	add	a, l
	ld	e, a
	cp	a, 48
	jp	nc, .LBB0_79
; %bb.112:                              ; %.preheader30
                                        ;   in Loop: Header=BB0_111 Depth=1
	ld	bc, 0
	ld	c, e
	ld	hl, JTI0_0
	add	hl, bc
	add	hl, bc
	add	hl, bc
	ld	hl, (hl)
	ld	c, b
	ld	iyl, c
	ld	b, 81
	ld	a, b
	jp	(hl)
	.local	.LBB0_113
.LBB0_113:
	call	_usb_Cleanup
	or	a, a
	sbc	hl, hl
	.local	.LBB0_114
.LBB0_114:                              ; %.loopexit31
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
	d24	.LBB0_20
	d24	.LBB0_53
	d24	.LBB0_46
	d24	.LBB0_60
	d24	.LBB0_54
	d24	.LBB0_63
	d24	.LBB0_37
	d24	.LBB0_79
	d24	.LBB0_49
	d24	.LBB0_62
	d24	.LBB0_45
	d24	.LBB0_48
	d24	.LBB0_59
	d24	.LBB0_43
	d24	.LBB0_52
	d24	.LBB0_79
	d24	.LBB0_42
	d24	.LBB0_56
	d24	.LBB0_61
	d24	.LBB0_68
	d24	.LBB0_57
	d24	.LBB0_58
	d24	.LBB0_67
	d24	.LBB0_69
	d24	.LBB0_74
	d24	.LBB0_51
	d24	.LBB0_50
	d24	.LBB0_72
	d24	.LBB0_40
	d24	.LBB0_70
	d24	.LBB0_71
	d24	.LBB0_65
	d24	.LBB0_79
	d24	.LBB0_79
	d24	.LBB0_55
	d24	.LBB0_66
	d24	.LBB0_79
	d24	.LBB0_66
	d24	.LBB0_44
	d24	.LBB0_79
	d24	.LBB0_79
	d24	.LBB0_79
	d24	.LBB0_79
	d24	.LBB0_41
	d24	.LBB0_113
	d24	.LBB0_79
	d24	.LBB0_39
	d24	.LBB0_38
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
	ld	bc, 29
	ld	a, e
	ex	de, hl
	lea	hl, iy + 0
	ldir
	ld	l, a
	ld	a, (ix + 9)
	ld	(_chat+30), a
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
	ld	de, 35
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB1_11
; %bb.5:
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	push	iy
	ld	(ix - 9), bc
	call	_memmove
	ld	iy, _chat
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	hl, 34
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
	ld	bc, 31
	ld	(ix - 3), hl
	call	__imulu
	ex	de, hl
	add	iy, de
	push	iy
	call	_strlen
	pop	de
	ld	de, 29
	ld	(ix - 6), hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	a, (ix + 9)
	jp	m, .LBB1_10
; %bb.7:
	ld	de, 35
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
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	a, (ix + 9)
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	de, (ix - 9)
	scf
	sbc	hl, hl
	push	hl
	pop	iy
	ld	hl, 34
	.local	.LBB1_9
.LBB1_9:                                ; %._crit_edge
	ld	bc, 0
	ld	(ix - 6), bc
	add	iy, de
	ld	(ix - 9), iy
	ld	(_chat_count), iy
	ld	bc, 31
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
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), a
	ld	hl, (ix - 9)
	dec	hl
	ld	(ix - 3), hl
	.local	.LBB1_10
.LBB1_10:
	ld	bc, 31
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
	ld	bc, 31
	ld	hl, (ix - 3)
	call	__imulu
	ex	de, hl
	lea	hl, iy + 0
	add	hl, de
	ld	(hl), b
	push	hl
	pop	iy
	inc	iy
	ld	bc, 29
	lea	de, iy + 0
	ldir
	.local	.LBB1_13
.LBB1_13:
	ld	bc, 31
	ld	hl, (ix - 3)
	call	__imulu
	ex	de, hl
	ld	hl, _chat
	push	hl
	pop	iy
	add	iy, de
	ld	(iy + 30), a
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
	ld	hl, _.str.5
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
	ld	hl, _.str.6
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
	.section	.text._draw_char_rot,"ax",@progbits
	.type	_draw_char_rot,@function        ; -- Begin function draw_char_rot
_draw_char_rot:                         ; @draw_char_rot
; %bb.0:
	ld	hl, -10
	call	__frameset
	ld	a, (ix + 12)
	ld	iy, _font8x8_basic
	ld	de, 76480
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB4_2
; %bb.1:
	ld	a, 63
	.local	.LBB4_2
.LBB4_2:
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 9), iy
	ld	iy, (ix + 9)
	add	iy, de
	ld	hl, (ix + 6)
	ld	bc, 320
	call	__imulu
	ex	de, hl
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	ex	de, hl
	ld	iy, 0
	.local	.LBB4_3
.LBB4_3:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB4_5 Depth 2
	ld	(ix - 3), iy
	ld	bc, (ix + 9)
	add	iy, bc
	lea	hl, iy + 0
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB4_10
; %bb.4:                                ;   in Loop: Header=BB4_3 Depth=1
	ld	hl, (ix - 9)
	ld	bc, (ix - 3)
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 10), a
	push	de
	pop	iy
	ld	bc, 0
	ld	(ix - 6), de
	.local	.LBB4_5
.LBB4_5:                                ;   Parent Loop BB4_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	hl, (ix + 6)
	add	hl, bc
	ld	de, 240
	or	a, a
	sbc	hl, de
	jr	nc, .LBB4_9
; %bb.6:                                ;   in Loop: Header=BB4_5 Depth=2
	ld	hl, 1
	call	__ishl
	ld	e, (ix - 10)
	ld	a, l
	and	a, e
	ld	l, a
	or	a, a
	ld	a, (ix + 18)
	jr	z, .LBB4_8
; %bb.7:                                ;   in Loop: Header=BB4_5 Depth=2
	ld	a, (ix + 15)
	.local	.LBB4_8
.LBB4_8:                                ;   in Loop: Header=BB4_5 Depth=2
	ld	hl, (-1900524)
	lea	de, iy + 0
	add	hl, de
	ld	(hl), a
	.local	.LBB4_9
.LBB4_9:                                ;   in Loop: Header=BB4_5 Depth=2
	inc	bc
	ld	de, -320
	add	iy, de
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	ld	de, (ix - 6)
	jr	nz, .LBB4_5
	.local	.LBB4_10
.LBB4_10:                               ; %.loopexit
                                        ;   in Loop: Header=BB4_3 Depth=1
	ld	iy, (ix - 3)
	inc	iy
	inc	de
	lea	hl, iy + 0
	ld	bc, 8
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB4_3
; %bb.11:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_draw_char_rot, .Lfunc_end4-_draw_char_rot
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
	jr	z, .LBB5_4
; %bb.1:
	ld	a, (_rx_pending)
	bit	0, a
	jr	nz, .LBB5_4
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
	jr	z, .LBB5_4
; %bb.3:
	xor	a, a
	ld	(_rx_pending), a
	.local	.LBB5_4
.LBB5_4:
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_queue_rx, .Lfunc_end5-_queue_rx
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
	jp	nz, .LBB6_28
; %bb.1:
	ld	hl, (ix + 12)
	ld	de, 8
	or	a, a
	sbc	hl, de
	jp	c, .LBB6_28
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
	jp	nz, .LBB6_28
; %bb.3:
	ld	a, c
	cp	a, 71
	jp	nz, .LBB6_28
; %bb.4:
	ld	a, e
	cp	a, 80
	jp	nz, .LBB6_28
; %bb.5:
	ld	a, l
	cp	a, 84
	jp	nz, .LBB6_28
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
	jr	c, .LBB6_8
; %bb.7:
	ld.sis	hl, 56
	.local	.LBB6_8
.LBB6_8:
	ld	(ix - 6), l
	ld	(ix - 5), h
	ld	l, -16
	add	a, l
	ld	l, a
	cp	a, 5
	jp	nc, .LBB6_28
; %bb.9:
	ld	bc, _chat+1054
	lea	de, iy + 0
	ld	e, l
	ld	hl, JTI6_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB6_10
.LBB6_10:
	ld	hl, _.str.7
	jr	.LBB6_13
	.local	.LBB6_11
.LBB6_11:
	ld	hl, _.str.9
	ld	(_status_str), hl
	jp	.LBB6_27
	.local	.LBB6_12
.LBB6_12:
	ld	hl, _.str.9
	.local	.LBB6_13
.LBB6_13:
	ld	(_status_str), hl
	ld	hl, (_chat_count)
	ld	de, 1
	ld	(ix - 3), hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	b, d
	jp	m, .LBB6_28
; %bb.14:
	ld	de, (ix - 3)
	dec	de
	ld	bc, 31
	ex	de, hl
	call	__imulu
	ex	de, hl
	ld	hl, _chat
	add	hl, de
	ld	a, (hl)
	or	a, a
	jp	z, .LBB6_28
; %bb.15:
	ld	de, 35
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	push	bc
	pop	hl
	ld	iy, 1
	jr	c, .LBB6_17
; %bb.16:
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	hl, _chat+1054
	push	hl
	pop	de
	inc	de
	ld	bc, 30
	ldir
	ld	bc, (ix - 3)
	scf
	sbc	hl, hl
	push	hl
	pop	iy
	ld	hl, 34
	.local	.LBB6_17
.LBB6_17:                               ; %._crit_edge4
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 2
	jp	.LBB6_27
	.local	.LBB6_18
.LBB6_18:
	ld	hl, _.str.10
	ld	(_status_str), hl
	ld	iy, (_chat_count)
	ld	de, 35
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	inc	bc
	ld	(ix - 12), bc
	ld	bc, 1
	ld	(ix - 9), iy
	lea	hl, iy + 0
	jp	m, .LBB6_20
; %bb.19:
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	bc, 30
	ld	de, (ix - 12)
	ld	hl, _chat+1054
	ldir
	scf
	sbc	hl, hl
	push	hl
	pop	bc
	ld	hl, 34
	.local	.LBB6_20
.LBB6_20:
	ld	de, (ix - 9)
	push	bc
	pop	iy
	add	iy, de
	ld	(ix - 15), iy
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 9), iy
	ld	hl, (ix - 9)
	inc	hl
	ld	(ix - 9), hl
	ld	bc, 29
	ld	de, (ix - 9)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 3
	ld	hl, (ix - 3)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	bc, (ix - 15)
	jr	z, .LBB6_24
; %bb.21:
	ld	de, 0
	ld	l, (ix - 6)
	ld	h, (ix - 5)
	ld	e, l
	ld	d, h
	ld	iy, _rx_pkt+8
	.local	.LBB6_22
.LBB6_22:                               ; =>This Inner Loop Header: Depth=1
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
	jr	nz, .LBB6_22
; %bb.23:
	ld	bc, (_chat_count)
	.local	.LBB6_24
.LBB6_24:
	push	bc
	pop	hl
	ld	de, 35
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	hl
	ld	iy, 1
	jp	m, .LBB6_26
; %bb.25:
	ld	hl, 1054
	push	hl
	ld	hl, _chat+31
	push	hl
	ld	hl, _chat
	push	hl
	ld	(ix - 3), bc
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_chat+1054), a
	ld	bc, 30
	ld	de, (ix - 12)
	ld	hl, _chat+1054
	ldir
	ld	bc, (ix - 3)
	scf
	sbc	hl, hl
	push	hl
	pop	iy
	ld	hl, 34
	.local	.LBB6_26
.LBB6_26:
	add	iy, bc
	ld	(_chat_count), iy
	ld	bc, 31
	call	__imulu
	ex	de, hl
	ld	iy, _chat
	add	iy, de
	ld	(iy), b
	ld	(ix - 3), iy
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 29
	ld	de, (ix - 3)
	lea	hl, iy + 0
	ldir
	ld	(iy + 30), 3
	.local	.LBB6_27
.LBB6_27:                               ; %.loopexit
	ld	b, 0
	.local	.LBB6_28
.LBB6_28:                               ; %.loopexit
	ld	a, b
	ld	(_rx_pending), a
	call	_queue_rx
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB6_29
.LBB6_29:
	ld	de, _rx_pkt+8
	ld	hl, _.str.8
	ld	(_status_str), hl
	ld	hl, (ix - 3)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	b, 0
	jr	z, .LBB6_28
; %bb.30:
	ld	bc, 0
	ld	l, (ix - 6)
	ld	h, (ix - 5)
	ld	c, l
	ld	b, h
	ld	(ix - 6), bc
	.local	.LBB6_31
.LBB6_31:                               ; =>This Inner Loop Header: Depth=1
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
	jr	nz, .LBB6_31
	jr	.LBB6_28
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_rx_complete, .Lfunc_end6-_rx_complete
	.section	.rodata._rx_complete,"a",@progbits
JTI6_0:
	d24	.LBB6_10
	d24	.LBB6_29
	d24	.LBB6_12
	d24	.LBB6_18
	d24	.LBB6_11
                                        ; -- End function
	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"CalcGPT QWERTY v2.0"

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"Sideways layout: 240x320"

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"+:Shift ^:Space -:Backspace"

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"ENTER:Send CLEAR:Clear Y=:Exit"

	.section	.rodata._descriptors,"a",@progbits
	.balign	1
	.local	_descriptors
_descriptors:
	d24	_device
	d24	_configs
	d24	_lang
	db	1                               ; 0x1
	d24	_strings

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"USB Init Failed!"

	.section	.bss._shift_mode,"aw",@nobits
	.balign	1
	.local	_shift_mode
_shift_mode:
	.zero	1

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
	.zero	1085

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

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"Connected to host"

	.section	.data._status_str,"aw",@progbits
	.balign	1
	.local	_status_str
_status_str:
	d24	_.str.6

	.section	.bss._rx_pending,"aw",@nobits
	.balign	1
	.local	_rx_pending
_rx_pending:
	.zero	1

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"Waiting for USB link\342\200\246"

	.section	.bss._rx_pkt,"aw",@nobits
	.balign	1
	.local	_rx_pkt
_rx_pkt:
	.zero	64

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"Gemini typing\342\200\246"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"Receiving stream\342\200\246"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"Online (Ready)"

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
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

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"> "

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"Sending prompt\342\200\246"

	.section	.bss._tx_pkt,"aw",@nobits
	.balign	1
	.local	_tx_pkt
_tx_pkt:
	.zero	64

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"USB Tx error"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"CalcGPT"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"[A] >"

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"[a] >"

	.section	.rodata._font8x8_basic,"a",@progbits
	.balign	1
	.local	_font8x8_basic
_font8x8_basic:
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.zero	8
	.asciz	"\030<<\030\030\000\030"
	.asciz	"66\000\000\000\000\000"
	.asciz	"66\1776\17766"
	.asciz	"\f>\003\0360\037\f"
	.asciz	"\000c3\030\ffc"
	.asciz	"\0346\034n;3n"
	.asciz	"\006\006\003\000\000\000\000"
	.asciz	"\030\f\006\006\006\f\030"
	.asciz	"\006\f\030\030\030\f\006"
	.asciz	"\000f<\377<f\000"
	.asciz	"\000\f\f?\f\f\000"
	.ascii	"\000\000\000\000\000\f\f\006"
	.asciz	"\000\000\000?\000\000\000"
	.asciz	"\000\000\000\000\000\f\f"
	.asciz	"`0\030\f\006\003\001"
	.asciz	">cs{og>"
	.asciz	"\f\016\f\f\f\f?"
	.asciz	"\03630\034\0063?"
	.asciz	"\03630\03403\036"
	.asciz	"8<63\1770x"
	.asciz	"?\003\037003\036"
	.asciz	"\034\006\003\03733\036"
	.asciz	"?30\030\f\f\f"
	.asciz	"\03633\03633\036"
	.asciz	"\03633>0\030\016"
	.asciz	"\000\f\f\000\000\f\f"
	.ascii	"\000\f\f\000\000\f\f\006"
	.asciz	"\030\f\006\003\006\f\030"
	.asciz	"\000\000?\000\000?\000"
	.asciz	"\006\f\0300\030\f\006"
	.asciz	"\03630\030\f\000\f"
	.asciz	">c{{{\003\036"
	.asciz	"\f\03633?33"
	.asciz	"?ff>ff?"
	.asciz	"<f\003\003\003f<"
	.asciz	"\0376fff6\037"
	.asciz	"\177F\026\036\026F\177"
	.asciz	"\177F\026\036\026\006\017"
	.asciz	"<f\003\003sf|"
	.asciz	"333?333"
	.asciz	"\036\f\f\f\f\f\036"
	.asciz	"x00033\036"
	.asciz	"gf6\0366fg"
	.asciz	"\017\006\006\006Ff\177"
	.asciz	"cw\177\177kcc"
	.asciz	"cgo{scc"
	.asciz	"\0346ccc6\034"
	.asciz	"?ff>\006\006\017"
	.asciz	"\036333;\0368"
	.asciz	"?ff>6fg"
	.asciz	"\0363\007\01683\036"
	.asciz	"?-\f\f\f\f\036"
	.asciz	"333333?"
	.asciz	"33333\036\f"
	.asciz	"ccck\177wc"
	.asciz	"cc6\034\0346c"
	.asciz	"333\036\f\f\036"
	.asciz	"\177c1\030Lf\177"
	.asciz	"\036\006\006\006\006\006\036"
	.asciz	"\003\006\f\0300`@"
	.asciz	"\036\030\030\030\030\030\036"
	.asciz	"\b\0346c\000\000\000"
	.ascii	"\000\000\000\000\000\000\000\377"
	.asciz	"\f\f\030\000\000\000\000"
	.asciz	"\000\000\0360>3n"
	.asciz	"\007\006\006>ff;"
	.asciz	"\000\000\0363\0033\036"
	.asciz	"800>33n"
	.asciz	"\000\000\0363?\003\036"
	.asciz	"\0346\006\017\006\006\017"
	.ascii	"\000\000n33>0\037"
	.asciz	"\007\0066nffg"
	.asciz	"\f\000\016\f\f\f\036"
	.ascii	"0\00000033\036"
	.asciz	"\007\006f6\0366g"
	.asciz	"\016\f\f\f\f\f\036"
	.asciz	"\000\0003\177\177kc"
	.asciz	"\000\000\0373333"
	.asciz	"\000\000\036333\036"
	.ascii	"\000\000;ff>\006\017"
	.ascii	"\000\000n33>0x"
	.asciz	"\000\000;nf\006\017"
	.asciz	"\000\000>\003\0360\037"
	.asciz	"\b\f>\f\f,\030"
	.asciz	"\000\0003333n"
	.asciz	"\000\000333\036\f"
	.asciz	"\000\000ck\177\1776"
	.asciz	"\000\000c6\0346c"
	.ascii	"\000\000333>0\037"
	.asciz	"\000\000?\031\f&?"
	.asciz	"8\f\f\007\f\f8"
	.asciz	"\030\030\030\000\030\030\030"
	.asciz	"\007\f\f8\f\f\007"
	.asciz	"n;\000\000\000\000\000"
	.zero	8

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_usb_Cleanup
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_usb_HandleEvents
	.extern	_gfx_FillRectangle
	.extern	_llvm.smax.i24
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
	.extern	_gfx_SetColor
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_os_GetCSC
	.extern	_llvm.memset.p0.i24
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
	.extern	_gfx_SetDraw
	.extern	__ishl
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_Begin
	.extern	_usb_SetEndpointFlags
