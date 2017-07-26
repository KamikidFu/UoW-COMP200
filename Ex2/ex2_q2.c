#include "/home/comp200/ex2/lib_ex2.h"

void count(int start, int end){
	if(0<=start && 0<=end && start<100 && end<100 && start!=end){
		int i=0;
		if(start<end){
			for(i=start;i<=end;i++){
				writessd(i);
				delay();
			}
		}else{
			for(i=start;end<=i;i--){
				writessd(i);
				delay();
			}
		}
}
}
