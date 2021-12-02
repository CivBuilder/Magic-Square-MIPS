# Author: Christopher Catechis <8000945777>
# Section: 1001
# Date Last Modified: 12/1/2021
# Program Description: This program creates a magic square using
# multi-dimensional arrays. 

.data
#;	System service constants
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	SYSTEM_PRINT_CHARACTER = 11
	SYSTEM_EXIT = 10
	SYSTEM_READ_INTEGER = 5

#;	Random Number Generator Values
	M = 0x00010001
	A = 75
	C = 74
	previousRandomNumber: .word  1

#;  Labels
    squareSizePrompt: .asciiz "Magic Square Size (2-10): "
	sizeErrorOutput: .asciiz "Size must be between 2 and 10.\n"
    sumPrompt: .asciiz "Magic Number: "
    numberErrorOutput: .asciiz "Magic number must be between the square size and 1000.\n"

#;	Magic Square
	MINIMUM_SIZE = 2
	MAXIMUM_SIZE = 10
	MAXIMUM_TOTAL = 1000
	magicSquare: .word MAXIMUM_SIZE*MAXIMUM_SIZE*4  # whenever I left this as a .space the program would crash. 

.text
.globl main
.ent main
main:
	#; Ask user for size of magic square to generate
	li $v0, SYSTEM_PRINT_STRING  # prompt user
    la $a0, squareSizePrompt
    syscall

	li $v0, SYSTEM_READ_INTEGER  # input
	syscall

	#;	Check that the size is between 2 and 10
	sizeCheck:
		li $t0, MINIMUM_SIZE
		li $t1, MAXIMUM_SIZE

		blt $v0, $t0, sizeErrorPrompt  # if size of square < minimum size
		bgt $v0, $t1, sizeErrorPrompt  # if size of square > maximum size

		move $s0, $v0  # else, save square size input

		j sumInput
	#;	Output an error and ask again if not within bounds
	sizeErrorPrompt:
		li $v0, SYSTEM_PRINT_STRING  # output error
		la $a0, sizeErrorOutput
		syscall

		li $v0, SYSTEM_PRINT_STRING  # re-prompt user
		la $a0, squareSizePrompt
		syscall

		li $v0, SYSTEM_READ_INTEGER  # input
		syscall

		j sizeCheck  # recheck size of input
	
	sumInput:
		#; Ask user for column/row total
		li $v0, SYSTEM_PRINT_STRING  # prompt user
		la $a0, sumPrompt
		syscall

		li $v0, SYSTEM_READ_INTEGER  # input
		syscall
		
		#;	Check that the total is between the square size and 1000
		sumCheck:
			move $t0, $s0  # $t0 = size of square
			li $t1, MAXIMUM_TOTAL  # $t1 = 1000

			blt $v0, $t0, sumErrorPrompt  # if sum < square size
			bgt $v0, $t1, sumErrorPrompt  # if sum > 1000

			move $s1, $v0  # else, $s1 = sum

			j magicSquarePhase

		#;	Output an error and ask again if not within bounds
		sumErrorPrompt:
				li $v0, SYSTEM_PRINT_STRING  # output error
				la $a0, numberErrorOutput
				syscall

				li $v0, SYSTEM_PRINT_STRING  # re-prompt user
				la $a0, sumPrompt
				syscall

				li $v0, SYSTEM_READ_INTEGER  # input
				syscall

				j sumCheck  # recheck size of input

	magicSquarePhase:	
		#; Create a magic square
		la $a0, magicSquare  # $a0 = matrix&
		move $t1, $s0  # $t1 = size of one side of square
		mulou $t2, $t1, $t1  # calculate size of matrix
		move $a1, $t2  # $a1 = size of matrix
		move $a2, $s1  # $a2 = sum total
		jal createMagicSquare

		#; Print the magic square
		la $a0, magicSquare  # $a0 = matrix&
		move $a1, $s0  # $a1 = size of one side of square
		move $a2, $s0  # $a2 = size of one side of square
		jal printMatrix

	endProgram:
	li $v0, SYSTEM_EXIT
	syscall
