; |ROMUP	- Added v1.0.5. Upload rom to a given slot. Ie. |ROMUP,"UTOPIA.ROM",15  . will upload Utopia rom to slot 15
ROMUP
	
	cp 2
	jp nz,RSX_Error
	
ROMUP_Main
	LD   L,(IX+2)
	LD   H,(IX+3)
	LD   A,(HL)     ; A = Length Filename
	cp   12 + 1
	jp	 nc,RSX_Error
	ld 	b,a
	
	INC  HL
	LD   E,(HL)
	INC  HL
	LD   D,(HL)     ; DE = Adress of Filename

	LD   A,(IX+1)
	cp   0
	jp   nz,RSX_Error
	
	; Main
	
	ex de,hl
	ld de,#c000
	call #BC77 ;CAS_IN_OPEN       ;in: HL=fname, B=fnamelen, DE=workbuf,
                        ;out: HL=header, DE=dest, BC=siz, A=type, cy=err, zf
    RET  NC     ; Error at opening the file

	
		
	call Wait4ARM_is_busy
	
	; reset write buffer pointers0
	ld 		bc,$FD41
	ld 		a,0
	out 	(c),a
	
	; Rom number 0-30 31 is Lower ROM
	inc 	bc
	LD   	a,(ix+0)   ; ROM-Number
	out 	(c),a
	
	; 0=normal ..TODO 1 = under CPC reset
	ld 		a,0
	out 	(c),a
	
	
	
	; Data (Max data size is &4000+80)
	ld de,#4080

ROMUP_memoryloop		; not a masterpiece ;-)

	;; read a char from the file, character is returned in A register

	push bc
	push de
	call &bc80  ; cas_in_char
	pop de
	pop bc
	jr nc,ROMUP_memoryloop_not_eof
	jr nz,ROMUP_memoryloop_not_eof

	;; could be end of file
	;; test for hard end of file byte
	cp &f
	jr z,ROMUP_memoryloop_eof


ROMUP_memoryloop_not_eof
;; write byte to memory

	
	out (c),a					; Data
	dec de
	ld  a, d
	or  e
	jr 	nz,ROMUP_memoryloop

ROMUP_memoryloop_eof
	; activate function
	ld 		bc,$FD41
	ld 		a,63
	out 	(c),a
MAXAM	
	call	Wait4ARM_is_busy
	
	jp	  CAS_IN_CLOSE      ; #BC7A 	out: DE=workbuf, cy=0=failed (no open file)
	
	
	
; ------------------------------------------------------------------------------
; F62,1:	Get list of Hardware Enables ROMs (31 is lower ROM) 

;|ROMSOFF  - Added v2.0.5. Without paramters, all roms of M4 board is disabled until CPC is rebooted or M4 reset is pressed.
;            Optional paramteres: "except rom number", "reset" (0 = do not reset, 1 = do reset). With this it's possible to disable all roms except one.
;            Example: |ROMSOFF,6,1  (will disable all other roms than rom 6 and reset the CPC). 
roms_print:

	cp 0
	jr z,roms_print_list
	cp 1
	jp z,roms_display_RSX	
	jp RSX_Error
