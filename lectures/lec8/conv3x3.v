
/*
3x3 CONVOLUTION ACCELERATOR

Applies one filter to a 3x3 image window.

mode = 0: Gaussian blur
mode = 1: Sobel edge detection

The controller selects each of the 9 pixels.
The MAC multiplies and adds each pixel's weight.
After 9 clock cycles, we get one output pixel.
*/

module conv3x3 (
    input clk,
    input reset,
    input start,
    input mode,
    input [71:0] window,
    output reg [7:0] result,
    output done
);

wire [3:0] index;
wire clear, enable;
wire signed [15:0] total;

wire [7:0] pixel;
reg signed [3:0] weight;

// Select one 8-bit pixel from our 72-bit window.
// index 0 -> bits [7:0], index 1 -> [15:8], etc.
assign pixel = window[index*8 +: 8];


// Choose the weight for the current pixel
always @(*) begin
    // gaussian blur below
    if (mode == 0) begin
        case (index)
            // set each value from 0 -> 8 to the right weight value for the filter ************************
            default: weight = 0;
        endcase

    // edge detector below
    end else begin
        case (index)
            // set each value from 0 -> 8 to the right weight value for the filter ************************
            default: weight = 0;
        endcase

    end
end


// Controller: selects pixels 0-8 and controls the MAC
// add conv_controller module instance, with all the right inputs/outputs, name it "controller". ************************


// MAC: multiply pixel by weight, then add to total
mac datapath (
    .clk(clk),
    .clear(clear),
    .enable(enable),
    .pixel({2'b00, pixel}),
    .weight(weight),
    .total(total)
);


// Convert the final sum into a grayscale pixel (0-255), up to 16 bits to account for overflows
reg [15:0] magnitude;
reg [15:0] scaled;


// post processing for pixel values, such as absolute value, scalars, and brightness cap
always @(*) begin

    // Negative Sobel results should also show edges
    // add if, else logic to check if our acculmated total is negative. if so, make it positive... ************************
    // assign the signed total to magnitude in this block

    if (mode == 0)
        scaled = $unsigned(total) >> // factor in the scalar from the gaussian blur ************************
    else
        scaled = magnitude >> 2;        // Sobel: divide by 4

    // Prevent pixel brightness from exceeding 255
    if (scaled > 255)
        result = 255;
    else
        result = scaled[7:0];

end

endmodule
