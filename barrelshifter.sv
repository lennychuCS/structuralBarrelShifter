`timescale 1ns / 1ps
`default_nettype none

// a simple module that gives an RTL description of the barrelshifter.
module barrelshifter #(parameter D_SIZE = 2) (
  input  logic [D_SIZE-1:0]         x_in,
  input  logic [$clog2(D_SIZE)-1:0] s_in,
  input  logic [2:0]                op_in,
  output logic [D_SIZE-1:0]         y_out,
  output logic                      zf_out,
  output logic                      vf_out
);
  // ops:
    // 000: LSR
    // 001: ASR
    // 01X: Rotate Right
    // 100: LSL
    // 101: ASL
    // 11X: Rotate Left

  // 000: LSR

  // if we're shifting left, flip


  // TODO ENSURE THAT THIS ONLY FLIPS WHEN NEEDED
  logic [D_SIZE-1:0] flipped;
  flipper #(D_SIZE) flip(x_in, flipped);

  logic [D_SIZE-1:0] inter [$clog2(D_SIZE)+1];
  logic [D_SIZE-1:0] arith [$clog2(D_SIZE)+1];
  logic [D_SIZE-1:0] rot [$clog2(D_SIZE)+1];

  mux2 #(D_SIZE) toflip(x_in, flipped, op_in[2], inter[0]);

  genvar i;
	// Generate for loop to instantiate N times
	generate
		for (i = 0; i < $clog2(D_SIZE); i = i + 1) begin
      mux2 #(D_SIZE) arthed({{2**i{1'b0}}, inter[i][D_SIZE-1:2**i]}, 
                            {{2**i{inter[i][D_SIZE-1]}}, inter[i][D_SIZE-1:2**i]}, 
                            op_in[0], arith[i]);
      mux2 #(D_SIZE) roted(arith[i], 
                            {inter[i][(2**i)-1:0], inter[i][D_SIZE-1:2**i]}, 
                            op_in[1], rot[i]);
      mux2 #(D_SIZE) muxed(inter[i], rot[i], s_in[i], inter[i+1]);
		end
	endgenerate

  // TODO ENSURE THAT THIS ONLY FLIPS WHEN NEEDED
  logic [D_SIZE-1:0] unflipped;
  flipper #(D_SIZE) unflip(inter[$clog2(D_SIZE)], unflipped);


  mux2 #(D_SIZE) tounflip(inter[$clog2(D_SIZE)], unflipped, op_in[2], y_out);

  assign vf_out = 0;
  assign zf_out = &(~y_out);
endmodule: barrelshifter

module mux2 #(parameter D_SIZE = 4) (
  input logic [D_SIZE-1:0]  a,
  input logic [D_SIZE-1:0]  b,
  input logic               s, // Select
  output logic [D_SIZE-1:0] y // Output
);
  assign y = s ? b : a;
endmodule: mux2

module flipper #(parameter D_SIZE = 4) (
  input logic [D_SIZE-1:0]  in,
  output logic [D_SIZE-1:0]  out
);
  genvar i;
	// Generate for loop to instantiate N times
	generate
		for (i = 0; i < D_SIZE; i = i + 1) begin
      assign out[D_SIZE - 1 - i] = in[i];
		end
	endgenerate
endmodule: flipper