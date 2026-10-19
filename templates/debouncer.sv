// debouncer template
module debouncer #(
    parameter int CLK_FREQ_HZ = 125_000_000,
    parameter int DEBOUNCE_MS = 50
)(
    input  logic clk,
    input  logic d,
    output logic q = 0
);

localparam int COUNT_MAX = (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;
localparam int COUNT_WIDTH = (COUNT_MAX > 1) ? $clog2(COUNT_MAX) : 1;

logic [COUNT_WIDTH-1:0] counter = '0;
logic d_meta = 0;
logic d_sync = 0;

always_ff @(posedge clk) begin
    // Synchronize asynchronous input
    d_meta <= d;
    d_sync <= d_meta;

    // Input matches current output
    if (d_sync == q) begin
        counter <= '0;
    end
    // Input has remained different long enough
    else if (counter == COUNT_MAX - 1) begin
        q <= d_sync;
        counter <= '0;
    end
    // Count consecutive cycles of disagreement
    else begin
        counter <= counter + 1'b1;
    end
end

endmodule

