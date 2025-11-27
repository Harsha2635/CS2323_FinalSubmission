module hazard_unit(rst,reg_writeM,reg_writeW,rd_addrM,rd_writeW,rs1_E,rs2_E,rs1_addrD, rs2_addrD, instrD,rd_addrE,result_srcE,pc_srcE,forwardAE,forwardBE,StallF,StallD,FlushD,FlushE);

    // Declaration of I/Os
    input rst,reg_writeM,reg_writeW;
    input [1:0]result_srcE;
    input pc_srcE;
    input [4:0] rd_addrM,rd_writeW,rs1_E,rs2_E,rs1_addrD, rs2_addrD, rd_addrE;
    input [31:0] instrD;
    output [1:0] forwardAE,forwardBE;
    output StallD,StallF,FlushD,FlushE;

    assign forwardAE = (rst == 1'b0) ? 2'b00 :
                       ((reg_writeM == 1'b1) & (rd_addrM != 5'h00) & (rd_addrM == rs1_E)) ? 2'b10 :
                       ((reg_writeW == 1'b1) & (rd_writeW != 5'h00) & (rd_writeW == rs1_E)) ? 2'b01 : 2'b00;

    assign forwardBE = (rst == 1'b0) ? 2'b00 :
                       ((reg_writeM == 1'b1) & (rd_addrM != 5'h00) & (rd_addrM == rs2_E)) ? 2'b10 :
                       ((reg_writeW == 1'b1) & (rd_writeW != 5'h00) & (rd_writeW == rs2_E)) ? 2'b01 : 2'b00;

    wire lwStall;

    assign lwStall = (result_srcE==2'b01) & ((rs1_addrD == rd_addrE) | (rs2_addrD == rd_addrE));
    assign StallF = !lwStall;
    assign StallD = !lwStall;
    assign FlushD = !pc_srcE;
    assign FlushE = !(lwStall|pc_srcE);

endmodule
