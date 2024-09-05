`timescale 1ns / 1ps



module mod2_dsm #(
    parameter DATA_WIDTH = 16  // Parameter to specify the input data width
)(
    input wire clk,                             // Clock input (e.g., 3.072 MHz)
    input wire rst,                           // Active-high reset
    input wire signed [DATA_WIDTH-1:0] in_data, // Input data with parameterized width
    input wire in_dither,   //input dither
    output wire out_bitstream                         // 1-bit output bitstream
);

    // Calculate internal widths based on DATA_WIDTH
    localparam INT_WIDTH = DATA_WIDTH + 3;  // Width of the integrators and feedback
    localparam Q_POS = 2 ** DATA_WIDTH;  // Positive feedback value
    localparam Q_NEG = -Q_POS;  // Negative feedback value

    // Internal signals
    reg signed [INT_WIDTH-1:0] integrator1;
    reg signed [INT_WIDTH-1:0] integrator2;
    wire signed [INT_WIDTH-1:0] feedback;
    
    assign feedback = (integrator2[INT_WIDTH-1] == 1'b0) ? Q_POS : Q_NEG;//two level feedback

    // Modulator logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the internal states
            integrator1 <= 0;
            integrator2 <= 0;
        end else begin
            // First integrator
            integrator1 <= integrator1 + in_data  - feedback;

            // Second integrator
            integrator2 <= integrator2 + integrator1 + in_dither - (feedback << 1);//scale feedback x2 
        end
    end

    // Output assignment
    assign out_bitstream = ~integrator2[INT_WIDTH-1]; //quantizer

endmodule

