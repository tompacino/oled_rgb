`timescale 1ns / 1ns

module oled_serial_driver #(
    parameter DATA_WIDTH = 8,
    localparam DATA_WIDTH_W = $clog2(DATA_WIDTH)
    )
    (
        input wire                  rst_n,
        input wire                  sclk,

        input wire [DATA_WIDTH-1:0] sdata,
        input wire                  sdata_valid,

        output wire                 ready,
        output wire                 mosi,
        output wire                 cs
    );

    logic ready_b;
    logic ready_r;
    logic [DATA_WIDTH_W:0] count_b;
    logic [DATA_WIDTH_W:0] count_r;

    logic cs_b;
    logic cs_r;
    logic [DATA_WIDTH-1:0] data_out_b;
    logic [DATA_WIDTH-1:0] data_out_r;

    assign ready = ready_r;
    assign cs = cs_r;
    assign mosi = data_out_r[0]; // serial data is LSB first

    always_comb
    begin
        ready_b         = ready_r;
        count_b         = count_r;
        cs_b            = cs_r;
        data_out_b      = data_out_r;
        if (sdata_valid && ready_r)
        begin
            // start count
            ready_b     = 0;
            count_b     = count_r + 1;
            cs_b        = 0;
            data_out_b  = sdata;
        end
        else if (count_r > 0)
        begin
            // counting
            data_out_b  = data_out_r >> 1;
            count_b     = count_r + 1;
            if (count_r == 8)
            begin
                // end of transmission
                ready_b = 1;
                count_b = 0;
                cs_b    = 1;
            end
        end
    end

    always_ff @(posedge sclk)
    begin
        if (!rst_n)
        begin
            ready_r <= 0;
            count_r <= 0;
            cs_r <= 0;
            data_out_r <= 0;
        end
        else
        begin
            ready_r <= ready_b;
            count_r <= count_b;
            cs_r <= cs_b;
            data_out_r <= data_out_b;
        end
    end

endmodule : oled_serial_driver
