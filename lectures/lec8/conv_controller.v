
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

    output clear,             // Reset the MAC's running total
    output enable,            // Allow the MAC to calculate
    output done,              // Signal that calculation is finished
    output reg [3:0] index    // Selects current pixel (0 to 8 formt he flattened 3x3)
);

// Define the three FSM states
parameter IDLE = 0, RUN = 1, DONE = 2;
reg [1:0] state;              // Stores the current state

always @(posedge clk) begin

    // reset the controller to its starting state
    if (reset) begin
        state <= IDLE;
        index <= 0;
    end

    else begin
        case (state)

            IDLE: begin
                index <= 0;          // Start with pixel 0

                if (start)
                    state <= RUN;    // Begin processing window
            end

            RUN: begin
                if (index == 8)
                    state <= DONE;   // All 9 pixels processed
                else
                    index <= index + 1; // Move to next pixel
            end

            DONE: begin
                state <= IDLE;       // Ready for next window
            end

            default: state <= IDLE;

        endcase
    end
end

// Control signals sent to the MAC and testbench
assign clear  = reset || (state == IDLE && start); // Clear total before each window
assign enable = (state == RUN);                    // Calculate only while RUN
assign done   = (state == DONE);                   // Output is ready

endmodule
