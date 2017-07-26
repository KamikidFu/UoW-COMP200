//Define all the devices it will use, using pointer as reference of devices
#define leftSSD (int*)0x73002
#define rightSSD (int*)0x73003
#define switches (int*)0x73000
#define pushButtons (int*)0x73001

//Main program
void main(){
	//Status, to change the print base or quit, 1 is 16-base, 2 is 10-base, 3 is to quit
	int status = 1;
	//Keep looping
	while(1){
		//Get the current push button value
		int pushButtonsValue = *pushButtons;
		//Get the current switches value
		int switchesValue = *switches;
		//If push button value is 0, it means the user did not push any button
		//So, it is not need to change the status
		//Therefore, the test is if the value not equal to 0
		if(pushButtonsValue != 0){
			//If the value is useful, then give value to status
			status = pushButtonsValue;
		}
		//Different cases of status
		//1 is for 16-base-SSD print
		if(status == 1){
			//Shift the switches value towards right by 4 bits, then and with 0xF
			//Because it only shows 4-bit data
			*leftSSD = ((switchesValue >> 4) & 0xF);
			//Get the last 4-bit data and send to right SSD
			*rightSSD = (switchesValue & 0xF);
		//Else if status is 2, for 10-base-SSD print
		}else if(status == 2){
			//Wrap the switches value by 99 using mod 100
			//That is, only shows the last 2-bit of decimal value
			switchesValue = switchesValue % 100;
			//Send the left bit to left SSD
			*leftSSD = (switchesValue / 10);
			//Send the right bit to right SSD
			*rightSSD = (switchesValue % 10);
		//Else if status is 3, for quiting program
		}else if(status == 3){
			//Quit
			return;
		}
	}
}

