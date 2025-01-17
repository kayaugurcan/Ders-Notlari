LIST P=16F877A
INCLUDE <P16F877A.INC>
__CONFIG _CP_OFF &_WDT_OFF &_HS_OSC &_PWRTE_OFF &_LVP_OFF

SAYAC0  EQU 0x20
SAYAC1  EQU 0x21
SAYAC2  EQU 0x22
TEMP    EQU 0x23
BIRLER  EQU 0x24
ONLAR   EQU 0x25
YUZLER  EQU 0x26
BINLER  EQU 0x27
TEMP1   EQU 0x28
TEMP2   EQU 0x29
TEMP3   EQU 0x2A
TEMP4   EQU 0x2B
ISTENEN EQU 0x2C
ISI     EQU 0x2D
;****** RESET VECTOR *****
	ORG 0
	GOTO START
;****** INTERRUPT VECTOR*****
	ORG 4
	GOTO START
;*** MACRO TANIMLAMA *****
BANK0 MACRO
	  BCF STATUS,5 
	  ENDM
BANK1 MACRO
	  BSF STATUS,5
	  ENDM
;**** ALT PROGRAMLAR YAZILAB�L�R *****

START BANK1
	  MOVLW B'11110000'
	  MOVWF TRISD   ;RD0,....,RD3 �IKI� OLDU. RD4,...,RD7 INPUT OLDU.
	  CLRF TRISB    ;PORTB LER OUTPUT OLDU.
	  CLRF TRISC    ;PORTC LER OUTPUT OLDU.
	  BANK0
	  CLRF PORTC    ; ISITICI VE SO�UTUCU PASSIVE
	  CLRF PORTB    ; DISPLAYLER PASSIVE/KAPALI
 	  CLRF PORTD    ; DATA HATTINDA 0 DE�ER� VAR
	  MOVLW .0
	  MOVWF BINLER
	  MOVLW .0
	  MOVWF YUZLER
	  MOVLW .0
	  MOVWF ONLAR
	  MOVLW .0
	  MOVWF BIRLER
	  MOVLW .20
	  MOVWF ISTENEN
	  MOVLW .23
	  MOVWF ISI   ; ISI SENS�RDEN GELEN ODA SICAKLI�I

LOOP CALL ISITSOGUT  ; ISITICI MI YOKSA SO�UTUCU MU KARAR ALT PROGRAMI
	 CALL TUSTARA    ; 12 ms ZAMAN ALIR B2(YUKARI) B6(A�A�I) OLACAK �EK�LDE ISTENEN DE���ECEK
	 CALL BASAMAKBUL ; BIRLER VE ONLAR REG'LER� ISTENEN DEN ELDE ED�LMEL�
	 CALL GOSTER     ; 15 KEZ*12ms ZAMAN ALIR.
	 GOTO LOOP
;**** ALT PROGRAMLAR YAZILAB�L�R ******

BASAMAKBUL
	 CLRF  ONLAR
	 CLRF  BIRLER
	 MOVF  ISTENEN,W
	 MOVWF TEMP

BASAMAKBUL1
	 BCF STATUS,C
	 BCF STATUS,Z
	 MOVLW .10
	 SUBWF TEMP,W  ;W=TEMP-W(10)
	 BTFSC STATUS,Z
	 GOTO ESITLIK1  ;Z=1 ESITLIK DURUMU VAR
	 BTFSC STATUS,C ;Z=0 BUYUKLUK/KUCUKLUK VAR
	 GOTO BUYUKLUK1 ;C=1 ODUNC ALMA YOK BUYUKLUK VAR
;****** KUCUKLUK BLOGU ******* 
	 MOVF TEMP,W
	 MOVWF BIRLER
	 RETURN
ESITLIK1
	 INCF ONLAR,F
	 RETURN
BUYUKLUK1
	 INCF ONLAR,F ;ONLAR++
 	 MOVLW .10
	 SUBWF TEMP,F ;TEMP=TEMP-10
	 GOTO BASAMAKBUL1
ISITSOGUT
	 BCF STATUS,C
	 BCF STATUS,Z
	 MOVF ISI,W
	 SUBWF ISTENEN,W ; W=ISTENEN-W(ISI)
	 BTFSC STATUS,Z
	 GOTO ESITLIK   ;Z=1 ESITLIK DURUMU VAR
	 BTFSC STATUS,C ;Z=0 BUYUKLUK/KUCUKLUK VAR
	 GOTO BUYUKLUK  ;C=1 ODUNC ALMA YOK BUYUKLUK VAR
	 ;KUCUKLUK BLOGU C=0 ODUNC ALMA VAR KUCUKLUK BLOGU
	 BCF PORTC,1   ;RC1=0 OLDU ISITICI DURDU
	 BSF PORTC,0   ;RC0=1 OLDU SO�UTUCU �ALI�TI
	 RETURN
