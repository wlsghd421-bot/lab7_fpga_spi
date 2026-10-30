/* STM32_3 과제8·9(송신 측) / 과제11 수신 확인용 송신 MCU
 * ece2_474_routine.c 의 polling_routine() 을 이 함수로 교체한다. SPI1 마스터(기본 템플릿 설정).
 * 1초마다 0x55, 0xA5, 0x00, 0xFF 를 차례로 보낸다. */
void polling_routine(void)
{
    static uint32_t last_ms = 0;
    static uint8_t  idx = 0;
    static const uint8_t table[4] = { 0x55, 0xA5, 0x00, 0xFF };

    uint32_t now_ms = HAL_GetTick();
    if (now_ms - last_ms < 1000U) return;
    last_ms = now_ms;

    uint8_t tx = table[idx];
    idx = (uint8_t)((idx + 1U) & 3U);

    HAL_GPIO_WritePin(SPI_CS_ece2_GPIO_Port, SPI_CS_ece2_Pin, GPIO_PIN_RESET);
    HAL_StatusTypeDef result = HAL_SPI_Transmit(&hspi1, &tx, 1U, 100U);
    HAL_GPIO_WritePin(SPI_CS_ece2_GPIO_Port, SPI_CS_ece2_Pin, GPIO_PIN_SET);

    printf("TX=%02X, result=%d\r\n", (unsigned int)tx, (int)result);
}
