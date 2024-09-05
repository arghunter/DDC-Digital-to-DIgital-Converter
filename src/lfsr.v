`timescale 1ns / 1ps

//16 bit LFSR sequence henerator
module lfsr16 (
    input wire clk,              // Clock input
    input wire rst,              // Reset input (active high)
    input wire en,              //active high enable
    output wire  lfsr_out  // LFSR output
);

    localparam LFSR_WIDTH = 16;
    
    // Register to hold the current state of the LFSR
    reg [LFSR_WIDTH:0] lfsr_reg;
    wire lfsr_xnor;  // Feedback bit for LFSR
    
    assign lfsr_xnor = lfsr_reg[16] ^~ lfsr_reg[15] ^~ lfsr_reg[13] ^~ lfsr_reg[4];
    
    always @(posedge clk or posedge rst) begin
        if(rst) 
            lfsr_reg <= 1;
        else begin
            if(en)
                lfsr_reg <= {lfsr_reg[LFSR_WIDTH-1:0], lfsr_xnor};
            else
                lfsr_reg <= lfsr_reg;
        end
    end
    
    assign lfsr_out = lfsr_reg[LFSR_WIDTH];

endmodule
