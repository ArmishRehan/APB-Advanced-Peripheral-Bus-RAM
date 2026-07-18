`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2026 04:35:49 AM
// Design Name: 
// Module Name: apb_slave
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


module apb_slave #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int MEM_DEPTH  = 256
)(
    input  logic                    PCLK,
    input  logic                    PRESETn,

    input  logic [ADDR_WIDTH-1:0]   PADDR,
    input  logic                    PSEL,
    input  logic                    PENABLE,
    input  logic                    PWRITE,
    input  logic [DATA_WIDTH-1:0]   PWDATA,
    output logic [DATA_WIDTH-1:0]   PRDATA,
    output logic                    PREADY,
    output logic                    PSLVERR
);

    // Internal Memory Array
    logic [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];

    // Address Decode Boundary Checks
    logic valid_address;
    assign valid_address = (PADDR < MEM_DEPTH);

    // APB Slave Response Logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA  <= '0;
            PSLVERR <= 1'b0;
        end else begin
            if (PSEL && !PENABLE) begin
                // SETUP Phase Evaluation
                PSLVERR <= !valid_address;
            end else if (PSEL && PENABLE && PREADY) begin
                // ACCESS Phase execution
                if (valid_address) begin
                    if (PWRITE) begin
                        memory[PADDR] <= PWDATA;
                    end else begin
                        PRDATA        <= memory[PADDR];
                    end
                    PSLVERR <= 1'b0;
                end else begin
                    PSLVERR <= 1'b1; // Error if accessing out of bounds
                end
            end
        end
    end

    assign PREADY = PSEL; 

endmodule
