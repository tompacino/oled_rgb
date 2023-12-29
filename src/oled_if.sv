`timescale 1ns / 1ns

interface oled_if();

    logic cs;       // serial clock
    logic mosi;     // chip select
    logic dc_c;     // master out slave in
    logic res;      // power reset
    logic vss_en;   // vcc enable
    logic pmod_en;  // vdd logic voltage control

    modport master (
        output cs, mosi, dc_c, res, vss_en, pmod_en
    );

    modport slave (
        input cs, mosi, dc_c, res, vss_en, pmod_en
    );

endinterface : oled_if
