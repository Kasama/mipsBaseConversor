################# Alunos ####################
##                                                                                            ##
##   Frederico de Azevedo Marques - Nusp 8936926    ##
## 	Roberto Pommella Alegro        - Nusp 8936756    ##
##                                                                                           ##
###########################################

.data
.align 2

	typeIdentifierInputMessage1: .asciiz "Usage: <BaseInput><Input><EnterKey>\nD - Decimal\nB - Binary\nO - Octal\nH - Hexa\nType a number to convert: "
	typeIdentifierInputMessage2: .asciiz "\nType a base to output number:\n"
	insultMessage: .asciiz "\nInput Error!! Please refer to the manual...\nTry again\n"
	char: .space 2
	savedNumber: .word 0
	binaryNumber: .space 65
	hexaNumber: .space 17
	octalNumber: .space 33

.text

main:
	#asking for input number
	li $v0, 4							# service 4, print string
	la $a0, typeIdentifierInputMessage1	# message to be printed
	syscall								# syscall

	
	#reading number
	li $v0, 8							# service 8, read string
	la $a0, char						# where to store read string
	li $a1, 2							# maximum size to be read
	syscall								# syscall
	
	lb $t0, char						# load typed char
	li $t1, 'O'							# load ascii character O
	beq $t1, $t0, readOctalNumber		# read number as Octal 
	li $t1, 'B'							# load ascii character B
	beq $t1, $t0, readBinaryNumber		# read number as Binary
	li $t1, 'D'							# load ascii character D
	beq $t1, $t0, readDecimalNumber		# read number as Decimal
	li $t1, 'H'							# load asciicharacter H
	beq $t1, $t0, readHexadecimalNumber	# read number as Hexadecimal
	j readError							# input error
	readNumberExit:						# return point for read number routine
	
	#asking for output base
	li $v0, 4							# service 4, print string
	la $a0, typeIdentifierInputMessage2	# message to be printed
	syscall								# syscall
	
	#printing converted number
	li $v0, 8							# service 8, read string
	la $a0, char						# where to store read string
	li $a1, 2							# maximum size to be read
	syscall								# syscall
	
	lb $t0, char						# load typed char
	li $t1, 'O'							# load ascii O character
	beq $t1, $t0, printOctalNumber		# print number as Octal
	li $t1, 'B'							# load ascii B character
	beq $t1, $t0, printBinaryNumber		# print number as Binary
	li $t1, 'D'							# load ascii D character
	beq $t1, $t0, printDecimalNumber	# print number as Decimal
	li $t1, 'H'							# load asciiH character
	beq $t1, $t0, printHexadecimalNumber# print number as Hexal	
	j readError							# input error
	printNumberExit:					# return point for print number routine
		
	li $v0, 10							# service 10, halt
	syscall								# syscall
#end main

readError:
	li, $v0, 4 				# service 4, print string
	la, $a0, insultMessage  # prepare syscall argument
	syscall
	j main 					# return main

### Read routines
readOctalNumber:
	li, $v0, 8 				# service 8, read string
	la $a0, octalNumber 	# read string to octalNumber
	li, $a1, 33 		 	# max size of 32+1(\0)
	syscall 				# syscall
	li $t0, 7 				# mask 00000000000000000000000000000111
	la $t1, octalNumber 	# first address of octalNumber string
	li $t5, 0 				# final number to be saved
	li $t9, '7' 			# char 7
	li $t8, '0' 			# char 0
	li $t7, '\n' 			# char \n
	readOctalNumber_loop: 						# read all numbers
		lb $t2, ($t1) 							# load the character (corresponds to 7 to 0)
		beq $t2, $t7, readOctalNumber_loopExit  # if \n is reached, gtfo
		sub $t2, $t2, $t8 						# subtract ascii character '0' 
		bltz $t2, readError 					# if the value is less than 0, the number typed is invalid
		bgt $t2, $t0, readError 				# if the value is higher than 7, the number typed is invalid
		sll $t5, $t5, 3 						# shifts the final number by three
		or $t5, $t2, $t5 						# sets the three least significant bits of it to what was read
		addi $t1, $t1, 1 						# increments the string pointer
		j readOctalNumber_loop	 				# read next number
	readOctalNumber_loopExit: 					# exit loop
	sw $t5, savedNumber 	# save to RAM
	j readNumberExit 		# return to caller

readDecimalNumber:
	li, $v0, 5 				# service 5, read integer number
	syscall 				# call service
	move $t0, $v0 			# move to temporary register to save to RAM
	sw $t0, savedNumber 	# save to RAM
	j readNumberExit 		# return to caller
readBinaryNumber:
	li, $v0, 8 				# service 8, read string
	la $a0, binaryNumber 	# read string to binaryNumber
	li, $a1, 65 		 	# max size of 64+1(\0)
	syscall 				# syscall
	li $t0, 1 				# mask 00000000000000000000000000000001
	la $t1, binaryNumber 	# first address of binaryNumber string
	li $t5, 0 				# final number to be saved
	li $t9, '1' 			# char 1
	li $t8, '0' 			# char 0
	li $t7, '\n' 			# char \n
	readBinaryNumber_loop: 						# read all numbers
		lb $t2, ($t1) 							# load the character (corresponds to 1 or 0)
		beq $t2, $t7, readBinaryNumber_loopExit # if \n is reached, gtfo
		sub $t2, $t2, $t8 						# subtract ascii character '0' 
		bltz $t2, readError 					# if the value is less than 0, the number typed is invalid
		bgt $t2, $t0, readError 				# if the value is higher than 1, the number typed is invalid
		sll $t5, $t5, 1 						# shifts the final number by one
		or $t5, $t2, $t5 						# sets the least significant bit of it to what was read
		addi $t1, $t1, 1 						# increments the string pointer
		j readBinaryNumber_loop 				# read next number
	readBinaryNumber_loopExit: 					# exit loop
	sw $t5, savedNumber 	# save to RAM
	j readNumberExit 		# return to caller
	
readHexadecimalNumber:
	li, $v0, 8 				# service 8, read string
	la $a0, hexaNumber 		# read string to hexaNumber
	li, $a1, 65 		 	# max size of 64+1(\0)
	syscall 				# syscall
	li $t0, 15				# mask 00000000000000000000000000001111
	la $t1, hexaNumber 		# first address of hexaNumber string
	li $t4, 0 				# final number to be saved
	li $t9, '9' 			# char 9
	li $t8, '0' 			# char 0
	li $t7, '\n' 			# char \n
	li $t5, 'f'				# char f
	li $t6, 'a'				# char a
	readHexadecimalNumber_loop: 						# read all numbers
		lb $t2, ($t1) 									# load the character (corresponds to 7 to 0)
		beq $t2, $t7, readHexadecimalNumber_loopExit 	# if \n is reached, gtfo
		bge $t2, $t6, readHexadecimalNumber_AtoF		# check if we need to subtract 'a' or '0'
		bge $t2, $t8, readHexadecimalNumber_0to9
		readHexadecimalNumber_AtoF:
			sub $t2, $t2, $t6 							# subtract ascii character 'a'
			addi $t2, $t2, 10 							# add 10 (0xA) to the number
			j readHexadecimalNumber_XtoX_return 		# skip next instruction
		readHexadecimalNumber_0to9:
			sub $t2, $t2, $t8 							# subtract ascii character '0'
		readHexadecimalNumber_XtoX_return: 
		bltz $t2, readError 							# if the value is less than 0, the number typed is invalid
		bgt $t2, $t0, readError 						# if the value is higher than 15, the number typed is invalid
		sll $t4, $t4, 4 								# shifts the final number by four
		or $t4, $t2, $t4		 						# sets the three least significant bits of it to what was read
		addi $t1, $t1, 1 								# increments the string pointer
		j readHexadecimalNumber_loop	 				# read next number
	readHexadecimalNumber_loopExit: 					# exit loop
	sw $t4, savedNumber 	# save to RAM
	j readNumberExit 		# return to caller

### Printing routines 
printOctalNumber:
	li $t0, 7 			# mask 00000000000000000000000000000111
	li $t1, 11			# load the number of times a Octal number fits a 32 bits Binary number (loop counter)
	lw $t2, savedNumber # load Octal number
	printOctalNumber_loopPush:
		and $t3, $t2, $t0	# extract an Octal digit
		srl $t2, $t2, 3		# logial shift 3 bits (Octal number) to right
		sub $sp, $sp, 4		# push Octal digit
		sw $t3, ($sp)		
		sub $t1, $t1, 1		# decrement loop counter
		bnez $t1, printOctalNumber_loopPush	
	li $t1, 11			# load the number of times a Octal number fits a 32 bits Binary number (loop counter)		
	printOctalNumber_loopPop:
		lw $t3, ($sp)		# push Octal digit
		add $sp, $sp, 4
		move $a0, $t3		# prepare syscall argument
		li $v0, 36			# service 36, print unsigned integer
		syscall
		sub $t1, $t1, 1		# decrement loop counter
		bnez $t1, printOctalNumber_loopPop
	j printNumberExit	# return to caller
	
printBinaryNumber:
	li $v0, 35			# service 35, print number as Binary
	lw $a0, savedNumber # prepare syscall argument
	syscall
	j printNumberExit   # return to caller
printDecimalNumber:
	li $v0, 36			# service 36, print number as Decimal
	lw $a0, savedNumber # prepare syscall argument
	syscall
	j printNumberExit	# return to caller
printHexadecimalNumber:
	li $v0, 34			# service 34, print number as Hexadecimal
	lw $a0, savedNumber # prepare syscall argument
	syscall
	j printNumberExit	# return to caller

### Exception handling
.ktext 0x80000180
	li, $v0, 4 				# service 4, print string
	la, $a0, insultMessage  # prepare syscall argument
	syscall
	la $ra, main 	# return back to main
	jr $ra
