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

	output wire pdm_out               // bitstream output at clock frequency
);

    // Internal signals
    wire [DATA_WIDTH+2+18:0] cic_out;
    wire cic_valid;
    wire [DATA_WIDTH-1:0] left_data;  // Parallel output for left channel
    wire [DATA_WIDTH-1:0] right_data;  // Parallel output for right channel
    wire right_data_valid;                       // Right data valid signal
    wire left_data_valid;                       // Left data valid signal
    

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
        .out_data(cic_out),
        .out_valid(cic_valid)
    );


    // Instantiate the Delta-Sigma Modulator
    mod2_dsm #(.DATA_WIDTH_WIDTH(DATA_WIDTH)) dsm_inst (
        .clk(bclk),
        .rst(rst),
        .in_data(cic_out),
        .out_bitstream(pdm_out) // PDM bitstream at clk frequency
    );    


// Logarithm base 2 for sizing registers

function integer clog2;
    input integer value;
    integer i;
    begin
        clog2 = 0;
        for (i = value; i > 0; i = i >> 1)
            clog2 = clog2 + 1;
    end
endfunction

endmodule


