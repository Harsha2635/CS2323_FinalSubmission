module datapath #(parameter WIDTH=32)(
    input  clk, reset,
    input  [31:0]instr,
    input  pc_src, jalr,
    input  [1:0]result_src,
    input  mem_write,
    input  [4:0]alu_control,
    input  alu_src,
    input  [1:0]imm_src,
    input  reg_write,
    input  [WIDTH-1:0]rs1_data, rs2_data, read_data,
    output [WIDTH-1:0]pc,
    output zero, msb, sltu, 
    output [WIDTH-1:0]mem_wr_data,
    output [WIDTH-1:0]mem_wr_addr,
    output [WIDTH-1:0]result
);


//Intermediate wires
wire [WIDTH-1:0]pc_plus4, pc_target, pc_next, pc_next_jalr;
wire [WIDTH-1:0]imm_extend, srcA, srcB, alu_result;

//PC-Logic(Instantiations)
mux2 #(WIDTH) main_pc_mux(pc_plus4, pc_target, pc_src, pc_next);
mux2 #(WIDTH) jalr_pc_mux(pc_next, alu_result, jalr, pc_next_jalr);
flipflop #(WIDTH) pc_ff(clk, reset, pc_next_jalr, pc);
adder #(WIDTH) pc_plus4adder(pc, {{(WIDTH-32){1'b0}}, 32'd4}, pc_plus4);
adder #(WIDTH) pc_target_adder(pc, imm_extend, pc_target);

//Register-file logic(Instantiations)
//reg_file #(WIDTH) main_reg_file(clk, reset, instr[19:15], instr[24:20], instr[11:7], reg_write, result, rs1_data, rs2_data);

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

//Result-mux
mux4 #(WIDTH) result_mux(alu_result, read_data, pc_plus4, lauipc, result_src, result);

assign mem_wr_data = rs2_data;
assign mem_wr_addr = alu_result;

endmodule