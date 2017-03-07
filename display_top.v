module display_top (
	input clk,
	input reset,
	
	input valid,
	input vsync,
	input [10:0] x,
	input [9:0] y,

	input new_sample_ready,
	input [15:0] sample_in_full,
	input [15:0] sample_in_1,
	input [15:0] sample_in_2,
	input [15:0] sample_in_3,

	input x_shrink,
	input x_stretch,
	input y_shrink,
	input y_stretch,

	input [1:0] play_state,
	input [1:0] song,

	input new_note,
	input [7:0] note ,
	input [7:0] duration,

	output wire [7:0] r, g, b
	);


	//******* Display Scaling FSMs ********//

	wire [2:0] xscale, yscale;

	display_scaling_fsm xscaler(
		.clk(clk),
		.reset(reset),
		.stretch(x_stretch),
		.shrink(x_shrink),
		.scale(xscale)
		);

	display_scaling_fsm yscaler(
		.clk(clk),
		.reset(reset),
		.stretch(y_stretch),
		.shrink(y_shrink),
		.scale(yscale)
		);


	//******** WAVE DISPLAY MODULES ********//

	wire pixel_full, pixel_1, pixel_2, pixel_3;
	wire [7:0] r_w, g_w, b_w;
	
	wave_display_top wd_full(
		.clk(clk),
		.reset(reset),
		.new_sample(new_sample_ready),
		.sample(sample_in_full),
		.x(x),
		.y(y),
		.valid(valid),
		.vsync(vsync),
		.xscale(xscale),
		.yscale(yscale),
		.pixel(pixel_full)
		);

	wave_display_top wd_1(
		.clk(clk),
		.reset(reset),
		.new_sample(new_sample_ready),
		.sample(sample_in_1),
		.x(x),
		.y(y),
		.valid(valid),
		.vsync(vsync),
		.xscale(xscale),
		.yscale(yscale),
		.pixel(pixel_1)
		);

	wave_display_top wd_2(
		.clk(clk),
		.reset(reset),
		.new_sample(new_sample_ready),
		.sample(sample_in_2),
		.x(x),
		.y(y),
		.valid(valid),
		.vsync(vsync),
		.xscale(xscale),
		.yscale(yscale),
		.pixel(pixel_2)
		);

	wave_display_top wd_3(
		.clk(clk),
		.reset(reset),
		.new_sample(new_sample_ready),
		.sample(sample_in_3),
		.x(x),
		.y(y),
		.valid(valid),
		.vsync(vsync),
		.xscale(xscale),
		.yscale(yscale),
		.pixel(pixel_3)
		);

	assign r_w = (pixel_full | pixel_1) ? 8'hFF : 8'h00; 
	assign g_w = (pixel_full | pixel_2) ? 8'hFF : 8'h00;
	assign b_w = (pixel_full | pixel_3) ? 8'hFF : 8'h00; 


	//******* OTHER DISPLAY STUFF ********//

	assign r = r_w;
	assign g = g_w;
	assign b = b_w;

endmodule