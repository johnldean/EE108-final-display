module display_scaling_fsm_tb ();
	reg clk;
	reg reset;
    reg stretch;
    reg shrink;
    wire [2:0] scale;

    display_scaling_fsm DUT(
        .clk(clk),
        .reset(reset),
        .shrink(shrink),
        .stretch(stretch),
        .scale(scale)
        );

	initial     
		forever
      		begin         
				#5 clk = 1 ; 
				#5 clk = 0 ;         
    end

	initial begin
        stretch = 0;
        shrink = 0;
		reset = 1; 
        #30
		reset = 0;
        #10


        repeat (10) begin
            @(posedge clk);
            stretch = 1;
            @(posedge clk);
            stretch = 0;
        end
        repeat (10) begin
            @(posedge clk);
            shrink = 1;
            @(posedge clk);
            shrink = 0;
        end
        repeat (10) begin
            @(posedge clk);
            stretch = 1;
            shrink = 1;
            @(posedge clk);
            stretch = 0;
            shrink = 0;
        end 

        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        #40
	    $stop; 
	end

endmodule

