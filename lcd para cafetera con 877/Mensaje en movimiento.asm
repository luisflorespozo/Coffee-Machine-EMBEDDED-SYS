
__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _RC_OSC & _LVP_ON & _DEBUG_OFF & _CPD_OFF
    LIST P=16F877A
    INCLUDE<P16F877A.INC>    ;Librería para el PIC16F877A

PDel0 	EQU 0CH
PDel1 	EQU 1CH

CBLOCK  0x0C

ENDC

	ORG	0x00
Inicio
	MOVLW   0x07 ; Configure all pins
	MOVWF   ADCON1
	call	LCD_Inicializa			; Prepara la pantalla.
	movlw	Mensaje0
	call	LCD_Mensaje

CALL DELAY
CALL DELAY

Inicio2
	call	LCD_Inicializa			; Prepara la pantalla.
Principal2
	movlw	Mensaje1				; Apunta al mensaje.
	call	LCD_MensajeMovimiento
	goto	Principal2				; Repite la visualización.

Mensajes
	addwf	PCL,F
Mensaje0							; Posición inicial del mensaje.
	DT "JUAN LUIS FLORES "		    	; Espacios en blanco al principio para mejor
	DT "                         "
	DT "                      "	; visualización.
   	DT "C.I:5190474 CBBA "
	DT "                ", 0x0		; Espacios en blanco al final.
Mensaje1							; Posición inicial del mensaje.
	DT "                 "		    	; Espacios en blanco al principio para mejor
	DT "PRACTICA DE LABORATORIO ~> "
	DT "SISTEMAS ELECTRONICOS ~> ING. MECATRONICA U.C.B Cochabamba  "	; visualización.
   	DT "~>>> Luis Flores Pozo ~>>>   [06/05/2011]  "
	DT "                ", 0x0		; Espacios en blanco al final.
;
	INCLUDE  <LCD_MENS.INC>			; Subrutina LCD_MensajeMovimiento.
	INCLUDE  <LCD_4BIT.INC>			; Subrutinas de control del LCD.
	INCLUDE  <RETARDOS.INC>			; Subrutinas de retardos.

DELAY2  movlw     .253 ; 1 set numero de repeticion  (B)
       movwf     PDel0 ; 1
PLoop1  movlw     .253 ; 1 set numero de repeticion  (A)
       movwf     PDel1 ; 1
PLoop2  clrwdt ; 1 clear watchdog
       clrwdt ; 1 ciclo delay
       decfsz    PDel1,1 ; 1 + (1) es el tiempo 0  ? (A)
       goto      PLoop2 ; 2 no, loop
       decfsz    PDel0,1 ; 1 + (1) es el tiempo 0  ? (B)
       goto      PLoop1 ; 2 no, loop
PDelL1  goto PDelL2 ; 2 ciclos delay
PDelL2  
       return ; 2+2 Fin.

DELAY	CALL DELAY2
		CALL DELAY2
		CALL DELAY2
		CALL DELAY2
		CALL DELAY2
		CALL DELAY2
RETURN


END							


