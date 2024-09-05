`timescale 1ns / 1ps


module ddc_top_level #(
    parameter CIC_ORDER = 3,         // Order of the CIC filter
    parameter CIC_INTERPOLATION = 64, // Interpolation factor for the CIC filter
    parameter DATA_WIDTH = 16        // Width of the input signal
)(
    input wire rst,             // Reset signal
    input wire bclk,            // Bit clock (3.072 MHz)
    input wire lrclk,           // Left/Right clock (48 kHz)
    input wire sdin,            // Serial data input
    input wire lfsr_en,         // enable LFSR dither
	output wire pdm_out_left,               // bitstream output at clock frequency
    output wire pdm_out_right,               // bitstream output at clock frequency    
	output wire clk_out_left,               // bitstream clk output at clock frequency
    output wire clk_out_right               // bitstream clk output at clock frequency
);

    // Internal signals
    wire signed [DATA_WIDTH-1:0] cic_out_left;
    wire signed [DATA_WIDTH-1:0] cic_out_right;
    wire signed [DATA_WIDTH-1:0] left_data;  // Parallel output for left channel
    wire signed [DATA_WIDTH-1:0] right_data;  // Parallel output for right channel
    wire right_data_valid;                       // Right data valid signal
    wire left_data_valid;                       // Left data valid signal
    wire lfsr_bitstream;                        //LFSR bistream - same used for both left and right delta sigma modulators
    
    assign clk_out_left = bclk;
    assign clk_out_right = bclk;    
    
    // Instantiate the I2S receiver
    i2s_rx_64x #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i2s_rx_inst (
        .rst(rst),
        .bclk(bclk),
        .lrclk(lrclk),
        .sdin(sdin),
        .left_data(left_data),
        .right_data(right_data),
        .left_data_valid(left_data_valid),
        .right_data_valid(right_data_valid)
    );    
    

    // Instantiate the CIC Interpolator
    cic3_interpolator #(
        .R(CIC_INTERPOLATION),
        .DATA_WIDTH(DATA_WIDTH)
    ) cic_left_inst (
        .clk(bclk),
        .rst(rst),
        .in_data(left_data),
        .in_valid(left_data_valid),
        .out_data(cic_out_left)
    );
    
    // Instantiate the CIC Interpolator
    cic3_interpolator #(
        .R(CIC_INTERPOLATION),
        .DATA_WIDTH(DATA_WIDTH)
    ) cic_right_inst (
        .clk(bclk),
        .rst(rst),
        .in_data(right_data),
        .in_valid(right_data_valid),
        .out_data(cic_out_right)
    );    


    // Instantiate the Delta-Sigma Modulator
    mod2_dsm #(.DATA_WIDTH(DATA_WIDTH)) dsm_left_inst (
        .clk(bclk),
        .rst(rst),
        .in_data(cic_out_left),
        .in_dither(lfsr_bitstream),
        .out_bitstream(pdm_out_left) // PDM bitstream at clk frequency
    );    

    // Instantiate the Delta-Sigma Modulator
    mod2_dsm #(.DATA_WIDTH(DATA_WIDTH)) dsm_right_inst (
        .clk(bclk),
        .rst(rst),
        .in_data(cic_out_right),
        .in_dither(lfsr_bitstream),
        .out_bitstream(pdm_out_right) // PDM bitstream at clk frequency
    );   
    
    //16 bit LFSR sequence henerator
    
    lfsr16 lsfr_inst (
        .clk(bclk),
        .rst(rst),
        .en(lfsr_en),
        .lfsr_out(lfsr_bitstream) // LFSR bitstream at clk frequency
    );  

endmodule


