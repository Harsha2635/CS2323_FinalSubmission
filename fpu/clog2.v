`ifndef CLOG2_V
`define CLOG2_V
module clog2;
  function integer CLOG2;
    input integer value;
    integer i;
    begin
      value = value - 1;
      for (i = 0; value > 0; i = i + 1)
        value = value >> 1;
      CLOG2 = i;
    end
  endfunction
endmodule
`endif
