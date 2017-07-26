#define sp1_transmit (int*)0x70000
#define sp1_receive (int*)0x70001
#define sp1_status (int*)0x70003
#define sp2_transmit (int*)0x71000
#define sp2_receive (int*)0x71001
#define sp2_status (int*)0x71003
int counter = 0;
char number_charArray[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

void main(){
	//Status:0, quit;1, "\rmm:ss";2, "\rssss.ss";3, "\rtttttt"
	int status = 1;
	while(1){
		char statusReceiveLetter;
		int status = *sp2_status;
		int shift_decimal;
		int min,sec;
		if((status & 1)!=0){
			statusReceiveLetter = *sp2_receive;
		}else{
			continue;
		}
		if(statusReceiveLetter == '1'){
			status=1;
		}else if(statusReceiveLetter == '2'){
			status=2;
		}else if(statusReceiveLetter == '3'){
			status=3;
		}else if(statusReceiveLetter == 'q'){
			status=0;
		}else{
			continue;
		}

		while(1){
			if((*sp2_status & 2)!=0){
				*sp2_transmit = '\r';
				break;
			}
		}
		while(1){
			if((*sp2_status & 2)!=0){
				*sp2_transmit = '\n';
				break;
			}
		}

		if(status == 1){
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = '\r';
					break;
				}
			}
			min = (counter / 100) / 60;
			sec = (counter / 100) % 60;
			for(shift_decimal=10; shift_decimal>0; shift_decimal /= 10){
				if(min>=shift_decimal){
					while(1){
						if((*sp2_status & 2)!=0){
							*sp2_transmit = number_charArray[(min % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = ':';
					break;
				}
			}
			for(shift_decimal=10; shift_decimal>0; shift_decimal /= 10){
				if(sec>=shift_decimal){
					while(1){
						if((*sp2_status & 2)!=0){
							*sp2_transmit = number_charArray[(sec % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
		}else if(status == 2){
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = '\r';
					break;
				}
			}
			for(shift_decimal=100000; shift_decimal>0; shift_decimal /= 10){
				if(shift_decimal == 10){
					while(1){
						if((*sp2_status & 2)!=0){
							*sp2_transmit = '.';
							break;
						}
					}
				}
				if(counter>=shift_decimal){
					while(1){
						if((*sp2_status & 2)!=0){
							*sp2_transmit = number_charArray[(counter % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
		}else if(status == 3){
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = '\r';
					break;
				}
			}
			for(shift_decimal=100000; shift_decimal>0 ; shift_decimal /= 10){
				if(counter>=shift_decimal){
					while(1){
						if((*sp2_status & 2)!=0){
							*sp2_transmit = number_charArray[(counter % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
		}else if(status == 0)
	      		return;		
	}
}
/*
char read_char(){
	if((*sp2_status & 1)!=0){
		return *sp2_receive;
	}
	return '\0';
}
*/
/*
void print_char(char charToPass){
	while(1){
		if((*sp2_status & 2)!=0){
			*sp2_transmit = charToPass;
			return;
		}
	}
}

char toChar(int key){
	if((key % 10)<10){
		char number_charArray[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		return number_charArray[key];
	}
	return '\0';
}
*/
/*
void next_line(){
	print_char('\r');
	print_char('\n');
}
*/
/*
void print_minutes_and_seconds(){
	print_char('\r');
	int shift_decimal=0;
	int min = (counter / 100) / 60;
	int sec = (counter / 100) % 60;
	for(shift_decimal=10000; shift_decimal>0; shift_decimal /= 10){
		if(counter>=shift_decimal){
			print_char(toChar((min % (shift_decimal*10))/shift_decimal));
		}
	}
	print_char(':');
	for(shift_decimal=10000; shift_decimal>0; shift_decimal /= 10){
		if(counter>=shift_decimal){
			print_char(toChar((sec % (shift_decimal*10))/shift_decimal));
		}
	}
}

void print_seconds(){
	print_char('\r');
	for(shift_decimal=10000; shift_decimal>0; shift_decimal /= 10){
		if(shift_decimal == 10){
			print_char('.');
		}
		if(counter>=shift_decimal){
			print_char(toChar((counter % (shift_decimal*10))/shift_decimal));
		}
	}
}

void print_timer_interrupts(){
	print_char('\r');
	int shift_decimal=0;
	for(shift_decimal=100000; shift_decimal>0 ; shift_decimal /= 10){
		if(counter>=shift_decimal){
			print_char(toChar((counter % (shift_decimal*10))/shift_decimal));
		}
	}
}
*/
