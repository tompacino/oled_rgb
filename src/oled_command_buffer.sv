`timescale 1ns / 1ns

// Discards commands if the buffer is full (violates handshake)

module oled_command_buffer #(
    parameter BUFFER_MAX = 1024,        // maximum number of serial commands that can be buffered
    parameter COMMAND_W  = 8            // bit width of serial commands
    )
    (
        input wire                  rst_n,
        input wire                  clk,
        input wire                  write_en,
        input wire [COMMAND_W-1:0]  write_command,
        input wire                  read_en,

        output wire [COMMAND_W-1:0] read_command,
        output wire                 commands_empty,
        output wire                 commands_full
    );

    logic full;
    logic empty;

    logic read_en_b;
    logic write_en_b;

    assign commands_empty   = empty;
    assign commands_full    = full;

    assign write_en_b       = write_en && !full;
    assign read_en_b        = read_en && !empty;

    fifo #(COMMAND_W, BUFFER_MAX) fifo_I
    (
        .rst_n(rst_n),
        .clk(clk),
        .write_en(write_en_b),
        .data_in(write_command),
        .read_en(read_en_b),
        .data_out(read_command),
        .full(full),
        .empty(empty),
        /* verilator lint_off PINCONNECTEMPTY */
        .almost_full(),
        .almost_empty()
        /* verilator lint_on PINCONNECTEMPTY */
    );

endmodule : oled_command_buffer
