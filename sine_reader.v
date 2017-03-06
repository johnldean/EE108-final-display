`define Q1 2'b00
`define Q2 2'b01
`define Q3 2'b10
`define Q4 2'b11
`define ADDRWIDTH 22
`define MAXADDR 10'd1023
`define ZERO 16'd0

module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,
    input generate_next,

    output sample_ready,
    output wire [15:0] sample
);

  wire [21:0] curr_addr, next_addr;
  wire [9:0] raw_addr, precision, rom_addr;
  wire [1:0] quadrant;
  wire precision_carry;
  wire [15:0] sr_out, sr_delay; 

  // change ROM address if Q2 or Q4
  assign rom_addr = (curr_addr[21:20] == `Q2 || curr_addr[21:20] == `Q4) ? `MAXADDR - curr_addr[19:10] : curr_addr[19:10];

  // initialize sine ROM
  sine_rom sr(
    .clk(clk),
    .addr(rom_addr),
    .dout(sr_out)
  );

  // delay output by two cycles - corresponding to sine ROM and addr_counter FFs
  wire tmp;
  dffr rom_delay1(.clk (clk), .r (reset), .d (generate_next), .q (tmp));
  dffr rom_delay2(.clk (clk), .r (reset), .d (tmp), .q (sample_ready));

  // modify ROM output if Q3 or Q4
  assign sample = (curr_addr[21:20] == `Q3 || curr_addr[21:20] == `Q4) ? `ZERO - sr_out : sr_out; 

  // initialize FF
  dffre #(`ADDRWIDTH) addr_counter_ff(
    .clk (clk),
    .r (reset),
    .en (generate_next),
    .d (next_addr), .q (curr_addr)
  );

  // increment address
  assign next_addr = curr_addr + {`Q1, step_size};

endmodule
