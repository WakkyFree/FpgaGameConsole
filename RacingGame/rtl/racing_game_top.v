/*
A simple racing game with two sprites and a scrolling playfield.
This version does not use a CPU; all logic is straight Verilog.
*/

module racing_game_top(clk, reset, hsync, vsync, rgb, hpaddle_left, hpaddle_right, vpaddle);

  input clk;
  input reset;
  input hpaddle_left, hpaddle_right, vpaddle;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  wire h_rise;
  wire v_rise;

  // player car position (set at VSYNC)
  reg [8:0] player_x;
  reg [8:0] player_y;  
  // paddle position (set continuously during frame)
  reg [8:0] paddle_x;
  reg [8:0] paddle_y;
  // enemy car position
  reg [8:0] enemy_x = 320;
  reg [8:0] enemy_y = 320;
  // enemy car direction, 1=right, 0=left
  reg enemy_dir = 0;	
  
  reg [15:0] track_pos = 0;	// player position along track (16 bits)
  reg [7:0] speed = 31;		// player velocity along track (8 bits)
  
  // video sync generator
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  detect_edge detect_edge_h(
    .clk(clk),
    .reset(reset),
    .din(hsync),
    .rise(h_rise),
    .fall()
  );  

  // set paddle registers
  always @(posedge clk)
    if (h_rise) begin
      //if (!hpaddle) paddle_x <= vpos[8:0];
      if (!vpaddle) paddle_y <= vpos[8:0];
    end

  
  // select player or enemy access to ROM
  wire player_load = (hpos >= 640) && (hpos < 644);
  wire enemy_load = (hpos >= 644);
  // wire up car sprite ROM
  // multiplex between player and enemy ROM address
  wire [3:0] player_sprite_yofs;
  wire [3:0] enemy_sprite_yofs;
  wire [3:0] car_sprite_yofs = player_load ? player_sprite_yofs : enemy_sprite_yofs;  
  wire [7:0] car_sprite_bits;  
  car_bitmap car(
    .yofs(car_sprite_yofs), 
    .bits(car_sprite_bits));
  
  // signals for player sprite generator
  wire player_vstart = {1'b0,player_y} == vpos;
  wire player_hstart = {1'b0,player_x} == hpos;
  wire player_gfx;
  wire player_is_drawing;

  // signals for enemy sprite generator
  wire enemy_vstart = {1'b0,enemy_y} == vpos;
  wire enemy_hstart = {1'b0,enemy_x} == hpos;
  wire enemy_gfx;
  wire enemy_is_drawing;
  
  // player sprite generator
  sprite_renderer player_renderer(
    .clk(clk),
    .vstart(player_vstart),
    .load(player_load),
    .hstart(player_hstart),
    .rom_addr(player_sprite_yofs),
    .rom_bits(car_sprite_bits),
    .gfx(player_gfx),
    .in_progress(player_is_drawing));

  // enemy sprite generator
  sprite_renderer enemy_renderer(
    .clk(clk),
    .vstart(enemy_vstart),
    .load(enemy_load),
    .hstart(enemy_hstart),
    .rom_addr(enemy_sprite_yofs),
    .rom_bits(car_sprite_bits),
    .gfx(enemy_gfx),
    .in_progress(enemy_is_drawing));

  // signals for enemy bouncing off left/right borders  
  wire enemy_hit_left = (enemy_x == 128);
  wire enemy_hit_right = (enemy_x == 496);
  wire enemy_hit_edge = enemy_hit_left || enemy_hit_right;
  
  detect_edge detect_edge_v(
    .clk(clk),
    .reset(reset),
    .din(vsync),
    .rise(v_rise),
    .fall()
  );
  
  // update player, enemy, track counters
  // runs once per frame
  always @(posedge clk)
    if(v_rise) begin
      if (hpaddle_left)
        player_x <= 176;
      else if(hpaddle_right)
        player_x <= 448;
      else
        player_x <= 312;
      player_y <= 360;
      track_pos <= track_pos + {11'b0,speed[7:4]};
      enemy_y <= enemy_y + {3'b0, speed[7:4]};
      if (enemy_hit_edge)
        enemy_dir <= !enemy_dir;
      if (enemy_dir ^ enemy_hit_edge)
        enemy_x <= enemy_x + 1;
      else
        enemy_x <= enemy_x - 1;
      // collision check?
      if (frame_collision)
        speed <= 16;
      else if (speed < ~paddle_y)
        if(speed != 255)
        speed <= speed + 1;
      else
        speed <= speed - 1;
    end
  
  // set to 1 when player collides with enemy or track
  reg frame_collision;
  
  always @(posedge clk)
    if (player_gfx && (enemy_gfx || track_gfx))
      frame_collision <= 1;
    else if (v_rise)
      frame_collision <= 0;
  
  // track graphics signals
  wire track_offside = (hpos[9:7]==3'b000) || (hpos[9:7]==3'b100); // track_offside<128, 512<track_offside<1024
  wire track_shoulder = (hpos[9:4]==6'b000111) || (hpos[9:4]==6'b100000); //track_shoulder<112, 512<track_shoulder<528
  wire track_gfx = (vpos[7:3]!=track_pos[7:3]) && track_offside;
  
  // combine signals for RGB output
  wire r = display_on && (player_gfx || enemy_gfx || track_shoulder);
  wire g = display_on && (player_gfx || track_gfx);
  wire b = display_on && (enemy_gfx || track_shoulder);
  assign rgb = {b,g,r};

endmodule
