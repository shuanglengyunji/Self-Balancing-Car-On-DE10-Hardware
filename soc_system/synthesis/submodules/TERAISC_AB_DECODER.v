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
reg PULSE_DOUBLE;
reg PULSE_DOUBLE_LAST;
reg DIRECT;
reg DIRECT_PATCH;


//    decode direct from phase A and B
//
always @(posedge DI_PHASE_A) DIRECT = DI_PHASE_B;
always @(posedge DI_PHASE_B) DIRECT_PATCH = ~(DIRECT ^ DI_PHASE_A);
assign DO_DIRECT = DIRECT | DIRECT_PATCH;

//    decode pulse from phase A and B
//
always PULSE_DOUBLE = DI_PHASE_A ^ DI_PHASE_B;

always @(posedge DI_SYSCLK) 
begin
    if(PULSE_DOUBLE != PULSE_DOUBLE_LAST) 
	begin
        DO_PULSE = 1'b1;
        PULSE_DOUBLE_LAST = PULSE_DOUBLE;
    end
    else begin
        DO_PULSE = 1'b0;
    end
    
end

endmodule
