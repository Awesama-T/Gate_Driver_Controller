///******************************************************************
//Generates tick on Nth clock cycle repeatedly.  
//tick: 
//timer_en:
//dead_time_clks: Dead time specified in clocks. dead_time_clks = dead-time(ns)/system clock's period(ns)
//******************************************************************

module timer #(parameter N=13)( 
output reg [N-1:0]r_reg,
input clk, reset
); 

wire [N-1:0]r_next; 
always@(posedge clk or posedge reset) 
	begin 
		if (reset) 
			r_reg <=0; 
		else  
			r_reg <= r_next;  

	end 

assign r_next = r_reg+1; 
endmodule 
