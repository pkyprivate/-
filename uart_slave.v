module uart_deal(
	input clk,
	input rst,
    input RXD,
	output uart_state,
	output reg [7: 0] DATA
);
	parameter bps = 10417;
	reg UART_RX_sync, UART_RX_sync1, UART_RX_sync2;
	reg buffer_0,buffer_1,buffer_2;//³ıÈ¥ÂË²¨
	wire posedge_out;
	reg uart_state;
	reg [15: 0] cnt_unit;
	reg [3:0] cnt_eight;
	
	// asynchronous data in 
	always @ (posedge clk) begin
		if(!rst) begin 
			buffer_0 <= 1'b1;
			buffer_1 <= 1'b1;
			buffer_2 <= 1'b1;
		end
		else begin 
			buffer_0 <= RXD;
			buffer_1 <= buffer_0;
			buffer_2 <= buffer_1;
		end
	end
	
	// detect posedge
	assign posedge_out = ~buffer_1 & buffer_2;
	
	// bps cycle count
	always @ (posedge clk) begin 
		if(!rst) begin 
			cnt_unit <= 0;
		end 
		else if(uart_state) begin 
			if(cnt_unit == bps-1) begin 
				cnt_unit <= 0;
			end
			else begin 
				cnt_unit <= cnt_unit+1;
			end
		end
	end
	
	// receive data bits count
	always @ (posedge clk) begin 
		if(!rst) begin 
			cnt_eight<= 0;
		end
		else if(uart_state && cnt_unit==bps-1) begin
			if(cnt_eight== 8) begin 
				cnt_eight <= 0;
			end
			else begin 
				cnt_eight <= cnt_eight+1;
			end
		end
	end
	
	// uart_state sign generate
	always @ (posedge clk) begin 
		if(!rst) begin 
			uart_state <= 0;
		end
		else if(posedge_out) begin 
			uart_state <= 1;
		end
		else if(uart_state && cnt_eight==8 && cnt_unit==bps-1) begin
			uart_state <= 0;
		end
	end
	
	// data in 
	always @ (posedge clk) begin 
		if(!rst) begin 
			DATA <= 0;
		end
		if(uart_state && cnt_unit==bps/2-1 && cnt_eight!=0) begin
			DATA[cnt_eight-1] <= RXD;
		end
	end
	
endmodule