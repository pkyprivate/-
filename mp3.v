module mp3(
    input       clk,             //2MH
    input       rst,            //MCU的重启请求
    input       play,           //开始播放始播放请求
    input       SO,             //MP3的传出信号
    input       DREQ,           //传输数据数据请求，高电平时可传输数据
    input       [2:0]current,  //歌曲id
    input       [15:0]volume,
    output reg  XCS,            //SCI 传输读写指令
    output reg  XDCS,           //SDI 传输数据
    output      SCK,            //MP3时钟
    output reg  SI,             //mp3的传入信号
    output reg  XRESET         //硬件复位，低电平有效
    );
    //设置MP3状态量
    parameter           H_RESET    = 0;      //硬复位
    parameter           S_RESET     = 1;     //软复位
    parameter           SET_CLOCKF  = 2 ;    //设置时钟寄存器
    parameter           SET_BASS    = 3 ;    //设置音调寄存器
    parameter           VOL_PRE     = 4 ;    //设置更改音量
    parameter           SET_VOL     = 5;     //设置音量寄存器
    parameter           WAITE       = 6;     //等待
    parameter           PLAY        = 7;     //播放
    parameter           END         = 8;     //结束
    
    reg [3:0]       state       = WAITE;            //state状态
    reg [31:0]      waiting_time     = 32'd0;     //延时进行操作
    reg [31:0]      SCI_cmd       = 32'd0;            //指令、地址 
    reg [7:0]       cntData   = 8'd32;            //SCI指令地址位数计数

    reg [31:0]      music_data     = 32'd0;           //音乐数据
    reg [31:0]      cntSended     = 32'd32;           //SDI中已经传送的数据位数

    reg [16:0]      addra       = 16'd0;            //ROM中的地址
    wire [31:0]     data0;                          //ROM传出
    wire [31:0]     data1;  
    wire [31:0]     data2;  
    wire [31:0]     data3;  
    wire [31:0]     data4;  
    reg             ena         = 0;
    reg             [2:0]pre_music = 0;
    reg             [15:0]pre_vol;
    assign SCK = (clk & ena);
  
  always @(negedge clk) begin
            if(!rst || pre_music!=current) begin
                pre_music <= current;
                XDCS <= 1'b1;
                XCS <= 1'b1;
                ena <= 0;
                SI <= 1'b0;
                XRESET <= 1'b1;
                addra <= 17'd0;
                cntSended <= 32'd32;
                music_data <= 32'd0;
                state <= WAITE;  
            end
            else begin
                case (state)
                    //----------------等待--------------//
                    WAITE:begin
                    if(waiting_time > 0)
                        waiting_time <= waiting_time - 1;
                    //转到硬复位
                    else begin
                        waiting_time <= 32'd2000;
                        state <= H_RESET;
                    end
                    end
                    //-----------------硬复位-------------//
                    H_RESET:begin
                    if(waiting_time> 0)
                        waiting_time<= waiting_time- 1;
                    else begin
                        XCS <= 1'b1;
                        XRESET <= 1'b0;
                        waiting_time <= 32'd10000;        //复位后延时一段时                                      
                        SCI_cmd  <= 32'h02_00_08_04;      //软复位指令
                        cntData <= 8'd32;                 //指令、地、数据长度
                        state <= S_RESET;                 //转移到软复位
                    end
                    end
                   //------------软复位----------------//
                   S_RESET:begin
                   if(waiting_time > 0) 
                   begin
                      XRESET <= 1;
                      waiting_time <= waiting_time - 1'b1;
                   end
                   else if(cntData == 0) //软复位结束
                   begin           
                      waiting_time <= 32'd10000;
                      cntData <= 8'd32;
                      SCI_cmd <= 32'h02_02_00_00;
                      state <= SET_BASS;
                      XCS <= 1'b1;                        
                      ena <= 1'b0;                        //关闭输入时钟
                      SI <= 1'b0;
                    end
                   else if(DREQ)                           //当DREQ有效时开始软复位
                   begin                     
                      XCS <= 1'b0;
                      ena <= 1'b1;
                      SI <=  SCI_cmd [cntData - 1];
                      cntData <= cntData -1;
                   end
                   else begin
                      XCS <= 1'b1;                        //DREQ无效时等待
                      ena <= 1'b0;
                      SI <= 1'b0;
                   end 
                   end            
                    //------设置音量信号--------//
                    SET_VOL:begin
                    if(waiting_time > 0)
                       waiting_time <=waiting_time -1;
                    else if(cntData == 0) 
                    begin
                       waiting_time<= 32'd2000;
                       state <= VOL_PRE;
                       cntData <= 8'd32;
                       XCS <= 1'b1;
                       ena <= 1'b0;
                       SI <= 1'b0;
                    end
                    else if(DREQ)       
                    begin                     //写入SCI指令地址数据
                       XCS <= 1'b0;
                       ena <= 1'b1;
                       SI <=  SCI_cmd [cntData - 1];
                       cntData <= cntData - 1'b1;
                    end
                    else begin                    //等待信号DREQ
                       XCS <= 1'b1;
                       ena <= 1'b0;
                       SI <= 1'b0;
                    end
                    end
                   //--------设置音调信号-----------//
                    SET_BASS:begin
                   if(waiting_time > 0)
                      waiting_time <=waiting_time -1;
                   else if(cntData == 0) 
                   begin
                      waiting_time <= 2000;
                      SCI_cmd <= 32'h02_03_70_00;
                      state <= SET_CLOCKF;
                      cntData <= 8'd32;
                      XCS <= 1'b1;
                      ena <= 1'b0;
                      SI <= 1'b0;
                    end
                    else if(DREQ)       
                    begin                     //写入SCI指令地址数据
                       XCS <= 1'b0;
                       ena <= 1'b1;
                       SI <=  SCI_cmd [cntData - 1];
                       cntData <= cntData - 1'b1;
                    end
                    else begin                 //等待信号DREQ
                       XCS <= 1'b1;
                       ena <= 1'b0;
                       SI <= 1'b0;
                    end
                  end
                   //--------设置时钟信号-----------//
                    SET_CLOCKF:begin
                  if(waiting_time > 0)
                     waiting_time <=waiting_time -1;
                  else if(cntData == 0) 
                  begin
                     waiting_time <= 2000;
                     state <= VOL_PRE;                   //转移到设置VOL
                     cntData <= 8'd32;
                     XCS <= 1'b1;
                     ena <= 1'b0;
                     SI <= 1'b0;
                  end
                  else if(DREQ)       
                  begin                    //写入SCI指令地址数据
                     XCS <= 1'b0;
                     ena <= 1'b1;
                     SI <=  SCI_cmd [cntData - 1];
                     cntData <= cntData - 1'b1;
                  end
                  else begin              //等待信号DREQ
                     XCS <= 1'b1;
                     ena <= 1'b0;
                     SI <= 1'b0;
                     end
                  end 
                   //----------改变音量----------//
                VOL_PRE:begin
                if(pre_vol!=volume)
                begin
                state <=SET_VOL;
                SCI_cmd <= {16'h02_0b,volume};
                pre_vol <= volume;
                cntData <= 8'd32;
                end
                else
                   state <= PLAY;  
               end
                //----------播放音乐----------//
                PLAY:begin
                if(waiting_time > 0)
                  waiting_time <= waiting_time - 1'b1;
                else if(play)
                begin
                   XDCS <= 1'b0;
                   ena <= 1'b1;
                   if(cntSended == 0) 
                   begin
                      if(pre_vol!=volume)
                      state <=VOL_PRE;
                      else
                      begin
                      XDCS <= 1'b1;                   //拉高XDCS
                      ena <= 1'b0;
                      SI <= 1'b0;
                      cntSended <= 32'd32;
                      case (current)
                      4'b0:music_data <= data0;
                      4'd1:music_data <= data1;
                      4'd2:music_data <= data2;
                      4'd3:music_data <= data3;
                      4'd4:music_data <= data4;
                      endcase
                    addra <= addra + 1'b1;
                    end
                    end
                   else begin
                   //当DREQ有效 或当前字节尚未发送完 则继续传
                   if(DREQ || (cntSended != 32 && cntSended != 24 && cntSended != 16 && cntSended != 8)) 
                   begin
                      SI <= music_data[cntSended - 1];
                      cntSended <= cntSended - 1'b1; 
                      ena <= 1;
                      XDCS <= 1'b0;
                   end
                   else begin      //DREQ拉低，停止传
                       ena <= 1'b0;
                       XDCS <= 1'b1;
                       SI <= 1'b0;
                   end
                  end
                 end
                else;                                           
                 end
                            
            endcase
       end
  end   
  
  blk_mem_gen_0 zero(
      .clka(clk),             // 时钟
      .addra(addra),          // 地址
      .douta(data0)           // 数据输出
      );
  
      blk_mem_gen_1 one (
      .clka(clk),             // 时钟
      .addra(addra),          // 地址
      .douta(data1)           // 数据输出
      );
  
      blk_mem_gen_2 two (
      .clka(clk),             // 时钟
      .addra(addra),          // 地址
      .douta(data2)           // 数据输出
      );
 endmodule                                               