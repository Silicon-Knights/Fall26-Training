// ==========================================
// MAC = Multiply and Accumulate
//
// On each clock cycle:
// 1. Multiply a pixel by its weight.
// 2. Add the answer to the running total.
//
// clear  = Start a new calculation
// enable = Allow multiplication and addition
// ==========================================

module mac (
    /*input or output?*/ clk,
    /*input or output?*/ clear,
    /*input or output?*/ enable,
    /*input or output?*/ signed [9:0] pixel, // 10 bit (8 bit number + 2 buffer bits)
    /*input or output?*/ signed [3:0] weight, // weight range is -2 to 2, so 4 bits
    /*input or output?*/ reg signed [15:0] total // 16 bits (big to store running sum)
);

always @(posedge clk) begin

    if (clear)
        total <= 0;
    else if (enable)
        total <=  // add actual MAC logic 

end

endmodule