ESITLIK
	 BCF PORTC,1 ;RC1=0 OLDU ISITICI DURDU
	 BCF PORTC,0 ;RC0=0 OLDU SO�UTUCU DURDU
	 RETURN
BUYUKLUK
	 BSF PORTC,1 ;RC1=1 OLDU ISITICI �ALI�TI
	 BCF PORTC,0 ;RC0=0 OLDU SO�UTUCU DURDU
	 RETURN

TUSTARA
;******** 1.SATIR TARAMA BA�LADI **********
	 MOVLW B'11110111'
	 MOVWF PORTD   ;RD3=0 OLDU 1.SATIR SE��LD�
	 CALL BEKLE    ;1.5ms BEKLER
B1 	 BTFSC PORTD,4 ;E�ER RD4=0 �SE 1 ATLA
	 GOTO B2
	 MOVLW .0
	 MOVWF ONLAR
	 MOVLW .1
	 MOVWF BIRLER
	 RETURN
B2 	 BTFSC PORTD,5 ;E�ER RD5=0 �SE 1 ATLA
	 GOTO B3
	 ; YUKARI BLOGU
	 INCF ISTENEN,F   ; ISTENEN = ISTENEN +1
	 ;�ST SINIR KODLAMASI
	 BCF STATUS,Z
	 MOVLW .33  ; W=33 OLDU
	 SUBWF ISTENEN,W ;W=ISTENEN-33(W)
	 BTFSC STATUS,Z  ;E�ER Z=0 �SE 1 ATLA
	 DECF ISTENEN,F  ;Z=1 ESITLIK VAR ISTENEN 33 OLMU� => ISTENEN=ISTENEN-1 AL
	 RETURN
B3 	 BTFSC PORTD,6   ;E�ER RD6=0 �SE 1 ATLA
	 GOTO B4
	 MOVLW .0
	 MOVWF ONLAR
	 MOVLW .3
	 MOVWF BIRLER
	 RETURN
B4	 BTFSC PORTD,7   ;E�ER RD7=0 �SE 1 ATLA
	 GOTO B5
	 MOVLW .0
	 MOVWF ONLAR
	 MOVLW .4
	 MOVWF BIRLER
	 RETURN
;******* 1.SATIR TARAMA B�TT� ***************
;******* 2.SATIR TARAMA BA�LADI *************
B5	 MOVLW B'11111011'
	 MOVWF PORTD   ;RD2=0 OLDU 2.SATIR SE��LD�
	 CALL BEKLE    ;1.5ms BEKLER
 	 BTFSC PORTD,4 ;E�ER RD4=0 �SE 1 ATLA
	 GOTO B6
	 MOVLW .0
	 MOVWF ONLAR
	 MOVLW .6
	 MOVWF BIRLER
	 RETURN
B6 	 BTFSC PORTD,5 ;E�ER RD5=0 �SE 1 ATLA
	 GOTO B7
	 ; A�A�I BLOGU
	 DECF ISTENEN,F
	 ;ALT SINIR KISITLAMASI
	 BCF STATUS,Z
	 MOVLW .15  ; W=15 OLDU
	 SUBWF ISTENEN,W ;W=ISTENEN-15(W)
	 BTFSC STATUS,Z  ;E�ER Z=0 �SE 1 ATLA
	 INCF ISTENEN,F  ;Z=1 ESITLIK VAR ISTENEN 15 OLMU� => ISTENEN=ISTENEN+1 AL
	 RETURN
B7 	 BTFSC PORTD,6   ;E�ER RD6=0 �SE 1 ATLA
	 GOTO B8
	 MOVLW .0
	 MOVWF ONLAR
	 MOVLW .7
	 MOVWF BIRLER
	 RETURN
B8	 BTFSC PORTD,7   ;E�ER RD7=0 �SE 1 ATLA
	 GOTO B9
	 MOVLW .0
	 MOVWF ONLAR
	 MOVLW .8
	 MOVWF BIRLER
	 RETURN
