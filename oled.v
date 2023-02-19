module oled(
	input clk, 
	input rst,
	input [3: 0] current,
	output reg DIN, // input pin 
	output reg OLED_CLK, 
	output reg CS, // chip select
	output reg DC, // Data & CMD 
	output reg RES
);
	parameter DELAY_TIME = 25000;
	
	// DC parameter
	parameter CMD = 1'b0;
	parameter DATA = 1'b1;
	
	// init cmds
	reg [383:0] cmds;
	initial
		begin
			cmds= {
			8'hAE, 8'hA0, 8'h76, 8'hA1, 8'h00, 8'hA2,
			8'h00, 8'hA4, 8'hA8, 8'h3F, 8'hAD, 8'h8E, 
			8'hB0, 8'h0B, 8'hB1, 8'h31, 8'hB3, 8'hF0,
			8'h8A, 8'h64, 8'h8B, 8'h78, 8'h8C, 8'h64,
			8'hBB, 8'h3A, 8'hBE, 8'h3E, 8'h87, 8'h06,
			8'h81, 8'h91, 8'h82, 8'h50, 8'h83, 8'h7D, 
			8'h15, 8'h00, 8'h5F, 8'h75, 8'h00, 8'h3F, 
			8'haf, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; 
		end
	
	// states
	parameter CMD_PRE = 0;
	parameter CMD_PRE_WRITE = 1;
	parameter DATA_PRE_WRITE = 2;
	parameter CMD_WRITE = 3;
	parameter DATA_PRE = 4;
	parameter DATA_WRITE=5;
	wire CLK;
    Divider #(.Time(50)) divider(clk, CLK);
	
    wire [1535:0] map;
    reg [5: 0] addra;
   
	reg [1535:0] temp;
	reg [15: 0] cmd_cnt;
	reg [7: 0] data_reg;
	reg [3: 0] state;
	integer cnt = 0;
	integer write_cnt = 0;
	
	// state machine
	always @ (posedge CLK) begin 
		if(!rst) begin 
			state <= CMD_PRE;
			cmd_cnt <= 0;
			CS <= 1'b1;
			RES <= 0;
		end
		else begin 
			RES <= 1;
			case(state)
				CMD_PRE: 
				begin 
					temp <= cmds;
					state <= CMD_PRE_WRITE;
					write_cnt <= 48;
					DC <= CMD;
				end
				// prepare for data write 
				DATA_PRE: 
				begin 
						if(cmd_cnt == 64) 
						begin 
							cmd_cnt <= 0;
							state <= DATA_PRE;
						end
						else 
						begin 
							temp<=map;
							state <= DATA_PRE_WRITE;
							write_cnt <= 192;
							DC <= DATA;
						end
					end
				// cut temp into several 8bits regs
				CMD_PRE_WRITE: 
				begin 
					if(write_cnt == 0) 
					begin 
						 cmd_cnt<=0;
					     addra <= 0;
						 state <= DATA_PRE;
					end
					else 
					begin 
						data_reg[7: 0] <= temp[383: 376];
						temp <= {temp[375: 0], temp[383: 376]};
						state <= CMD_WRITE;
						OLED_CLK <= 0;
						cnt <= 8;
					end
				end
			    DATA_PRE_WRITE: 
                     begin 
                     if(write_cnt == 0) 
                         begin 
                           cmd_cnt <= cmd_cnt+1;
                           addra <= addra+1;
                           state <= DATA_PRE;
                         end
                         else 
                         begin 
                            data_reg[7: 0] <=  temp[1535: 1528];
                            temp <= {temp[1527: 0], temp[1535: 1528]};
                            state <= DATA_WRITE;
                            OLED_CLK <= 0;
                            cnt <= 8;
                          end
                      end
				// shift 8bits into DIN port
				CMD_WRITE: 
				begin 
						if(OLED_CLK) 
						begin 
							if(cnt == 0) 
							begin 
								CS <= 1;
								write_cnt <= write_cnt-1;
								state <= CMD_PRE_WRITE;
							end
							else 
							begin 
								CS <= 0;
								DIN <= data_reg[cnt-1];
								cnt <= cnt-1;
							end
						end
						OLED_CLK <= ~OLED_CLK;
					end
				DATA_WRITE: 
                    begin 
                    if(OLED_CLK) 
                      begin 
                      if(cnt == 0) 
                      begin 
                         CS <= 1;
                         write_cnt <= write_cnt-1;
                         state <= DATA_PRE_WRITE;
                      end
                      else 
                      begin 
                        CS <= 0;
                        DIN <= data_reg[cnt-1];
                        cnt <= cnt-1;
                      end
                     end
                  OLED_CLK <= ~OLED_CLK;
                 end
				default:;
			endcase
		end
	end 
   blk_mem_gen_3 your_instance_name(.clka(CLK),.addra({current,addra}),.douta(map));
endmodule
