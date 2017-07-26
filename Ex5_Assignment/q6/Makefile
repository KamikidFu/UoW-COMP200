all:
	wasm kernel_q6.s
	wcc -S serial_task.c
	wasm serial_task.s
	wcc -S parallel_task.c
	wasm parallel_task.s
	wlink -o kernel_q6.srec parallel_task.o serial_task.o kernel_q6.o breakout.o rocks.o gameSelect.o
	
clean:
	rm kernel_q6.srec kernel_q6.o serial_task.o serial_task.s parallel_task.s parallel_task.o
	
