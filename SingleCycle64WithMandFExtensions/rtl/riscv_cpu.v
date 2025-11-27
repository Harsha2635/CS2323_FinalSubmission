module riscv_cpu #(parameter WIDTH=64)(
    input  clk, reset,
    input  [31:0]instr,
    input  [WIDTH-1:0]read_data,
    output [WIDTH-1:0]pc,
    output [WIDTH-1:0]mem_wr_addr,
    output [WIDTH-1:0]mem_wr_data,
    output mem_write,
    output [2:0]funct3,
    output [WIDTH-1:0]result, wr_data_f
);

//Intermediate wires
wire pc_src, alu_src, reg_write, int_float, reg_write_f;
wire [1:0]result_src, imm_src, fpu_ctrl, result_src_f;
wire [4:0]alu_control;
wire zero, msb, sltu, jalr;

//datapath instantiation
datapath #(WIDTH) dp(clk, reset, instr, pc_src, jalr, result_src, mem_write, alu_control, alu_src, imm_src, reg_write, read_data, reg_write_f, result_src_f, fpu_ctrl, int_float, pc, zero, msb, sltu, mem_wr_data, mem_wr_addr, result, wr_data_f);

//controller instantiation
controller cp(instr[6:0], instr[14:12], instr[30], instr[25], instr[5], instr[31:27], zero, msb, sltu, pc_src, result_src, mem_write, alu_control, alu_src, imm_src, reg_write, jalr, reg_write_f, fpu_ctrl, int_float, result_src_f);

assign funct3 = instr[14:12];

endmodule