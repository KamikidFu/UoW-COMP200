.global main

# Useful handles for the different pcb entry.
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

main:
  # Set up interrupt handler address
  movsg $2, $evec
  sw $2, default_handler($0)
  la $2, interrupt_handler
  movgs $evec, $2

  # Unmask IRQ2(timer), KU=1, OKU=1, IE=0, OIE=1.
	addi $5, $0, 0x4D
	movgs $cctrl, $5

  # Make sure there are no old interrupts still hanging around in timer.
  sw $0, 0x72003($0)

  # Put our auto load value into timer.
  addi $11, $0, 24
  sw $11, 0x72001($0)

  # Enable the timer and autorestart for timer.
  addi $11, $0, 0x3
  sw $11, 0x72000($0)

  # Initialise the timeslice counter 2.
  addi $2, $0, 2
  sw $2, timeslice_count($2)

  # Load the base address for pcb 1.
  la $1, task1_pcb

  # Link pcb 1 to pcb 1.
  la $2, task1_pcb
  sw $2, pcb_link($1)

  # Setup the stack pointer for pcb 1.
  la $2, task1_stack
  sw $2, pcb_sp($1)

  # Setup the $ear field for pcb 1.
  la $2, serial_main
  sw $2, pcb_ear($1)

  # Setup the $cctrl field for pcb 1($5 set above).
  sw $5, pcb_cctrl($1)

  # Initialise the current task pointer to be task 1.
  la $1, task1_pcb
  sw $1, current_task($0)

  j load_context

dispatcher:
save_context:
  # Get the base address of our current pcb.
  lw $13, current_task($0)

  # Save all of our registers.
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

  # Get the old value of $13.
  movsg $1, $ers
  sw $1, pcb_reg13($13)

  # Save $ear.
  movsg $1, $ear
  sw $1, pcb_ear($13)

  # Save $cctrl.
  movsg $1, $cctrl
  sw $1, pcb_cctrl($13)

schedule:
  # Load the current task pcb.
  lw $13, current_task($0)

  # Load the next task pcb from the current pcb.
  lw $13, pcb_link($13)

  # Store the next task as the current task.
  sw $13, current_task($0)

load_context:
  # Get the pcb of the current task(the task we are abouit to start up).
  lw $13, current_task($0)

  # Reload $13 into $ers.
  lw $1, pcb_reg13($13)
  movgs $ers, $1

  # Restore $ear.
  lw $1, pcb_ear($13)
  movgs $ear, $1

  # Restore $cctrl
  lw $1, pcb_cctrl($13)
  movgs $cctrl, $1

  # Restore the other registers.
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

  # Return to the current task.
  rfe


interrupt_handler:
  # Check what caused the exception

  # Was it something that we don't handle?
  # It is included because it gives priority to software interrupts.
  movsg $13, $estat
  andi $13, $13, 0xffb0
  bnez $13, call_default_handler

  # Was it serial port 2?
  movsg $13, $estat
  andi $13, $13, 0x40
  bnez $13, timer_handler

  # Just call the default handler
  call_default_handler:
  lw $13, default_handler($0)
  jr $13

timer_handler:
  # Acknowledge interrupt.
  sw $0, 0x72003($0)

  # Increment counter variable.
  lw $13, counter($0)
  addi $13, $13, 1
  sw $13, counter($0)

  # Decrement the timeslice counter.
  lw $13, timeslice_count($0)
  subi $13, $13, 1
  sw $13, timeslice_count($0)

  # If the timeslice counter is not zero, just return.
  bnez $13, no_dispatch

  # Reset the timeslice counter.
  addi $13, $0, 2
  sw $2, timeslice_count($0)

  # Jump to next task.
  j dispatcher

no_dispatch:
  #Return from exception.
  rfe

.bss
  # The first pcb, as well as it's stack.
  task1_pcb:
    .space 18
    .space 200
  task1_stack:

  timeslice_count:
    .word

  # A place to store a pointer to the currently running task.
  current_task:
    .word

	# A place to store the address of the default exception handler
	default_handler:
    .word
