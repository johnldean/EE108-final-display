module sample_scale_tb();
	reg [7:0] read_value;
	reg [2:0] scale;
	wire [7:0] scaled_value;
	wire in_range; 


	sample_scale DUT(
		.read_value(read_value),
		.scale(scale),
		.scaled_value(scaled_value),
		.in_range(in_range)
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