module wave_capture (
    input clk,
    input reset,
    input new_sample_ready,
    input [15:0] new_sample_in,
    input wave_display_idle,

    output wire [8:0] write_address,
    output wire write_enable,
    output wire [7:0] write_sample,
    output wire read_index
);
	//Wires representing the current sample and the previous sample
	wire[15:0] yprev, ycurr;

	// two dffre's for latching the the sample value and storing the previous one
	dffre #(16) LATCH_SAMPLE_1(
		.clk (clk),
		.r (reset), .en(new_sample_ready),
		.d (ycurr), .q (yprev)
	);
	dffre #(16) LATCH_SAMPLE_2(
		.clk (clk),
		.r (reset), .en(new_sample_ready),
		.d (new_sample_in), .q (ycurr)
	);

	wire [1:0] state, next; //A 2 bit number for state: 00 = armed, 01 = active, 11 = wait
	reg [1:0] next1;	
	reg [7:0] counter;

	dffr #(2) STATE_FF(
		.clk (clk),
		.r (reset),
		.d (next), .q (state)
	);

	//temporary regs for use in the always block
	reg [8:0] output_address;
	reg output_enable;
	reg [7:0] output_sample;
	reg output_index;
	
	always@(*) begin

		//Reset values
		output_index = reset ? 1'b0 : output_index;
		if (reset) begin
			output_index = 1'b0;
			output_address = 9'b0;
			output_enable = 1'b0;
			output_sample = 8'b0;
			next1 = 3'd0;
			counter = 8'd0;
		end else begin
				case(state) 
				
				//ARMED
				2'b00: begin		
					//$display("State: %b", state);			
					counter = 8'b00000000;	//reset counter
					//Go active if a the sample crosses zero
					next1 = ((ycurr[15] == 0 && yprev[15] == 1)) ? 2'b01 : 2'b00;	
					output_enable = 1'b0;	//Don't write yet		
					output_address = 9'b0;
					output_sample = 8'b0;
					output_index = read_index_prev;
					end

				//ACTIVE
				2'b01: begin		
					//$display("State: %b", state);
					output_enable = new_sample_ready ? 1'b1 : 1'b0;	//Start writing
					 
					output_index = read_index_prev;
					output_address = {~read_index_prev, counter};	//Assign address
					output_sample = (counter_prev == 0) ? 8'd128 : (ycurr[15:8] + 8'b10000000);	//Assign sample, shift number over by 128 to make the number positive
					

					next1 = (counter_prev == 8'b11111111) ? 2'b11 : 2'b01;	//Go to wait if counter is 255
					//next1 = (counter_prev == 8'b100) ? 2'b11 : 2'b01;	//Go to wait if counter is 4 (FOR TESTING ONLY)

					counter = new_sample_ready ? (counter_prev + 8'b1) : (counter_prev);	//Increment counter
					end

				//WAIT
				default: begin		
					//$display("State: %b", state);
					output_enable = 1'b0;		//Stop writing
					output_address = 9'b0;		//reset address
					output_sample = 8'b0;		//reset output
					
					next1 = wave_display_idle ? 2'b00 : 2'b11;	//Go armed if wave display is idle
					output_index = wave_display_idle ? ~read_index_prev : read_index_prev;	//invert read_index
					counter = 8'd0;
				end
			endcase
		end
	end

	assign next = reset ? 2'b00 : next1; //reset state
	
	//assign outputs	
	assign write_address = output_address;
	assign write_enable = output_enable;
	assign write_sample = output_sample;
	assign read_index = reset ? 1'b0 : output_index;
	 

	// delay Flip FLops
	wire read_index_prev;	
	dffr #(1) READ_INDEX_FF(.clk (clk), .r (reset), .d (read_index), .q (read_index_prev));
	
	wire [7:0] counter_prev;
	dffr #(8) COUNTER_FF(.clk (clk), .r (reset), .d (counter), .q (counter_prev));
	
endmodule
