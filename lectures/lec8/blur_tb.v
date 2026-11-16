
`timescale 1ns/1ps

module blur_tb;

    parameter W = 128;
    parameter H = 128;

    reg clk = 0;
    always #5 clk = ~clk;       // clock period = 10 ns

    reg reset = 1;
    reg start = 0;
    reg [71:0] window = 0;      // nine 8-bit pixels

    wire [7:0] result;
    wire done;

    reg [7:0] image [0:W*H-1];  // store image pixels

    integer row, col, k;
    integer pixel_row, pixel_col;
    integer file_handle;

    // Connect our convolution accelerator
    conv3x3 dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .mode(1'b0),            // 0 = Gaussian Blur
        .window(window),
        .result(result),
        .done(done)
    );

    initial begin

        $readmemh("input_image.mem", image);  // /oad image
        repeat (2) @(negedge clk);
        reset = 0;

        file_handle = $fopen("blur_output.mem", "w");
        if (file_handle == 0) begin
            $display("ERROR: Cannot open output file");
            $finish;
        end

        // SLIDING WINDOW

        for (row = 0; row < H-2; row = row + 1) begin
            for (col = 0; col < W-2; col = col + 1) begin
				
					// window iteration below
                for (k = 0; k < 9; k = k + 1) begin
                    pixel_row = row + k / 3;
                    pixel_col = col + k % 3;

                    window[k*8 +: 8] = image[pixel_row*W + pixel_col]; // select pixel from image
                end

                @(negedge clk);
                start = 1;              // start calculation

                @(negedge clk);
                start = 0;					 // stop calculation

                wait (done == 1);       // wait for 9 MAC operations
                #1;

                $fdisplay(file_handle, "%02h", result);

                @(negedge clk);         // Allow FSM to return to IDLE
            end
        end

        $fclose(file_handle);
        $display("Gaussian blur complete!");
        $finish;

    end

endmodule
