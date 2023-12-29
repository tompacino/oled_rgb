`timescale 1ns / 1ns

module timer_microseconds #(
    parameter CLOCK_FREQUENCY_HZ    = 200000000,
    parameter CLOCK_COUNT_W         = 32
    )
    (
        input wire                      rst_n, // active low reset
        input wire                      clk,
        input wire                      update_match,
        input wire [CLOCK_COUNT_W-1:0]  match,
        output wire                     done
    );

    logic [CLOCK_COUNT_W-1:0] counter_b;
    logic [CLOCK_COUNT_W-1:0] counter_r;

    logic done_b;
    logic done_r;

    logic microsecond_flag;

    timer_microsecond #(CLOCK_FREQUENCY_HZ) timer_microsecond_I
        (
        .rst_n(rst_n),
        .clk(clk),
        .flag(microsecond_flag)
        );

    always_comb
    begin
        counter_b               = counter_r;
        done_b                  = 0;
        if (update_match)
            // Update match
            counter_b           = match;
        else
        begin
            // Counting...
            if (counter_r != 0)
            begin
                if (microsecond_flag)
                    counter_b   = counter_r - 1;
                if (counter_b == 0)
                    done_b      = 1;
            end
            // Finished counting
            else
                done_b          = 0;
        end
    end

    assign done = done_r;

    always_ff @(posedge clk)
    begin
        if (!rst_n)
        begin
            counter_r       <= 0;
            done_r          <= 0;
        end
        else
        begin
            counter_r       <= counter_b;
            done_r          <= done_b;
        end
    end

endmodule : timer_microseconds
