.bss
	enable_flag: .word	#enable_flag is a place to store value which determine the task is enable or not
	old_vector: .word	#old_vector is a place to store system handler address
	current_task: .word	#current_task is to store the current running task PCB address
	breakout_PCB:   	#breakout_PCB is a space to store task's registers
			.space 18
			.space 200
	breakout_stack:		#breakout_stack is a space to store task's stack
	rocks_PCB:    		#rocks_PCB is a space to store task's registers
			.space 18
			.space 200
	rocks_stack:		#rocks_stack is a space to store task's stack
	gameSelect_PCB:     	#gameSelect_PCB is a space to store task's registers
			.space 18
			.space 200
	gameSelect_stack:	#gameSelect_stack is a space to store task's stack

.data
	time_slice: .word 100	#time_slice is a value of each task runtime duration

#These are definitions of both general and special registers in PCB
.equ pcb_link, 0		#pcb_link is a space to store next task's PCB address
.equ pcb_reg1, 1		#pcb_reg1 to pcb_ra are all general registers
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
.equ pcb_ear, 16		#pcb_ear is to store $ear, the exception address register
.equ pcb_cctrl, 17		#pcb_cctrl is to store $cctrl, the CPU control register
.equ pcb_timeSlice, 18		#pcb_timeSlice is to store more specific time slice for different task
.equ pcb_enable, 19		#pcb_enable is an enabled flag, skip unenabed task

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

	#Set up Multitasking, PCB 1, breakout game
	la $1, breakout_PCB	#Load the base address for breakout PCB, task 1
	la $2, rocks_PCB	#Load task 2 PCB
	sw $2, pcb_link($1)	#Store address to pcb_link
	la $2, breakout_stack	#Load stack
	sw $2, pcb_sp($1)	#Store to pcb_sp
	la $2, breakout_main	#Load breakout main program address
	sw $2, pcb_ear($1)	#Store to pcb_ear
	movsg $2, $cctrl	#Load cctrl settings
	sw $2, pcb_cctrl($1)	#Store to pcb_cctrl
	addi $2, $0, 1		#Set up the time slice
	sw $2, pcb_timeSlice($1)#Store time slice into pcb
	sw $2, pcb_enable($1)	#Set enable current task in PCB

	#Set up Multitasking, PCB 2, rocks task
	la $1, rocks_PCB	#Load the base address for rocks PCB, task 2
	la $2, gameSelect_PCB	#Load task 1 PCB
	sw $2, pcb_link($1)	#Store address to pcb_link
	la $2, rocks_stack	#Load stack
	sw $2, pcb_sp($1)	#Store to pcb_sp
	la $2, rocks_main	#Load rocks main program address
	sw $2, pcb_ear($1)	#Store to pcb_ear
	movsg $2, $cctrl	#Load cctrl settings
	sw $2, pcb_cctrl($1)	#Store to pcb_cctrl
	addi $2, $0, 1		#Set up the time slice
	sw $2, pcb_timeSlice($1)#Store time slice into pcb
	sw $2, pcb_enable($1)	#Set enable current task in PCB
	

	#Set up Multitasking, PCB 3, gameSelect task
	la $1, gameSelect_PCB	#Load the base address for gameSelect PCB, task 2
	la $2, breakout_PCB	#Load task 1 PCB
	sw $2, pcb_link($1)	#Store address to pcb_link
	la $2, gameSelect_stack	#Load stack
	sw $2, pcb_sp($1)	#Store to pcb_sp
	la $2, gameSelect_main	#Load gameSelect main program address
	sw $2, pcb_ear($1)	#Store to pcb_ear
	movsg $2, $cctrl	#Load cctrl settings
	sw $2, pcb_cctrl($1)	#Store to pcb_cctrl
	addi $2, $0, 4		#Set up the time slice
	sw $2, pcb_timeSlice($1)#Store time slice into pcb
	addi $3, $0, 1
	sw $3, pcb_enable($1)	#Set enable current task in PCB
	
	#Set the first run task, serial task
	la $1, rocks_PCB	#Load the address of serial_PCB
	sw $1, current_task($0)	#Store the address to current task pointer
	j Load_Context		#Jump to load context of registers from PCB
	
task1_Detection:
	jal breakout_main
	j Quit_Task
task2_Detection:
	jal rocks_main
	j Quit_Task
task3_Detection:
	jal gameSelect_main
	j Quit_Task

Quit_Task:
	sw $0, pcb_enable($13)

Interrupt_Handler:
	#When interrupts generated, by the set of $evec
	#It will go here to handle the interrupt
	movsg $13,$estat	#Get the value of $estat into $13
	andi $4,$13,0xFFB0	#Check if there are other interrupts besides IRQ2
	beqz $4,IRQ_2_Handler	#If there is only IRQ2, then brench to the handler
	lw $13,old_vector($0)	#Else load the value in old_vector, the orignal handler
	jr $13			#Jump to that handler

IRQ_2_Handler:
	sw $0, 0x72003($0)	#Acknowledge timer
	lw $13, time_slice($0)	#Load time slice value into $13
	subi $13, $13, 1	#Substract by one
	sw $13, time_slice($0)	#Restore $13 into time_slice
	beqz $13, dispatcher	#If $13 is 0, it means the current task running time is over
				#branch to dispatcher to dispatch next task
	rfe			#Else, return from exception

dispatcher:			#dispatcher is to dispatch each
Save_Context:
	#Save_Context is to save current task's registers into PCB
	lw $13, current_task($0)#Load current task PCB address

	sw $1, pcb_reg1($13)	#Store general registers, $1 to $ra, except $13
	sw $2, pcb_reg2($13)	#because the original value in $13 is automatically
	sw $3, pcb_reg3($13)	#stored into $ers, exception register save
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

	movsg $1, $ers		#Move $13 value from $ers to $1
	sw $1, pcb_reg13($13)	#Store $1 into pcb_reg13, where $13 should be
	
	movsg $1, $ear		#Move $ear from $ear to $1
	sw $1, pcb_ear($13)	#Store $1 into pcb_ear

	movsg $1, $cctrl	#Move $cctrl from $cctrl to $1
	sw $1, pcb_cctrl($13)	#Store $1 into pcb_cctrl

Schedule:
	#Schedule next task become current task
	lw $13, current_task($0)#Load current task PCB address
	lw $13, pcb_link($13)	#Using $13 value loaded before, to load next task PCB address in pcb_link
	sw $13, current_task($0)#Store next task PCB address into current_task flag
	lw $13, pcb_enable($13)
	seqi $13, $13, 0
	bnez $13, Schedule

Renew_time_slice:
	#Renew time slice for scheduled next task to run
	lw $1, current_task($0)	#Load current task's PCB address
	lw $13, pcb_timeSlice($1)#Load the time slice for this task
	sw $13, time_slice($1)	#Store into time_slice variable

Load_Context:
	#Load scheduled next task's registers in its PCB
	lw $13, current_task($0)#Load current task PCB address

	lw $1, pcb_reg13($13)	#Load $13 from pcb_reg13 to $1
	movgs $ers, $1		#Move $13 value from $1 to $ers

	lw $1, pcb_ear($13)	#Load $ear from PCB
	movgs $ear, $1		#Move the value to $ear

	lw $1, pcb_cctrl($13)	#Load $cctrl from PCB
	movgs $cctrl, $1	#Move the value to $cctrl

	lw $1, pcb_reg1($13)	#Load general registers from $1 to $ra except $13
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
