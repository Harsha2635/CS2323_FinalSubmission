module execute_cycle #(parameter WIDTH = 32)(
    input  clk, reset,
    input  reg_writeE,
    input  [1:0]result_srcE,
    input  mem_writeE,
    input  branchE,
    input  [3:0]alu_controlE,
    input  alu_srcE,
    input  [WIDTH-1:0]rs1_dataE, rs2_dataE, pcE,
    input  [4:0]rd_addrE,
    input  [WIDTH-1:0]imm_extendE, pc_plus4E,
    input  [2:0]funct3E,
    output reg pc_srcE,
    output [WIDTH-1:0]pc_targetE,
    output reg_writeM,
    output [1:0]result_srcM,
    output mem_writeM,
    output [WIDTH-1:0]alu_resultM, write_dataM,
    output [4:0]rd_addrM,
    output [WIDTH-1:0]pc_plus4M,
    output [2:0]funct3M
);

//Intermediate wires
wire [WIDTH-1:0]srcBE, srcAE, alu_resultE, write_dataE;
wire zeroE, msbE, sltuE;


//regs declaration
reg reg_writeE_reg, mem_writeE_reg;
reg [1:0]result_srcE_reg;
reg [WIDTH-1:0]alu_resultE_reg, write_dataE_reg, pc_plus4E_reg;
reg [4:0]rd_addrE_reg;
reg [2:0]funct3E_reg;

assign srcAE = rs1_dataE;
//ALU-SRC Mux instantiation
mux2 #(32) alu_src_mux(rs2_dataE, imm_extendE, alu_srcE, srcBE);

//ALU Instantiation
alu #(32) main_alu(srcAE, srcBE, alu_controlE, alu_resultE, zeroE, msbE, sltuE);

//pc-target adder
adder #(32) pct_adder(pcE, imm_extendE, pc_targetE);

//pcsrc andgate
always @(*) begin
    pc_srcE <= 0;
    if(branchE) begin
        case(funct3E)
            3'b000 : pc_srcE <= (zeroE);  //beq
            3'b001 : pc_srcE <= (!zeroE);  //bne
            3'b100 : pc_srcE <= (msbE);  //blt
            3'b101 : pc_srcE <= (!msbE);  //bge
            3'b110 : pc_srcE <= (sltuE);  //bltu
            3'b111 : pc_srcE <= (!sltuE);  //bgeu
            default : pc_srcE <= 0;
        endcase
    end
end

//Execute registers logic

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        reg_writeE_reg  <= 0;
        result_srcE_reg <= 0;
        mem_writeE_reg  <= 0;
        alu_resultE_reg <= 0;
        write_dataE_reg <= 0;
        rd_addrE_reg    <= 0;
        pc_plus4E_reg   <= 0;
        funct3E_reg     <= 0;
    end
    else begin /* beginpc_srcE = (branchE & !zeroE);  //bne */
        reg_writeE_reg  <= reg_writeE;
        result_srcE_reg <= result_srcE;
        mem_writeE_reg  <= mem_writeE;
        alu_resultE_reg <= alu_resultE;
        write_dataE_reg <= write_dataE;
        rd_addrE_reg    <= rd_addrE;
        pc_plus4E_reg   <= pc_plus4E;
        funct3E_reg     <= funct3E;
    end
end

//outputs logic

assign reg_writeM  = reg_writeE_reg;
assign result_srcM = result_srcE_reg;
assign mem_writeM  = mem_writeE_reg;
assign alu_resultM = alu_resultE_reg;
assign write_dataM = write_dataE_reg;
assign rd_addrM    = rd_addrE_reg;
assign pc_plus4M   = pc_plus4E_reg;
assign funct3M     = funct3E_reg;

endmodule
