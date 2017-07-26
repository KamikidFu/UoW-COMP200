.global main
.text

main:
	#set up handler address
	movsg $2,$evec
	sw $2,default_handler($0)
	la $2, interrupt_handler
	movgs $evec, $2
	#enable irq2, interrupt mode and kernal mode
	addi $2, $0, 0x4A
	movgs $cctrl, $2
	# Acknowledge any outstanding interrupts
	sw $0, 0x72003($0)
	# Put our count value into the timer load reg
	addi $11, $0, 24
	sw $11, 0x72001($0)
	# Enable the timer and set auto-restart mode
	addi $11, $0, 0x3
	sw $11, 0x72000($0)
	# Unmask IRQ2,KU=1,OKU=1,IE=0,OIE=1
	addi $5, $0, 0x4d
	# Setup the pcb for task 1
	la $1, serial_pcb
	# Setup the link field
	la $2, serial_pcb
	sw $2, pcb_link($1)
	# Setup the stack pointer
	la $2, serial_stack
	sw $2, pcb_sp($1)
	# Setup the $ear field
	la $2, serial_main
	sw $2, pcb_ear($1)
	# Setup the $cctrl field
	sw $5, pcb_cctrl($1)
	la $1, serial_pcb
	sw $1, current_task($0)
	j load_context
interrupt_handler:
	#an IRQ3 interrupt (user interrupt button)
	movsg $13, $estat
	andi $13,$13,0xffb0
	beqz $13, timer_interrupt_handler
	lw $13,default_handler($0)
	jr $13
timer_interrupt_handler:
	#acknowledge
	sw $0, 0x72003($0)
	#if the time has not run out, we increment the counter
	lw $13,counter($0)
	addi $13,$13,1
	sw $13,counter($0)
	#subtract the time slice by one, if the time runs out, we jump to dispatcher
	lw $13, current_time_slice($0)
	subi $13,$13,1
	sw $13, current_time_slice($0)
	beqz $13, dispatcher

	rfe
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
	#bottom of the task
	.equ pcb_sp, 14
	.equ pcb_ra, 15
	#value of PC when an exception has occured, it is set to the entry point of the task
	.equ pcb_ear, 16
	.equ pcb_cctrl, 17
dispatcher:
save_context:
	# Get the base address of the current PCB
	lw $13, current_task($0)
	# Save the registers
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
	# $1 is saved now so we can use it
	# Get the old value of $13
	movsg $1, $ers
	# and save it to the pcb
	sw $1, pcb_reg13($13)
	# Save $ear
	movsg $1, $ear
	sw $1, pcb_ear($13)
	# Save $cctrl
	movsg $1, $cctrl
	sw $1, pcb_cctrl($13)
schedule:
	lw $13, current_task($0)
	lw $13, pcb_link($13)
	sw $13, current_task($0)
new_time_slice:
	#set the new time slice
	lw $13, current_time_slice($0)
	addi $13,$0,2
	sw $13, current_time_slice($0)
load_context:
	#Get PCB of current task
	lw $13, current_task($0)
	# Get the PCB value for $13 back into $ers
	lw $1, pcb_reg13($13)
	movgs $ers, $1
	# Restore $ear
	lw $1, pcb_ear($13)
	movgs $ear, $1
	# Restore $cctrl
	lw $1, pcb_cctrl($13)
	movgs $cctrl, $1
	# Restore the other registers
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
	# Return to the new task
	rfe
.data
	current_time_slice:
									.word 2
.bss
	serial_pcb:
						.space 18
						.space 200
  serial_stack:

	default_handler:
	.word
	current_task:
	.word
