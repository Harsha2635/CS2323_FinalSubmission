module instr_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 64, MEM_SIZE = 512) (
    input       [ADDR_WIDTH-1:0] instr_addr,
    output      [DATA_WIDTH-1:0] instr
);

// array of MEM_SIZE words, each DATA_WIDTH wide
reg [DATA_WIDTH-1:0] instr_ram [0:MEM_SIZE-1];

initial begin
//    $readmemh("instr_mem_contents.hex", instr_ram);
    instr_ram[0] <= 32'h00100093;
    instr_ram[1] <= 32'h1020f1d3;
    instr_ram[2] <= 32'h1011f253;
    instr_ram[3] <= 32'h00403027;  
    instr_ram[4] <= 32'h00003287;
    instr_ram[5] <= 32'h0012f353;
end

// word-aligned memory access
// use correct bits of instr_addr to index instr_ram
assign instr = instr_ram[instr_addr[$clog2(MEM_SIZE)+1 : 2]];

endmodule