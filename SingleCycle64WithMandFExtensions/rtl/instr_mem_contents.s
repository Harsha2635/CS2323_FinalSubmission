addi x1, x0, 1
fmul.s f3, f1, f2
fmul.s f4, f3, f1
fsd f4, 0(x0)
fld f5, 0(x0)
fadd.s f6, f5, f1
fdiv.s f7, f5, f1
addi x1,x0,10
addi x2,x0,5
add x3,x2,x1
ld  x4,0(x3)
add x5,x4,x3
bne x5, x0, jump
addi x21, x0, 1
jump: 
    addi x22, x0, 2
addi x21, x21, 0