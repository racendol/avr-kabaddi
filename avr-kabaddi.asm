.include "m8535def.inc"

;LCD init template borrowed from Lab 5
.def temp = r16 ; temporary register
.def EW = r23 ; for PORTA
.def PB = r24 ; for PORTB

INIT_STACK:
	ldi temp, low(RAMEND)
	ldi temp, high(RAMEND)
	out SPH, temp
	rjmp INIT_LCD_MAIN

INIT_LCD_MAIN:
	rcall INIT_LCD

	ser temp
	out DDRA,temp ; Set port A as output
	out DDRB,temp ; Set port B as output

	rjmp test_output

INIT_LCD:
	cbi PORTA,1 ; CLR RS
	ldi PB,0x38 ; MOV DATA,0x38 --> 8bit, 2line, 5x7
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi PB,$0E ; MOV DATA,0x0E --> disp ON, cursor ON, blink OFF
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	rcall CLEAR_LCD ; CLEAR LCD

	ldi PB,$06 ; MOV DATA,0x06 --> increase cursor, display sroll OFF
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	ret


CLEAR_LCD:
	cbi PORTA,1 ; CLR RS
	ldi PB,$01 ; MOV DATA,0x01
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	ret


test_output:
	sbi PORTA, 1 ;set rs

	ldi PB,0xB6 ;set カ to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	
	ldi PB,0xCA ;set ハ to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi PB,0xDE ;set '' to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi PB,0xAF ;set ッ to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi PB,0xC3 ;set テ to lcd
	out PORTB,PB 
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi PB,0xDE ;set '' to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi PB,0xA8 ;set ィ to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	cbi PORTA, 1 ;clear rs
	ldi PB,0xC0 ;pindah ke line ke 2 
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	sbi PORTA, 1 ;set rs
	ldi PB,0x32 ;set 2 to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	cbi PORTA, 1 ;clear rs
	ldi PB,0x94 ;pindah ke line ke 3 
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	sbi PORTA, 1 ;set rs
	ldi PB,0x33 ;set 3 to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	cbi PORTA, 1 ;clear rs
	ldi PB,0xD4 ;pindah ke line ke 4 
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	sbi PORTA, 1 ;set rs
	ldi PB,0x34 ;set 4 to lcd
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	rjmp forever

forever:
	rjmp forever
