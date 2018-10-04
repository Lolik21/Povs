
#include "p16f84.inc" 
    
StartingAdress set 0x30  ; the starting address of the array, a constant
CurrentPointer equ 0x2F  ; the pointer to the current element in array, a variable
IndexI equ 0x2A;
IndexJ equ 0x2C ; the pointer to inner sort loop
TempVariable equ 0x2B ; Temp variable
TempVariableForW equ 0x29;
MinimalElement equ 0x2E  ; the maximal number in array, a variable
ArrayLength set 0x14   ; the number of elements in array, a constant 

    
START
	BCF STATUS, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
	CLRF CurrentPointer      ; CurrentPointer=0
	CLRW
	ADDLW 0xFF
	MOVWF MinimalElement;
LOOP1
	MOVF CurrentPointer,0    ; W=CurrentPointer
	ADDLW StartingAdress     ; W=W+CurrentPointer
	MOVWF FSR       ; FSR=W, INDF=array[W]
	MOVF INDF,0     ; W=INDF
	SUBWF MinimalElement,0   ; W=W-MinimalElement
	BTFSS STATUS,0  ; If W > 0 then go to SMALL
	GOTO ValueIsMoreThenVMIN
			; Else W <= 0 then W is smaller than MinimalElement
	MOVF CurrentPointer,0 ; W=CurrentPointer
	ADDLW StartingAdress ; W = W + CP
	MOVWF FSR ; FSR = W;
	MOVF INDF,0 ; W = INDF
	MOVWF MinimalElement ; MinimalElement=array[CurrentPointer]
	
ValueIsMoreThenVMIN
	INCF CurrentPointer,0x1  ; CurrentPointer=CurrentPointer+1
	MOVLW ArrayLength     ; W=ArrayLength
	SUBWF CurrentPointer,0   ; W=W-CurrentPointer
	BTFSS STATUS,0  ; CurrentPointer > ArrayLength ?
	GOTO LOOP1      ; no
	                ; yes
	CLRF IndexI      ; BUBBLE SORT
	MOVF IndexI, 0
	ADDLW StartingAdress
	MOVWF IndexI	
SortAcsLoop
	CLRF IndexJ
	MOVF IndexJ, 0
	ADDLW StartingAdress
	MOVWF IndexJ
	INCF IndexI
	MOVLW ArrayLength     ; W=ArrayLength
	ADDLW StartingAdress
	SUBWF IndexI,0   ; W=W-IndexJ
	BTFSC STATUS,0  ; IndexI > ArrayLength + StartingAdress ?
	GOTO EndOfSort      ; yes
	
SortInnerLoop
	INCF IndexJ
	
	MOVLW ArrayLength     ; W=ArrayLength
	ADDLW StartingAdress
	SUBWF IndexJ,0   ; W=W-IndexJ
	BTFSC STATUS,0  ; IndexJ > ArrayLength + StartingAdress ?
	GOTO SortAcsLoop      ; yes
	
	MOVF IndexJ,0 ; 
	MOVWF FSR		    ;here we getting a[IndexJ] -> TempVariable
	MOVF INDF,0
	MOVWF TempVariable
	DECF IndexJ ; temp decrement
	MOVF IndexJ,0 ; 
	MOVWF FSR		    ; here we getting a[IndexJ - 1] -> W
	MOVF INDF,0
	MOVWF TempVariableForW
	INCF IndexJ
	SUBWF TempVariable,0 ; W = W - TempVariable but W dont change(2-nd param)
	BTFSC STATUS,0 ; If a[IndexJ] < a[IndexJ-1]
	GOTO SortInnerLoop
	;a[IndexJ] >= a[IndexJ-1]
	
	MOVF IndexJ,0
	MOVWF FSR
	MOVF TempVariableForW, 0	
	MOVWF INDF
	DECF IndexJ
	MOVF IndexJ,0
	MOVWF FSR
	MOVF TempVariable, 0	
	MOVWF INDF
	INCF IndexJ
	GOTO SortInnerLoop

EndOfSort
	CLRF IndexI
	CLRF IndexJ
	
	
	END
