`timescale 1ns / 1ns

// FIFO implemented as dual port block ram with one clock
// Need to change this to correctly read mem initialisation

module fifo #(
    parameter DATA_WIDTH    = 8,
    parameter FIFO_DEPTH    = 1024,
    localparam FIFO_DEPTH_W = $clog2(FIFO_DEPTH)
    )
    (
    input wire                      rst_n,
    input wire                      clk,
    input wire                      write_en,
    input wire [DATA_WIDTH-1:0]     data_in,
    input wire                      read_en,
    output wire [DATA_WIDTH-1:0]    data_out,
    output wire                     full,
    output wire                     empty,
    output wire                     almost_full,
    output wire                     almost_empty
    );

    logic [DATA_WIDTH-1:0] ram [FIFO_DEPTH-1:0];
    logic [FIFO_DEPTH_W-1:0] write_ptr, read_ptr;

    assign full = (read_ptr == write_ptr);
    assign almost_full = (read_ptr == (write_ptr + 4));

    assign empty = (write_ptr == (read_ptr + 1));
    assign almost_empty = (write_ptr == (read_ptr + 4));

    assign data_out = ram[read_ptr];

    always_ff @(posedge clk)
    begin
        if (!rst_n)
        begin
            read_ptr            <= 0;
            write_ptr           <= 1;
        end
        else
        begin
            if (write_en)
            begin
                ram[write_ptr] <= data_in;
                write_ptr      <= write_ptr + 1;
            end
            if (read_en)
            begin
                read_ptr       <= read_ptr + 1;
            end
        end
    end

endmodule : fifo
