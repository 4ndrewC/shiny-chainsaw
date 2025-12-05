`timescale 1ns/1ps

module tb_nn;

    logic clk;
    logic [2:0] layer;
    logic [15:0] in;
    logic [15:0] out;

    nn dut (
        .clk(clk),
        .layer(layer),
        .in(in),
        .out(out)
    );

    always #5 clk = ~clk; 

    initial begin

        clk = 0;
        in = 16'h0003;
        layer = 0;

        #20;
        layer = 1;

        #20;
        layer = 2;

        #20;
        $finish;
    end

endmodule
