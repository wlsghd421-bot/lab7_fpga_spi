`timescale 1ns/1ps
// 엔드투엔드: spi_tx_top -> spi_rx_top -> UART("XX\r\n") 검사, MOSI 변화 시점 검사, 중단된 바이트 복구 검사
module tb_spi_top;
    reg clk=0, rst=1; always #10 clk=~clk;
    wire sck, mosi, cs_n; wire [7:0] ltx, lrx; wire txd;
    spi_tx_top #(.SEC(400000), .HALF(50)) t(.clk_50mhz(clk),.rst_p(rst),.spi_sck(sck),.spi_mosi(mosi),.spi_cs_n(cs_n),.led(ltx));
    // 수신기 포트에는 마스터 출력 대신 mux: 정상 구간은 마스터, 중단 시험 구간은 TB가 구동
    reg force_en=0; reg f_sck=0, f_mosi=0, f_cs=1;
    wire r_sck = force_en ? f_sck : sck, r_mosi = force_en ? f_mosi : mosi, r_cs = force_en ? f_cs : cs_n;
    spi_rx_top #() r(.clk_50mhz(clk),.rst_p(rst),.spi_sck(r_sck),.spi_mosi(r_mosi),.spi_cs_n(r_cs),.pc_txd(txd),.led(lrx));
    // 마스터 규칙 검사: MOSI는 SCK 하강 에지(또는 CS 하강)에서만 바뀐다
    integer errs=0; reg mosi_q; reg sck_q=0;
    always @(posedge clk) begin
        if (!force_en && !cs_n && sck===1'b1 && mosi!==mosi_q) begin errs=errs+1; $display("FAIL MOSI changed while SCK high"); end
        mosi_q<=mosi;
    end
    // UART 모니터 (DIV=5208 -> 104166 ns/bit)
    reg [7:0] ch; integer i; reg [7:0] line[0:3]; integer cnt=0;
    task rxch; begin
        @(negedge txd); #(52083); for(i=0;i<8;i=i+1) begin #(104166); ch[i]=txd; end #(104166);
    end endtask
    task expect_byte(input [7:0] hi, input [7:0] lo); begin
        rxch; if (ch!==hi) begin errs=errs+1; $display("FAIL hi %h exp %h",ch,hi); end
        rxch; if (ch!==lo) begin errs=errs+1; $display("FAIL lo %h exp %h",ch,lo); end
        rxch; if (ch!==8'h0D) begin errs=errs+1; $display("FAIL CR"); end
        rxch; if (ch!==8'h0A) begin errs=errs+1; $display("FAIL LF"); end
    end endtask
    initial begin
        repeat(5) @(posedge clk); rst=0;
        expect_byte("5","5"); expect_byte("A","5");
        // 중단 시험: 마스터 유휴 확인 후 TB가 4클록만 보내고 CS를 올린 뒤, 완전한 0x3C를 보낸다
        wait(cs_n && !t.busy); #1000; force_en=1; f_cs=1; f_sck=0; #1000;
        f_cs=0; f_mosi=1; #500; repeat(4) begin f_sck=1; #500; f_sck=0; #500; end
        f_cs=1; #2000;
        f_cs=0;
        for (i=7;i>=0;i=i-1) begin f_mosi=(8'h3C>>i)&1; #500; f_sck=1; #500; f_sck=0; end
        #500; f_cs=1; #500;
        expect_byte("3","C");
        if (errs==0) $display("PASS: end-to-end UART 55 A5, MOSI change only on SCK low, aborted byte recovered (3C)");
        else $display("FAIL errs=%0d",errs);
        $finish;
    end
    initial begin #600_000_000; $display("FAIL timeout"); $finish; end
endmodule
