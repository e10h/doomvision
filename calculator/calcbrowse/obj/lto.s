	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -41
	call	__frameset
	ld	l, 31
	ld	(ix - 12), l
	ld	(ix - 11), h
	ld	h, 0
	ld	(ix - 20), l
	ld	(ix - 19), h
	ld	hl, -1900032
	ld	(ix - 23), hl
	ld	hl, _.str.4+1
	ld	(ix - 38), hl
	ld	hl, _.str.5+1
	ld	(ix - 35), hl
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	ld	h, 0
	ld	(ix - 15), l
	ld	(ix - 14), h
	ld	(ix - 18), h                    ; 1-byte Folded Spill
	ld	bc, 0
	.local	.LBB0_1
.LBB0_1:                                ; =>This Inner Loop Header: Depth=1
	ld	(ix - 26), bc
	push	bc
	pop	hl
	ld	c, 5
	call	__ishru
	ld	e, (ix - 12)
	ld	d, (ix - 11)
	ld	d, l
	ld	(ix - 12), e
	ld	(ix - 11), d
	mlt	de
	push	hl
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	ex	(sp), hl
	pop	iy
	ld	iyl, e
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 37
	call	__smulu
	ld	c, (ix - 15)
	ld	b, (ix - 14)
	ld	c, h
	ld	(ix - 15), c
	ld	(ix - 14), b
	ld	l, c
	ld	a, e
	sub	a, l
	ld	e, a
	srl	e
	ld	a, e
	add	a, l
	ld	l, a
	ld	l, 2
	ld	b, l
	call	__bshru
	ld	l, a
	ex	de, hl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 29), l
	ld	(ix - 28), h
	ld	a, (ix - 18)                    ; 1-byte Folded Reload
	call	__bshru
	ld	l, 7
	and	a, l
	ld	d, a
	ld	l, (ix - 12)
	ld	h, (ix - 11)
	ld	e, l
	mlt	de
	ld	d, iyh
	ld	l, e
	ld	h, d
	ld.sis	bc, 37
	call	__smulu
	ld	c, (ix - 15)
	ld	b, (ix - 14)
                                        ; kill: def $b killed $b killed $bc def $bc
	ld	c, h
	ld	l, c
	ld	a, e
	sub	a, l
	ld	e, a
	srl	e
	ld	a, e
	add	a, l
	ld	l, a
	ld	b, 2
	call	__bshru
	ld	l, a
	ex	de, hl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 32), hl
	ld	l, 3
	ld	a, (ix - 18)
	and	a, l
	ld	h, a
	ld	e, (ix - 12)
	ld	d, (ix - 11)
	ld	l, e
	mlt	hl
	push	iy
	ex	(sp), hl
	ld	(ix - 20), l
	ld	(ix - 19), h
	pop	hl
	ex	de, hl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 86
	call	__smulu
	ld	e, (ix - 15)
	ld	d, (ix - 14)
                                        ; kill: def $d killed $d killed $de def $de
	ld	e, h
	ld	l, (ix - 29)
	ld	h, (ix - 28)
	ld	c, 10
	call	__sshl
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	hl, (ix - 32)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	c, l
	ld	b, h
	add.sis	iy, de
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	call	__sor
	ld	bc, (ix - 26)
	ld	iy, (ix - 23)
	ld	(iy), l
	ld	(iy + 1), h
	inc	bc
	lea	iy, iy + 2
	ld	(ix - 23), iy
	inc	(ix - 18)
	push	bc
	pop	hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	jp	nz, .LBB0_1
; %bb.2:
	ld	hl, 255
	push	hl
	call	_gfx_FillScreen
	pop	hl
	call	_draw_chrome_bar
	ld	hl, 40
	push	hl
	pop	iy
	ld	hl, _.str+1
	ld	(ix - 12), hl
	ld	hl, 84
	push	hl
	pop	bc
	.local	.LBB0_3
.LBB0_3:                                ; =>This Inner Loop Header: Depth=1
	ld	de, 255
	push	de
	ld	de, 27
	push	de
	push	bc
	ld	hl, 80
	push	hl
	push	iy
	ld	de, 8
	add	iy, de
	ld	(ix - 15), iy
	call	_draw_char
	ld	iy, (ix - 15)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 12), hl
	or	a, a
	jr	nz, .LBB0_3
; %bb.4:                                ; %.preheader8.preheader
	ld	bc, 73
	ld	hl, 40
	push	hl
	pop	iy
	ld	hl, _.str.1+1
	ld	de, 49
	.local	.LBB0_5
.LBB0_5:                                ; %.preheader8
                                        ; =>This Inner Loop Header: Depth=1
	ld	(ix - 15), hl
	ld	hl, 255
	push	hl
	push	bc
	push	de
	ld	hl, 100
	push	hl
	push	iy
	ld	de, 8
	add	iy, de
	ld	(ix - 12), iy
	call	_draw_char
	ld	iy, (ix - 12)
	ld	bc, 73
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 15)
	ld	a, (hl)
	ld	e, a
	inc	hl
	or	a, a
	jr	nz, .LBB0_5
; %bb.6:                                ; %.preheader7.preheader
	ld	hl, 40
	push	hl
	pop	iy
	ld	hl, _.str.2+1
	ld	(ix - 12), hl
	ld	hl, 50
	.local	.LBB0_7
.LBB0_7:                                ; %.preheader7
                                        ; =>This Inner Loop Header: Depth=1
	ld	de, 255
	push	de
	push	bc
	push	hl
	ld	hl, 116
	push	hl
	push	iy
	ld	de, 8
	add	iy, de
	ld	(ix - 15), iy
	call	_draw_char
	ld	iy, (ix - 15)
	ld	bc, 73
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	ld	a, (hl)
	ld	e, a
	inc	hl
	ld	(ix - 12), hl
	ex	de, hl
	or	a, a
	jr	nz, .LBB0_7
; %bb.8:                                ; %.preheader6.preheader
	ld	hl, 40
	push	hl
	pop	iy
	ld	hl, _.str.3+1
	ld	(ix - 12), hl
	ld	hl, 67
	push	hl
	pop	bc
	.local	.LBB0_9
.LBB0_9:                                ; %.preheader6
                                        ; =>This Inner Loop Header: Depth=1
	ld	de, 255
	push	de
	ld	hl, 27
	push	hl
	push	bc
	ld	hl, 140
	push	hl
	push	iy
	ld	de, 8
	add	iy, de
	ld	(ix - 15), iy
	call	_draw_char
	ld	iy, (ix - 15)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 12), hl
	or	a, a
	jr	nz, .LBB0_9
; %bb.10:                               ; %.preheader5.preheader
	ld	hl, 40
	push	hl
	pop	iy
	ld	bc, 91
	.local	.LBB0_11
.LBB0_11:                               ; %.preheader5
                                        ; =>This Inner Loop Header: Depth=1
	ld	de, 8
	add	iy, de
	ld	(ix - 12), iy
	ex	de, hl
	ld	(ix - 15), de
	ld	hl, 255
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	bc
	ld	hl, 156
	push	hl
	push	de
	call	_draw_char
	ld	iy, (ix - 12)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 15)
	ld	de, 305
	or	a, a
	sbc	hl, de
	jr	nc, .LBB0_13
