.text
.global main

main:
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
	j main			#Go back to main for next input character
