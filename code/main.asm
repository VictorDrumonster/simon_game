#include <p16f887.inc>
list p=16f887

	cblock	0x20 	;dando um nome para um endere�o de memoria
		led_cnt
	endc

	org		0x00 	;vetor de inicializa��o
	goto	Start
	
	org		0x04	;vetor de interrup��o
	retfie
	
Start:
	;--- I/O config ----
	bsf		STATUS,RP0 	;seleciona o banco1
	movlw	B'11110000'
	movwf	TRISA		;configurar RA0-RA3 como saida
						;e RA3-RA4 como entrada
	bsf		STATUS,RP1
	clrf	ANSEL		; Configura a PORTA como entrada digital
	
Main:
	call	Rotina_Inicializacao
	goto 	Main
	
Rotina_Inicializacao:
	bcf		STATUS,RP1		;indo para o banco0
	bcf		STATUS,RP0
	movlw	0x0F			;movendo b'00001111' 
	movwf	PORTA			;ligando os leds
	call 	Delay_1s		;chama fun��o de delay
	clrf	PORTA			;apaga todos os leds
	clrf 	led_cnt			;led_cnt=0
	
LedCountLoop:
	clrf	PORTA			;apaga todos os leds
	clrf 	led_cnt			;led_cnt=0
	movlw   .0
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA0	;sim
	
	movlw   .1
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA0	;sim
	
	movlw   .2
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA0	;sim
	
	movlw   .3
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA0	;sim
	call 	Delay_200ms
	incf	led_cnt , F		;
	
	movlw 	.4
	subwf	led_cnt , W					
	btfss	STATUS  , Z 	;led_cnt=4?
	goto   	LedCountLoop	;n�o
	clrf 	PORTA			;sim
	
	return
	
Delay_1s:
	nop
	return
Delay_200ms:
	nop
	return
end


				
	
	
		