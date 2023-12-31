`timescale 1ns / 1ns

// DRAM

module oled_power_on_spi#(
    parameter DATA_WIDTH    = 8,
    parameter DATA_DEPTH    = 64,
    localparam DATA_DEPTH_W = $clog2(DATA_DEPTH)
    )
    (
        input wire                      rst_n,
        input wire                      clk,
        input wire                      read_en,
        output wire [DATA_WIDTH-1:0]    data_out,
        output wire                     done
    );

    logic [DATA_WIDTH-1:0]      ram [DATA_DEPTH-1:0];
    logic [DATA_DEPTH_W-1:0]    read_ptr_r;

    logic [DATA_DEPTH_W-1:0]    read_ptr_b;

    assign data_out = ram[read_ptr_r];
    assign done     = (read_ptr_r == 46);

    always_comb
    begin
        // Increment read ptr
        read_ptr_b      = read_ptr_r;
        if (read_en)
            read_ptr_b  = (read_ptr_r == 46) ? 0 : read_ptr_r + 1;
    end

    always_ff @(posedge clk)
    begin
        if (!rst_n)
        begin
            read_ptr_r          <= 0;
            // PRELOAD RAM WITH POWER ON SPI COMMANDS
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
            ram[41]             <= 8'h25;
            ram[42]             <= 8'h00;
            ram[43]             <= 8'h00;
            ram[44]             <= 8'h5F;
            ram[45]             <= 8'h3F;
            ram[46]             <= 8'hAF;
        end
        else
        begin
            read_ptr_r          <= read_ptr_b;
        end
    end

endmodule : oled_power_on_spi
