module wave_display_top(
    input clk,
    input reset,
    input new_sample,
    input [15:0] sample,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]     
    input valid,
    input vsync,
    input [2:0] xscale,
    input [2:0] yscale,
    output pixel
);

    wire [7:0] read_sample, write_sample;
    wire [8:0] read_address, write_address;
    wire read_index;
    wire write_en;
    wire wave_display_idle = ~vsync;

    wave_capture wc(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(sample),
        .write_address(write_address),
        .write_enable(write_en),
        .write_sample(write_sample),
        .wave_display_idle(wave_display_idle),
        .read_index(read_index)
    );
    
    wire [8:0] scaled_address;
    wire out_of_range_x;
    address_scale as(
        .read_value(read_address[7:0]),
        .scale(xscale),
        .scaled_value(scaled_address[7:0]),
        .out_of_range(out_of_range_x) 
    );
    assign scaled_address[8] = read_address[8];

    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address),
        .dina(write_sample),
        .douta(),
        .addrb(scaled_address),
        .doutb(read_sample)
    );
    
    wire [7:0] scaled_value;
    wire [1:0] out_of_range_y;
    sample_scale ss(
        .read_value(read_sample),
        .scale(yscale),
        .scaled_value(scaled_value),
        .out_of_range(out_of_range_y) 
    );

    wire valid_pixel, pixel;
    wave_display wd(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .valid(valid),
        .read_address(read_address),
        .read_value(scaled_value),
        .out_of_range_x(out_of_range_x),
        .out_of_range_y(out_of_range_y),
        .read_index(read_index),
        .valid_pixel(valid_pixel),
        .pixel(pixel)
    );
    
endmodule
