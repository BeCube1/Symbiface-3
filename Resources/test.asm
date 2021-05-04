;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.3.0 8604 (May 11 2013) (MINGW32)
; This file was generated Fri Nov 27 07:19:29 2015
;--------------------------------------------------------
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
;--------------------------------------------------------
; Home
;--------------------------------------------------------
;--------------------------------------------------------
; code
;--------------------------------------------------------
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/INPUT.h:5: void waitKey()
;	---------------------------------
; Function waitKey
; ---------------------------------
_waitKey_start:
_waitKey:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/INPUT.h:12: __endasm;
	call &bb06
	ld h, 0
	ld l, a
	ret
_waitKey_end:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/INPUT.h:15: void getstr(char *dest )
;	---------------------------------
; Function getstr
; ---------------------------------
_getstr_start:
_getstr:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/INPUT.h:49: __endasm;
	call &bb81 ; txt cur on
	pop bc
	pop de
	push de
	push bc
	inputText:
	call &bb06
	cp &fc ; break
	jp z, inputText
	cp &7f ; del
	jp z, inputText
	cp 13
	jp z, doReturn
	ld (de), a
	inc de
	call &bb5a
	jp inputText
	doReturn:
	xor a
	ld (de),a
	inc de
	call &bb84 ; txt cur off
	ret
_getstr_end:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/MEMORY.h:5: memcpy(char *src,char *dest,int length )
;	---------------------------------
; Function memcpy
; ---------------------------------
_memcpy_start:
_memcpy:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/MEMORY.h:18: __endasm;
	pop ix
	pop bc
	pop de
	pop hl
	push hl
	push de
	push bc
	push ix
	ldir
	ret
_memcpy_end:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/MEMORY.h:21: bankSwitch(char *bank )
;	---------------------------------
; Function bankSwitch
; ---------------------------------
_bankSwitch_start:
_bankSwitch:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\/MEMORY.h:35: __endasm;
	pop bc
	pop hl
	push hl
	push bc
	ld a, l
	call &bd5b
	ld h, 0
	ld l, a
	ret
_bankSwitch_end:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\Test.c:10: main()
;	---------------------------------
; Function main
; ---------------------------------
_main_start:
_main:
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\Test.c:12: memcpy(  &8000,  &c000,  &4000 );
	ld	hl, &4000
	push	hl
	ld	h,  &C0
	push	hl
	ld	h,  &80
	push	hl
	call	_memcpy
	ld	hl, &0006
	add	hl,sp
	ld	sp,hl
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\Test.c:13: waitKey();
	call	_waitKey
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\Test.c:14: waitKey();
	call	_waitKey
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\Test.c:15: waitKey();
	call	_waitKey
;D:\nobackup\CPC-Programmierung\CPP-Test\Resources\Test.c:16: waitKey();
	jp	_waitKey
_main_end:
