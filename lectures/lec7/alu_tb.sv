`timescale 1ns/1ps

module alu_tb;

reg  [7:0] A, B;
reg  [2:0] opcode;
wire [7:0] result;

alu uut (
    .A(A),
    .B(B),
    .opcode(opcode),
    .result(result)
);

initial begin
    A = 12;
    B = 3;

    opcode = 3'b000; #10;
    $display("ADD: %d", result);

    opcode = 3'b001; #10;
    $display("SUB: %d", result);

    // implement tests for the rest of the instructions!

    $finish;
end

endmodule
