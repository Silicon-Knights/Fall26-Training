
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

    if (mode == 0) begin
        case (index)
            0: weight = 1;
            1: weight = 2;
            2: weight = 1;
            3: weight = 2;
            4: weight = 4;
            5: weight = 2;
            6: weight = 1;
            7: weight = 2;
            8: weight = 1;
            default: weight = 0;
        endcase

    end else begin
        case (index)
            0: weight = -1;
            1: weight =  0;
            2: weight =  1;
            3: weight = -2;
            4: weight =  0;
            5: weight =  2;
            6: weight = -1;
            7: weight =  0;
            8: weight =  1;
            default: weight = 0;
        endcase

    end
end


// Controller: selects pixels 0-8 and controls the MAC
conv_controller controller (
    .clk(clk),
    .reset(reset),
    .start(start),
    .clear(clear),
    .enable(enable),
    .done(done),
    .index(index)
);


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
    if (total < 0)
        magnitude = -total;
    else
        magnitude = total;

    if (mode == 0)
        scaled = $unsigned(total) >> 4;  // Blur: divide by 16
    else
        scaled = magnitude >> 2;        // Sobel: divide by 4

    // Prevent pixel brightness from exceeding 255
    if (scaled > 255)
        result = 255;
    else
        result = scaled[7:0];

end

endmodule
