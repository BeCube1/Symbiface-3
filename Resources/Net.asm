
; ------------------------------------------------------------------------------
;;; Get Free Socket-Number for TCP-Connections	(90.13)
;;;
;;; IN: --- ; OUT: A=Socket-Number, Z indicates Error
;;;
	 
SF3_CMD_SOCKET
	call	Wait4ARM_is_busy
	jp 		z,SF3_NET_COMMAND_ERROR0

	; reset write buffer pointers0
	ld 		bc,$FD41
	ld 		a,7
	out 	(c),a
	
	; active subfuntion
	ld 		bc,$FD49
	ld 		a,13
	out 	(c),a
		
	; activate function
	ld 		bc,$FD41
	ld 		a,90
	out 	(c),a
	
	call 	Wait4ARM_is_busy
	jp 		z,SF3_NET_COMMAND_ERROR0

	; get free socket number 0-3   255 is no free socket
	ld 		bc,$FD49
	in 		a,(c)	
	cp 		255
	ret
	
; ------------------------------------------------------------------------------	
;;; Connect to IP-Address	(90.5)
;;;
;;; IN: A=Socket-Number, DE=Pointer to IP-Addr; OUT: Z-Flag indicates Error
;;;

SF3_CMD_CONNECT	
	push	af
	push	de

    call 	Wait4ARM_is_busy
	jp 		z,SF3_NET_COMMAND_ERROR_PUSH_2

	; reset write buffer pointers0
	ld 		bc,$FD41
	ld 		a,7
	out		(c),a
	
	; active subfuntion
	ld 		bc,$FD49
	ld 		a,5
	out		(c),a
	
	pop		ix
	; IP-Adress
	ld		a,(ix+3)
	out		(c),a
	ld 		a,(ix+2)
	out		(c),a
	ld 		a,(ix+1)
	out		(c),a
	ld 		a,(ix+0)
	out		(c),a

	ld 		a,(ix+5)
	out		(c),a
	ld 		a,(ix+4)
	out		(c),a	
;	ld 		hl,23	; Port (23=Telnet)
;	out 	(c),h
;	out 	(c),l
	
	pop 	af		; Socket Channel 0-3
	
	out 	(c),a	
	
	; activate function
	ld 		bc,$FD41
	ld 		a,90
	out 	(c),a
	
	
	call	Wait4ARM_is_busy
	call 	nz,Wait4WIFI_is_busy					; Check for Wifi, if ARM indicates no error

	call 	get_err_number							; Read WIFI-Error: call function 72.4
	cp 		0   ; 0=No Error
	jr 		z,SF3_CMD_CONNECT_OK

	cp 		a
 	ret

SF3_CMD_CONNECT_OK
	or 		1			; Z-Flag = 0   "jr nz,..."
	ret
	
; ------------------------------------------------------------------------------	
;;; Close Connection	(90.10)
;;;
;;; IN: A=Socket-Number; OUT: Z-Flag indicates Error
;;;

SF3_CMD_CLOSE_CONNECTION
	push 	af

	call 	Wait4ARM_is_busy
	jp 		z,SF3_NET_COMMAND_ERROR_PUSH_1
		
	; reset write buffer pointers0
	ld 		bc,$FD41
	ld 		a,7
	out 	(c),a
	
	; active subfuntion

	ld 		bc,$FD49
	ld 		a,10
	out 	(c),a
	
	; Socket Channel 0-3
	pop 	af
	out 	(c),a
	
	; activate function
	ld 		bc,$FD41
	ld 		a,90
	out 	(c),a

	call 	Wait4ARM_is_busy
	
	ret
	
; ------------------------------------------------------------------------------
;;; Receive TCP-Data	(90.16)
;;;
;;; IN: A=Socket-Number, DE=Size to receive, IX=Pointer to Memory (where to write); OUT: A=Buffer State, BC=Size, Filled (IX)-Memory
;;;

