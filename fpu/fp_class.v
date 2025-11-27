`timescale 1ns / 1ps

module fp_class #(
  parameter WIDTH = 32
)(
  input [WIDTH-1:0] f,
  output reg signed [NEXP+1:0] fExp,
  output reg [NSIG:0] fSig,
  output [NTYPES-1:0] fFlags
);

  localparam NEXP = (WIDTH == 32) ? 8 : 11;
  localparam NSIG = (WIDTH == 32) ? 23 : 52;

  `include "ieee-754-flags.vh"

  clog2 clog();
  localparam CLOG2_NSIG = clog.CLOG2(NSIG+1);

  wire expOnes, expZeroes, sigZeroes;

  assign expOnes   =  &f[WIDTH-2:NSIG];
  assign expZeroes = ~|f[WIDTH-2:NSIG];
  assign sigZeroes = ~|f[NSIG-1:0];

  assign fFlags[SNAN] = expOnes & ~sigZeroes & ~f[NSIG-1];
  assign fFlags[QNAN] = expOnes & f[NSIG-1];
  assign fFlags[INFINITY] = expOnes & sigZeroes;
  assign fFlags[ZERO] = expZeroes & sigZeroes;
  assign fFlags[SUBNORMAL] = expZeroes & ~sigZeroes;
  assign fFlags[NORMAL] = ~expOnes & ~expZeroes;

  reg [NSIG:0] mask;
  reg [CLOG2_NSIG-1:0] sa;
  integer i;

  always @(*) begin

    mask = {(NSIG+1){1'b1}};
    fExp = f[WIDTH-2:NSIG];
    fSig = f[NSIG-1:0];
    sa = 0;
    if (fFlags[NORMAL]) begin
      fExp = f[WIDTH-2:NSIG] - BIAS;
      fSig = {1'b1,f[NSIG-1:0]};
    end

    else if (fFlags[SUBNORMAL]) begin
      for (i = (1 << (CLOG2_NSIG - 1));i > 0; i = i >> 1) begin
        if ((fSig & (mask << (NSIG + 1 - i))) == 0) begin
          fSig = fSig << i;
          sa = sa | i;
        end
      end
      fExp = EMIN - sa;
    end
  end

endmodule