; %bb.12:                               ; %.preheader5
                                        ;   in Loop: Header=BB0_11 Depth=1
	ld	hl, (ix - 38)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 38), hl
	or	a, a
	lea	hl, iy + 0
	jr	nz, .LBB0_11
	.local	.LBB0_13
.LBB0_13:                               ; %.preheader4.preheader
	ld	hl, 40
	push	hl
	pop	iy
	ld	bc, 91
	.local	.LBB0_14
.LBB0_14:                               ; %.preheader4
                                        ; =>This Inner Loop Header: Depth=1
	ld	de, 8
	add	iy, de
	ld	(ix - 12), iy
	ex	de, hl
	ld	(ix - 15), de
	ld	hl, 255
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	bc
	ld	hl, 172
	push	hl
	push	de
	call	_draw_char
	ld	iy, (ix - 12)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 15)
	ld	de, 305
	or	a, a
	sbc	hl, de
	jr	nc, .LBB0_16
; %bb.15:                               ; %.preheader4
                                        ;   in Loop: Header=BB0_14 Depth=1
	ld	hl, (ix - 35)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 35), hl
	or	a, a
	lea	hl, iy + 0
	jr	nz, .LBB0_14
	.local	.LBB0_16
.LBB0_16:                               ; %.preheader.preheader
	ld	hl, 40
	push	hl
	pop	iy
	ld	hl, _.str.6+1
	ld	(ix - 12), hl
	ld	de, 91
	.local	.LBB0_17
.LBB0_17:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	ld	hl, 255
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	de
	ld	hl, 188
	push	hl
	push	iy
	ld	de, 8
	add	iy, de
	ld	(ix - 15), iy
	call	_draw_char
	ld	iy, (ix - 15)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	ld	a, (hl)
	ld	e, a
	inc	hl
	ld	(ix - 12), hl
	or	a, a
	jr	nz, .LBB0_17
; %bb.18:
	ld	hl, (_cursor_x)
	ld	de, (_cursor_y)
	push	de
	push	hl
	call	_save_and_draw_cursor
	pop	hl
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_Blit
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
	jp	nz, .LBB0_94
; %bb.19:
	call	_usb_HandleEvents
	call	_kb_Scan
	ld	hl, -720878
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	hl, -720868
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	iyl, e
	ld	iyh, d
	pop	de
	ld	hl, -720866
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 18), l
	ld	(ix - 17), h
	ld	a, (_main.prev_g1)
	ld	l, a
	ld	a, (_main.prev_g6)
	ld	e, a
	ld	d, 0
	ld	a, c
	ld	(_main.prev_g1), a
	push	iy
	ex	(sp), hl
	ld	(ix - 15), l
	ld	(ix - 14), h
	pop	hl
	ld	a, iyl
	ld	(_main.prev_g6), a
	ld	(ix - 12), c
	ld	(ix - 11), b
	ld	a, c
	bit	4, a
	jp	nz, .LBB0_93
; %bb.20:
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	bc, 0
	ld	l, (ix - 15)
	ld	h, (ix - 14)
	ld	c, l
	ld	b, h
	ld	(ix - 26), bc
	or	a, a
	sbc	hl, hl
	ld	c, (ix - 18)
	ld	b, (ix - 17)
	ld	l, c
	ld	h, b
	ld	(ix - 18), hl
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	ex	de, hl
	ld	iyh, d
	ex	de, hl
	ld	l, e
	ld	h, d
	call	__snot
	ld	c, l
	ld	b, h
	ld	l, (ix - 15)
	ld	h, (ix - 14)
	call	__sand
	ld	(ix - 15), l
	ld	(ix - 14), h
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	.local	.LBB0_21
.LBB0_21:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 23), e
	ld	(ix - 22), d
	call	__snot
	ld	c, l
	ld	b, h
	ld	l, (ix - 12)
	ld	h, (ix - 11)
	call	__sand
	ld	(ix - 12), l
	ld	(ix - 11), h
	ld	e, l
	ld	a, (_url_bar_active)
	ld	c, a
	bit	3, e
	jr	nz, .LBB0_23
; %bb.22:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	e, c
	jr	.LBB0_26
	.local	.LBB0_23
.LBB0_23:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	e, 1
	ld	a, c
	xor	a, e
	ld	e, a
	ld	(_url_bar_active), a
	bit	0, c
	jr	nz, .LBB0_25
; %bb.24:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, 63
	push	hl
	ld	hl, _current_url
	push	hl
	ld	hl, _url_input
	push	hl
	ld	(ix - 29), e                    ; 1-byte Folded Spill
	call	_strncpy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _url_input
	push	hl
	call	_strlen
	pop	de
	ld	e, (ix - 29)                    ; 1-byte Folded Reload
	ld	(_url_input_len), hl
	.local	.LBB0_25
.LBB0_25:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	ld	a, h
	ld	(_needs_blit), a
	.local	.LBB0_26
.LBB0_26:                               ;   in Loop: Header=BB0_21 Depth=1
	bit	0, e
	jr	z, .LBB0_35
; %bb.27:                               ;   in Loop: Header=BB0_21 Depth=1
	call	_os_GetCSC
	ld	e, (ix - 15)
	ld	d, (ix - 14)
	ld	l, e
	ld	h, d
	ld.sis	bc, 1
	call	__sand
	bit	0, l
	jp	nz, .LBB0_45
; %bb.28:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, e
	bit	6, l
	ld	c, (ix - 20)
	ld	b, (ix - 19)
	jp	nz, .LBB0_84
; %bb.29:                               ;   in Loop: Header=BB0_21 Depth=1
	cp	a, 15
	jp	z, .LBB0_84
; %bb.30:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, e
	bit	2, l
	jr	nz, .LBB0_33
; %bb.31:                               ;   in Loop: Header=BB0_21 Depth=1
	cp	a, 56
	jr	z, .LBB0_33
; %bb.32:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, (ix - 12)
	ld	h, (ix - 11)
	ld	a, l
	bit	2, a
	jp	z, .LBB0_86
	.local	.LBB0_33
.LBB0_33:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, (_url_input_len)
	push	de
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_86
; %bb.34:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, _url_input
	add	hl, de
	dec	de
	ld	(_url_input_len), de
	dec	hl
	ld	c, (ix - 20)
	ld	b, (ix - 19)
	jp	.LBB0_85
	.local	.LBB0_35
.LBB0_35:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, (_hold_duration)
	push	de
	pop	hl
	ld	bc, 11
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	bc, 5
	jp	p, .LBB0_37
; %bb.36:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	bc, 2
	.local	.LBB0_37
.LBB0_37:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(ix - 41), de
	ex	de, hl
	ld	de, 26
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	hl, 9
	ld	(ix - 32), hl
	jp	p, .LBB0_39
; %bb.38:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(ix - 32), bc
	.local	.LBB0_39
.LBB0_39:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, (_cursor_x)
	ld	(ix - 29), hl
	ld	iy, (_cursor_y)
	ld	de, (ix - 18)
	ld	a, e
	bit	3, a
	ld	(ix - 38), iy
	ld	bc, 1
	jr	z, .LBB0_43
; %bb.40:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, (ix - 38)
	ld	de, (ix - 32)
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	ld	de, 17
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB0_42
; %bb.41:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	iy, 16
	.local	.LBB0_42
.LBB0_42:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(_cursor_y), iy
	ld	de, (ix - 18)
	.local	.LBB0_43
