__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _RC_OSC & _LVP_ON & _DEBUG_OFF & _CPD_OFF
    LIST P=16F877A
    INCLUDE<P16F877A.INC>    ;Librería para el PIC16F877A

ESTADO	EQU		0x03
PORTA	EQU		0x05
PORTB	EQU		0x06
PORTD	EQU		0x08
PORTC	EQU		0x07
TRISA	EQU		0x85
TRISB	EQU		0x86
TRISC	EQU		0x87
TRISD	EQU		0x88
CONT0	EQU		0x0C
CONT1	EQU		0x1C
MONTO	EQU		0x0E
AUX		EQU		0x0F
AUX2	EQU		1CH
ADCON	EQU		9FH
TRISE	EQU		89H
#DEFINE LEDROJO	PORTC,3;		para definir nuestras salidas y 
#DEFINE LEDROJO2	PORTC,4;	usarlas mas facilmente
#DEFINE	LEDAMAR	PORTC,5
#DEFINE	LEDVERD	PORTC,6
#DEFINE LEDAZUL	PORTC,7

		ORG		0x00
		GOTO	INICIO
INICIO	BSF		STATUS,5		; BANK1
		CLRF	TRISA			; RA0-RA2 -> Display	
		BSF		TRISA,3			; RA3<- ENTRADA SELECTCAFE
		BSF		TRISA,4			; RA4<- ENTRADA START
		CLRF	TRISB			; RB4-RB7-> LR LA LV LAZ LR
		CLRF	TRISC
		CLRF	TRISD
		BSF		TRISC,0			; RB0<-ENTRADA MONEDA1BS
		BSF		TRISC,1			; RB1<-ENTRADA MONEDA2BS
		BSF		TRISC,2			; RB2<-ENTRADA MONEDA5BS
		
	MOVLW   0x07 ; Configure all pins
	MOVWF   ADCON
	BCF		TRISE,4
		BCF		STATUS,5		; BANK0

START	CLRF	PORTA			; DP=0
		CLRF	PORTC
		CLRF	PORTD
		CLRF	PORTB			; LR=LA=LV=LAZ=LR=OFF
		CLRF	MONTO			; MONEY=0
		CLRF	AUX				; AUX=0
		CLRF	AUX2
ES1BS	CALL	SELECCAFE
		BTFSC	PORTC,0			; MONEDA1BS=0?							SWITCH 1 BS
		GOTO	ES2BS
		CALL	DELAY
		MOVLW	0x07			; W<-7
		BCF		ESTADO,0		; C=0;
		SUBWF	MONTO,0			; W=MONEY-W
		BTFSC	ESTADO,0		; C=0? - MONEY<7?	
		GOTO	MONTODEMAS		; RECHAZA LA MONEDA  
		MOVLW	0x01			; W<-1
		ADDWF	MONTO,1			; MONTO=MONTO+1BS
		GOTO	MOSTRAR
ES2BS	CALL	SELECCAFE
		BTFSC	PORTC,1			; MONEDA2BS=0?							SWITCH 2 BS
		GOTO	ES5BS
		CALL	DELAY
		MOVLW	0x06			; W<-6
		BCF		ESTADO,0		; C=0;
		SUBWF	MONTO,0			; W=MONTO-6
		BTFSC	ESTADO,0		; C=0? - MONEY<6?	
		GOTO	MONTODEMAS		; RECHAZA LA MONEDA
		MOVLW	0x02			; W<-2
		ADDWF	MONTO,1			; MONTO=MONTO+2BS
		GOTO	MOSTRAR
ES5BS	CALL	SELECCAFE
		BTFSC	PORTC,2			; SW5BS=0?							SWITCH 5 BS
		GOTO	ES1BS
		CALL	DELAY
		MOVLW	0x05			; W<-3
		BCF		ESTADO,0		; C=0;
		SUBWF	MONTO,0			; W=MONEY-W
		BTFSC	ESTADO,0		; C=0? - MONEY<3?	
		GOTO	MONTODEMAS			; RECHAZA LA MONEDA 
		MOVLW	0x05			; W<-5
		ADDWF	MONTO,1			; MONEY=MONEY+W
		GOTO	MOSTRAR
MOSTRAR MOVF	MONTO,0			; W=MONEY						MOSTRAR CANTIDAD DE DINERO
		MOVWF	PORTD			; DP=W
		GOTO	ES1BS
