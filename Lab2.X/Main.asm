#include "p16f84.inc" 

StartingAddress set 0x30  ; the starting address of the array, a constant
StartingEEPROMAddress set 0x30 ;
CurrentPointer equ 0x2F  ; the pointer to the current element in array, a variable
Value equ 0x2E
ArrayLength set 0xA   ; the number of elements in array, a constant 

    ORG 0x0000
    GOTO BEGIN
 
MySuperSubRootine:
    BSF STATUS, RP0 ; To bank 1;
    BCF INTCON, GIE ; Disable interrupts
    BSF EECON1, WREN ; Enable write    
    
SUBLOOP1:
    BCF STATUS, RP0 ; To bank 0;
    MOVF CurrentPointer,0    ; W=CurrentPointer
    ADDLW StartingAddress     ; W=W+c_addr
    MOVWF FSR       ; FSR=W, INDF=array[W]
    MOVF INDF , 0
    MOVWF Value  
    
    MOVLW StartingEEPROMAddress
    ADDWF CurrentPointer, 0
    MOVWF EEADR
    MOVF Value, 0
    MOVWF EEDATA
    BSF STATUS, RP0 ; To bank 1;
    
    MOVLW 55h
    MOVWF EECON2 
    MOVLW 0AAh
    MOVWF EECON2
    BSF EECON1 , WR
    BTFSC EECON1, WR 		;wait here until write completes
    GOTO $-1
    
    INCF CurrentPointer,0x1  ; CurrentPointer=CurrentPointer+1
    MOVLW ArrayLength     ; W=ArrayLength
    SUBWF CurrentPointer,0   ; W=W-CurrentPointer
    BTFSS STATUS,0  ; CurrentPointer > ArrayLength ?
    GOTO SUBLOOP1      ; no
		

    BSF INTCON, GIE
    BCF STATUS, RP0 ; To bank 0;
    RETURN
 
 
BEGIN:
	BCF STATUS, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
	CLRF CurrentPointer      ; CurrentPointer=0
	CLRF Value
	INCF Value, 1
LOOP1:
	MOVF CurrentPointer,0    ; W=CurrentPointer
	ADDLW StartingAddress     ; W=W+c_addr
	MOVWF FSR       ; FSR=W, INDF=array[W]
	MOVF Value,0     ; W=CurrentPointer
	MOVWF INDF
	
	INCF CurrentPointer,0x1  ; CurrentPointer=CurrentPointer+1
	INCF Value, 1
	MOVLW ArrayLength     ; W=ArrayLength
	SUBWF CurrentPointer,0   ; W=W-CurrentPointer
	BTFSS STATUS,0  ; CurrentPointer > ArrayLength ?
	GOTO LOOP1      ; no
	                ; yes
	CLRF CurrentPointer      ; CurrentPointer=0
	CALL MySuperSubRootine
	end

	
