module BOX_AVE (
	clk,
	sample,
	raw_data_in,
	ave_data_out,
    data_out_valid);

parameter 
ADC_WIDTH = 8,				// ADC Convertor Bit Precision
LPF_DEPTH_BITS = 4;         // 2^LPF_DEPTH_BITS is decimation rate of averager

//input ports
input	clk;                                // sample rate clock
input	sample;				                // raw_data_in is good on rising edge, 
input	[ADC_WIDTH-1:0]	raw_data_in;		// raw_data input

//output ports
output [ADC_WIDTH-1:0]	ave_data_out;		// ave data output
output data_out_valid;                      // ave_data_out is valid, single pulse

reg [ADC_WIDTH-1:0]	ave_data_out;		
//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
reg [ADC_WIDTH+LPF_DEPTH_BITS-1:0]      accum;          // accumulator
reg [LPF_DEPTH_BITS-1:0]                count;          // decimation count
reg [ADC_WIDTH-1:0]  					raw_data_d1;    // pipeline register

reg sample_d1, sample_d2;                               // pipeline registers
reg result_valid;                                       // accumulator result 'valid'
wire accumulate;                                        // sample rising edge detected
wire latch_result;                                      // latch accumulator result

//***********************************************************************
//
//  Rising Edge Detection and data alignment pipelines
//
//***********************************************************************
always @(posedge clk)
begin
		sample_d1 <= sample;                // capture 'sample' input
		sample_d2 <= sample_d1;             // delay for edge detection
		raw_data_d1 <= raw_data_in; 	    // pipeline 
		result_valid <= latch_result;		// pipeline for alignment with result
end

assign		accumulate = sample_d1 && !sample_d2;	    // 'sample' rising_edge detect
assign		latch_result = accumulate && (count == 0);	// latch accum. per decimation count

//***********************************************************************
//
//  Accumulator Depth counter
//
//***********************************************************************
always @(posedge clk)
begin
	    if (accumulate)	count <= count + 1;         // incr. count per each sample
end
//***********************************************************************
//
//  Accumulator
//
//***********************************************************************
always @(posedge clk)
begin
        if (accumulate)
            if(count == 0)                      // reset accumulator
    		    accum <= raw_data_d1;           // prime with first value
            else
                accum <= accum + raw_data_d1;   // accumulate	
end
	
//***********************************************************************
//
//  Latch Result
//
//  ave = (summation of 'n' samples)/'n'  is right shift when 'n' is power of two
//
//***********************************************************************
always @(posedge clk)
begin
	if (latch_result) begin            // at end of decimation period...
        ave_data_out <= accum >> LPF_DEPTH_BITS;	  // ... save accumulator/n result
    end
end

assign data_out_valid = result_valid;       // output assignment

endmodule
