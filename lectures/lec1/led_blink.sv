```
`timescale 1ns / 1ps

module led(
    input logic clk,
    output logic [3:0] led
    );
    
    logic [31:0] counter = 0;
    logic clk_out;
    
    always_ff @(posedge clk) begin
        if (counter == 124999999) begin
            clk_out <= 1;
            counter <= 0;
        end else begin
            counter <= counter + 1;
            clk_out <= 0;
        end
    end
        
    logic [3:0] led_reg = 0;
    
    always_ff @(posedge clk_out) begin
        led_reg <= led_reg + 1;
    end
    
    assign led = led_reg;
endmodule
```