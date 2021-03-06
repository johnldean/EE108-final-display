module sample_scale (
	input [7:0] read_value,
	input [2:0] scale,
	output wire [7:0] scaled_value,
	output wire [1:0] out_of_range 
	);

	wire signed [8:0] signed_read_value, singed_scaled_value;
	wire signed [16:0] read_value_shifted1, read_value_shifted2;

	assign signed_read_value = read_value - 127;
	assign read_value_shifted1 = {signed_read_value, 8'b0000_0000};
	assign read_value_shifted2 = read_value_shifted1 >>> scale;
	assign singed_scaled_value = {read_value_shifted1[16], read_value_shifted2[11:4]};
	assign scaled_value = singed_scaled_value + 127;
	assign out_of_range = { (read_value_shifted2[16:11] != 6'b000000) & (read_value_shifted2[16] == 0) ,
						    (read_value_shifted2[16:11] != 6'b111111) & (read_value_shifted2[16] == 1) };


endmodule