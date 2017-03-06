
module wave_display_tb ();
		reg clk;
		reg reset;
        reg [10:0] x;
        reg [9:0] y;
        reg valid;
        reg read_index;

        wire [7:0] read_value;
		wire [8:0] read_address;
		wire valid_pixel;
        wire [7:0] r,g,b;

	wave_display DUT_DISPLAY (
		.clk(clk),
		.reset(reset),
        .x(x),
        .y(y),
        .valid(valid),
        .read_value(read_value),
        .read_index(read_index),

        .read_address(read_address),
        .valid_pixel(valid_pixel),
        .r(r),
        .g(g),
        .b(b)
	);

    fake_sample_ram ROM (
        .clk(clk),
        .addr(read_address),
        .dout(read_value)
        );

	initial     
		forever
      		begin         
				#5 clk = 1 ; 
				#5 clk = 0 ;         
    end

	initial begin
		#15 reset = 1;
		#5 reset = 0;
        valid = 1;
        read_index = 0;
        x = 0;
        y = 0;
        #10

        repeat ((1279+1) * (1023+1)) begin
            @(posedge clk) begin
                x = x + 1;
                if ( {r,g,b} != 0) begin
                    $display("%d, %d, %d, %d, %d", x, y, r, g, b);
                end

                //$display("Addr: %d, Read: %d", read_address, read_value);
                if (x > 11'd1279) begin
                    x = 0;
                    y = y + 1;
                    if(y > 10'd1023) begin
                        y = 0;
                    end
                end
            end
        end

	$stop; 
	end

endmodule





