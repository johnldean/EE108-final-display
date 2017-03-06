module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    output play,
    output reset_player,
    output [1:0] song,
    input song_done
);

	wire [2:0] state;
	reg [2:0] next_state;
	dffr #(3) FF1 (.clk(clk), .d(next_state), .q(state), .r(reset));

	always @(*) begin
		if (next_button | song_done) begin
			next_state[2:1] = state[2:1] + 1;
			next_state[0] = 0;
		end else if (play_button) begin	
			next_state[2:1] = state[2:1];	
			next_state[0] = ~state[0];
		end else begin			
			next_state[2:1] = state[2:1];	
			next_state[0] = state[0];
		end
	end

	assign reset_player = (next_button | song_done | reset);
	assign song = state[2:1];
	assign play = state[0];

endmodule
