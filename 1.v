
module infra_red (

);
	
	always @(posedge clk)  // clk : 20 ns = 1/50 us 
	begin
		state <= next_state;
	end

endmodule

