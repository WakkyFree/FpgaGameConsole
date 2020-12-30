module detect_edge(clk, reset, din, rise, fall);

  input clk;
  input reset;
  input din;
  output rise;
  output fall;

  reg [1:0] d_reg;

  always @(posedge clk or posedge reset)
  begin
    if (reset) begin
      d_reg <= 2'b00;
    end else begin
      d_reg <= {d_reg[0], din};
    end
  end

  assign rise = d_reg == 2'b01;
  assign fall = d_reg == 2'b10;

endmodule