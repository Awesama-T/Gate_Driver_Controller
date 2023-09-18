//***********************************************************************
//
//  ADC
//  Hardware Setup comprises of 680 pF cap & 18 kO resistor
//  
//***********************************************************************
module ADC (
	clk,                                     
	digital_out,            
	analog_cmp,	            
	analog_out,             
	sample_rdy);            

parameter 
ADC_WIDTH = 8,              // ADC Convertor Bit Precision
ACCUM_BITS = 10,            // 2^ACCUM_BITS is decimation rate of accumulator
LPF_DEPTH_BITS = 3;         // 2^LPF_DEPTH_BITS is decimation rate of averager

//input ports
input	clk;                            // sample rate clock
input	analog_cmp ;                    // input from LVDS buffer (comparitor)

//output ports
output	analog_out;                     // feedback to comparitor input RC circuit
output  sample_rdy;                     // digital_out is ready
output [ADC_WIDTH-1:0]	digital_out;    // digital output word of ADC


//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
reg                         delta;          // captured comparitor output
reg [ACCUM_BITS-1:0]	    sigma;          // running accumulator value
reg [ADC_WIDTH-1:0]	    accum;          // latched accumulator value
reg [ACCUM_BITS-1:0]	    counter;        // decimation counter for accumulator
reg							rollover;       // decimation counter terminal count
reg							accum_rdy;      // latched accumulator value 'ready' 

//***********************************************************************
//
//  SSD 'Analog' Input - PWM
//
//	External Comparator Generates High/Low Value
//
//***********************************************************************

always @ (posedge clk)
begin
    delta <= analog_cmp;        // capture comparitor output
end

assign analog_out = delta;      // feedback to comparitor LPF

//***********************************************************************
//
//  Accumulator Stage
//
//	Adds PWM positive pulses over accumulator period
//
//***********************************************************************

always @ (posedge clk)
begin
        if (rollover) begin
            // latch top ADC_WIDTH bits of sigma accumulator (drop LSBs)
            accum <= sigma[ACCUM_BITS-1:ACCUM_BITS-ADC_WIDTH];
            sigma <= delta;         // reset accumulator, prime with current delta value
        end else begin
            if (&sigma != 1'b1)         // if not saturated
                sigma <= sigma + delta; // accumulate 
        end
        accum_rdy <= rollover;     // latch 'rdy' (to align with accum)
end
//***********************************************************************
//
//  Box filter Average
//
//	Acts as simple decimating Low-Pass Filter
//
//***********************************************************************

BOX_AVE #(
    .ADC_WIDTH(ADC_WIDTH),
    .LPF_DEPTH_BITS(LPF_DEPTH_BITS))
box_ave (
    .clk(clk),
    .sample(accum_rdy),
    .raw_data_in(accum),
    .ave_data_out(digital_out),
    .data_out_valid(sample_rdy)
);

//************************************************************************
//
// Sample Control - Accumulator Timing
//	
//************************************************************************

always @(posedge clk)
begin
		counter <= counter + 1;       // running count
		rollover <= &counter;         // assert 'rollover' when counter is all 1's
end

endmodule
