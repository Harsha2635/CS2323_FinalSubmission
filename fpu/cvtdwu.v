module cvtdwu (
    input  [31:0] in,
    output reg [63:0] out
);
    reg sign;
    reg [10:0] exp;
    reg [51:0] frac;

    integer i;
    integer shift;
    reg [31:0] value;
    reg [63:0] mantissa;
    integer leading_one_pos;

    always @(*) begin
        value = in;
        sign = 1'b0;

        if (value == 0) begin
            out = 64'd0;
        end else begin
            leading_one_pos = -1;
            for (i = 31; i >= 0; i = i - 1)
                if (value[i] && leading_one_pos == -1)
                    leading_one_pos = i;

            exp = 1023 + leading_one_pos;
            mantissa = ((value << (52 - leading_one_pos)) & 64'hFFFFFFFFFFFFF);

            frac = mantissa[51:0];
            out = {sign, exp[10:0], frac};
        end
    end
endmodule
