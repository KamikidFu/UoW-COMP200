all:
	wcc -S serial_task.c
	wcc -S parallel_task.c
	wasm serial_task.s
	wasm parallel_task.s
	wasm kernel_q5.s
	wlink -o kernel_q5.srec kernel_q5.o serial_task.o parallel_task.o
	
clean:
	rm serial_task.s serial_task.o kernel_q5.srec kernel_q5.o parallel_task.s parallel_task.o
	
