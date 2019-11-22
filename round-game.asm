init_round:
	rcall INIT_LCD

	ldi temp, 0
	rcall init_hp

	ldi line, 0
	ldi temp2, 0
	rcall fill_border_field

	rcall place_player
	rcall check_square

	rjmp end

RESET_SRAM:
	ldi XH, high(FIELD_DATA)
	ldi XL, low(FIELD_DATA)

	ldi temp, 16
	ldi temp2, 0xFF

	SRAM_loop:
		st X, temp2
		inc XL
		dec temp

		tst temp
		brne SRAM_loop
		
	ldi temp, 0
	ldi temp2, 0

	ret

move:
	cbi PORTA, 1 ;clear rs
	mov PB, temp2 ;pindah ke posisi yg di temp2
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ret

print:
	sbi PORTA, 1 ;set rs
	mov PB, temp2
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ret

init_hp:
	ldi temp2, 0b10000001
	rcall move
	
	rcall write_hp

	inc temp

	ldi temp2, 0b10001110
	rcall move

	rcall write_hp

	ret
	
	write_hp:
		ldi temp2, 0b01001000 ;H
		rcall print

		ldi temp2, 0b01010000 ;P
		rcall print
	
		ldi temp2, 0b00100000 ;space
		rcall print

		ldi temp2, 0b01010000 ;P
		rcall print

		tst temp
		breq write_player1

		rjmp write_player2


	write_player1:
		ldi temp2, 0b00110001 ;1
		rcall print

		ldi temp2, 0b11000011
		rcall move

		mov temp2, health1

		rjmp write_current_hp

	write_player2:
		ldi temp2, 0b00110010 ;2
		rcall print

		ldi temp2, 0b11010000
		rcall move

		mov temp2, health2

		rjmp write_current_hp

	write_current_hp:
		cpi temp2, 3
		brne case_2
		ldi temp2, 0b00110011
		rjmp print_hp

		case_2:
			cpi temp2, 2
			brne case_1
			ldi temp2, 0b00110010
			rjmp print_hp

		case_1:
			ldi temp2, 0b00110001

		print_hp:
			rcall print

		ret

place_player:

	ldi col, 3
	
	place_loop:
		in temp2, PINA
		cpi temp2, 0b00001111
		brlo place_loop
	
	sbrc temp2, 4
	rjmp first_square
	
	sbrc temp2, 5
	rjmp second_square

	sbrc temp2, 6
	rjmp third_square

	sbrc temp2, 7
	rjmp fourth_square

	first_square:
		ldi line, 0

		rcall get_player_loc
		rcall move

		rjmp print_player

	second_square:
		ldi line, 1

		rcall get_player_loc
		rcall move

		rjmp print_player

	third_square:
		ldi line, 2

		rcall get_player_loc
		rcall move

		rjmp print_player

	fourth_square:
		ldi line, 3

		rcall get_player_loc
		rcall move
	
	print_player:
		ldi temp2, 0b00111100
		rcall print

		ret

player_movement:
	move_loop:
		in temp2, PINA
		cpi temp2, 0b00001111
		brlo move_loop
	
	sbrc temp2, 4
	rjmp forward
	
	sbrc temp2, 5
	rjmp backward

	sbrc temp2, 6
	rjmp left

	sbrc temp2, 7
	rjmp right

	forward:
		cpi col, 0
		breq finish
		
		rcall del_player
		dec col
		rcall move_player

		rjmp check_square

	backward:
		cpi col, 3
		breq player_movement
		
		rcall del_player
		inc col
		rcall move_player

		rjmp check_square
	
	left:
		cpi line, 3
		breq player_movement

		rcall del_player
		dec col
		inc line
		rcall move_player

		rjmp check_square
		
	right:
		cpi line, 0
		breq player_movement

		rcall del_player
		dec col
		dec line
		rcall move_player

		rjmp check_square

	finish:
		rcall round_finish
		ret

del_player:
	rcall get_player_loc
	rcall move

	ldi temp2, 0b00100000
	rcall print

	ret

move_player:
	rcall get_player_loc
	rcall move

	rcall print_player

	ret

get_player_loc:
	tline0:
		cpi line, 0
		brne tline1
		ldi temp2, LINE1

	tline1:
		cpi line, 1
		brne tline2
		ldi temp2, LINE2
	
	tline2:
		cpi line, 2
		brne tline3
		ldi temp2, LINE3

	tline3:
		cpi line, 3
		brne add_col
		ldi temp2, LINE4
		
	add_col:
		add temp2, col
	
	ret

get_loc_data:
	ldi XH, high(FIELD_DATA)
	ldi XL, low(FIELD_DATA)

	ldi temp, 0

	push line

	loop_line:
		tst line
		breq line_end

		subi temp, -4
		dec line
		rjmp loop_line

	line_end:
		pop line

	add temp, col

	add XL, temp
	
	ret


check_square:
	rcall get_loc_data

	ld temp3, X

	cpi temp3, 0x11
	breq trapped

	cpi temp3, 0x10
	breq pointed

	rjmp player_movement
	
	trapped:
		rcall get_player_loc
		rcall move
		ldi temp2, 0b01011000
		rcall print

		ret
	
	pointed:
		inc point
		ldi temp2, 0xFF
		st X, temp2
		
		rjmp player_movement

round_finish:
	mov temp2, current_player
	cpi temp2, 0
	brne player2
	
	sub health1, point

	ret

	player2:
		sub health2, point
	
	ret

end:
	rcall RESET_SRAM

	mov temp2, health1
	cpi temp2, 0
	breq print_win
	
	mov temp2, health2
	cpi temp2, 0
	breq print_win

	mov temp2, current_player
	cpi temp2, 1
	breq set_player2
	
	ldi temp2, 1
	rjmp switch

	set_player2:
		ldi temp2, 0
	
	switch:
		mov current_player, temp2
	
	ldi line, 0
	ldi temp2, 0
	mov point, line
	rjmp init_field

	print_win:
		rcall INIT_LCD
		ldi temp2, 0xC7
		rcall move

		ldi temp2, 0b01010000
		rcall print

		ldi temp2, 0b00110000
		add temp2, current_player
		inc temp2
		rcall print

		ldi temp2, 0b00100000
		rcall print

		ldi temp2, 0b01010111
		rcall print

		ldi temp2, 0b01101001
		rcall print

		ldi temp2, 0b01101110
		rcall print

over:
