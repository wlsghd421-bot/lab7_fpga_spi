`timescale 1ns/1ps
module tb_spi;
    reg clk=0, rst=1; always #10 clk=~clk;
    // (1) master -> slave 직결 (과제12 구조)
    wire sck, mosi, cs_n; reg start=0; reg [7:0] txd;
    wire [7:0] rxd; wire v; wire busy;
    spi_master_tx #(.HALF(50)) m(.clk(clk),.rst_p(rst),.start(start),.tx_data(txd),.sck(sck),.mosi(mosi),.cs_n(cs_n),.busy(busy));
    spi_slave_rx s(.clk(clk),.rst_p(rst),.sck(sck),.mosi(mosi),.cs_n(cs_n),.data(rxd),.valid(v));
    integer errs=0, rises=0; reg [7:0] got[0:7]; integer n=0;
    always @(posedge sck) rises = rises + 1;
    always @(posedge clk) if (v) begin got[n]=rxd; n=n+1; end
    task send(input [7:0] b); begin
        txd=b; @(posedge clk); start=1; @(posedge clk); start=0;
        wait(!busy); repeat(20) @(posedge clk);
    end endtask
    // MOSI는 SCK 상승 에지에서 MSB부터 읽어 sampled와 비교
    reg [7:0] samp; integer sb=0; reg [7:0] exp_bits[0:3];
    always @(posedge sck) begin samp = {samp[6:0],mosi}; end
    initial begin
        repeat(5) @(posedge clk); rst=0; repeat(5) @(posedge clk);
        send(8'h55); send(8'hA5); send(8'h00); send(8'hFF);
        if (n!==4) begin errs=errs+1; $display("FAIL count n=%0d",n); end
        if (got[0]!==8'h55) begin errs=errs+1; $display("FAIL 55 got %h",got[0]); end
        if (got[1]!==8'hA5) begin errs=errs+1; $display("FAIL A5 got %h",got[1]); end
        if (got[2]!==8'h00) begin errs=errs+1; $display("FAIL 00 got %h",got[2]); end
        if (got[3]!==8'hFF) begin errs=errs+1; $display("FAIL FF got %h",got[3]); end
        if (rises!==32) begin errs=errs+1; $display("FAIL rises=%0d",rises); end
        if (sck!==1'b0 || cs_n!==1'b1) begin errs=errs+1; $display("FAIL idle"); end
        if (errs==0) $display("PASS: 4 bytes 55 A5 00 FF, 32 rising edges, idle SCK low / CS high");
        else $display("FAIL errs=%0d",errs);
        $finish;
    end
    initial begin #50_000_000; $display("FAIL timeout"); $finish; end
    initial begin $dumpfile("tb_spi.vcd"); $dumpvars(0,tb_spi); end
endmodule
