module flipflop #(parameter WIDTH = 32)(
    input  clk, reset, enable,
    input  [WIDTH-1:0]d,
    output reg [WIDTH-1:0]q
);

always @(posedge clk or negedge reset) begin
    if(!reset) q <= 0;
    else if(!enable) q <= q;
    else q<= d;
end

endmodule
