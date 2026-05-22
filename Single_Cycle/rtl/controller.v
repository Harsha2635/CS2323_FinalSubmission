module controller(
    input  [6:0]opcode,
    input  [2:0]funct3,
    input  funct7_5, funct7_1, op_5,
    input  zero, msb, sltu,
    output reg pc_src,
    output [1:0]result_src,
    output mem_write,
    output reg [4:0]alu_control,
    output alu_src,
    output [1:0]imm_src,
    output reg_write,
    output jalr
);
    
    reg [10:0]controls;
    wire branch;
    wire [1:0]alu_op;

    //Branch_resultSrc_memWrite_aluSrc_immSrc_regWrite_aluOp_jalr
    always @(*) begin
        casez(opcode)
            7'b0000011 : controls = 11'b0_01_0_1_00_1_00_0; //ld, etc.
            7'b0010011 : controls = 11'b0_00_0_1_00_1_10_0; //addi, etc.
            7'b0100011 : controls = 11'b0_01_1_1_01_0_00_0; //sd, etc.
            7'b0110011 : controls = 11'b0_00_0_0_xx_1_10_0; //add, mul, div, rem etc.
            7'b1100011 : controls = 11'b1_xx_0_0_10_0_01_0; //beq, etc.
            7'b0?10111 : controls = 11'b0_11_0_x_xx_1_xx_0; //lui, auipc
            7'b1101111 : controls = 11'b0_10_0_x_11_1_xx_0; //jal
            7'b1100111 : controls = 11'b0_10_0_1_00_1_xx_1; //jalr

            default    : controls = 11'bx_xx_x_x_xx_x_xx_0; //invalid opcode
        endcase
    end

    assign {branch, result_src, mem_write, alu_src, imm_src, reg_write, alu_op, jalr} = controls;

    always @(*) begin
        pc_src = 0;
        
        //pc_src determination

        if(opcode == 7'b1101111)begin           //jal
            pc_src = 1;
        end

        else if(opcode == 7'b1100011)begin    //Branch instruction
            if(branch) begin 
                case(funct3)
                    3'b000 : pc_src = zero;   //beq
                    3'b001 : pc_src = ~zero;  //bne
                    3'b100 : pc_src = msb;    //blt
                    3'b101 : pc_src = ~msb;   //bge
                    3'b110 : pc_src = sltu;   //bltu
                    3'b111 : pc_src = ~sltu;  //bgeu
                    default : pc_src = 1'bx;
                endcase
            end
        end


        //alu_control determination
        case(alu_op)
            2'b00 : alu_control = 5'b00000; //addition
            2'b01 : alu_control = 5'b00001; //subtraction
            2'b10 : begin
                if(funct7_1==0) begin
                    case(funct3)
                        3'b000 : begin
                            if(funct7_5 & op_5) alu_control = 5'b00001; //sub
                            else alu_control = 5'b00000;              //add, addi
                        end
                        3'b001 : alu_control = 5'b00010; //sll
                        3'b010 : alu_control = 5'b00011; //slt
                        3'b011 : alu_control = 5'b00100; //sltu
                        3'b100 : alu_control = 5'b00101; //xor
                        3'b101 : begin
                            if(~funct7_5) alu_control = 5'b00110; //srl
                            else alu_control = 5'b00111;          //sra
                        end
                        3'b110 : alu_control = 5'b01000;  //or
                        3'b111 : alu_control = 5'b01001;  //and
                    endcase
                end
                else begin
                        case(funct3)
                            3'b000 : alu_control = 5'b10000; //mul
                            3'b001 : alu_control = 5'b10001; //mulh
                            3'b010 : alu_control = 5'b10010; //mulhsu
                            3'b011 : alu_control = 5'b10011; //mulhu
                            3'b100 : alu_control = 5'b10100; //div
                            3'b101 : alu_control = 5'b10101; //divu
                            3'b110 : alu_control = 5'b10110; //rem
                            3'b111 : alu_control = 5'b10111; //remu
                        endcase
                end
            end
        endcase
    end

    

endmodule
