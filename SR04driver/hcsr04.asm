/*
 * hcsr04.asm
 *
 *  Created: 29-05-2026 13:38:29
 *   Author: barathrajkb
 */ 

HCSR04_Init:
	cbi PORTD, PORTD2
	sbi DDRD, DDD2
	ret

HCSR04_Trigger:
	sbi PORTD, PORTD2
	ldi r16, 60
	trigger_delay:
		dec r16
		brne trigger_delay
	cbi PORTD, PORTD2
	ret

HCSR04_WaitForEchoRise:

    ; Clear Input Capture Flag
    ldi r16, 0x20
    out TIFR1, r16

	wait_rise:
		in r16, TIFR1

		sbrc r16, ICF1
		rjmp rise_detected

		rjmp wait_rise

	rise_detected:

		; Read captured timestamp
		lds r16, ICR1L
		lds r17, ICR1H

		; Store rising edge timestamp
		sts rise_time_l, r16
		sts rise_time_h, r17

		; Switch to falling edge capture
		ldi r16, 0x02
		sts TCCR1B, r16

		ret

HCSR04_WaitForEchoFall:
	; Clear Input Capture Flag
    ldi r16, 0x20
    out TIFR1, r16

	wait_fall:
		in r16, TIFR1

		sbrc r16, ICF1
		rjmp fall_detected

		rjmp wait_fall
	
	fall_detected:
		; Read captured timestamp
		lds r16, ICR1L
		lds r17, ICR1H

		; Store falling edge timestamp
		sts fall_time_l, r16
		sts fall_time_h, r17

		; Switch to rising edge capture
		ldi r16, 0x42
		sts TCCR1B, r16

		ret


HCSR04_ProcessMeasurement:
	; Load falling edge time
	lds r16, fall_time_l
	lds r17, fall_time_h
	; Load rising edge time
	lds r18, rise_time_l
	lds r19, rise_time_h
	; Calculate pulse width
	sub r16, r18
	sbc r17, r19
	; r17:r16 contains pulse_width
	sts pulse_width_l, r16
	sts pulse_width_h, r17

	; Clear register for storing distance
	clr r20
	clr r21

	; Distance(cm) = (pulse_width)/116

	ldi r18, 0x74
	ldi r19, 0x00

	division_loop:
		cp  r16, r18
		cpc r17, r19

		brlo division_done

		sub r16, r18
		sbc r17, r19

		; distance ++
		inc r20
		brne no_overflow 
		inc r21 

		no_overflow:
		rjmp division_loop

	division_done:
		sts distance_l, r20
		sts distance_h, r21

		ret

HCSR04_MeasureDistance:
	clr r16
    sts TCNT1H, r16
    sts TCNT1L, r16

    rcall HCSR04_Trigger
    rcall HCSR04_WaitForEchoRise
    rcall HCSR04_WaitForEchoFall
    rcall HCSR04_ProcessMeasurement

    ret