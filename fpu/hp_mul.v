`timescale 1ns / 1ps
module hp_mul #(
    parameter WIDTH = 32,
    parameter INTn = 128
)(
    input  [WIDTH-1:0] a, b,
    input  [5:0] rounding_mode,
    output [WIDTH-1:0] p
    
);
    wire aSnan, aQnan, aInfinity, aZero, aSubnormal, aNormal;
    wire bSnan, bQnan, bInfinity, bZero, bSubnormal, bNormal;

    localparam NEXP  = (WIDTH == 32) ? 8  : 11;
    localparam NMANT = (WIDTH == 32) ? 23 : 52;

    `include "ieee-754-flags.vh"

    localparam EXP_BITS  = NEXP;
    localparam MANT_BITS = NMANT;
    localparam SIG_BITS  = MANT_BITS + 1;
    localparam SUBNORM_MIN = EMIN - MANT_BITS;

    wire signed [EXP_BITS+1:0] aExp, bExp;
    reg  signed [EXP_BITS+1:0] pExp, t1Exp, t2Exp;
    wire [SIG_BITS-1:0] aSig, bSig;
    reg  [SIG_BITS:0] pSig, tSig;
    reg  [WIDTH-1:0] pTmp;
    wire [2*SIG_BITS-1:0] rawSignificand;
    reg pSign;
    reg [EXP_BITS-1:0] biased_exp;
    reg out_snan, out_qnan, out_infinity, out_zero, out_subnormal, out_normal;
    wire out_inexact;

    wire signed [EXP_BITS+1:0] roundedExp;
    wire [MANT_BITS:0] roundedSig;
    wire inexact_round;
    reg needs_rounding;
    reg [INTn-1:0] sigForRounding;

    assign aExp = (aSubnormal) ? EMIN : $signed({1'b0, a[WIDTH-2:MANT_BITS]}) - BIAS;
    assign bExp = (bSubnormal) ? EMIN : $signed({1'b0, b[WIDTH-2:MANT_BITS]}) - BIAS;

    assign aSig = {(aNormal | aInfinity), a[MANT_BITS-1:0]};
    assign bSig = {(bNormal | bInfinity), b[MANT_BITS-1:0]};

    hp_class #(.WIDTH(WIDTH)) aClass (
        .f(a),
        .snan(aSnan),
        .qnan(aQnan),
        .infinity(aInfinity),
        .zero(aZero),
        .subnormal(aSubnormal),
        .normal(aNormal)
    );

    hp_class #(.WIDTH(WIDTH)) bClass (
        .f(b),
        .snan(bSnan),
        .qnan(bQnan),
        .infinity(bInfinity),
        .zero(bZero),
        .subnormal(bSubnormal),
        .normal(bNormal)
    );

    assign rawSignificand = aSig * bSig;

    round #(
        .WIDTH(WIDTH),
        .INTn(INTn)
    ) rounder (
        .negIn(pSign),
        .expIn(t2Exp),
        .sigIn(sigForRounding),
        .ra(rounding_mode),
        .expOut(roundedExp),
        .sigOut(roundedSig),
        .inexact(inexact_round)
    );

    assign out_inexact = inexact_round & needs_rounding;

    always @(*) begin
        pSign = a[WIDTH-1] ^ b[WIDTH-1];
        pTmp = {pSign, {EXP_BITS{1'b1}}, 1'b0, {MANT_BITS{1'b1}}}; // sNaN default
        {out_snan, out_qnan, out_infinity, out_zero, out_subnormal, out_normal} = 6'b000000;
        needs_rounding = 1'b0;
        sigForRounding = {INTn{1'b0}};
        t2Exp = 0;
        tSig = 0;
        pSig = 0;
        pExp = 0;
        biased_exp = 0;

        if ((aSnan | bSnan) == 1'b1) begin
            pTmp = aSnan ? a : b;
            out_snan = 1'b1;
        end
        else if ((aQnan | bQnan) == 1'b1) begin
            pTmp = aQnan ? a : b;
            out_qnan = 1'b1;
        end
        else if ((aInfinity | bInfinity) == 1'b1) begin
            if ((aZero | bZero) == 1'b1) begin
                if (WIDTH == 32) begin
                    pTmp = 32'h7FC00000;
                end else begin
                    pTmp = 64'h7FF8000000000000;
                end
                out_qnan = 1'b1;
            end
            else begin
                pTmp = {pSign, {EXP_BITS{1'b1}}, {MANT_BITS{1'b0}}};
                out_infinity = 1'b1;
            end
        end
        else if ((aZero | bZero) == 1'b1 || (aSubnormal & bSubnormal) == 1'b1) begin
            pTmp = {pSign, {(WIDTH-1){1'b0}}};
            out_zero = 1'b1;
        end
        else begin
            t1Exp = aExp + bExp;

            if (rawSignificand[2*SIG_BITS-1] == 1'b1) begin
                tSig = rawSignificand[2*SIG_BITS-1:SIG_BITS-1];
                t2Exp = t1Exp + 1;
                sigForRounding = {rawSignificand, {(INTn-2*SIG_BITS){1'b0}}};
            end
            else begin
                tSig = rawSignificand[2*SIG_BITS-2:SIG_BITS-2];
                t2Exp = t1Exp;
                sigForRounding = {rawSignificand, {(INTn-2*SIG_BITS){1'b0}}} << 1;
            end

            if (t2Exp < SUBNORM_MIN) begin
                pTmp = {pSign, {(WIDTH-1){1'b0}}};
                out_zero = 1'b1;
            end
            else if (t2Exp < EMIN) begin
                needs_rounding = 1'b1;
                pSig = roundedSig;
                pExp = roundedExp;
                pTmp = {pSign, {EXP_BITS{1'b0}}, pSig[MANT_BITS-1:0]};
                out_subnormal = 1'b1;
            end
            else if (t2Exp > EMAX) begin
                pTmp = {pSign, {EXP_BITS{1'b1}}, {MANT_BITS{1'b0}}};
                out_infinity = 1'b1;
            end
            else begin
                needs_rounding = 1'b1;
                pSig = roundedSig;
                pExp = roundedExp;

                if (pExp > EMAX) begin
                    pTmp = {pSign, {EXP_BITS{1'b1}}, {MANT_BITS{1'b0}}};
                    out_infinity = 1'b1;
                end
                else begin
                    biased_exp = pExp + BIAS;
                    pTmp = {pSign, biased_exp[EXP_BITS-1:0], pSig[MANT_BITS-1:0]};
                    out_normal = 1'b1;
                end
            end
        end
    end

    assign p = pTmp;

endmodule
