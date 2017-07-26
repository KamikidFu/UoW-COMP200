all:
	wasm kernel_q7.s
	wcc -S serial_task.c
	wasm serial_task.s
	wcc -S parallel_task.c
	wasm parallel_task.s
	wlink -o kernel_q7.srec parallel_task.o serial_task.o kernel_q7.o breakout.o rocks.o gameSelect.o
	
clean:
	rm kernel_q7.srec kernel_q7.o serial_task.o serial_task.s parallel_task.s parallel_task.o
	
