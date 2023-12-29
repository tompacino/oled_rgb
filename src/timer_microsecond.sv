`timescale 1ns / 1ns

// Assert 'cycle' for one cycle every time a microsecond passes

module timer_microsecond#(
    parameter CLOCK_FREQUENCY_HZ=200000000,
    localparam MATCH=CLOCK_FREQUENCY_HZ/1000000,
    localparam CLOCK_COUNT_W    = $clog2(MATCH)
    )
    (
        input rst_n,    // active low rst_n
        input clk,
        output flag
    );

    /* verilator lint_off WIDTH */
    logic [CLOCK_COUNT_W-1:0] counter_r = MATCH;
    /* verilator lint_on WIDTH */

    assign flag = (counter_r == 0);

    always_ff @(posedge clk)
        counter_r <= (!rst_n) ? {CLOCK_COUNT_W{1'b1}} : counter_r + 1;

endmodule : timer_microsecond