SF3_CMD_NET_RECEIVE_DATA	
	push	af
	push	de
	call	CheckRXBufferContent						; IN: A=Socket-Number; OUT: DE=Number of bytes in the buffer
	jp 		z,SF3_NET_COMMAND_ERROR_PUSH_2
    ld 		a, e
    or 		d
	jr		z,SF3_CMD_NET_RECEIVE_DATA_no_Data_Exit	; Length = 0
	
	; RX-Buffer smaller as "Size to Receive"?  (so reduce the "Size to Receive")
	ex		de,hl
	pop		de
	
	push	hl
	pop		bc
	or 		a
	sbc 	hl,de
	jr 		nc,not_higher
	push	bc
	pop		de
not_higher	
	pop		af
	
	
	; Read the data

	; Channel 0: #FD45
	; Channel 1: #FD46	
	; Channel 2: #FD47
	; Channel 3: #FD48
	
	; ld bc,#FD45 + a
	ld 		b,$FD
	add 	a,$45
	ld 		c,a

	push 	de
	
SF3_CMD_NET_RECEIVE_DATA_Read_Loop:
    in 		a,(c)
	ld 		(ix),a

	inc 	ix
    dec 	de    
    ld 		a, e
    or 		d
    jr 		nz,SF3_CMD_NET_RECEIVE_DATA_Read_Loop
	
	pop 	bc			; return the Size
	ld 		a,0			; no error
	ret

SF3_CMD_NET_RECEIVE_DATA_no_Data_Exit
	pop		af
	pop		de
	ld 		bc,0		; Size = 0
	ld		a,0			; no error	("only" Size 0)
	ret

; ------------------------------------------------------------------------------	
;;; Send Data to TCP	(90.8)
;;;
;;; IN A=Socket-Number, DE=Size to send, IX=Pointer to Memory (what to send)		 OUT: Z indicates Error
;;;

SF3_CMD_NET_SEND_CUSTOM_DATA
    push 	af
    call 	Wait4ARM_is_busy
	call 	nz,Wait4WIFI_is_busy	; Check for Wifi, if ARM indicates no error
	jp 		z,SF3_NET_COMMAND_ERROR_PUSH_1


	; reset write buffer pointers0
	ld 		bc,$FD41
	ld 		a,7
	out 	(c),a
	
	; active subfuntion
	ld 		bc,$FD49
	ld 		a,8
	out 	(c),a
	
	; socket channel number  n = 0-3 
	pop 	af		; A=Socket
	out 	(c),a
	
	; send data
SF3_CMD_NET_SEND_CUSTOM_DATA_LOOP:	
	ld 		a,(ix)
	inc 	ix
	out 	(c),a
	dec 	de
	ld 		a,d
	or 		e
	jr 		nz,SF3_CMD_NET_SEND_CUSTOM_DATA_LOOP	
	

	; activate function
	ld 		bc,$FD41
	ld 		a,90
	out 	(c),a
	
		 
	call 	Wait4ARM_is_busy
	call 	nz,Wait4WIFI_is_busy	; Check for Wifi, if ARM indicates no error
	ret
	
; ------------------------------------------------------------------------------
;;; Get Socket-State
;;;
;;; IN: A=Socket-Number; OUT: A=Status (0 ==IDLE (OK), 1 == connect in progress, 2 == send in progress), DE=Data  data received in internal buffer
;;;

SF3_GET_SOCKET_STATE
	; reset write buffer pointers0
	ld 		bc,$FD4E
	in		a,(c)
	; 0 idle 
	; 1 busy
	; 2 error
	; 3 offline
	; 4 socket closed(?!)
	push	af
	cp		2
	jr		nc,SF3_GET_SOCKET_STATE_ERR					; Jump State = 2 or higher
	
	; Get DE=Data  data received in internal buffer
	call	CheckRXBufferContent						; IN: A=Socket-Number; OUT: DE=Number of bytes in the buffer
	jp 		z,SF3_NET_COMMAND_ERROR_PUSH_1

	pop		af
	ret

SF3_GET_SOCKET_STATE_ERR
	call	get_err_number								; Read WIFI-Error: call function 72.4, called only to reset error-state
	
	ld		de,0
	pop		af
	ret
		

