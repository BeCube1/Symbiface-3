;71d	Get System info
;		
;	if (&FD41 = 1) return 		check busy?
;		
;out &FD41,71d			Function Get System info
;while (inp (&FD41 == 1)		wait processing 0 = oke 1 = busy
;
;	 					“System:    *	 SYMBiFACE 3.0” 	<13>
;						“”					<13>
;						“CPU:		STM32F405 168Mhz”	<13>
;						“RAM:      	512KB”			<13>
;											<10>
;						[*] Space not defined				
;do { 				
;	    c = inp(&FD42);
;	    print chr$(c);
;	} while (c <> 10)
version_cmd:
	di
	call SYM3_OLED_WaitReady
;	call SYM3_OLED_TestReady
;	ret z			; OLED is busy
	
	ld bc,#FD41
	ld a,71	;		Function Get System info
	out (c),a
	
	call SYM3_OLED_WaitReady
	inc bc
	ld bc,#FD42	
version_cmd_Loop:	
	in a,(c)
	cp 10
	jr z,version_exit
	call #bb5a
	cp 13
	jr nz,version_cmd_Loop
	ld a,10
	call &bb5a
	jr version_cmd_Loop
version_exit	
	ei
	ret