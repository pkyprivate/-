`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/07 15:50:19
// Design Name: 
// Module Name: Divider
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
module Divider #(parameter Time =10)
(
input I_CLK, //输入时钟信号，上升沿有效
output reg O_CLK //输出时钟
);
integer count=0;
initial O_CLK=0;
always @( posedge I_CLK )
  begin
    if(count+1==Time)
        begin
           O_CLK=~O_CLK;
           count=0;
        end
    else
        count=count+1;
   end
endmodule
