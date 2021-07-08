module rgb_generator(clk,hsync, vsync,rgb,vde);

  //system
  input   clk;

  //video
  output  hsync;
  output  vsync;
  output  [23:0]  rgb;
  output  vde;

  wire [9:0] hpos;
  wire [9:0] vpos;
  wire [2:0] rgb3bit;
  wire [7:0] red;
  wire [7:0] green;
  wire [7:0] blue;

  test_hvsync_top test_hvsync_top_0 (
    .clk    (clk),
    .hsync  (hsync),
    .vsync  (vsync),
    .rgb    (rgb3bit),
    .vde    (vde)
  );

  assign red = { 8{rgb3bit[0]} };
  assign green = { 8{rgb3bit[1]} };
  assign blue = { 8{rgb3bit[2]} };
  assign rgb = { red, green, blue };

endmodule
