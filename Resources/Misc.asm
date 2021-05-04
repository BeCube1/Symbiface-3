MemTest:

	di
	
	ld a,1
	call SendCMDSubsetForPointer0

	ei
	ret

; ------------------------------------------------------------------------------

GetErrorText:
	di
	ld a,5
	call SendCMDSubsetForPointer0
	

	ld bc,#FD42
GetErrorText_loop:
	in a,(c)
	cp 10
	jr z,GetErrorText_exit
	call #bb5a
	jr GetErrorText_loop
GetErrorText_exit
	call #bb5a
	ei
	ret

GetError4OLED:
	di
	

	ld a,5
	call SendCMDSubsetForPointer0
	
	ld ix,#ACA4		; ASCII-Buffer for Input&List, free on 464,664,6128
	push ix	
	ld bc,#FD42
GetError4OLED_loop:
	in a,(c)
	cp 10
	jr z,GetError4OLED_exit
	ld (ix),a
	inc ix
	jr GetError4OLED_loop
GetError4OLED_exit
	ld (ix),a
	ld (ix+1),0
	
	
;	push ix
;	ld ix,OLED_DEFAULT_SCROLL_PARAMS
;	call OLED_SCROLL_SET_MAIN
;	pop ix

;	ld de,0
;	ld a,10
;	call SYM3_OLED_Init_PrintText		; IN:     A=Font types 	10,18,26, DE=XY

	
	ld a,12	; Length
	pop de



	call OLED_PRINTTEXT_Main_WithoutRSX_Parse		; A=Length & DE=Pointer
;	ex de,hl
;	ld a,10
;	ld de,0
;	call SYM3_OLED_PrintText
	
	ei
	ret	
	
	

	
	
; ------------------------------------------------------------------------------

LEDtest:
	di
	
	ld a,6
	call SendCMDSubsetForPointer0
	
	ei
	ret


; ------------------------------------------------------------------------------

LED_Set_VU:
	cp 2
	jp nz,RSX_Error
	
	; letzter
	;ld c,(ix+0)

	; erster
	;ld c,(ix+2)

	
	; High-Bytes testen
	ld a,0
	cp (ix+1)
	jp nz,RSX_Error
	cp (ix+3)
	jp nz,RSX_Error
	
	; Werte ok?
	; bis 255 erlaubt
;	ld a,3   + 10
	LD  e,(IX+0)
;    cp  e
;	jp 	c,RSX_Error
	LD  d,(IX+2)
;    cp  d
;	jp 	c,RSX_Error




	di
	push de	; D=left VU		E=right VU
	
	call MP3_App_Cancel
	
	call SYM3_OLED_WaitReady

	; reset write buffer pointers0
	ld bc,#FD41
	ld a,0
	out (c),a

	; active subfuntion
	ld bc,#FD42
	ld a,7
	out (c),a

	; set LED values
	pop de
	out (c),d
	out (c),e
	

	; active function
	ld bc,#FD41
	ld a,72
	out (c),a

	call SYM3_OLED_WaitReady
	ei
	ret
; ------------------------------------------------------------------------------
			
MP3_App_Cancel	
	; reset write buffer pointers0
	ld bc,#FD41
	ld a,0
	out (c),a

	; active subfuntion
	ld bc,#FD42
	ld a,0			; app 0 = disable mp3
	out (c),a
					
	; active function
	ld bc,#FD41
	ld a,40
	out (c),a
	
	ret

; ------------------------------------------------------------------------------
GetMeasurements

	di
	call SYM3_OLED_WaitReady

	; active function
	ld bc,#FD41
	ld a,125
	out (c),a

	call SYM3_OLED_WaitReady

	ld bc,#FD42
GetMeasurements_loop:
	in a,(c)
	cp 10
	jr z,GetMeasurements_exit
	call #bb5a
	cp 13
	jr nz,GetMeasurements_loop
	ld a,10
	call &bb5a
	jr GetMeasurements_loop
GetMeasurements_exit
;	call #bb5a
	ei
	ret
	
; ------------------------------------------------------------------------------


SendCMDSubsetForPointer0:
	push af
	call SYM3_OLED_WaitReady
	; reset write buffer pointers0
	ld bc,#FD41
	ld a,0
	out (c),a
	; active subfuntion
	pop af
	inc bc		;ld bc,#FD42
	out (c),a
	; active function
	dec bc		;ld bc,#FD41
	ld a,72
	out (c),a
	jp SYM3_OLED_WaitReady	
	
SendCMDSubsetForPointer0_V2:
	push af
;	call SYM3_OLED_WaitReady                    für RTC-Reset & DFU-Anzeige nicht benötigt
	; reset write buffer pointers0
	ld bc,#FD41
	ld a,0
	out (c),a
	; active subfuntion
	pop af
	inc bc		;ld bc,#FD42
	out (c),a
	; active function
	dec bc		;ld bc,#FD41
	ld a,72
	out (c),a
	jp SYM3_OLED_WaitReady	
	
































































PrintRXSize2OLED
ret
push af
push de
push bc
push hl
push ix

;	call get_wifi_rx_content
	ld a,"("
	call &bb5a
	call SUB_Print_16BitHex		; ####	
	ld a,")"
	call &bb5a	
	jr PrintRXSize2OLED_Exit
	
	push de   
	call RSX_OLED_CLS
	pop hl
SUB_Print_16BitHex2OLED:	
	ld ix,#bf00
	ld a,h
	call SUB_Print_8BitHex2OLED
	ld (ix+0),a
	ld a,l
	call SUB_Print_8BitHex2OLED
	ld (ix+1),a
	ld (ix+2),0
	push ix
	pop hl
	call Text2OLED_Upper

PrintRXSize2OLED_Exit:
pop ix
pop hl
pop bc
pop de
pop af	
	ret
	
	

	
	
	
SUB_Print_8BitHex2OLED:
	push af
	srl a
	srl a
	srl a
	srl a
	
	call print_hex_digi2OLED
	pop af
	and &X1111

print_hex_digi2OLED:	
	cp 10
	jr c,print_hex_digi2OLED1
	add a,"A"-10
	jr print_hex_digi2OLED2
print_hex_digi2OLED1:
	add a,"0"
print_hex_digi2OLED2:
	;jp  txt_output	
	ret


	
NET_DEBUG_OLED

	push hl
	call RSX_OLED_CLS
	pop hl
	ld a,18
	ld de,#0101
	call SYM3_OLED_PrintText
	ret

NET_DEBUG2_OLED_VALUE ; in A
	add a,"0"
	ld (#bf00),a
	ld a,0
	ld (#bf01),a
	ld a,18
	ld de,#0110
	ld hl,#bf00
	jp SYM3_OLED_PrintText
	



; ------------------------------------------------------------------------------
;;get_wifi_rx_content
;; in   a = socket
;;out   de = content 16 bit
;
;    push 	af
;    call 	Wait4ARM_is_busy
;
;	; reset write buffer pointers0
;	ld 		bc,$FD41
;	ld 		a,7
;	out 	(c),a
;	
;	; active subfuntion
;	ld 		bc,$FD49
;	ld 		a,6
;	out 	(c),a
;	
;	; socket channel number  n = 0-3 
;	pop 	af
;	out 	(c),a
;
;	; activate function
;	ld 		bc,$FD41
;	ld 		a,90
;	out 	(c),a
;	
;    call 	Wait4ARM_is_busy
;	
;    
;    ld 		bc,$fd49
;    in 		a,(c)
;    ld 		d,a    
;    in 		a,(c)
;    ld 		e,a
;    ret
    
