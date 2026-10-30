# lab7_fpga_spi — STM32_3 SPI (MCU ↔ FPGA)
- `src/spi_slave_rx.v` 과제10 슬레이브 수신기 (CS 확인, SCK 상승 에지 검출, 시프트 레지스터+비트 카운터, 입력 2단 동기화)
- `src/spi_master_tx.v` 과제11 마스터 송신기 (Mode 0, SCK 500 kHz, MSB first)
- `src/spi_rx_top.v` / `src/spi_tx_top.v` 상위 모듈, `src/hex_uart_out.v` + `src/uart.v` UART 출력
- `sim/tb_spi.sv` 마스터→슬레이브 직결(과제12 구조), `sim/tb_spi_top.sv` UART까지 엔드투엔드
- `mcu/` 과제8·9·11용 MCU polling_routine
- 핀: SCK=EXT1(G10), MOSI=EXT2(C10), CS=EXT3(F11)
```
iverilog -g2012 -o a.vvp src/spi_slave_rx.v src/spi_master_tx.v sim/tb_spi.sv && vvp a.vvp
iverilog -g2012 -o b.vvp src/*.v sim/tb_spi_top.sv && vvp b.vvp
```
