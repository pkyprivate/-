`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/03 11:10:54
// Design Name: 
// Module Name: song_choose
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


module song_choose(
	input clk,
	input pre,
	input nxt,
	output reg [2:0] current
);
parameter DELAY_TIME = 20000000;
	integer delay = 0;
	always @ (negedge clk) begin 
            if(delay == DELAY_TIME) begin
                if(pre) begin
                    current <= (current==0) ? 0: current-1;
                    delay <= 0;
                end
                else if(nxt) begin
                    current <= (current==2) ? 2: current+1;
                    delay <= 0;
                end
            end
            else delay <= delay + 1;
           end
     
endmodule

