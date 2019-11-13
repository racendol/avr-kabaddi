.include "m8535def.inc"

.def EW = r23 ; for PORTA
.def PB = r24 ; for PORTB

.def line = r20 ;register untuk menyimpan line ke berapa
.def col = r21 ;register untuk menyimpan kolom ke berapa

.def health1 = r10 ;menyimpan sisa nyawa player pertama
.def health2 = r11 ;menyimpan sisa nyawa plaer ke dua
.def current_player = r12 ;menyimpan player mana yang sedang jalan
.def penalty = r13 ;reg yg menyimpan apakah player kena penalty atau tidak

.def temp = r16 ; temporary register
.def temp2 = r17 ;temp reg 2
.def temp3 = r18 ;temp reg 3
.def temp4 = r19

.equ LINE1 = 0x88 ;kotak paling kiri dari field line pertama
.equ LINE2 = 0XC8 ;kotak paling kiri dari field line ke dua
.equ LINE3 = 0x9C ;kotak paling kiri dari field line ke tiga
.equ LINE4 = 0xDC ;kotak paling kiri dari field line ke empat

.equ FIELD_DATA = 0x0060 ;SRAM dari 0x0060 - 0x006F berisi data di field

init_game:
	ldi temp, 3

	mov health1, temp
	mov health2, temp
	clr line
	clr col

	mov current_player, line ;set curr player jadi 0 (player 1)
	mov penalty, line ;set penalty jadi 0 (jadi belum ada penalty)

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
.include "setup-game.asm"



forever:
	rjmp forever



init_field_text_table:
	.db "Set Up", "trap", "Rem:", "player"

KeyTable: ;dari kiri
	.db 0x03, 0x07, 0x0B, 0x0F ; kolom ke empat
	.DB 0x02, 0x06, 0x0A, 0x0E ; kolom ke tiga
	.DB 0x01, 0x05, 0x09, 0x0D ; kolom ke dua
	.DB 0x00, 0x04, 0x08, 0x0C ; kolom pertama
