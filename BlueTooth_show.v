`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/12 14:45:56
// Design Name: 
// Module Name: BlueTooth_show
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


module BlueTooth_show(
	input clk,
	input signal,
	output reg TXD=1
	);																	                                                             //大致思路与输入类似，tx连接蓝牙的rx，注意run信号为开始信号，连接的输入的over信号
        reg [12:0]cnt_clk=0;
        reg [4:0]cnt_message=0;
        reg t_start=1;
        wire [7:0]message=7'b0000000;
        always @(posedge clk) begin
            if (signal==1&&t_start==1) begin
                t_start<=0;
                cnt_clk<=0;
            end
            else if (signal==0&&t_start==0&&cnt_message==0) begin                //在run的下降沿开始输出
                TXD<=0;
                cnt_clk<=cnt_clk+1;
                if (cnt_clk==5208) begin
                    TXD<=message[cnt_message];
                    cnt_clk<=0;
                    cnt_message<=1;
                    t_start<=0;
                end
            end
            else if (cnt_message>=1) begin
                cnt_clk<=cnt_clk+1;
                if (cnt_clk==5208) begin
                    cnt_clk<=0;
                    if (cnt_message==8) begin
                        TXD<=1;
                        t_start<=1;
                        cnt_message<=0;
                    end
                    else begin
                        TXD<=message[cnt_message];
                        cnt_message<=cnt_message+1;
                    end
                end
            end
            else begin
                TXD=1;
            end
        end
    endmodule