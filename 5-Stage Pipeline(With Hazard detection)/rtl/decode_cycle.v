module decode_cycle #(parameter WIDTH = 32)(
    input  clk, reset, nflush,
    input  [31:0]instrD,
    input  [WIDTH-1:0]pcD, pc_plus4D,
    input  reg_writeW,
    input  [4:0]rd_addrW,
    input  [WIDTH-1:0]resultW,
    output reg_writeE,
    output [1:0]result_srcE,
    output mem_writeE,
    output branchE,
    output [3:0]alu_controlE,
    output alu_srcE,
    output [WIDTH-1:0]rs1_dataE, rs2_dataE, pcE,
    output [4:0]rd_addrE,
    output [WIDTH-1:0]imm_extendE,
    output [WIDTH-1:0]pc_plus4E,
    output [2:0]funct3E,
    output [4:0]rs1_E,rs2_E
);

//Intermediate-wires
wire [1:0]result_srcD;
wire mem_writeD, alu_srcD, reg_writeD, branchD;
wire [4:0]rd_addrD;
wire [3:0]alu_controlD;
wire [1:0]imm_srcD;
wire [WIDTH-1:0]rs1_dataD, rs2_dataD, imm_extendD;

//Decode registers declaration
reg reg_writeD_reg, mem_writeD_reg, branchD_reg, alu_srcD_reg;
reg [1:0]result_srcD_reg;
reg [3:0]alu_controlD_reg;
reg [WIDTH-1:0]rs1_dataD_reg, rs2_dataD_reg, pcD_reg, imm_extendD_reg, pc_plus4D_reg;
reg [4:0]rd_addrD_reg,rs1_D_r,rs2_D_r;
reg [2:0]funct3D_reg;

//controller instantiation
controller cp(instrD[6:0], instrD[14:12], instrD[30], instrD[5], branchD, result_srcD, mem_writeD, alu_controlD, alu_srcD, imm_srcD, reg_writeD);

//register file instantiation
reg_file #(32) rf(clk, reset, instrD[19:15], instrD[24:20], rd_addrW, reg_writeW, resultW, rs1_dataD, rs2_dataD);

//Immediate extend instantiation
imm_extend #(32) imm(instrD[31:7], imm_srcD, imm_extendD);

//Decode-registers logic
always @(posedge clk or negedge reset) begin
    if(!nflush) begin
        reg_writeD_reg   <= 0;
        result_srcD_reg  <= 0;
        mem_writeD_reg   <= 0;
        branchD_reg      <= 0;
        alu_controlD_reg <= 0;
        alu_srcD_reg     <= 0;
        rs1_dataD_reg     <= 0;
        rs2_dataD_reg     <= 0;
        pcD_reg          <= 0;
        rd_addrD_reg     <= 0;
        imm_extendD_reg  <= 0;
        pc_plus4D_reg    <= 0;
        funct3D_reg      <= 0;
        rs1_D_r          <= 0;
        rs2_D_r          <= 0;
    end
    else begin
        reg_writeD_reg   <= reg_writeD;
        result_srcD_reg  <= result_srcD;
        mem_writeD_reg   <= mem_writeD;
        branchD_reg      <= branchD;
        alu_controlD_reg <= alu_controlD;
        alu_srcD_reg     <= alu_srcD;
        rs1_dataD_reg    <= rs1_dataD;
        rs2_dataD_reg    <= rs2_dataD;
        pcD_reg          <= pcD;
        rd_addrD_reg     <= rd_addrD;
        imm_extendD_reg  <= imm_extendD;
        pc_plus4D_reg    <= pc_plus4D;
        funct3D_reg      <= instrD[14:12];
        rs1_D_r          <= instrD[19:15];
        rs2_D_r          <= instrD[24:20];
    end
end

assign rd_addrD = instrD[11:7];


//Outputs-logic
assign reg_writeE   = reg_writeD_reg;
assign result_srcE  = result_srcD_reg;
assign mem_writeE   = mem_writeD_reg;
assign branchE      = branchD_reg;
assign alu_controlE = alu_controlD_reg;
assign alu_srcE     = alu_srcD_reg;
assign rs1_dataE    = rs1_dataD_reg;
assign rs2_dataE    = rs2_dataD_reg;
assign pcE          = pcD_reg;
assign rd_addrE     = rd_addrD_reg;
assign imm_extendE  = imm_extendD_reg;
assign pc_plus4E    = pc_plus4D_reg;
assign funct3E      = funct3D_reg;
assign rs1_E        = rs1_D_r;
assign rs2_E        = rs2_D_r;

endmodule
