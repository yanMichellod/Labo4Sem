#include "stm32f7xx_hal.h"
#include <stdint.h>


extern  void ledSend(uint32_t);
extern void ledsRGB(uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t);
extern void manyLedRGB(uint32_t , uint32_t*);
void SystemClock_Config (void);
GPIO_InitTypeDef GPIO_InitStruct;

int main(void)
{
	uint32_t i;
	SystemClock_Config();
	__HAL_RCC_GPIOA_CLK_ENABLE();
  GPIO_InitStruct.Pin  = GPIO_PIN_0;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

	/*
	for(;;)
	{
			ledSend(0x00ff0000);
			ledSend(0x0000ff00);
			ledSend(0x000000ff);
			ledSend(0x000000ff);

	}
	*/
	uint32_t ledValues4[] = {0x00000000, 0x00000000, 0x00000000, 0x00000000};
	uint32_t ledValues5[] = {0x0000ff00, 0x000000ff, 0x00ff0000, 0x0000ff00, 0x00ff00ff};
	uint32_t ledValues8[] = {0x000000ff, 0x00ff0000, 0x0000ff00, 0x000000ff, 0x00ffffff, 0x00ff0000, 0x0000ff00, 0x000000ff};
	uint32_t ledValuesReset[] = {0x00000000, 0x00000000, 0x00000000,0x00000000, 0x00000000, 0x00000000, 0x00000000,0x00000000};
	manyLedRGB(8, ledValuesReset);
	uint8_t increase = 1;

	for(;;)
	{
			//ledsRGB(1, 0x00ff0000, 0x0000ff00, 0x000000ff, 0x00ff0000);
			//ledsRGB(2, 0x00ff0000, 0x0000ff00, 0x000000ff, 0x00ff0000);
			//ledsRGB(5, 0x00ff0000, 0x0000ff00, 0x000000ff, 0x00ff0000, 0x000000ff);
 			//ledsRGB(5, 0x00000000, 0x00000000, 0x00000000, 0x00000000,0x00000000);
			//manyLedRGB(4, ledValues4);
			//manyLedRGB(4, ledValuesReset);
			//manyLedRGB(5, ledValues5);
			//manyLedRGB(5, ledValuesReset);
			//manyLedRGB(8, ledValues8);
			//manyLedRGB(8, ledValuesReset);

			manyLedRGB(4, ledValues4);
		
			if(ledValues4[0] == 0)
			{
					increase = 1;
			} else if(ledValues4[0] == 0x000000ff)
			{
					increase = 0;
			}
			
			ledValues4[0] = (increase == 0) ? (--(ledValues4[0])) : (++(ledValues4[0]));
			ledValues4[1] = (increase == 0) ? (ledValues4[1] - 0x00000100) : (ledValues4[1] + 0x00000100);
			ledValues4[2] = (increase == 0) ? (ledValues4[2] - 0x00010000) : (ledValues4[2] + 0x00010000);
			ledValues4[3] = (increase == 0) ? (ledValues4[3] - 0x00010101) : (ledValues4[3] + 0x00010101);
		
			for(int i =0 ; i < 100000 ; i ++){
			}
	}

}
void SystemClock_Config (void) {
  RCC_ClkInitTypeDef RCC_ClkInitStruct;
  RCC_OscInitTypeDef RCC_OscInitStruct;

  /* Enable HSE Oscillator and activate PLL with HSE as source */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSIState = RCC_HSI_OFF;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 25;
  RCC_OscInitStruct.PLL.PLLN = 432;  
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 9;
  HAL_RCC_OscConfig(&RCC_OscInitStruct);

  /* Activate the OverDrive to reach the 216 MHz Frequency */
  HAL_PWREx_EnableOverDrive();
  
  /* Select PLL as system clock source and configure the HCLK, PCLK1 and PCLK2 clocks dividers */
  RCC_ClkInitStruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;  
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;  
  HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_7);
}

HAL_StatusTypeDef HAL_InitTick(uint32_t TickPriority)
{
	return HAL_OK;
}