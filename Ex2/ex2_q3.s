.text
.global main

main:
	subui $sp,$sp,5		#Make 5 spaces for $2(Leftside),$3(Rightside), $ra, subroutine-count
				#No.0 and 1 space is used by subroutine, count because of stackframe.
	sw $ra, 2($sp)		#Save the $ra into No.2 in the stack
	sw $2, 3($sp)		#Save the previous $2 into No.3 in the stack
	sw $3, 4($sp)		#Save the previous $3 into No.4 in the stack
	
	add $2,$0,$0		#Initialise $2,$3 register
	add $3,$0,$0
	
	jal readswitches	#Call subroutine to get the switches value, $1 for storing value

	andi $2,$1,0xf0		#Get the most-left value using andi, 0xf0=11110000
	srli $2,$2,4		#Shift to right by 4 to get the 4 bits value leftside
	andi $3,$1,0x0f		#Get the most-right value using andi, 0x0f=00001111

	sw $2, 1($sp)		#Save the $2, leftside value into stack
	sw $3, 0($sp)		#Save the $3, rightside value into stack

	jal count		#Jump to subroutine count
	
	lw $ra,2($sp)		#Load back $ra return address
	lw $2,3($sp)		#Load back previous $2 value
	lw $3,4($sp)		#Load back previous $3 value
	addui $sp,$sp,5		#Delete the 5 spaces in stack
	
	jr $ra			#Jump back where call this subroutine

#Stack view
#+-----------+
#|0($2 count)|
#+-----------+
#|1($3 Count)|
#+-----------+
#|   2($ra)  |
#+-----------+
#| 3(Pre $2) |
#+-----------+
#| 4(Pre $3) |
#+-----------+
#Yunhao Fu, 1255469, COMP200
