//Define all the devices it will use, using pointer as reference of devices
#define sp2_transmit (int*)0x71000
#define sp2_receive (int*)0x71001
#define sp2_status (int*)0x71003
int counter = 0;	//Global counter

/*
	Methods:
	read_char(): Read char from sp2_receive register and return the value
	print_char(): Print char to sp2_transmit, pass a char into this method
	toChar(): Parse int value to char value type, for print char use and return the char
	clean_line(): Clean a line for next print
	print_minutes_and_seconds(): Print the type 1 format as required
	print_seconds(): Print the type 2 format as required
	print_timer_interrupts(): Print the type 3 format as required
	serial_main(): The main method in program
*/
char read_char(){
	while(1){						//Infinite loop for checking status
		if((*sp2_status & 1)!=0){			//Check the value in status register, if it is ready for it to receive any char
			return *sp2_receive;			//Then receive it from receive register
		}
		return '\0';					//Otherwise, return empty char
	}
}

void print_char(char charToPass){
	while(1){						//Infinite loop for checking status
		if((*sp2_status & 2)!=0){			//Check the value in status register, if it is ready for it to transmit any char
			*sp2_transmit = charToPass;		//Then transmit char to transmit register
			return;
		}
	}
}

char toChar(int key){
	if((key % 10)<10){					//Check the key if is less than 10, because it only parses int to char between 0 and 9
		char number_charArray[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};	//char array to pick which char to return
		return number_charArray[key];			//Return the char
	}
	return '\0';						//Otherwise, return empty char
}

void clean_line(){
	int looper;						//Loop counter
	for(looper=7;looper>0;looper--){			//For loop to print space char to line for cleaning
		print_char(' ');				//Print the char
	}
	print_char('\r');					//print return char at the line
}

void print_minutes_and_seconds(){
	//Counter update 100 times per second
	//That is, from the last 3 digit, the second
	//Use shift_decimal to pick number in different decimal
	int shift_decimal=0;
	//Thus, counter divided by 100, it comes how many seconds, divided by 60 again, it comes how many minutes
	int min = (counter / 100) / 60;
	//As for seconds, mod by 60 to get how many seconds that could not form 1 minutes
	int sec = (counter / 100) % 60;
	//Using loop to display each decimal places in minutes on SP2
	for(shift_decimal=10; shift_decimal>0; shift_decimal /= 10){
		//Check if current decimal place can be shown
		if(min>=shift_decimal){
			//Call method to show the char it calculate
			print_char(toChar((min % (shift_decimal*10))/shift_decimal));
		}else{
			//Use char 0 as placeholder
			print_char('0');
		}
	}
	//Print the : char
	print_char(':');
	//Using loop to display each decimal places in seconds on SP2
	for(shift_decimal=10; shift_decimal>0; shift_decimal /= 10){
		//Check if current decimal place can be shown
		if(sec>=shift_decimal){
			//Call method to show the char it calculate
			print_char(toChar((sec % (shift_decimal*10))/shift_decimal));
		}else{
			//Use char 0 as placeholder
			print_char('0');
		}
	}
}

void print_seconds(){
	//Use shift_decimal to pick number in different decimal
	int shift_decimal=0;
	//Using loop to display each decimal places in SP2
	for(shift_decimal=100000; shift_decimal>0; shift_decimal /= 10){
		//When the decimal comes 10, it need to print . char
		if(shift_decimal == 10){
			print_char('.');
		}
		//Check if current decimal place can be shown
		if(counter>=shift_decimal){
			//Call method to show the char it calculate
			print_char(toChar((counter % (shift_decimal*10))/shift_decimal));
		}else{
			print_char('0');
		}
	}
}

void print_timer_interrupts(){
	//Use shift_decimal to pick number in different decimal
	int shift_decimal=0;
	//Using loop to display each decimal places in SP2
	for(shift_decimal=100000; shift_decimal>0 ; shift_decimal /= 10){
		//Check if current decimal place can be shown
		if(counter>=shift_decimal){
			//Call method to show the char it calculate
			print_char(toChar((counter % (shift_decimal*10))/shift_decimal));
		}else{
			//Use char 0 as placeholder
			print_char('0');
		}
	}
}

void serial_main(){
	//Status:0, quit;1, "\rmm:ss";2, "\rssss.ss";3, "\rtttttt"
	int status = 1;
	while(1){
		//Receive the letter from sp2
		char statusReceiveLetter = read_char();
		//Check the letter to change the status
		if(statusReceiveLetter == '1'){
			status=1;
		}else if(statusReceiveLetter == '2'){
			status=2;
		}else if(statusReceiveLetter == '3'){
			status=3;
		}else if(statusReceiveLetter == 'q'){
			return;
		}
		//Check status to call different methods
		if(status == 1){
			print_minutes_and_seconds();
		}else if(status == 2){
			print_seconds();
		}else if(status == 3){
			print_timer_interrupts();
		}else if(status == 0)
	      		return;		
		//Clean the line for next print
		clean_line();
	}
}

