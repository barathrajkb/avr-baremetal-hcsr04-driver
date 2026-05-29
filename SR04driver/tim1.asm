/*
 * tim1.asm
 *
 *  Created: 29-05-2026 13:00:32
 *   Author: barathrajkb
 */ 

TIM1_Init:
	; PB0 input
    cbi DDRB, DDB0

    ; Clear timer
    clr r16
    sts TCNT1H, r16
    sts TCNT1L, r16

    ; Clear pending capture flag
    ldi r16, 0x20
    out TIFR1, r16

    ; Disable Timer1 interrupts
    clr r16
    sts TIMSK1, r16

    ; Configure Timer1
    clr r16
    sts TCCR1A, r16

    ldi r16, 0x42
    sts TCCR1B, r16

    ret