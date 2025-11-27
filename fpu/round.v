`timescale 1ns / 1ps

module round #(
  parameter WIDTH = 32,
  parameter INTn = 64
)(
  input negIn,
  input signed [NEXP+1:0] expIn,
  input [INTn-1:0] sigIn,
  input [NRAS:0] ra,
  output signed [NEXP+1:0] expOut,
  output [NSIG:0] sigOut,
  output reg inexact
);

  localparam NEXP = (WIDTH == 32) ? 8 : 11;
  localparam NSIG = (WIDTH == 32) ? 23 : 52;

  `include "ieee-754-flags.vh"

  wire Cout;
  wire [NSIG:0] aSig,rSig;
  wire signed [NEXP+1:0] rExp;

  reg [NSIG:0] keptbits;
  reg [INTn-1:0] yBar;

  reg lastbit,Gaurd,Sticky;

  reg subnormal;

  always @(*) begin
    subnormal = 1;

    if (expIn < EMIN-NSIG-1) begin

      lastbit = 1'b0;
      Gaurd = 1'b0;
      Sticky = |sigIn;
      keptbits = {(NSIG+1){1'b0}};
    end

    else if (expIn < EMIN-NSIG) begin

      lastbit = 1'b0;
      Gaurd = sigIn[INTn-1];
      Sticky = |sigIn[INTn-2:0];
      keptbits = {(NSIG+1){1'b0}};

    end

    else if (expIn < EMIN) begin

      lastbit = sigIn[INTn-NSIG+EMIN-expIn-1];
      Gaurd = sigIn[INTn-NSIG+EMIN-expIn-2];
      yBar = sigIn << (NSIG-EMIN+expIn+1);
      Sticky = |yBar[INTn-2:0];
      keptbits = {(sigIn >> (INTn-NSIG+EMIN-expIn-1)),1'b0};

    end
    else begin

      lastbit = sigIn[INTn-NSIG-1];
      Gaurd = sigIn[INTn-NSIG-2];
      Sticky = |sigIn[INTn-NSIG-3:0];
      keptbits = sigIn[INTn-1:INTn-NSIG-1];
      subnormal = 0;

    end

    inexact = Gaurd | Sticky;
  end

  wire roundBit =
   (ra[roundTiesToEven] & Gaurd & (lastbit | Sticky)) |
   (ra[roundTowardPositive] & ~negIn & (Gaurd | Sticky)) |
   (ra[roundTowardNegative] & negIn & (Gaurd | Sticky));

  universal_adder #(.N(NSIG+1)) round_adder (
    .A(keptbits),
    .B({{NSIG{1'b0}},(roundBit & subnormal)}),
    .Cin(roundBit),
    .S(aSig),
    .Cout(Cout)
  );

  assign rSig = Cout ? {Cout,aSig[NSIG:1]} : aSig;
  assign rExp = expIn + Cout;

  assign expOut = |rSig ? ((rExp<EMIN-NSIG) ? EMIN-NSIG : rExp) : rExp;
  assign sigOut = rSig;

endmodule