.LBB0_43:                               ;   in Loop: Header=BB0_21 Depth=1
	push	de
	pop	hl
	call	__iand
	bit	0, l
	jr	nz, .LBB0_47
; %bb.44:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(ix - 35), iy
	jp	.LBB0_50
	.local	.LBB0_45
.LBB0_45:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	iy, (_url_input_len)
	lea	hl, iy + 0
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	hl, _url_bar_active
	ld	c, (ix - 20)
	ld	b, (ix - 19)
	jp	m, .LBB0_85
; %bb.46:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, 63
	push	hl
	ld	hl, _url_input
	push	hl
	ld	hl, _current_url
	push	hl
	ld	(ix - 12), iy
	call	_strncpy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	push	hl
	ld	hl, _url_input
	push	hl
	ld	hl, 3
	push	hl
	call	_send_cmd
	ld	c, (ix - 20)
	ld	b, (ix - 19)
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _.str.8
	ld	(_status_msg), hl
	ld	hl, _url_bar_active
	jp	.LBB0_85
	.local	.LBB0_47
.LBB0_47:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, (ix - 32)
	add	iy, de
	lea	hl, iy + 0
	ld	de, 239
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB0_49
; %bb.48:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	iy, 239
	.local	.LBB0_49
.LBB0_49:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(ix - 35), iy
	ld	(_cursor_y), iy
	ld	de, (ix - 18)
	.local	.LBB0_50
.LBB0_50:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, e
	bit	1, a
	ld	iy, (ix - 29)
	jr	z, .LBB0_54
; %bb.51:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, (ix - 29)
	ld	bc, (ix - 32)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB0_53
; %bb.52:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	iy, 0
	.local	.LBB0_53
.LBB0_53:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(_cursor_x), iy
	.local	.LBB0_54
.LBB0_54:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, e
	bit	2, a
	jr	z, .LBB0_58
; %bb.55:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, (ix - 32)
	add	iy, de
	lea	hl, iy + 0
	ld	de, 319
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB0_57
; %bb.56:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	iy, 319
	.local	.LBB0_57
.LBB0_57:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(_cursor_x), iy
	.local	.LBB0_58
.LBB0_58:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, (ix - 35)
	ld	de, (ix - 38)
	or	a, a
	sbc	hl, de
	ld	c, -1
	jr	nz, .LBB0_60
; %bb.59:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	c, 0
	.local	.LBB0_60
.LBB0_60:                               ;   in Loop: Header=BB0_21 Depth=1
	lea	hl, iy + 0
	ld	de, (ix - 29)
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	nz, .LBB0_62
; %bb.61:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, 0
	.local	.LBB0_62
.LBB0_62:                               ;   in Loop: Header=BB0_21 Depth=1
	or	a, c
	ld	l, a
	ld	(ix - 18), l                    ; 1-byte Folded Spill
	bit	0, l
	jr	nz, .LBB0_64
; %bb.63:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, 0
	jr	.LBB0_65
	.local	.LBB0_64
.LBB0_64:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, (ix - 41)
	inc	de
	.local	.LBB0_65
.LBB0_65:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(_hold_duration), de
	ld	l, 1
	ld	e, (ix - 15)
	ld	d, (ix - 14)
	ld	a, e
	and	a, l
	ld	l, a
	ld	e, 32
	ld	c, (ix - 12)
	ld	b, (ix - 11)
	ld	a, c
	and	a, e
	ld	e, a
	ld	a, e
	add	a, l
	ld	l, a
	or	a, a
	jp	z, .LBB0_67
; %bb.66:                               ;   in Loop: Header=BB0_21 Depth=1
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 5), l
	ld	(ix - 4), h
	ld	hl, (ix - 35)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 3), l
	ld	(ix - 2), h
	ld	(ix - 1), 1
	ld	hl, 5
	push	hl
	pea	ix - 5
	ld	hl, 1
	push	hl
	call	_send_cmd
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 4
	ld	(_click_anim), hl
	ld	hl, _.str.9
	ld	(_status_msg), hl
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	ld	a, h
	ld	(_needs_blit), a
	.local	.LBB0_67
.LBB0_67:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, (ix - 26)
	ld	a, l
	bit	1, a
	jr	nz, .LBB0_73
; %bb.68:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, l
	bit	2, a
	ld	de, 0
	push	hl
	ld	l, (ix - 12)
	ld	h, (ix - 11)
	ex	(sp), hl
	pop	iy
	jp	z, .LBB0_79
; %bb.69:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, (ix - 15)
	ld	h, (ix - 14)
	ld	a, l
	bit	2, a
	jr	nz, .LBB0_72
; %bb.70:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, (_main.scroll_hold)
	push	de
	pop	hl
	ld	bc, 9
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_78
; %bb.71:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, 3
	ld	a, e
	and	a, l
	ld	l, a
	or	a, a
	jp	nz, .LBB0_78
	.local	.LBB0_72
.LBB0_72:                               ;   in Loop: Header=BB0_21 Depth=1
	ld.sis	hl, -120
	ld	(ix - 9), l
	ld	(ix - 8), h
	ld	hl, 2
	push	hl
	pea	ix - 9
	jr	.LBB0_77
	.local	.LBB0_73
.LBB0_73:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, (ix - 15)
	ld	h, (ix - 14)
	ld	a, l
	bit	1, a
	push	hl
	ld	l, (ix - 12)
	ld	h, (ix - 11)
	ex	(sp), hl
	pop	iy
	jr	nz, .LBB0_76
; %bb.74:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	de, (_main.scroll_hold)
	push	de
	pop	hl
	ld	bc, 9
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB0_78
; %bb.75:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	l, 3
	ld	a, e
	and	a, l
	ld	l, a
	or	a, a
	jr	nz, .LBB0_78
	.local	.LBB0_76
.LBB0_76:                               ;   in Loop: Header=BB0_21 Depth=1
	ld.sis	hl, 120
	ld	(ix - 7), l
	ld	(ix - 6), h
	ld	hl, 2
	push	hl
	pea	ix - 7
	.local	.LBB0_77
.LBB0_77:                               ;   in Loop: Header=BB0_21 Depth=1
	push	hl
	call	_send_cmd
	push	hl
	ld	l, (ix - 12)
	ld	h, (ix - 11)
	ex	(sp), hl
	pop	iy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _.str.10
	ld	(_status_msg), hl
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	ld	a, h
	ld	(_needs_blit), a
	ld	de, (_main.scroll_hold)
	.local	.LBB0_78
.LBB0_78:                               ;   in Loop: Header=BB0_21 Depth=1
	inc	de
	.local	.LBB0_79
.LBB0_79:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(_main.scroll_hold), de
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 1
	call	__sand
	bit	0, l
	ld	hl, 4
	ld	de, _.str.11
	jr	nz, .LBB0_82
; %bb.80:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, iyl
	bit	1, a
	ld	hl, 5
	ld	de, _.str.12
	jr	nz, .LBB0_82
; %bb.81:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, iyl
	bit	2, a
	ld	hl, 6
	ld	de, _.str.13
	jr	z, .LBB0_83
	.local	.LBB0_82
.LBB0_82:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(ix - 12), de
	ld	de, 0
	push	de
	push	de
	push	hl
	call	_send_cmd
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 12)
	ld	(_status_msg), hl
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	ld	a, h
	ld	(_needs_blit), a
	.local	.LBB0_83
