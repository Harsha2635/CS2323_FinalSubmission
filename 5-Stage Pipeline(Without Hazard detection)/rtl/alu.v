module alu #(parameter WIDTH = 32)(
    input  [WIDTH-1:0] a, b,
    input  [3:0] alu_control,
    output reg [WIDTH-1:0] alu_result,
    output zero, msb, sltu
);

    always @(*) begin
        case(alu_control)
            4'b0000 : alu_result = a + b;        //add
            4'b0001 : alu_result = a + ~b + 1;   //sub
            4'b0010 : alu_result = a << b;       //sll
            4'b0011 : begin                  //slt
                if(a[WIDTH-1] != b[WIDTH-1]) alu_result = a[WIDTH-1] ? 1 : 0;
                else alu_result = (a < b) ? 1 : 0;
            end
            4'b0100 : alu_result = (a < b) ? 1 : 0;//sltu
            4'b0101 : alu_result = a^b;            //xor
            4'b0110 : alu_result = a >> b;         //srl
            4'b0111 : alu_result = $signed(a) >>> b ;//sra
            4'b1000 : alu_result = a|b;            //or
            4'b1001 : alu_result = a&b;            //and
            default : alu_result = {WIDTH{1'bx}};
        endcase
    end

    assign zero = (alu_result==0) ? 1 : 0;
    assign msb  = alu_result[WIDTH-1];
    assign sltu = (a<b);

endmodule