roms_print_list:
	call Wait4ARM_is_busy
	
	;reset write buffer pointer 0
	ld bc,#fd41
	ld a,0
	out (c),a
	
	; active subfuntion
	inc bc
	inc a
	out (c),a
	; active function
	dec bc
	ld a,62
	out (c),a
	
	;
	call Wait4ARM_is_busy
	
	ld hl,roms_txt
	call PrintString
	
	ld de,roms_print_RAM_Part_Start
	ld hl,#b06e - 1    ; # b06e - 1: Last Adress to changeable (464+6128)   ae8b-b06e are safe
	ld bc,roms_print_RAM_Part_End-roms_print_RAM_Part_Start
	sbc hl,bc			; Carry dont need to clear or set
	ex de,hl
	push de
	ldir

	call GetColumnCount		; OUT: a=Column
	ld (#b06e),a
	call KL_CURR_SELECTION  ;#B912 out: A=upper ROM bank
	ld e,a
	ld d,0					; Counter for Column
	ret
roms_txt
	defm "ROMS:",#d,#a,"-----",#d,#a,0
    ;------------------------------
roms_print_RAM_Part_Start	
	
roms_print_loop:
	ld bc,#fd42
	in a,(c)
	cp 255
	jr z,roms_print_loop_exit			; EXIT
	 
	
	; Print ROM-Number
	push af

	ld a,(#b06e)				; Max Column
	cp d						; Counter for Column
	
	jr nz,roms_print_loop_1
	
	
	call PrintCRLF
	ld d,#0
roms_print_loop_1	
	
	
	; Cursor to next Column  
 	call TXT_GET_CURSOR  		;  #BB78  out: H=x, L=y
 	ld a,d
 	sla a
 	sla a
 	ld h,a
 	sla a
 	sla a
	add a,h
	inc a						; Due to Start-Value D=0 => H will be 0 too
	ld h,a
 	call TXT_SET_CURSOR			; #BB75    in: H=x, L=y
 	inc d

	; Print ROM-Number
	pop af
	push af
	call SUB_PRINT_8BIT_2digits
	; Select ROM
	pop af
	ld c,a
	call KL_ROM_SELECT      ; #B90F in: C=upper ROM bank (select, and enable that bank)
	
	ld a,":"
	call &bb5a
	
	
	; Print ROM-Text
	ld hl,(#C004)

roms_print_romname_loop	
	ld a,(hl)
	push af
	res 7,a
	call #bb5a
	pop af
	bit 7,a
	jr nz,roms_print_loop_next_rom		; Next ROM
	inc hl
	jr roms_print_romname_loop	
roms_print_loop_next_rom
	;inc d					; One Column printed
	ld c,e
	call KL_ROM_SELECT      ; #B90F in: C=upper ROM bank (select, and enable that bank)
	jr roms_print_loop

roms_print_loop_exit
;	pop bc
	ld c,e
	jp KL_ROM_SELECT      ; #B90F in: C=upper ROM bank (select, and enable that bank)
roms_print_RAM_Part_End	
; ------------------------------------------------------------------------------
roms_display_RSX_ROMTXT:
	defb "ROM ",0

roms_display_RSX:
	ld a,(ix+1)
	cp 0
	jp nz,RSX_Error
	
	ld a,(ix+0)				; ROM-Number
	
	
	; Print "ROM  7:"
	push af
	ld hl,roms_display_RSX_ROMTXT
	call PrintString
	pop af
	call SUB_PRINT_8BIT_2digits
	ld a,":"
	call &bb5a


	; Copy Main-Function to RAM
	ld de,roms_display_RSX_RAM_Part_Start
	ld hl,#b06e - 1    ; # b06e - 1: Last Adress to changeable (464+6128)   ae8b-b06e are safe
	ld bc,roms_display_RSX_RAM_Part_End-roms_display_RSX_RAM_Part_Start
	sbc hl,bc			; Carry dont need to clear or set
	ex de,hl
	push de
	ldir

	call GetColumnCount		; OUT: a=Column
	ld (#b06e),a
	call KL_CURR_SELECTION  ;#B912 out: A=upper ROM bank
	
	ld e,a					; Symbiface 3-ROM-Location
	ld d,0					; Counter for Column
	
	ld c,(ix+0)				; ROM-Number
	
	jp KL_ROM_SELECT      ; #B90F in: C=upper ROM bank (select, and enable that bank)
	; --------
roms_display_RSX_RAM_Part_Start	
	;
	ld ix,(#C004)
	
	; Print ROM-Name
roms_display_RSX_loop_print_ROM_Name
	ld a,(ix)
	inc ix
	push af
	res 7,a
	call #bb5a
	pop af
	bit 7,a
	jr z,roms_display_RSX_loop_print_ROM_Name
	
	ld a,#0d
	call #bb5a
	ld a,#0a
	call #bb5a
	call #bb5a
	
	; Print RSX-Names

roms_display_one_RSX:
	ld a,(ix)
	cp 0
	jr z,roms_display_RSX_exit			; last ROM already displayed	
	inc ix
	res 7,a
	cp " "								; Printable Char?
	jr c,roms_display_one_RSX
	
	;call nc,#bb5a
	call #bb5a
	ld a,(ix-1)
	bit 7,a
	jr nz,roms_display_one_RSX_next		; Next RSX
	jr roms_display_one_RSX	
	
roms_display_one_RSX_next:
	; Cursor to next Column  
	inc d
	ld a,(#b06e)				; Max Column
	cp d						; Counter for Column
	
	jr nz,roms_display_one_RSX_next_1
	
	
	ld a,#0d
	call #bb5a
	ld a,#0a
	call #bb5a

	
	ld d,#0
roms_display_one_RSX_next_1
	

 	call TXT_GET_CURSOR  		;  #BB78  out: H=x, L=y
 	ld a,d
 	sla a
 	sla a
 	ld h,a
 	sla a
 	sla a
	add a,h
	inc a						; Due to Start-Value D=0 => H will be 0 too
	ld h,a
 	call TXT_SET_CURSOR			; #BB75    in: H=x, L=y
 	


	jr roms_display_one_RSX
	
	
roms_display_RSX_exit
	ld c,e
	jp KL_ROM_SELECT      ; #B90F in: C=upper ROM bank (select, and enable that bank)
	
roms_display_RSX_RAM_Part_End:	
	; ********************
GetColumnCount:	
	call SCR_GET_MODE       ;#BC11 out: A=mode (cy=mode0, z=mode1, ie. cmp mode,1)
	ld d,1					; 1 Column   
	cp 0					; Screen Mode 0
	jr z,GetColumnCount_exit
	ld d,2					; 3 Columns	 
	cp 1					; Screen Mode 1	
	jr z,GetColumnCount_exit
	; Screen Mode 2
	ld d,4					; 6 Columns
GetColumnCount_exit
	ld a,d
	ret
; ------------------------------------------------------------------------------	
;|ROMSET	- Added v1.0.5. Used to enable or disable rom (must be uploaded already). |ROMSET,15,0  will disable rom 15. |ROMSET,15,1 will re-enable it.
;	F62,0:	Get Hardware Rom enable / disable

romset
	cp 2
	jp nz,RSX_Error
	
	ld a,0
	cp (ix+1)
	jp nz,RSX_Error
	cp (ix+3)
	jp nz,RSX_Error
	
	
	
	di	
	call Wait4ARM_is_busy
	
	;reset write buffer pointer 0
	ld bc,#fd41
	ld a,0
	out (c),a
	
	; active subfuntion
	inc bc
	ld a,3
	out (c),a
	
	; ROM-Number
	ld a,(ix+2)				; ROM-Number
	out (c),a

	; Enable/disable  (1=Enable)
	ld a,(ix+0)				; Enable-Switch		0 or 1
	out (c),a
	
	; active function
	dec bc
	ld a,62
	out (c),a
	
	call Wait4ARM_is_busy
	ei
	ret