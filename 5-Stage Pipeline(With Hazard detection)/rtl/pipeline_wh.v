module pipeline_wh #(parameter WIDTH=32)(
    input clk, reset,
    output [WIDTH-1:0]result
);

//Intermediate wires
wire pc_srcE, reg_writeW, reg_writeE, mem_writeE, branchE, alu_srcE, reg_writeM, mem_writeM,StallF,StallD,FlushD,FlushE,result_srcE0;
wire [31:0]instrD;
wire [WIDTH-1:0]pc_targetE, pcD, pc_plus4D, resultW, rs1_dataE, rs2_dataE, pcE, imm_extendE, pc_plus4E, alu_resultM, write_dataM, pc_plus4M, alu_resultW, read_dataW, pc_plus4W, mem_result;
wire [4:0]rd_addrW, rd_addrE, rd_addrM;
wire [1:0]result_srcE, result_srcM, result_srcW;
wire [3:0]alu_controlE;
wire [2:0]funct3E, funct3M;
wire [4:0]rs1_E,rs2_E;
wire [1:0]forwardAE, forwardBE;

//fetch-cycle
fetch_cycle #(32) fc(clk, reset, FlushD, StallD, StallF, pc_srcE, pc_targetE, instrD, pcD, pc_plus4D);

//decode-cycle
decode_cycle #(32) dc(clk,reset, FlushE, instrD, pcD, pc_plus4D, reg_writeW, rd_addrW, resultW, reg_writeE, result_srcE, mem_writeE, branchE, alu_controlE, alu_srcE, rs1_dataE, rs2_dataE, pcE, rd_addrE, imm_extendE, pc_plus4E, funct3E,rs1_E,rs2_E);

//execute-cycle
execute_cycle #(32) ec(clk, reset, reg_writeE, result_srcE, mem_writeE, branchE, alu_controlE, alu_srcE, rs1_dataE, rs2_dataE, pcE, rd_addrE, imm_extendE, pc_plus4E, funct3E, resultW, forwardAE, forwardBE, mem_result, pc_srcE, pc_targetE, reg_writeM, result_srcM, mem_writeM, alu_resultM, write_dataM, rd_addrM, pc_plus4M, funct3M);

//memory-cycle
memory_cycle #(32) mc(clk, reset, reg_writeM, result_srcM, mem_writeM, alu_resultM, write_dataM, rd_addrM, pc_plus4M, funct3M, reg_writeW, result_srcW, alu_resultW, read_dataW, rd_addrW, pc_plus4W, mem_result);

//write-back cycle
writeback_cycle #(32) wc(result_srcW, alu_resultW, read_dataW, pc_plus4W, resultW);

//hazard unit
hazard_unit forwarding(reset,reg_writeM,reg_writeW,rd_addrM,rd_addrW,rs1_E,rs2_E, instrD[19:15], instrD[24:20], instrD,rd_addrE,result_srcE,pc_srcE,forwardAE,forwardBE,StallF,StallD,FlushD,FlushE);


assign result = resultW;

endmodule
