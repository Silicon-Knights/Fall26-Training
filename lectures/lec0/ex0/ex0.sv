

// Module Declaration
// declares module name and I/O
//

module ex0 (
   input logic a, b,
   output logic c 
);

logic parta, partb;

// Assign statement
// | or, & and
// assign c = a & b;
// assign c = a | b;

assign parta = !a & b;
assign partb = !b & a;
assign c = parta | partb;

endmodule 


`timescale 1ns/1ps;

module ex0_tb ();

logic a_tb, b_tb;
logic c_tb;

ex0 dut (
    .a(a_tb),
    .b(b_tb),
    .c(c_tb)
    );

    initial begin
        $dumpfile("ex0_tb.vcd");
        $dumpvars(0, ex0_tb);
        b_tb = 0;
        a_tb = 0;
    end 

    always begin
        #5;
        a_tb = 1;
        #5;
        a_tb = 0;
    end

    always begin
        #10;
        b_tb = 0;
        #10;
        b_tb = 1;
    end
    
    always begin
        #100;
        $finish;
    end

endmodule
