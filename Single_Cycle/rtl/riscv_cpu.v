module riscv_cpu #(parameter WIDTH=32)(
    input  clk, reset,
    input  [31:0]instr,
    input  [WIDTH-1:0]rs1_data, rs2_data, read_data,
    output [WIDTH-1:0]pc,
    output [WIDTH-1:0]mem_wr_addr,
    output [WIDTH-1:0]mem_wr_data,
    output mem_write,
    output [2:0]funct3,
    output [WIDTH-1:0]result, [4:0]rs1_addr, [4:0]rs2_addr, [4:0]rd_addr, 
    output reg_write
);

//Intermediate wires
wire pc_src, alu_src;
wire [1:0]result_src, imm_src;
wire [4:0]alu_control;
wire zero, msb, sltu, jalr;

//datapath instantiation
datapath #(WIDTH) dp(clk, reset, instr, pc_src, jalr, result_src, mem_write, alu_control, alu_src, imm_src, reg_write, rs1_data, rs2_data, read_data, pc, zero, msb, sltu, mem_wr_data, mem_wr_addr, result);

//controller instantiation
controller cp(instr[6:0], instr[14:12], instr[30], instr[25], instr[5], zero, msb, sltu, pc_src, result_src, mem_write, alu_control, alu_src, imm_src, reg_write, jalr);

assign funct3 = instr[14:12];
assign rs1_addr = instr[19:15];
assign rs2_addr = instr[24:20];
assign rd_addr = instr[11:7];

endmodule