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
            // PRELOAD RAM WITH POWER ON COMMANDS
            ram[0]              <= 8'hFD;
            ram[1]              <= 8'h12;
            ram[2]              <= 8'hAE;
            ram[3]              <= 8'hA0;
            ram[4]              <= 8'h72;
            ram[5]              <= 8'hA1;
            ram[6]              <= 8'h00;
            ram[7]              <= 8'hA2;
            ram[8]              <= 8'h00;
            ram[9]              <= 8'hA4;
            ram[10]             <= 8'hA8;
            ram[11]             <= 8'h3F;
            ram[12]             <= 8'hAD;
            ram[13]             <= 8'h8E;
            ram[14]             <= 8'hB0;
            ram[15]             <= 8'h0B;
            ram[16]             <= 8'hB1;
            ram[17]             <= 8'h31;
            ram[18]             <= 8'hB3;
            ram[19]             <= 8'hF0;
            ram[21]             <= 8'h8A;
            ram[22]             <= 8'h64;
            ram[23]             <= 8'h8B;
            ram[24]             <= 8'h78;
            ram[25]             <= 8'h8C;
            ram[26]             <= 8'h64;
            ram[27]             <= 8'hBB;
            ram[28]             <= 8'h3A;
            ram[29]             <= 8'hBE;
            ram[31]             <= 8'h3E;
            ram[32]             <= 8'h87;
            ram[33]             <= 8'h06;
            ram[34]             <= 8'h81;
            ram[35]             <= 8'h91;
            ram[36]             <= 8'h82;
            ram[37]             <= 8'h50;
            ram[38]             <= 8'h83;
            ram[39]             <= 8'h7D;
            ram[40]             <= 8'h2E;
            ram[40]             <= 8'h25;
            ram[40]             <= 8'h00;
            ram[40]             <= 8'h00;
            ram[40]             <= 8'h5F;
            ram[40]             <= 8'h3F;
            ram[40]             <= 8'hAF;
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
