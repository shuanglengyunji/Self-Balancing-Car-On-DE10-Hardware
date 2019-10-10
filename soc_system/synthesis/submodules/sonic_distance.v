module sonic_distance(
		input 				 av_mm_clk,
		input 				 av_mm_rst,
		input 				 av_mm_read,
		input 				 av_mm_cs,
		output	reg[31:0]		 av_mm_readdata,
		input				av_mm_address,
		input 				sonic_echo,
		output 	reg			sonic_trigger
);

reg [21:0]  counter;
reg [21:0]	measure_count;
reg [2:0]   state;

reg [21:0]	measure_value;

always @(posedge av_mm_clk or negedge av_mm_rst)
if(~av_mm_rst)
	counter<=0;
else if(counter==22'h3fffff)
	counter<=0;
else counter<=counter+1;


reg     	    reg_echo;
always @(posedge av_mm_clk or negedge av_mm_rst)
if(~av_mm_rst) 
	reg_echo<=0;
else
	reg_echo<=sonic_echo;
	

reg  [10:0] trig_count;
wire count_rst=(counter==22'h3fffff)?0:1;
always @(posedge av_mm_clk or negedge count_rst)
if(~count_rst)
begin
	measure_count<=0;
	trig_count<=0;
	state<=0;
end
else
begin
	case(state)
	3'd0:begin
			sonic_trigger<=1;
			state<=1;
		end
	3'd1:begin
			if(trig_count==2000)
			begin
				sonic_trigger<=0;
				state<=2;
			end	
			else
			begin
				trig_count<=trig_count+1;
				state<=1;
			end
		end
	3'd2:begin
			if(!reg_echo&sonic_echo)
				state<=3;
			else
				state<=2;
		 end
	3'd3:begin
			if(reg_echo&!sonic_echo)
				state<=4;
			else
			begin
				state<=3;
				measure_count<=measure_count+1;
			end		
		 end
	3'd4:begin
			state<=state;
		 end
	endcase
end

always @(posedge av_mm_clk or negedge av_mm_rst)
if(~av_mm_rst) 
	measure_value<=0;
else if(state==3'd4)
	measure_value<=measure_count;
else
	measure_value<=measure_value;
	

always @(posedge av_mm_clk or negedge av_mm_rst)
if(~av_mm_rst)
begin
	av_mm_readdata<=0;
end
else 
begin
	if(av_mm_cs&&av_mm_read&&av_mm_address==0)
		av_mm_readdata<={10'b0,measure_value};
end	

endmodule