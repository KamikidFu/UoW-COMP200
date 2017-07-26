.text
.global main
main:
		#Set up Exception Verctor Register
		#Store the old or so-called current value in $evec
		#Using movsg to get the value
	movsg $2,$evec
		#Store the value into old_Vector
	sw $2,old_vector($0)
		#Load address of new handler address
	la $2, InterruptHandler
		#Store the new value into $evec
	movgs $evec, $2

		#Set up cctrl
	movsg $2,$cctrl
		#Enable interrupt mode, kernal mode and irq2
	andi $2,$2,0x0F
	ori $2,$2,0x42
		#Move the value into $cctrl
	movgs $cctrl,$2

		#Set up timer
		#Acknowledge any outstanding interrupts
		#and ensure the overrun bit is reset to zero
		#Store 0 into Timer Interrupt Acknowledge Register
	sw $0,0x72003($0)
		#Set up the timer
		#2400Hz*1s=2400
	addi $2,$0,2400
		#Store the value into Timer Load Register
	sw $2,0x72001($0)
		#Enable automatic restart and timer
		#0x03=0b00000011
	addi $2,$0,0x03
		#Store the value into Timer Control Register
	sw $2,0x72000($0)

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
		#Get the value of $estat test irq2
	movsg $13,$estat
		#Check if there are other interrupts besides irq2
		#0b10110000=0xB0,last 4 bits are undefinied in $estat
	andi $4,$13,0xFFB0
		#If there is only irq2, then brench to the handler
	beqz $4,TimerInterruptHandler
		#Else load the value in old_vector, the orignal handler
	lw $13,old_vector($0)
		#Jump to that handler
	jr $13

TimerInterruptHandler:
		#Acknowledge the interrupt and overrun detected
	sw $0,0x72003($0)
		#Load value from counter
	lw $13,counter($0)
		#Add one more to counter
	addi $13,$13,1
		#Store new value to counter
	sw $13,counter($0)
	rfe

.bss
		#Store the address of default exception handler and counter
	old_vector: .word
.data
	counter: .word 0
#1255469, Yunhao Fu, COMP200
