module mux2 (
    input logic a, b,
    input logic sel,
    output c
);

always_comb begin

    if (sel == 1'b0) begin
        c = a;
    end else begin
        c = b;
    end
end

// Another way of doing Mux with assign
 //assign c = sel == 0 ? a : b;

endmodule


