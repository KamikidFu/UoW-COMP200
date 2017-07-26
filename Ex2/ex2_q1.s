.text				
.global decryptAndPrint		

decryptAndPrint:
	subui $sp,$sp,4		#Make 4 spaces for putc-subroutine, $ra, $1(character) and $2(key)
	sw $ra,1($sp)		#Save the previous next address of previous call
	sw $1,2($sp)		#Save the previous value of $1
	sw $2,3($sp)		#Save the previous value of $2
	
	add $1,$0,$0		#Initialise registers for this current subroutine
	add $2,$0,$0

#Where is the input-character and key from? Just the next two spaces in stack. - Answered by tutor
	lw $1,4($sp)		#Load special value to $1 and $2 for decyption
	lw $2,5($sp)

	xor $1,$1,$2		#Decyption process using xor

#How can we pass parameter to putc subroutine?Like putc(c)? Put the parameter at the top of stack. putc will use the value to do work based on stackframe. - Answered by tutor
	sw $1,0($sp)		#Get value ready for putc
	jal putc		#Call subroutine, putc

	lw $ra,1($sp)		#Load back $ra, $1, $2 previous value
	lw $1,2($sp)
	lw $2,3($sp)
	addui $sp,$sp,4		#Delete 4 spaces in stack

	jr $ra			#Jump back to previous subroutine

#Stack view
#+-----------+
#|0($sp)putc |
#+-----------+
#|  1($ra)   |
#+-----------+
#| 2($1,Char)|
#+-----------+
#| 3($2,Key) |
#+-----------+
#| 4(Decypt) |
#+-----------+
#| 5(Decypt) |
#+-----------+
#Yunhao Fu, 1255469, COMP200
