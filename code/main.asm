#include <p16f887.inc>
list p=16f887
__CONFIG _CONFIG1, 	0x2ff4
__CONFIG _CONFIG2,	0x3FFF

#define button	PORTB,RB0
	cblock	0x20 	;dando um nome para um endere�o de memoria
		led_cnt
		cnt_1
		cnt_2
		_wreg
		_status
		timer_counter_5s
		timer_counter_50ms
		level		;0 	hard
					;1	easy
		sequency
		move
		last_move
		last_input
		timeout		;0
					;1
		current_move
	endc
	HARD_TIMEOUT	EQU		.3
	EASY_TIMEOUT	EQU		.5
	MOVE_BASE_ADD	EQU		0x5F
	TMR0_50ms		EQU		.61
	LED_RED			EQU 	b'00000001'
	LED_YELLOW		EQU		b'00000010'
	LED_GREEN		EQU		b'00000100'
	LED_BLUE		EQU		b'00001000'
	
	org		0x00 	;vetor de inicializa��o
	goto	Start
	
	org		0x04	;vetor de interrup��o
	movwf	_wreg
	swapf	STATUS, W
	movwf 	_status
	clrf	STATUS
	btfsc	INTCON,T0IF			;T0IF==1?
	goto	Timer0Interrupt		;yes
	goto	ExitInterrupt		;no
	
Timer0Interrupt:
	bcf		INTCON,T0IF;
	incf	timer_counter_5s,F
	incf	timer_counter_50ms,F
	movlw 	TMR0_50ms
	movwf	TMR0
	goto	ExitInterrupt
	
ExitInterrupt:
	swapf	_status,W
	movwf	STATUS
	swapf	_wreg,F
	swapf	_wreg,W
	
	retfie	
Start:
	;--- I/O config ----
	clrf	timer_counter_5s
	clrf	timer_counter_50ms
	bsf		STATUS,RP0 	;seleciona o banco1
	movlw	B'11110000'
	movwf	TRISA		;configurar RA0-RA3 como saida
						;e RA3-RA4 como entrada
	bcf		TRISB,TRISB0	;configurando RB0 como entrada - start
	bcf		TRISB,TRISB1	;configurando RB1 como entrada - level
	
	clrf 	TRISD			;dodos os pinos como entrada
	
	bsf		STATUS,RP1
	clrf	ANSELH
	clrf	ANSEL		; Configura a PORTA como entrada digital
	
;-------Configura��o do TIMER0 --------
;INTCON,TMR0,OPTION_REG
;OPTION_REG: 
;TOCS=0 (INTOSC/4)
;PSA= 0 (PRESCALER TMR0)
;PS=111
	bcf		STATUS,RP1		;indo para o bank1		
	movlw 	b'00000111'		;
	iorwf 	OPTION_REG,F	;setando PSA<2:0>
	movlw 	b'11010111' 	;
	andwf 	OPTION_REG,F	;clear TOCS, PSA 
	bcf		STATUS,RP0		;INDO PARA O BANK 0	
	movlw 	.61
	movwf	TMR0
	bcf		INTCON,T0IF		;limpando a Flag
	bsf		INTCON,T0IE		;abilitando interrup��p de TMRO
	bsf		INTCON,GIE		;abilitando interrup��es
	call	Rotina_Inicializacao
	
	movlw	MOVE_BASE_ADD
	movwf	FSR
	bcf		STATUS,IRP

Main:
	btfsc	button		;bot�o start pressionado
	goto	Main
	
	
	movf	TMR0,W
	movwf	move		;copia TMR0 para move
	clrf	sequency	;sequencia igual a zero
	btfsc	PORTB,RB1	;sele��o de level
	goto	LevelEasy
	
	goto	LevelHard

LevelEasy:
	bcf 	level,0
	goto	Main_Loop


LevelHard:
	bsf 	level,0
	goto	Main_Loop

Main_Loop:
	call	SorteiaNumero
	call	StoreNumber
	goto Main

;--------------
;Recebe move
SorteiaNumero:

	movlw	0x03
	andwf	move			;clear bits <7:2>

	movlw	.0
	subwf	move, W
	btfsc	STATUS,Z
	retlw	LED_RED
	
	movlw	.1
	subwf	move, W
	btfsc	STATUS,Z
	retlw	LED_YELLOW

	movlw	.2
	subwf	move, W
	btfsc	STATUS,Z
	retlw	LED_GREEN
	
	movlw	.3
	subwf	move, W
	btfsc	STATUS,Z
	retlw	LED_BLUE

StoreNumber:
	movwf	INDF
	incf	FSR,F
	incf	last_move,F
	return
Entrada_de_movimento
	bcf		STATUS,RP0
	bcf		STATUS,RP1		;bank0
	clrf	last_input
	movlw	MOVE_BASE_ADD
	movwf	FSR				;
InputLoop
	movf	PORTD,W
	andlw	0x0FF			;limpado RD <7:4>
	sublw	0x00
	btfss	STATUS,Z		;Testando entradas
	goto	ButtonNotPressed
	goto	ButtonPressed

ButtonNotPressed:
	btfss	timeout,0			;ocorreu timeout
	goto	InputLoop		;n�o
	return
ButtonPressed:
	movwf current_move
	call CompareInput
	sublw	.0
	btfsc	STATUS,Z		;bot�o correto pressionado?
	return					;n�o
	
	incf	last_input
	incf	FSR,F
	
	movf	last_input,W
	subwf	last_move,W
	btfsc	STATUS,C		;last_input>last_move
	return
	goto	InputLoop

CompareInput:
	movf	current_move
	subwf	INDF,W
	btfss	STATUS,Z
	retlw	.0				;botao errado

	retlw	current_move
	
			
Rotina_Inicializacao:
	bcf		STATUS,RP1		;indo para o banco0
	bcf		STATUS,RP0
	movlw	0x0F			;movendo b'00001111' 
	movwf	PORTA			;ligando os leds
	call 	Delay_1s		;chama fun��o de delay
	clrf 	led_cnt			;led_cnt=0
	
LedCountLoop:
	clrf	PORTA			;apaga todos os leds
	movlw   .0
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA0	;sim
	
	movlw   .1
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA1	;sim
	
	movlw   .2
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA2	;sim
	
	movlw   .3
	subwf	led_cnt , W
	btfsc	STATUS  , Z 	;led_cnt=0?
	bsf		PORTA   , RA3	;sim
	call 	Delay_200ms
	incf	led_cnt , F		;
	
	movlw 	.4
	subwf	led_cnt , W					
	btfss	STATUS  , Z 	;led_cnt=4?
	goto   	LedCountLoop	;n�o
	clrf 	PORTA			;sim
	
	return
	
Delay_1s:
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	return

Delay_1ms:
	movlw	.248
	movwf	cnt_1
Delay1:	
	nop
	decfsz	cnt_1,F			;decrementado cnt_1
	goto Delay1
							;cnt =0 
	return

Delay_200ms
	movlw	.200
	movwf	cnt_2
Delay_2
	call	Delay_1ms
	decfsz	cnt_2,F
	goto	Delay_2
	return
	
end


				
	
	
		