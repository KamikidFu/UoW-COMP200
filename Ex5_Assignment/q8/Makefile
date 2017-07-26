all:
	wasm kernel_q8.s
	wlink -o kernel_q8.srec kernel_q8.o breakout.o rocks.o gameSelect.o
	
clean:
	rm kernel_q8.srec kernel_q8.o
	
