`timescale 1ns / 1ps
module hp_class #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] f,
    output snan,
    output qnan,
    output infinity,
    output zero,
    output subnormal,
    output normal
);

generate
    if (WIDTH == 32) begin : single_precision
        wire expOnes, expZeroes, sigZeroes;
        assign expOnes    = &f[30:23];
        assign expZeroes  = ~|f[30:23];
        assign sigZeroes  = ~|f[22:0];
        assign snan       = expOnes & ~sigZeroes & ~f[22];
        assign qnan       = expOnes & f[22];
        assign infinity   = expOnes & sigZeroes;
        assign zero       = expZeroes & sigZeroes;
        assign subnormal  = expZeroes & ~sigZeroes;
        assign normal     = ~expOnes & ~expZeroes;
    end

    else if (WIDTH == 64) begin : double_precision
        wire expOnes, expZeroes, sigZeroes;
        assign expOnes    = &f[62:52];
        assign expZeroes  = ~|f[62:52];
        assign sigZeroes  = ~|f[51:0];

        assign snan       = expOnes & ~sigZeroes & ~f[51];
        assign qnan       = expOnes & f[51];
        assign infinity   = expOnes & sigZeroes;
        assign zero       = expZeroes & sigZeroes;
        assign subnormal  = expZeroes & ~sigZeroes;
        assign normal     = ~expOnes & ~expZeroes;
    end

    else begin : invalid_width
        assign snan       = 1'b0;
        assign qnan       = 1'b0;
        assign infinity   = 1'b0;
        assign zero       = 1'b0;
        assign subnormal  = 1'b0;
        assign normal     = 1'b0;
    end
endgenerate

endmodule
