init_round: ; Func to prepare the round before player's input

	check_penalty:
		tst penalty ; Check if there's any penalty invoked
		breq setup_round ; If there's none, continue the round

		clr penalty ; Clear the penalty register

		test_p1:
			tst current_player ; Check if it's player 1's turn
			brne test_p2 ; If it's not, jump to player2's case

			dec health1 ; Decrease player 1's health by 1 (Penalized)
			rjmp end_check ; jump to end_check
		
		test_p2:
			dec health2 ; Decrease player 2's health by 1 (Penalized)
		
		end_check:
			rjmp end ; End current round
				
	setup_round:
		rcall INIT_LCD ; Clear and prepare LCD for round's start

		rcall init_hp ; Call init_hp

		rcall fill_border_field ; Call fill_border_field

		rcall place_player ; Call place_player
		rcall check_square ; Call check_square on the player's choice

		rjmp end ; End the round

init_hp: ; Function for printing both player's HP on the LCD

	ldi temp, 0 ; Set temp (counter) as 0

	ldi temp2, 0x81 ; Load 0x81 (LCD screen) to temp2
	rcall move ; call move
	
	rcall write_hp ; Call write_hp (for player1)

	inc temp ; Increment temp

	ldi temp2, 0x8E ; Load 0x8E (LCD screen) to temp2
	rcall move ; Call move

	rcall write_hp ; Call write_hp

	ret ; return
	
	write_hp: ; Function for printing (HP

		ldi temp2, 0b01001000 ; Load "H" to temp2
		rcall print ; Call print

		ldi temp2, 0b01010000 ; Load "P" to temp2
		rcall print ; Call print
	
		ldi temp2, 0b00100000 ; Load " " to temp2
		rcall print ; Call print

		ldi temp2, 0b01010000 ; Load "P" to temp2
		rcall print ; Call print

		tst temp ; Check if temp is 0
		brne write_player2 ; If not, jump to write_player_2

		write_player1:
			ldi temp2, 0b00110001 ; Load "1" to temp2
			rcall print ; Call print

			ldi temp2, 0xC3 ; Load 0xC3 (LCD screen) to temp2
			rcall move ; Call move
			
			ldi temp2, 0b00110000 ; Load "0" to temp2
			add temp2, health1 ; Add temp2 with P1's health
			rcall print ; Print P1's remaining health

			ret ; return

		write_player2:
			ldi temp2, 0b00110010 ; Load "2" into temp2
			rcall print ; Call print

			ldi temp2, 0xD0 ; Load 0xD0 (LCD screen) to temp2
			rcall move ; Call move

			ldi temp2, 0b00110000 ; Load "0" to temp2
			add temp2, health2 ; Add temp2 with P2's health
			rcall print ; Print P2's remaining health

			ret ; return

RESET_SRAM: ; Function for resetting SRAM's content after every round

	ldi XH, high(FIELD_DATA) ; Set X high to FIELD_DATA
	ldi XL, low(FIELD_DATA) ; Set X low to FIELD_DATA

	ldi temp, 16 ; Set temp (counter) as 16 (0x60 to 0x6F)
	ldi temp2, 0xFF ; Set temp2 (data) as 0xFF

	SRAM_loop:
		st X, temp2 ; Store 0xFF to X

		inc XL ; Increment X
		dec temp ; Decrement counter

		tst temp ; Check if counter is 0
		brne SRAM_loop ; If it's not 0, loop again
		
	clr temp ; Clear temp
	clr temp2 ; Clear temp2

	ret ; return

move: ; Function for moving cursor to location given in temp2

	cbi PORTA, 1 ; Clear RS
	mov PB, temp2 ; Change position to the address on temp2
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ret ; return

print: ; Function for printing character given in temp2

	sbi PORTA, 1 ; Set RS
	mov PB, temp2 ; Print character on temp2
	out PORTB,PB
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN

	ret ; return

get_player_loc: ; Function for getting the current player's location (LCD address wise)

	test_line0:
		cpi line, 0 ; Check if line is 0
		brne test_line1 ; If not, jump to test_line1
		ldi temp2, LINE1 ; Load LINE1 address to temp2

	test_line1:
		cpi line, 1 ; Check if line is 1
		brne test_line2 ; If not, jump to test_line2
		ldi temp2, LINE2 ; Load LINE2 address to temp2
	
	test_line2:
		cpi line, 2 ; Check if line is 2
		brne test_line3 ; If not, jump to test_line3
		ldi temp2, LINE3 ; Load LINE3 address to temp2

	test_line3:
		cpi line, 3 ; Check if line is 3
		brne add_col ; If not, jump to add_col
		ldi temp2, LINE4 ; Load LINE4 address to temp2
		
	add_col:
		add temp2, col ; Add column to temp2's address
	
	ret ; return

get_loc_data: ; Function for checking the content of the current square (SRAM)

	ldi XH, high(FIELD_DATA) ; Set X high to FIELD_DATA
	ldi XL, low(FIELD_DATA) ; Set X low to FIELD_DATA

	ldi temp, 0 ; Set temp (sum) as 0

	push line ; Push line's content to the stack

	loop_line:
		tst line ; Check if line is 0
		breq line_end ; If it is, jump to line_end

		subi temp, -4 ; Add 4 to temp
		dec line ; Decrement line
		rjmp loop_line ; Jump to loop_line

	line_end:
		pop line ; Pop stack to line

	add temp, col ; Add sum with column

	add XL, temp ; Add XL with sum
	
	ret ; return

place_player: ; Function for placing player initially

	ldi col, 3 ; Set col as 3
	
	place_loop:
		in temp2, PINA ; Move PINA's content into temp2
		cpi temp2, 0b00001111 ; Check if there's any button pressed in PINA
		brlo place_loop ; If not, loop back
	
	sbrc temp2, 4 ; If button pressed is bit 4
	ldi line, 0 ; Set line as 0
	
	sbrc temp2, 5 ; If button pressed is bit 5
	ldi line, 1 ; Set line as 1

	sbrc temp2, 6 ; If button pressed is bit 6
	ldi line, 2 ; Set line as 2

	sbrc temp2, 7 ; If button pressed is bit 7
	ldi line, 3 ; Set line as 3
	
	rcall move_player ; Call move_player

	ret ; return

player_movement: ; Function for getting player's movement input

	move_loop:
		in temp2, PINA ; Move PINA's content into temp2
		cpi temp2, 0b00001111 ; Check if there's any button pressed in PINA
		brlo move_loop ; If not, loop back
	
	sbrc temp2, 4 ; If button pressed is bit 4
	rjmp forward ; Jump to forward
	
	sbrc temp2, 5 ; If button pressed is bit 5
	rjmp backward ; Jump to backward

	sbrc temp2, 6 ; If button pressed is bit 6
	rjmp left ; Jump to left

	sbrc temp2, 7 ; If button pressed is bit 7
	rjmp right ; Jump to right

	forward:
		cpi col, 0 ; Check if column is 0 (Leftmost col)
		breq finish ; If it is, jump to finish
		
		rcall del_player ; Call del_player
		dec col ; Decrement col
		rcall move_player ; Call move_player

		rjmp check_square ; Jump to check_square

	backward:
		cpi col, 3 ; Check if column is 3 (Rightmost col)
		breq player_movement ; If it is, jump to player_movement (No effect)
		
		rcall del_player ; Call del_player
		inc col ; Increment col
		rcall move_player ; Call move_player

		rjmp check_square ; Jump to check_square
	
	left: ; Diagonal front-left
		cpi line, 3 ; Check if line is 3 (Bottom line)
		breq player_movement ; If it is, jump to player_movement (No effect)

		rcall del_player ; Call del_player
		dec col ; Decrement col
		inc line ; Increment line
		rcall move_player ; Call move_player

		rjmp check_square ; Jump to check_square
		
	right: ; Diagonal front-right
		cpi line, 0 ; Check if line is 0 (Top line)
		breq player_movement ; If it is, jump to player_movement (No effect)

		rcall del_player ; Call del_player
		dec col ; Decrement col
		dec line ; Increment line
		rcall move_player ; CAll move_player

		rjmp check_square ; Jump to check_square

	check_square: ; Function for checking data on current player's location

		rcall get_loc_data ; Call get_loc_data

		ld temp3, X ; Load current location data to temp3

		cpi temp3, 0x11 ; Check if temp3 is 0x11 (Marker for trap)
		breq trapped ; If it is, jump to trapped

		cpi temp3, 0x10 ; Check if temp3 is 0x10 (Marker for point)
		breq pointed ; If it is, jump to pointed

		rjmp player_movement ; If it's neither, jump back to player_movement
	
		trapped:
			rcall get_player_loc ; Call get_player_loc
			rcall move ; Move to player's location

			ldi temp2, 0b01011000 ; Load temp2 with "X"
			rcall print ; Call print

			rcall DELAY_01 ; Call DELAY_01

			trapped_confirmation:
				rcall INIT_LCD ; Call INIT_LCD (Clears LCD)

				ldi temp2, 0xC6 ; Load 0xC6 (LCD Screen) to temp2
				rcall move ; Call move

				ldi temp2, 0b01010100 ; Load "T" to temp2
				rcall print ; Call print

				ldi temp2, 0b01110010 ; Load "r" to temp2
				rcall print ; Call print

				ldi temp2, 0b01100001 ; Load "a" to temp2
				rcall print ; Call print

				ldi temp2, 0b01110000 ; Load "p" to temp2
				rcall print ; Call print
				rcall print ; Call print

				ldi temp2, 0b01100101 ; Load "e" to temp2
				rcall print ; Call print

				ldi temp2, 0b01100100 ; Load "d" to temp2
				rcall print ; Call print

				rcall print_continue ; Call print_continue
		
				trap_loop:
					sbis PINA, 4 ; Skip if bit 7 in PINA is 1 (Forward button is pressed)
					rjmp trap_loop ; Jump to trap_loop

			ret ; return

		pointed:
			inc point ; Increment point

			ldi temp2, 0xFF ; Load 0xFF (Empty square) to temp2
			st X, temp2 ; Overwrite address in X with 0xFF
		
			rjmp player_movement ; Jump to player_movement

	finish: ; Function for handling player reaching the exit

		tst current_player ; Check if current player is P1
		breq player2 ; If it is, jump to player2
	
		sub health1, point ; If it's P2, decrease P1's health

		ret ; return

		player2: 
			sub health2, point ; If it's P1, decrease P2's health

		round_confirmation:
			rcall INIT_LCD
			
			ldi temp2, 0xC4 ; Load 0xC4 (LCD screen) to temp2
			rcall move ; Call move

			ldi temp2, 0b01000111 ; Load "G" into temp2
			rcall print ; Call print

			ldi temp2, 0b01101111 ; Load "o" into temp2
			rcall print ; Call print

			ldi temp2, 0b01110100 ; Load "t" into temp2
			rcall print ; Call print

			ldi temp2, 0b00100000 ; Load " " into temp2
			rcall print ; Call print

			ldi temp2, 0b00110000 ; Load "0" into temp2
			add temp2, point ; Add point to temp2
			rcall print ; Call print

			ldi temp2, 0b00100000 ; Load " " into temp2
			rcall print ; Call print

			ldi temp2, 0b01110000 ; Load "p" into temp2
			rcall print ; Call print

			ldi temp2, 0b01101111 ; Load "o" into temp2
			rcall print ; Call print

			ldi temp2, 0b01101001 ; Load "i" into temp2
			rcall print ; Call print

			ldi temp2, 0b01101110 ; Load "n" into temp2
			rcall print ; Call print

			ldi temp2, 0b01110100 ; Load "t" to temp2
			rcall print ; Call print

			rcall print_continue ; Call print_continue

			finish_loop:
				sbis PINA, 4 ; Skip if bit 7 in PINA is 1 (Forward button is pressed)
				rjmp finish_loop ; Jump to finish_loop

		ret ; return

	del_player: ; Function for deleting the player marker

		rcall get_player_loc ; Call get_player_loc
		rcall move ; Call move

		ldi temp2, 0b00100000 ; Load " " to temp2
		rcall print ; Call print

		ret ; return

	move_player: ; Function for writing the player marker
		rcall get_player_loc ; Call get_player_loc
		rcall move ; Call move

		ldi temp2, 0b00111100 ; Load "<" into temp2
		rcall print ; Call print

		ret ; return

print_continue:
	ldi temp2, 0x99 ; Load 0x99 (LCD screen to temp2)
	rcall move ; Call move

	ldi temp2, 0b01000110 ; Load "F" to temp2
	rcall print ; Call print

	ldi temp2, 0b00100000 ; Load " " to temp2
	rcall print ; Call print

	ldi temp2, 0b01110100 ; Load "t" to temp2
	rcall print ; Call print
	
	ldi temp2, 0b01101111 ; Load "o" to temp2
	rcall print ; Call print

	ldi temp2, 0b00100000 ; Load " " to temp2
	rcall print ; Call print

	ldi temp2, 0b01100011 ; Load "c" to temp2
	rcall print ; Call print

	ldi temp2, 0b01101111 ; Load "o" to temp2
	rcall print ; Call print

	ldi temp2, 0b01101110 ; Load "n" to temp2
	rcall print ; Call print

	ldi temp2, 0b01110100 ; Load "t" to temp2
	rcall print ; Call print

	ret ; return

end:
	rcall RESET_SRAM ; Call RESET_SRAM (clear SRAM)

	tst health1 ; Test if health1 is 0 (P1 lose)
	breq print_win ; If yes, jump to print_win
	
	tst health2 ; Test if health2 is 0 (P2 lose)
	breq print_win ; If yes, jump to print_win

	tst current_player ; Test if current_player is 0 (P1)
	breq set_player2 ; If yes, jump to set_player2
	
	set_player1:
		clr current_player ; Clear current_player (1 to 0)
		rjmp reset_round ; Jump to reset_round

	set_player2:
		inc current_player ; Increment current_player (0 to 1)
	
	reset_round:
		clr point ; Clear round points
		rjmp init_field ; Jump to init_field

	print_win:
		rcall INIT_LCD ; Call INIT_LCD (Clears LCD)

		ldi temp2, 0xC7 ; Load 0xC7 (LCD screen) to temp2
		rcall move ; Call move

		ldi temp2, 0b01010000 ; Load "P" to temp2
		rcall print ; Call print

		test_hp1:
			tst health1 ; Test if P1 health is 0
			brne test_hp2 ; If not, jump to test_hp2
			
			ldi temp2, 0b00110010 ; Load "2" into temp2
			rjmp end_test_hp ; Jump to end_test_hp

		test_hp2:
			ldi temp2, 0b00110001 ; Load "1" into temp2

		end_test_hp:
			rcall print ; Call print

		ldi temp2, 0b00100000 ; Load " " into temp2
		rcall print ; Call print

		ldi temp2, 0b01010111 ; Load "w" into temp2
		rcall print ; Call print

		ldi temp2, 0b01101001 ; Load "i" into temp2
		rcall print ; Call print

		ldi temp2, 0b01101110 ; Load "n" into temp2
		rcall print ; Call print

		rjmp gameover ; Jump to gameover

gameover:
