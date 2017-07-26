.text
.global main

main:
	#Read switches and get both side data ready
	lw $1, 0x73000($0)	#Load the switches data
	andi $2,$1,0x0f		#Get the right 4-bit data
	andi $3,$1,0xf0		#Get the left 4-bit data
	srli $3,$3,0x04		#Shift 4 bits to get the actual data

	#Read different cases of button
	lw $4, 0x73001($0)	#Load button data, cases are ~11/~10/~01/~00
	andi $5,$4,0x03		#Get just two bits of button data, ~xx($4) & ~11(0x03) -> xx($5)

	#Two button, 11, case
	subi $5,$4,0x03		#Two buttons pressed case, i.e. 11($5) - 11(0x03) = 0($5)
	beqz $5, exit		#Jump to exit and exit the program
	#Left button, 10, case
	andi $5,$4,0x02		#Button 1 pressed, xx($4) & 10(0x02) -> x0($5)
	srli $5,$5,0x01		#Shift the 2-bit data to right and get 1-bit, x0($5) -> x($5)
	bnez $5, invert		#if this 1-bit is not 0, i.e. 1 left button is pushed, jump to invert
	#Right button, 01, case
	andi $5,$4,0x01		#Button 0 pressed, xx($4) & 01(0x01) -> 0x($5)
	bnez $5, display	#if x is not 0, i.e. 1 right button is pushed, jump to display
	#No button, 00, case
	j main			#Return to main

display:
	#Easily store data into both side of SSD
	sw $3, 0x73002($0)	#Store the data into Left SSD
	sw $2, 0x73003($0)	#Store the data into right SSD
	
	j main			#Return to main

invert:
	#Invert switch data and then jump to display
	xori $2,$2,0x0f		#Invert the right 4-bit data
	xori $3,$3,0x0f		#Invert the left 4-bit data
	j display		#Jump to display

exit:
	syscall
