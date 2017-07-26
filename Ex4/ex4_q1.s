.text
.global main
main:
		#Set up Exception Verctor Register
		#Store the old or current value in $evec
		#Using movsg to get the value
	movsg $2,$evec
		#Store the value into old_Vector
	sw $2,old_vector($0)
		#Load address of new handler address
	la $2, InterruptHandler
		#Store the new value into $evec
	movgs $evec, $2
		
		#Acknowledge User Interrupt Button
	sw $0, 0x7F000($0)
	
		#Set up cctrl
	movsg $2,$cctrl
		#Enable interrupt mode, kernal mode and irq1
	andi $2,$2,0x0F
	ori $2,$2,0x22
		#Move the value into $cctrl
	movgs $cctrl,$2

loop:
		#Load word from counter's address
	lw $2,counter($0)
		#Get the left bit by division of counter by 10
	divi $3,$2,0x0A
		#Get the right bit by remainder of counter by 10
	remi $4,$2,0x0A
		#Store the value respectively into left and right
	sw $3,0x73002($0)
	sw $4,0x73003($0)
		#Jump to loop and calculate agian
	j loop

InterruptHandler:
		#When interrupts generated, by the set of $evec
		#It will go here to handle the interrupt
		#Get the value of $estat into $3
	movsg $13,$estat
		#Check if there are other interrupts besides irq1
		#0b11010000=0xD0,last 4 bits are undefinied in $estat
	andi $4,$13,0xFFD0
		#If there is only irq1, then brench to the handler
	beqz $4,UserInterruptButtonHandler
		#Else load the value in old_vector, the orignal handler
	lw $13,old_vector($0)
		#Jump to that handler
	jr $13

UserInterruptButtonHandler:
		#When the program comes here, that is the time to add counter
		#This is what the handler does
		#Store zero to interrupt button, because we already know the button is pressed once
	sw $0,0x7F000($0)
		#Load value from counter
	lw $13,counter($0)
		#Add one to counter
	addi $13,$13,1
		#Store new value into counter
	sw $13,counter($0)
		#rfe to leave handler (Return from exception)
	rfe

.bss
		#Store the address of default exception handler and counter
	old_vector: .word
.data
	counter: .word 0
#1255469, Yunhao Fu, COMP200
