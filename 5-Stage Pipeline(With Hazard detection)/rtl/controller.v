module controller(
    input  [6:0]opcode,
    input  [2:0]funct3,
    input  funct7_5, op_5,
    // input  zero, msb, sltu,
    output branch,
    output [1:0]result_src,
    output mem_write,
    output reg [3:0]alu_control,
    output alu_src,
    output [1:0]imm_src,
    output reg_write
);
    
    reg [9:0]controls;
    wire [1:0]alu_op;

    //Branch_resultSrc_memWrite_aluSrc_immSrc_regWrite_aluOp
    always @(*) begin
        case(opcode)
            7'b0000011 : controls = 10'b0_01_0_1_00_1_00; //ld, etc.
            7'b0010011 : controls = 10'b0_00_0_1_00_1_10; //addi, etc.
            7'b0100011 : controls = 10'b0_xx_1_1_01_0_00; //sd, etc.
            7'b0110011 : controls = 10'b0_00_0_0_xx_1_10; //add, etc.
            7'b1100011 : controls = 10'b1_xx_0_1_10_0_01; //beq, etc.
            default    : controls = 10'bx_xx_x_x_xx_x_xx; //invalid opcode
        endcase
    end

    assign {branch, result_src, mem_write, alu_src, imm_src, reg_write, alu_op} = controls;

    always @(*) begin
        // pc_src = 0;

        //pc_src determination
        // if(branch) begin //Branch instruction
        //     case(funct3)
        //         3'b000 : pc_src = zero;   //beq
        //         3'b001 : pc_src = ~zero;  //bne
        //         3'b100 : pc_src = msb;  //blt
        //         3'b101 : pc_src = ~msb;  //bge
        //         3'b110 : pc_src = sltu;  //bltu
        //         3'b111 : pc_src = ~sltu;  //bgeu
        //         default : pc_src = 1'bx;
        //     endcase
        // end


        //alu_control determination
        case(alu_op)
            2'b00 : alu_control = 4'b0000; //addition
            2'b01 : alu_control = 4'b0001; //subtraction
            2'b10 : begin
                case(funct3)
                    3'b000 : begin
                        if(funct7_5 & op_5) alu_control = 4'b0001; //sub
                        else alu_control = 4'b0000;              //add, addi
                    end
                    3'b001 : alu_control = 4'b0010; //sll
                    3'b010 : alu_control = 4'b0011; //slt
                    3'b011 : alu_control = 4'b0100; //sltu
                    3'b100 : alu_control = 4'b0101; //xor
                    3'b101 : begin
                        if(~funct7_5) alu_control = 4'b0110; //srl
                        else alu_control = 4'b0111;          //sra
                    end
                    3'b110 : alu_control = 4'b1000;  //or
                    3'b111 : alu_control = 4'b1001;  //and
                endcase
            end
        endcase
    end

    

endmodule
