all:
	wasm kernel_q6.s
	wlink -o kernel_q6.srec kernel_q6.o breakout.o rocks.o gameSelect.o
	
clean:
	rm kernel_q6.srec kernel_q6.o
	