;********** 2.SATIR B�TT� ***************
;******* 3.SATIR TARAMA BA�LADI *************
B9	 MOVLW B'11111101'
	 MOVWF PORTD   ;RD1=0 OLDU 2.SATIR SE��LD�
	 CALL BEKLE    ;1.5ms BEKLER
 	 BTFSC PORTD,4 ;E�ER RD4=0 �SE 1 ATLA
	 GOTO B10
	 MOVLW .0
	 MOVWF ONLAR
	 MOVLW .9
	 MOVWF BIRLER
	 RETURN
B10  BTFSC PORTD,5 ;E�ER RD5=0 �SE 1 ATLA
	 GOTO B11
	 MOVLW .1 
	 MOVWF ONLAR
	 MOVLW .0
	 MOVWF BIRLER
	 RETURN
B11	 BTFSC PORTD,6   ;E�ER RD6=0 �SE 1 ATLA
	 GOTO B12
	 MOVLW .1
	 MOVWF ONLAR
	 MOVLW .1
	 MOVWF BIRLER
	 RETURN
B12	 BTFSC PORTD,7   ;E�ER RD7=0 �SE 1 ATLA
	 GOTO B13
	 MOVLW .1
	 MOVWF ONLAR
	 MOVLW .2
	 MOVWF BIRLER
	 RETURN
;********** 3.SATIR B�TT� ***************
;******* 4.SATIR TARAMA BA�LADI *************
B13	 MOVLW B'11111110'
	 MOVWF PORTD   ;RD0=0 OLDU 2.SATIR SE��LD�
	 CALL BEKLE    ;1.5ms BEKLER
 	 BTFSC PORTD,4 ;E�ER RD4=0 �SE 1 ATLA
	 GOTO B14
	 MOVLW .1
	 MOVWF ONLAR
	 MOVLW .3
	 MOVWF BIRLER
	 RETURN
B14	 BTFSC PORTD,5 ;E�ER RD5=0 �SE 1 ATLA
	 GOTO B15	 
	 MOVLW .1  
	 MOVWF ONLAR
	 MOVLW .4
	 MOVWF BIRLER
	 RETURN
B15	 BTFSC PORTD,6   ;E�ER RD6=0 �SE 1 ATLA
	 GOTO B16
	 MOVLW .1
	 MOVWF ONLAR
	 MOVLW .5
	 MOVWF BIRLER
	 RETURN
B16	 BTFSC PORTD,7   ;E�ER RD7=0 �SE 1 ATLA
	 RETURN 
	 MOVLW .1
	 MOVWF ONLAR
	 MOVLW .6
	 MOVWF BIRLER
	 RETURN
;********** 4.SATIR B�TT� ***************

GOSTER 
	MOVLW .15
	MOVWF TEMP1
GOSTER1
	MOVF BINLER,W
	MOVWF PORTD   ;PORTD = W  => DATA BUS = BINLER
	MOVLW B'00000001'
	MOVWF PORTB   ;RB0=1 OLDU BINLER DISPLAY AKT�F
	CALL BEKLE    ;3ms bekler
	MOVF YUZLER,W
	MOVWF PORTD   ;PORTD = W  => DATA BUS = YUZLER
	MOVLW B'00000010'
	MOVWF PORTB   ;RB1=1 OLDU BINLER DISPLAY AKT�F
	CALL BEKLE
	MOVF ONLAR,W
	MOVWF PORTD   ;PORTD = W  => DATA BUS = ONLAR
	MOVLW B'00000100'
	MOVWF PORTB   ;RB2=1 OLDU BINLER DISPLAY AKT�F
	CALL BEKLE
	MOVF BIRLER,W
	MOVWF PORTD   ;PORTD = W  => DATA BUS = BIRLER
	MOVLW B'00001000'
	MOVWF PORTB   ;RB3=1 OLDU BINLER DISPLAY AKT�F
	CALL BEKLE
	DECFSZ TEMP1,F ;TEMP1 = TEMP1-1 E�ER TEMP1=0 �SE 1 ATLA
	GOTO GOSTER1
 	CLRF PORTB    ; DISPLAY MODULU PASSIVE TUM DISPLAYLER KAPALI
	RETURN

BEKLE
	MOVLW .10
	MOVWF SAYAC0
BEKLE0
	MOVLW .50
	MOVWF SAYAC1
BEKLE1
	MOVLW .50
	MOVWF SAYAC2
BEKLE2
	DECFSZ SAYAC2,F
	GOTO BEKLE2
	DECFSZ SAYAC1,F
	GOTO BEKLE1
	DECFSZ SAYAC0,F
	GOTO BEKLE0
	RETURN
	END
	



	
