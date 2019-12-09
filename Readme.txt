+---------------------------------------------------------------------------------------+
   Kabaddi - AVR ASM
+---------------------------------------------------------------------------------------+

Final Project of Group 14 - Dostedt?
Nadhif Adyatma Prayoga
Taufik Algi Fahri
Rocky Arkan Adnan

POK - A

Thanks to
Ervan A. Hayadi - Lab Assistant
Erdefi Rakun - Lecturer

=====================================
About
=====================================
Kabaddi is a 2 player game that involves one of them guessing where the other might
have placed their points while avoiding traps that are also placed by them. The game
is played on a 4x4 field and a limited set of movement. Both players starts at 3 HP
each and each time they guessed a point, their opponent loses an HP. The game ends
when one of the player has 0 HP.

=====================================
How to play
=====================================
1. Make sure you've installed AVR studio before
2. Double click on avr-kabaddi.aps
3. On AVR studio, click build and run
4. Open up hapsim
5. Load the XML in hapsim
6. Click run and play the game

=====================================
Controls
=====================================
The controls are entirely done on the Hapsim screen

To place traps and points (Defending Player), use the 4x4 keypad on the right side
of the LCD. Each button on the keypad corresponds with a square on the field,
represented on the LCD. (Ex: row 4 col 4 is 16)

To choose an initial square and control player movements, use the 4 buttons below the
LCD :

For initial placement of player :
- To place the player on the first row, press "Forward"
- To place the player on the second row, press "Backward"
- To place the player on the third row, press "Diag-Left"
- To place the player on the fourth row, press "Diag-Right"

The player is always placed on the rightmost column

For movements :
- To go forward 1 square or to finish the round, press "Forward"
- To go backward 1 square, press "Backward"
- To go diagonal-left forward 1 column, press "Diag-Left"
- To go diagonal-right forward 1 column, press "Diag-Right"

The player cannot move to a square outside the field, other than to finish the round

To reset the game, use the button called "Reset" below the LCD

=====================================
Gameflow
=====================================
1. Both players decide who should be player 1 and who should be player 2

2. Player 2 then will place 3 traps, represented as X and a n amount of points 
according to their HP (Both players starts at 3 HP) using the keypad

The rule of placing traps and points is as follow :
a. You cannot place traps and or points on top of another
b. You cannot place traps on the same column as one another
c. You cannot place points on the same column as one another

If you happened to break any of these rule, the game continues
but you will be penalized after you placed all the traps and points, losing 1 hp. 
After each penalty, the round ends and the players swap roles. This stays true 
for all forms of penalty.

3. If no penalty occurs, player 1 then will choose any one of the square
on the rightmost column using the buttons. After choosing, a representation
would appear as "<"

4. Player 1 choose where to move next using the buttons. A 30 second
clock would count down after each movement/placement. If there is no movement
by the time the clock counts to 30. A penalty would occur.

5. After each movement/placement to a square, a check would be made :
a. If there's a point on said square, add it to the point pool (invisible)
b. If there's a trap on said square, show it and the round ends
c. If there's nothing, nothing happens

6. If Player 1 presses forward on the leftmost column, the round will end

7. When the round ends, a few things can happen :
a. If the round ends because the player presses forward, the opponent's HP 
(in this case, player 2) will be deducted by the amount of points in the point pool
b. If the round ends because the player steps on a trap, nothing happens

8. After a round end, if any of the player HP is 0 (after previous check) the game
ends and the victor will be the player that still has HP.

9. If both players have more than 0 HP, the game continues, repeat step 2 but
both players swaps roles. Now player 1 should place traps and points and player 2
should control the player. So on and so forth.

To know whose turn it is, refer to the LED below the keypad. The light turns shines red
on the player who's turn it is.