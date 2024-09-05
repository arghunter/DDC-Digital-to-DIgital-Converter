`timescale 1ns / 1ps



module tb_ddc_top_level;
    // Parameters
    parameter BCLK_PER_FRAME = 32;  // Number if bclks in left and right frames
    parameter LRCLK_FREQ = 48000; // LRCLK frequency in Hz
    parameter BIT_CLK_FREQ = LRCLK_FREQ * BCLK_PER_FRAME * 2; // Bit clock frequency
    
    
    parameter CIC_ORDER = 5;         // Order of the CIC filter
    parameter CIC_INTERPOLATION = 64; // Interpolation factor for the CIC filter
    parameter DATA_WIDTH = 16;        // Width of the input signal
    // Testbench signals
    reg rst;
    reg bclk;  // Bit clock (3.072 MHz)
    reg lrclk; // LR clock (48 kHz)
    reg sdin;  // Serial data input
    reg lfsr_en; //LFSR dither enable
    
    reg sdin_no_delay = 0;  // Bit clock (3.072 MHz)
 
    wire pdm_out_left; //sdm bitstrem output left  
    wire pdm_out_right; //sdm bitstrem output right
    
    wire [DATA_WIDTH-1:0] left_data;
    wire [DATA_WIDTH-1:0] right_data;
    wire left_data_valid;
    wire right_data_valid;
    
    // Testbench variables
    integer data_file_id;   // File handler
    integer scan_file;   // Variable to read from file
    integer data_valueL;  // Data read from file
    integer data_valueR; //data value - right
    integer bit_counter; // Bit counter
    integer out_file_id; //output fileid

    // Instantiate the I2S receiver
    ddc_top_level  uut (
        .rst(rst),
        .bclk(bclk),
        .lrclk(lrclk),
        .sdin(sdin),
        .lfsr_en(lfsr_en),
        //.left_data(left_data),
        //.right_data(right_data),
        //.left_data_valid(left_data_valid),
        //.right_data_valid(right_data_valid),
        .pdm_out_left(pdm_out_left),
        .pdm_out_right(pdm_out_right)
    );

    // Bit clock generation (3.072 MHz)
    //always #162.5 bclk = ~bclk;

    // LR clock generation (48 kHz)
    //always #10400 lrclk = ~lrclk;
    
    // Generate SCLK (bit clock) and LRCLK (word select clock)
    
    initial begin
        bclk = 0;
        lrclk = 0;
        forever begin
            #(1000000000 / (2*BIT_CLK_FREQ)) bclk = ~bclk; // bclk generation
            //if (bclk == 1 && bit_counter == (BCLK_PER_FRAME-1)) begin
            //    lrclk = ~lrclk; // Toggle LRCLK after sending DATA_WIDTH bits
            //end
        end
    end 
    
       
    

    // Test sequence
    initial begin  
        //data_file_id = $fopen("ramp_test_64step_16b_LR_10.txt", "r"); 
        //data_file_id = $fopen("i2s_test_data.txt", "r"); // Open file for reading  
        //data_file_id = $fopen("i2s_sin_test.txt", "r");   //ramp 1 ch
        data_file_id = $fopen("sine_3khz_1ch.txt", "r");   //sine 3k 1 ch
        
        // Initialize signals
        rst = 0;
        bclk = 0;
        lrclk = 0;
        sdin = 0;
        lfsr_en = 0;

        // Apply reset
        rst = 1;
        #25;
        rst = 0;
        #30; 
        
        forever begin                  
            //scan_file = $fscanf(data_file_id, "%d %d\n", data_valueL, data_valueR); // Read data from file
            scan_file = $fscanf(data_file_id, "%d\n", data_valueR); // Read data from file
            data_valueL = 10;
            
            if (scan_file != 1) begin
                $fclose(data_file_id);
                $stop; // End simulation if no more data
            end
            
                        // Send the data bit by bit
            for (bit_counter = 0; bit_counter < BCLK_PER_FRAME; bit_counter = bit_counter + 1) begin
                if(bit_counter < DATA_WIDTH) begin
                    sdin_no_delay = data_valueL[DATA_WIDTH-1 - bit_counter];
                 end else begin
                    sdin_no_delay = 0;
                 end 
                
                @(negedge bclk) //I2S - transition occurs on neg edge
                begin 
                    if(bit_counter == BCLK_PER_FRAME-1) begin 
                        lrclk <= 1;
                     end
                     sdin <= sdin_no_delay; //I2S data occurs 1 clk cycle after the LRCLK edge
                end//; // Wait for the next clock edge
                
            end
            
            
                        // Send the data bit by bit
            for (bit_counter = 0; bit_counter < BCLK_PER_FRAME; bit_counter = bit_counter + 1) begin
                if(bit_counter < DATA_WIDTH) begin
                    sdin_no_delay = data_valueR[DATA_WIDTH-1 - bit_counter];
                 end else begin
                    sdin_no_delay = 0;
                 end 
                
                @(negedge bclk) //I2S - transition occurs on neg edge
                begin 
                    if(bit_counter == BCLK_PER_FRAME-1) begin 
                        lrclk <= 0;
                     end
                     sdin <= sdin_no_delay; //I2S data occurs 1 clk cycle after the LRCLK edge
                end//; // Wait for the next clock edge
                
            end            

        end
        

     /*   
        
        // Simulate I2S serial data
        // The following data pattern is just an example
        // You would typically use more meaningful data in a real test
        #20475; // skip the first LR cycle
        // Transmit left channel data: 0xA5A5
        #325 sdin = 0;  // clk 0 - bit 0 of previous frame
        #325 sdin = 1;  // clk 1 - bit 31
        #325 sdin = 0;  // clk 2 - bit 30
        #325 sdin = 1;  // clk 3 - bit 29
        #325 sdin = 0;  // clk 4 - bit 28
        #325 sdin = 0;  // clk 5 - bit 27
        #325 sdin = 1;  // clk 6 - bit 26
        #325 sdin = 0;  // clk 7 - bit 25
        #325 sdin = 1;  // clk 8 - bit 24
        #325 sdin = 1;  // clk 9 - bit 23
        #325 sdin = 0;  // clk 10 - bit 22
        #325 sdin = 1;  // clk 11 - bit 21
        #325 sdin = 0;  // clk 12 - bit 20
        #325 sdin = 0;  // clk 13 - bit 19
        #325 sdin = 1;  // clk 14 - bit 18
        #325 sdin = 0;  // clk 15 - bit 17
        #325 sdin = 1;  // clk 16 - bit 16
        #325 sdin = 0;  // clk 17 - bit 15
        #325 sdin = 0;  // clk 18 - bit 14
        #325 sdin = 0;  // clk 19 - bit 13
        #325 sdin = 0;  // clk 20 - bit 12
        #325 sdin = 0;  // clk 21 - bit 11
        #325 sdin = 0;  // clk 22 - bit 10
        #325 sdin = 0;  // clk 23 - bit 9
        #325 sdin = 0;  // clk 24 - bit 8
        #325 sdin = 0;  // clk 25 - bit 7
        #325 sdin = 0;  // clk 26 - bit 6
        #325 sdin = 0;  // clk 27 - bit 5
        #325 sdin = 0;  // clk 28 - bit 4
        #325 sdin = 0;  // clk 29 - bit 3
        #325 sdin = 0;  // clk 30 - bit 2
        #325 sdin = 0;  // clk 31 - bit 1
        // Transmit right channel data: 0xF00F
        #325 sdin = 0;  // clk 0 - bit 0 of previous frame
        #325 sdin = 1;  // clk 1 - bit 31
        #325 sdin = 1;  // clk 2 - bit 30
        #325 sdin = 1;  // clk 3 - bit 29
        #325 sdin = 1;  // clk 4 - bit 28
        #325 sdin = 0;  // clk 5 - bit 27
        #325 sdin = 0;  // clk 6 - bit 26
        #325 sdin = 0;  // clk 7 - bit 25
        #325 sdin = 0;  // clk 8 - bit 24
        #325 sdin = 0;  // clk 9 - bit 23
        #325 sdin = 0;  // clk 10 - bit 22
        #325 sdin = 0;  // clk 11 - bit 21
        #325 sdin = 0;  // clk 12 - bit 20
        #325 sdin = 1;  // clk 13 - bit 19
        #325 sdin = 1;  // clk 14 - bit 18
        #325 sdin = 1;  // clk 15 - bit 17
        #325 sdin = 1;  // clk 16 - bit 16
        #325 sdin = 0;  // clk 17 - bit 15
        #325 sdin = 0;  // clk 18 - bit 14
        #325 sdin = 0;  // clk 19 - bit 13
        #325 sdin = 0;  // clk 20 - bit 12
        #325 sdin = 0;  // clk 21 - bit 11
        #325 sdin = 0;  // clk 22 - bit 10
        #325 sdin = 0;  // clk 23 - bit 9
        #325 sdin = 0;  // clk 24 - bit 8
        #325 sdin = 0;  // clk 25 - bit 7
        #325 sdin = 0;  // clk 26 - bit 6
        #325 sdin = 0;  // clk 27 - bit 5
        #325 sdin = 0;  // clk 28 - bit 4
        #325 sdin = 0;  // clk 29 - bit 3
        #325 sdin = 0;  // clk 30 - bit 2
        #325 sdin = 0;  // clk 31 - bit 1
        // End simulation
        #100000;
        
        */
        $finish;
    end
    
     // Open file and write signal value on every clock edge
    initial begin
        out_file_id = $fopen("pdm_signal_output1.txt", "w"); // Open file in write mode

        if (out_file_id == 0) begin
            $display("Error: Could not open file.");
            $finish;
        end

        forever @(posedge bclk) begin
            $fwrite(out_file_id, "%0t, %b, %b, %d, %d, %d, %d\n", $time, pdm_out_left, pdm_out_right, uut.dsm_left_inst.in_data, uut.dsm_left_inst.integrator1, uut.dsm_left_inst.integrator2, uut.dsm_left_inst.feedback,); // Write signal level
        end
    end

    // Monitor the output
    initial begin
        //$monitor("Time = %0t | lrclk = %b | sdin = %b | sd_out = %b | left_data = %h | right_data = %h | left_data_valid = %b  | right_data_valid = %b", 
        //         $time, lrclk, sdin, pdm_out, left_data, right_data, left_data_valid, right_data_valid);
        $monitor("Time = %0t | lrclk = %b | sdin = %b | sd_out = %b ", $time, lrclk, sdin, pdm_out_right);
    end

endmodule
