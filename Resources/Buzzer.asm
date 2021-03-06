;80d	Set buzzer
;
;	Note: 	Tone 	00 buzzer off
;			01 low
;			02 middle
;			03 high
;
;		rhythm	00 continu
;			01 slow
;			02 middle
;			03 fast
;
;	if (&FD41 = 1) return 		check busy?
;	out &FD41,0d			reset intern write buffer pointers (RTC, mouse, oled)
;	out &FD42, tone		2 bits
;	out &FD42, rhythm		2 bits
;REM out &FD42, res		
;	REM Out &FD42, res	
;	out &FD41,80d			active function	
;
;	while (inp (&FD41 == 1)	wait processing 0 = oke 1 = busy 

buzz:		; |buzz,tone,rhythm
	cp 2
	jr z,buzz_Main
	cp 0
	jp nz,RSX_Error
	ld hl,0
	jr buzz_Main2
	
buzz_Main
	; High-Bytes test
	ld a,0
	cp (ix+1)
	jp nz,RSX_Error
	cp (ix+3)
	jp nz,RSX_Error
	
	; values ok?
	ld a,3
	LD  l,(IX+0)
    cp  l
	jp 	c,RSX_Error
	LD  h,(IX+2)
    cp  h
	jp 	c,RSX_Error


buzz_Main2
	di
	call wait_for_ARM_response
	
	ld bc,#FD41
	ld a,#0
	out (c),a
	inc bc
	
	out (c),h
	out (c),l
	
	dec bc
	ld a,80
	out (c),a
	
	call wait_for_ARM_response
	ei
	
	ret