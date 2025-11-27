module alu #(parameter WIDTH = 32)(
    input  [WIDTH-1:0] a, b,
    input  [4:0] alu_control,
    output reg [WIDTH-1:0] alu_result,
    output zero, msb, sltu
);

    wire [(2*WIDTH-1):0] mul, mulsu, mulu;
    wire [WIDTH-1:0]div, divu, rem, remu;

    muldiv_alu #(32) mext_alu(a, b, mul, mulsu, mulu, div, divu, rem, remu);

    always @(*) begin
        case(alu_control)
            5'b00000 : alu_result = a + b;        //add
            5'b00001 : alu_result = a + ~b + 1;   //sub
            5'b00010 : alu_result = a << b;       //sll
            5'b00011 : begin                  //slt
                if(a[WIDTH-1] != b[WIDTH-1]) alu_result = a[WIDTH-1] ? 1 : 0;
                else alu_result = (a < b) ? 1 : 0;
            end
            5'b00100 : alu_result = (a < b) ? 1 : 0;//sltu
            5'b00101 : alu_result = a^b;            //xor
            5'b00110 : alu_result = a >> b;         //srl
            5'b00111 : alu_result = $signed(a) >>> b ;//sra
            5'b01000 : alu_result = a|b;            //or
            5'b01001 : alu_result = a&b;            //and
            5'b10000 : alu_result = mul[WIDTH-1:0];         //mul
            5'b10001 : alu_result = mul[2*WIDTH-1:WIDTH];   //mulh
            5'b10010 : alu_result = mulsu[2*WIDTH-1:WIDTH]; //mulhsu
            5'b10011 : alu_result = mulu[2*WIDTH-1:WIDTH];  //mulhu
            5'b10100 : alu_result = div;         //div
            5'b10101 : alu_result = divu;        //divu
            5'b10110 : alu_result = rem;         //rem
            5'b10111 : alu_result = remu;        //remu
            default  : alu_result = {WIDTH{1'bx}};
        endcase
    end

    assign zero = (alu_result==0) ? 1 : 0;
    assign msb  = alu_result[WIDTH-1];
    assign sltu = (a<b);

endmodule