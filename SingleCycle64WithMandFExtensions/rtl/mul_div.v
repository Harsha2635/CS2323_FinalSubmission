module muldiv_alu#(parameter WIDTH = 32)(
    input [WIDTH-1:0]a, b,
    output [(2*WIDTH-1):0] mul, mulsu, mulu,
    output [WIDTH-1:0]div, divu, rem, remu
);
    assign mul   = $signed(a)   * $signed(b);
    assign mulsu = $signed(a)   * $unsigned(b);
    assign mulu  = $unsigned(a) * $unsigned(b);
    assign div   = (b != 0) ? ($signed(a)   / $signed(b)) : 32'd0;
    assign divu  = (b != 0) ? ($unsigned(a) / $unsigned(b)) : 32'd0;
    assign rem   = (b != 0) ? ($signed(a)   % $signed(b)) : 32'd0;
    assign remu  = (b != 0) ? ($unsigned(a) % $unsigned(b)) : 32'd0;

endmodule