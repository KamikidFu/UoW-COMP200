#define sp2_transmit (int*)0x71000
#define sp2_receive (int*)0x71001
#define sp2_status (int*)0x71003
int counter = 0;	//Global counter
char number_charArray[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};	//Char Array for Ouput Number

void main(){
	//Status:0, quit;1, "\rmm:ss";2, "\rssss.ss";3, "\rtttttt"
	int outputFormat = 1;
	//Inifine loop
	while(1){
		//Local variables
		//char statusReceiveLetter, to receive the letters from SP2, e.g. 1,2,3,q or others
		//int shift_decimal, using to mod each decimal place numbers
		//int min,sec, using to show the minutes and seconds of counter
		//int status, current SP2 status
		char statusReceiveLetter;
		int shift_decimal;
		int min,sec;
		//Check RDR if it is okay to receive letter from SP2
		if((*sp2_status & 1)!=0){
			//Receive letter from SP2
			statusReceiveLetter = *sp2_receive;
		}
		//Check the letter to change the status
		if(statusReceiveLetter == '1'){
			//If letter is '1', then status is 1, "\rmm:ss" output
			outputFormat=1;
		}else if(statusReceiveLetter == '2'){
			//If letter is '2', then status is 2, "\rssss.ss" output
			outputFormat=2;
		}else if(statusReceiveLetter == '3'){
			//If letter is '3', then status is 3, "\rtttttt" output
			outputFormat=3;
		}else if(statusReceiveLetter == 'q'){
			//If letter is 'q', then status is 0, to quit
			return;
		}

		//Generate a new line to output
		//Using loop to check status, and transmit '\r', to SP2
		while(1){
			if((*sp2_status & 2)!=0){
				*sp2_transmit = '\r';
				break;
			}
		}
		//Using loop to check status, and transmit '\n', to SP2
		while(1){
			if((*sp2_status & 2)!=0){
				*sp2_transmit = '\n';
				break;
			}
		}
		
		//Check different status for different output
		if(outputFormat == 1){
			//Using loop to check status, and transmit '\r', to SP2
			//To make it return at beginning of line
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = '\r';
					break;
				}
			}
			//Counter update 100 times per second
			//That is, from the last 3 digit, the second
			//Thus, counter divided by 100, it comes how many seconds, divided by 60 again, it comes how many minutes
			min = (counter / 100) / 60;
			//As for seconds, mod by 60 to get how many seconds that could not form 1 minutes
			sec = (counter / 100) % 60;
			//Using loop to display each decimal places in minutes on SP2
			for(shift_decimal=10; shift_decimal>0; shift_decimal /= 10){
				//Check if current decimal place can be shown
				if(min>=shift_decimal){
					//Using loop to check status, and transmit the number to SP2
					while(1){
						if((*sp2_status & 2)!=0){
							//Using number char array to locate which char to show
							*sp2_transmit = number_charArray[(min % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
			//Using loop to check status, and transmit ':' to SP2
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = ':';
					break;
				}
			}
			//Using loop to display each decimal places in seconds on SP2
			for(shift_decimal=10; shift_decimal>0; shift_decimal /= 10){
				//Check if current decimal place can be shown
				if(sec>=shift_decimal){
					//Using loop to check status, and transmit the number to SP2
					while(1){
						if((*sp2_status & 2)!=0){
							//Using number char array to locate which char to show
							*sp2_transmit = number_charArray[(sec % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
		}else if(outputFormat == 2){	//Status 2, "\rssss.ss"
			//Using loop to check status, and transmit '\r', to SP2
			//To make it return at beginning of line
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = '\r';
					break;
				}
			}
			//Using loop to display each decimal places on SP2
			for(shift_decimal=100000; shift_decimal>0; shift_decimal /= 10){
				//Output the '.' when the decimal place is 10
				if(shift_decimal == 10){
					//Using loop to check status, and transmit '\.', to SP2
					while(1){
						if((*sp2_status & 2)!=0){
							*sp2_transmit = '.';
							break;
						}
					}
				}
				//Check if current decimal place can be shown
				if(counter>=shift_decimal){
					//Using loop to check status, and transmit to SP2
					while(1){
						if((*sp2_status & 2)!=0){
							//Using number char array to locate which char to show
							*sp2_transmit = number_charArray[(counter % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
		}else if(outputFormat == 3){	//Status 3, "\rtttttt"
			//Using loop to check status, and transmit '\r', to SP2
			//To make it return at beginning of line
			while(1){
				if((*sp2_status & 2)!=0){
					*sp2_transmit = '\r';
					break;
				}
			}
			//Using loop to display each decimal places on SP2
			for(shift_decimal=100000; shift_decimal>0 ; shift_decimal /= 10){
				//Check if current decimal place can be shown
				if(counter>=shift_decimal){
					//Using loop to check status, and transmit to SP2
					while(1){
						if((*sp2_status & 2)!=0){
							//Using number char array to locate which char to show
							*sp2_transmit = number_charArray[(counter % (shift_decimal*10))/shift_decimal];
							break;
						}
					}
				}
			}
		}else if(outputFormat == 0)	//Status 0, quit application
	      		return;		//Return from the method
	}
	return;
}
