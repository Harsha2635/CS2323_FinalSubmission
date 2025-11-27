module reg_file_f(
    input  clk, reset,
    // input  fsd,
    input  [4:0]rs1_addr,  rs2_addr, rd_addr,
    input  reg_write,
    input  [63:0]wr_data,
    output [63:0]rs1_data, rs2_data
);

localparam n_regs = 32;

reg [63:0]reg_file_array[0:n_regs-1];

integer i;

initial begin
    reg_file_array[1] <= 64'h40000000;
    reg_file_array[2] <= 64'h40000000;
end

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        for(i = 0; i < n_regs; i=i+1) begin
            reg_file_array[i] = -1;
        end
    end
    else begin
        if(reg_write) reg_file_array[rd_addr] = wr_data;
    end
    // else if(!fsd) begin    //single-precision
    //     if(reg_write) reg_file_array[rd_addr][31:0] = wr_data[31:0];
    // end
    // else begin
    //     if(reg_write) reg_file_array[rd_addr] = wr_data;
    // end
end

assign rs1_data = reg_file_array[rs1_addr];
assign rs2_data = reg_file_array[rs2_addr];

endmodule