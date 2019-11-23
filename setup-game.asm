init_field:
	rcall INIT_LCD
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
	fill_prep:
		clr line
		clr temp2

	border_loop:
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
	rjmp border_loop

	change:
	cpi temp2, 5
	brne pindah_line
	ret

	pindah_line:
	ldi temp2, 5
	ldi line, 0
	rjmp border_loop


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

	;init untuk mengecek input keypad
	ldi col, 4 
	ldi line, 1

	ldi temp2, 3
	ldi temp, 0

	mov temp3, health2 ;pindah health player 1 ke temp3

	cpse current_player, temp ;kalau current player adalah 0 (player 1), maka skip perintah dibawah
	mov temp3, health1 ;pindah health player 2 ke temp3

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
	subi col, 1 ;decrement column

	; read column 3
	ldi temp, 0b10111111 ; PB6 = 0
	out PORTD, temp
	in temp, PIND ; read input line
	ori temp, 0b11110000 ; mask upper bits
	cpi temp, 0b11111111 ; a key in this column pressed?
	brne KeyRowFound ; key found
	adiw ZL,4 ; column not found, point Z one row down
	subi col, 1 ;decrement column

	; read column 2
	ldi temp, 0b11011111 ; PB5 = 0
	out PORTD, temp
	in temp, PIND ; read again input line
	ori temp, 0b11110000 ; mask upper bits
	cpi temp, 0b11111111 ; a key in this column?
	brne KeyRowFound ; column found
	adiw ZL,4 ; column not found, another four keys down
	subi col, 1 ;decrement column

	; read column 1
	ldi temp, 0b11101111 ; PB4 = 0
	out PORTD, temp
	in temp, PIND ; read again input line
	ori temp, 0b11110000 ; mask upper bits
	cpi temp, 0b11111111 ; a key in this column?
	brne KeyRowFound ;column found

	ldi col, 4 ;balikin lagi column ke 4
	breq read_key ; unexpected: no key in this column pressed

KeyRowFound: ; column identified, now identify row
	lsr temp ; shift a logic 0 in left, bit 0 to carry
	brcc KeyProc ; a zero rolled out, key is found

	adiw ZL,1 ; point to next key code of that column
	subi line, -1 ;increment line
	rjmp KeyRowFound ; repeat shift

