init_field:
	rcall fill_border_field

	ldi ZL, low(2*init_field_text_table)
	ldi ZH, high(2*init_field_text_table)

	cbi PORTA, 1 ;clear rs
	ldi PB, 0xC0 ;pindah ke c0 (paling kiri line 2)
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi temp, 0 ;set temp jadi counter db
	rcall setup_text

	cbi PORTA, 1 ;clear rs
	ldi PB, 0xCF ;pindah ke cf
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi temp, 6
	rcall setup_text


	ldi temp2, 0x33 ;set temp2 jadi counter remaining
	rcall setup_num_text

	rjmp init_keypad

fill_border_field:
	cpi line, 0
	breq line1_fill

	cpi line, 1
	breq line2_fill

	cpi line, 2
	breq line3_fill

	ldi temp, 0xDB
	rjmp fill

	line1_fill:
	ldi temp, 0x87
	rjmp fill

	line2_fill:
	ldi temp, 0xC7
	rjmp fill

	line3_fill:
	ldi temp, 0x9B
	rjmp fill

	fill:
	add temp, temp2
	cbi PORTA, 1 ;clear rs
	mov PB, temp ;pindah ke posisi yg di temp
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	sbi PORTA, 1 ;set rs
	ldi PB,0xFF ;set garis hitam
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	cpi line, 3
	breq change
	subi line, -1
	rjmp fill_border_field

	change:
	cpi temp2, 5
	brne pindah_line
	ret

	pindah_line:
	ldi temp2, 5
	ldi line, 0
	rjmp fill_border_field


setup_text:
	lpm
	cpi temp, 10
	breq end_setup_text

	sbi PORTA, 1 ;set rs
	mov PB, r0 ;set yang ada di db
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	adiw ZL, 1
	subi temp, -1

	cpi temp, 6
	breq set_trap_text
	rjmp setup_text

	set_trap_text:
	cbi PORTA, 1 ;clear rs
	ldi PB, 0x95 ;pindah ke posisi tulisan trap/player
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	rjmp setup_text


	end_setup_text:
	ret


setup_num_text:
	cbi PORTA, 1 ;clear rs
	ldi PB, 0xA4 ;pindah ke A4
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	sbi PORTA, 1 ;set rs
	mov PB, temp2 ;set angka remaining di temp2
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ret

;keypad read input section
;code referenced from http://www.avr-asm-tutorial.net/avr_en/apps/key_matrix/keypad/keyboard.html#io

init_keypad:
	ldi temp, 0b11110000 ; data direction register column lines output
	out DDRD, temp    ; set direction register
	ldi temp, 0b00001111 ; Pull-Up-Resistors to lower four port pins
	out PORTD, temp    ; to output port
	
;
; Check any key pressed
;
read_key:
	ldi temp, 0b00001111 ; PB4..PB6=Null, pull-Up-resistors to input lines
	out PORTD, temp    ; of port pins PB0..PB3
	in temp, PIND    ; read key results
	ori temp,0b11110000 ; mask all upper bits with a one
	cpi temp,0b11111111 ; all bits = One?
	breq read_key        ; yes, no key is pressed

;
; Identify the key pressed
;
ReadKey:
	ldi ZH,HIGH(2*KeyTable) ; Z is pointer to key code table
	ldi ZL,LOW(2*KeyTable)

	; read column 4
	ldi temp, 0b01111111 ; PB7 = 0
	out PORTD, temp
	in temp, PIND ; read input line
	ori temp, 0b11110000 ; mask upper bits
	cpi temp, 0b11111111 ; a key in this column pressed?
	brne KeyRowFound ; key found
	adiw ZL,4 ; column not found, point Z one row down

	; read column 3
	ldi temp, 0b10111111 ; PB6 = 0
	out PORTD, temp
	in temp, PIND ; read input line
	ori temp, 0b11110000 ; mask upper bits
	cpi temp, 0b11111111 ; a key in this column pressed?
	brne KeyRowFound ; key found
	adiw ZL,4 ; column not found, point Z one row down

	; read column 2
	ldi temp, 0b11011111 ; PB5 = 0
	out PORTD, temp
	in temp, PIND ; read again input line
	ori temp, 0b11110000 ; mask upper bits
	cpi temp, 0b11111111 ; a key in this column?
	brne KeyRowFound ; column found
	adiw ZL,4 ; column not found, another four keys down

	; read column 1
	ldi temp, 0b11101111 ; PB4 = 0
	out PORTD, temp
	in temp, PIND ; read again input line
	ori temp, 0b11110000 ; mask upper bits
	cpi temp, 0b11111111 ; a key in this column?
	brne KeyRowFound ;column found

	breq read_key ; unexpected: no key in this column pressed

KeyRowFound: ; column identified, now identify row
	lsr temp ; shift a logic 0 in left, bit 0 to carry
	brcc KeyFound ; a zero rolled out, key is found
	adiw ZL,1 ; point to next key code of that column
	rjmp KeyRowFound ; repeat shift

KeyFound: ; pressed key is found 
	lpm ; read key code to R0
	rjmp KeyProc ; countinue key processing

KeyProc:
	rjmp KeyProc
