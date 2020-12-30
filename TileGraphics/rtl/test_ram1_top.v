module test_ram1_top(clk, reset, hsync, vsync, rgb);

  input clk, reset;
  output hsync, vsync;
  output [2:0] rgb;

  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  
  wire [9:0] ram_addr;
  wire [7:0] ram_read;
  reg [7:0] ram_write;
  reg ram_writeenable = 0;
  reg [3:0] counter;
  wire v_rise;
  wire [7:0] lfsr_adrs;

  // RAM to hold 32x32 array of bytes
  RAM_sync ram(
    .clk(clk),
    .dout(ram_read),
    .din(ram_write),
    .addr(ram_addr),
    .we(ram_writeenable)
  );
  
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
 
  wire [4:0] row = vpos[7:3];	// 7-bit row, vpos / 8
  wire [4:0] col = hpos[7:3];	// 7-bit column, hpos / 8
  wire [2:0] rom_yofs = vpos[2:0]; // scanline of cell
  wire [4:0] rom_bits;		   // 5 pixels per scanline
  
  wire [3:0] digit = ram_read[3:0]; // read digit from RAM
  wire [2:0] xofs = hpos[2:0];      // which pixel to draw (0-7)
  
  assign ram_addr = {row,col};	// 14-bit RAM address

  always @ (posedge clk) begin
    if (reset)
      counter <= 4'd0;
    else if (v_rise)
      counter <= counter + 4'd1;
  end

  // digits ROM
  digits10_case numbers(
    .digit(digit),
    .yofs(rom_yofs),
    .bits(rom_bits)
  );

  // extract bit from ROM output
  wire r = display_on && 0;
  wire g = display_on && rom_bits[~xofs];
  wire b = display_on && 0;
  assign rgb = {b,g,r};

  detect_edge detect_edge_0(
    .clk(clk),
    .reset(reset),
    .din(vsync),
    .rise(v_rise),
    .fall()
  );

  LFSR #(.NUM_BITS(8)) lfsr_inst
         (.i_Clk(clk),
          .i_Enable(1'b1),
          .i_Seed_DV(1'b0),
          .i_Seed_Data({8{1'b0}}), // Replication
          .o_LFSR_Data(lfsr_adrs),
          .o_LFSR_Done()
          );

  // increment the current RAM cell
  always @(posedge clk)
    if(counter == 4'd15) begin
    case (hpos[2:0])
        // on 7th pixel of cell
        6: begin
          // increment RAM cell
          ram_write <= lfsr_adrs;
          // only enable write on last scanline of cell
          ram_writeenable <= display_on && rom_yofs == 7;
        end
        // on 8th pixel of cell
        7: begin
          // disable write
          ram_writeenable <= 0;
        end
      endcase
    end
endmodule
