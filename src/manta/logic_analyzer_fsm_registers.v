`default_nettype none
`timescale 1ns/1ps

module logic_analyzer_fsm_registers(
    input wire clk,

    // input port
    input wire [15:0] addr_i,
    input wire [15:0] wdata_i,
    input wire [15:0] rdata_i,
    input wire rw_i,
    input wire valid_i,

    // output port
    output reg [15:0] addr_o,
    output reg [15:0] wdata_o,
    output reg [15:0] rdata_o,
    output reg rw_o,
    output reg valid_o,

    // registers
    input wire [3:0] state,
    output reg [15:0] trigger_loc,
    output reg request_start,
    output reg request_stop,
    input wire [ADDR_WIDTH-1:0] read_pointer,
    input wire [ADDR_WIDTH-1:0] write_pointer
    );

    initial trigger_loc = 0;
    initial request_start = 0;
    initial request_stop = 0;

    parameter BASE_ADDR = 0;
    localparam MAX_ADDR = BASE_ADDR + 5;
    parameter SAMPLE_DEPTH = 0;
    parameter ADDR_WIDTH = $clog2(SAMPLE_DEPTH);

    always @(posedge clk) begin
        addr_o <= addr_i;
        wdata_o <= wdata_i;
        rdata_o <= rdata_i;
        rw_o <= rw_i;
        valid_o <= valid_i;

        // check if address is valid
        if( (valid_i) && (addr_i >= BASE_ADDR) && (addr_i <= MAX_ADDR)) begin

            // reads
            if(!rw_i) begin
                case (addr_i)
                    BASE_ADDR + 0: rdata_o <= state;
                    BASE_ADDR + 1: rdata_o <= trigger_loc;
                    BASE_ADDR + 2: rdata_o <= request_start;
                    BASE_ADDR + 3: rdata_o <= request_stop;
                    BASE_ADDR + 4: rdata_o <= read_pointer;
                    BASE_ADDR + 5: rdata_o <= write_pointer;
                endcase
            end

            // writes
            else begin
                case (addr_i)
                    BASE_ADDR + 1: trigger_loc <= wdata_i;
                    BASE_ADDR + 2: request_start <= wdata_i;
                    BASE_ADDR + 3: request_stop <= wdata_i;
                endcase
            end
        end
    end


endmodule
`default_nettype wire