.LBB0_83:                               ;   in Loop: Header=BB0_21 Depth=1
	bit	0, (ix - 18)                    ; 1-byte Folded Reload
	jr	z, .LBB0_86
	jr	.LBB0_89
	.local	.LBB0_84
.LBB0_84:                               ;   in Loop: Header=BB0_21 Depth=1
	or	a, a
	sbc	hl, hl
	ld	(_url_input_len), hl
	ld	hl, _url_input
	.local	.LBB0_85
.LBB0_85:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(hl), 0
	ld	a, b
	ld	(_needs_blit), a
	.local	.LBB0_86
.LBB0_86:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, (_needs_blit)
	bit	0, a
	jr	z, .LBB0_89
; %bb.87:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, (_click_anim)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB0_89
; %bb.88:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	a, (_url_bar_active)
	bit	0, a
	jr	z, .LBB0_92
	.local	.LBB0_89
.LBB0_89:                               ;   in Loop: Header=BB0_21 Depth=1
	call	_restore_cursor_bg
	call	_draw_chrome_bar
	ld	hl, (_click_anim)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB0_91
; %bb.90:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, 224
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	iy, (_cursor_x)
	ld	bc, (_cursor_y)
	ld	hl, (_click_anim)
	add	hl, hl
	ex	de, hl
	ld	hl, 10
	or	a, a
	sbc	hl, de
	push	hl
	push	bc
	push	iy
	call	_gfx_Circle
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (_click_anim)
	dec	hl
	ld	(_click_anim), hl
	.local	.LBB0_91
.LBB0_91:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, (_cursor_x)
	ld	de, (_cursor_y)
	push	de
	push	hl
	call	_save_and_draw_cursor
	pop	hl
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_Blit
	pop	hl
	ld	a, 1
	ld	(_needs_blit), a
	.local	.LBB0_92
.LBB0_92:                               ;   in Loop: Header=BB0_21 Depth=1
	call	_usb_HandleEvents
	call	_kb_Scan
	ld	hl, -720878
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 12), l
	ld	(ix - 11), h
	ld	hl, -720868
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	iyl, e
	ld	iyh, d
	pop	de
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 26), hl
	ld	hl, -720866
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	c, l
	ld	b, h
	ld	(ix - 18), bc
	ld	a, (_main.prev_g1)
	ld	e, (ix - 23)
	ld	d, (ix - 22)
	ld	e, a
	ld	a, (_main.prev_g6)
	ld	l, a
	ld	h, d
	call	__snot
	ld	c, l
	ld	b, h
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	call	__sand
	ld	(ix - 15), l
	ld	(ix - 14), h
	ld	l, (ix - 12)
	ld	h, (ix - 11)
	ld	a, l
	ld	(_main.prev_g1), a
	ld	a, iyl
	ld	(_main.prev_g6), a
	ld	a, l
	bit	4, a
	ld	l, e
	ld	h, d
	jp	z, .LBB0_21
	.local	.LBB0_93
.LBB0_93:                               ; %.loopexit
	call	_usb_Cleanup
	call	_gfx_End
	or	a, a
	sbc	hl, hl
	jr	.LBB0_97
	.local	.LBB0_94
.LBB0_94:
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, 224
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	ld	hl, 12
	push	hl
	push	hl
	ld	hl, _.str.7
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 1
	push	hl
	call	_gfx_Blit
	pop	hl
	.local	.LBB0_95
.LBB0_95:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB0_95
; %bb.96:
	call	_gfx_End
	ld	hl, 1
	.local	.LBB0_97
.LBB0_97:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_main, .Lfunc_end0-_main
                                        ; -- End function
	.section	.text._draw_chrome_bar,"ax",@progbits
	.type	_draw_chrome_bar,@function      ; -- Begin function draw_chrome_bar
_draw_chrome_bar:                       ; @draw_chrome_bar
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	hl, 27
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 16
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
	ld	hl, 54
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 320
	push	hl
	ld	hl, 16
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_HorizLine
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_url_bar_active)
	bit	0, a
	jp	z, .LBB1_10
; %bb.1:
	ld	hl, _.str.14+1
	ld	(ix - 3), hl
	ld	hl, _url_input+1
	ld	(ix - 9), hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 12
	push	hl
	ld	hl, 312
	push	hl
	ld	hl, 2
	push	hl
	ld	hl, 4
	push	hl
	call	_gfx_FillRectangle
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 31
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 12
	push	hl
	ld	hl, 312
	push	hl
	ld	hl, 2
	push	hl
	ld	hl, 4
	push	hl
	call	_gfx_Rectangle
	ld	bc, 71
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 8
	ex	de, hl
	push	de
	pop	iy
	.local	.LBB1_2
.LBB1_2:                                ; =>This Inner Loop Header: Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 252
	push	hl
	push	bc
	ld	hl, 4
	push	hl
	push	iy
	add	iy, de
	ld	(ix - 6), iy
	call	_draw_char
	ld	iy, (ix - 6)
	ld	de, 8
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	a, (hl)
	ld	c, a
	inc	hl
	ld	(ix - 3), hl
	or	a, a
	jr	nz, .LBB1_2
; %bb.3:
	ld	a, (_url_input)
	ld	iyl, a
	or	a, a
	jr	z, .LBB1_7
; %bb.4:                                ; %.preheader.preheader
	ld	bc, 36
	push	bc
	pop	hl
	.local	.LBB1_5
.LBB1_5:                                ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	ld	(ix - 3), bc
	add	hl, de
	ld	(ix - 6), hl
	ld	de, 0
	push	de
	ld	de, 255
	push	de
	push	iy
	ld	hl, 4
	push	hl
	push	bc
	call	_draw_char
	ld	de, 8
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	bc, 305
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB1_7
; %bb.6:                                ; %.preheader
                                        ;   in Loop: Header=BB1_5 Depth=1
	ld	hl, (ix - 9)
	ld	a, (hl)
	ld	iyl, a
	inc	hl
	ld	(ix - 9), hl
	ld	hl, (ix - 6)
	or	a, a
	push	hl
	pop	bc
	jr	nz, .LBB1_5
	.local	.LBB1_7
.LBB1_7:                                ; %.loopexit
	ld	a, (-851968)
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	ld	iy, 4
	jp	nz, .LBB1_18
; %bb.8:
	ld	de, (_url_input_len)
	ld	bc, 34
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB1_18
; %bb.9:
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, 36
	add	hl, de
	ld	de, 0
	push	de
	ld	de, 252
	push	de
	ld	de, 95
	push	de
	push	iy
	push	hl
	call	_draw_char
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	jp	.LBB1_18
	.local	.LBB1_10
.LBB1_10:
	ld	a, (_current_url)
	ld	iyl, a
	or	a, a
	jr	z, .LBB1_14
; %bb.11:                               ; %.preheader6.preheader
	ld	de, _current_url+1
	ld	(ix - 6), de
	ld	de, 6
	ld	bc, 255
	push	de
	pop	hl
	.local	.LBB1_12
.LBB1_12:                               ; %.preheader6
                                        ; =>This Inner Loop Header: Depth=1
	ld	(ix - 3), de
	ld	de, 8
	add	hl, de
	ld	(ix - 9), hl
	ld	de, 27
	push	de
	push	bc
	push	iy
	ld	hl, 4
	push	hl
	ld	hl, (ix - 3)
	push	hl
	call	_draw_char
	ld	bc, 255
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 3)
	ld	de, 305
	or	a, a
	sbc	hl, de
	jr	nc, .LBB1_14
