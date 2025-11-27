module fetch_cycle #(parameter WIDTH = 32)(
    input  clk, reset, nflush, nenable, nff_enable,
    input  pc_srcE,
    input  [WIDTH-1:0]pc_targetE,
    output [31:0]instrD,
    output [WIDTH-1:0]pcD,
    output [WIDTH-1:0]pc_plus4D
);


//Intermediate wires
wire [WIDTH-1:0]pc_plus4F, pc_nextF, pcF;
wire [31:0]instrF;

//Registers declaration
reg [WIDTH-1:0]pcF_reg, pc_plus4F_reg;
reg [31:0]instrF_reg;

//PC instantiations
mux2 #(WIDTH)pc_muxF(pc_plus4F, pc_targetE, pc_srcE, pc_nextF);
flipflop #(WIDTH)pc_ffF(clk, reset, nff_enable, pc_nextF, pcF);
adder #(WIDTH)pc_plus4adderF(pcF,  {{(WIDTH-32){1'b0}}, 32'd4}, pc_plus4F);


//Instruction register Instantiation
instr_mem #(32, 32, 512)imF(pcF, instrF);

//Fetch-Register logic
always @(posedge clk or negedge reset) begin
    if(!nflush) begin
        instrF_reg   <= 0;
        pcF_reg      <= 0;
        pc_plus4F_reg <= 0;
    end
    else if(!nenable) begin
        instrF_reg    <= instrF_reg;
        pcF_reg       <= pcF_reg;
        pc_plus4F_reg <= pc_plus4F_reg;
    end
    else begin
        instrF_reg    <= instrF;
        pcF_reg       <= pcF;
        pc_plus4F_reg <= pc_plus4F;
    end
end

//outputs
assign instrD    = instrF_reg;
assign pcD       = pcF_reg;
assign pc_plus4D = pc_plus4F_reg;


endmodule
