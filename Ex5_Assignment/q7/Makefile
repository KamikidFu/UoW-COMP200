all:
	wasm kernel_q7.s
	wlink -o kernel_q7.srec kernel_q7.o breakout.o rocks.o gameSelect.o
	
clean:
	rm kernel_q7.srec kernel_q7.o
	
