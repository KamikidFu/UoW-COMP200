all:
	wcc -S serial_task.c
	wasm serial_task.s
	wlink -o serial_task.srec serial_task.o
	
clean:
	rm serial_task.s serial_task.o serial_task.srec
	
