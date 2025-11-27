`timescale 1ns/1ps

module tb_top_riscv_single;

  parameter WIDTH = 64;

  reg clk = 1;
  reg reset = 0;
  wire [WIDTH-1:0] result, wr_data_f;
  wire [WIDTH-1:0] pc;
  wire [WIDTH-1:0] read_data, mem_wr_addr, mem_wr_data;
  wire led;

  top_riscv_single #(WIDTH) dut (
    .clk(clk),
    .reset(reset),
    .result(result),
    .wr_data_f(wr_data_f),
    .pc(pc),
    .read_data(read_data),
    .mem_wr_addr(mem_wr_addr),
    .mem_wr_data(mem_wr_data),
    .led(led)
  );

  always #5 clk = ~clk;

  initial begin
    // VCD dump setup
    $dumpfile("out.vcd");
    $dumpvars(0, tb_top_riscv_single);
    
    reset = 0;
    #5;
    reset = 1;
    #200;
    $finish;
  end

  initial begin
    $monitor("time=%0t reset=%b result=%h pc=%h read_data=%h led=%b", $time, reset, wr_data_f, pc, read_data, led);
  end

endmodule
