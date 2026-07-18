`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2026 04:37:28 AM
// Design Name: 
// Module Name: apb_top
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

module apb_top #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    input  logic                    CLK,
    input  logic                    RSTn,
    
    input  logic                    transfer,
    input  logic                    write,
    input  logic [ADDR_WIDTH-1:0]   addr_in,
    input  logic [DATA_WIDTH-1:0]   data_in,
    output logic [DATA_WIDTH-1:0]   data_out,
    output logic                    ready_out,
    output logic                    error_out
);

    logic [ADDR_WIDTH-1:0] apb_paddr;
    logic                  apb_psel;
    logic                  apb_penable;
    logic                  apb_pwrite;
    logic [DATA_WIDTH-1:0] apb_pwdata;
    logic [DATA_WIDTH-1:0] apb_prdata;
    logic                  apb_pready;
    logic                  apb_pslverr;

    apb_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_inst (
        .PCLK(CLK),
        .PRESETn(RSTn),
        .transfer(transfer),
        .write(write),
        .addr_in(addr_in),
        .data_in(data_in),
        .data_out(data_out),
        .ready_out(ready_out),
        .error_out(error_out),
        .PADDR(apb_paddr),
        .PSEL(apb_psel),
        .PENABLE(apb_penable),
        .PWRITE(apb_pwrite),
        .PWDATA(apb_pwdata),
        .PRDATA(apb_prdata),
        .PREADY(apb_pready),
        .PSLVERR(apb_pslverr)
    );

    apb_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(256)
    ) slave_inst (
        .PCLK(CLK),
        .PRESETn(RSTn),
        .PADDR(apb_paddr),
        .PSEL(apb_psel),
        .PENABLE(apb_penable),
        .PWRITE(apb_pwrite),
        .PWDATA(apb_pwdata),
        .PRDATA(apb_prdata),
        .PREADY(apb_pready),
        .PSLVERR(apb_pslverr)
    );

endmodule
