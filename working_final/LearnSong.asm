# $1 contains a 7 bit value that indicates which notes are pressed
# hardcode that registers to contain the states of the keys.
# $2 contains the learnsong signal
# $3 contains a constant to compare the signal to, to know if it is time to start learning a song

# $8 contains the current note to play
# $9 contains the address to read from dmem

addi $3, $3, 1 #initialize register 3 to 1

start:
bne $2, $3, start # if $2 (learn song mode) is not equal to $3 (1), wait

addi $9, $0, 1 # register 9 contains address to read from for load instructions. Initialize to 1
addi $10, $0, 56 # number of notes to read from dmen is set here. 

#load in the first note from the song from dmem. $8 contains the next note to play
lw $8, 0($9)

check :
# is the correct key pressed, compare values in $1 (input) and $8 (expected).
bne $8 , $1 , check 			# if the correct key is not pressed, keep waiting until it is.
addi $9, $9, 1 					# increment dmem address to read from by 1
lw $8, 0($9) 					# load next note from the song into $8
blt $9, $10, check				# if the address in $9 is less than $10, wait for next note to be played.

add $8, $0, $0								# Otherwise end of song is reached.
bne $2, $3, start
