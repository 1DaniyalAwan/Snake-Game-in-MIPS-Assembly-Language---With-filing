.data # define the color
lightRd: .word 0x00FF4444 # 0x0RGB
lightGrey: .word 0x00a5a5a5
lightBlue : .word 0x00327aef
black : .word 0x00000000
startMessage : .asciiz "Game Start !!!! Good Luck!!!!\n"
progress1 : .asciiz "You eat a fruit!! Your current score is "
progress2 : .asciiz ". Keep Going!! \n"
deadMessage : .asciiz "You died!!!! GAME OVER    \n"


updatedhigh : .asciiz "Updated High Scores    \n"

fin:    .asciiz "highscores.txt"      # filename for input
buffer: .space 100                # buffer to hold the input
highscore1: .word 0               # variable to hold first high score
highscore2: .word 0               # variable to hold second high score
highscore3: .word 0               # variable to hold third high score
highscore4: .word 0               # variable to hold fourth high score
highscore5: .word 0               # variable to hold fifth high score
newline_msg: .asciiz "\nPrevious High scores:\n"
gapline: .asciiz "\n"

top1: .word 0  # Variables to store top 5 scores
top2: .word 0
top3: .word 0
top4: .word 0
top5: .word 0

current_score: .word 0 # variable to store current score

scores: .space 24  # Array to store all 6 scores (6 * 4 bytes)

fout:   .asciiz "highscores.txt"      # filename for output
newline: .asciiz "\n"             # newline character

buffer1: .space 12
buffer2: .space 12
buffer3: .space 12
buffer4: .space 12
buffer5: .space 12

.text

#Print the start message
li $v0, 4
la $a0 startMessage
syscall

  # Open the file
  li   $v0, 13           # system call for open file
  la   $a0, fin          # input file name
  li   $a1, 0            # Open for reading
  li   $a2, 0            # mode is ignored
  syscall                # open the file
  move $s6, $v0          # save the file descriptor 

  # Read the file
  li   $v0, 14           # system call for read from file
  move $a0, $s6          # file descriptor
  la   $a1, buffer       # address of buffer to store input
  li   $a2, 100          # maximum number of characters to read
  syscall                # read from file

  # Close the file
  li   $v0, 16           # system call for close file
  move $a0, $s6          # file descriptor to close
  syscall                # close the file

  # Initialize variables
  la   $t0, buffer       # load address of buffer
  li   $t1, 0            # high score counter
  li   $t2, 5            # total high scores to read

  parse_scores:
  # Skip non-numeric characters
skip_non_numeric:
  lb   $t5, 0($t0)       # load byte from buffer
  beq  $t5, 0, finish    # null terminator, end of buffer
  blt  $t5, 48, next_char  # skip if character < '0'
  bgt  $t5, 57, next_char  # skip if character > '9'

  # Parse the numeric value
  li   $t4, 0            # clear accumulator
parse_digit:
  lb   $t5, 0($t0)       # load byte
  blt  $t5, 48, store_highscore # end of number if not a digit
  bgt  $t5, 57, store_highscore # end of number if not a digit
  sub  $t5, $t5, 48       # convert ASCII to integer
  mul  $t4, $t4, 10       # shift left by one place
  add  $t4, $t4, $t5      # add the digit
  addi $t0, $t0, 1        # move to next byte
  j parse_digit           # continue parsing

store_highscore:
  # Store the parsed number
  move $t6, $t4          # move parsed number to $t6
  beq  $t1, 0, store1
  beq  $t1, 1, store2
  beq  $t1, 2, store3
  beq  $t1, 3, store4
  beq  $t1, 4, store5
  j next_char

store1:
  sw   $t6, highscore1
  j increment_counter
store2:
  sw   $t6, highscore2
  j increment_counter
store3:
  sw   $t6, highscore3
  j increment_counter
store4:
  sw   $t6, highscore4
  j increment_counter
store5:
  sw   $t6, highscore5
  j finish

increment_counter:
  addi $t1, $t1, 1       # increment high score counter
  j next_char

next_char:
  addi $t0, $t0, 1       # move to the next byte in buffer
  j skip_non_numeric      # continue parsing

