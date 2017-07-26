.text
.global main

main:
	jal parallel_job
	jal serial_job
	j main

parallel_job:
	#Read switches and get both side data ready
	lw $1, 0x73000($0)	#Load the switches data
	andi $2,$1,0x0f		#Get the right 4-bit data
	andi $3,$1,0xf0		#Get the left 4-bit data
	srli $3,$3,0x04		#Shift 4 bits to get the actual data

	#Read different cases of button
	lw $4, 0x73001($0)	#Load button data, cases are ~11/~10/~01/~00
	andi $5,$4,0x03		#Get just two bits of button data, ~xx & ~11 -> xx
	subi $5,$4,0x03		#Two buttons pressed case, if ~11 - ~11 = 0
	beqz $5, exit		#Jump to exit and exit the program

	andi $5,$4,0x02		#Button 1 pressed, xx & 10 -> x0
	srli $5,$5,0x01		#Shift the 2-bit data to right and get 1-bit, x0 -> x
	bnez $5, invert		#if this 1-bit is not 0, jump to invert

	andi $5,$4,0x01		#Button 0 pressed, xx & 01 -> 0x
	bnez $5, display	#if x is not 0, jump to display
	
	jr $ra

	display:
		#Easily store data into both side of SSD
		sw $3, 0x73002($0)	#Store the data into Left SSD
		sw $2, 0x73003($0)	#Store the data into right SSD
		
		jr $ra

	invert:
		#Invert switch data and then jump to display
		xori $2,$2,0x0f		#Invert the right 4-bit data
		xori $3,$3,0x0f		#Invert the left 4-bit data
		j display

	exit:
		syscall

serial_job:
	lw $1, 0x70003($0)	#Read current status from Serial Status Register
	andi $1,$1,0x01		#Get the RDR value to check is Serial Port ready
	beqz $1, main		#0-false, not ready, go back to main to wait
	lw $2, 0x70001($0)	#When it is ready, load the date from Serial Receive Data Register
	addi $3,$0,'A'		#$3 is for checking character use, add the first value of 'A' to it
	addi $4,$0,'Z'		#$4 is for checking character use as well, using as a stop point
	addi $4,$4,0x01		#It should check uppercase Z, so add one more to register $4
read:
	seq $5,$3,$4		#If $3=$4, that is, $3 is growing and checked the character is Z or not
	bnez $5, star		#Then branch to star label to change the value as '*'
	seq $6,$2,$3		#$2 is what the value it get from SRDR, that is, the character to check
	bnez $6, send		#If they are the same, directly to send to send out the character
	addi $3,$3,0x01		#else, grow $3 to next character to check with $2
	j read			#go back to read for checking

star:
	addi $2,$0,'*'		#change the $2 value to '*'
	j send			#send for output

send:
	lw $1,0x70003($0)	#Read current status from serial status register
	andi $1,$1,0x02		#Get the TDR value to check is serial port ready
	beqz $1, send		#0-false, not ready, go back to send to wait
	sw $2,0x70000($0)	#when it is ready, store the value to address of STDR
	jr $ra			#Go back to main for next input character
