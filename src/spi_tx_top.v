`timescale 1ns/1ps
// 과제11: FPGA(SPI 마스터) -> MCU 슬레이브. 1초마다 0x55,0xA5,0x00,0xFF를 순서대로 전송
module spi_tx_top #(parameter integer SEC = 50_000_000, parameter integer HALF = 50)(
    input  wire clk_50mhz, rst_p,
    output wire spi_sck, spi_mosi, spi_cs_n,
    output wire [7:0] led
);
    reg [31:0] t; reg [1:0] idx; reg start; wire busy;
    reg [7:0] txd;
    always @* case(idx) 0: txd=8'h55; 1: txd=8'hA5; 2: txd=8'h00; default: txd=8'hFF; endcase
    always @(posedge clk_50mhz) begin
        if (rst_p) begin t<=0; idx<=0; start<=0; end
        else begin
            start<=0;
            if (t == SEC-1) begin t<=0; start<=1; end else t<=t+1;
            if (start) idx<=idx+1'b1;
        end
    end
    // start 시점의 idx를 보내고 그 다음 펄스에서 idx 증가
    spi_master_tx #(.HALF(HALF)) m(.clk(clk_50mhz),.rst_p(rst_p),.start(start),.tx_data(txd),
        .sck(spi_sck),.mosi(spi_mosi),.cs_n(spi_cs_n),.busy(busy));
    assign led = txd;
endmodule
