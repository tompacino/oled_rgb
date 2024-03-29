`timescale 1ns / 1ns
/**
    - The display controller operates in SPI Mode 3 (clock idles on logic high, data is captured on the clock rising edge, and data is transferred on the clock falling edge) and with a minimum clock cycle time of 150 ns (as per table 21 of the SSD1331 datasheet). The embedded display only supports SPI write, so users will not be able to receive any information back from the display over SPI.

    - By driving and keeping the Chip Select (CS) line at a logic level low, users may send both commands and data streams to the display controller based on the state of the Data/Command (D/C) pin

    - The VCCEN control (pin 9) toggles the positive voltage supply to the screen itself and the PMODEN control (pin 10) toggles the power supply ground to the display. Users may turn off either one of these controls to reduce the power consumption of the Pmod OLEDrgb to approximately 200 nA.
*/

module oled_controller(
        input wire          rst_n,                   // active low reset
        input wire          sclk,                    // serial clock

        /* verilator lint_off UNUSED */

        input wire          command_in_valid,       // high when command_valid SPI command received
        input wire [7:0]    command_in,             // SPI command sent
        output wire         command_in_ready,       // assert high when ready for new SPI comm

        /* verilator lint_off UNDRIVEN */
        output wire         cs,                     // chip select
        output wire         mosi,                   // master out slave in
        /* verilator lint_on UNDRIVEN */

        output wire         dc_c,                   // data/command control
        output wire         res,                    // power reset
        output wire         vss_en,                 // vcc enable
        output wire         pmod_en                 // vdd logic voltage control

        /* verilator lint_on UNUSED */
    );

    typedef enum
    {
        IDLE,
        POWER_ON,
        POWER_ON_SPI,
        READY,
        OUTPUT_COMMAND_SERIAL,
        POWER_OFF
    } state;

    /* verilator lint_off UNUSED */
    /* verilator lint_off PINCONNECTEMPTY */

    state       state_b;
    state       state_r;

    logic       start_pwr_on_b;
    logic       pwr_on_done_b;

    logic       start_pwr_on_spi_b;
    logic       pwr_on_spi_done_b;
    logic [7:0] pwr_on_spi_command_out;

    logic       read_command_b;
    logic [7:0] command_out;
    logic       command_out_valid_b;
    logic       commands_empty;
    logic       commands_full;

    logic [7:0] mux_dout;
    logic       mux_valid;

    oled_power_on #(200000000,1) oled_power_on_I (
        .rst_n(rst_n),
        .sclk(sclk),
        .start(start_pwr_on_b),
        .done(pwr_on_done_b),
        .dc_c(dc_c),
        .res(res),
        .vss_en(vss_en),
        .pmod_en(pmod_en)
    );

    oled_power_on_spi #(8, 64) oled_power_on_spi_I (
        .rst_n(rst_n),
        .clk(sclk),
        .read_en(),
        .data_out(pwr_on_spi_command_out),
        .done(pwr_on_spi_done_b)
    );

    oled_command_buffer #(1024, 8) oled_command_buffer_I (
        .rst_n(rst_n),
        .clk(sclk),
        .write_en(command_in_valid),
        .write_command(command_in),
        .read_en(read_command_b),
        .read_command(command_out),
        .commands_empty(commands_empty),
        .commands_full(commands_full)
    );

    mux #(8, 2) mux_valid_I (
        .sel(),
        .din('{pwr_on_spi_command_out, command_out}),
        .dout(mux_dout)
    );

    mux #(1, 2) mux_data_I (
        .sel(),
        .din(),
        .dout(mux_valid)
    );

    oled_serial_driver #(8) oled_serial_driver_I (
        .rst_n(rst_n),
        .sclk(sclk),
        .sdata(),
        .sdata_valid(),
        .ready(),
        .mosi(mosi),
        .cs(cs)
    );

    // Command buffer should accept new commands so long as it isn't full
    assign command_in_ready            = !commands_full && (state_b == READY);
    assign command_out_valid_b      = !commands_empty && read_command_b;

    always_comb
    begin
        state_b                     = state_r;
        start_pwr_on_b              = 0;
        start_pwr_on_spi_b          = 0;
        read_command_b              = 0;
        case (state_r)
            IDLE:
            begin
                state_b             = POWER_ON;
                start_pwr_on_b      = 1;
            end
            POWER_ON:
            begin
                start_pwr_on_b      = 0;
                if (pwr_on_done_b)
                begin
                    state_b         = POWER_ON_SPI;
                    start_pwr_on_spi_b = 1;
                end
            end
            POWER_ON_SPI:
            begin
                start_pwr_on_spi_b  = 0;
                read_command_b      = 1;
                if (pwr_on_spi_done_b)
                begin
                    state_b         = READY;
                end
            end
            READY:
            begin
                if (command_in_valid)
                begin
                    state_b         = OUTPUT_COMMAND_SERIAL;
                    read_command_b  = 0;
                end
            end
            OUTPUT_COMMAND_SERIAL:
                state_b             = READY;
        endcase
    end

    always_ff @(posedge sclk)
    begin
        if (!rst_n)
        begin
            state_r                 <= IDLE;
        end
        else
        begin
            state_r                 <= state_b;
        end
    end

endmodule : oled_controller
