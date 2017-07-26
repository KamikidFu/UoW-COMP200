.bss
	old_vector: .word
	current_task: .word
	breakout_PCB: 
			.space 18
			.space 200
	breakout_stack:
	rocks_PCB: 
			.space 18
			.space 200
	rocks_stack:
	gameSelect_PCB: 
			.space 18
			.space 200
	gameSelect_stack:

.data
	time_slice: .word 100

.equ pcb_link, 0
.equ pcb_reg1, 1
.equ pcb_reg2, 2
.equ pcb_reg3, 3
.equ pcb_reg4, 4
.equ pcb_reg5, 5
.equ pcb_reg6, 6
.equ pcb_reg7, 7
.equ pcb_reg8, 8
.equ pcb_reg9, 9
.equ pcb_reg10, 10
.equ pcb_reg11, 11
.equ pcb_reg12, 12
.equ pcb_reg13, 13
.equ pcb_sp, 14
.equ pcb_ra, 15
.equ pcb_ear, 16
.equ pcb_cctrl, 17

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

	#Set up Multitasking, PCB 1, serial task
	la $1, breakout_PCB	#Load the base address for serial PCB, task 1
	la $2, rocks_PCB	#Load task 2 PCB
	sw $2, pcb_link($1)	#Store address to pcb_link
	la $2, breakout_stack	#Load stack
	sw $2, pcb_sp($1)	#Store to pcb_sp
	la $2, breakout_main	#Load serial main program address
	sw $2, pcb_ear($1)	#Store to pcb_ear
	movsg $2, $cctrl	#Load cctrl settings
	sw $2, pcb_cctrl($1)	#Store to pcb_cctrl
	sw $1, current_task($0)	#Store the address to current task pointer

	#Set up Multitasking, PCB 2, parallel task
	la $1, rocks_PCB	#Load the base address for parallel PCB, task 2
	la $2, gameSelect_PCB	#Load task 1 PCB
	sw $2, pcb_link($1)	#Store address to pcb_link
	la $2, rocks_stack	#Load stack
	sw $2, pcb_sp($1)	#Store to pcb_sp
	la $2, rocks_main	#Load serial main program address
	sw $2, pcb_ear($1)	#Store to pcb_ear
	movsg $2, $cctrl	#Load cctrl settings
	sw $2, pcb_cctrl($1)	#Store to pcb_cctrl

	#Set up Multitasking, PCB 3, parallel task
	la $1, gameSelect_PCB	#Load the base address for parallel PCB, task 2
	la $2, breakout_PCB	#Load task 1 PCB
	sw $2, pcb_link($1)	#Store address to pcb_link
	la $2, gameSelect_stack	#Load stack
	sw $2, pcb_sp($1)	#Store to pcb_sp
	la $2, gameSelect_main	#Load serial main program address
	sw $2, pcb_ear($1)	#Store to pcb_ear
	movsg $2, $cctrl	#Load cctrl settings
	sw $2, pcb_cctrl($1)	#Store to pcb_cctrl

	j Load_Context		#Jump to load context of registers from PCB
	
Interrupt_Handler:
	#When interrupts generated, by the set of $evec
	#It will go here to handle the interrupt

	movsg $13,$estat	#Get the value of $estat into $13
	andi $4,$13,0xFFB0	#Check if there are other interrupts besides IRQ2, 					#0b10110000=0xB0,last 4 bits are undefinied in $estat
	beqz $4,IRQ_2_Handler	#If there is only IRQ2, then brench to the handler
	lw $13,old_vector($0)	#Else load the value in old_vector, the orignal handler
	jr $13			#Jump to that handler

IRQ_2_Handler:
	sw $0, 0x72003($0)	#Acknowledge timer
	lw $13, time_slice($0)
	subi $13, $13, 1
	sw $13, time_slice($0)
	beqz $13, dispatcher
	rfe

dispatcher:
Save_Context:
	lw $13, current_task($0)

	sw $1, pcb_reg1($13)
	sw $2, pcb_reg2($13)
	sw $3, pcb_reg3($13)
	sw $4, pcb_reg4($13)
	sw $5, pcb_reg5($13)
	sw $6, pcb_reg6($13)
	sw $7, pcb_reg7($13)
	sw $8, pcb_reg8($13)
	sw $9, pcb_reg9($13)
	sw $10, pcb_reg10($13)
	sw $11, pcb_reg11($13)
	sw $12, pcb_reg12($13)
	sw $sp, pcb_sp($13)
	sw $ra, pcb_ra($13)

	movsg $1, $ers
	sw $1, pcb_reg13($13)
	
	movsg $1, $ear
	sw $1, pcb_ear($13)

	movsg $1, $cctrl
	sw $1, pcb_cctrl($13)

Schedule:
	lw $13, current_task($0)
	lw $13, pcb_link($13)
	sw $13, current_task($0)

Renew_time_slice:
	addi $13, $0, 100
	sw $13, time_slice($0)

Load_Context:
	lw $13, current_task($0)

	lw $1, pcb_reg13($13)
	movgs $ers, $1

	lw $1, pcb_ear($13)
	movgs $ear, $1

	lw $1, pcb_cctrl($13)
	movgs $cctrl, $1

	lw $1, pcb_reg1($13)
	lw $2, pcb_reg2($13)
	lw $3, pcb_reg3($13)
	lw $4, pcb_reg4($13)
	lw $5, pcb_reg5($13)
	lw $6, pcb_reg6($13)
	lw $7, pcb_reg7($13)
	lw $8, pcb_reg8($13)
	lw $9, pcb_reg9($13)
	lw $10, pcb_reg10($13)
	lw $11, pcb_reg11($13)
	lw $12, pcb_reg12($13)
	lw $sp, pcb_sp($13)
	lw $ra, pcb_ra($13)

	rfe