finish:
 
  
  

lw $t1, lightRd($0) # put the color value into $t1
lw $t2, lightGrey($0) #put border color into $t2
lw $s7, lightBlue($0) #put snake head color into $s7


addi $t0, $gp, 0 # $gp -> $t0 cause I will change value

lw $t5 1000($gp)

li $t5 0	#assign $t5 as a counter for border drawing (can be freed later)
li $t6 32	#assign $t6 as a constraint of border drawing (can be freed later)
li $t4, 1	#assign $t4 as a function code for border drawing (can be freed later

jal paintBorder	#paint the border

#t4, t5, t6 are freed
#The initial length of the snake is 4 units and I only need to track the head and tail in fact
addi $t4 $gp 2108 #assigan a head location to the snake
sw $t4 4460($gp) #give a memory location to store the start of snake array
addi $t4 $gp 4460	#save the location of the snake array to 
li $t5 3	#use $t5 to store the length - 1 of the snake


#initialize snake 

#use $t6 as a temporary register to store the location value (can be freed later)
addi $t0, $gp, 0 #reset t0 to gp
sw $t7, 2108($t0)

sw $t1, 2104($t0)
addi $t6 $t0 2104
sw $t6, 4($t4)

sw $t1, 2100($t0)
addi $t6 $t0 2100
sw $t6, 8($t4)

sw $t1, 2096($t0)
addi $t6 $t0 2096
sw $t6, 12($t4)

#now entering the game plaing loop
li $s2 100
jal generateFruit

#set $s5 as the score
li $s5 0


gameLoop:
lw $t6 0($t4)	#get the location of the head
add $t6 $t6 $s0
beq $t6 $t3 extendSnake #check if the location of the head collide with fruit

#sleep 
li $a0 500
li $v0 32
syscall

jal getInput

move $t8, $v0 # move the key press data into $a0 for printing
#move the snake forward ( for now set it to move +4 (D)


beq $t8, 119 moveUp # pressed w
beq $t8, 115 moveDown # pressed s
beq $t8, 97 moveLeft #pressed a
beq $t8, 100 moveRight #pressed d

beq $s2, 119 moveUp # pressed w
beq $s2, 115 moveDown # pressed s
beq $s2, 97 moveLeft #pressed a
beq $s2, 100 moveRight #pressed d

j gameLoop



j exit

#paint the borders
paintBorder:
beq $t4, 1 paintHorizontalBorder   #if function code $t4 equal to 1, then go paint the upper horizontal border
li $t5, 0	#reset the counter to 0
li $t6 30	#add a constraint to $t6 with 30	
beq $t4, 2 paintVerticalBorder	#if function code $t4 equal to 2, then go paint the vertical borders
li $t5, 0	#reset the counter to 0
li $t6 32	#reload the constraint to 32
beq $t4, 3 paintBottomHorizontalBorder	#if function code $4 equal to 3, then go paint the horizontal border
jr $ra		#return to previous line


#paint the upper horizonal border
paintHorizontalBorder:
li $t4 2
beq $t5, $t6 paintBorder
addi $t5 $t5 1
sw $t2, 0($t0)
addi $t0, $t0, 4
j paintHorizontalBorder  

#paint the lower horizontal border
paintBottomHorizontalBorder:
li $t4 4
beq $t5, $t6 paintBorder
addi $t5 $t5 1
sw $t2, 0($t0)
addi $t0, $t0, 4
j paintBottomHorizontalBorder 

#paint the vertical border
paintVerticalBorder:
li $t4 3
beq $t5, $t6 paintBorder
addi $t5, $t5, 1
sw $t2, 0($t0)
addi $t0, $t0, 124
sw $t2, 0($t0)
addi $t0, $t0, 4
j paintVerticalBorder

#this function is to generate a fruit
generateFruit:
fruitloop:
li $a1 991
li $v0 42
syscall
mul $a0 $a0 4
add $a0 $a0 $gp
lw $a1, 0($a0)
beq $a1, $t1 ,  fruitloop
beq $a1, $t2, fruitloop
move $t3 $a0
sw $t1, 0($t3)
jr $ra

