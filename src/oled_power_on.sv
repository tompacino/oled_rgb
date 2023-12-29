`timescale 1ns / 1ns

// Performs the OLED power on sequence for control signals

module oled_power_on #(
    parameter CLOCK_FREQUENCY_HZ=200000000,
    parameter DEBUG=0, // changes all timers to 10 us
    localparam CLOCK_COUNT_W=32,
    localparam WAIT_POWER_STABLE_US=20000,
    localparam WAIT_RESET_US=3
    )
    (
        input wire          rst_n,                  // active low reset
        input wire          sclk,                   // serial clock

        input wire          start,                  // high when valid SPI command received
        output wire         done,                   // assert high when power on sequence is done

        output wire         dc_c,                   // master out slave in
        output wire         res,                    // power reset
        output wire         vss_en,                 // vcc enable
        output wire         pmod_en                 // vdd logic voltage control
    );

    typedef enum
    {
        IDLE,
        START_SEQUENCE,
        SET_CONTROL,
        DISABLE_RESET,
        DISABLE_VCC,
        WAIT_POWER_STABLE,
        SET_RESET,
        WAIT_RESET,
        DONE
    } state;

    state state_b;
    state state_r;

    logic start_r;
    logic done_b;
    logic done_r;

    logic dc_c_b;
    logic dc_c_r;
    logic res_b;
    logic res_r;
    logic vss_en_b;
    logic vss_en_r;
    logic pmod_en_b;
    logic pmod_en_r;

    logic timer_update_match_b;
    logic [CLOCK_COUNT_W-1:0] timer_match_b;
    logic timer_done;


    timer_microseconds #(CLOCK_FREQUENCY_HZ, CLOCK_COUNT_W) timer_microseconds_I
    (
        .rst_n(rst_n),
        .clk(sclk),
        .update_match(timer_update_match_b),
        .match(timer_match_b),
        .done(timer_done)
    );

    always_comb
    begin
        if (start && !start_r)
            state_b         = START_SEQUENCE;
        else
        begin
            state_b         = state_r;
            // Outputs
            dc_c_b          = dc_c_r;
            res_b           = res_r;
            vss_en_b        = vss_en_r;
            pmod_en_b       = pmod_en_r;
            done_b          = done_r;
            // Timer
            timer_update_match_b   = 0;
            timer_match_b   = 0;
            case (state_r)
                START_SEQUENCE:
                begin
                    state_b = SET_CONTROL;
                    dc_c_b  = 0;
                end
                SET_CONTROL:
                begin
                    state_b = DISABLE_RESET;
                    res_b   = 1;
                end
                DISABLE_RESET:
                begin
                    state_b = DISABLE_VCC;
                    vss_en_b = 0;
                end
                DISABLE_VCC:
                begin
                    state_b = WAIT_POWER_STABLE;
                    pmod_en_b   = 1;
                    // Start a 20ms=20000us timer to wait for stable power
                    timer_update_match_b = 1;
                    timer_match_b = (DEBUG) ? 10 : WAIT_POWER_STABLE_US;
                end
                WAIT_POWER_STABLE:
                begin
                    if (timer_done)
                    begin
                        state_b = SET_RESET;
                        res_b = 0;
                        // Start a 3us timer to hold reset low
                        timer_update_match_b = 1;
                        timer_match_b = WAIT_RESET_US;
                    end
                end
                SET_RESET:
                begin
                    if (timer_done)
                    begin
                        state_b = WAIT_RESET;
                        res_b = 1;
                        // Start a 3us timer to wait for reset to complete
                        timer_update_match_b = 1;
                        timer_match_b = WAIT_RESET_US;
                    end
                end
                WAIT_RESET:
                begin
                    if (timer_done)
                    begin
                        state_b = DONE;
                        done_b  = 1;
                    end
                end
                DONE:
                begin
                    state_b = IDLE;
                    done_b  = 0;
                end
            endcase
        end
    end

    assign dc_c     = dc_c_r;
    assign res      = res_r;
    assign vss_en   = vss_en_r;
    assign pmod_en  = pmod_en_r;
    assign done     = done_r;

    always_ff @(posedge sclk)
    begin
        if (!rst_n)
        begin
            state_r         <= IDLE;

            start_r         <= 0;
            done_r          <= 0;

            dc_c_r          <= 0;
            res_r           <= 0;
            vss_en_r        <= 0;
            pmod_en_r       <= 0;
        end
        else begin
            state_r         <= state_b;

            start_r         <= start;
            done_r          <= done_b;

            dc_c_r          <= dc_c_b;
            res_r           <= res_b;
            vss_en_r        <= vss_en_b;
            pmod_en_r       <= pmod_en_b;
        end
    end

endmodule : oled_power_on
