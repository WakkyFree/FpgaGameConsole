///////////////////////////////////////////////////////////////////////////////
This is the dummy file for LFSR module.
Please copy and paste the code on:
https://www.nandland.com/vhdl/modules/lfsr-linear-feedback-shift-register.html
///////////////////////////////////////////////////////////////////////////////
module LFSR #(parameter NUM_BITS = 8)
  (
   input i_Clk,
   input i_Enable,
 
   input i_Seed_DV,
   input [NUM_BITS-1:0] i_Seed_Data,
 
   output [NUM_BITS-1:0] o_LFSR_Data,
   output o_LFSR_Done
   );

   assign o_LFSR_Data = {(NUM_BITS){1'b0}};
   assign o_LFSR_Done = 1'b0;

endmodule // LFSR