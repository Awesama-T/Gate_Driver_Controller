module MAIN_CONTROLLER #(parameter 
//***********************************************************************
//  Modify the Below Parameters as Desired
//***********************************************************************
CLK_PERIOD = 						8,				// Clock Period of the FPGA Clock (ns)
DUTY_H= 							100,			// Combined Duty-cycle of the H-bridge PWMs Specified in % (0% - 100%)
PWM_PERIOD_H = 						500_000,		// Time-period of the H-bridge PWMs Specified In ns (2KHz - 2MHz) OR (500,000ns - 500ns)
DEAD_TIME_H = 						100,			// Dead-time between the H-bridge PWMs Specified in ns (0ns - 5000ns)
//***********************************************************************
//  Modify the Below Parameters Only if Required
//***********************************************************************
ADC_WIDTH = 						9,             	// ADC Width (bits)
ACCUM_BITS = 						9,            	// 2^ACCUM_BITS is decimation rate of accumulator (bits)
LPF_DEPTH_BITS = 					10,         	// 2^LPF_DEPTH_BITS is decimation rate of averager (bits)
N = 								12				// N=12 Will Work For System Clock With Period Greater Than or Equal To 5 ns, Else Increase It
) 

(
output[ADC_WIDTH-1:0]			digital_out,
output							analog_out,
output[5:0]					pwm_out,
output[1:0]					pwm_out_H_bridge,
input							analog_cmp,	
input							en_deadtime,
input[5:0]						pwm_in
);

//***********************************************************************
//
//  Internal Oscialltor
// //  Some Compatible Frequencies (MHz): 133, 88.67, 53.20, 19, 14, 7
//***********************************************************************
wire clk;
OSCH #(133.00) inst (.STDBY(1'b0), .OSC(clk), .SEDSTDBY());
//***********************************************************************
//
//  ADC
//  
//***********************************************************************
wire  							sample_rdy;
wire							analog_out_i;
wire [ADC_WIDTH-1:0]			digital_out_abs;
reg [N-1:0]					dead_time_in_clks;
wire [5:0] 					pwm_out_i;
reg [ADC_WIDTH-1:0]			digital_out_stable;
ADC #(
	.ADC_WIDTH(ADC_WIDTH),
	.ACCUM_BITS(ACCUM_BITS),
	.LPF_DEPTH_BITS(LPF_DEPTH_BITS)
	)
SSD_ADC(
	.clk(clk),
	.analog_cmp(analog_cmp),
	.digital_out(digital_out_abs),
	.analog_out(analog_out_i),
	.sample_rdy(sample_rdy)
	);
	
assign digital_out   = ~digital_out_stable;	 // invert bits for LED display 
assign analog_out    =  analog_out_i;
assign pwm_out = en_deadtime?pwm_out_i: pwm_in;

reg [13:0] temp1;
reg [13:0] temp2;

always@(posedge clk)
	begin
		if(sample_rdy == 1)
			begin
			digital_out_stable <= digital_out_abs;
			end
		temp1 <= ((digital_out_stable)*10);
		temp2 <= temp1+100;
		dead_time_in_clks <= (temp2/CLK_PERIOD); 
	end	
	
//***********************************************************************
//
//  Dead time
//
//  Dead Time Range: 100 ns - 5000 ns
//***********************************************************************
DEAD_TIME #(.N(N))inst1(pwm_out_i[1:0],pwm_in[0],dead_time_in_clks,clk);
DEAD_TIME #(.N(N))inst2(pwm_out_i[3:2],pwm_in[2],dead_time_in_clks,clk);
DEAD_TIME #(.N(N))inst3(pwm_out_i[5:4],pwm_in[4],dead_time_in_clks,clk);
//***********************************************************************
//
//  H-bridge
//
//***********************************************************************
H_bridge #(.DUTY(DUTY_H), .PWM_PERIOD(PWM_PERIOD_H), .DEAD_TIME(DEAD_TIME_H), .CLK_PERIOD(CLK_PERIOD)) 
inst4(pwm_out_H_bridge,clk);

endmodule

