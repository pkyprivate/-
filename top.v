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
input clk,//100Mhz���Դ�ʱ��
input rst,//mp3�����ź�
input ena,//ѡ����Ʒ�ʽ
// display7
output [6: 0] oData,//���Ƶ���ʵ������
output [7: 0] position,//������һλ����
//mp3
input       play,           //��ʼ��������
input       SO,             //����
input       DREQ,           //�������󣬸ߵ�ƽʱ�ɴ�������
output      XCS,            //Ƭѡ���루�͵�ƽ��Ч��
output      XDCS,           //����Ƭѡ/�ֽ�ͬ��
output      SCK,            //ʱ��
output      SI,             //����mp3
output      XRESET,         //Ӳ����λ���͵�ƽ��Ч
 //song choose
input pre,                  //��һ��
input nxt,                  //��һ��
//volume choose
input up,                   //����
input down,                  //����          
// bluetooth 
input signal,             //�����������
input RXD,
output TXD     ,           //ͨ������������ź�
// oled part 
output DIN, // input pin 
output OLED_CLK, //oled�ź�
output CS,
output DC, // Data & CMD 
output RES //��λ�ź�
  );
 //                                              �����ź�                                                     //
wire [15:0] Time;//ʱ���ź�
wire [2:0]  current1;//��������
wire [15:0] volume1;//��������
wire [2:0]  current2;//��������
wire [15:0] volume2;//��������
wire [2:0]  current;//�ϳ�MP3����
wire [15:0] volume;//�ϳ�MP3����
wire clk2;          //MP3ʱ��
Divider #(.Time(50)) divider(clk, clk2);
//                                              ʵ������ģ��                                                  //

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
