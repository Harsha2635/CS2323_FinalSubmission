module cvtdw(in, out);
  parameter INTn = 32;
  parameter NEXP = 11;
  parameter NSIG = 52;
  localparam BIAS = ((1 << (NEXP - 1)) - 1);
  function integer CLOG2;
    input integer value;
    integer i;
    begin
      value = value - 1;
      for (i = 0; value > 0; i = i + 1)
        value = value >> 1;
      CLOG2 = i;
    end
  endfunction
  
  localparam CLOG2_INTn = CLOG2(INTn);

  input signed [INTn-1:0] in;
  output [NEXP+NSIG:0] out;
  reg [NEXP+NSIG:0] out;

  reg [INTn-1:0] sig;
  wire [INTn-1:0] mask;

  assign mask = {INTn{1'b1}};

  integer i, exp;

  always @(in)
    begin
      if (in[INTn-1])
        sig = ~in + 1;
      else
        sig = in;

      if (in == 0)
        begin
          out = {NEXP+NSIG+1{1'b0}};
        end
      else
        begin
          exp = 0;
          for (i = (1 << (CLOG2_INTn - 1)); i > 0; i = i >> 1)
            begin
              if ((sig & (mask << (INTn - i))) == 0)
                begin
                  sig = sig << i;
                  exp = exp | i;
                end
            end

          exp = (INTn - 1) + BIAS - exp;

          if (NSIG >= INTn - 1)
            out = {in[INTn-1],
                   exp[NEXP-1:0],
                   sig[INTn-2:0],
                   {(NSIG - INTn + 1){1'b0}}};
          else
            out = {in[INTn-1],
                   exp[NEXP-1:0],
                   sig[INTn-2 -: NSIG]};

        end
    end
endmodule