MONTODEMAS
		BSF		LEDAZUL			; LED CAMBIO=ON
		CALL	DELAY
		BCF		LEDAZUL			; LED CAMBIO=OFF
		GOTO	ES1BS
SELECCAFE
		CALL	START2
		BTFSC	PORTA,3			; MONEDA1BS=0?							SWITCH 1 BS
		RETURN
		CALL	DELAY
		MOVLW	0x01			; W<-1
		ADDWF	AUX,1			; MONTO=MONTO+1BS
		CALL	CHECK

		GOTO	MOSTRAR2
		
CHECK;							PARA QUE EL SW SELEC NO SE PASE DE 4
		MOVLW	0x05			; W<-5
		BCF		ESTADO,0		; C=0;
		SUBWF	AUX,0			; W=MONEY-W
		BTFSS	ESTADO,0		; C=0? - MONEY<5?	
		RETURN;					SI NO retorna
		CLRF	AUX;			;si si borra la variable select
		CLRF	PORTA
		RETURN
MOSTRAR2
		MOVF	AUX,0			; W=MONEY		muestra el dinero
		MOVWF	PORTD			; DP=W
		GOTO	SELECCAFE;		vamos a seleccionar que cafe
START2;							se apreto start??
		BTFSC	PORTA,4
		RETURN;					si no sigue en lo que estaba
		MOVF	MONTO,0;		si si, hace  w<-monto
		MOVWF	AUX2
		MOVF	MONTO,AUX2; HACEMOS AUXTEM<-CONTEMP
CAFEPURO
		BCF		ESTADO,0		; C=0;
		MOVLW	0x01			; W<-1
		SUBWF	MONTO,W			; W=MONEY-W
		BTFSS	ESTADO,0		; C=1? - MONEY>=1?	
		GOTO	ES1BS;			si no vuelve a pedir dinero
		BCF		ESTADO,2;		si si, continua
		MOVLW	0X01;			w<-1
		SUBWF	AUX,W			;AUX es 1?
		BTFSS	ESTADO,2
		GOTO	CAFELECHE;	si no pregunta el siguiente
;CALL	MSJ1
	BSF		LEDROJO;		si si prende el led ROJO y devuelve el cambio
		
		GOTO	CUANTODECAMBIO

CAFELECHE
		BCF		ESTADO,0		; C=0;
		MOVLW	0x02			; W<-2
		SUBWF	MONTO,W			; W=MONEY-W
		BTFSS	ESTADO,0		; C=1? - MONEY>=2?	
		GOTO	ES1BS;			si no vuelve a pedir dinero
		BCF		ESTADO,2;		si si, continua
		MOVLW	0X02;			w<-2
		SUBWF	AUX,W			;AUX es 2?
		BTFSS	ESTADO,2
		GOTO	CAFEEXPRESS;	si no pregunta el siguiente
		BSF		LEDAMAR;		si si prende el led AMARILLO y devuelve el cambio
		
		GOTO	CUANTODECAMBIO
;CALL	MSJ2
CAFEEXPRESS
		BCF		ESTADO,0		; C=0;
		MOVLW	0x03			; W<-3
		SUBWF	MONTO,W			; W=MONEY-W
		BTFSS	ESTADO,0		; C=1? - MONEY>=3?	
		GOTO	ES1BS;			si no vuelve a pedir dinero
		BCF		ESTADO,2;		si si, continua
		MOVLW	0X03;			w<-3
		SUBWF	AUX,W			;AUX es 3?
		BTFSS	ESTADO,2
		GOTO	CAFECAPUCCINO;	si no pregunta el siguiente
		BSF		LEDVERD;		si si prende el led verde y devuelve el cambio
		
		GOTO	CUANTODECAMBIO
;		CALL	MSJ3
CAFECAPUCCINO
		BCF		ESTADO,0		; C=0;
		MOVLW	0x04			; W<-4
		SUBWF	MONTO,W			; W=MONEY-W
		BTFSS	ESTADO,0		; C=1? - MONEY>=4?	
		GOTO	ES1BS;			si no vuelve a pedir dinero
		BCF		ESTADO,2;		si si, continua
		MOVLW	0X04;			w<-4
		SUBWF	AUX,W			;AUX es 4?
		BTFSS	ESTADO,2
		GOTO	CAFEEXPRESS;	si no pregunta el siguiente
	;	CALL	MSJ4
		BSF		LEDROJO2;		si si prende el led ROJO2 y devuelve el cambio
CUANTODECAMBIO
		BCF		ESTADO,2;		borramos zero de status
		MOVF	AUX,0;			movemos el aux a W
		SUBWF	MONTO,W;		hacemos monto-w
