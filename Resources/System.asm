PrintDFUName:
;F70 Get DFU filename
;.
;110 out &FD41,70 Function Get DFU filename
;120 call ARM response
;130 C = inp(&FD42)
;140 IF C = 10 THEN PRINT: END
;150 IF C = 13 THEN PRINT: GOTO 130
;160 PRINT CHR$(C);
;170 GOTO 130
	ld bc,&fd41
	ld a,70
	out (c),a
	

	call wait_for_ARM_response
	
	ld bc,&fd42	
PrintDFUNameLoop
	in a,(c)
	push bc
	push af
	call &bb5a
	pop af
	pop bc
	cp 10
	ret z
	jr PrintDFUNameLoop