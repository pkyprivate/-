module BlueTooth_command(
	input clk,
	input rst,
	input RXD,
	output reg [15: 0] volume,
	output reg [2: 0] current
);

	parameter DELAY_TIME = 5000000;
	integer cnt = 0;
	wire flag;
	wire [7: 0] data;
	uart_deal ud(.clk(clk), .rst(rst), .RXD(RXD), .uart_state(flag), .DATA(data));
	// the phone actually send message like B100 to let data keep 00 after change the sign.
	always @ (posedge clk) begin
		if(cnt==DELAY_TIME)
			case(data) 
				8'hB1: begin 
						current <= (current==0) ? 2: current-1;
						cnt <= 0;
					end
				8'hB2: begin 
						current <= (current==3) ? 0: current+1;
						cnt <= 0;
					end
				8'hB3: begin 
						volume <= (volume==0) ? 0: (volume - 16'h1010);
						cnt <= 0;
					end
				8'hB4: begin 
						volume <= (volume==16'hF0F0) ? 16'hF0F0 : (volume + 16'h1010);
						cnt <= 0;
					end
				8'h0: begin
						current<= 0;
						cnt <= 0;
					end 
				8'h1: begin
						current <= 1;
						cnt <= 0;
					end 
				8'h2: begin
						current <= 2;
						cnt <= 0;
					end 
				8'h3: begin
						current <= 3;
						cnt <= 0;
					end
			   8'h4: begin
                        current <= 4;
                        cnt <= 0;
                         end
				default: ;
			endcase
		else cnt <= cnt+1;
	end
endmodule