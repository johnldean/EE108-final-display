module wave_display (
    input clk,
    input reset,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]
    input valid,
    input [7:0] read_value,
    input [1:0] out_of_range_y,
    input out_of_range_x,
    input read_index,
    output wire [8:0] read_address,
    output wire valid_pixel,
    output wire pixel
);

    //Store the previous adress, so that we can tell when the read address has updated.
    wire [8:0] read_address_prev;
	assign read_address = {read_index, x[9:2]};
    dffr #(9) FF1(.clk(clk), .r(reset), .d(read_address), .q(read_address_prev));
	
    //FF's for storing the current and old read values
    wire new_addr = (read_address != read_address_prev);
    wire [7:0] read_value_old, read_value_old_checked;
    reg [7:0] read_value_checked;
	dffre #(8) FF2(.clk(clk), .r(reset), .d(read_value_checked), .q(read_value_old), .en(new_addr));

    //out of range x will update before the value back is actually returned. This delays it by one clock cycle
    wire out_of_range_x_curr;
    dffr #(1) FF3(.clk(clk), .r(reset), .d(out_of_range_x), .q(out_of_range_x_curr));

    //Check for the read_value input being off-screen
    always @(*) begin
        if (out_of_range_y[0]) begin //if the value is out of range and too high
            read_value_checked = 0;
        end
        else if (out_of_range_y[1]) begin //if the value is out of range and too low
            read_value_checked = 255;
        end else begin
            read_value_checked = read_value;
        end
    end



	// color_pixel indicates if the pixel should be colored, left_edge indacates if you are on the left edge of screen
	wire color_pixel, setup_region, left_edge;
    assign left_edge = (x < 5); 
    assign read_value_old_checked = left_edge ? read_value : read_value_old;
    assign setup_region = ((y == 0) & (x < 9)) | (x == 0);
	// logic for when a pixed should be colored
    assign color_pixel = (((read_value_checked >= y[9:2]) & (read_value_old_checked <= y[9:2])) | ((read_value_checked <= y[9:2]) & (read_value_old_checked >= y[9:2]))) & ~out_of_range_x_curr;
    // logic for when the pixels are colored
	assign valid_pixel = (x <= 1024) & valid;

    // if all the checks meet assign the pixel true
	assign pixel = (color_pixel & valid & valid_pixel & ~setup_region);


endmodule
