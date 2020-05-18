// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x70; //make a pointer to access the PIO block
	volatile unsigned int *SW_PIO = (unsigned int*)0x50;
	volatile unsigned int *PUSH_PIO = (unsigned int*)0x60;

	unsigned int accumulator = 0;
	unsigned int pressed = 0;

	*LED_PIO = 0; //clear all LEDs
	while ( (1+1) != 3) //infinite loop
	{
		if ((*PUSH_PIO & 0x01) == 0x01)
			accumulator = 0;

		else{
			if ((*PUSH_PIO & 0x10) == 0x10){
				if (pressed == 0){
					accumulator += *SW_PIO;
					if (accumulator > 255){
						accumulator -= 256;
					}
					pressed = 1;
				}
			}
			else{
				pressed = 0;
			}
		}

		for (i=0;i < 100000;i++);
		*LED_PIO = accumulator;
	}
	return 1; //never gets here
}