; %bb.13:                               ; %.preheader6
                                        ;   in Loop: Header=BB1_12 Depth=1
	ld	hl, (ix - 6)
	ld	a, (hl)
	ld	iyl, a
	inc	hl
	ld	(ix - 6), hl
	ld	hl, (ix - 9)
	or	a, a
	push	hl
	pop	de
	jr	nz, .LBB1_12
	.local	.LBB1_14
.LBB1_14:                               ; %.loopexit7
	ld	iy, (_status_msg)
	ld	l, (iy)
	ld	a, l
	or	a, a
	jp	z, .LBB1_18
; %bb.15:                               ; %.preheader4.preheader
	ld	de, 220
                                        ; kill: def $l killed $l def $uhl
	inc	iy
	ld	(ix - 3), de
	.local	.LBB1_16
.LBB1_16:                               ; %.preheader4
                                        ; =>This Inner Loop Header: Depth=1
	ld	(ix - 6), iy
	ld	(ix - 9), de
	ld	bc, 8
	push	hl
	pop	iy
	ld	hl, (ix - 3)
	add	hl, bc
	ld	(ix - 3), hl
	ld	bc, 27
	push	bc
	ld	bc, 31
	push	bc
	push	iy
	ld	hl, 4
	push	hl
	push	de
	call	_draw_char
	ld	iy, (ix - 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 9)
	ld	bc, 305
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB1_18
; %bb.17:                               ; %.preheader4
                                        ;   in Loop: Header=BB1_16 Depth=1
	ld	a, (iy)
	ld	l, a
	inc	iy
	or	a, a
	ld	de, (ix - 3)
	jr	nz, .LBB1_16
	.local	.LBB1_18
.LBB1_18:                               ; %.loopexit5
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_draw_chrome_bar, .Lfunc_end1-_draw_chrome_bar
                                        ; -- End function
	.section	.text._draw_char,"ax",@progbits
	.type	_draw_char,@function            ; -- Begin function draw_char
_draw_char:                             ; @draw_char
; %bb.0:
	ld	hl, -10
	call	__frameset
	ld	a, (ix + 12)
	ld	bc, _font8x8_basic
	cp	a, 0
	call	pe, __setflag
	jp	p, .LBB2_2
; %bb.1:
	ld	a, 63
	.local	.LBB2_2
.LBB2_2:
	ld	iy, 0
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	push	bc
	pop	hl
	add	hl, de
	ld	(ix - 9), hl
	ld	hl, (ix + 9)
	ld	bc, 320
	call	__imulu
	ex	de, hl
	ld	hl, (ix + 6)
	add	hl, de
	lea	bc, iy + 0
	.local	.LBB2_3
.LBB2_3:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB2_5 Depth 2
	ld	(ix - 6), hl
	ld	(ix - 3), bc
	push	bc
	pop	hl
	ld	bc, (ix + 9)
	add	hl, bc
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB2_10
; %bb.4:                                ;   in Loop: Header=BB2_3 Depth=1
	ld	hl, (ix - 9)
	ld	de, (ix - 3)
	add	hl, de
	ld	a, (hl)
	ld	(ix - 10), a
	ld	bc, 0
	.local	.LBB2_5
.LBB2_5:                                ;   Parent Loop BB2_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	hl, (ix + 6)
	add	hl, bc
	ld	de, 320
	or	a, a
	sbc	hl, de
	jr	nc, .LBB2_9
; %bb.6:                                ;   in Loop: Header=BB2_5 Depth=2
	ld	hl, 1
	call	__ishl
	ld	e, (ix - 10)
	ld	a, l
	and	a, e
	ld	l, a
	ld	iy, (-1900524)
	ld	de, (ix - 6)
	add	iy, de
	add	iy, bc
	or	a, a
	ld	a, (ix + 18)
	jr	z, .LBB2_8
; %bb.7:                                ;   in Loop: Header=BB2_5 Depth=2
	ld	a, (ix + 15)
	.local	.LBB2_8
.LBB2_8:                                ;   in Loop: Header=BB2_5 Depth=2
	ld	(iy), a
	.local	.LBB2_9
.LBB2_9:                                ;   in Loop: Header=BB2_5 Depth=2
	inc	bc
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	jr	nz, .LBB2_5
	.local	.LBB2_10
.LBB2_10:                               ; %.loopexit
                                        ;   in Loop: Header=BB2_3 Depth=1
	ld	bc, (ix - 3)
	inc	bc
	ld	iy, (ix - 6)
	ld	de, 320
	add	iy, de
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jp	nz, .LBB2_3
; %bb.11:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_draw_char, .Lfunc_end2-_draw_char
                                        ; -- End function
	.section	.text._save_and_draw_cursor,"ax",@progbits
	.type	_save_and_draw_cursor,@function ; -- Begin function save_and_draw_cursor
_save_and_draw_cursor:                  ; @save_and_draw_cursor
; %bb.0:
	ld	hl, -12
	call	__frameset
	ld	iy, (ix + 6)
	ld	hl, (ix + 9)
	ld	bc, 320
	ld	de, _cursor_sprite
	ld	(ix - 3), de
	ld	de, _cursor_saved
	ld	(ix - 6), de
	ld	(_saved_x), iy
	ld	(_saved_y), hl
	call	__imulu
	ex	de, hl
	lea	hl, iy + 0
	add	hl, de
	ld	bc, 0
	.local	.LBB3_1
.LBB3_1:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB3_3 Depth 2
	ld	(ix - 9), hl
	ld	(ix - 12), bc
	push	bc
	pop	hl
	ld	bc, (ix + 9)
	add	hl, bc
	ld	de, 240
	or	a, a
	sbc	hl, de
	jr	nc, .LBB3_9
; %bb.2:                                ; %.preheader.preheader
                                        ;   in Loop: Header=BB3_1 Depth=1
	ld	bc, 0
	.local	.LBB3_3
.LBB3_3:                                ; %.preheader
                                        ;   Parent Loop BB3_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	hl, (ix + 6)
	add	hl, bc
	ld	de, 320
	or	a, a
	sbc	hl, de
	jr	nc, .LBB3_8
; %bb.4:                                ;   in Loop: Header=BB3_3 Depth=2
	ld	hl, (-1900524)
	ld	de, (ix - 9)
	add	hl, de
	add	hl, bc
	ld	a, (hl)
	ld	iy, (ix - 6)
	add	iy, bc
	ld	(iy), a
	ld	iy, (ix - 3)
	add	iy, bc
	ld	a, (iy)
	cp	a, 1
	ld	l, 0
	jr	z, .LBB3_7
; %bb.5:                                ;   in Loop: Header=BB3_3 Depth=2
	cp	a, 2
	jr	nz, .LBB3_8
; %bb.6:                                ;   in Loop: Header=BB3_3 Depth=2
	ld	a, -1
	ld	l, a
	ld	de, (ix - 9)
	.local	.LBB3_7
.LBB3_7:                                ;   in Loop: Header=BB3_3 Depth=2
	ld	a, l
	ld	hl, (-1900524)
	add	hl, de
	add	hl, bc
	ld	(hl), a
	.local	.LBB3_8
.LBB3_8:                                ;   in Loop: Header=BB3_3 Depth=2
	inc	bc
	push	bc
	pop	hl
	ld	de, 9
	or	a, a
	sbc	hl, de
	jr	nz, .LBB3_3
	.local	.LBB3_9
