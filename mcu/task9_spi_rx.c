/* STM32_3 과제9(수신 측) / 과제11 수신 MCU
 * SPI1 을 슬레이브로 다시 설정하고 VCP UART(9600)로 받은 값을 출력한다. */
#define SPI_NSS_RX_ece2_Pin       GPIO_PIN_4
#define SPI_NSS_RX_ece2_GPIO_Port GPIOA

void ece2_474_init(void)
{
    if (HAL_SPI_DeInit(&hspi1) != HAL_OK) Error_Handler();
    hspi1.Init.Mode = SPI_MODE_SLAVE;
    hspi1.Init.NSS  = SPI_NSS_HARD_INPUT;
    if (HAL_SPI_Init(&hspi1) != HAL_OK) Error_Handler();

    GPIO_InitTypeDef gpio = {0};
    gpio.Pin       = SPI_NSS_RX_ece2_Pin;
    gpio.Mode      = GPIO_MODE_AF_PP;
    gpio.Pull      = GPIO_PULLUP;
    gpio.Speed     = GPIO_SPEED_FREQ_LOW;
    gpio.Alternate = GPIO_AF5_SPI1;
    HAL_GPIO_Init(SPI_NSS_RX_ece2_GPIO_Port, &gpio);
}

void polling_routine(void)
{
    uint8_t rx = 0;
    HAL_StatusTypeDef result = HAL_SPI_Receive(&hspi1, &rx, 1U, 2000U);
    if (result == HAL_OK)           printf("RX=%02X\r\n", (unsigned int)rx);
    else if (result == HAL_TIMEOUT) printf("RX timeout: check sender, SCK, MOSI, CS and GND\r\n");
    else                            printf("RX error=%d\r\n", (int)result);
}
