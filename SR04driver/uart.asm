/*
 * uart.asm
 *
 *  Created: 29-05-2026 18:37:48
 *   Author: barathrajkb
 */ 

UART_Init:
	; Baud = 9600 @ 16 MHz
	ldi r16, HIGH(103)
	sts UBRR0H, r16

	ldi r16, LOW(103)
	sts UBRR0L, r16

	; Enable TX
	ldi r16, (1<<TXEN0)
	sts UCSR0B, r16

	; 8 data bits, 1 stop bit, no parity
	ldi r16, (1<<UCSZ01)|(1<<UCSZ00)
	sts UCSR0C, r16

	ret

UART_TxByte:
	wait_udre:
		lds r17, UCSR0A

		sbrs r17, UDRE0
		rjmp wait_udre

		sts UDR0, r16

		ret

UART_TxPacket:

    ; Start byte
    ldi r16, 0xAA
    rcall UART_TxByte

    ; Distance low byte
    lds r16, distance_l
    rcall UART_TxByte

    ; Distance high byte
    lds r16, distance_h
    rcall UART_TxByte

    ret