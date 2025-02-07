`timescale 1ns / 1ps
`default_nettype none

// a simple module that gives an RTL description of the barrelshifter.
module barrelshifter #(parameter D_SIZE = 4) (
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

  logic [D_SIZE-1:0] lsr1, lsr2;
  mux2 #(D_SIZE) lsr1mux(x_in[D_SIZE-1:0], {1'b0, x_in[D_SIZE-1:1]}, s_in[0], lsr1);
  mux2 #(D_SIZE) lsr2mux(lsr1[D_SIZE-1:0], {2'b0, lsr1[D_SIZE-1:2]}, s_in[1], lsr2);

  // 001: ASR

  logic [D_SIZE-1:0] asr1, asr2;
  mux2 #(D_SIZE) asr1mux(x_in[D_SIZE-1:0], {x_in[D_SIZE-1], x_in[D_SIZE-1:1]}, s_in[0], asr1);
  mux2 #(D_SIZE) asr2mux(asr1[D_SIZE-1:0], {{2{asr1[D_SIZE-1]}}, asr1[D_SIZE-1:2]}, s_in[1], asr2);

  // 01X: Rotate Right

  logic [D_SIZE-1:0] rr1, rr2;
  mux2 #(D_SIZE) rr1mux(x_in[D_SIZE-1:0], {x_in[0], x_in[D_SIZE-1:1]}, s_in[0], rr1);
  mux2 #(D_SIZE) rr2mux(rr1[D_SIZE-1:0], {rr1[1:0], rr1[D_SIZE-1:2]}, s_in[1], rr2);

  // 100: LSL

  logic [D_SIZE-1:0] lsl1, lsl2;
  mux2 #(D_SIZE) lsl1mux(x_in[D_SIZE-1:0], {x_in[D_SIZE-2:0], 1'b0}, s_in[0], lsl1);
  mux2 #(D_SIZE) lsl2mux(lsl1[D_SIZE-1:0], {lsl1[D_SIZE-3:0], 2'b0}, s_in[1], lsl2);

  // 101: ASL

  logic [D_SIZE-1:0] asl1, asl2;
  mux2 #(D_SIZE) asl1mux(x_in[D_SIZE-1:0], {x_in[D_SIZE-2:0], x_in[0]}, s_in[0], asl1);
  mux2 #(D_SIZE) asl2mux(asl1[D_SIZE-1:0], {asl1[D_SIZE-3:0], {2{asl1[0]}}}, s_in[1], asl2);

  // 11X: Rotate Left

  logic [D_SIZE-1:0] rl1, rl2;
  mux2 #(D_SIZE) rl1mux(x_in[D_SIZE-1:0], {x_in[D_SIZE-2:0], x_in[D_SIZE-1]}, s_in[0], rl1);
  mux2 #(D_SIZE) rl2mux(rl1[D_SIZE-1:0], {rl1[D_SIZE-3:0], rl1[D_SIZE-1:D_SIZE-2]}, s_in[1], rl2);


  // Output
  logic [D_SIZE-1:0] rout, lout, rrout, rlout;
  mux2 #(D_SIZE) routmux(lsr2, asr2, op_in[0], rout);
  mux2 #(D_SIZE) loutmux(lsl2, asl2, op_in[0], lout);
  mux2 #(D_SIZE) rroutmux(rout, rr2, op_in[1], rrout);
  mux2 #(D_SIZE) rloutmux(lout, rl2, op_in[1], rlout);
  mux2 #(D_SIZE) outmux(rrout, rlout, op_in[2], y_out);

  assign vf_out = 0;
  assign zf_out = 0;
endmodule: barrelshifter

module mux2 #(parameter D_SIZE = 4) (
  input logic [D_SIZE-1:0]  a,
  input logic [D_SIZE-1:0]  b,
  input logic               s, // Select
  output logic [D_SIZE-1:0] y // Output
);
  assign y = s ? b : a;
endmodule: mux2