CAMBIO	MOVWF	MONTO;			movemos el resultado de la resta a w
		BSF		LEDAZUL			; prendemos el led azul de devolver cambio                                          SI HAY CAMBIO ENCIENDE LA LUZ DE CAMBIO
SINC	MOVF	MONTO,0			; W<-MONEY									SI NO HAY CAMBIO VIENE ACA
		MOVWF	PORTD
			; DP<-W
		CALL 	DELAY2
		CALL 	DELAY2
		CALL 	DELAY2
CALL	MSJ2
		GOTO	START
RETURN



MSJ1
	call	LCD_Inicializa			; Prepara la pantalla.
	movlw	Mensaje1
	call	LCD_Mensaje

CALL DELAY

	call	LCD_Inicializa			; Prepara la pantalla.
	movlw	Mensaje11				; Apunta al mensaje.
	call	LCD_MensajeMovimiento
;	goto	Principal2				; Repite la visualización.
CALL DELAY
RETURN

MSJ2
	call	LCD_Inicializa			; Prepara la pantalla.
	movlw	Mensaje2
	call	LCD_Mensaje

RETURN

MSJ3
	call	LCD_Inicializa			; Prepara la pantalla.
	movlw	Mensaje3
	call	LCD_Mensaje

RETURN
MSJ4
	call	LCD_Inicializa			; Prepara la pantalla.
	movlw	Mensaje4
	call	LCD_Mensaje

RETURN
Mensajes
	addwf	PCL,F
Mensaje1							; Posición inicial del mensaje.
	DT "CAFE PURO 1 Bs   "		    	; Espacios en blanco al principio para mejor
	DT "                         "
	DT "                      "	; visualización.
   	DT "RECIBA SU CAMBIO "
	DT "                ", 0x0		; Espacios en blanco al final.
Mensaje11							; Posición inicial del mensaje.
	DT "                 "		    	; Espacios en blanco al principio para mejor
	DT "PREPARANDO...  "
	DT "GRACIAS. VUELVA PRONTO  "	; visualización.
 ;  	DT "                ", 0x0		; Espacios en blanco al final.
GOTO	CAFEPURO
MensajesA
Mensaje2						; Posición inicial del mensaje.
	DT "CAFE C/LECH 2 Bs"		    	; Espacios en blanco al principio para mejor
;	DT "                         "
;	DT "                     "	; visualización.
;   	DT "RECIBA SU CAMBIO "
;	DT "                ", 0x0		; Espacios en blanco al final.

Mensaje3							; Posición inicial del mensaje.
	DT "CAFE EXPRES 3 Bs"		    	; Espacios en blanco al principio para mejor
;	DT "                         "
;	DT "                     "	; visualización.
;   	DT "RECIBA SU CAMBIO "
;	DT "                ", 0x0		; Espacios en blanco al final.
;CLEAR	DISPLAY
GOTO 	CAFEPURO
Mensaje4							; Posición inicial del mensaje.
	DT "CAPUCCINO 4 Bs  "		    	; Espacios en blanco al principio para mejor
	DT "                         "
;	DT "                     "	; visualización.
;   	DT "RECIBA SU CAMBIO "
;	DT "                ", 0x0		; Espacios en blanco al final.

	INCLUDE  <LCD_MENS.INC>			; Subrutina LCD_MensajeMovimiento.
	INCLUDE  <LCD_4BIT.INC>			; Subrutinas de control del LCD.
	INCLUDE  <RETARDOS.INC>			; Subrutinas de retardos.



DELAY	MOVLW	0xFF; 			;*DELAY		
		MOVWF	CONT0
J2		MOVLW	0xFF
		MOVWF	CONT1
J1		DECF	CONT1,1
		MOVLW	0x00			; W<-0
		BCF		ESTADO,2		; Z<-0
		SUBWF	CONT1,0			; W<-RESULTADO SI W=0 SO Z=1
		BTFSS	ESTADO,2		; Z=1?
		GOTO 	J1
		DECF	CONT0,1
		MOVLW	0x00			; W<-0
		BCF		ESTADO,2		; Z<-0
		SUBWF	CONT0,0			; W<-RESULTADO SI W=0 SO Z=1
		BTFSS	ESTADO,2		; Z=1?
		GOTO 	J2
		RETURN
DELAY2
		CALL	DELAY
		CALL	DELAY
RETURN

		END
		
		
			
		