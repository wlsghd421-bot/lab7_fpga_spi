`timescale 1ns/1ps
// SPI Mode 0 마스터 송신기: SCK = CLK_HZ/(2*HALF) , MSB first
module spi_master_tx #(parameter integer HALF = 50)(   // 50 MHz/100 = 500 kHz
    input  wire clk, rst_p,
    input  wire start,
    input  wire [7:0] tx_data,
    output reg  sck, mosi, cs_n,
    output wire busy
);
    localparam IDLE=0, SETUP=1, HI=2, LO=3, TAIL=4;
    reg [2:0] st;
    reg [7:0] sh;
    reg [2:0] bitn;
    integer t;
    assign busy = (st != IDLE);
    always @(posedge clk) begin
        if (rst_p) begin
            st<=IDLE; sck<=0; mosi<=0; cs_n<=1; sh<=0; bitn<=0; t<=0;
        end else case (st)
            IDLE: if (start) begin
                sh<=tx_data; cs_n<=0; mosi<=tx_data[7]; bitn<=0; t<=HALF-1; st<=SETUP;
            end
            SETUP: if (t!=0) t<=t-1; else begin sck<=1; t<=HALF-1; st<=HI; end   // 첫 상승 에지
            HI:    if (t!=0) t<=t-1; else begin
                sck<=0; t<=HALF-1;                                                   // 하강 에지
                if (bitn==3'd7) st<=TAIL;
                else begin sh<={sh[6:0],1'b0}; mosi<=sh[6]; bitn<=bitn+1'b1; st<=LO; end
            end
            LO:    if (t!=0) t<=t-1; else begin sck<=1; t<=HALF-1; st<=HI; end
            TAIL:  if (t!=0) t<=t-1; else begin cs_n<=1; mosi<=0; st<=IDLE; end
        endcase
    end
endmodule
