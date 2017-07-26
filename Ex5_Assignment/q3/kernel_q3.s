.bss
	old_vector: .word	#old_vector is a place to store system handler address

.text
.global main
main:
	#Set up $cctrl
	movsg $1, $cctrl	#Store the value from $cctrl to general register $1
	andi $1,$1,0x0F		#Save the last bits of KU, OKU, IE, OIE
	ori $1,$1,0x4D		#Using ori to open the timer interrupt, IRQ2, KU, OKU, IE
	movgs $cctrl, $1	#Restore value into $cctrl
	#Set up $evec
	movsg $1,$evec		#Store the value into old_Vector
	sw $1, old_vector($0)	#Load address of new handler address
	la $1, Interrupt_Handler#Store the new value into $evec
	movgs $evec, $1		#Restore the value into $evec
	#Set up Timer
	sw $0, 0x72003($0)	#Acknowledge timer to make there is no previous interrupts
	addi $1, $0, 24		#Set up the period time
	sw $1, 0x72001($0)	#Store the period into timer
	addi $1, $0, 0x03	#Set up auto-start and timer-enable value
	sw $1, 0x72000($0)	#Store the control value into timer
	#Jump and link to main
	jal serial_main

Interrupt_Handler:
	#When interrupts generated, by the set of $evec
	#It will go here to handle the interrupt

	movsg $13,$estat	#Get the value of $estat into $13
	andi $4,$13,0xFFB0	#Check if there are other interrupts besides IRQ2, 0b10110000=0xB0,last 4 bits are undefinied in $estat
	beqz $4, IRQ_2_Handler	#If there is only IRQ2, then brench to the handler
	lw $13, old_vector($0)	#Else load the value in old_vector, the orignal handler
	jr $13			#Jump to that handler

IRQ_2_Handler:
	sw $0, 0x72003($0)	#Acknowledge timer
	lw $13, counter($0)	#Retrive counter value into $13
	addi $13,$13,1		#Add one more into $13
	sw $13, counter($0)	#Restore $13 into counter
	rfe
