all:
	wcc -S serial_task.c
	wasm serial_task.s
	wasm kernel_q3.s
	wlink -o kernel_q3.srec kernel_q3.o serial_task.o
	
clean:
	rm serial_task.s serial_task.o kernel_q3.srec kernel_q3.o
	
