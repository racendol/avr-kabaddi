.include "m8535def.inc"

.def temp = r16 ; temporary register
.def EW = r23 ; for PORTA
.def PB = r24 ; for PORTB

.def line = r17 ;register untuk menyimpan line ke berapa
.def col = r18 ;register untuk menyimpan kolom ke berapa

.def health1 = r19 ;menyimpan sisa nyawa player pertama
.def health2 = r20 ;menyimpan sisa nyawa plaer ke dua

.def posA = r1 ;posisi player dari player defending (A)
.def posB = r2 ;posisi player dari player defending (B)
.def posC = r3 ;posisi player dari player defending (C)

.def trapA = r4 ;posisi trap dari player defending (A)
.def trapB = r5 ;posisi trap dari player defending (B)
.def trapC = r6 ;posisi trap dari player defending (C)


.equ LINE1 = 0x80 ;start dari line pertama
.equ LINE2 = 0XC0 ;start dari line ke dua
.equ LINE3 = 0x94 ;start dari line ke tiga
.equ LINE4 = 0xD4 ;start dari line ke empat


INIT_STACK:
	ldi temp, low(RAMEND)
	ldi temp, high(RAMEND)
	out SPH, temp

;LCD init template borrowed from Lab 5
.include "init-lcd.asm"

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

rcall CLEAR_LCD

;TODO: complete this!
.include "start-game.asm"


forever:
	rjmp forever
