`timescale 1ns / 1ps

module universal_adder #(
  parameter N = 32
)(
  input [N-1:0] A,
  input [N-1:0] B,
  input Cin,
  output [N-1:0] S,
  output Cout
);

  wire [N:0] sum_with_carry;

  assign sum_with_carry = A + B + Cin;
  assign S = sum_with_carry[N-1:0];
  assign Cout = sum_with_carry[N];

endmodule
