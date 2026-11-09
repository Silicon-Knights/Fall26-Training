`timescale 1ns/1ps

module register_file_tb;

reg clk;
reg reset;
reg write_enable;

reg [1:0] read_addr1, read_addr2;
reg [1:0] write_addr;
reg [7:0] write_data;

wire [7:0] read_data1, read_data2;

register_file uut (
    .clk(clk),
    .reset(reset),
    .write_enable(write_enable),
    .read_addr1(read_addr1),
    .read_addr2(read_addr2),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Generate clock: switches every 5 ns
always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;
    write_enable = 0;

    read_addr1 = 0;
    read_addr2 = 1;
    write_addr = 0;
    write_data = 0;

    // STEP 1: Reset all registers
    #10;
    reset = 0;

    // STEP 2: Write 12 into R0
    write_enable = 1;
    write_addr = 2'b00;
    write_data = 12;
    #10;

    // STEP 3: Write 3 into R1
    write_addr = 2'b01;
    write_data = 3;
    #10;

    // STEP 4: Read R0 and R1
    write_enable = 0;
    read_addr1 = 2'b00;
    read_addr2 = 2'b01;
    #10;

    $display("R0 = %d", read_data1);
    $display("R1 = %d", read_data2);

    // Expected:
    // R0 = 12
    // R1 = 3


    // =====================================
    // CHALLENGE
    //
    // 1. Write 25 into R2
    // 2. Write 50 into R3
    // 3. Read R2 and R3
    // 4. Display their values
    //
    // Uncomment and complete!
    // =====================================

    /*
    write_enable = 1;

    write_addr = 2'b;
    writedata = ;
    #10;

    write_addr = 2'b;
    writedata = ;
    #10;

    write_enable = 0;

    read_addr1 = 2'b;
    read_addr2 = 2'b;
    #10;

    $display("R2 = %d", read_data1);
    $display("R3 = %d", read_data2);
    */

    $finish;
end

endmodule