.end main

#; Prints a 2D matrix to the console
#; Arguments:
#;	$a0 - &matrix
#;	$a1 - rows
#;	$a2 - columns
.globl printMatrix
.ent printMatrix
printMatrix:

	move $t0, $a0  # move array into $t0
	mul $a1, $a1, $a2  # i = columns * rows
	move $t3, $a2  # $t3 = size of column
    li $t1, 1  # index
	
    printLoop:
        li $v0, SYSTEM_PRINT_INTEGER
        lw $a0, ($t0)
        syscall
        #; Print a space between each value
        li $v0, SYSTEM_PRINT_CHARACTER
        li $a0, ' '
        syscall
        #; Print a newline after each row
        remu $t2, $t1, $t3  # $t2 = index % columnSize
        bnez $t2, skipNewLine
            li $v0, SYSTEM_PRINT_CHARACTER
            li $a0, '\n'
            syscall

        skipNewLine:
        
        addu $t1, $t1, 1 # index for newline Counter
        addu $t0, $t0, 4  # next character
        subu $a1, $a1, 1  # --i
    bnez $a1, printLoop  # if i!=0, loop
	
	jr $ra
.end printMatrix

#; Gets a random non-negative number between a specified range
#; Uses a linear congruential generator
#;	m = 2^16+1
#;	a = 75
#;	c = 74
#;	newRandom = (previous*a+c)%m
#; Arguments:
#;	$a0 - Minimum Value
#;	$a1 - Maximum Value
#; Global Variables/Constants Used
#;	previousRandom - Used to generate the next value, must be updated each time
#;	m, a, c
#; Returns a random signed integer number
.globl getRandomNumber
.ent getRandomNumber
getRandomNumber:
	lw $t0, previousRandomNumber  # random number
	subu $a1, $a1, 1
	move $t1, $a0  # minimum value
	move $t3, $a1  # maximum value
	#; Multiply the previous random number by A
	mulou $t0, $t0, A
	#; Add C
	addu $t0, $t0, C
	#; Get the remainder by M
	remu $t0, $t0, M
	#; Set the previousRandomNumber to this new random value
	sw $t0, previousRandomNumber
	#; Use the new random value to generate a random number within the specified range
	subu $t3, $t3, $t1  # (maximumValue-minimumValue+1) + minimumValue
	addu $t3, $t3, 1
	remu $t0, $t0, $t3
	addu $t0, $t0, $a0
	#;	return randomNumber = newRandom%(maximum-minimum+1)+minimum
	move $v0, $t0
	jr $ra
.end getRandomNumber