;process keyinput
KeyProc:
	;r5 - r9 = register digunakan untuk menyimpan posisi yang telah diinput sebelumnya
	;r5 - r7 = trap
	;r8 - r9 = player (2 saja karena untuk posisi terakhir tidak usah dicek)
	;posisi disimpen dengan value 0xpq, dengan p = line, dan q = column
	mov temp4, line
	lsl line
	lsl line
	lsl line
	lsl line
	add line, col
	mov r0, line
	mov line, temp4

	;cek kalau player pernah menempati posisi yang sama
	cp r5, r0 ;if r5 = r0
	breq penalty_input ;berarti penalty input

	cp r6, r0 ;if r5 = r0
	breq penalty_input ;berarti penalty input

	cp r7, r0 ;if r5 = r0
	breq penalty_input ;berarti penalty input

	cp r8, r0 ;if r5 = r0
	breq penalty_input ;berarti penalty input

	cp r9, r0 ;if r5 = r0
	breq penalty_input ;berarti penalty input

	tst temp2 ;cek apakah player sudah menempati semua trap
	brne trap_pos_input ;kalau belom, maka ke trap_pos_input
	rjmp player_pos_input ;kalau sudah, maka ke player_pos_input

	;cek apakah input column player sama
	trap_pos_input:
	mov temp, r5 ;pindah r5 ke temp
	ori temp, 0xF0 ;mask bit bagian line (p)

	mov temp4, r0 ;pindah r0  ke temp4
	ori temp4, 0xF0 ;mask bit bagian line (p)

	cp temp, temp4 ;compare bit column
	breq penalty_input ;kalau sama, maka penalty

	mov temp, r6 ;pindah r6 ke temp
	ori temp, 0xF0 ;mask bit bagian line (p)

	cp temp, temp4 ;compare bit column (q)
	breq penalty_input ;kalau sama, maka penalty

	rjmp save_position ;kalau tidak sama di keduanya, maka posisi valid

	player_pos_input:
	mov temp, r8 ;pindah r8 ke temp
	ori temp, 0xF0 ;mask bit bagian line (p)

	mov temp4, r0 ;pindah r0  ke temp4
	ori temp4, 0xF0 ;mask bit bagian line (p)

	cp temp, temp4 ;compare bit column (q)
	breq penalty_input ;kalau sama, maka penalty

	mov temp, r9 ;pindah r9 ke temp
	ori temp, 0xF0 ;mask bit bagian line (p)

	cp temp, temp4 ;compare bit column (q)
	breq penalty_input ;kalau sama, maka penalty
	
	rjmp save_position ;kalau tidak sama di keduanya, maka posisi valid

	penalty_input:
	ldi temp, 1 ;load temp dengan 1
	mov penalty, temp ;penalty bit jadi 1

	tst temp2
	brne penalty_trap
	ldi temp, 0x4F
	rjmp show_pos_to_lcd

	penalty_trap:
	ldi temp, 0x58
	rjmp show_pos_to_lcd

	save_position:
	rcall save_to_regist
	;init pointer field_data
	ldi XH, high(FIELD_DATA)
	ldi XL, low(FIELD_DATA)

	lpm ;load data yg ditunjuk Z di keytable ke r0
	add XL, r0 ;add offset dari xl, dengan value yg ada di r0

	tst temp2
	brne save_trap
	rjmp save_player

	save_trap:
	ldi temp, 0x11
	st X, temp ;store 0xFF ke posisi address yg ditunjuk x
	ldi temp, 0x58 ;simbol X untuk lcd
	rjmp show_pos_to_lcd

	save_player:
	ldi temp, 0x10
	st X, temp ;store 0xF0 ke posisi address yg ditunjuk x
	ldi temp, 0x4F ;simbol O untuk lcd
	rjmp show_pos_to_lcd


	show_pos_to_lcd:
	cpi line, 1
	breq line1_write
	cpi line, 2
	breq line2_write
	cpi line, 3
	breq line3_write

	ldi line, LINE4
	rjmp show_lcd_pos

	line1_write:
	ldi line, LINE1
	rjmp show_lcd_pos

	line2_write:
	ldi line, LINE2
	rjmp show_lcd_pos

	line3_write:
	ldi line, LINE3
	rjmp show_lcd_pos

	show_lcd_pos:
	add col, line ;column = line + column (posisi full)
	subi col, 1 ;dec column karena menggunakan zero indexing

	cbi PORTA, 1 ;clear rs
	mov PB, col ;pindah ke A4
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	sbi PORTA, 1 ;set rs
	mov PB, temp ;set dengan karakter yang diset di temp
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	rcall DELAY_01 ;butuh delay, karena kalo gk pake somehow ngesubi 2 kali

	ldi line, 1
	ldi col, 4

	tst temp2 ;cek apakah udah input semua trap
	breq dec_player_count_tmp ;kalau maka decrement player

	subi temp2, 1 ;decrement trap count
	rcall change_num_text ;ubah text counter di lcd
	
	cpi temp2, 0 ;cek apakah abis di dec jadi 0
	breq change_text_to_player ;kalau iya, maka ubah text trap jadi player

	rjmp read_key ;ulang lagi

	dec_player_count_tmp:
	subi temp3, 1 ;decrement player count
	rcall change_num_text ;ubah text counter di lcd

	tst temp3
	breq end_keypad_input ;kalau sudah input semua player, maka end	
	rjmp read_key ;else ulang lagi

save_to_regist:
	cpi temp2, 3
	breq add_r5

	cpi temp2, 2
	breq add_r6

	cpi temp2, 1
	breq add_r7

	cpi temp3, 3
	breq add_r8

	cpi temp3, 2
	breq add_r9
	
	add_r5:
	mov r5, r0
	ret

	add_r6:
	mov r6, r0
	ret

	add_r7:
	mov r7, r0
	ret

	add_r8:
	mov r8, r0
	ret

	add_r9:
	mov r9, r0
	ret

change_num_text:
	mov r0, temp2 ;simpen dahulu temp2 ke r0
	tst temp2 ;check kalau sudah masang semua trap
	brne trap_num_change ;kalau belom maka display untuk trap

	;kalau sudah maka display untuk player
	mov temp2, temp3 ;temp2 = temp3
	subi temp2, -0x30 ;temp2 + 0x30 = karakter lcd dengan karakter angka temp2 
	rcall setup_num_text ;display to lcd, dengan value di temp2
	mov temp2, r0 ;value awal balik lagi ke temp2
	ret

	trap_num_change:
	subi temp2, -0x30 ;temp2 + 0x30 = karakter lcd dengan karakter angka temp2 
	rcall setup_num_text ;display to lcd
	mov temp2, r0 ;value awal balik lagi ke temp2
	ret 

DELAY_01:
	; Generated by delay loop calculator
	; at http://www.bretmulvey.com/avrdelay.html
	;
	; DELAY_CONTROL 40 000 cycles
	; 5ms at 8.0 MHz

	    ldi  temp, 52
	    ldi  temp4, 242
	L1: dec  temp4
	    brne L1
	    dec  temp
	    brne L1
	    nop
	ret

change_text_to_player:
	cbi PORTA, 1 ;clear rs
	ldi PB, 0x94 ;pindah ke A4
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ldi ZL, low(2*init_field_text_table)
	ldi ZH, high(2*init_field_text_table)

	adiw ZL, 14
	ldi temp, 6
	rcall setup_text

	ldi temp, 8
	rcall setup_text

	rjmp read_key
	

end_keypad_input:
	;clear r5-r9 register
	clr r5
	clr r6
	clr r7
	clr r8
	clr r9
