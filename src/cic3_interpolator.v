`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2024 01:52:52 PM
// Design Name: 
// Module Name: cic3_interpolator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module cic3_interpolator #(
    parameter R = 64,            // Interpolation factor
    parameter DATA_WIDTH = 16    // Input data width,
)(
    input wire clk,
    input wire rst,
    input wire signed [DATA_WIDTH-1:0] in_data,
    input wire in_valid,
    output wire signed [DATA_WIDTH-1:0] out_data
);
    reg signed [DATA_WIDTH-1:0] comb_reg0; //1st stage comb reg
    reg signed [DATA_WIDTH+0:0] comb_reg1; //2st stage comb reg  - need extra bit  
    reg signed [DATA_WIDTH+1:0] comb_reg2; //2st stage comb reg  - need extra bit
    
    reg signed [DATA_WIDTH+0:0] comb_out0; //first comb out - add 1 bit extra
    reg signed [DATA_WIDTH+1:0] comb_out1; //2nd comb out - add 1 bit extra
    reg signed [DATA_WIDTH+2:0] comb_out2; //3rd comb out - add 1 bit extra  
    
    reg signed [DATA_WIDTH+2+1:0] int_reg0; //1 st stage integrator reg
    reg signed [DATA_WIDTH+2+5:0] int_reg1; //2 nd stage integrator reg
    reg signed [DATA_WIDTH+2+10:0] int_reg2; //3 rd stage integrator reg
         
    wire [7:0] counter;  
         
    //comb stages
    always @(negedge clk or posedge rst) begin
        if(rst) begin
            comb_reg0 <= 0;
            comb_reg1 <= 0;
            comb_reg2 <= 0;  
            comb_out0 <= 0;
            comb_out1 <= 0;  
            comb_out2 <= 0;                              
        end else begin
            if(in_valid) begin
                comb_reg0 <= in_data;
                comb_out0 <= comb_reg0 - in_data;
                comb_reg1 <= comb_out0;
                comb_out1 <= comb_reg1 - comb_out0;
                comb_reg2 <= comb_out1; 
                comb_out2 <= comb_reg2 - comb_out1;
            end
        end
    end 


    
    //integrator stages
        
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            int_reg0 <= 0;
            int_reg1 <= 0;
            int_reg2 <= 0;                      
        end else begin
            if(in_valid) begin
                int_reg0 <= int_reg0 + comb_out2;
            end else begin
                int_reg0 <= int_reg0;
            end
            int_reg1 <= int_reg1 + int_reg0;
            int_reg2 <= int_reg2 + int_reg1;
            //out_data <=   int_reg2[DATA_WIDTH+2+9:DATA_WIDTH+2+9-16];//pick top 16 bits of the interpolator output 
        end
    end 
    
    assign out_data =   int_reg2[DATA_WIDTH+2+10:DATA_WIDTH+2+10-16];//pick top 16 bits of the interpolator output

endmodule