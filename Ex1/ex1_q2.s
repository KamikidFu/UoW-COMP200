.text				#.text directive, where the instructions are
.global main			#.global main, entry point of program

main:
	addi $1, $0, 0		#Initialise $1 for subroutine readswitches
	addi $2, $0, 0		#Initialise $2 for subroutine writessd
	addi $3, $0, 0		#Initialise loop counter
	jal readswitches	#Call subroutine to get the value
loop:
	seqi $8, $3, 8		#Totally 8 switches, to set up the loop
	bnez $8, print		#If it reads 8 times, print the value
	jal status		#Call label status to check the switches status
	addi $3, $3, 1		#Increase the loop counter
	j loop			#Jump to the beginning of loop for check next switch status

status:
	andi $4, $1, 1		#Check the last digit of one switches is 1 using Bwise AND
	srli $1, $1, 1		#Shift the number to right by 1
	bnez $4, outputgrow	#Update the number of output if $4 is not zero
	jr $ra			#Jump to where call it, using $ra 

outputgrow:
	addi $2, $2, 1		#Add 1 to $2 for print
	jr $ra			#Jump to where call it, using $ra 

print:
	jal writessd		#Call subroutine to print the result
	j main			#Jump to main, the beginning of program

#Yunhao Fu, 1255469, COMP200
