`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2026 04:34:20 AM
// Design Name: 
// Module Name: apb_master
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

// APB Master Module
module apb_master #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    // System Signals
    input  logic                    PCLK,
    input  logic                    PRESETn,
    
    // Core Controller Interface
    input  logic                    transfer,
    input  logic                    write,
    input  logic [ADDR_WIDTH-1:0]   addr_in,
    input  logic [DATA_WIDTH-1:0]   data_in,
    output logic [DATA_WIDTH-1:0]   data_out,
    output logic                    ready_out,
    output logic                    error_out,

    // APB Bus Interface
    output logic [ADDR_WIDTH-1:0]   PADDR,
    output logic                    PSEL,
    output logic                    PENABLE,
    output logic                    PWRITE,
    output logic [DATA_WIDTH-1:0]   PWDATA,
    input  logic [DATA_WIDTH-1:0]   PRDATA,
    input  logic                    PREADY,
    input  logic                    PSLVERR
);

    localparam logic [1:0] IDLE   = 2'b00;
    localparam logic [1:0] SETUP  = 2'b01;
    localparam logic [1:0] ACCESS = 2'b10;

    logic [1:0] current_state, next_state;

    // State Register
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State Logic
    always_comb begin
        case (current_state)
            IDLE: begin
                if (transfer)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
            SETUP: begin
                next_state = ACCESS;
            end
            ACCESS: begin
                if (PREADY) begin
                    if (transfer)
                        next_state = SETUP;
                    else
                        next_state = IDLE;
                end else begin
                    next_state = ACCESS; // Hold state if slave inserts wait states
                end
            end
            default: next_state = IDLE;
        endcase
    end

    // Output Registers & Combinational Logic 
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PADDR    <= '0;
            PWRITE   <= 1'b0;
            PWDATA   <= '0;
            data_out <= '0;
        end else begin
            if (current_state == IDLE && transfer) begin
                PADDR  <= addr_in;
                PWRITE <= write;
                if (write) begin
                    PWDATA <= data_in;
                end
            end else if (current_state == ACCESS && PREADY && !PWRITE) begin
                data_out <= PRDATA;
            end
        end
    end

    // Assigning Control Signal States
    always_comb begin
        PSEL      = (current_state == SETUP || current_state == ACCESS);
        PENABLE   = (current_state == ACCESS);
        ready_out = (current_state == ACCESS) && PREADY;
        error_out = (current_state == ACCESS) && PREADY && PSLVERR;
    end

endmodule