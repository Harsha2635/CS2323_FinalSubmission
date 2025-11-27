module memory_cycle #(parameter WIDTH=32)(
    input  clk, reset,
    input  reg_writeM,
    input  [1:0]result_srcM,
    input  mem_writeM,
    input  [WIDTH-1:0]alu_resultM,
    input  [WIDTH-1:0]write_dataM,
    input  [4:0]rd_addrM,
    input  [WIDTH-1:0]pc_plus4M,
    input  [2:0]funct3M,
    output reg_writeW,
    output [1:0]result_srcW,
    output [WIDTH-1:0]alu_resultW, read_dataW,
    output [4:0]rd_addrW,
    output [WIDTH-1:0]pc_plus4W,
    output [WIDTH-1:0]mem_result
);

//Intermediate wires
wire [WIDTH-1:0]read_dataM;

//regs declaration
reg reg_writeM_reg;
reg [1:0]result_srcM_reg;
reg [WIDTH-1:0]alu_resultM_reg, read_dataM_reg, pc_plus4M_reg;
reg [4:0]rd_addrM_reg;

//data-memory instantiation
data_mem #(32, 32) dm(clk, reset, mem_writeM, write_dataM, alu_resultM, funct3M, read_dataM);

//Memory registers logic

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        reg_writeM_reg  <= 0;
        result_srcM_reg <= 0;
        alu_resultM_reg <= 0;
        read_dataM_reg  <= 0;
        pc_plus4M_reg   <= 0;
        rd_addrM_reg    <= 0;
    end
    else begin
        reg_writeM_reg  <= reg_writeM;
        result_srcM_reg <= result_srcM;
        alu_resultM_reg <= alu_resultM;
        read_dataM_reg  <= read_dataM;
        pc_plus4M_reg   <= pc_plus4M;
        rd_addrM_reg    <= rd_addrM;
    end
end

//output logic
assign reg_writeW   = reg_writeM_reg;
assign result_srcW  = result_srcM_reg;
assign alu_resultW  = alu_resultM_reg;
assign read_dataW   = read_dataM_reg;
assign pc_plus4W    = pc_plus4M_reg;
assign rd_addrW     = rd_addrM_reg;
assign mem_result   = result_srcM ? read_dataM : alu_resultM;

endmodule
