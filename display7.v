`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/10 22:07:58
// Design Name: 
// Module Name: display7
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module display7(
input clk,//时钟信号
input [15:0] iData,//输入的秒钟信号
output reg [6:0] oData,//控制灯现实的数字
output reg [7: 0] position//控制哪一位灯亮
    );
wire CLK;
reg [4: 0] pos=0;
reg [31: 0] Data;
 Divider #(.Time(100000)) divider(clk, CLK);
 initial position = 8'b11111110;
 always @ (posedge CLK) 
    begin 
    position <= {position[6:0], position[7]};
    //此行代码为网上借鉴，用于七段数码管显示很有效
    if(pos<28)
    pos <= pos+4;
    else
    pos=0;
    end
    
    always@(iData)
    begin
      Data[3: 0] <= iData%10;//秒
         Data[7: 4] <= (iData/10)%6;//十秒
         Data[11: 8]<= (iData/60)%10;//分
         Data[15: 12] <= iData/600;//十分
         Data[19:16]<= (iData/6000);//百分
         Data[23:20] <= (iData/60000);//千分
         Data[27:24]<=0;//凑数用的
         Data[31:28]<=0;//凑数用的
    //change to display7
     case ({Data[pos+3], Data[pos+2],Data[pos+1],Data[pos]}) 
     4'b0000 :oData<=7'b1000000;
     4'b0001 :oData<=7'b1111001;
     4'b0010 :oData<=7'b0100100;
     4'b0011 :oData<=7'b0110000;
     4'b0100 :oData<=7'b0011001;
     4'b0101 :oData<=7'b0010010;
     4'b0110 :oData<=7'b0000010;
     4'b0111 :oData<=7'b1111000;
     4'b1000 :oData<=7'b0000000;
     4'b1001 :oData<=7'b0010000;   
     default :oData<=7'b1111111;
    endcase
   end
endmodule
