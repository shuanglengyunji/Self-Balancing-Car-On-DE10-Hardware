module motor_measure(
	clk,
	reset_n,
	
	s_cs,
	s_write,
	s_read,
	s_address,
	s_writedata,
	s_readdata,
	
	phase_AB
);
	input 			clk;
	input 			reset_n;
	
	input 			s_cs;
	input	 		s_write;
	input 			s_read;
	input [2:0]	    s_address;
	input [31:0]	s_writedata;
	output reg[31:0] 	s_readdata;
	
	input  [1:0]	phase_AB;
`define CNT_ENABLE 1
`define CNT_WRITE 2
`define CNT_READ  0

wire direction;
wire conter_pulse;
reg [15:0] counter;
reg [15:0] cnt_arr;
reg        count_en;
 TERAISC_AB_DECODER u_decoder
(
    .DI_SYSCLK(clk),
    .DI_PHASE_A(phase_AB[0]),
    .DI_PHASE_B(phase_AB[1]),    
    .DO_PULSE(conter_pulse),
    .DO_DIRECT(direction)
);  

always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		cnt_arr<=0;
		count_en<=0;
	end
	else if (s_cs & s_write)
 	begin
		 if(s_address==`CNT_ENABLE)
			count_en<=s_writedata;
	 end  
	else if(s_cs & s_read)
	begin
		if(s_address==`CNT_READ)
			s_readdata<=counter;
	end
end

always @( posedge clk or negedge reset_n)
begin
	if(~reset_n)
		counter<=16'h8000;
	else if(s_cs && s_write && s_address==`CNT_WRITE)
		counter<=s_writedata[15:0];
	else if(count_en && conter_pulse )
	begin
		if(direction)
		begin
			if(counter<16'hffff) 
				counter<=counter+1;
		end
		else if(!direction)
		begin
			 if(counter>0)
				counter<=counter-1;
		end
		else
			counter<=0;
	end
end  

endmodule


module TERAISC_AB_DECODER
(
    DI_SYSCLK,
    DI_PHASE_A,
    DI_PHASE_B,    
    DO_PULSE,
    DO_DIRECT
);

//    input
//
input DI_SYSCLK;
input DI_PHASE_A;
input DI_PHASE_B;

//    output
//
output DO_PULSE;
output DO_DIRECT;

//    register
//
reg DO_PULSE;
wire PULSE_DOUBLE;
reg PULSE_DOUBLE_LAST;
reg DIRECT;
reg DIRECT_PATCH;


//    decode direct from phase A and B
//
always @(posedge DI_PHASE_A) DIRECT <= DI_PHASE_B;
always @(posedge DI_PHASE_B) DIRECT_PATCH <= ~(DIRECT ^ DI_PHASE_A);
assign DO_DIRECT = DIRECT | DIRECT_PATCH;

//    decode pulse from phase A and B
//
assign PULSE_DOUBLE = DI_PHASE_A ^ DI_PHASE_B;

always @(posedge DI_SYSCLK) 
begin
    if(PULSE_DOUBLE != PULSE_DOUBLE_LAST) 
	begin
        DO_PULSE <= 1'b1;
        PULSE_DOUBLE_LAST <= PULSE_DOUBLE;
    end
    else begin
        DO_PULSE <= 1'b0;
    end
    
end

endmodule

