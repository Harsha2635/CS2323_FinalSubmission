module top_riscv_single #(parameter WIDTH=64)(
    input clk, reset,
    output [WIDTH-1:0]result, wr_data_f,
    output [WIDTH-1:0]pc,
    output [WIDTH-1:0]read_data, mem_wr_addr, mem_wr_data,
    output led
);

wire [31:0]instr;
wire [2:0]funct3;
wire mem_write;

riscv_cpu #(64) cpu(clk, reset, instr, read_data, pc, mem_wr_addr, mem_wr_data, mem_write, funct3, result, wr_data_f);

instr_mem #(32, 64) im(pc, instr);

data_mem #(64, 32) dm(clk, reset, mem_write, mem_wr_data, mem_wr_addr, funct3, read_data);

assign led = (result==={WIDTH{1'bx}}) ? 1 : 0;

endmodule
