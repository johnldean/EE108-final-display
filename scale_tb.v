module scale_tb();
	reg [7:0] read_value;
	reg [2:0] scale;
	wire [7:0] scaled_value;
	wire [7:0] scaled_address;
	wire [1:0] out_of_range_y; 
	wire out_of_range_x;


	sample_scale DUT_sample(
		.read_value(read_value),
		.scale(scale),
		.scaled_value(scaled_value),
		.out_of_range(out_of_range_y)
		);

	address_scale DUT_address(
		.read_value(read_value),
		.scale(scale),
		.scaled_value(scaled_address),
		.out_of_range(out_of_range_x)
		);


	initial begin
		scale = 4;
		#5
		read_value = 128;
		#5
		read_value = 2;
		#5 
		read_value = 250;
		#5
		scale = 0;
		#5
		scale = 1;
		#5
		scale = 2;
		#5
		scale = 3;
		#5
		scale = 4;
		#5
		scale = 5;
		#5
		scale = 6;
		#5
		scale = 7;
		#5
		read_value = 120;
		#5
		scale = 0;
		#5
		scale = 1;
		#5
		scale = 2;
		#5
		scale = 3;
		#5
		scale = 4;
		#5
		scale = 5;
		#5
		scale = 6;
		#5
		scale = 7;
		#5
		scale = 4;


		$stop;
	end

endmodule 