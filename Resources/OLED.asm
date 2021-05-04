; ------------------------------------------------------------------------
;201d	Oled Write data to SSD1306
;
;	if (&FD41 = 1) return 		check busy?
;	out &FD41,0d				reset intern write buffer pointers				
;
;	example scroll to right
;	out &FD42, 0x2E			De-Activated scroll
;	out &FD42, 0xA3			Direction
;	out &FD42, 0x00			Dummy
;	out &FD42, 0x00			Start page
;	out &FD42, 0x02			Interval
;	out &FD42, 0x02			End page
;	out &FD42, 0x0B			vertical scolling offset
;	out &FD42, 0x2F			Activated scroll
 ;	..
;	..
;	..	
;	out &FD41,201d				actie function
;	while (inp (&FD41 == 1)		wait processing 0 = oke 1 = busy 2 = error

OLED_DEFAULT_SCROLL_PARAMS
	defb #2F,0,#1b,0,2,0,4,0,0,0,#A3,0,#2E,0

RSX_OLED_SCROLL
	cp 7
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
	cp (ix+5)
	jp nz,RSX_Error
	cp (ix+7)
	jp nz,RSX_Error
	cp (ix+9)
	jp nz,RSX_Error
	cp (ix+11)
	jp nz,RSX_Error
	cp (ix+13)
	jp nz,RSX_Error
	
	
	
OLED_SCROLL_SET_MAIN
	di
	call SYM3_OLED_WaitReady
	
	ld bc,#FD42
	
	;	out &FD42, 0x2E			De-Activated scroll
	ld a,(ix+12)
	out (c),a
	;	out &FD42, 0xA3			Direction
	ld a,(ix+10)
	out (c),a	
	;	out &FD42, 0x00			Dummy
	ld a,0
	out (c),a	
	;	out &FD42, 0x00			Start page
	ld a,(ix+8)
	out (c),a	
	;	out &FD42, 0x02			Interval
	ld a,(ix+6)
	out (c),a	
	;	out &FD42, 0x02			End page
	ld a,(ix+4)
	out (c),a	
	;	out &FD42, 0x0B			vertical scolling offset
	ld a,(ix+2)
	out (c),a	
	;	out &FD42, 0x2F			Activated scroll
	ld a,(ix+0)
	out (c),a	

	
	
	ld bc,#FD41
	ld a,201	;		Function Oled Write data to SSD1306
	out (c),a
	call SYM3_OLED_WaitReady
	ei
	ret



; ------------------------------------------------------------------------

;202d	Oled print text in Upper row 
;	Note: maximum is 12 characters
;
;if (&FD41 = 1) return 		check busy?
;	out &FD42, char 			to print character
;	out &FD42, char 			to print character
;	out &FD42, char 			to print character
;	..
;	..	
;	out &FD41,202d				active function
;	while (inp (&FD41 == 1)		wait processing 0 = oke 1 = busy 2 = error


RSX_OLED_PRINTTEXT
	cp 1
	jp nz,RSX_Error
	
OLED_PRINTTEXT_Main
	LD   L,(IX+0)
	LD   H,(IX+1)   ; HL = @a$ = Adresse des Descriptors
	LD   A,(HL)     ; B = Länge des Strings
	cp   12 + 1
	jp	 nc,RSX_Error
	
	;cp   8+3
	INC  HL
	LD   E,(HL)
	INC  HL
	LD   D,(HL)     ; DE = Adresse des Strings

OLED_PRINTTEXT_Main_WithoutRSX_Parse
	di
	push af
	call SYM3_OLED_WaitReady
	
	
	
	;Reset OLED-Write Pointer
	ld bc,#FD41
	ld a,0
	out (c),a
	inc bc
	
	pop hl
OLED_PRINTTEXT_Main2	
	ld a,(de)
	cp 0
	jr z,OLED_PRINTTEXT_Main_exit
	inc de	
	out (c),a
	dec h
	jr nz,OLED_PRINTTEXT_Main2

OLED_PRINTTEXT_Main_exit:	
	ld bc,#FD41
	ld a,202	;		Function Oled PrintText
	out (c),a
	call SYM3_OLED_WaitReady
	ei
	ret





; ------------------------------------------------------------------------
RSX_OLED_CLS
;2.2.1	200d	Oled clear display (black)
	di
	call SYM3_OLED_WaitReady
;	call SYM3_OLED_TestReady
;	ret z			; OLED is busy
	
	ld bc,#FD41
	ld a,200	;		function clear display
	out (c),a
	
	call SYM3_OLED_WaitReady
	ei
	ret
; ------------------------------------------------------------------------
; 2.2.2	210d	Oled print text on display   x, y, font, text
SYM3_OLED_PrintText
	di
	; SYM3_OLED_Init_PrintText		; IN:     A=Font types 	10,18,26, DE=XY,  HL=Textpointer
	push af
	call SYM3_OLED_WaitReady
	
	ld bc,#FD41
	ld a,0		; 			reset intern write buffer pointers (RTC, mouse, oled)
	out (c),a

	ld bc,#FD42
	out (c),d	; 			x as 		0-127	(left to right)
	out (c),e	;  			y as 		0-31	(up to down)
	pop af
	out (c),a

	ld bc,#FD42
SYM3_OLED_PrintText1
	ld a,(hl)
	cp 0
	jr z,SYM3_OLED_PrintText_Exit
	out (c),a
	inc hl
	jr SYM3_OLED_PrintText1

SYM3_OLED_PrintText_Exit
	ld bc,#FD41
	ld a,210	;		function Print text to display
	out (c),a
	call SYM3_OLED_WaitReady
	
	ei
	ret

; ------------------------------------------------------------------------	
SYM3_OLED_PrintOneChar
	ld bc,#FD42
	out (c),a
	ret	


	
; ------------------------------------------------------------------------------
;	F202	Oled print text in Upper row 
;	Note: maximum is 12 characters
Text2OLED_Upper			; HL=Zero-terminated Textstring
	di
	push hl
	call Wait4ARM_is_busy
	
	ld bc,#fd42
	pop hl
Text2OLED_Upper_loop	
	ld a,(hl)
	cp 0
	jr z,Text2OLED_Upper_Exit
	out  (c),a
	inc hl
	jr Text2OLED_Upper_loop
Text2OLED_Upper_Exit:	
	ld bc,#fd41
	ld a,202
	out  (c),a
	ei
	ret