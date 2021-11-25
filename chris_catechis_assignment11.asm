# Author: Christopher Catechis <8000945777>
# Section: 1001
# Date Last Modified: 11/25/2021
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

#;labels
    squareSizeOutput: .asciiz "Magic Square Size (2-10): "
	sizeErrorOutput: .asciiz "Size must be between 2 and 10."
    magicNumberOutput: .asciiz "Magic Number: "
    numberErrorOutput: .asciiz "Magic number must be between the square size and 1000."

#;	Magic Square
	MINIMUM_SIZE = 2
	MAXIMUM_SIZE = 10
	MAXIMUM_TOTAL = 1000
	magicSquare: .space MAXIMUM_SIZE*MAXIMUM_SIZE*4 

#; Additional variables
	sizeInput: .space 4

.text
.globl main
.ent main
main:
	#; Ask user for size of magic square to generate
	li $v0, SYSTEM_PRINT_STRING  # prompt user
    la $a0, squareSizeOutput
    syscall

	li $v0, SYSTEM_READ_INTEGER  # input
	la $a0, sizeInput
	syscall
	#;	Check that the size is between 2 and 10
	sizeCheck:
		li $t0, 2
		li $t1, 10
		lw $t2, sizeInput

		blt $t2, $t0, sizeErrorPrompt
		bgt $t2, $t1, sizeErrorOutput

		j sumInput
	#;	Output an error and ask again if not within bounds
	sizeErrorPrompt:
		li $v0, SYSTEM_PRINT_STRING  # prompt user
		la $a0, squareSizeOutput
		syscall

		li $v0, SYSTEM_READ_INTEGER  # input
		la $a0, sizeInput
		syscall

		j sizeCheck  # recheck size of input
	
	sumInput:
		#; Ask user for column/row total
		
		#;	Check that the total is between the square size and 1000
		#;	Output an error and ask again if not within bounds
			
		#; Create a magic square
		
		#; Print the magic square

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
	#; Print a space between each value
	#; Print a newline after each row
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
	#; Multiply the previous random number by A
	#; Add C
	#; Get the remainder by M
	#; Set the previousRandomNumber to this new random value
	#; Use the new random value to generate a random number within the specified range
	#;	return randomNumber = newRandom%(maximum-minimum+1)+minimum
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
	#; Initialize Matrix values to 0
	#; loop:
	#; 	Choose a random row # using getRandomNumber
	#; 	Choose a random column # using getRandomNumber
	#; 	Check if the column and row totals are < desired total
	#; 	If both are < than the desired total:
	#; 		Add 1 to matrix[row][column]
	#; Repeat until all rows/columns have a total value equal to the desired value
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
	jr $ra
.end getRowTotal