module DEAD_TIME #(parameter N = 12) (
output wire [1:0]pwm_out,
input pwm_in,
input [N-1:0]dead_time_clks,
input clk
);

//////////////////////////////////////////////////Edge Detector/////////////////////////
reg 				current ;
reg 				next;
wire 				pe, ne;
always@(posedge clk)
	begin
	current <= pwm_in;
	next <= current	;
		end
assign pe = (current & ~next);
assign ne = (~current & next); 
//*************************************************************************************\//

////////////////////////////////////////////////Counter////////////////////////////////////
wire 					reset;
reg [N-1:0]			counter;

always@(posedge clk) 
	begin 
		if (reset) 
			counter <= 0; 
		else  
			counter <= counter +1;  
	end 
//*************************************************************************************\//

////////////////////////////////////////////////Dead Time Logic///////////////////////////
reg 				flag1;
reg 				flag2;
reg 				flag3;
reg 				flag4;

always@(posedge clk)
	begin
		if(pe==1'd1)
			begin
				flag1 <= 1;
				flag2 <= 0;
				flag4 <= 0;
				end
				else if((flag1==1) && counter>dead_time_clks)
			begin
				flag3 <= 1;
				end
				else if((flag2==1) && counter>dead_time_clks)
			begin     
				flag4 <= 1;
				end
				
		if (ne==1'd1)
			begin
				flag1 <= 0;
				flag2 <= 1;
				flag3 <= 0;
				end
				
		
		
	end
assign reset = (pe | ne)?1'd1:1'd0;
assign pwm_out[0] = flag3?1'd1: 1'd0;
assign pwm_out[1] = flag4?1'd1: 1'd0;
//*************************************************************************************\//

endmodule
