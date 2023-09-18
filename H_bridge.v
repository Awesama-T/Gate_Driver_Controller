//***********************************************************************
//Lowest possible frequency with 16-bit counter & 133 MHz clock is ~2.5 KHz
//DUTY: Maximum DUTY is 100, producing 50% duty_cycle in either PWMs.
//PWM_PERIOD: Given in integer ns
//CLK_PERIOD: Given in integer ns
//DEAD_TIME: Given in integer ns. Its best given in multiples of the clock period                          
//***********************************************************************
module H_bridge #(parameter DUTY = 7'd100, PWM_PERIOD = 40000, DEAD_TIME = 13'd100, CLK_PERIOD = 4'd8)(
output [1:0]pwm_out,
input clk
);

localparam [15:0]CLKS_IN_PWM_PERIOD = (PWM_PERIOD/CLK_PERIOD);
localparam [15:0]CLKS_IN_DEAD_TIME = (DEAD_TIME/CLK_PERIOD);
localparam [15:0]TH_HIGH_0 = ((((CLKS_IN_PWM_PERIOD)*(100-(DUTY/2)))/100) + (CLKS_IN_DEAD_TIME));
localparam [15:0]TH_HIGH_1 = (((TH_HIGH_0-CLKS_IN_DEAD_TIME)/2) - (((CLKS_IN_PWM_PERIOD) - (TH_HIGH_0-CLKS_IN_DEAD_TIME))/2) + (CLKS_IN_DEAD_TIME));
localparam [15:0]TH_LOW_1 = (((TH_HIGH_0-CLKS_IN_DEAD_TIME)/2) + (((CLKS_IN_PWM_PERIOD) - (TH_HIGH_0-CLKS_IN_DEAD_TIME))/2))+1;

//***********************************************************************
//
//  PWM Generator
//
//***********************************************************************
reg [15:0]counter = 0;
always@(posedge clk)
	begin
		counter <= counter + 1;
		if (counter>(CLKS_IN_PWM_PERIOD))
			counter <= 1;
		end
assign pwm_out[0] = (counter>TH_HIGH_0)?1'd1:1'd0;
assign pwm_out[1] = ((counter>TH_HIGH_1) && (counter<TH_LOW_1))?1'd1:1'd0;
endmodule
