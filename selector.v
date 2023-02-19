`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/06 23:41:20
// Design Name: 
// Module Name: selector
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


module selector(
input ena,
input [2:0]current1,
input [15:0]volume1,
input [2:0] current2,
input [15:0] volume2,
output reg [2:0] current,
output reg [15:0] volume
    );

always@(*)
begin
   if(ena)
   begin
     current<=current1;
     volume<=volume1;
   end
   else
    begin
       current<=current2;
       volume<=volume2;
     end
end
endmodule
