module display_scaling_fsm(
	input clk,
	input reset,
	input stretch,
	input shrink,
	output wire [2:0] scale
	);
	
	wire [2:0] scale_prev, scale_prev_1;
	wire en_shrink, en_stretch;
	reg [2:0] rscale;

	assign en_shrink = (scale_prev != 3'b000) & shrink;
	assign en_stretch = (scale_prev != 3'b111) & stretch;

	always @(*) begin
		if(en_shrink & ~en_stretch) begin
			rscale = scale_prev - 1;
		end else if (~en_shrink & en_stretch) begin
			rscale = scale_prev + 1;
		end else begin
			rscale = scale_prev;
		end
	end

	assign scale = reset ? 3'b100 : rscale;
	assign scale_prev = reset ? 3'b100 : scale_prev_1;
	dff #(3) FF(.clk(clk), .d(scale), .q(scale_prev_1));


endmodule 

