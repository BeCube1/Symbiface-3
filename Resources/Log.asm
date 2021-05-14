PrintLog:
	di
	
	ld a,11
	call SendCMDSubsetForPointer0

	
	; Read Data
	ld bc,#FD42
PrintLog_loop
	in a,(c)
	cp 0
	jr z,PrintLog_exit
	call TXT_OUTPUT		; #BB5A
	
	call KM_READ_KEY	; #BB1B ; KM_READ_KEY
	jr nc,PrintLog_loop
	cp KEY_ESC
	jr z,PrintLog_exit
	cp KEY_SPACE
	call z,&bb18	
	jr PrintLog_loop

PrintLog_exit:
	ei
	ret