; ------------------------------------------------------------------------------	
;;; Check RX buffer content	 (90.18)
;;;
;;; IN: A=Socket-Number; OUT: DE=Number of bytes in the buffer
;;;

CheckRXBufferContent:
  	push	af
  	call 	Wait4ARM_is_busy
	jp 		z,SF3_NET_COMMAND_ERROR_PUSH_3
    

	; reset write buffer pointers0
	ld 		bc,$FD41
	ld 		a,7
	out 	(c),a

	; active subfuntion
	ld 		bc,$FD49
	ld 		a,18
	out 	(c),a
	
	; Socket Channel 0-3
	pop 	af
	out 	(c),a
	
	; activate function
	ld 		bc,$FD41
	ld 		a,90
	out 	(c),a
     
    ; End
    call 	Wait4ARM_is_busy
	call 	nz,Wait4WIFI_is_busy	; Check for Wifi, if ARM indicates no error

	ld		bc,$fd49
	in		d,(c)
	in		e,(c)
	
	or 		1	; Clear Z-Flag
	ret

; ------------------------------------------------------------------------------
;;; Lookup Internet-Adress	(90.4)
;;;
;;; IN: DE=Adress of IP-Adress ("0" terminated), IX=Adress of the Host-String; OUT: (DE)=Filled Memory with IP-Adress , A=0 Host found / A=255 Host not found
;;;

SF3_CMD_NET_LOOKUP_IP
	push 	de		; Filled (DE) with IP-Adress
	call 	Wait4ARM_is_busy
	jp 		z,SF3_NET_COMMAND_ERROR_PUSH_1
	
	; reset write buffer pointers0
	ld 		bc,$FD41
	ld 		a,7
	out 	(c),a
	
	; active subfuntion
	ld 		bc,$FD49
	ld 		a,4
	out 	(c),a
SF3_CMD_NET_LOOKUP_IP_Loop	
	ld 		a,(ix)
	cp 		0
	jr 		z,SF3_CMD_NET_LOOKUP_IP_Loop_Exit
	cp 		":"
	jr 		z,SF3_CMD_NET_LOOKUP_IP_Loop_Exit
	inc 	ix
	out 	(c),a
	jr 		SF3_CMD_NET_LOOKUP_IP_Loop

SF3_CMD_NET_LOOKUP_IP_Loop_Exit:	
	ld 		bc,$FD41
	ld 		a,90					; Function DNS Resolve
	out 	(c),a
	
	call 	Wait4ARM_is_busy
	call 	nz,Wait4WIFI_is_busy	; Check for Wifi, if ARM indicates no error
	pop 	ix						; Filled (IX) with IP-Adress
	jr 		z,SF3_CMD_NET_LOOKUP_IP_ERR
	
	; Get Result
	ld 		bc,$FD49	
	in 		a,(c)
	ld 		(ix+3),a
	in 		a,(c)
	ld 		(ix+2),a
	in 		a,(c)
	ld 		(ix+1),a
	in 		a,(c)
	ld 		(ix+0),a	
	ld 		a,0
	ret	
	
SF3_CMD_NET_LOOKUP_IP_ERR
	ld 		a,255
	ret
	
	
	
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
DisplayNetConfig
;120 out &FD41, 7
;130 out &FD49, 11
;140 out &FD41, 90
;150 call ARM response
;160 call WIFI response
;
;6x print inp(&hfd49); mac: &hx &hx &hx &hx &hx &hx
;4x print inp(&hfd49); IP: 192 168 2 19
;4x print inp(&hfd49); Mask: 255 255 255 0
;4x print inp(&hfd49); Gateway: 192 168 2 192
;4x print inp(&hfd49); dns1: 168 2 254 0
;4x print inp(&hfd49); dns2: 0 0 0 0

