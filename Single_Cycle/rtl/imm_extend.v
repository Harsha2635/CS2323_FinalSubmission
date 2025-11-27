module imm_extend #(parameter WIDTH = 32)(
    input      [31 : 7]instr,
    input      [1 : 0]imm_src,
    output reg [WIDTH - 1 : 0]imm_extend
);

always @(*) begin
    if (WIDTH == 32) begin
        case(imm_src)
            2'b00 : imm_extend = {{20{instr[31]}}, instr[31:20]};                // I - Type
            2'b01 : imm_extend = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S - Type
            2'b10 : imm_extend = {{19{instr[31]}}, instr[31], instr[7], instr[30 : 25], instr[11 : 8], 1'b0}; // B - Type Instructions
            2'b11 : imm_extend = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J - Type Instructions
            default : imm_extend = 32'bx;
        endcase
    end
    else begin
        case(imm_src)
            2'b00 : imm_extend = {{52{instr[31]}}, instr[31:20]};                // I - Type
            2'b01 : imm_extend = {{52{instr[31]}}, instr[31:25], instr[11:7]}; // S - Type
            2'b10 : imm_extend = {{51{instr[31]}}, instr[31], instr[7], instr[30 : 25], instr[11 : 8], 1'b0}; // B - Type Instructions
            2'b11 : imm_extend = {{43{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J - Type Instructions
            default : imm_extend = 64'bx;
        endcase
    end
end

endmodule