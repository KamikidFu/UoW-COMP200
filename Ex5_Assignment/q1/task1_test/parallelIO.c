#define leftSSD (int*)0x73002
#define rightSSD (int*)0x73003
#define switches (int*)0x73000
#define pushButtons (int*)0x73001

void main(){
	int status = 1;
	while(1){
		int pushButtonsValue = *pushButtons;
		int switchesValue = *switches;
		if(pushButtonsValue != 0){
			status = pushButtonsValue;
		}
/*
		switch(status){
			case 1:
				*leftSSD = ((switchesValue >> 4) & 0xF);
				*rightSSD = (switchesValue & 0xF);
			case 2:
				switchesValue = switchesValue % 100;
				*leftSSD = (switchesValue / 10);
				*rightSSD = (switchesValue % 10);
			case 3:
				return;
			default:
				switchesValue = switchesValue % 100;
				*leftSSD = (switchesValue / 10);
				*rightSSD = (switchesValue % 10);
		}
*/

		if(status == 1){
			*leftSSD = ((switchesValue >> 4) & 0xF);
			*rightSSD = (switchesValue & 0xF);
		}else if(status == 2){
			switchesValue = switchesValue % 100;
			*leftSSD = (switchesValue / 10);
			*rightSSD = (switchesValue % 10);
		}else if(status == 3){
			return;
		}
	}
}

/*
void main(){
	int status = buttonStatus();
	while(1){
		switch(status){
			case -1:
				return;
			case 1:
				*leftSSD = (*switches) / 16;
				*rightSSD = (*switches) % 16;
			default:
				*leftSSD = (*switches % 100) / 10;
				*rightSSD = (*switches % 100) % 10;
		}
	}
}
*/
/*
void printDecBase(){
	*leftSSD = (*switches % 100) / 10;
	*rightSSD = (*switches % 100) % 10;
}
void printHexBase(){
	*leftSSD = (*switches) / 16;
	*rightSSD = (*switches) % 16;
}
*/
/*
int buttonStatus(){
//Four status of buttons
//Exit, two button pressed, button value is 3, return -1
//10-base, button 1 pressed, button value is 2, return 0
//16-base, button 0 pressed, button value is 1, return 1
//No-thing pressed, button value is 0, return 2
	int button = *pushButtons;
	if(button == 3){
		return -1;
	}else if(button == 2){
		return 0;
	}else if(button == 1){
		return 1;
	}else{
		return 2;
	}
}
*/
/*WASM cannot support bool value?
void main(){
	bool exit = false;
	int base = 0;
	int switchValue = 0;
	while(!exit){
		base = printBase();
		if(base == 1){
			switchValue = switches;
			leftSSD = ((switchValue >> 4)&0x0F);
			rightSSD = switchValue&0x0F;
		}else if(base == 2){
			switchValue = switches % 100;
			leftSSD = (switchValue / 10);
			rightSSD = (switchValue % 10);
		}
		exist = twoButtons();
	}
}
int printBase(){
//Print bases are 16 or 10
//Return 1, if the button 0 is pressed, 16-based
//Return 0, if the button 1 is pressed, 10-based
//By default, it is 10-based output
	int buttonValue = pushButtons;
	if(buttonValue == 1){
		return 1;
	}else if(buttonValue == 2){
		return 0;
	}else{
		return 0;
	}
}
bool twoButtons(){
//Check if two buttons are pushed
//if so, the exit boolean value become true
//if not, the exit boolean value become false;
	int buttonValue = pushButtons;
	if(buttonValue == 3){
		return true;
	}
	return false;
}
*/