#; Creates a magic square 2D matrix
#;
#; Example 3x3 Magic Square with 11 as totals:
#;	4 1 6	4+1+6 = 11
#;  5 3 3	5+3+3 = 11
#;  2 7 2	2+7+2 = 11
#;	
#;	4+5+2 = 11
#;	1+3+7 = 11
#;	6+3+2 = 11
#;	
#; Arguments:
#;	$a0 - &matrix
#;	$a1 - size of matrix
#;	$a2 - row/column desired total
.globl createMagicSquare
.ent createMagicSquare
createMagicSquare:
	# prologue, initialize stack
	subu $sp, $sp, 24
	sw $s0, ($sp)  # $s0 = size of square
	sw $s1, 4($sp)	# $s1 = row/column total (magic number)
	sw $s2, 8($sp)	# $s2 = random row
	sw $s3, 12($sp)	# $s3 = random column
	sw $s4, 16($sp)	# $s4 = amount of times incremented
	sw $ra, 20($sp)

    #; Initialize Matrix values to 0
	move $t0, $a1  # one-dimensional size of matrix
	move $t9, $a1 
	move $t2, $a0  # move array into temporary register
    InitializeMatrix:
		beqz $t0, getRandomRow  # if i = 0, end loop
        sw $zero, ($t2)  # $a0[j] = 0
        addu $t2, $t2, 4  # iterate through array
        subu $t0, $t0, 1  # --i`	
		#; loop:
		j InitializeMatrix
		
	li $s4, 0  # index of amount of times 1 is added to matrix
	magicSquareCreation:
		#; 	Choose a random row # using getRandomNumber
		getRandomRow:
			li $a0, 0
			move $a1, $s0
			jal getRandomNumber
			move $s2, $v0

		#; 	Choose a random column # using getRandomNumber
		getRandomColumn:
			li $a0, 0
			move $a1, $s0
			jal getRandomNumber
			move $s3, $v0
			
		#; 	Check if the column and row totals are < desired total
		la $a0, magicSquare
		move $a1, $s0
		move $a2, $s0
		move $a3, $s3
		jal getColumnTotal
		# result in $v0

		la $a0, magicSquare
		move $a1, $s0
		move $a2, $s0
		move $a3, $s2
		jal getRowTotal
		# result in $v1

		#; 	If both are < than the desired total:
		mulou $t0, $s1, $t9
		beq $s4, $t0, loopComplete  # if additionsMade == matrixSize, done.
		beq $v0, $s1, magicSquareCreation  # if columnTotal == magicNumber, try again
		beq $v1, $s1, magicSquareCreation  # if rowTotal == magicNumber, try again
		#;  Add 1 to matrix[row][column]
		# row major calculation
		la $t1, magicSquare  # load address of magic square
		mulou $t0, $s2, $s0  # rowIdx * numOfCols
		addu $t0, $t0, $s3  # resultOfAbove + colIdx
		mulou $t0, $t0, 4  # resultOfAbove * 4
		addu $t0, $t0, $t1  # baseAddress + resultOfAbove
		lw $t2, ($t0)  # load address of matrix[row][column]
		addu $t2, $t2, 1
		sw $t2, ($t0)  # store it back
		addu $s4, $s4, 1  # ++additionsMade
		#; Repeat until all rows/columns have a total value equal to the desired value
		mulou $t0, $s0, $s1  # squareSize * magicNumber
		beq $s4, $t0, loopComplete  # if additionsMade == matrixSize, done.
		j magicSquareCreation  # else- loop again, scallywag.

	loopComplete:
		# epilogue, restore stack
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addu $sp, $sp, 24

		jr $ra
.end createMagicSquare

#; Gets the total of the specified column
#; Arguments
#;	$a0 - &matrix
#;	$a1 - rows
#;	$a2 - columns
#;	$a3 - column # to total
#; Returns the total of the column values in the matrix
.globl getColumnTotal
.ent getColumnTotal
getColumnTotal:
	# do row major calculation
	mulou $t0, $a3, 4  # colIdx * data size
	addu $t0, $t0, $a0  # $t0 + matrix

	li $t1, 0  # index = 0
	li $t3, 0  # sum = 0

	mulou $t4, $a2, 4  # rowSize * dataSize for incrementing
	
	# sum the column
	sumColumnLoop:
		lw $t2, ($t0)
		addu $t3, $t3, $t2 # sum += row[i]

		addu $t0, $t0, $t4  # ++i
		addu $t1, $t1, 1  # ++index

		bne $t1, $a1 sumColumnLoop

	move $v0, $t3
	jr $ra
.end getColumnTotal

#; Gets the total of the specified row
#; Arguments
#;	$a0 - &matrix
#;	$a1 - rows
#;	$a2 - columns
#;	$a3 - row # to total
#; Returns the total of the row values in the matrix
.globl getRowTotal
.ent getRowTotal
getRowTotal:
	# do row major calculation
	mulou $t0, $a3, $a2  # rowIdx * numOfCols
	mulou $t0, $t0, 4  # $t0 * data size
	addu $t0, $t0, $a0  # $t0 + matrix

	li $t1, 0  # index = 0
	li $t3, 0  # sum = 0

	# sum the row
	sumRowLoop:
		lw $t2, ($t0)
		addu $t3, $t3, $t2 # sum += row[i]

		addu $t0, $t0, 4  # ++i
		addu $t1, $t1, 1  # ++index

		bne $t1, $a2 sumRowLoop

	move $v1, $t3
	jr $ra
.end getRowTotal