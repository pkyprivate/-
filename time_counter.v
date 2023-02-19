`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/31 23:18:02
// Design Name: 
// Module Name: time_counter
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

//用来计时1s操作
module time_counter(
    input rst,
	input clk,
	output reg [15: 0] Time
);
    integer counter=0;
    always @ (posedge clk)
    begin
    if(rst)
    begin
        if((counter+1)==100000000)
        begin
            counter <= 0;
            Time <= Time+1;
        end
        else
            counter <= counter+1;
         end
    else
       counter<=0;
    end
endmodule