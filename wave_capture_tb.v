module wave_capture_tb ();
		reg clk;
		reg reset;
		reg new_sample_ready;
		reg [15:0] new_sample_in;
		reg wave_display_idle;

		wire [8:0] write_address;
		wire write_enable;
		wire [7:0] write_sample;
		wire read_index;

	wave_capture DUT_CAPTURE (
		.clk(clk),
		.reset(reset),
		.new_sample_ready(new_sample_ready),
		.new_sample_in(new_sample_in),
		.wave_display_idle(wave_display_idle),

		.write_address(write_address),
		.write_enable(write_enable),
		.write_sample(write_sample),
		.read_index(read_index)
	);

	initial     
		forever
      		begin         
				#5 clk = 1 ; 
				#5 clk = 0 ;
    end

	initial begin
		#15
		#20 reset = 1;
		#10 reset = 0;
		#10 wave_display_idle = 0;


		//Should stay in armed
		#30 	new_sample_ready = 1; new_sample_in = 16'b0111000000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;

		#30 	new_sample_ready = 1; new_sample_in = 16'b1010100000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;

		#30 	new_sample_ready = 1; new_sample_in = 16'b1111000000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;
		
		//Should now be active
		#30 	new_sample_ready = 1; new_sample_in = 16'b0100000000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;
		

		repeat (128) begin
			#30 new_sample_ready = 1; new_sample_in = new_sample_in + 16'b0000000100000000;
			#10  new_sample_ready = 0; 
		end

		repeat (128) begin
			#30 new_sample_ready = 1; new_sample_in = new_sample_in - 16'b0000000100000000;
			#10  new_sample_ready = 0; 
		end

		
		//Should now be in wait
		#30 	new_sample_ready = 1; new_sample_in = 16'b1010010000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;

		#30 	new_sample_ready = 1; new_sample_in = 16'b1111111000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;

		#30 	new_sample_ready = 1; new_sample_in = 16'b0100000000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;
		
		//Go back to armed
		#30 	wave_display_idle = 1; new_sample_ready = 1; new_sample_in = 16'b1100000000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;
		

		//Active again
		#30 	new_sample_ready = 1; new_sample_in = 16'b0100000000000111;
		#10 	new_sample_ready = 0; new_sample_in = 0;

		#1000

	$stop; 
	end

endmodule