#this will extend the snake when it eat a fruit and it will generate a new fruit
extendSnake:

#print out game update message
li $v0, 4
la $a0 progress1
syscall
addi $s5 $s5 1	#update the score by 1
move $a0, $s5
sw $s5, current_score
li $v0, 1
syscall
li $v0, 4
la $a0 progress2
syscall


lw $a0 0($t4) #store the old location of the head
addi $t4 $t4 -4	#move the location of the head forward
sw $t3 0($t4) #save the location of the new head to the new head memory address
sw $s7 0($t3)
sw $t1 0($a0)
addi $t5 $t5 1
jal generateFruit
j gameLoop

#movement, use $t8 as adder to change the direction

moveRight:
li $s0 4
j updatePreviousDirection

moveLeft:
li $s0 -4
j updatePreviousDirection

moveUp:
li $s0 -128
j updatePreviousDirection

moveDown:
li $s0 128
j updatePreviousDirection


updatePreviousDirection:
beq $t8 32 updateSnake
beqz $t8 updateSnake
move $s2 $t8
j updateSnake


updateSnake:
lw $t6 0($t4)	#get the head location
add $a0 $t6 $s0 	#calculate the new head location
lw $a1 0($a0)	#read the color at location
beq $a0 $t3 gameLoop
beq $a1 $t1 exit
beq $a1 $t2 exit
sw $s7 0($a0)
sw $t1 0($t6)
mul $t6 $t5 4 #store a counter of rewritting the snake array to $t6
add $t7 $t6 $t4
lw $t7 0($t7)
sw $0 0($t7)
j reWriteSnakeArray



reWriteSnakeArray:
beqz $t6 finishReWriteSnake	#check if the counter is less than, if less than zero, then finished rewriting the snake
addi $t7 $t6 -4		#get the adder to get the second to tail
add $t7 $t7 $t4	#get the location of the second to tail in memory
lw $t7 0($t7) 	#get the location of the second to tail
add $s1 $t6 $t4 	#get the location of tail in memory
sw $t7  0($s1) 	#save the second to tail 
addi $t6 $t6 -4
j reWriteSnakeArray

finishReWriteSnake:
sw $a0 0($t4) #update the loaction of the head in snake array
j gameLoop


 
getInput:
	li $s4, 0xffff0000
	lw $t9, 0($s4)
	bnez $t9, read_val
	li $v0, 0 # If $s2 has zero, there is no value to read, ret 0	
	jr $ra
	read_val:
		# Read value cause there is something there!
		lw $v0, 4($s4)
	jr $ra

exit: 
#print game over message
li $v0, 4
la $a0 deadMessage
syscall

 # Print the high scores for debugging
  li   $v0, 4            # Debug: Print message
  la   $a0, newline_msg
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, highscore1   # load first high score
  syscall                # print high score
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, highscore2   # load second high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, highscore3   # load third high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, highscore4   # load fourth high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, highscore5   # load fifth high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall



 # Load high scores and current score
    la $t0, highscore1         # Load address of highscore1
    lw $t1, 0($t0)             # Load highscore1 into $t1
    la $t0, highscore2         # Load address of highscore2
    lw $t2, 0($t0)             # Load highscore2 into $t2
    la $t0, highscore3         # Load address of highscore3
    lw $t3, 0($t0)             # Load highscore3 into $t3
    la $t0, highscore4         # Load address of highscore4
    lw $t4, 0($t0)             # Load highscore4 into $t4
    la $t0, highscore5         # Load address of highscore5
    lw $t5, 0($t0)             # Load highscore5 into $t5
    la $t0, current_score      # Load address of current_score
    lw $t6, 0($t0)             # Load current score into $t6

    # First, copy the scores into registers to work with them
    move $t7, $t1              # Copy highscore1 to $t7
    move $t8, $t2              # Copy highscore2 to $t8
    move $t9, $t3              # Copy highscore3 to $t9
    move $s0, $t4              # Copy highscore4 to $s0
    move $s1, $t5              # Copy highscore5 to $s1

    # Insert the current score in the right position if it's large enough
    # Step 1: Check if current score should be placed in the top 5 scores.

    # Check if current score is larger than the smallest score (s1)
    blt $t6, $s1, skip_5th
    move $t0, $s1              # Move 5th place into temporary register
    move $s1, $t6              # Replace 5th place with current score
