module mp3(
    input       clk,             //2MH
    input       rst,            //MCU����������
    input       play,           //��ʼ����ʼ��������
    input       SO,             //MP3�Ĵ����ź�
    input       DREQ,           //���������������󣬸ߵ�ƽʱ�ɴ�������
    input       [2:0]current,  //����id
    input       [15:0]volume,
    output reg  XCS,            //SCI �����дָ��
    output reg  XDCS,           //SDI ��������
    output      SCK,            //MP3ʱ��
    output reg  SI,             //mp3�Ĵ����ź�
    output reg  XRESET         //Ӳ����λ���͵�ƽ��Ч
    );
    //����MP3״̬��
    parameter           H_RESET    = 0;      //Ӳ��λ
    parameter           S_RESET     = 1;     //��λ
    parameter           SET_CLOCKF  = 2 ;    //����ʱ�ӼĴ���
    parameter           SET_BASS    = 3 ;    //���������Ĵ���
    parameter           VOL_PRE     = 4 ;    //���ø�������
    parameter           SET_VOL     = 5;     //���������Ĵ���
    parameter           WAITE       = 6;     //�ȴ�
    parameter           PLAY        = 7;     //����
    parameter           END         = 8;     //����
    
    reg [3:0]       state       = WAITE;            //state״̬
    reg [31:0]      waiting_time     = 32'd0;     //��ʱ���в���
    reg [31:0]      SCI_cmd       = 32'd0;            //ָ���ַ 
    reg [7:0]       cntData   = 8'd32;            //SCIָ���ַλ������

    reg [31:0]      music_data     = 32'd0;           //��������
    reg [31:0]      cntSended     = 32'd32;           //SDI���Ѿ����͵�����λ��

    reg [16:0]      addra       = 16'd0;            //ROM�еĵ�ַ
    wire [31:0]     data0;                          //ROM����
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
                    //----------------�ȴ�--------------//
                    WAITE:begin
                    if(waiting_time > 0)
                        waiting_time <= waiting_time - 1;
                    //ת��Ӳ��λ
                    else begin
                        waiting_time <= 32'd2000;
                        state <= H_RESET;
                    end
                    end
                    //-----------------Ӳ��λ-------------//
                    H_RESET:begin
                    if(waiting_time> 0)
                        waiting_time<= waiting_time- 1;
                    else begin
                        XCS <= 1'b1;
                        XRESET <= 1'b0;
                        waiting_time <= 32'd10000;        //��λ����ʱһ��ʱ                                      
                        SCI_cmd  <= 32'h02_00_08_04;      //��λָ��
                        cntData <= 8'd32;                 //ָ��ء����ݳ���
                        state <= S_RESET;                 //ת�Ƶ���λ
                    end
                    end
                   //------------��λ----------------//
                   S_RESET:begin
                   if(waiting_time > 0) 
                   begin
                      XRESET <= 1;
                      waiting_time <= waiting_time - 1'b1;
                   end
                   else if(cntData == 0) //��λ����
                   begin           
                      waiting_time <= 32'd10000;
                      cntData <= 8'd32;
                      SCI_cmd <= 32'h02_02_00_00;
                      state <= SET_BASS;
                      XCS <= 1'b1;                        
                      ena <= 1'b0;                        //�ر�����ʱ��
                      SI <= 1'b0;
                    end
                   else if(DREQ)                           //��DREQ��Чʱ��ʼ��λ
                   begin                     
                      XCS <= 1'b0;
                      ena <= 1'b1;
                      SI <=  SCI_cmd [cntData - 1];
                      cntData <= cntData -1;
                   end
                   else begin
                      XCS <= 1'b1;                        //DREQ��Чʱ�ȴ�
                      ena <= 1'b0;
                      SI <= 1'b0;
                   end 
                   end            
                    //------���������ź�--------//
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
                    begin                     //д��SCIָ���ַ����
                       XCS <= 1'b0;
                       ena <= 1'b1;
                       SI <=  SCI_cmd [cntData - 1];
                       cntData <= cntData - 1'b1;
                    end
                    else begin                    //�ȴ��ź�DREQ
                       XCS <= 1'b1;
                       ena <= 1'b0;
                       SI <= 1'b0;
                    end
                    end
                   //--------���������ź�-----------//
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
                    begin                     //д��SCIָ���ַ����
                       XCS <= 1'b0;
                       ena <= 1'b1;
                       SI <=  SCI_cmd [cntData - 1];
                       cntData <= cntData - 1'b1;
                    end
                    else begin                 //�ȴ��ź�DREQ
                       XCS <= 1'b1;
                       ena <= 1'b0;
                       SI <= 1'b0;
                    end
                  end
                   //--------����ʱ���ź�-----------//
                    SET_CLOCKF:begin
                  if(waiting_time > 0)
                     waiting_time <=waiting_time -1;
                  else if(cntData == 0) 
                  begin
                     waiting_time <= 2000;
                     state <= VOL_PRE;                   //ת�Ƶ�����VOL
                     cntData <= 8'd32;
                     XCS <= 1'b1;
                     ena <= 1'b0;
                     SI <= 1'b0;
                  end
                  else if(DREQ)       
                  begin                    //д��SCIָ���ַ����
                     XCS <= 1'b0;
                     ena <= 1'b1;
                     SI <=  SCI_cmd [cntData - 1];
                     cntData <= cntData - 1'b1;
                  end
                  else begin              //�ȴ��ź�DREQ
                     XCS <= 1'b1;
                     ena <= 1'b0;
                     SI <= 1'b0;
                     end
                  end 
                   //----------�ı�����----------//
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
                //----------��������----------//
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
                      XDCS <= 1'b1;                   //����XDCS
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
                   //��DREQ��Ч ��ǰ�ֽ���δ������ �������
                   if(DREQ || (cntSended != 32 && cntSended != 24 && cntSended != 16 && cntSended != 8)) 
                   begin
                      SI <= music_data[cntSended - 1];
                      cntSended <= cntSended - 1'b1; 
                      ena <= 1;
                      XDCS <= 1'b0;
                   end
                   else begin      //DREQ���ͣ�ֹͣ��
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
      .clka(clk),             // ʱ��
      .addra(addra),          // ��ַ
      .douta(data0)           // �������
      );
  
      blk_mem_gen_1 one (
      .clka(clk),             // ʱ��
      .addra(addra),          // ��ַ
      .douta(data1)           // �������
      );
  
      blk_mem_gen_2 two (
      .clka(clk),             // ʱ��
      .addra(addra),          // ��ַ
      .douta(data2)           // �������
      );
 endmodule                                               