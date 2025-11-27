module datapath #(parameter WIDTH=64)(
    input  clk, reset,
    input  [31:0]instr,
    input  pc_src, jalr,
    input  [1:0]result_src,
    input  mem_write,
    input  [4:0]alu_control,
    input  alu_src,
    input  [1:0]imm_src,
    input  reg_write,
    input  [WIDTH-1:0]read_data,
    input  reg_write_f,
    input  [1:0]result_src_f,
    input  [1:0]fpu_ctrl,
    input  int_float,
    output [WIDTH-1:0]pc,
    output zero, msb, sltu, 
    output [WIDTH-1:0]mem_wr_data,
    output [WIDTH-1:0]mem_wr_addr,
    output [WIDTH-1:0]result,
    output [63:0]wr_data_f
);


//Intermediate wires
wire [WIDTH-1:0]pc_plus4, pc_target, pc_next, pc_next_jalr;
wire [WIDTH-1:0]rs1_data, rs2_data, imm_extend, srcA, srcB, alu_result;
wire [63:0]rs1_data_f, rs2_data_f;
wire [31:0]outf32;
wire [63:0]outf64;

//PC-Logic(Instantiations)
mux2 #(WIDTH) main_pc_mux(pc_plus4, pc_target, pc_src, pc_next);
mux2 #(WIDTH) jalr_pc_mux(pc_next, alu_result, jalr, pc_next_jalr);
flipflop #(WIDTH) pc_ff(clk, reset, pc_next_jalr, pc);
adder #(WIDTH) pc_plus4adder(pc, 64'd4, pc_plus4);
adder #(WIDTH) pc_target_adder(pc, imm_extend, pc_target);

//Register-file logic(Instantiations)
reg_file #(WIDTH) main_reg_file(clk, reset, instr[19:15], instr[24:20], instr[11:7], reg_write, result, rs1_data, rs2_data);

//Immediate-extend block instantiation
imm_extend #(WIDTH) imm_extendBlock(instr[31:7], imm_src, imm_extend);

//Selecting b/w rs2 and imm
mux2 #(WIDTH) alusrc_mux(rs2_data, imm_extend, alu_src, srcB);
assign srcA = rs1_data;

//ALU-Instantiation
alu #(WIDTH) main_alu(srcA, srcB, alu_control, alu_result, zero, msb, sltu);

//lui, auipc Logic
wire [WIDTH-1:0] lui = {{(WIDTH-32){1'b0}}, instr[31:12], 12'b0};
wire [WIDTH-1:0]auipc, lauipc;
adder #(WIDTH) auipc_adder(pc, lui, auipc);
mux2 #(WIDTH) lauipc_mux(auipc, lui, instr[5], lauipc);


//For F-Extension

//f_register
reg_file_f float_reg_file(clk, reset, instr[19:15], instr[24:20], instr[11:7], reg_write_f, wr_data_f, rs1_data_f, rs2_data_f);

wire [31:0]rs1_data_f32, rs2_data_f32;
assign rs1_data_f32 = rs1_data_f[31:0];
assign rs2_data_f32 = rs2_data_f[31:0];

fpu_32 fpu32_unit(rs1_data_f32, rs2_data_f32, fpu_ctrl, outf32);
fpu_64 fpu64_unit(rs1_data_f, rs2_data_f, fpu_ctrl, outf64);


//Result-mux
mux4 #(WIDTH) result_mux(alu_result, read_data, pc_plus4, lauipc, result_src, result);

//Resultf-mux
wire [63:0]outf32_padded = {32'hffffffff, outf32};
wire [63:0]read_data_padded = {{32{1'b1}}, read_data[31:0]};
mux4 #(64) result_muxf(outf32_padded, outf64, read_data_padded, read_data, result_src_f, wr_data_f);

assign mem_wr_data = int_float ? rs2_data_f : rs2_data;
assign mem_wr_addr = alu_result;

endmodule