; ------------------------------------------------------------------------------	
PrintString:
	ld a,(hl)
	cp 0
	ret z
	call &bb5a
	inc hl
	jr PrintString


; ------------------------------------------------------------------------------	
;	F72,4:	Get Error number
;		Note: 
;		 remove the error text on the oled
; 		 reset Wifi error 
;
;if (&FD41 = 1) return 			check ARM busy?
;		out &FD41, 0			reset write buffer pointers0
;		out &FD42, 4			active subfuntion
;		out &FD41, 72			active function
;		while (inp (&FD41 == 1)		wait processing 
;
;		print(inp(&FD42))
get_err_number	
	
	ld a,4
	call SendCMDSubsetForPointer0_V2
	
	ld bc,#FD42
	in a,(c)
	ret
	
; ------------------------------------------------------------------------------
;;; Wait for ARM and get the ARM-Status
;;;
;;; IN: ---; OUT: Z indicates Error
;;;

wait_for_ARM_response:
Wait4ARM_is_busy:
	ld 		bc,$fd41
ARM_is_busy	
	; if fd41 <> 1 then return 
	in 		a,(c)
	cp 		1
	jr 		z,ARM_is_busy
	cp 		0											; else error exist
	jr		z,start_command_wait4ARM_WIFI_OK_Exit		; Z-Flag = 0 when Code "0" => all ok
ARM_Error_Exit
	call	get_err_number								; Read WIFI-Error: call function 72.4, called only to reset error-state
	cp		a											; Z-Flag = 1 when Error exist
	ret
	

; ------------------------------------------------------------------------------
;;; Wait for WIFI and get the WIFI-Status
;;;
;;; IN: ---; OUT: Z indicates Error
;;;

WIFI_response
Wait4WIFI_is_busy:
	
	; 0 idle 
	; 1 busy
	; 2 error
	; 3 offline
	
	ld 		bc,$fd4e
Wait4WIFI_is_busy_loop:		
	in 		a,(c)
	cp 		1
	jr 		z,Wait4WIFI_is_busy_loop
	cp 		0
	jr 		z,start_command_wait4ARM_WIFI_OK_Exit
	
	; SF3_CMD_CONNECT_ERROR	
	; when FD4e reported an error   you must read error code with F72,4
	cp		2
	call	z,get_err_number							; Read WIFI-Error: call function 72.4, called only to reset error-state
	cp 		a											; Z-Flag = 1
	ret

start_command_wait4ARM_WIFI_OK_Exit
	or 		1											; Z-Flag = 0   "jr nz,..."
	ret

; ------------------------------------------------------------------------------
SF3_NET_COMMAND_ERROR_PUSH_3
	pop af
SF3_NET_COMMAND_ERROR_PUSH_2
	pop de
SF3_NET_COMMAND_ERROR_PUSH_1
	pop af
SF3_NET_COMMAND_ERROR0
	cp a												; Z-Flag = 1
	ret
	
	
	
