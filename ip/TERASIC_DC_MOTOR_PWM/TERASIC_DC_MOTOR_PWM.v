module TERASIC_DC_MOTOR_PWM(
	input						clk,
	input						reset_n,
	//
	input						s_cs,
	input		[1:0]			s_address,
	input						s_write,
	input		[31:0]			s_writedata,
	input						s_read,
	output reg	[31:0]			s_readdata,
	
	//
	output	reg					PWM,
	output	reg					DC_MOTOR_IN1,
	output	reg					DC_MOTOR_IN2
);


`define REG_TOTAL_DUR	2'd0
`define REG_HIGH_DUR	2'd1
`define REG_CONTROL		2'd2


////////////////////////////////////////
// MM Port
reg	motor_go;
reg	motor_forward;
reg	motor_fast_decay;

always @(posedge clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		// PWM
		high_dur <= 0;
		total_dur <= 0;
		
		// MOTOR
		motor_go <= 1'b0;
		motor_forward <= 1'b1;
		motor_fast_decay <= 1'b1;
	end
	else if (s_cs && (s_address == `REG_CONTROL))
	begin
		if (s_write)
			{motor_fast_decay, motor_forward, motor_go} <= s_writedata[2:0];
		else if (s_read)
			s_readdata <= {29'b0, motor_fast_decay, motor_forward, motor_go};
	end
	else if (s_cs & s_write)
	begin
		if (s_address == `REG_TOTAL_DUR)
			total_dur <= s_writedata;
		else if (s_address == `REG_HIGH_DUR)
			high_dur <= s_writedata;
	end
	else if (s_cs & s_read)
	begin
		if (s_address == `REG_TOTAL_DUR)
			s_readdata <= total_dur;
		else if (s_address == `REG_HIGH_DUR)
			s_readdata <= high_dur;
	end	
end



////////////////////////////////////////


always @(*)
begin
	if (motor_fast_decay)
	begin  
		// fast decay
		if (motor_go)
		begin
			if (motor_forward)
				{DC_MOTOR_IN2, DC_MOTOR_IN1,PWM} <= {1'b1, 1'b0,PWM_OUT}; // forward
			else
				{DC_MOTOR_IN2, DC_MOTOR_IN1,PWM} <= {1'b0, 1'b1,PWM_OUT}; // reverse
		end
		else
			{DC_MOTOR_IN2, DC_MOTOR_IN1,PWM} <= {1'b1, 1'b1,1'b0};
	end
	else
	begin 
		// slow decay
		if (motor_go)
		begin
			if (motor_forward)
				{DC_MOTOR_IN2, DC_MOTOR_IN1,PWM} <= {1'b1, 1'b0,PWM_OUT}; // forward
			else
				{DC_MOTOR_IN2, DC_MOTOR_IN1,PWM} <= {1'b0, 1'b1,PWM_OUT}; // reverse
		end
		else
			{DC_MOTOR_IN2, DC_MOTOR_IN1,PWM} <= {1'b0, 1'b0,1'b0};	
	end
end


////////////////////////////////////////
// PWM

reg			PWM_OUT;
reg	[31:0]	total_dur;
reg	[31:0]	high_dur;
reg	[31:0]	tick;

always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		tick <= 1;
	end
	else if (tick >= total_dur)
	begin
		tick <= 1;
	end
	else
		tick <= tick + 1;
end

always @ (posedge clk)
begin
		PWM_OUT <= (tick <= high_dur)?1'b1:1'b0;
end





endmodule
