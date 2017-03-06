module display_top_tb();
    
    //****** MUSIC PLAYER STUFF *********//
    reg clk, reset, next_button, play_button;
    wire new_frame;
    wire signed new_sample;
    wire [15:0] sample;

    music_player #(.BEAT_COUNT(100)) music_player(
        .clk(clk),
        .reset(reset),
        .next_button(next_button),
        .play_button(play_button),
        .new_frame(new_frame),
        .sample_out(sample),
	    .new_sample_generated(new_sample)
    );

    // AC97 interface
    wire AC97Reset_n;        // Reset signal for AC97 controller/clock
    wire SData_Out;          // Serial data out (control and playback data)
    wire Sync;               // AC97 sync signal

    // Our codec simulator
    ac97_if codec(
        .Reset(1'b0), // Reset MUST be shorted to 1'b0
        .ClkIn(clk),
        .PCM_Playback_Left(sample),   // Set these two to different
        .PCM_Playback_Right(sample),  // samples to have stereo audio!
        .PCM_Record_Left(),
        .PCM_Record_Right(),
        .PCM_Record_Valid(),
        .PCM_Playback_Accept(new_frame),  // Asserted each sample
        .AC97Reset_n(AC97Reset_n),
        .AC97Clk(1'b0),
        .Sync(Sync),
        .SData_Out(SData_Out),
        .SData_In(1'b0)
    );

    //*********************************//




    //***** DISPLAY STUFF *******//
    reg [10:0] x;
    reg [9:0] y;
    reg valid;
    reg read_index;
    reg vsync;
    reg [2:0] yscale;
    wire [7:0] r,g,b;

    wave_display_top wd_top (
        .clk (clk),
        .reset (reset),
        .new_sample (new_sample),
        .sample (sample),
        // .x(x_q[10:0]),
        // .y(y_q[9:0]),
        .x(x[10:0]),
        .y(y[9:0]),
        .yscale(yscale),
        .valid(valid),
        .vsync(vsync),
        .r(r),
        .g(g),
        .b(b) 
    );




    // Clock and reset
    initial begin
        vsync = 1;
        x = 0;
        y = 0;
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    //dispay
    initial begin

        yscale = 3;
    	valid = 1;
        vsync = 0;
        repeat (10_000) @(posedge clk);
        forever begin
        	vsync = 1;
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
	                    vsync = 0;
	                    repeat (100) begin
	                        @(posedge clk);
	                    end
	                    y = 0;
	                end
	            end
	        end
	    end
    end

    // Tests
    integer delay;
    initial begin
        delay = 1279*1023 + 10_000;
        play_button = 1'b0;
        next_button = 1'b0;
        @(negedge reset);
        @(negedge clk);

        repeat (25) begin
            @(negedge clk);
        end 

        // Start playing
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay) begin
            @(posedge clk);
        end
	

        $stop;
    end


endmodule
