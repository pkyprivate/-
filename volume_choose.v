`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/04 22:13:23
// Design Name: 
// Module Name: volume_choose
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


module volume_choose(
	input clk,
	input up,
	input down,
	output reg [15:0] volume
);
parameter DELAY_TIME = 10000000;
	integer delay = 0;
	always @ (negedge clk) begin 
            if(delay == DELAY_TIME) begin
                 if(up) 
                 begin
                   volume <= (volume==0) ? 0: (volume - 16'h10_10);
                    delay <= 0;
                end
                else if(down) 
                 begin
                     volume <= (volume==16'hF0_F0) ? 16'hF0_F0 : (volume + 16'h10_10);
                    delay <= 0;
                end
            end
            else delay <= delay + 1;
        end

endmodule
