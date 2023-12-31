`timescale 1ns / 1ns

module mux #(
    parameter DATA_WIDTH = 8,
    parameter N=2
    )
    (
        input wire [$clog2(N)-1:0]      sel,
        input wire [DATA_WIDTH-1:0]     din [N-1:0],
        output wire [DATA_WIDTH-1:0]    dout
    );

    logic [DATA_WIDTH-1:0] data_b;

    assign dout = data_b;

    always_comb
    begin
        data_b = din[sel];
    end

endmodule : mux
