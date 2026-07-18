`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2026 04:39:33 AM
// Design Name: 
// Module Name: tb_apb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_apb;

    localparam int ADDR_WIDTH = 32;
    localparam int DATA_WIDTH = 32;

    logic                    CLK;
    logic                    RSTn;
    logic                    transfer;
    logic                    write;
    logic [ADDR_WIDTH-1:0]   addr_in;
    logic [DATA_WIDTH-1:0]   data_in;
    logic [DATA_WIDTH-1:0]   data_out;
    logic                    ready_out;
    logic                    error_out;

    apb_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .CLK(CLK),
        .RSTn(RSTn),
        .transfer(transfer),
        .write(write),
        .addr_in(addr_in),
        .data_in(data_in),
        .data_out(data_out),
        .ready_out(ready_out),
        .error_out(error_out)
    );

    // Clock Generation
    always #5 CLK = ~CLK;

    task automatic reset_sequence();
        CLK       = 0;
        RSTn      = 0;
        transfer  = 0;
        write     = 0;
        addr_in   = '0;
        data_in   = '0;
        #20;
        RSTn      = 1;
        #10;
    endtask

    task automatic apb_write(input logic [ADDR_WIDTH-1:0] waddr, input logic [DATA_WIDTH-1:0] wdata);
        @(posedge CLK);
        transfer = 1'b1;
        write    = 1'b1;
        addr_in  = waddr;
        data_in  = wdata;
        
        @(posedge CLK);
        wait(ready_out);
        @(posedge CLK);
        transfer = 1'b0;
        write    = 1'b0;
    endtask

    task automatic apb_read(input logic [ADDR_WIDTH-1:0] raddr);
        @(posedge CLK);
        transfer = 1'b1;
        write    = 1'b0;
        addr_in  = raddr;
        
        @(posedge CLK);
        wait(ready_out);
        $display("[READ OUT] Address: 0x%0h | Data Returned: 0x%0h | Error Check: %b", raddr, data_out, error_out);
        @(posedge CLK);
        transfer = 1'b0;
    endtask

    initial begin
        $display("Starting SystemVerilog APB Compliance Testbench Pipeline...");
        reset_sequence();

        // Testcase 1: Standard Write Sequences to Slave Memory 
        $display("\n--- Executing Valid Write Sequences ---");
        apb_write(32'h0000_0004, 32'hDEAD_BEEF);
        apb_write(32'h0000_0008, 32'hCAFE_BABE);

        // Testcase 2: Standard Read Sequences
        $display("\n--- Executing Valid Read Sequences ---");
        apb_read(32'h0000_0004);
        apb_read(32'h0000_0008);

        // Testcase 3: Boundary Test Generating Out-of-Bounds Error Response (PSLVERR Assertion)
        $display("\n--- Testing Invalid Bounds (PSLVERR Expected) ---");
        apb_read(32'h0000_0FFF); // Exceeds defined MEM_DEPTH limit (256)

        #50;
        $display("\nSimulation Complete.");
        $finish;
    end

endmodule
