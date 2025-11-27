`timescale 1ns / 1ps

module fp_add_exact #(
  parameter WIDTH = 32
)(
  input [WIDTH-1:0] a,
  input [WIDTH-1:0] b,
  input [5:0] ra,
  output [WIDTH-1:0] s
  
);

  localparam NEXP = (WIDTH == 32) ? 8 : 11;
  localparam NSIG = (WIDTH == 32) ? 23 : 52;

  `include "ieee-754-flags.vh"

  clog2 clog();
  localparam CLOG2_NSIG = clog.CLOG2(NSIG+1);

  wire inexact;
  wire signed [NEXP+1:0] aExp,bExp,expOut;
  wire signed [NEXP+1:0] qExp,expIn;
  wire [NSIG:0] aSig,bSig,sigOut;
  reg signed [NSIG+5:0] dTmp,bTmp[15:1],iTmp[15:1];
  reg [NSIG+5:0] tSig;
  wire [NSIG:0] qSig;
  wire [NTYPES-1:0] aFlags,bFlags;
  reg [NTYPES-1:0] sFlags;
  reg [NEXCEPTIONS-1:0] exception;

  fp_class #(.WIDTH(WIDTH)) aClass(a,aExp,aSig,aFlags);
  fp_class #(.WIDTH(WIDTH)) bClass(b,bExp,bSig,bFlags);

  wire aSign = a[WIDTH-1];
  wire bSign = b[WIDTH-1];
  reg signed [NSIG+1:0] shiftAmt;

  reg signed [EMAX+2:EMIN-NSIG] augendSig,addendSig,normSig;
  wire signed [EMAX+2:EMIN-NSIG] sumSig,absSig,bigSig;
  reg signed [NEXP+1:0] adjExp,normExp,biasExp;
  wire signed [NEXP+1:0] bigExp;

  reg sumSign;
  wire absSign;
  reg [3:0] shiftCount;
  reg [CLOG2_NSIG-1:0] na;
  reg [EMAX+2:EMIN-NSIG] mask;

  wire Cout1,Cout2;
  reg subtract,zero,e0,si;
  reg [WIDTH-1:0] alwaysS;
  integer i;

  always @(*) begin
    mask = {(EMAX-(EMIN-NSIG)+3){1'b1}};
    sFlags = 0;
    exception = 0;
    subtract = a[WIDTH-1] ^ b[WIDTH-1];

    if (aFlags[SNAN] | bFlags[SNAN]) begin
      {alwaysS,sFlags} = aFlags[SNAN] ? {a,aFlags} : {b,bFlags};
    end
    else if (aFlags[QNAN] | bFlags[QNAN]) begin
      {alwaysS,sFlags} = aFlags[QNAN] ? {a,aFlags} : {b,bFlags};
    end
    else if (aFlags[ZERO] | bFlags[ZERO]) begin
      if (aFlags[ZERO] & bFlags[ZERO]) begin

        sFlags[ZERO] = 1;
        if (aSign & bSign) begin
          alwaysS = {1'b1,{(WIDTH-1){1'b0}}};
        end else if (~aSign & ~bSign) begin
          alwaysS = {1'b0,{(WIDTH-1){1'b0}}};
        end else begin
          alwaysS = {ra[roundTowardNegative],{(WIDTH-1){1'b0}}};
        end
      end else begin
        {alwaysS,sFlags} = aFlags[ZERO] ? {b,bFlags} : {a,aFlags};
      end

    end

    else if (aFlags[INFINITY] & bFlags[INFINITY]) begin

      if (subtract) begin
        exception[INVALID] = 1;
        sFlags[QNAN] = 1;
        alwaysS = {1'b0,{NEXP{1'b1}},1'b1,{(NSIG-1){1'b0}}};
      end else begin
        sFlags[INFINITY] = 1;
        alwaysS = {aSign,{NEXP{1'b1}},{NSIG{1'b0}}};
      end

    end

    else if (aFlags[INFINITY] | bFlags[INFINITY]) begin
      {alwaysS,sFlags} = aFlags[INFINITY] ? {a,aFlags} : {b,bFlags};
    end

    else begin
      augendSig = 0;
      addendSig = 0;
      na = 0;
      zero = 1;

      if (aExp < bExp) begin
        sumSign = b[WIDTH-1];
        shiftAmt = bExp - aExp;
        augendSig[EMAX:EMAX-NSIG] = bSig;
        addendSig[EMAX:EMAX-NSIG] = aSig;
        adjExp = bExp;
      end
      else begin
        sumSign = a[WIDTH-1];
        shiftAmt = aExp - bExp;
        augendSig[EMAX:EMAX-NSIG] = aSig;
        addendSig[EMAX:EMAX-NSIG] = bSig;
        adjExp = aExp;
      end

      addendSig = addendSig >> shiftAmt;
      normSig = bigSig;

      for (i = (1 << (CLOG2_NSIG - 1)); i > 0; i = i >> 1) begin
        if ((normSig & (mask << ((EMAX-(EMIN-NSIG)+1) - i))) == 0) begin
          normSig = normSig << i;
          na = na | i;
        end
        else
          zero = 0;
      end

      normExp = bigExp - na;

      if (zero) begin
        sFlags[ZERO] = 1;
        alwaysS = {ra[roundTowardNegative] & subtract,{(WIDTH-1){1'b0}}};
      end
      else if (normExp < EMIN || expOut < EMIN) begin
        sFlags[SUBNORMAL] = 1;
        if (sigOut == 0) begin
          sFlags[ZERO] = 1;
          sFlags[SUBNORMAL] = 0;
          alwaysS = {absSign,{(WIDTH-1){1'b0}}};
        end else begin
          alwaysS = {absSign,{NEXP{1'b0}},sigOut[NSIG:1]};
        end
        exception[UNDERFLOW] = inexact;
        exception[INEXACT] = inexact;
      end
      else if (expOut > EMAX) begin
        si = ra[roundTowardZero] |
            (ra[roundTowardNegative] & ~absSign) |
            (ra[roundTowardPositive] &  absSign);
        alwaysS = {absSign,{{(NEXP-1){1'b1}},~si},{NSIG{si}}};
        sFlags[INFINITY] = ~si;
        sFlags[NORMAL]   =  si;
        exception[OVERFLOW] = 1;
      end
      else begin
        sFlags[NORMAL] = 1;
        biasExp = expOut + BIAS;
        alwaysS = {absSign,biasExp[NEXP-1:0],sigOut[NSIG-1:0]};
      end

      exception[INEXACT] = exception[INEXACT] | inexact;
    end
  end

  universal_adder #(.N(EMAX-(EMIN-NSIG)+3)) sum_adder (
    .A(augendSig),.B(addendSig ^ {(EMAX-(EMIN-NSIG)+3){subtract}}),
    .Cin(subtract),.S(sumSig),.Cout(Cout1)
  );

  assign absSign = sumSign ^ sumSig[EMAX+2];

  universal_adder #(.N(EMAX-(EMIN-NSIG)+3)) abs_adder (
    .A({(EMAX-(EMIN-NSIG)+3){1'b0}}),
    .B(sumSig ^ {(EMAX-(EMIN-NSIG)+3){sumSig[EMAX+2]}}),
    .Cin(sumSig[EMAX+2]),.S(absSig),.Cout(Cout2)
  );

  assign bigSig = absSig >> absSig[EMAX+1];
  assign bigExp = adjExp + absSig[EMAX+1];

  round #(.WIDTH(WIDTH),.INTn(EMAX-(EMIN-NSIG)+1)) round_inst (
    .negIn(absSign),.expIn(normExp),.sigIn(normSig[EMAX:EMIN-NSIG]),
    .ra(ra),.expOut(expOut),.sigOut(sigOut),.inexact(inexact)
  );

  assign s = alwaysS;

endmodule
