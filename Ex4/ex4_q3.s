.text
.global main
main:		
		#Set up cctrl
	movsg $2,$cctrl
		#Enable interrupt mode, kernal mode, irq2 (Timer) and irq3 (Parallel)
	andi $2,$2,0x0F
	ori $2,$2,0xC2
		#Move the value into $cctrl
	movgs $cctrl,$2

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
		
		#Acknowledge Parallel Interrupts
	sw $0,0x73005($0)
		#Enable Parallel interrupts
	addi $2,$0,0x03
		#Store to Parallel Control Register
	sw $2,0x73004($0)
		
		#Set up timer
		#Acknowledge any outstanding interrupts
		#and ensure the overrun bit is reset to zero
		#Store 0 into Timer Interrupt Acknowledge Register to acknowledge
	sw $0,0x72003($0)
		#Set up the timer
		#2400Hz*1s=2400
	addi $2,$0,2400
		#Store the value into Timer Load Register
	sw $2,0x72001($0)
		#Enable automatic restart but timer is not running at beginning
		#0x02=0b00000010
	addi $2,$0,0x02
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
		#Get the value of $estat and test irq2
	movsg $13,$estat
		#Check if there are other interrupts besides irq2
		#0b10110000=0xB0,last 4 bits are undefinied in $estat
	andi $13,$13,0xFFB0
		#If there is only irq2, then brench to the handler
	beqz $13,TimerInterruptHandler	

		#Get the value of $estat agian and test irq3
	movsg $13,$estat
		#Check if there are other interrupts besides irq3
		#0b01110000=0x90,last 4 bits are undefinied in $estat
	andi $13,$13,0xFF70
		#If there is only irq3, then brench to the handler
	beqz $13,ParallelInterruptHandler
	

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

ParallelInterruptHandler:
		#Acknowledge
	sw $0,0x73005($0)

		#Get current push button value from push button register
	lw $13,0x73001($0)
		#Push button 0
	andi $13,$13,0x01	
		#If pressed, jump to resume
	bnez $13,button0Resume

	lw $13,0x73001($0)
		#Push button 1
	andi $13,$13,0x02
		#If pressed, jump to reset
	bnez $13,button1Reset

	rfe

button0Resume:
		#Load current timer control status
	lw $13,0x72000($0)
		#Change the last bit to 1 using xor
	xori $13,$13,0x01
		#Store to timer agian
	sw $13,0x72000($0)
	rfe
	
button1Reset:
		#Get value from timer, to check if the timer is running
	lw $13,0x72000($0)
		#Get last bit, to check enable or not
	andi $13,$13,0x01
		#If $13 is not zero, it means timer is running
	bnez $13, generalEndHandler
		#Else, it should reset the counter
	addi $13,$0,0
		#Store zero to counter
	sw $13,counter($0)
	rfe
	
generalEndHandler:
	rfe

.bss
		#Store the address of default exception handler and counter
	old_vector: .word
.data
	counter: .word 0
#1255469, Yunhao Fu, COMP200
