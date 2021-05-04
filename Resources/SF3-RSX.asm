	org #C000
; ------------------------------------------------------------------------------
; ROM Header
rom_type
    defb 	1                          ; Background ROM
rom_version
    defb 	0,1,2
; ------------------------------------------------------------------------------
rsx_names
    defw 	rsx_name_table
; ------------------------------------------------------------------------------
    jp   	init_rom
; ------------------------------------------------------------------------------
extra_rsxs
	jp 		RSX_OLED_CLS
	jp 		RSX_OLED_PRINTTEXT
	jp 		RSX_OLED_SCROLL
	jp 		version_cmd
	jp 		LEDtest
	jp 		LED_Set_VU
	jp 		buzz
	jp 		buzz
	jp 		reset
	jp 		roms_print
	jp 		ROMUP
	jp 		romset
	jp 		PrintLog
	jp 		GetErrorText
	jp 		MemTest
	jp 		GetMeasurements
	jp		PrintDFUName
	; --- NET ---
	jp 		SF3_CMD_SOCKET				; IN  ---     OUT: Return data[0] = socket number or 0xFF (error). Only TCP protocol for now.
	jp		SF3_CMD_CONNECT				; IN   A=Socket, DE=Pointer to IP-Addr (descent order needed!)      Z-Flag indicates Error		
	jp		SF3_GET_SOCKET_STATE		; IN A= Socket,   OUT   (0 ==IDLE (OK), 1 == connect in progress, 2 == send in progress)			       DE=Data   (from IX+2 / IX+3)	
	jp  	SF3_CMD_NET_RECEIVE_DATA	; IN A= Socket, DE=Size IX=Pointer to Data   OUT   A=Buffer State, BC=Size, Filled (DE)-Memory
	jp		SF3_CMD_NET_LOOKUP_IP 		; IN DE=Adress of IP-Adress ("0" terminated), IX=Adress of the Host-String			OUT=Filled (BC) with IP-Adress
	jp		SF3_CMD_NET_SEND_CUSTOM_DATA; IN IX=Pointer to Data (#00:Length, #01:Socketnumber, #02-#9999:Data)   OUT   nothing
	jp		SF3_CMD_CLOSE_CONNECTION	; IN A= Socket
	; ---
	jp		DisplayNetConfig
	; --- RTC ---
	jp		RTC_Reset		; RRESET
	jp		RTC_SetDate		; RSDATE
	jp		RTC_GetDate		; RGDATE
	jp		RTC_SetTime		; RSTIME
	jp		RTC_GetTime		; RGTIME
; ------------------------------------------------------------------------------ 
rsx_name_table
    defb 	'Sym3 Helper',' ' + $80 	; needed for NC+LAUNCH-Detections (can be removed, but NC/Launch must be changed)
    defb 	'OCL','S' + $80
    defb 	'OPRIN','T' + $80
    defb 	'OSCROL','L' + $80
    defb 	'VE','R' + $80
    defb 	'LED','T' + $80
    defb 	'LED','V' + $80
    defb 	'BUZ','Z' + $80
    defb 	'BEE','P' + $80
    defb 	'RESE','T' + $80
    defb 	'SROM','S' + $80
    defb 	'SROMU','P' + $80
    defb 	'SROMSE','T' + $80
    defb 	'LO','G' + $80
    defb 	'GER','R' + $80
    defb 	'MEMTES','T' + $80
    defb 	'MEASUR','E' + $80
    defb    'DF','U' + $80
    ; --- NET ---
    defb 	$91						; SOCK
    defb 	$92						; CONNECT
    defb 	$93						; GET_SOCK_STATE
	defb 	$94						; NET_RECEIVE_DATA
	defb 	$95						; NET_LOOKUP_IP
	defb 	$96						; NET_SEND_CUSTOM_DATA
	defb 	$97						; CMD_CLOSE_CONNECTION
    ; -----------
    defb 	'IPCONFI','G' + $80		; IP-Config
	; --- RTC ---
	defb	'RRESE','T' + $80		; RTC_Reset
	defb	'RSDAT','E' + $80		; RTC_SetDate
	defb	'RGDAT','E' + $80		; RTC_GetDate
	defb	'RSTIM','E' + $80		; RTC_SetTime
	defb	'RGTIM','E' + $80		; RTC_GetTime	
    defb 	0                          ; End RSX name table
; ------------------------------------------------------------------------------ 
init_rom	
	push 	ix
	push 	iy
	push 	de
	push 	hl

	ld 		hl,versionstring
	call 	PrintString
	
	pop 	hl
	pop 	de
	pop 	iy
	pop 	ix
	SCF 							; Set_C_Flag
	ret
; ------------------------------------------------------------------------------    
RSX_Error
	ld 		hl,RSX_wrong_parameters
	jp 		PrintString
; ------------------------------------------------------------------------------    
	include "C:\#nobackup\CPC-Programmierung\NC\Resources\Macros.asm"
	include "C:\#nobackup\CPC-Programmierung\NC\Resources\firmware_calls.h"
    include "C:\#nobackup\CPC-Programmierung\NC\Resources\MyFirmwareCalls.h"
    include "DataArea.h"	
	
	include "c:\#nobackup\CPC-Programmierung\IDE-Phactory\Resources\MySubRoutines4AllROMs.asm"
	include "MySubRoutines4SF3ROM.asm"
	include "RTC.asm"
	include "OLED.asm"
	include "Version.asm"
	include "Buzzer.asm"
	include "Reset.asm"	
	include "ROM.asm"
	include "Net.asm"	
	include "Log.asm"
	include "Misc.asm"
	include "System.asm"
; ------------------------------------------------------------------------------
EndROM
 	;Padding the rom with 0s until the checksum byte
 	ds 		$FFFF-EndROM,$00