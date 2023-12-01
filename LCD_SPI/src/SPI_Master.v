`timescale 1ns / 1ns

module SPI_Master(SCLK, CS, CLK, rst, btn1, MOSI, DC, RES, VCC_EN, PMOD_EN, led);
    parameter IDLE = 4'b1111;
    parameter SHIFT = 4'b0001;

    output reg SCLK, CS, DC, RES, VCC_EN, PMOD_EN;      //Serial clock and chip select(active low)
    output reg MOSI;          //Master Out Slave In 
    output reg [3:0] led;
    
    reg [15:0] data_o;       //Data TO BE transmitted
    reg [3:0] temp;
    input CLK, rst, btn1;     //System clock and rst(btn0 and active low)
    
    reg [4:0]curr_state;        //Update the current state
    reg transmit_data;          //Will help determine of trasmission is complete
    reg [15:0] shift_register;   //Will help send data out 1 bit at a time
    wire [3:0]btn_deb, btn_pulse;

//For transmitting button
    debounce DEB1(.clk    (CLK),
                 .rst    (rst),
                 .button (btn1),
                 .result (btn_deb[1]) 
    );

   single_pulse_detector SPD1(
                        .clk (CLK),
                        .rst (rst),
                        .i_signal (btn_deb[1]),
                        .o_signal (btn_pulse[1]) 
    );

//For reset button
    debounce DEB0(.clk    (CLK),
                 .rst    (rst),
                 .button (btn1),
                 .result (btn_deb[0]) 
    );

   single_pulse_detector SPD0(
                        .clk (CLK),
                        .rst (rst),
                        .i_signal (btn_deb[0]),
                        .o_signal (btn_pulse[0]) 
    );
    
always @(posedge CLK or posedge btn_pulse[0]) begin
    if (btn_pulse[0]) begin
        curr_state = IDLE;
    end
    if(btn_pulse[1]) begin
        curr_state = SHIFT;
    end    
end

always @(posedge CLK) begin
    case(curr_state )
        IDLE: begin
                led = curr_state; 
                CS = 1'b1;
                SCLK = 1'b0;  
                MOSI = 1'b0;
                transmit_data = 1'b0;
                shift_register = 8'b0;        
              end

        SHIFT: begin
                led = curr_state;
                CS = 1'b0;
                SCLK = ~SCLK;
                shift_register = 16'hAA; //shift register takes data
                transmit_data = 1'b1;    
               end
    endcase
end

always @(posedge SCLK) begin
    //Shift out data on rising edge of SCLK
    MOSI = shift_register[15]; //MSB first
    //Shift bits to left and replace LSB with 0
    shift_register = {shift_register[14:0], 1'b0};
end

always @(transmit_data) begin
    //If all data sent, all 0s
    if(shift_register == 8'b0) begin
        //transmission complete
        curr_state = IDLE;
        transmit_data = 1'b0; 
    end                    
end

//always @(posedge CLK or posedge btn_pulse[0]) begin
//    if (btn_pulse[0]) begin
//        curr_state = IDLE;
//        led = curr_state;
//        temp = 4'b0000;
//        CS = 1'b1;
//        SCLK = 1'b0;
//        MOSI = 1'b0;
//        transmit_data = 1'b0;
//        shift_register = 8'b0;
//    end else begin
//        if(curr_state == IDLE) begin
//            CS = 1'b1;
//            SCLK = 1'b0;
//            led = curr_state;
//            DC = 1'b0;              //Set DC logic low
//            if(btn_pulse[1]) begin
//                //Assert CS and begin transmission of data
//                CS = 1'b0;
//                shift_register = 16'hAA; //shift register takes data
//                curr_state = SHIFT;
//                led = curr_state;
//                transmit_data = 1'b1;
                
//             end
          
//    end else begin
//        if(curr_state == SHIFT) begin
//        SCLK = ~SCLK;
//        led = curr_state;
        
//            if (SCLK == 1'b1) begin
//            //Shift out data on rising edge of SCLK
//            MOSI = shift_register[7]; //MSB first
//            //Shift bits to left and replace LSB with 0
//            shift_register = {shift_register[6:0], 1'b0};
//            end
            
//            if(transmit_data) begin
//                //If all data sent, all 0s
//                if(shift_register == 8'b0) begin
//                    //transmission complete
//                    curr_state = IDLE;
//                    transmit_data = 1'b0; 
//                end                    
//            end
            
//        end  
//        end   
//    end

//end 

endmodule