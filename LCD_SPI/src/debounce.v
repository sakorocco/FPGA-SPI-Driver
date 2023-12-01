`timescale 1ns/1ns

module debounce (
    input clk,
    input rst,
    input button,
    output result
);
    parameter clk_freq = 125_000_000; // System clock frequency in Hz
    parameter stable_time = 10;       // Time button must remain stable in ms

    reg [31:0] count;
    localparam MAX_DELAY = clk_freq * stable_time / 1000;
    reg set; // Sync reset to zero

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            set = 1'b0;
            count = 0;
        end else begin
            if (button) begin
                if (count == MAX_DELAY - 1) begin
                    set = 1'b1;
                end
                count = count + 1;
            end else begin
                set = 1'b0;
                count = 0;
            end
        end
    end

    assign result = set;

endmodule

