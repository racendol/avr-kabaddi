.include "m8535def.inc"

.def EW = r23 ; for PORTA
.def PB = r24 ; for PORTB

.def line = r20 ;register untuk menyimpan line ke berapa
.def col = r21 ;register untuk menyimpan kolom ke berapa

.def health1 = r10 ;menyimpan sisa nyawa player pertama
.def health2 = r11 ;menyimpan sisa nyawa plaer ke dua
.def current_player = r12 ;menyimpan player mana yang sedang jalan
.def penalty = r13 ;reg yg menyimpan apakah player kena penalty atau tidak
.def point = r14 ; stores point accumulated in a round

.def temp = r16 ; temporary register
.def temp2 = r17 ;temp reg 2
.def temp3 = r18 ;temp reg 3
.def temp4 = r19

.equ LINE1 = 0x88 ;kotak paling kiri dari field line pertama
.equ LINE2 = 0XC8 ;kotak paling kiri dari field line ke dua
.equ LINE3 = 0x9C ;kotak paling kiri dari field line ke tiga
.equ LINE4 = 0xDC ;kotak paling kiri dari field line ke empat

.equ FIELD_DATA = 0x0060 ;SRAM dari 0x0060 - 0x006F berisi data di field

.org $00
rjmp MAIN
.org $01
rjmp ext_int0
.org $13
rjmp ISR_TCOM0

MAIN:

INIT_STACK:
	ldi temp, low(RAMEND)
	ldi temp, high(RAMEND)
	out SPH, temp

RESET:

init_game:
	clr point ; clear everything
	clr penalty
	clr health1
	clr health2
	clr line
	clr col
	clr temp
	clr temp2
	clr temp3
	clr temp4

	ldi temp, 3

	mov health1, temp
	mov health2, temp
	clr line
	clr col

	mov current_player, line ;set curr player jadi 0 (player 1)
	mov penalty, line ;set penalty jadi 0 (jadi belum ada penalty)


INIT_INTERRUPT:
	ldi temp,0b00000010
	out MCUCR,temp
	ldi temp,0b01000000
	out GICR,temp

	sei

	clr temp

CLEAR_SRAM:
	ldi XH, high(FIELD_DATA)
	ldi XL, low(FIELD_DATA)

	ldi temp, 16
	ldi temp2, 0xFF

	SRAM_clear_loop:
		st X, temp2
		inc XL
		dec temp

		tst temp
		brne SRAM_clear_loop

INIT_LED:
	ser temp ; load $FF to temp
	out DDRD,temp ; Set PORTD to output

	ldi temp,0x02
	out PORTD,temp ; Update LEDS

	clr temp
	clr temp2


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

.include "setup-game.asm"
.include "round-game.asm"

forever:
	rjmp forever

ext_int0:
	pop temp ; throw away the address
	ldi ZL, low(RESET) ; load new address
	ldi ZH, high(RESET)
	push ZL ; push new address
	push ZH

	clr ZL ; clear everything
	clr ZH
	clr temp

	reti ; jump to new address

init_field_text_table:
	.db "Set Up", "trap", "Rem:", "player"

KeyTable: ;dari kiri
	.db 0x03, 0x07, 0x0B, 0x0F ; kolom ke empat
	.DB 0x02, 0x06, 0x0A, 0x0E ; kolom ke tiga
	.DB 0x01, 0x05, 0x09, 0x0D ; kolom ke dua
	.DB 0x00, 0x04, 0x08, 0x0C ; kolom pertama
