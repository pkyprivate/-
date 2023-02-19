`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/30 17:42:28
// Design Name: 
// Module Name: top
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
module top(
//public
input clk,//100Mhz的自带时钟
input rst,//mp3重启信号
input ena,//选择控制方式
// display7
output [6: 0] oData,//控制灯现实的数字
output [7: 0] position,//控制哪一位灯亮
//mp3
input       play,           //开始播放请求
input       SO,             //传出
input       DREQ,           //数据请求，高电平时可传输数据
output      XCS,            //片选输入（低电平有效）
output      XDCS,           //数据片选/字节同步
output      SCK,            //时钟
output      SI,             //传入mp3
output      XRESET,         //硬件复位，低电平有效
 //song choose
input pre,                  //上一首
input nxt,                  //下一首
//volume choose
input up,                   //升高
input down,                  //降低          
// bluetooth 
input signal,             //对外输出歌曲
input RXD,
output TXD     ,           //通过蓝牙输入的信号
// oled part 
output DIN, // input pin 
output OLED_CLK, //oled信号
output CS,
output DC, // Data & CMD 
output RES //复位信号
  );
 //                                              串联信号                                                     //
wire [15:0] Time;//时间信号
wire [2:0]  current1;//按键控制
wire [15:0] volume1;//按键控制
wire [2:0]  current2;//蓝牙控制
wire [15:0] volume2;//蓝牙控制
wire [2:0]  current;//合成MP3歌曲
wire [15:0] volume;//合成MP3音量
wire clk2;          //MP3时钟
Divider #(.Time(50)) divider(clk, clk2);
//                                              实例化各模块                                                  //

        // time_counter
        time_counter A1(
            .rst(rst),
            .clk(clk),
            .Time(Time)
        );    
        
        // display7
        display7 B1(
            .clk(clk),
            .iData(Time),
            .oData(oData),
            .position(position)
        );
        
        //mp3
         mp3    C1(
               .clk(clk2),
               .rst(rst),
               .play(play),
               .SO(SO),
               .DREQ(DREQ),
               .XCS(XCS),
               .XDCS(XDCS),
               .SCK(SCK),
               .SI(SI),
               .XRESET(XRESET),
               .current(current),
               .volume(volume)
           );
           
         //song choose
         song_choose D1(
                 .clk(clk),
                 .nxt(nxt),
                 .pre(pre),
                 .current(current1)
                 );
                 
         //volume_choose
         volume_choose E1(
                  .clk(clk),
                  .up(up),
                  .down(down),
                  .volume(volume1)
                  );   
                  
          //bluetooth
          BlueTooth_command F1(  
                           .clk(clk),
                           .volume(volume2),
                           .rst(rst),
                           .current(current2),
                           .RXD(RXD)
                           );
           BlueTooth_show G1(
                            .clk(clk),
                            .TXD(TXD),
                            .signal(signal)
                                  );
        //decide which one to control
        selector  H1    (
                       .ena(ena),
                       .current(current),
                       .current1(current1),
                       .current2(current2),
                       .volume(volume),
                       .volume1(volume1),
                       .volume2(volume2)
                       );
                       
        //oled
        oled I1(
               .clk(clk), 
                .rst(rst),
               .current(current),
                .DIN(DIN), 
                .OLED_CLK(OLED_CLK), 
                .CS(CS), 
                .DC(DC), // Data & CMD 
                .RES(RES)
           );
endmodule
