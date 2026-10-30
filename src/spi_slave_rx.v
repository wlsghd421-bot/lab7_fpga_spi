`timescale 1ns/1ps
// SPI Mode 0 슬레이브 수신기: CS 확인, SCK 상승 에지 검출, 8비트 MSB first 수신
module spi_slave_rx(
    input  wire clk, rst_p,
    input  wire sck, mosi, cs_n,
    output reg  [7:0] data,
    output reg  valid          // 한 바이트 수신 완료 시 clk 한 주기 high
);
    (* ASYNC_REG="TRUE" *) reg [2:0] sck_s, cs_s, mosi_s;
    wire sck_rise = (sck_s[2:1] == 2'b01);
    wire cs_low   = ~cs_s[1];
    reg [7:0] shift;
    reg [2:0] cnt;
    always @(posedge clk) begin
        if (rst_p) begin
            sck_s<=0; cs_s<=3'b111; mosi_s<=0;
            shift<=0; cnt<=0; data<=0; valid<=0;
        end else begin
            sck_s  <= {sck_s[1:0],  sck};
            cs_s   <= {cs_s[1:0],   cs_n};
            mosi_s <= {mosi_s[1:0], mosi};
            valid  <= 1'b0;
            if (!cs_low) cnt <= 3'd0;          // CS 해제 시 비트 카운터 초기화
            else if (sck_rise) begin
                shift <= {shift[6:0], mosi_s[1]};
                cnt   <= cnt + 1'b1;
                if (cnt == 3'd7) begin
                    data  <= {shift[6:0], mosi_s[1]};
                    valid <= 1'b1;
                end
            end
        end
    end
endmodule
