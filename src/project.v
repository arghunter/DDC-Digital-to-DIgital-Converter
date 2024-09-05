/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
// This porject was a collaboration between me(arghunter) and the other collaborators on this repository (Acknowledged in the ReadMe)
module tt_um_ddc_arghunter (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
wire rst;
  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe[7:0]  = 0;
  assign uio_out[7:0]  = 0;
  assign uo_out[7:4] = 0;
  assign rst = !rst_n;
  generate
    ddc_top_level  u_ddc_top_level  (
        .rst(rst),
        .bclk(ui_in[0]),
        .lrclk(ui_in[1]),
        .sdin(ui_in[2]),
        .lfsr_en(ui_in[3]),
        .pdm_out_left(uo_out[0]),
        .pdm_out_right(uo_out[1]),
        .clk_out_left(uo_out[2]),
        .clk_out_right(uo_out[3])
        
    );    
  endgenerate
  // List all unused inputs to prevent warnings
    wire _unused = &{ena, clk,ui_in[7:4],uio_in[7:0], 1'b0};

endmodule