.LBB3_9:                                ; %.loopexit
                                        ;   in Loop: Header=BB3_1 Depth=1
	ld	bc, (ix - 12)
	inc	bc
	ld	hl, (ix - 9)
	ld	de, 320
	add	hl, de
	ld	(ix - 9), hl
	ld	iy, (ix - 6)
	lea	iy, iy + 9
	ld	(ix - 6), iy
	ld	iy, (ix - 3)
	lea	iy, iy + 9
	ld	(ix - 3), iy
	push	bc
	pop	hl
	ld	de, 12
	or	a, a
	sbc	hl, de
	ld	hl, (ix - 9)
	jp	nz, .LBB3_1
; %bb.10:
	ld	a, 1
	ld	(_cursor_is_saved), a
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_save_and_draw_cursor, .Lfunc_end3-_save_and_draw_cursor
                                        ; -- End function
	.section	.text._usb_event,"ax",@progbits
	.type	_usb_event,@function            ; -- Begin function usb_event
_usb_event:                             ; @usb_event
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	iy, (ix + 6)
	ld	de, 0
	xor	a, a
	ld	bc, 12
	lea	hl, iy + 0
	sbc	hl, bc
	jr	nz, .LBB4_4
; %bb.1:
	ld	hl, 8
	push	hl
	push	de
	push	de
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
	jr	z, .LBB4_3
; %bb.2:
	or	a, a
	sbc	hl, hl
	push	hl
	push	bc
	call	_usb_SetEndpointFlags
	pop	hl
	pop	hl
	ld	de, (_ep_out)
	.local	.LBB4_3
.LBB4_3:
	sbc	hl, hl
	adc	hl, de
	ld	hl, 0
	push	hl
	push	de
	call	nz, _usb_SetEndpointFlags
	pop	hl
	pop	hl
	xor	a, a
	ld	(_tx_busy), a
	ld	hl, _.str.16
	ld	(_status_msg), hl
	call	_queue_rx
	ld	de, 0
	jr	.LBB4_6
	.local	.LBB4_4
.LBB4_4:
	ld	bc, -3
	lea	hl, iy + 0
	call	__iand
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB4_6
; %bb.5:
	ld	hl, _.str.17
	ld	(_ep_in), de
	ld	(_ep_out), de
	ld	(_rx_pending), a
	ld	(_tx_busy), a
	ld	(_status_msg), hl
	.local	.LBB4_6
.LBB4_6:
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_usb_event, .Lfunc_end4-_usb_event
                                        ; -- End function
	.section	.text._send_cmd,"ax",@progbits
	.type	_send_cmd,@function             ; -- Begin function send_cmd
_send_cmd:                              ; @send_cmd
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	de, (_ep_in)
	ld	(ix - 3), de
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB5_10
; %bb.1:
	ld	l, (ix + 6)
	ld	iy, (ix + 12)
	ld	a, 1
	ld	e, 66
	ld	c, 82
	ld	h, 79
	ld	d, 87
	ld	b, 0
	ld	(_tx_busy), a
	ld	a, e
	ld	(_tx_pkt), a
	ld	a, c
	ld	(_tx_pkt+1), a
	ld	a, h
	ld	(_tx_pkt+2), a
	ld	a, d
	ld	(_tx_pkt+3), a
	ld	a, l
	ld	(_tx_pkt+4), a
	ld	a, b
	lea	bc, iy + 0
	ld	(_tx_pkt+5), a
	ld.sis	de, 56
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	jr	c, .LBB5_3
; %bb.2:
	ld.sis	iy, 56
	.local	.LBB5_3
.LBB5_3:
	ld	hl, _tx_pkt+6
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	ld	de, 0
	ld	e, iyl
	ld	d, iyh
	ld	(ix - 6), de
	ld	hl, (ix + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB5_6
; %bb.4:
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jr	z, .LBB5_6
; %bb.5:
	ld	hl, (ix - 6)
	push	hl
	ld	hl, (ix + 9)
	push	hl
	ld	hl, _tx_pkt+8
	push	hl
	call	_memcpy
	ld	bc, (ix + 12)
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB5_6
.LBB5_6:
	ld	de, _tx_pkt
	ld	l, c
	ld	h, b
	ld.sis	bc, 56
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB5_8
; %bb.7:
	ld	hl, 56
	ld	bc, (ix - 6)
	ld	iy, _tx_pkt+8
	add	iy, bc
	or	a, a
	sbc	hl, bc
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	iy
	call	_memset
	ld	de, _tx_pkt
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB5_8
.LBB5_8:
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, _tx_complete
	push	hl
	ld	hl, 64
	push	hl
	push	de
	ld	hl, (ix - 3)
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
	jr	z, .LBB5_10
; %bb.9:
	xor	a, a
	ld	(_tx_busy), a
	.local	.LBB5_10
.LBB5_10:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_send_cmd, .Lfunc_end5-_send_cmd
                                        ; -- End function
	.section	.text._restore_cursor_bg,"ax",@progbits
	.type	_restore_cursor_bg,@function    ; -- Begin function restore_cursor_bg
_restore_cursor_bg:                     ; @restore_cursor_bg
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	a, (_cursor_is_saved)
	bit	0, a
	jp	z, .LBB6_10
; %bb.1:                                ; %.preheader.preheader
	xor	a, a
	ld	iy, _cursor_saved
	sbc	hl, hl
	ld	(ix - 3), hl
	push	hl
	pop	bc
	.local	.LBB6_2
.LBB6_2:                                ; %.preheader
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_4 Depth 2
	ld	(ix - 6), iy
	ld	iy, (_saved_y)
	lea	hl, iy + 0
	ld	(ix - 9), bc
	add	hl, bc
	ld	de, 240
	or	a, a
	sbc	hl, de
	jr	nc, .LBB6_8
; %bb.3:                                ;   in Loop: Header=BB6_2 Depth=1
	ld	de, (_saved_x)
	lea	hl, iy + 0
	ld	bc, 320
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix - 3)
	add	hl, bc
	ld	(ix - 15), hl
	ld	bc, 0
	.local	.LBB6_4
.LBB6_4:                                ;   Parent Loop BB6_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 12), de
	ex	de, hl
	add	hl, bc
	ld	de, 320
	or	a, a
	sbc	hl, de
	jr	c, .LBB6_6
; %bb.5:                                ;   in Loop: Header=BB6_4 Depth=2
	ld	iy, (ix - 12)
	jr	.LBB6_7
	.local	.LBB6_6
.LBB6_6:                                ;   in Loop: Header=BB6_4 Depth=2
	ld	iy, (ix - 6)
	add	iy, bc
	ld	a, (iy)
	ld	hl, (-1900524)
	ld	de, (ix - 12)
	add	hl, de
	ld	de, (ix - 15)
	add	hl, de
	add	hl, bc
	ld	(hl), a
	xor	a, a
	ld	iy, (_saved_x)
	.local	.LBB6_7
.LBB6_7:                                ;   in Loop: Header=BB6_4 Depth=2
	inc	bc
	push	bc
	pop	hl
	ld	de, 9
	or	a, a
	sbc	hl, de
	lea	de, iy + 0
	jr	nz, .LBB6_4
	.local	.LBB6_8
