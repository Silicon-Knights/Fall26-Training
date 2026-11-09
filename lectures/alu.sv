module alu (
    /* input or output? */  [7:0] A,
    /* input or output? */  [7:0] B,
    /* input or output? */  [2:0] opcode,
    /* input or output? */ reg [7:0] result
);

always @(*) begin
    case (opcode)
        // implement the operations for each of the opcodes!
        default: result = 8'b0;
    endcase
end

endmodule
