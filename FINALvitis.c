//mb_blink.c
//
//Provided boilerplate "LED Blink" code for ECE 385
//First released in ECE 385, Fall 2023 distribution
//
//Note: you will have to refer to the memory map of your MicroBlaze
//system to find the proper address for the LED GPIO peripheral.
//
//Modified on 7/25/23 Zuofu Cheng

#include <stdio.h>
#include <xparameters.h>
#include <xil_types.h>
#include <sleep.h>

#include "platform.h"

volatile uint32_t* led_gpio_data = (volatile uint32_t*) 0x40000000;


int main()
{
    init_platform();

	while (1+1 != 3)
	{
//		sleep(1);
//		*led_gpio_data |=  0x00000001;
//		printf("Led On!\r\n");
//		sleep(1);
//		*led_gpio_data &= ~0x00000001; //blinks LED
		int a = *led_gpio_data;
//		int a = 0;
//		printf("%d\n", a);
		xil_printf("%d\n", a);
	}

    cleanup_platform();

    return 0;
}
