
`timescale 1ns/1ps

// ==========================================
// FSM = Convolution Controller
//
// IDLE: Wait for a new 3x3 image window
// RUN:  Process the 9 pixels using the MAC
// DONE: Signal that the result is ready
//
// The FSM controls WHEN the MAC calculates.
// ==========================================

module conv_controller (
    input clk,
    input reset,
    input start,
    /*input or output?*/ clear,             // Reset the MAC's running total
    /*input or output?*/ enable,            // Allow the MAC to calculate
    /*input or output?*/ done,              // Signal that calculation is finished
    /*input or output?*/ reg [3:0] index    // Selects current pixel (0 to 8 formt he flattened 3x3)
);

// Define the three FSM states
parameter IDLE = 0, RUN = 1, DONE = 2;
reg [1:0] state;              // stores the current state

always @(posedge clk) begin
    // reset the controller to its starting state
    if (reset) begin
        state <= IDLE;
        index <= 0;
    end

    else begin
        case (state)
            IDLE: begin
                // index <= 0 starts us at pixel 0 below
                index <= 0;          
                // add logic to check input start, to determine how to transition state... 
            end
            RUN: begin
                // check if index has hit last pixel. If so, transition to DONE state,
                // else, move to the next pixel
            end
            DONE: begin
                // adjust state to IDLE state to be ready for next window
            end
            default: state <= IDLE; // default waiting state

        endcase
    end
end

// Control signals sent to the MAC and testbench
assign clear  = reset || (state == IDLE && start); // Clear total before each window
assign enable = (state == RUN);                    // Calculate only while RUN
assign done   = // add logic for checking status of DONE state...

endmodule
