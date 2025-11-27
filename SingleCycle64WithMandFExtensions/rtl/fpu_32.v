module fpu_32(
    input  [31:0]a, b,
    input  [1:0]fpu_ctrl,
    output reg [31:0]out
);

wire [31:0]fadds, fsubs, fmuls, fdivs;

fp_add_exact #(32)fpu_add32(a, b, 6'b000001, fadds);
fp_add_exact #(32)fpu_sub32(a, b^(32'h80000000),  6'b000001, fsubs);
hp_mul #(32)fpu_mul32(a, b, 6'b000001, fmuls);
// fp_div #(32)fpu_div32(a, b, 6'b000001, fdivs);

always @(*) begin
    case(fpu_ctrl)
        2'b00 : out <= fadds;
        2'b01 : out <= fsubs;
        2'b10 : out <= fmuls;
        2'b11 : out <= fdivs;
    endcase
end

endmodule