skip_5th:

    # Check if current score is larger than the 4th largest score (s0)
    blt $t6, $s0, skip_4th
    move $t1, $s0              # Move 4th place into temporary register
    move $s0, $t6              # Move score place into 4th place
    move $s1, $t1              # Replace 4th place with 5th
skip_4th:

    # Check if current score is larger than the 3rd largest score (t9)
    blt $t6, $t9, skip_3rd
    move $t2, $t9              # Move 3rd place into temporary register
    move $t9, $t6              # Move score place into 3rd place
    move $s0, $t2              # Move 3rd place into 4th place
skip_3rd:

    # Check if current score is larger than the 2nd largest score (t8)
    blt $t6, $t8, skip_2nd
    move $t3, $t8              # Move 2nd place into temporary register
    move $t8, $t6              # Move score place into 2nd place
    move $t9, $t3              # Move 2nd place into 3rd place
skip_2nd:

    # Check if current score is larger than the 1st largest score (t7)
    blt $t6, $t7, skip_1st
    move $t4, $t7              # Move 1st place into temporary register
    move $t7, $t6              # Move score place into 1st place
    move $t8, $t4              # Move 1st place into 2nd place
skip_1st:

    # Store the final sorted top 5 scores into new variables
    la $t0, top1
    sw $t7, 0($t0)             # Store highest score in new_highscore1
    la $t0, top2
    sw $t8, 0($t0)             # Store second highest score in new_highscore2
    la $t0, top3
    sw $t9, 0($t0)             # Store third highest score in new_highscore3
    la $t0, top4
    sw $s0, 0($t0)             # Store fourth highest score in new_highscore4
    la $t0, top5
    sw $s1, 0($t0)             # Store fifth highest score in new_highscore5


  # Print Updated High Scores
  li   $v0, 4            # Debug: Print message
  la   $a0, updatedhigh
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, top1   # load new first high score
  syscall                # print high score
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, top2   # load new second high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, top3   # load new third high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, top4   # load new fourth high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall

  li   $v0, 1            # system call for print integer
  lw   $a0, top5   # load new fifth high score
  syscall
  
  li   $v0, 4            # gap line
  la   $a0, gapline
  syscall
  
  #Output code 
  
  lw $t0, top1         # Load the value of inte into $t0

    # Convert integer in $t0 to string in score1
    li $t1, 10           # Load the base (10) into $t1
    li $t2, 0            # Initialize index for score1
    la $t3, buffer1       # Load address of score1 into $t3
    
    convert_loop1:
    # Get the last digit
    div $t0, $t1         # Divide $t0 by 10
    mfhi $t4             # Get the remainder (last digit)
    addi $t4, $t4, '0'   # Convert digit to ASCII
    sb $t4, 0($t3)       # Store the ASCII character in score1
    addi $t3, $t3, 1     # Move to the next character
    mflo $t0             # Get the quotient
    bnez $t0, convert_loop1 # Repeat until $t0 is 0

    # Null-terminate the string
    sb $zero, 0($t3)     # Store null terminator
    
    
    lw $t0, top2         # Load the value of inte into $t0

    # Convert integer in $t0 to string in score1
    li $t1, 10           # Load the base (10) into $t1
    li $t2, 0            # Initialize index for score1
    la $t3, buffer2       # Load address of score1 into $t3
    
    convert_loop2:
    # Get the last digit
    div $t0, $t1         # Divide $t0 by 10
    mfhi $t4             # Get the remainder (last digit)
    addi $t4, $t4, '0'   # Convert digit to ASCII
    sb $t4, 0($t3)       # Store the ASCII character in score1
    addi $t3, $t3, 1     # Move to the next character
    mflo $t0             # Get the quotient
    bnez $t0, convert_loop2 # Repeat until $t0 is 0

    # Null-terminate the string
    sb $zero, 0($t3)     # Store null terminator
    
    
    lw $t0, top3         # Load the value of inte into $t0

    # Convert integer in $t0 to string in score1
    li $t1, 10           # Load the base (10) into $t1
    li $t2, 0            # Initialize index for score1
    la $t3, buffer3       # Load address of score1 into $t3
    
    convert_loop3:
    # Get the last digit
    div $t0, $t1         # Divide $t0 by 10
    mfhi $t4             # Get the remainder (last digit)
    addi $t4, $t4, '0'   # Convert digit to ASCII
    sb $t4, 0($t3)       # Store the ASCII character in score1
    addi $t3, $t3, 1     # Move to the next character
    mflo $t0             # Get the quotient
    bnez $t0, convert_loop3 # Repeat until $t0 is 0

    # Null-terminate the string
    sb $zero, 0($t3)     # Store null terminator
    
    
    lw $t0, top4         # Load the value of inte into $t0

    # Convert integer in $t0 to string in score1
    li $t1, 10           # Load the base (10) into $t1
    li $t2, 0            # Initialize index for score1
    la $t3, buffer4       # Load address of score1 into $t3
    
    convert_loop4:
    # Get the last digit
    div $t0, $t1         # Divide $t0 by 10
    mfhi $t4             # Get the remainder (last digit)
    addi $t4, $t4, '0'   # Convert digit to ASCII
    sb $t4, 0($t3)       # Store the ASCII character in score1
    addi $t3, $t3, 1     # Move to the next character
    mflo $t0             # Get the quotient
    bnez $t0, convert_loop4 # Repeat until $t0 is 0

    # Null-terminate the string
    sb $zero, 0($t3)     # Store null terminator
    
    
    lw $t0, top5         # Load the value of inte into $t0

    # Convert integer in $t0 to string in score1
    li $t1, 10           # Load the base (10) into $t1
    li $t2, 0            # Initialize index for score1
    la $t3, buffer5       # Load address of score1 into $t3

    convert_loop5:
    # Get the last digit
    div $t0, $t1         # Divide $t0 by 10
    mfhi $t4             # Get the remainder (last digit)
    addi $t4, $t4, '0'   # Convert digit to ASCII
    sb $t4, 0($t3)       # Store the ASCII character in score1
    addi $t3, $t3, 1     # Move to the next character
    mflo $t0             # Get the quotient
    bnez $t0, convert_loop5 # Repeat until $t0 is 0

    # Null-terminate the string
    sb $zero, 0($t3)     # Store null terminator


  ###############################################################
  # Open (for writing) a file
  li   $v0, 13       # system call for open file
  la   $a0, fout     # output file name
  li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 

  ###############################################################
  # Write each score to the file
  la   $a1, buffer1   # address of the first score
  jal  write_line    # write first score with newline

  la   $a1, buffer2   # address of the second score
  jal  write_line    # write second score with newline

  la   $a1, buffer3   # address of the third score
  jal  write_line    # write third score with newline

  la   $a1, buffer4   # address of the fourth score
  jal  write_line    # write fourth score with newline

  la   $a1, buffer5   # address of the fifth score
  jal  write_line    # write fifth score with newline

  ###############################################################
  # Close the file
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file

li $v0 10
syscall

###############################################################
# Subroutine to write a line (string + newline) to the file
# Input: $a1 = address of the string
# Uses: $s6 (file descriptor), $t0, $t1, $v0
###############################################################
write_line:
  # Write the string
  li   $v0, 15       # system call for write to file
  move $a0, $s6      # file descriptor 
  move $t0, $a1      # address of the string
  li   $t1, 0        # initialize length to 0

  # Calculate string length
string_length:
  lb   $t2, 0($t0)   # load byte from string
  beq  $t2, $zero, end_length # if null terminator, stop
  addi $t0, $t0, 1   # move to next character
  addi $t1, $t1, 1   # increment length
  j    string_length # repeat

end_length:
  move $a1, $a1      # start of string
  move $a2, $t1      # length of the string
  syscall            # write the string

  # Write the newline
  li   $v0, 15       # system call for write to file
  move $a0, $s6      # file descriptor
  la   $a1, newline  # address of newline character
  li   $a2, 1        # length of newline
  syscall            # write the newline

  jr   $ra           # return to caller
