module ex0 (
    input logic b, clk,
    output logic c
);

logic a;

always_ff @(posedge clk) begin
    a <= b;
    c <= a;
end
endmodule

module ex1 (
    input logic b, clk,
    output logic c
);

logic a;

always_ff @(posedge clk) begin
    a = b;
    c = a;
end
endmodule

module tb ();

logic clk, a, b, c0, c1;

ex0 dut0 (
    .b(b),
    .c(c0),
    .clk(clk)
);

ex1 dut1 (
    .b(b),
    .c(c1),
    .clk(clk)
);

initial begin
    $dumpfile("output.vcd");
    $dumpvars(0, tb);
    a = 0;
    b = 0;
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
    a = 0;
    #12;
    a = 1;
    #12;
end

always begin
    b = 0;
    #24;
    b = 1;
    #24;
end
endmodule
