;
; SR04driver.asm
;
; Created: 29-05-2026 12:46:02
; Author : barathrajkb
;
.include "m328pdef.inc"
.include "globals.asm"

; HC-SR04 Port Declaration
.equ TRIG_PORT = PORTD
.equ TRIG_DDR  = DDRD
.equ TRIG_BIT  = 2

.equ ECHO_PIN  = PINB
.equ ECHO_DDR  = DDRB
.equ ECHO_BIT  = 0

.cseg
.org 0x0000
rjmp reset

; ASM file inclusion
.include "tim1.asm"
.include "hcsr04.asm"
.include "uart.asm"

reset:
    ; Initialize Stack Pointer
    ldi r16, HIGH(RAMEND)
    out SPH, r16
    ldi r16, LOW(RAMEND)
    out SPL, r16

	; Turn ON onboard LED (D13 / PB5)
    sbi DDRB, DDB5
    sbi PORTB, PORTB5

	; Call TIM1 Initialization
	rcall TIM1_Init
	; Call Sensor Initialization
	rcall HCSR04_Init
	; Call UART Initialization
	rcall UART_Init
main:
    rcall HCSR04_MeasureDistance
	rcall UART_TxPacket
	rcall Delay_100ms
	rjmp main


Delay_100ms:
    ldi r18, 9
	outer_loop:
		ldi r19, 255

		middle_loop:
			ldi r20, 230

			inner_loop:
				dec r20
				brne inner_loop

				dec r19
				brne middle_loop

				dec r18
				brne outer_loop

	ret

