module zybo_top(

//system
input         CLK,
input         RST,
output [3:0]  LED,
input         BTN0,
input         BTN1,
input         BTN2,

//video
output  hsync,
output  vsync,
output [4:0]  red,
output [5:0]  green,
output [4:0]  blue

);

wire clk_vga;
wire [9:0] hpos;
wire [9:0] vpos;
wire [2:0] rgb;

wire w_btn0_rmv_chat;
wire w_btn1_rmv_chat;
wire w_btn2_rmv_chat;

reg [1:0] r_btn0;
reg [1:0] r_btn1;
reg [1:0] r_btn2;

always @(posedge clk_vga)
  begin
    r_btn0 <= {r_btn0[0], BTN0}; 
    r_btn1 <= {r_btn1[0], BTN1};
    r_btn2 <= {r_btn2[0], BTN2};
  end

assign w_btn0_rmv_chat = &r_btn0;
assign w_btn1_rmv_chat = &r_btn1;
assign w_btn2_rmv_chat = &r_btn2;

assign  LED = 4'b1010;

clk_vga_25m clk_vga_25m_0 (
  .clk_out1(clk_vga),
  .reset(RST), 
  .locked(),
  .clk_in1(CLK)
);

racing_game_top racing_game_top_0 (
  .clk    (clk_vga),
  .reset  (RST),
  .hpaddle_left(w_btn2_rmv_chat),
  .hpaddle_right(w_btn0_rmv_chat),
  .vpaddle(w_btn1_rmv_chat),
  .hsync  (hsync),
  .vsync  (vsync),
  .rgb    (rgb)
);

assign red = { 5{rgb[0]} };
assign green = { 6{rgb[1]} };
assign blue = { 5{rgb[2]} };

endmodule