.LBB6_8:                                ; %.loopexit
                                        ;   in Loop: Header=BB6_2 Depth=1
	ld	bc, (ix - 9)
	inc	bc
	ld	de, 320
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	ld	iy, (ix - 6)
	lea	iy, iy + 9
	push	bc
	pop	hl
	ld	de, 12
	or	a, a
	sbc	hl, de
	jp	nz, .LBB6_2
; %bb.9:
	ld	(_cursor_is_saved), a
	.local	.LBB6_10
.LBB6_10:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_restore_cursor_bg, .Lfunc_end6-_restore_cursor_bg
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
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_tx_complete, .Lfunc_end7-_tx_complete
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
	jr	z, .LBB8_4
; %bb.1:
	ld	a, (_rx_pending)
	bit	0, a
	jr	nz, .LBB8_4
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
	jr	z, .LBB8_4
; %bb.3:
	xor	a, a
	ld	(_rx_pending), a
	.local	.LBB8_4
.LBB8_4:
	pop	ix
	ret
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_queue_rx, .Lfunc_end8-_queue_rx
                                        ; -- End function
	.section	.text._rx_complete,"ax",@progbits
	.type	_rx_complete,@function          ; -- Begin function rx_complete
_rx_complete:                           ; @rx_complete
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	hl, (ix + 9)
	xor	a, a
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB9_23
; %bb.1:
	ld	hl, (ix + 12)
	ld	de, 8
	or	a, a
	sbc	hl, de
	jp	c, .LBB9_23
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
	cp	a, 66
	ld	a, 0
	jp	nz, .LBB9_23
; %bb.3:
	ld	a, c
	cp	a, 82
	ld	a, 0
	jp	nz, .LBB9_23
; %bb.4:
	ld	a, e
	cp	a, 79
	ld	a, 0
	jp	nz, .LBB9_23
; %bb.5:
	ld	a, l
	cp	a, 87
	ld	a, 0
	jp	nz, .LBB9_23
; %bb.6:
	ld	hl, _rx_pkt+6
	ld	a, (_rx_pkt+4)
	ld	de, (hl)
	ld.sis	bc, 56
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	ld	iyl, e
	ld	iyh, d
	jr	c, .LBB9_8
; %bb.7:
	ld.sis	iy, 56
	.local	.LBB9_8
.LBB9_8:
	ld	l, -16
	add	a, l
	ld	l, a
	cp	a, 6
	ld	a, 0
	jp	nc, .LBB9_23
; %bb.9:
	ld	bc, 0
	ld	c, l
	ld	hl, JTI9_0
	add	hl, bc
	add	hl, bc
	add	hl, bc
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB9_10
.LBB9_10:
	call	_restore_cursor_bg
	or	a, a
	sbc	hl, hl
	ld	(_page_write_idx), hl
	ld	hl, _.str.18
	ld	(_status_msg), hl
	.local	.LBB9_11
.LBB9_11:
	xor	a, a
	ld	(_tx_busy), a
	jp	.LBB9_22
	.local	.LBB9_12
.LBB9_12:
	ld	de, _current_url
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 3), hl
	push	hl
	ld	hl, _rx_pkt+8
	push	hl
	push	de
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _current_url
	ld	de, (ix - 3)
	add	hl, de
	ld	(hl), 0
	jp	.LBB9_21
	.local	.LBB9_13
.LBB9_13:
	ld.sis	bc, 2
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jp	c, .LBB9_23
; %bb.14:
	ld	bc, 1
	ld	hl, (-1900524)
	ld	(ix - 12), hl
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 9), hl
	ld	hl, (_page_write_idx)
	ld	(ix - 3), hl
	sbc	hl, hl
	ex	de, hl
	.local	.LBB9_15
.LBB9_15:                               ; =>This Inner Loop Header: Depth=1
	ld	iy, _rx_pkt+8
	lea	hl, iy + 0
	ld	(ix - 6), de
	add	hl, de
	ld	l, (hl)
	ld	de, 0
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	ld	e, l
	ld	hl, (ix - 3)
	add	hl, de
	ld	de, 76801
	or	a, a
	sbc	hl, de
	jr	c, .LBB9_17
; %bb.16:                               ;   in Loop: Header=BB9_15 Depth=1
	ld	hl, (ix - 3)
	sub	a, l
	ld	iyl, a
	.local	.LBB9_17
.LBB9_17:                               ;   in Loop: Header=BB9_15 Depth=1
	ld	a, iyl
	or	a, a
	ld	de, 0
	jr	z, .LBB9_19
; %bb.18:                               ;   in Loop: Header=BB9_15 Depth=1
	ld	a, iyl
	ld	hl, _rx_pkt+8
	add	hl, bc
	ld	l, (hl)
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	ld	e, a
	push	de
	pop	bc
	ld	(ix - 15), bc
	ld	hl, (ix - 12)
	ld	de, (ix - 3)
	add	hl, de
	push	bc
	ld	e, iyl
	push	de
	push	hl
	call	_memset
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (_page_write_idx)
	ld	de, (ix - 15)
	add	hl, de
	ld	(_page_write_idx), hl
	ld	(ix - 3), hl
	.local	.LBB9_19
.LBB9_19:                               ;   in Loop: Header=BB9_15 Depth=1
	xor	a, a
	ld	hl, (ix - 6)
	ld	de, 2
	add	hl, de
	ld	bc, 65535
	call	__iand
	push	hl
	pop	iy
	lea	bc, iy + 0
	inc	bc
	push	bc
	pop	hl
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	lea	de, iy + 0
	jp	c, .LBB9_15
	jr	.LBB9_23
	.local	.LBB9_20
.LBB9_20:
	ld	hl, _.str.19
	ld	(_status_msg), hl
	xor	a, a
	ld	(_tx_busy), a
	.local	.LBB9_21
.LBB9_21:                               ; %.loopexit
	xor	a, a
	ld	(_needs_blit), a
	.local	.LBB9_22
.LBB9_22:                               ; %.loopexit
	xor	a, a
	.local	.LBB9_23
.LBB9_23:                               ; %.loopexit
	ld	(_rx_pending), a
	call	_queue_rx
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB9_24
.LBB9_24:
	ld	iy, _rx_pkt+8
	ld.sis	bc, 39
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jr	c, .LBB9_26
; %bb.25:
	ld.sis	de, 39
	.local	.LBB9_26
.LBB9_26:
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 3), hl
	push	hl
	push	iy
	ld	hl, _rx_complete.dynamic_status
	push	hl
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	bc, _rx_complete.dynamic_status
	push	bc
	pop	hl
	ld	de, (ix - 3)
	add	hl, de
	ld	(hl), 0
	ld	(_status_msg), bc
	xor	a, a
	ld	(_needs_blit), a
	jr	.LBB9_23
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_rx_complete, .Lfunc_end9-_rx_complete
	.section	.rodata._rx_complete,"a",@progbits
JTI9_0:
	d24	.LBB9_10
	d24	.LBB9_13
	d24	.LBB9_20
	d24	.LBB9_12
	d24	.LBB9_24
	d24	.LBB9_11
                                        ; -- End function
	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"TI-84 Graphical Web Browser"

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"1. Connect USB cable to laptop"

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"2. Open doomvision /browser"

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"Controls:"

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"[Arrows] Move Mouse   [ENTER] Click"

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"[+] / [-] Scroll Page  [WINDOW] URL"

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"[GRAPH] Back           [Y=] Quit"

	.section	.data._cursor_x,"aw",@progbits
	.balign	1
	.local	_cursor_x
