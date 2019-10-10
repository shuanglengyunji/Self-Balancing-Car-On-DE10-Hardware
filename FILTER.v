module FILTER (   
                iCLK,
                iRST_N,                                               
                iDATA_A,
					 iDATA_B,
					 ODATA_A,
					 ODATA_B
               );

input					iCLK;
input					iRST_N;
input					iDATA_A;
input					iDATA_B;
output reg 			ODATA_A; 
output reg 			ODATA_B; 
 
reg		[15:0]  	FILTER_CLK_DIV;
reg					FILTER_CLK;

// Clock Setting
parameter      	CLK_Freq        =       50000000;       //      50      MHz
parameter       	FILTER_Freq     =       15000;          //      15      KHz

/////////////////////   FILTER Clock      ////////////////////////
always@(posedge iCLK or negedge iRST_N)
begin
        if(!iRST_N)
        begin
				FILTER_CLK   <=      0;
				FILTER_CLK_DIV    <=      0;
        end
        else
        begin
				if( FILTER_CLK_DIV < (CLK_Freq/FILTER_Freq/8) )
						FILTER_CLK_DIV    <=      FILTER_CLK_DIV+1;
            else
            begin
						FILTER_CLK_DIV    <=      0;
						FILTER_CLK   <=      ~FILTER_CLK;
            end
        end
end


always@(posedge FILTER_CLK or negedge iRST_N)
begin
        if(!iRST_N)
        begin
					ODATA_A   <=      0;
        end
        else
        begin
				if(iDATA_A)
					ODATA_A    <=     1;
				else
					ODATA_A    <=     0;					
        end
end

always@(posedge FILTER_CLK or negedge iRST_N)
begin
        if(!iRST_N)
        begin
					ODATA_B   <=      0;
        end
        else
        begin
				if(iDATA_B)
					ODATA_B    <=     1;
				else
					ODATA_B    <=     0;					
        end
end

endmodule
