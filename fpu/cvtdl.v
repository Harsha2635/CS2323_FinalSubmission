module cvtdl (
    input  signed [63:0] int_in,
    output reg [63:0] double_out
);
    reg sign;
    reg [63:0] abs_val;
    integer exponent;
    reg [10:0] biased_exp;
    reg [51:0] mantissa;
    reg [63:0] tmp;

    integer i;

    always @(*) begin
        if (int_in == 0) begin
            double_out = 64'b0;
        end else begin
            sign = int_in[63];
            abs_val = sign ? -int_in : int_in;

            exponent = -1;
            for (i = 63; i >= 0; i = i - 1)
                if (abs_val[i] && exponent == -1)
                    exponent = i;

            biased_exp = exponent + 1023;
            mantissa = (abs_val << (52 - exponent)) & 64'hFFFFFFFFFFFFF;
            double_out = {sign, biased_exp, mantissa};
        end
    end
endmodule
