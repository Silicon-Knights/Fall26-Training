module ff (
    input logic d,
    input logic clk,
    output logic q
);

// always_comb
//
always_ff @(posedge clk) begin
    q <= d;
end

endmodule


module tb ();

logic clk, d, q;

ff dut (
    .d(d),
    .q(q),
    .clk(clk)
);

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    d = 0;
    clk = 0;
    #200;
    $finish;
end

always begin
    clk = 0;
    #4;
    clk = 1;
    #4;
end

always begin
    d = 0;
    #8;
    d = 1;
    #8;
end
endmodule


