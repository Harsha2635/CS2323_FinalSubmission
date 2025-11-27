module top_riscv_single #(parameter WIDTH=32)(
    input clk, reset,
    output [WIDTH-1:0]result,
    output [WIDTH-1:0]pc,
    output [WIDTH-1:0]read_data, mem_wr_addr, mem_wr_data,
    output led
);

wire [31:0]instr;
wire [2:0]funct3;
wire mem_write;

riscv_cpu #(32) cpu(clk, reset, instr, read_data, pc, mem_wr_addr, mem_wr_data, mem_write, funct3, result);

instr_mem #(32, 32) im(pc, instr);

data_mem #(32, 32) dm(clk, reset, mem_write, mem_wr_data, mem_wr_addr, funct3, read_data);

assign led = (result==={WIDTH{1'bx}}) ? 1 : 0;

endmodule
