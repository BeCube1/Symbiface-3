;F105 RTC sub functions
;F105,0: RTC Set Backup register
;F105,1: RTC Get Backup register
;F100 Set time hour minute sec
;F101 Get time hour minute sec
;F102 Reset RTC
;F103 Get time BCD hour minute sec
;F104 Get date BCD day month year
;F110 Set date day month year
;F111 Get date day month year



; ------------------------------------------------------------------------------
RTC_SetTime		; RSTIME
;F100 Set time hour minute sec
;100 call ARM ready
;110 out &FD41,0 reset buffer pointers 0
;120 out &FD42, hours hours 0 - 23
;130 out &FD42, minutes minutes 0 - 59
;140 out &FD42, seconds seconds 0 - 59
;150 out &FD41,100 function set time
;160 call ARM response
	cp 3
	jp nz,RSX_Error

	; check, if some values goes to 16 Bit
	ld  a,(IX+5)
	cp 	0
	jp nz,RSX_Error
	ld   a,(IX+3)
	cp 	0
	jp nz,RSX_Error
	ld   a,(IX+1)
	cp 	0
	jp nz,RSX_Error


	; Hours
	ld   a,(IX+4)
	cp   24
	jp   nc,RSX_Error    ; > 23

	; Minutes
	ld   a,(IX+2)
	cp   60
	jp   nc,RSX_Error

	; Seconds
	ld   a,(IX+0)
	cp   60
	jp   nc,RSX_Error


	ld bc,&fd41
	ld a,0
	out (c),a


	; hours
	ld bc,&fd42
	ld a,(IX+4)
	out (c),a
	
	; minutes
	ld bc,&fd42
	ld a,(IX+2)
	out (c),a
	
	; seconds
	ld bc,&fd42
	ld a,(IX+0)
	out (c),a

	ld bc,&fd41
	ld a,100
	out (c),a
	
	jp ARM_response


; ------------------------------------------------------------------------------
RTC_GetTime		; RGTIME
;F101 Get time hour minute sec
;100 call ARM ready
;110 out &FD41,101 active function
;120 call ARM response
;130 print inp(&FD42) hours 0-23
;140 print inp(&FD42) minutes 0-59
;150 print inp(&FD42) seconds 0-59

	ld bc,&fd41
	ld a,101
	out (c),a
	
	call ARM_response
	
	ld bc,&fd42
	in a,(c)
	call SUB_PRINT_8BIT_T
	ld a,":"
	call &bb5a
	in a,(c)
	call SUB_PRINT_8BIT_T
	ld a,":"
	call &bb5a
	in a,(c)
	jp SUB_PRINT_8BIT_T

; ------------------------------------------------------------------------------
RTC_Reset		; RRESET
;F102 Reset RTC
;Note: Only needed when are problem with the time and date, all value are 0 !
;100 call ARM ready
;110 out &FD41,102 active function
;120 call ARM response
	ld bc,&fd41
	ld a,102
	out (c),a
	
	jp ARM_response


; ------------------------------------------------------------------------------
RTC_SetDate		; RSDATE

;F110 Set date day month year
;100 call ARM ready
;110 out &FD41,0 reset buffer pointers 0
;120 out &FD42, day day 1 -31
;130 out &FD42, month month 1 -12
;140 out &FD42, year
;150 out &FD41,110 active function
;160 call ARM response
	cp 3
	jp nz,RSX_Error

	; check, if some values goes to 16 Bit
	ld  a,(IX+5)
	cp 	0
	jp nz,RSX_Error
	ld   a,(IX+3)
	cp 	0
	jp nz,RSX_Error
	ld   a,(IX+1)
	cp 	0
	jp nz,RSX_Error


	; Days
	ld   a,(IX+4)
	cp   32
	jp   nc,RSX_Error    ; > 31
	cp   0
	jp   z,RSX_Error
	
	; Month
	ld   a,(IX+2)
	cp   13
	jp   nc,RSX_Error	; >12
	cp   0
	jp   z,RSX_Error

	; Year
	ld   a,(IX+0)
	cp   100
	jp   nc,RSX_Error	; >99


	ld bc,&fd41
	ld a,0
	out (c),a


	; Days
	ld bc,&fd42
	ld a,(IX+4)
	out (c),a
	
	; Month
	ld bc,&fd42
	ld a,(IX+2)
	out (c),a
	
	; Year
	ld bc,&fd42
	ld a,(IX+0)
	out (c),a

	ld bc,&fd41
	ld a,110
	out (c),a
	
	jp ARM_response


; ------------------------------------------------------------------------------
RTC_GetDate		; RGDATE
;F111 Get date day month year
;100 call ARM ready
;110 out &FD41,111 active function
;120 call ARM response
;130 print inp(&FD42) day 1-31
;140 print inp(&FD42) month 1-12
;150 print inp(&FD42) year 0-99 (real is + 2000)
;160 print inp(&FD42)
	ld bc,&fd41
	ld a,111
	out (c),a
	
	call ARM_response
	
	ld bc,&fd42
	in a,(c)
	call SUB_PRINT_8BIT_T
	ld a,"/"
	call &bb5a
	in a,(c)
	call SUB_PRINT_8BIT_T
	ld a,"/"
	call &bb5a
	in a,(c)
	jp SUB_PRINT_8BIT_T
