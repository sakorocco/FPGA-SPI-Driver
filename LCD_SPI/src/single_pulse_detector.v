`timescale 1ns / 1ps

module single_pulse_detector(clk, rst, i_signal, o_signal);
    input clk, rst, i_signal;
    output reg o_signal;
   
    parameter detect_type = 2'b00; // Default value for detect_type
   
    reg ff1, ff0;
    
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ff1 = 1'b0;
            ff0 = 1'b0;
        end else begin
            ff0 = i_signal;
            ff1 = ff0;
        end
        
     end
    
    always @* begin
    
        case (detect_type )
            2'b00: o_signal = (~ff1 & ff0);
            2'b01: o_signal = (~ff0 & ff1);
            2'b10: o_signal = (ff0 ^ ff1);
            default: o_signal = 1'b0;
        
        
        endcase
    
    
    end
    
endmodule
