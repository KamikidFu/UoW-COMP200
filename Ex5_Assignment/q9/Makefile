all:
	wasm kernel_q9.s
	wlink -o kernel_q9.srec kernel_q9.o breakout.o rocks.o gameSelect.o
	
clean:
	rm kernel_q9.srec kernel_q9.o
	
