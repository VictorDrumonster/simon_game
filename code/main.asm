#include <pic26f887.inc>
list p=16f887

	cblock	0x20 	;dando um nome para um endereço de memoria
		led_cnt
	endc

	org		0x00 	;vetor de inicialização
	goto	Start
	
	org		0x04	;vetor de interrupção
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
	goto	Rotina_Inicializacao
	
Rotina_Inicializacao:
	bcf		STATUS,RP1		;indo para o banco0
	bcf		STATUS,RP0
	movlw	0x0F			;movendo b'00001111' 
	movwf	PORTA			;ligando os leds
	call 	Delay_1s		;chama função de delay
	clrf	PORTA			;apaga todos os leds
	
	
	
	
	
		