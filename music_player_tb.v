module music_player_tb();
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

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    integer delay;
    initial begin
        delay = 10000;
        play_button = 1'b0;
        next_button = 1'b0;
        @(negedge reset);
        @(negedge clk);

        repeat (25) begin
            @(negedge clk);
        end 

        // Start playing
        $display("Starting playing song 0...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay) begin
            @(posedge new_sample);
	    $display("%d", sample); 
        end
	

        $stop;
    end


endmodule
