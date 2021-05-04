; ##############################################################################
; http://sgate.emt.bme.hu/patai/publications/z80guide/part4.html
;SUB_Multiply8:
;Multiply8_:                    ; this routine performs the operation HL=D*E
;  push af
;  ld hl,0                        ; HL is used to accumulate the result
;  ld a,d                         ; checking one of the factors; returning if it is zero
;  or a
;  jr z,Multiply8_Exit
;  ld b,d                         ; one factor is in B
;  ld d,h                         ; clearing D (H is zero), so DE holds the other factor
;MulLoop:                         ; adding DE to HL exactly B times
;  add hl,de
;  djnz MulLoop
;Multiply8_Exit
;  pop af
;  ret

; ##############################################################################


PrintString:
	ld a,(hl)
	cp 0
	ret z
	call &bb5a
	inc hl
	jr PrintString

;PrintCRLF
;	ld a,&0d
;	call &bb5a
;	ld a,&0a
;	jp &bb5a




;SUB_PRINT_8BIT_:                 ; Print A-Reg
;	push bc
;	push de
;	ld e,0                     ; Supress Printing (to cut leading "0")
;SUB_PRINT_8BIT_a:
;	ld b,100                   ;divisor to obtain 100's digit value
;	call print_decimal_digit   ;display digit
;	ld b,10                    ;divisor to obtain 10's digit value
;	call print_decimal_digit   ;display digit
;	ld b,1                     ;divisor to obtain 1's digit value
;	call print_decimal_digit   ;display digit	
;	pop de
;	pop bc
;	ret
;	
;	
;print_decimal_digit:
;	;; simple division routine
;	ld c,0                     ;zeroise result 
;decimal_divide:
;	sub b                      ;subtract divisor
;	jr c,display_decimal_digit ;if dividend is less than divisor, the division has finished.                     	      
;	inc c                      ;increment digit value
;	jr decimal_divide
;
;display_decimal_digit :
;	add a,b                   ;add divisor because dividend was negative,leaving remainder
;;;-----------------------------------------------------------------------------
;;; digit is a number between 0..9
;;; convert this into a ASCII character '0'..'9' then display this
;display_decimal_digit2 :
;	push af
;	ld a,c                    ;get digit value
;	cp 0                      ;Supress leading "0"
;	jr nz,display_decimal_digit3
;	ld a,&ff
;	cp e                      ;Supress leading "0"
;	ld a,"0"
;	jr z,display_decimal_digit4
;	ld a,' '
;	jr display_decimal_digit4
;display_decimal_digit3:
;	add a,"0"                 ;convert value into ASCII character
;	ld e,&FF
;display_decimal_digit4:	
;	call txt_output           ;display digit
;	pop af
;	ret	
;	
;display_decimal_digit2_dont_supress_zero:
;	; das gleiche wie "display_decimal_digit2", nur das eine "0" gedruckt wird
;	push af
;    ld a,c                    ;get digit value
;	jr display_decimal_digit3
;; #########################

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
	; call SendCMDSubsetForPointer0
	call SendCMDSubsetForPointer0_V2     ; 31.12.19
	
	ld bc,#FD42
	in a,(c)
	ret
	
; ------------------------------------------------------------------------------
;;; Wait for ARM and get the ARM-Status
;;;
;;; IN: ---; OUT: Z indicates Error
;;;

ARM_response
SYM3_OLED_WaitReady
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

ARM_ready
WIFI_ready
	

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
	
	
	