_cursor_x:
	d24	160                             ; 0xa0

	.section	.data._cursor_y,"aw",@progbits
	.balign	1
	.local	_cursor_y
_cursor_y:
	d24	120                             ; 0x78

	.section	.rodata._descriptors,"a",@progbits
	.balign	1
	.local	_descriptors
_descriptors:
	d24	_device
	d24	_configs
	d24	_lang
	db	1                               ; 0x1
	d24	_strings

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"USB Init Failed!"

	.section	.bss._main.prev_g1,"aw",@nobits
	.balign	1
	.local	_main.prev_g1
_main.prev_g1:
	.zero	1

	.section	.bss._main.prev_g6,"aw",@nobits
	.balign	1
	.local	_main.prev_g6
_main.prev_g6:
	.zero	1

	.section	.bss._main.scroll_hold,"aw",@nobits
	.balign	1
	.local	_main.scroll_hold
_main.scroll_hold:
	.zero	3

	.section	.bss._url_bar_active,"aw",@nobits
	.balign	1
	.local	_url_bar_active
_url_bar_active:
	.zero	1

	.section	.bss._url_input,"aw",@nobits
	.balign	1
	.local	_url_input
_url_input:
	.zero	64

	.section	.data._current_url,"aw",@progbits
	.balign	1
	.local	_current_url
_current_url:
	.asciz	"https://wikipedia.org\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

	.section	.bss._url_input_len,"aw",@nobits
	.balign	1
	.local	_url_input_len
_url_input_len:
	.zero	3

	.section	.bss._needs_blit,"aw",@nobits
	.balign	1
	.local	_needs_blit
_needs_blit:
	.zero	1

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"Navigating\342\200\246"

	.section	.data._status_msg,"aw",@progbits
	.balign	1
	.local	_status_msg
_status_msg:
	d24	_.str.17

	.section	.bss._hold_duration,"aw",@nobits
	.balign	1
	.local	_hold_duration
_hold_duration:
	.zero	3

	.section	.bss._click_anim,"aw",@nobits
	.balign	1
	.local	_click_anim
_click_anim:
	.zero	3

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"Clicked"

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"Scrolling\342\200\246"

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"Going Back\342\200\246"

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"Going Forward\342\200\246"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"Reloading\342\200\246"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"Go: "

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

	.section	.data._saved_x,"aw",@progbits
	.balign	1
	.local	_saved_x
_saved_x:
	d24	160                             ; 0xa0

	.section	.data._saved_y,"aw",@progbits
	.balign	1
	.local	_saved_y
_saved_y:
	d24	120                             ; 0x78

	.section	.bss._cursor_saved,"aw",@nobits
	.balign	1
	.local	_cursor_saved
_cursor_saved:
	.zero	108

	.section	.bss._cursor_is_saved,"aw",@nobits
	.balign	1
	.local	_cursor_is_saved
_cursor_is_saved:
	.zero	1

	.section	.rodata._cursor_sprite,"a",@progbits
	.balign	1
	.local	_cursor_sprite
_cursor_sprite:
	db	1                               ; 0x1
	.zero	8
	.asciz	"\001\001\000\000\000\000\000\000"
	.asciz	"\001\002\001\000\000\000\000\000"
	.asciz	"\001\002\002\001\000\000\000\000"
	.asciz	"\001\002\002\002\001\000\000\000"
	.asciz	"\001\002\002\002\002\001\000\000"
	.asciz	"\001\002\002\002\002\002\001\000"
	.asciz	"\001\002\002\002\001\001\001\001"
	.asciz	"\001\002\001\002\001\000\000\000"
	.asciz	"\001\001\000\001\002\001\000\000"
	.asciz	"\000\000\000\000\001\002\001\000"
	.asciz	"\000\000\000\000\000\001\001\000"

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

	.section	.bss._tx_busy,"aw",@nobits
	.balign	1
	.local	_tx_busy
_tx_busy:
	.zero	1

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"Connected \302\267 Loading\342\200\246"

	.section	.bss._rx_pending,"aw",@nobits
	.balign	1
	.local	_rx_pending
_rx_pending:
	.zero	1

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"Connect USB to Browse"

	.section	.bss._rx_pkt,"aw",@nobits
	.balign	1
	.local	_rx_pkt
_rx_pkt:
	.zero	64

	.section	.bss._page_write_idx,"aw",@nobits
	.balign	1
	.local	_page_write_idx
_page_write_idx:
	.zero	3

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"Receiving page\342\200\246"

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"Ready"

	.section	.bss._rx_complete.dynamic_status,"aw",@nobits
	.balign	1
	.local	_rx_complete.dynamic_status
_rx_complete.dynamic_status:
	.zero	40

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
	.asciz	"\t\002 \000\001\001\000\2002\t\004\000\000\002\377E\002\000\007\005\201\002@\000\000\007\005\002\002@\000"

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
	db	34                              ; 0x22
	db	3                               ; 0x3
	dw	84                              ; 0x54
	dw	73                              ; 0x49
	dw	45                              ; 0x2d
	dw	56                              ; 0x38
	dw	52                              ; 0x34
	dw	32                              ; 0x20
	dw	87                              ; 0x57
	dw	101                             ; 0x65
	dw	98                              ; 0x62
	dw	32                              ; 0x20
	dw	66                              ; 0x42
	dw	114                             ; 0x72
	dw	111                             ; 0x6f
	dw	119                             ; 0x77
	dw	115                             ; 0x73
	dw	101                             ; 0x65
	dw	114                             ; 0x72
	dw	0                               ; 0x0

	.section	.bss._tx_pkt,"aw",@nobits
	.balign	1
	.local	_tx_pkt
_tx_pkt:
	.zero	64

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_usb_Cleanup
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_llvm.smin.i24
	.extern	_usb_HandleEvents
	.extern	_strncpy
	.extern	_gfx_FillRectangle
	.extern	_llvm.smax.i24
	.extern	_llvm.lifetime.end.p0
	.extern	_memcpy
	.extern	__ishru
	.extern	_llvm.eh.sjlj.lsda
	.extern	_usb_GetDeviceEndpoint
	.extern	__sor
	.extern	_gfx_FillScreen
	.extern	__Unwind_SjLj_Unregister
	.extern	_strlen
	.extern	__frameset
	.extern	__bshru
	.extern	_kb_Scan
	.extern	_usb_FindDevice
	.extern	_memset
	.extern	__iand
	.extern	__imulu
	.extern	_usb_Init
	.extern	__setflag
	.extern	_usb_ScheduleTransfer
	.extern	_gfx_PrintStringXY
	.extern	__snot
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_gfx_SetColor
	.extern	_os_GetCSC
	.extern	_llvm.memset.p0.i24
	.extern	_llvm.eh.sjlj.callsite
	.extern	_gfx_End
	.extern	_gfx_Circle
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.stacksave.p0
	.extern	_llvm.lifetime.start.p0
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.umin.i16
	.extern	_llvm.frameaddress.p0
	.extern	_gfx_Rectangle
	.extern	__sshl
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	__smulu
	.extern	_gfx_Blit
	.extern	_gfx_HorizLine
	.extern	_gfx_SetDraw
	.extern	__ishl
	.extern	_gfx_SetTextFGColor
	.extern	_usb_SetEndpointFlags
	.extern	_gfx_Begin
