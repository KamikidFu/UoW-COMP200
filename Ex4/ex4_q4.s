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
		#2400Hz*0.01s=24
	addi $2,$0,24
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
	divi $2,$2,100
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
		#Get the value of $estat agian and test irq3
	movsg $13,$estat
		#Check if there are other interrupts besides irq3
		#0b01110000=0x90,last 4 bits are undefinied in $estat
	andi $4,$13,0xFF70
		#If there is only irq3, then brench to the handler
	beqz $4,ParallelInterruptHandler

		#Get the value of $estat and test irq2
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
	bnez $13, printR
		#Else, it should reset the counter
	addi $13,$0,0
		#Store zero to counter
	sw $13,counter($0)
	rfe
	
printR:
		#Check Serial Port Status Register
	lw $13, 0x70003($0)
		#Check TDR status
	andi $13, $13, 0x02
		#Jump back to title
	beqz $13, printR
		#Get value ready
	addi $13,$0,'\r'
		#Print \r into TDR
	sw $13, 0x70000($0)
printN:
		#Check Serial Port Status Register
	lw $13, 0x70003($0)
		#Check TDR status
	andi $13, $13, 0x02
		#Jump back to title
	beqz $13, printN
		#Get value ready
	addi $13,$0,'\n'
		#Print \n into TDR
	sw $13, 0x70000($0)
printS1:
		#Check Serial Port Status Register
	lw $13, 0x70003($0)
		#Check TDR status
	andi $13, $13, 0x02
		#Jump back to title
	beqz $13, printS1
		#Get value from counter
	lw $13, counter($0)
		#Get the first digit
	divi $13, $13, 1000
		#Add 48, so it will shows as readable number
		#Because 0 is 48 in ASCII code
	addi $13, $13, 48
		#Store value into TDR
	sw $13, 0x70000($0)
printS2:
		#Check Serial Port Status Register
	lw $13, 0x70003($0)
		#Check TDR status
	andi $13, $13, 0x02
		#Jump back to title
	beqz $13, printS2
		#Get value from counter
	lw $13, counter($0)
		#Get the second digit
	divi $13, $13, 100
	remi $13, $13, 10
		#Add 48, so it will shows as readable number
	addi $13, $13, 48
		#Store value into TDR
	sw $13, 0x70000($0)
printDot:
		#Check Serial Port Status Register
	lw $13, 0x70003($0)
		#Check TDR status
	andi $13, $13, 0x02
		#Jump back to title
	beqz $13, printDot
		#Get value ready
	addi $13,$0,'.'
		#Print . into TDR
	sw $13, 0x70000($0)
printS3:
		#Check Serial Port Status Register
	lw $13, 0x70003($0)
		#Check TDR status
	andi $13, $13, 0x02
		#Jump back to title
	beqz $13, printS3
		#Get value from counter
	lw $13, counter($0)
		#Get the third digit
	divi $13, $13, 10
	remi $13, $13, 10
		#Add 48, so it will shows as readable number
	addi $13, $13, 48
		#Store value into TDR
	sw $13, 0x70000($0)
printS4:
		#Check Serial Port Status Register
	lw $13, 0x70003($0)
		#Check TDR status
	andi $13, $13, 0x02
		#Jump back to title
	beqz $13, printS4
		#Get value from counter
	lw $13, counter($0)
		#Get the forth digit
	remi $13, $13, 10
		#Add 48, so it will shows as readable number
	addi $13, $13, 48
		#Store value into TDR
	sw $13, 0x70000($0)
	rfe

.bss
		#Store the address of default exception handler and counter
	old_vector: .word
.data
	counter: .word 0
#1255469, Yunhao Fu, COMP200
