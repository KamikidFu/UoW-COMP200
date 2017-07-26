.text		#.text directive, where the instructions are
.global main	#.global main, entry point of program

main:
	jal readswitches	#Jump to subroutine, Returned value to $1
	add $2, $1, $0		#$2 is the register which writessd will use, $0 is always 0
	jal writessd		#Jump to subroutine, Write value to ssd
	j main			#Endlessly jump to the beginning

#Yunhao Fu, 1255469, COMP200
	
