
// Module Declaration
module comb (
   input logic a, b,
   output logic c 
);

// Combinational Assign 
assign c = a & b;

// Always need an endmodule
endmodule



// Testbench - can be in separate file
module comb_tb ();

// signal declarations in testbench
logic a, b, c;

// entity instantiation
comb dut (
    .a(a),
    .b(b),
    .c(c)
);

// initial begin block, creates vcd file and initial stimuli
initial begin
    $dumpfile("basic.vcd");
    $dumpvars(0, comb_tb);
    a = 0;
    b = 0;
    #100;
    $finish;
end


// always blocks, run forever
always begin
    #5;
    a = 0;
    #5;
    a = 1;
end 

always begin
    #10;
    b = 0;
    #10;
    b = 1;
end

endmodule
