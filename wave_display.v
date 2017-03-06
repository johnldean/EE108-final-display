module wave_display (
    input clk,
    input reset,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]
    input valid,
    input [7:0] read_value,
    input in_range_y,
    input read_index,
    output wire [8:0] read_address,
    output wire valid_pixel,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);

	// assigning the read adress to be one ahead of the current address so that the ROM output will be
	// on time even with the delay
    wire [8:0] read_address_prev;
	assign read_address = {read_index, x[9:2]};
    dffr #(9) FF1(.clk(clk), .r(reset), .d(read_address), .q(read_address_prev));
	
    wire new_addr = (read_address != read_address_prev);
    wire [7:0] read_value_old, read_value_old_checked;
	dffre #(8) FF4(.clk(clk), .r(reset), .d(read_value), .q(read_value_old), .en(new_addr));

	// color_pixel indicates if the pixel should be colored, left_edge indacates if you are on the left edge of screen

	wire color_pixel, setup_region, left_edge;
    assign left_edge = (x < 5); 
    assign read_value_old_checked = left_edge ? read_value : read_value_old;
    assign setup_region = ((y == 0) & (x < 9)) | (x == 0);
	// logic for when a pixed should be colored
    assign color_pixel = (((read_value >= y[9:2]) & (read_value_old_checked <= y[9:2])) | ((read_value <= y[9:2]) & (read_value_old_checked >= y[9:2])));
    // logic for when the pixels are colored
	assign valid_pixel = (x <= 1024) & valid;

    // some stuff to make colors
    wire [7:0] red, green, blue;
    assign red = 0;
    assign green = 8'hFF;
    assign blue = 0;


    // if all the checks meet assign the pixel values
	assign {r, g, b} = (color_pixel & valid & valid_pixel & ~setup_region) ? {red, green, blue} : 24'h00_00_00;


endmodule
