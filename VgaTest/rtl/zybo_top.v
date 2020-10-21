module zybo_top(

//system
input         CLK,
input         RST,
output [3:0]  LED,

//video
output  hsync,
output  vsync,
output [4:0]  red,
output [5:0]  green,
output [4:0]  blue

);

wire display_on;
wire [9:0] hpos;
wire [9:0] vpos;
wire [2:0] rgb;

assign  LED = 4'b1010;

clk_vga_25m clk_vga_25m_0 (
  .clk_out1(clk_vga),
  .clk_out2(clk_sys),
  .reset(RST), 
  .locked(),
  .clk_in1(CLK)
);

test_hvsync_top test_hvsync_top_0 (
  .clk    (clk_vga),
  .reset  (RST),
  .hsync  (hsync),
  .vsync  (vsync),
  .rgb    (rgb)
);

assign red = { 5{rgb[0]} };
assign green = { 6{rgb[1]} };
assign blue = { 5{rgb[2]} };

endmodule