;	call ARM_ready
;	call WIFI_ready
;	call ARM_response
;	call WIFI_response
	
	ld bc,&FD41
	ld a,7
	out (c),a
	
	ld bc,&FD49
	ld a,11
	out (c),a

	ld bc,&FD41
	ld a,90
	out (c),a

	call ARM_response
	call WIFI_response

	; ---- Output ----
	
	; Print MAC
	ld hl,NetConfigTXT1
	call PrintString


	ld bc,&fd49

	in a,(c)
	call SUB_Print_8BitHex ; IN:  A=8 Bit HexValue
	ld a,':'
	call &bb5a
	in a,(c)
	call SUB_Print_8BitHex ; IN:  A=8 Bit HexValue
	ld a,':'
	call &bb5a
	in a,(c)
	call SUB_Print_8BitHex ; IN:  A=8 Bit HexValue
	ld a,':'
	call &bb5a
	in a,(c)
	call SUB_Print_8BitHex ; IN:  A=8 Bit HexValue
	ld a,':'
	call &bb5a
	in a,(c)
	call SUB_Print_8BitHex ; IN:  A=8 Bit HexValue
	ld a,':'
	call &bb5a
	in a,(c)
	call SUB_Print_8BitHex ; IN:  A=8 Bit HexValue

	
	; Print IP
	ld hl,NetConfigTXT2
	call PrintString
	call Print4ConfigDatas
	
	; Print Mask
	ld hl,NetConfigTXT3
	call PrintString
	call Print4ConfigDatas

	; Print Gateway
	ld hl,NetConfigTXT4
	call PrintString
	call Print4ConfigDatas

	; Print DNS1
	ld hl,NetConfigTXT5
	call PrintString
	call Print4ConfigDatas

	; Print DNS2
	ld hl,NetConfigTXT6
	call PrintString
	jp  Print4ConfigDatas
	
Print4ConfigDatas
	ld bc,&fd49
	in a,(c)
	call SUB_PRINT_8BIT_T
	ld a,"."
	call &bb5a	
	in a,(c)
		call SUB_PRINT_8BIT_T
	ld a,"."
	call &bb5a	
	in a,(c)
		call SUB_PRINT_8BIT_T
	ld a,"."
	call &bb5a	
	in a,(c)
	
;		jp display_decimal_digit2
SUB_PRINT_8BIT_T:                 ; Print A-Reg
	push bc
	push de
	ld e,0                    ; Supress Printing (to cut leading "0")	

	ld b,100                   ;divisor to obtain 100's digit value
	call print_decimal_digit_T   ;display digit
	ld b,10                    ;divisor to obtain 10's digit value
	call print_decimal_digit_T   ;display digit
	ld b,1                     ;divisor to obtain 1's digit value
	ld e,255
	; Supress Printing (to cut leading "0")
	call print_decimal_digit   ;display digit	
	pop de
	pop bc
	ret	

print_decimal_digit_T:
	;; simple division routine
	ld c,0                     ;zeroise result 
decimal_divide_T:
	sub b                      ;subtract divisor
	jr c,display_decimal_digit_T ;if dividend is less than divisor, the division has finished.                     	      
	inc c                      ;increment digit value
	jr decimal_divide_T

display_decimal_digit_T :
	add a,b                   ;add divisor because dividend was negative,leaving remainder
;;-----------------------------------------------------------------------------
;; digit is a number between 0..9
;; convert this into a ASCII character '0'..'9' then display this
	push af
	ld a,c                    ;get digit value
	cp 0                      ;Supress leading "0"
	jr nz,display_decimal_digit3_T
	ld a,&ff
	cp e                      ;Supress leading "0"
	ld a,"0"
	jr z,display_decimal_digit4_T
	pop af
	ret	
display_decimal_digit3_T:
	add a,"0"                 ;convert value into ASCII character
	ld e,&FF
display_decimal_digit4_T:	
	call txt_output           ;display digit
	pop af
	ret	

	
NetConfigTXT1:	defm "MAC:     ",0
NetConfigTXT2:	defm &0d,&0a,"IP:      ",0
NetConfigTXT3:	defm &0d,&0a,"MASK:    ",0
NetConfigTXT4:	defm &0d,&0a,"GATEWAY: ",0
NetConfigTXT5:	defm &0d,&0a,"DNS1:    ",0
NetConfigTXT6:	defm &0d,&0a,"DNS2:    ",0