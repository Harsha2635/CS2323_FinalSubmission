module writeback_cycle #(parameter WIDTH=32)(
    input  [1:0]result_srcW,
    input  [WIDTH-1:0]alu_resultW,
    input  [WIDTH-1:0]read_dataW,
    input  [WIDTH-1:0]pc_plus4W,
    output [WIDTH-1:0]resultW
);

//result-mux instantiation
mux3 #(32)result_mux(alu_resultW, read_dataW, pc_plus4W, result_srcW, resultW);

endmodule