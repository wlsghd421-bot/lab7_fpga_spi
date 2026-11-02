`timescale 1ns/1ps
// 핀 확인용: 입력 핀 8개를 LED D1~D8에 그대로 표시한다. (3.3 V를 닿게 하면 해당 LED가 켜진다)
// in[0]=F8(I/O 00) in[1]=E8(I/O 01) in[2]=A7(I/O 02) in[3]=G8(I/O 03)
// in[4]=G10(EXT1)  in[5]=C10(EXT2)  in[6]=F11(EXT3)  in[7]=D11(EXT4)
module pin_probe(input wire [7:0] in, output wire [7:0] led);
    assign led = in;
endmodule
