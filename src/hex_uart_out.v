`timescale 1ns/1ps
// 수신 바이트를 "XX\r\n" (ASCII 16진수)로 UART 송신
module hex_uart_out #(parameter integer DIV = 5208)(
    input wire clk, rst_p, valid,
    input wire [7:0] data,
    output wire tx
);
    reg [7:0] d; reg [2:0] k; reg busy; reg send;
    wire ready; reg [7:0] ch;
    function [7:0] hx(input [3:0] n); hx = (n<10) ? 8'h30+n : 8'h41+n-10; endfunction
    always @* case(k) 0: ch=hx(d[7:4]); 1: ch=hx(d[3:0]); 2: ch=8'h0D; default: ch=8'h0A; endcase
    uart_tx #(.DIV(DIV)) u(.clk(clk),.rst_p(rst_p),.valid(send),.data(ch),.ready(ready),.tx(tx));
    always @(posedge clk) begin
        if (rst_p) begin busy<=0; k<=0; send<=0; d<=0; end
        else begin
            send<=0;
            if (!busy) begin if (valid) begin d<=data; k<=0; busy<=1; end end
            else if (ready && !send) begin
                send<=1;
            end else if (send) begin   // send 펄스 직후 다음 문자 준비
                if (k==3) begin busy<=0; k<=0; end else k<=k+1'b1;
            end
        end
    end
endmodule
