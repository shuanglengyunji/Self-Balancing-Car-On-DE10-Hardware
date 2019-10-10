
module infra_red (
	input 			clk,
	input 			rst_n,
	output 	[7:0] 	To_HPS,
	inout 	[7:0] 	To_GPIO
);
	
	// ----------------------------------

	// State:
	// OUT 		- 0			Wait1	- 1			IN 		- 2
	// Wait2 	- 3			TEST 	- 4
	
	// Direction:
	// OUT		- 1			Infinite - 0 
	
	reg [2:0] state,next_state;
	reg direction;
	reg [7:0] data_reg, data_reg1;
	
	assign To_HPS = data_reg1;
	assign To_GPIO = direction ? 8'b1111_1111 : 8'bz;
	
	always @(posedge clk)
	begin
		if (rst_n == 0)
			data_reg1 = 8'b0;
		else
			data_reg1 <= data_reg;
	end
	
	always @(posedge clk)  // clk : 20 ns = 1/50 us 
	begin
		if (rst_n == 0)
		begin
			data_reg <= 8'b0;
			direction <= 1;
		end
		else if (state == 0)		// 0 - 输出电平
		begin
			direction <= 1;
			data_reg <= data_reg;
		end
		else if (state == 1)	// 1 - 保持电平
		begin
			direction <= 1;
			data_reg <= data_reg;
		end
		else if (state == 2)	// 2 - 切换为高阻态
		begin
			direction <= 0;
			data_reg <= data_reg;
		end
		else if (state == 3)	// 3 - 保持高阻态
		begin
			direction <= 0;
			data_reg <= data_reg;
		end
		else if (state == 4)	// 4 - 读取数据（保持高阻态）
		begin
			direction <= 0;
			data_reg <= To_GPIO;
		end
		else
		begin
			direction <= 0;
			data_reg <= data_reg;
		end
	end
	
	always @(posedge clk)  // clk : 20 ns = 1/50 us 
	begin
		state <= next_state;
	end
	
	reg [31:0] counter;
	always @(posedge clk)  // clk : 20 ns = 1/50 us 
	begin
		if ( rst_n == 0 || counter >= 10503)		// counter的周期为1/50 us	(0 - 5503)
		begin 
			counter <= 0;
		end
		else
		begin
			counter <= counter + 1;
		end
	end
	
	always @(counter)
	begin
		if (counter == 0)								// 0
			next_state <= 0;
		else if (counter >= 1 && counter <= 500)		// 1-500
			next_state <= 1;
		else if (counter == 501)						// 501
			next_state <= 2;
		else if (counter >= 502 && counter <= 10502)		// 502 - 5502
			next_state <= 3;
		else if (counter == 10503)
			next_state <= 4;
		else
			next_state <= next_state;
	end

endmodule

