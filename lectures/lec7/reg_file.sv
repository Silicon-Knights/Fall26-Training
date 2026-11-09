module register_file (
    input clk,
    input reset,
    input write_enable,

    input [1:0] read_addr1,
    input [1:0] read_addr2,
    input [1:0] write_addr,

    input [7:0] write_data,

    output [7:0] read_data1,
    output [7:0] read_data2
);

// Four registers, each 8 bits wide
reg [7:0] registers [0:3];


// Write to registers on rising clock edge
always @(posedge clk or posedge reset) begin

    if (reset) begin
        // Clear all registers [set all registers to 0] (hint: use a for loop!)
    end

    else if (write_enable) begin
        registers[write_addr] <= write_data;
    end

end

// Read two registers simultaneously
assign read_data1 = /* fill in */;
assign read_data2 = /* fill in */ ;

endmodule