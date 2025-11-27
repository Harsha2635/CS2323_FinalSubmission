`timescale 1ns / 1ps

module pipeline_wh_tb;

  // Testbench signals
  reg clk;
  reg reset;
  wire [31:0] result;

  // Instantiate the DUT (Device Under Test)
  pipeline_wh #(32) dut (
    .clk(clk),
    .reset(reset),
    .result(result)
  );

  // Clock generation: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Toggle every 5ns
  end

  // Reset sequence
  initial begin
    reset = 0;
    #20;
    reset = 1;          // Deassert reset after 20ns
  end

  // Monitor result during simulation
  initial begin
    $dumpfile("out.vcd");
    $dumpvars(0, pipeline_wh_tb);

    $monitor("Time=%0t | reset=%b | result=%h", $time, reset, result);
  end

  // Simulation runtime control
  initial begin
    #2000;                  // Run for 2000ns (adjust as needed)
    $display("Simulation finished at time=%0t", $time);
    $finish;
  end

endmodule
