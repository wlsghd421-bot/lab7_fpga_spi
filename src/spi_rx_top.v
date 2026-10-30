`timescale 1ns/1ps
// 과제10: MCU(SPI 마스터) -> FPGA(SPI 슬레이브) 수신, 결과를 UART로 출력
module spi_rx_top(
    input  wire clk_50mhz, rst_p,
    input  wire spi_sck, spi_mosi, spi_cs_n,
    output wire pc_txd,
    output wire [7:0] led
);
    wire [7:0] d; wire v; reg [7:0] last;
    spi_slave_rx rx(.clk(clk_50mhz),.rst_p(rst_p),.sck(spi_sck),.mosi(spi_mosi),.cs_n(spi_cs_n),.data(d),.valid(v));
    hex_uart_out #(.DIV(5208)) out(.clk(clk_50mhz),.rst_p(rst_p),.valid(v),.data(d),.tx(pc_txd));
    always @(posedge clk_50mhz) if (rst_p) last<=0; else if (v) last<=d;
    assign led = last;
endmodule
