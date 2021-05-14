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
	
	ld ix,#ACA4			; ASCII-Buffer for Input&List, free on 464,664,6128
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
	
	ld a,12	; Length
	pop de

	call OLED_PRINTTEXT_Main_WithoutRSX_Parse		; A=Length & DE=Pointer
	
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
	
	
	; test High-Bytes
	ld a,0
	cp (ix+1)
	jp nz,RSX_Error
	cp (ix+3)
	jp nz,RSX_Error
	
	; Get Left/Right-Value (8Bit depth)
	LD  e,(IX+0)
	LD  d,(IX+2)



	di
	push de	; D=left VU		E=right VU
	
	call MP3_App_Cancel
	
	call wait_for_ARM_response

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

	call wait_for_ARM_response
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
	call wait_for_ARM_response

	; active function
	ld bc,#FD41
	ld a,125
	out (c),a

	call wait_for_ARM_response

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
	call wait_for_ARM_response
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
	jp wait_for_ARM_response	
	
SendCMDSubsetForPointer0_V2:
	push af
;	call wait_for_ARM_response                    not needed for RTC-Reset & DFU-Display
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
	jp wait_for_ARM_response	
	
